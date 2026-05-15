import 'dart:convert';
import 'dart:io';

import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

const String backupFileExtension = 'aegi';
const int backupFormatVersion = 1;
const String lastManualBackupAtKey = 'backup_last_manual_backup_at';
const String lastRestoreAtKey = 'backup_last_restore_at';
const String lastImportedBackupVersionKey = 'backup_last_imported_app_version';
const String lastImportedBackupCreatedAtKey = 'backup_last_imported_created_at';

class BackupStatus {
  const BackupStatus({
    this.lastManualBackupAt,
    this.lastRestoreAt,
    this.lastImportedBackupVersion,
    this.lastImportedBackupCreatedAt,
  });

  final DateTime? lastManualBackupAt;
  final DateTime? lastRestoreAt;
  final String? lastImportedBackupVersion;
  final DateTime? lastImportedBackupCreatedAt;
}

class BackupPreview {
  const BackupPreview({
    required this.backupFormatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.platform,
    required this.childCount,
  });

  final int backupFormatVersion;
  final String appVersion;
  final DateTime createdAt;
  final String platform;
  final int childCount;
}

class BackupExportArtifact {
  const BackupExportArtifact({required this.file, required this.preview});

  final File file;
  final BackupPreview preview;
}

class BackupRestoreResult {
  const BackupRestoreResult({
    required this.preview,
    required this.restoredChildCount,
  });

