import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summary computes daily totals and latest values', () {
    final now = DateTime(2026, 4, 28, 12);
    final logs = [
      PregnancyLog(
        id: '1',
        childId: 'c',
        type: PregnancyLogType.waterIntake,
        timestamp: now,
        metadata: {'amount': 10, 'unit': 'oz', 'amountMl': 295.735},
        createdAt: now,
      ),
      PregnancyLog(
        id: '2',
        childId: 'c',
        type: PregnancyLogType.weight,
        timestamp: now,
        metadata: {'amount': 150, 'unit': 'lb', 'weightKg': 68.0388},
        createdAt: now,
      ),
      PregnancyLog(
        id: '3',
        childId: 'c',
        type: PregnancyLogType.bloodPressure,
        timestamp: now,
        metadata: {'systolic': 120, 'diastolic': 80},
        createdAt: now,
      ),
      PregnancyLog(
        id: '4',
        childId: 'c',
        type: PregnancyLogType.medication,
        timestamp: now,
        metadata: {'name': 'Prenatal'},
        createdAt: now,
      ),
      PregnancyLog(
        id: '5',
        childId: 'c',
        type: PregnancyLogType.mood,
        timestamp: now,
        metadata: {'mood': 'happy'},
        createdAt: now,
      ),
      PregnancyLog(
        id: '6',
        childId: 'c',
        type: PregnancyLogType.kickCounter,
        timestamp: now,
        metadata: {'durationSeconds': 180},
        createdAt: now,
      ),
    ];

    final summary = TodaySummary.fromLogs(logs, now);
    expect(summary.kickSessionsToday, 1);
    expect(summary.latestKickDurationSeconds, 180);
    expect(summary.totalWaterMlToday, closeTo(295.735, 0.001));
    expect(summary.latestWeightKg, closeTo(68.0388, 0.001));
    expect(summary.latestSystolic, 120);
    expect(summary.latestDiastolic, 80);
    expect(summary.latestMedicationName, 'Prenatal');
    expect(moodLabel(summary.latestMood), 'Happy');
  });

  test('summary picks latest entry when multiple logs of same type exist', () {
    final now = DateTime(2026, 4, 28, 18);
    // Logs arrive in DESC order (newest first) like the DB query returns
    final logs = [
      PregnancyLog(
        id: 'w2',
        childId: 'c',
        type: PregnancyLogType.weight,
        timestamp: DateTime(2026, 4, 28, 16),
        metadata: {'weightKg': 70.0},
        createdAt: DateTime(2026, 4, 28, 16),
      ),
      PregnancyLog(
        id: 'w1',
        childId: 'c',
        type: PregnancyLogType.weight,
        timestamp: DateTime(2026, 4, 28, 8),
        metadata: {'weightKg': 68.0},
        createdAt: DateTime(2026, 4, 28, 8),
      ),
      PregnancyLog(
        id: 'bp2',
        childId: 'c',
        type: PregnancyLogType.bloodPressure,
        timestamp: DateTime(2026, 4, 28, 15),
        metadata: {'systolic': 125, 'diastolic': 82},
        createdAt: DateTime(2026, 4, 28, 15),
      ),
      PregnancyLog(
        id: 'bp1',
        childId: 'c',
        type: PregnancyLogType.bloodPressure,
        timestamp: DateTime(2026, 4, 28, 7),
        metadata: {'systolic': 118, 'diastolic': 76},
        createdAt: DateTime(2026, 4, 28, 7),
      ),
    ];

    final summary = TodaySummary.fromLogs(logs, now);
    // Should pick the newest (first in DESC list)
    expect(summary.latestWeightKg, 70.0);
    expect(summary.latestWeightTimestamp, DateTime(2026, 4, 28, 16));
    expect(summary.latestSystolic, 125);
    expect(summary.latestDiastolic, 82);
    expect(summary.latestBloodPressureTimestamp, DateTime(2026, 4, 28, 15));
  });

  test('unit conversions work', () {
    expect(mlToUnit(295.735, VolumeUnit.oz), closeTo(10.0, 0.01));
    expect(kgToUnit(68.0388, WeightUnit.lb), closeTo(150.0, 0.01));
  });
}
