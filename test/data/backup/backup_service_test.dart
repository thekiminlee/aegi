import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/backup/backup_service.dart';
import 'package:aegi/data/local/local_database.dart' as local_db;
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/baby_log.dart' as baby_model;
import 'package:aegi/data/models/child_profile.dart' as child_model;
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart' as pregnancy_model;
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:aegi/data/repositories/baby_log_repository.dart';
import 'package:aegi/data/repositories/child_repository.dart';
import 'package:aegi/data/repositories/contraction_repository.dart';
import 'package:aegi/data/repositories/journal_repository.dart';
import 'package:aegi/data/repositories/pregnancy_repository.dart';
import 'package:aegi/data/repositories/settings_repository.dart';
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late local_db.LocalDatabase sourceDb;
  late DriftBackupService sourceBackupService;
  late DriftAppMetaRepository sourceMetaRepo;
  late DriftChildRepository sourceChildRepo;
  late DriftSettingsRepository sourceSettingsRepo;
  late DriftPregnancyRepository sourcePregnancyRepo;
  late DriftContractionRepository sourceContractionRepo;
  late DriftJournalRepository sourceJournalRepo;
  late DriftBabyLogRepository sourceBabyRepo;
  late Directory exportDir;

  setUp(() async {
    exportDir = await Directory.systemTemp.createTemp('aegi_backup_test_');
    sourceDb = local_db.LocalDatabase.forTesting(NativeDatabase.memory());
    sourceMetaRepo = DriftAppMetaRepository(sourceDb);
    sourceChildRepo = DriftChildRepository(sourceDb);
    sourceSettingsRepo = DriftSettingsRepository(sourceDb);
    sourcePregnancyRepo = DriftPregnancyRepository(sourceDb);
    sourceContractionRepo = DriftContractionRepository(sourceDb);
    sourceJournalRepo = DriftJournalRepository(sourceDb);
    sourceBabyRepo = DriftBabyLogRepository(sourceDb);
    sourceBackupService = DriftBackupService(
      sourceDb,
      sourceMetaRepo,
      const _FakeBackupAppInfoProvider(
        BackupAppInfo(
          appVersion: '2.0.1',
          buildNumber: '17',
          platform: 'android',
        ),
      ),
    );

    final now = DateTime.utc(2026, 5, 14, 8);
    await sourceChildRepo.createInitialChild(
      child_model.ChildProfile(
        id: 'child-1',
        name: 'Ari',
        gender: Gender.female,
        mode: AppMode.arrived,
        dueDate: DateTime.utc(2025, 12, 1),
        birthDate: DateTime.utc(2026, 1, 5),
        medicalProviderPhone: '555-1234',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await sourceSettingsRepo.saveInitialSettings(
      AppSettings(
        selectedChildId: 'child-1',
        volumeUnit: VolumeUnit.oz,
        weightUnit: WeightUnit.lb,
        lengthUnit: LengthUnit.inch,
        temperatureUnit: TemperatureUnit.fahrenheit,
        notificationsEnabled: true,
        weeklyPregnancyReminderEnabled: false,
        trackingReminderEnabled: true,
      ),
    );
    await sourceMetaRepo.setOnboardingComplete(true);
    await sourceMetaRepo.setValue(selectedThemeKey, 'calmBloom');
    await sourceMetaRepo.setValue(
      deletedChildIdsKey,
      jsonEncode(['ghost-child']),
    );

    await sourcePregnancyRepo.addLog(
      pregnancy_model.PregnancyLog(
        id: 'preg-1',
        childId: 'child-1',
        type: PregnancyLogType.waterIntake,
        timestamp: now.add(const Duration(hours: 1)),
        metadata: {'amount': 12.0},
        createdAt: now.add(const Duration(hours: 1)),
      ),
    );
    await sourceContractionRepo.startContraction('child-1');
    await sourceContractionRepo.stopContraction('child-1', intensity: 4);
    await sourceJournalRepo.addEntry(
      JournalEntryModel(
        id: 'journal-1',
        childId: 'child-1',
        timestamp: now.add(const Duration(hours: 2)),
        body: 'Long night.',
        tags: const ['sleep', 'feeding'],
        createdAt: now.add(const Duration(hours: 2)),
        updatedAt: now.add(const Duration(hours: 2)),
      ),
    );
    await sourceBabyRepo.addLog(
      baby_model.BabyLog(
        id: 'baby-1',
        childId: 'child-1',
        type: BabyLogType.bottleFeed,
        timestamp: now.add(const Duration(hours: 3)),
        metadata: {'amount': 5.0},
        createdAt: now.add(const Duration(hours: 3)),
      ),
    );
  });

  tearDown(() async {
    await sourceDb.close();
    if (await exportDir.exists()) {
      await exportDir.delete(recursive: true);
    }
  });

  test('backup archive round-trips all persisted data', () async {
    final artifact = await sourceBackupService.createBackupExport(
      outputDirectory: exportDir,
    );
    final bytes = await artifact.file.readAsBytes();

    final targetDb = local_db.LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => targetDb.close());
    final targetService = DriftBackupService(
      targetDb,
      DriftAppMetaRepository(targetDb),
      const _FakeBackupAppInfoProvider(
        BackupAppInfo(appVersion: '2.0.1', buildNumber: '99', platform: 'ios'),
      ),
    );

    final result = await targetService.restoreBackupBytes(bytes);
    expect(result.restoredChildCount, 1);

    final child = await (targetDb.select(
      targetDb.childProfiles,
    )..where((tbl) => tbl.id.equals('child-1'))).getSingle();
    expect(child.name, 'Ari');
    expect(child.mode, AppMode.arrived.index);

    final settings = await (targetDb.select(
      targetDb.appSettingsTable,
    )..where((tbl) => tbl.id.equals(1))).getSingle();
    expect(settings.selectedChildId, 'child-1');
    expect(settings.temperatureUnit, TemperatureUnit.fahrenheit.index);

    final appMetaRows = await targetDb.select(targetDb.appMetaTable).get();
    final appMetaMap = {for (final row in appMetaRows) row.key: row.value};
    expect(appMetaMap[onboardingCompletedKey], 'true');
    expect(appMetaMap[selectedThemeKey], 'calmBloom');
    expect(appMetaMap[lastRestoreAtKey], isNotNull);
    expect(appMetaMap[lastImportedBackupVersionKey], '2.0.1+17');

    expect(
      await (targetDb.select(
        targetDb.pregnancyLogs,
      )).get().then((rows) => rows.length),
      1,
    );
    expect(
      await (targetDb.select(
        targetDb.contractionSessions,
      )).get().then((rows) => rows.length),
      1,
    );
    expect(
      await (targetDb.select(
        targetDb.contractionEntries,
      )).get().then((rows) => rows.length),
      1,
    );
    expect(
      await (targetDb.select(
        targetDb.journalEntries,
      )).get().then((rows) => rows.length),
      1,
    );
    expect(
      await (targetDb.select(
        targetDb.babyLogs,
      )).get().then((rows) => rows.length),
      1,
    );
  });

  test('restore accepts backup from previous major line', () async {
    final artifact = await sourceBackupService.createBackupExport(
      outputDirectory: exportDir,
    );
    final bytes = await artifact.file.readAsBytes();
    final migratedBytes = _rewriteManifest(bytes, appVersion: '1.0.1+4');

    final targetDb = local_db.LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => targetDb.close());
    final targetService = DriftBackupService(
      targetDb,
      DriftAppMetaRepository(targetDb),
      const _FakeBackupAppInfoProvider(
        BackupAppInfo(
          appVersion: '2.0.1',
          buildNumber: '7',
          platform: 'android',
        ),
      ),
    );

    final result = await targetService.restoreBackupBytes(migratedBytes);
    expect(result.preview.appVersion, '1.0.1+4');
    expect(result.restoredChildCount, 1);
  });

  test('restore rejects backup older than previous major line', () async {
    final artifact = await sourceBackupService.createBackupExport(
      outputDirectory: exportDir,
    );
    final bytes = await artifact.file.readAsBytes();
    final migratedBytes = _rewriteManifest(bytes, appVersion: '0.9.9+1');

    final targetDb = local_db.LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => targetDb.close());
    final targetService = DriftBackupService(
      targetDb,
      DriftAppMetaRepository(targetDb),
      const _FakeBackupAppInfoProvider(
        BackupAppInfo(
          appVersion: '2.0.1',
          buildNumber: '7',
          platform: 'android',
        ),
      ),
    );

    await expectLater(
      () => targetService.restoreBackupBytes(migratedBytes),
      throwsA(isA<BackupException>()),
    );
  });

  test('failed restore leaves existing local data unchanged', () async {
    final artifact = await sourceBackupService.createBackupExport(
      outputDirectory: exportDir,
    );
    final bytes = await artifact.file.readAsBytes();
    final corruptedBytes = _rewriteManifest(
      bytes,
      checksumSha256:
          '0000000000000000000000000000000000000000000000000000000000000000',
    );

    final targetDb = local_db.LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => targetDb.close());
    final targetChildRepo = DriftChildRepository(targetDb);
    await targetChildRepo.createInitialChild(
      child_model.ChildProfile(
        id: 'existing',
        name: 'Keep Me',
        gender: Gender.unspecified,
        mode: AppMode.expecting,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final targetService = DriftBackupService(
      targetDb,
      DriftAppMetaRepository(targetDb),
      const _FakeBackupAppInfoProvider(
        BackupAppInfo(appVersion: '2.0.1', buildNumber: '9', platform: 'ios'),
      ),
    );

    await expectLater(
      () => targetService.restoreBackupBytes(corruptedBytes),
      throwsA(isA<BackupException>()),
    );

    final children = await targetDb.select(targetDb.childProfiles).get();
    expect(children, hasLength(1));
    expect(children.single.id, 'existing');
    expect(children.single.name, 'Keep Me');
  });
}

class _FakeBackupAppInfoProvider implements BackupAppInfoProvider {
  const _FakeBackupAppInfoProvider(this._info);

  final BackupAppInfo _info;

  @override
  Future<BackupAppInfo> getInfo() async => _info;
}

Uint8List _rewriteManifest(
  Uint8List archiveBytes, {
  String? appVersion,
  String? checksumSha256,
}) {
  final archive = ZipDecoder().decodeBytes(archiveBytes);
  final manifestFile = archive.find('manifest.json')!;
  final manifest =
      jsonDecode(utf8.decode(manifestFile.readBytes()!))
          as Map<String, dynamic>;
  if (appVersion != null) {
    manifest['appVersion'] = appVersion;
  }
  if (checksumSha256 != null) {
    manifest['checksumSha256'] = checksumSha256;
  }

  final dataFile = archive.find('data.json')!;
  final rebuilt = Archive()
    ..add(ArchiveFile.string('manifest.json', jsonEncode(manifest)))
    ..add(ArchiveFile.bytes('data.json', dataFile.readBytes()!));
  return ZipEncoder().encodeBytes(rebuilt);
}