  final BackupPreview preview;
  final int restoredChildCount;
}

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupAppInfo {
  const BackupAppInfo({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
}

abstract class BackupAppInfoProvider {
  Future<BackupAppInfo> getInfo();
}

class PackageInfoBackupAppInfoProvider implements BackupAppInfoProvider {
  const PackageInfoBackupAppInfoProvider();

  @override
  Future<BackupAppInfo> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return BackupAppInfo(
      appVersion: packageInfo.version.trim(),
      buildNumber: packageInfo.buildNumber.trim(),
      platform: defaultTargetPlatform.name,
    );
  }
}

abstract class BackupService {
  Future<BackupStatus> getStatus();
  Future<BackupExportArtifact> createBackupExport({Directory? outputDirectory});
  Future<void> recordManualBackup(DateTime exportedAt);
  Future<BackupPreview> inspectBackupBytes(Uint8List bytes);
  Future<BackupRestoreResult> restoreBackupBytes(Uint8List bytes);
}

class DriftBackupService implements BackupService {
  DriftBackupService(this._database, this._appMetaRepository, this._appInfo);

  final LocalDatabase _database;
  final AppMetaRepository _appMetaRepository;
  final BackupAppInfoProvider _appInfo;

  static const _appId = 'aegi';
  static const _supportedFormatVersions = {backupFormatVersion};
  static const _excludedMetaKeys = {
    lastManualBackupAtKey,
    lastRestoreAtKey,
    lastImportedBackupVersionKey,
    lastImportedBackupCreatedAtKey,
  };

  @override
  Future<BackupExportArtifact> createBackupExport({
    Directory? outputDirectory,
  }) async {
    final appInfo = await _appInfo.getInfo();
    final createdAt = DateTime.now().toUtc();
    final bytes = await _createBackupBytes(
      appInfo: appInfo,
      createdAt: createdAt,
    );
    final preview = await inspectBackupBytes(bytes);
    final tempDir = outputDirectory ?? await getTemporaryDirectory();
    final fileName = _buildBackupFileName(createdAt);
    final file = File('${tempDir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return BackupExportArtifact(file: file, preview: preview);
  }

  @override
  Future<BackupStatus> getStatus() async {
    final lastManualBackupAt = await _appMetaRepository.getValue(
      lastManualBackupAtKey,
    );
    final lastRestoreAt = await _appMetaRepository.getValue(lastRestoreAtKey);
    final lastImportedBackupVersion = await _appMetaRepository.getValue(
      lastImportedBackupVersionKey,
    );
    final lastImportedBackupCreatedAt = await _appMetaRepository.getValue(
      lastImportedBackupCreatedAtKey,
    );
    return BackupStatus(
      lastManualBackupAt: _tryParseTimestamp(lastManualBackupAt),
      lastRestoreAt: _tryParseTimestamp(lastRestoreAt),
      lastImportedBackupVersion: lastImportedBackupVersion,
      lastImportedBackupCreatedAt: _tryParseTimestamp(
        lastImportedBackupCreatedAt,
      ),
    );
  }

  @override
  Future<void> recordManualBackup(DateTime exportedAt) {
    return _appMetaRepository.setValue(
      lastManualBackupAtKey,
      exportedAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<BackupPreview> inspectBackupBytes(Uint8List bytes) async {
    final parsed = _decodeArchive(bytes);
    final payload = _parsePayload(parsed.dataJson);
    return BackupPreview(
      backupFormatVersion: parsed.manifest.backupFormatVersion,
      appVersion: parsed.manifest.appVersion,
      createdAt: parsed.manifest.createdAt,
      platform: parsed.manifest.platform,
      childCount: payload.children.length,
    );
  }

  @override
  Future<BackupRestoreResult> restoreBackupBytes(Uint8List bytes) async {
    final currentAppInfo = await _appInfo.getInfo();
    final parsed = _decodeArchive(bytes);
    _validateCompatibility(
      manifest: parsed.manifest,
      currentAppVersion: currentAppInfo.appVersion,
    );
    final payload = _parsePayload(parsed.dataJson);
    _validatePayload(payload);

    await _database.transaction(() async {
      await _database.batch((batch) {
        batch.deleteAll(_database.contractionEntries);
        batch.deleteAll(_database.contractionSessions);
        batch.deleteAll(_database.pregnancyLogs);
        batch.deleteAll(_database.babyLogs);
        batch.deleteAll(_database.journalEntries);
        batch.deleteAll(_database.appSettingsTable);
        batch.deleteAll(_database.appMetaTable);
        batch.deleteAll(_database.childProfiles);

        if (payload.children.isNotEmpty) {
          batch.insertAll(_database.childProfiles, payload.children);
        }
        if (payload.appSettings != null) {
          batch.insert(_database.appSettingsTable, payload.appSettings!);
        }
        if (payload.appMeta.isNotEmpty) {
          batch.insertAll(_database.appMetaTable, payload.appMeta);
        }
        if (payload.pregnancyLogs.isNotEmpty) {
          batch.insertAll(_database.pregnancyLogs, payload.pregnancyLogs);
        }
        if (payload.contractionSessions.isNotEmpty) {
          batch.insertAll(
            _database.contractionSessions,
            payload.contractionSessions,
          );
        }
        if (payload.contractionEntries.isNotEmpty) {
          batch.insertAll(
            _database.contractionEntries,
            payload.contractionEntries,
          );
        }
        if (payload.journalEntries.isNotEmpty) {
          batch.insertAll(_database.journalEntries, payload.journalEntries);
        }
        if (payload.babyLogs.isNotEmpty) {
          batch.insertAll(_database.babyLogs, payload.babyLogs);
        }

        batch.insert(
          _database.appMetaTable,
          AppMetaTableCompanion.insert(
            key: lastRestoreAtKey,
            value: DateTime.now().toUtc().toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
        batch.insert(
          _database.appMetaTable,
          AppMetaTableCompanion.insert(
            key: lastImportedBackupVersionKey,
            value: parsed.manifest.appVersion,
          ),
          mode: InsertMode.insertOrReplace,
        );
        batch.insert(
          _database.appMetaTable,
          AppMetaTableCompanion.insert(
            key: lastImportedBackupCreatedAtKey,
            value: parsed.manifest.createdAt.toIso8601String(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });
    });

    return BackupRestoreResult(
      preview: BackupPreview(
        backupFormatVersion: parsed.manifest.backupFormatVersion,
        appVersion: parsed.manifest.appVersion,
        createdAt: parsed.manifest.createdAt,
        platform: parsed.manifest.platform,
        childCount: payload.children.length,
      ),
      restoredChildCount: payload.children.length,
    );
  }

  Future<Uint8List> _createBackupBytes({
    required BackupAppInfo appInfo,
    required DateTime createdAt,
  }) async {
    final payload = await _snapshotPayload();
    final dataJson = jsonEncode(payload);
    final dataBytes = Uint8List.fromList(utf8.encode(dataJson));
    final manifest = _BackupManifest(
      appId: _appId,
      backupFormatVersion: backupFormatVersion,
      appVersion: _composeVersion(appInfo),
      createdAt: createdAt,
      platform: appInfo.platform,
      checksumSha256: sha256.convert(dataBytes).toString(),
    );

    final archive = Archive()
      ..add(ArchiveFile.string('manifest.json', jsonEncode(manifest.toJson())))
      ..add(ArchiveFile.bytes('data.json', dataBytes));

    return ZipEncoder().encodeBytes(archive);
  }

  Future<Map<String, Object?>> _snapshotPayload() async {
    final children = await (_database.select(
      _database.childProfiles,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();
    final appSettings = await (_database.select(
      _database.appSettingsTable,
    )..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
    final appMeta = await (_database.select(
      _database.appMetaTable,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.key)])).get();
    final pregnancyLogs = await (_database.select(
      _database.pregnancyLogs,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)])).get();
    final contractionSessions = await (_database.select(
      _database.contractionSessions,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.startedAt)])).get();
    final contractionEntries = await (_database.select(
      _database.contractionEntries,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.startedAt)])).get();
    final journalEntries = await (_database.select(
      _database.journalEntries,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)])).get();
    final babyLogs = await (_database.select(
      _database.babyLogs,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)])).get();

    return {
      'children': children.map(_childToJson).toList(growable: false),
      'appSettings': appSettings == null ? null : _settingsToJson(appSettings),
      'appMeta': appMeta
          .where((row) => !_excludedMetaKeys.contains(row.key))
          .map((row) => {'key': row.key, 'value': row.value})
          .toList(growable: false),
      'pregnancyLogs': pregnancyLogs
          .map(_pregnancyLogToJson)
          .toList(growable: false),
      'contractionSessions': contractionSessions
          .map(_contractionSessionToJson)
          .toList(growable: false),
      'contractionEntries': contractionEntries
          .map(_contractionEntryToJson)
          .toList(growable: false),
      'journalEntries': journalEntries
          .map(_journalEntryToJson)
          .toList(growable: false),
      'babyLogs': babyLogs.map(_babyLogToJson).toList(growable: false),
    };
  }

  _DecodedBackup _decodeArchive(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      final manifestFile = archive.find('manifest.json');
      final dataFile = archive.find('data.json');
      if (manifestFile == null || dataFile == null) {
        throw const BackupException('Backup file missing manifest or data.');
      }

      final manifestBytes = manifestFile.readBytes();
      final dataBytes = dataFile.readBytes();
      if (manifestBytes == null || dataBytes == null) {
        throw const BackupException('Backup file could not be read.');
      }

      final manifestJson = jsonDecode(utf8.decode(manifestBytes));
      if (manifestJson is! Map<String, dynamic>) {
        throw const BackupException('Backup manifest is invalid.');
      }

      final manifest = _BackupManifest.fromJson(manifestJson);
      if (!_supportedFormatVersions.contains(manifest.backupFormatVersion)) {
        throw BackupException(
          'Backup format v${manifest.backupFormatVersion} is not supported.',
        );
      }
      if (manifest.appId != _appId) {
        throw const BackupException('Backup file belongs to a different app.');
      }

      final computedChecksum = sha256.convert(dataBytes).toString();
      if (computedChecksum != manifest.checksumSha256) {
        throw const BackupException('Backup file is corrupted.');
      }

      return _DecodedBackup(
        manifest: manifest,
        dataJson: utf8.decode(dataBytes),
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException('Backup file is unreadable.');
    }
  }

  _BackupPayload _parsePayload(String dataJson) {
    final decoded = jsonDecode(dataJson);
    if (decoded is! Map<String, dynamic>) {
      throw const BackupException('Backup payload is invalid.');
    }

    return _BackupPayload(
      children: _asList(decoded['children']).map(_childFromJson).toList(),
      appSettings: decoded['appSettings'] == null
          ? null
          : _settingsFromJson(_asMap(decoded['appSettings'])),
      appMeta: _asList(decoded['appMeta']).map(_appMetaFromJson).toList(),
      pregnancyLogs: _asList(
        decoded['pregnancyLogs'],
      ).map(_pregnancyLogFromJson).toList(),
      contractionSessions: _asList(
        decoded['contractionSessions'],
      ).map(_contractionSessionFromJson).toList(),
      contractionEntries: _asList(
        decoded['contractionEntries'],
      ).map(_contractionEntryFromJson).toList(),
      journalEntries: _asList(
        decoded['journalEntries'],
      ).map(_journalEntryFromJson).toList(),
      babyLogs: _asList(decoded['babyLogs']).map(_babyLogFromJson).toList(),
    );
  }

  void _validateCompatibility({
    required _BackupManifest manifest,
    required String currentAppVersion,
  }) {
    final currentMajor = _parseMajorVersion(currentAppVersion);
    final sourceMajor = _parseMajorVersion(manifest.appVersion);
    if (currentMajor == null || sourceMajor == null) {
      return;
    }
    if (sourceMajor < currentMajor - 1 || sourceMajor > currentMajor) {
      throw BackupException(
        'Backup from version ${manifest.appVersion} is not supported by this app.',
      );
    }
  }

  void _validatePayload(_BackupPayload payload) {
    final childIds = payload.children.map((row) => row.id.value).toSet();
    if (payload.children.isNotEmpty && payload.appSettings == null) {
      throw const BackupException('Backup is missing app settings.');
    }

    final selectedChildId = payload.appSettings?.selectedChildId.value;
    if (selectedChildId != null && !childIds.contains(selectedChildId)) {
      throw const BackupException('Backup settings reference a missing child.');
    }

    final sessionIds = payload.contractionSessions
        .map((row) => row.id.value)
        .toSet();
    for (final log in payload.pregnancyLogs) {
      if (!childIds.contains(log.childId.value)) {
        throw const BackupException(
          'Backup contains pregnancy logs for a missing child.',
        );
      }
    }
    for (final log in payload.babyLogs) {
      if (!childIds.contains(log.childId.value)) {
        throw const BackupException(
          'Backup contains baby logs for a missing child.',
        );
      }
    }
    for (final entry in payload.journalEntries) {
      if (!childIds.contains(entry.childId.value)) {
        throw const BackupException(
          'Backup contains journal entries for a missing child.',
        );
      }
    }
    for (final session in payload.contractionSessions) {
      if (!childIds.contains(session.childId.value)) {
        throw const BackupException(
          'Backup contains contraction sessions for a missing child.',
        );
      }
    }
    for (final entry in payload.contractionEntries) {
      if (!sessionIds.contains(entry.sessionId.value)) {
        throw const BackupException(
          'Backup contains contraction entries for a missing session.',
        );
      }
    }
  }

  String _composeVersion(BackupAppInfo appInfo) {
    final buildNumber = appInfo.buildNumber.trim();
    if (buildNumber.isEmpty) return appInfo.appVersion;
    return '${appInfo.appVersion}+$buildNumber';
  }

  String _buildBackupFileName(DateTime createdAt) {
    final stamp = createdAt
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll('T', '_');
    return 'aegi_backup_$stamp.$backupFileExtension';
  }

  int? _parseMajorVersion(String version) {
    final match = RegExp(r'^(\d+)').firstMatch(version.trim());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  DateTime? _tryParseTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  List<dynamic> _asList(Object? value) {
    if (value == null) return const [];
    if (value is List) return value;
    throw const BackupException('Backup payload list is invalid.');
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    throw const BackupException('Backup payload object is invalid.');
  }

  Map<String, Object?> _childToJson(ChildProfile row) => {
    'id': row.id,
    'name': row.name,
    'gender': Gender.values[row.gender].name,
    'mode': AppMode.values[row.mode].name,
    'dueDate': row.dueDate?.toUtc().toIso8601String(),
    'birthDate': row.birthDate?.toUtc().toIso8601String(),
    'medicalProviderPhone': row.medicalProviderPhone,
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };

  ChildProfilesCompanion _childFromJson(dynamic value) {
    final json = _asMap(value);
    return ChildProfilesCompanion.insert(
      id: _readRequiredString(json, 'id'),
      name: _readRequiredString(json, 'name'),
      gender: _genderFromBackup(_readRequiredString(json, 'gender')).index,
      mode: _appModeFromBackup(_readRequiredString(json, 'mode')).index,
      dueDate: Value(_readOptionalDate(json, 'dueDate')),
      birthDate: Value(_readOptionalDate(json, 'birthDate')),
      medicalProviderPhone: Value(
        _readOptionalString(json, 'medicalProviderPhone'),
      ),
      createdAt: _readRequiredDate(json, 'createdAt'),
      updatedAt: _readRequiredDate(json, 'updatedAt'),
    );
  }

  Map<String, Object?> _settingsToJson(AppSettingsTableData row) => {
    'selectedChildId': row.selectedChildId,
    'volumeUnit': VolumeUnit.values[row.volumeUnit].name,
    'weightUnit': WeightUnit.values[row.weightUnit].name,
    'lengthUnit': LengthUnit.values[row.lengthUnit].name,
    'temperatureUnit': TemperatureUnit.values[row.temperatureUnit].name,
    'notificationsEnabled': row.notificationsEnabled,
    'weeklyPregnancyReminderEnabled': row.weeklyPregnancyReminderEnabled,
    'trackingReminderEnabled': row.trackingReminderEnabled,
  };

  AppSettingsTableCompanion _settingsFromJson(Map<String, dynamic> json) {
    return AppSettingsTableCompanion.insert(
      id: const Value(1),
      selectedChildId: _readRequiredString(json, 'selectedChildId'),
      volumeUnit: _volumeUnitFromBackup(
        _readRequiredString(json, 'volumeUnit'),
      ).index,
      weightUnit: _weightUnitFromBackup(
        _readRequiredString(json, 'weightUnit'),
      ).index,
      lengthUnit: _lengthUnitFromBackup(
        _readRequiredString(json, 'lengthUnit'),
      ).index,
      temperatureUnit: _temperatureUnitFromBackup(
        _readRequiredString(json, 'temperatureUnit'),
      ).index,
      notificationsEnabled: _readRequiredBool(json, 'notificationsEnabled'),
      weeklyPregnancyReminderEnabled: _readRequiredBool(
        json,
        'weeklyPregnancyReminderEnabled',
      ),
      trackingReminderEnabled: _readRequiredBool(
        json,
        'trackingReminderEnabled',
      ),
    );
  }

  AppMetaTableCompanion _appMetaFromJson(dynamic value) {
    final json = _asMap(value);
    return AppMetaTableCompanion.insert(
      key: _readRequiredString(json, 'key'),
      value: _readRequiredString(json, 'value'),
    );
  }

  Map<String, Object?> _pregnancyLogToJson(PregnancyLog row) => {
    'id': row.id,
    'childId': row.childId,
    'type': PregnancyLogTypeCodec.fromStoredValue(row.type).name,
    'timestamp': row.timestamp.toUtc().toIso8601String(),
    'metadata': _decodeMetadata(row.metadataJson),
    'createdAt': row.createdAt.toUtc().toIso8601String(),
  };

  PregnancyLogsCompanion _pregnancyLogFromJson(dynamic value) {
    final json = _asMap(value);
    return PregnancyLogsCompanion.insert(
      id: _readRequiredString(json, 'id'),
      childId: _readRequiredString(json, 'childId'),
      type: _pregnancyLogTypeFromBackup(
        _readRequiredString(json, 'type'),
      ).storedValue,
      timestamp: _readRequiredDate(json, 'timestamp'),
      metadataJson: jsonEncode(_readRequiredMap(json, 'metadata')),
      createdAt: _readRequiredDate(json, 'createdAt'),
    );
  }

  Map<String, Object?> _contractionSessionToJson(ContractionSession row) => {
    'id': row.id,
    'childId': row.childId,
    'startedAt': row.startedAt.toUtc().toIso8601String(),
    'endedAt': row.endedAt?.toUtc().toIso8601String(),
  };

  ContractionSessionsCompanion _contractionSessionFromJson(dynamic value) {
    final json = _asMap(value);
    return ContractionSessionsCompanion.insert(
      id: _readRequiredString(json, 'id'),
      childId: _readRequiredString(json, 'childId'),
      startedAt: _readRequiredDate(json, 'startedAt'),
      endedAt: Value(_readOptionalDate(json, 'endedAt')),
    );
  }

  Map<String, Object?> _contractionEntryToJson(ContractionEntry row) => {
    'id': row.id,
    'sessionId': row.sessionId,
    'startedAt': row.startedAt.toUtc().toIso8601String(),
    'endedAt': row.endedAt?.toUtc().toIso8601String(),
    'intensity': row.intensity,
  };

  ContractionEntriesCompanion _contractionEntryFromJson(dynamic value) {
    final json = _asMap(value);
    return ContractionEntriesCompanion.insert(
      id: _readRequiredString(json, 'id'),
      sessionId: _readRequiredString(json, 'sessionId'),
      startedAt: _readRequiredDate(json, 'startedAt'),
      endedAt: Value(_readOptionalDate(json, 'endedAt')),
      intensity: Value(_readOptionalInt(json, 'intensity')),
    );
  }

  Map<String, Object?> _journalEntryToJson(JournalEntry row) => {
    'id': row.id,
    'childId': row.childId,
    'timestamp': row.timestamp.toUtc().toIso8601String(),
    'body': row.body,
    'tags': _decodeList(row.tagsJson),
    'createdAt': row.createdAt.toUtc().toIso8601String(),
    'updatedAt': row.updatedAt.toUtc().toIso8601String(),
  };

  JournalEntriesCompanion _journalEntryFromJson(dynamic value) {
    final json = _asMap(value);
    return JournalEntriesCompanion.insert(
      id: _readRequiredString(json, 'id'),
      childId: _readRequiredString(json, 'childId'),
      timestamp: _readRequiredDate(json, 'timestamp'),
      body: _readRequiredString(json, 'body'),
      tagsJson: jsonEncode(_readRequiredStringList(json, 'tags')),
      createdAt: _readRequiredDate(json, 'createdAt'),
      updatedAt: _readRequiredDate(json, 'updatedAt'),
    );
  }

  Map<String, Object?> _babyLogToJson(BabyLog row) => {
    'id': row.id,
    'childId': row.childId,
    'type': BabyLogTypeCodec.fromStoredValue(row.type).name,
    'timestamp': row.timestamp.toUtc().toIso8601String(),
    'metadata': _decodeMetadata(row.metadataJson),
    'createdAt': row.createdAt.toUtc().toIso8601String(),
  };

  BabyLogsCompanion _babyLogFromJson(dynamic value) {
    final json = _asMap(value);
    return BabyLogsCompanion.insert(
      id: _readRequiredString(json, 'id'),
      childId: _readRequiredString(json, 'childId'),
      type: _babyLogTypeFromBackup(
        _readRequiredString(json, 'type'),
      ).storedValue,
      timestamp: _readRequiredDate(json, 'timestamp'),
      metadataJson: jsonEncode(_readRequiredMap(json, 'metadata')),
      createdAt: _readRequiredDate(json, 'createdAt'),
    );
  }

  String _readRequiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw BackupException('Backup is missing required "$key".');
  }

  String? _readOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    throw BackupException('Backup field "$key" is invalid.');
  }

  bool _readRequiredBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw BackupException('Backup field "$key" is invalid.');
  }

  int? _readOptionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw BackupException('Backup field "$key" is invalid.');
  }

  DateTime _readRequiredDate(Map<String, dynamic> json, String key) {
    final value = _readRequiredString(json, key);
    final parsed = DateTime.tryParse(value)?.toUtc();
    if (parsed != null) return parsed;
    throw BackupException('Backup timestamp "$key" is invalid.');
  }

  DateTime? _readOptionalDate(Map<String, dynamic> json, String key) {
    final raw = json[key];
    if (raw == null) return null;
    if (raw is! String) {
      throw BackupException('Backup timestamp "$key" is invalid.');
    }
    final parsed = DateTime.tryParse(raw)?.toUtc();
    if (parsed != null) return parsed;
    throw BackupException('Backup timestamp "$key" is invalid.');
  }

  Map<String, dynamic> _readRequiredMap(Map<String, dynamic> json, String key) {
    return _asMap(json[key]);
  }

  List<String> _readRequiredStringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw BackupException('Backup field "$key" is invalid.');
    }
    return value.map((item) => item.toString()).toList(growable: false);
  }

  Map<String, dynamic> _decodeMetadata(String raw) {
    final decoded = jsonDecode(raw);
    return _asMap(decoded);
  }

  List<dynamic> _decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded;
    throw const BackupException('Backup list data is invalid.');
  }

  Gender _genderFromBackup(String value) {
    return switch (value) {
      'male' => Gender.male,
      'female' => Gender.female,
      'unspecified' || 'unknown' => Gender.unspecified,
      _ => throw BackupException('Unknown gender "$value" in backup.'),
    };
  }

  AppMode _appModeFromBackup(String value) {
    return switch (value) {
      'expecting' => AppMode.expecting,
      'arrived' => AppMode.arrived,
      _ => throw BackupException('Unknown mode "$value" in backup.'),
    };
  }

  VolumeUnit _volumeUnitFromBackup(String value) {
    return switch (value) {
      'ml' => VolumeUnit.ml,
      'oz' => VolumeUnit.oz,
      _ => throw BackupException('Unknown volume unit "$value" in backup.'),
    };
  }

  WeightUnit _weightUnitFromBackup(String value) {
    return switch (value) {
      'kg' => WeightUnit.kg,
      'lb' => WeightUnit.lb,
      _ => throw BackupException('Unknown weight unit "$value" in backup.'),
    };
  }

  LengthUnit _lengthUnitFromBackup(String value) {
    return switch (value) {
      'cm' => LengthUnit.cm,
      'inch' || 'in' => LengthUnit.inch,
      _ => throw BackupException('Unknown length unit "$value" in backup.'),
    };
  }

  TemperatureUnit _temperatureUnitFromBackup(String value) {
    return switch (value) {
      'celsius' || 'c' => TemperatureUnit.celsius,
      'fahrenheit' || 'f' => TemperatureUnit.fahrenheit,
      _ => throw BackupException(
        'Unknown temperature unit "$value" in backup.',
      ),
    };
  }

  PregnancyLogType _pregnancyLogTypeFromBackup(String value) {
    return switch (value) {
      'kickCounter' => PregnancyLogType.kickCounter,
      'waterIntake' => PregnancyLogType.waterIntake,
      'weight' => PregnancyLogType.weight,
      'bloodPressure' => PregnancyLogType.bloodPressure,
      'medication' || 'medicine' => PregnancyLogType.medication,
      'mood' => PregnancyLogType.mood,
      _ => throw BackupException(
        'Unknown pregnancy log type "$value" in backup.',
      ),
    };
  }

  BabyLogType _babyLogTypeFromBackup(String value) {
    return switch (value) {
      'bottleFeed' => BabyLogType.bottleFeed,
      'breastMilk' => BabyLogType.breastMilk,
      'diaperWet' => BabyLogType.diaperWet,
      'diaperDirty' => BabyLogType.diaperDirty,
      'nap' => BabyLogType.nap,
      'nightSleep' => BabyLogType.nightSleep,
      _ => throw BackupException('Unknown baby log type "$value" in backup.'),
    };
  }
}

