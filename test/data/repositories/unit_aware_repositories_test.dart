import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/baby_log.dart' as baby_model;
import 'package:aegi/data/models/pregnancy_log.dart' as pregnancy_model;
import 'package:aegi/data/repositories/baby_log_repository.dart';
import 'package:aegi/data/repositories/pregnancy_repository.dart';
import 'package:aegi/data/repositories/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late DriftSettingsRepository settingsRepo;
  late DriftPregnancyRepository pregnancyRepo;
  late DriftBabyLogRepository babyRepo;

  setUp(() async {
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    settingsRepo = DriftSettingsRepository(db);
    pregnancyRepo = DriftPregnancyRepository(db);
    babyRepo = DriftBabyLogRepository(db);
    await settingsRepo.saveInitialSettings(
      AppSettings(
        selectedChildId: 'c1',
        volumeUnit: VolumeUnit.oz,
        weightUnit: WeightUnit.lb,
        lengthUnit: LengthUnit.cm,
        temperatureUnit: TemperatureUnit.celsius,
        notificationsEnabled: true,
        weeklyPregnancyReminderEnabled: true,
        trackingReminderEnabled: true,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('pregnancy save canonicalizes and fetch converts by settings', () async {
    final now = DateTime(2026, 1, 1, 10);
    await pregnancyRepo.addLog(
      pregnancy_model.PregnancyLog(
        id: 'p1',
        childId: 'c1',
        type: PregnancyLogType.waterIntake,
        timestamp: now,
        metadata: {'amount': 10.0},
        createdAt: now,
      ),
    );
    await pregnancyRepo.addLog(
      pregnancy_model.PregnancyLog(
        id: 'p2',
        childId: 'c1',
        type: PregnancyLogType.weight,
        timestamp: now,
        metadata: {'amount': 150.0},
        createdAt: now,
      ),
    );

    final waterRow = await (db.select(
      db.pregnancyLogs,
    )..where((t) => t.id.equals('p1'))).getSingle();
    expect(waterRow.metadataJson, contains('"amountMl"'));
    expect(waterRow.metadataJson, isNot(contains('"amountOz"')));
    expect(waterRow.metadataJson, isNot(contains('"unit"')));

    final weightRow = await (db.select(
      db.pregnancyLogs,
    )..where((t) => t.id.equals('p2'))).getSingle();
    expect(weightRow.metadataJson, contains('"weightKg"'));
    expect(weightRow.metadataJson, isNot(contains('"weightLb"')));
    expect(weightRow.metadataJson, isNot(contains('"unit"')));

    final logsOzLb = await pregnancyRepo.watchLogsForChild('c1').first;
    final water = logsOzLb.firstWhere((l) => l.id == 'p1');
    final weight = logsOzLb.firstWhere((l) => l.id == 'p2');
    expect(
      (water.metadata['displayAmount'] as num).toDouble(),
      closeTo(10.0, 0.01),
    );
    expect(
      (weight.metadata['displayWeight'] as num).toDouble(),
      closeTo(150.0, 0.01),
    );

    await settingsRepo.updateSettings(
      AppSettings(
        selectedChildId: 'c1',
        volumeUnit: VolumeUnit.ml,
        weightUnit: WeightUnit.kg,
        lengthUnit: LengthUnit.cm,
        temperatureUnit: TemperatureUnit.celsius,
        notificationsEnabled: true,
        weeklyPregnancyReminderEnabled: true,
        trackingReminderEnabled: true,
      ),
    );

    final logsMetric = await pregnancyRepo.watchLogsForChild('c1').first;
    final waterMetric = logsMetric.firstWhere((l) => l.id == 'p1');
    final weightMetric = logsMetric.firstWhere((l) => l.id == 'p2');
    expect(
      (waterMetric.metadata['displayAmount'] as num).toDouble(),
      closeTo(295.735, 0.01),
    );
    expect(
      (weightMetric.metadata['displayWeight'] as num).toDouble(),
      closeTo(68.0388, 0.01),
    );
  });

  test(
    'baby log add and update keep canonical storage and display conversion',
    () async {
      final now = DateTime(2026, 1, 2, 10);
      await babyRepo.addLog(
        baby_model.BabyLog(
          id: 'b1',
          childId: 'c1',
          type: BabyLogType.bottleFeed,
          timestamp: now,
          metadata: {'amount': 4.0},
          createdAt: now,
        ),
      );

      await babyRepo.updateLog(
        baby_model.BabyLog(
          id: 'b1',
          childId: 'c1',
          type: BabyLogType.bottleFeed,
          timestamp: now,
          metadata: {'amount': 5.0},
          createdAt: now,
        ),
      );

      final row = await (db.select(
        db.babyLogs,
      )..where((t) => t.id.equals('b1'))).getSingle();
      expect(row.metadataJson, contains('"amountMl"'));
      expect(row.metadataJson, isNot(contains('"amountOz"')));
      expect(row.metadataJson, isNot(contains('"unit"')));

      final logsOz = await babyRepo.watchLogsForChild('c1').first;
      final feedOz = logsOz.firstWhere((l) => l.id == 'b1');
      expect(
        (feedOz.metadata['displayAmount'] as num).toDouble(),
        closeTo(5.0, 0.01),
      );
    },
  );

  test('active stream re-converts when settings change', () async {
    final now = DateTime(2026, 1, 3, 10);
    await pregnancyRepo.addLog(
      pregnancy_model.PregnancyLog(
        id: 'p3',
        childId: 'c1',
        type: PregnancyLogType.waterIntake,
        timestamp: now,
        metadata: {'amount': 8.0},
        createdAt: now,
      ),
    );

    final emissions = <double>[];
    final sub = pregnancyRepo.watchLogsForChild('c1').listen((logs) {
      final value =
          (logs.firstWhere((l) => l.id == 'p3').metadata['displayAmount']
                  as num)
              .toDouble();
      emissions.add(value);
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(emissions.first, closeTo(8.0, 0.01));

    await settingsRepo.updateSettings(
      AppSettings(
        selectedChildId: 'c1',
        volumeUnit: VolumeUnit.ml,
        weightUnit: WeightUnit.kg,
        lengthUnit: LengthUnit.cm,
        temperatureUnit: TemperatureUnit.celsius,
        notificationsEnabled: true,
        weeklyPregnancyReminderEnabled: true,
        trackingReminderEnabled: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(emissions.last, closeTo(236.588, 0.02));
    await sub.cancel();
  });
}
