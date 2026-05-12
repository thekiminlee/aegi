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

  test('latest-value metrics show last recorded log, not just today', () {
    final now = DateTime(2026, 4, 28, 12);
    final yesterday = DateTime(2026, 4, 27, 20);
    final twoDaysAgo = DateTime(2026, 4, 26, 15);
    // DESC order: today water + kicks, but weight/BP/med/mood from previous days
    final logs = [
      PregnancyLog(
        id: 'w1',
        childId: 'c',
        type: PregnancyLogType.waterIntake,
        timestamp: now,
        metadata: {'amountMl': 500.0},
        createdAt: now,
      ),
      PregnancyLog(
        id: 'k1',
        childId: 'c',
        type: PregnancyLogType.kickCounter,
        timestamp: now,
        metadata: {'durationSeconds': 120},
        createdAt: now,
      ),
      // Yesterday's water + kicks should NOT count
      PregnancyLog(
        id: 'w0',
        childId: 'c',
        type: PregnancyLogType.waterIntake,
        timestamp: yesterday,
        metadata: {'amountMl': 300.0},
        createdAt: yesterday,
      ),
      PregnancyLog(
        id: 'k0',
        childId: 'c',
        type: PregnancyLogType.kickCounter,
        timestamp: yesterday,
        metadata: {'durationSeconds': 90},
        createdAt: yesterday,
      ),
      // Latest-value metrics from previous days should show
      PregnancyLog(
        id: 'wt1',
        childId: 'c',
        type: PregnancyLogType.weight,
        timestamp: yesterday,
        metadata: {'weightKg': 69.5},
        createdAt: yesterday,
      ),
      PregnancyLog(
        id: 'bp1',
        childId: 'c',
        type: PregnancyLogType.bloodPressure,
        timestamp: twoDaysAgo,
        metadata: {'systolic': 115, 'diastolic': 75},
        createdAt: twoDaysAgo,
      ),
      PregnancyLog(
        id: 'med1',
        childId: 'c',
        type: PregnancyLogType.medication,
        timestamp: yesterday,
        metadata: {'name': 'Iron'},
        createdAt: yesterday,
      ),
      PregnancyLog(
        id: 'mood1',
        childId: 'c',
        type: PregnancyLogType.mood,
        timestamp: twoDaysAgo,
        metadata: {'mood': 'calm'},
        createdAt: twoDaysAgo,
      ),
    ];

    final summary = TodaySummary.fromLogs(logs, now);
    // Daily aggregates: only today
    expect(summary.totalWaterMlToday, closeTo(500.0, 0.001));
    expect(summary.kickSessionsToday, 1);
    // Latest-value: from previous days
    expect(summary.latestWeightKg, 69.5);
    expect(summary.latestWeightTimestamp, yesterday);
    expect(summary.latestSystolic, 115);
    expect(summary.latestDiastolic, 75);
    expect(summary.latestBloodPressureTimestamp, twoDaysAgo);
    expect(summary.latestMedicationName, 'Iron');
    expect(summary.latestMedicationTimestamp, yesterday);
    expect(summary.latestMood, isNotNull);
    expect(summary.latestMoodTimestamp, twoDaysAgo);
  });

  test('unit conversions work', () {
    expect(mlToUnit(295.735, VolumeUnit.oz), closeTo(10.0, 0.01));
    expect(kgToUnit(68.0388, WeightUnit.lb), closeTo(150.0, 0.01));
  });
}