class _DecodedBackup {
  const _DecodedBackup({required this.manifest, required this.dataJson});

  final _BackupManifest manifest;
  final String dataJson;
}

class _BackupManifest {
  const _BackupManifest({
    required this.appId,
    required this.backupFormatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.platform,
    required this.checksumSha256,
  });

  final String appId;
  final int backupFormatVersion;
  final String appVersion;
  final DateTime createdAt;
  final String platform;
  final String checksumSha256;

  Map<String, Object?> toJson() => {
    'appId': appId,
    'backupFormatVersion': backupFormatVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'platform': platform,
    'checksumSha256': checksumSha256,
  };

  factory _BackupManifest.fromJson(Map<String, dynamic> json) {
    final appId = json['appId'];
    final backupFormatVersion = json['backupFormatVersion'];
    final appVersion = json['appVersion'];
    final createdAt = json['createdAt'];
    final platform = json['platform'];
    final checksumSha256 = json['checksumSha256'];
    if (appId is! String ||
        backupFormatVersion is! int ||
        appVersion is! String ||
        createdAt is! String ||
        platform is! String ||
        checksumSha256 is! String) {
      throw const BackupException('Backup manifest is invalid.');
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt)?.toUtc();
    if (parsedCreatedAt == null) {
      throw const BackupException('Backup manifest timestamp is invalid.');
    }

    return _BackupManifest(
      appId: appId,
      backupFormatVersion: backupFormatVersion,
      appVersion: appVersion,
      createdAt: parsedCreatedAt,
      platform: platform,
      checksumSha256: checksumSha256,
    );
  }
}

class _BackupPayload {
  const _BackupPayload({
    required this.children,
    required this.appSettings,
    required this.appMeta,
    required this.pregnancyLogs,
    required this.contractionSessions,
    required this.contractionEntries,
    required this.journalEntries,
    required this.babyLogs,
  });

  final List<ChildProfilesCompanion> children;
  final AppSettingsTableCompanion? appSettings;
  final List<AppMetaTableCompanion> appMeta;
  final List<PregnancyLogsCompanion> pregnancyLogs;
  final List<ContractionSessionsCompanion> contractionSessions;
  final List<ContractionEntriesCompanion> contractionEntries;
  final List<JournalEntriesCompanion> journalEntries;
  final List<BabyLogsCompanion> babyLogs;
}
