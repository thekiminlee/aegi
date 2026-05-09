import 'package:aegi/core/enums/mood_type.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:intl/intl.dart';

class PregnancyCalc {
  const PregnancyCalc({
    required this.currentWeek,
    required this.daysRemaining,
    required this.progress,
  });

  final int currentWeek;
  final int daysRemaining;
  final double progress;

  factory PregnancyCalc.fromDueDate(DateTime? dueDate, DateTime now) {
    if (dueDate == null) {
      return const PregnancyCalc(currentWeek: 1, daysRemaining: 0, progress: 0);
    }
    final startDate = dueDate.subtract(const Duration(days: 280));
    final daysPregnant = now.difference(startDate).inDays;
    final currentWeek = ((daysPregnant / 7).floor() + 1);
    final daysRemaining = dueDate.difference(now).inDays.clamp(0, 280);
    final progress = (daysPregnant / 280).clamp(0.0, 1.0);
    return PregnancyCalc(
      currentWeek: currentWeek,
      daysRemaining: daysRemaining,
      progress: progress,
    );
  }
}

class TodaySummary {
  const TodaySummary({
    required this.kickSessionsToday,
    required this.latestKickDurationSeconds,
    required this.totalWaterMlToday,
    required this.latestWeightKg,
    required this.latestWeightTimestamp,
    required this.latestSystolic,
    required this.latestDiastolic,
    required this.latestBloodPressureTimestamp,
    required this.latestMedicationName,
    required this.latestMedicationTimestamp,
    required this.latestMood,
    required this.latestMoodTimestamp,
  });

  final int kickSessionsToday;
  final int? latestKickDurationSeconds;
  final double totalWaterMlToday;
  final double? latestWeightKg;
  final DateTime? latestWeightTimestamp;
  final int? latestSystolic;
  final int? latestDiastolic;
  final DateTime? latestBloodPressureTimestamp;
  final String? latestMedicationName;
  final DateTime? latestMedicationTimestamp;
  final MoodType? latestMood;
  final DateTime? latestMoodTimestamp;

  factory TodaySummary.empty() => const TodaySummary(
    kickSessionsToday: 0,
    latestKickDurationSeconds: null,
    totalWaterMlToday: 0,
    latestWeightKg: null,
    latestWeightTimestamp: null,
    latestSystolic: null,
    latestDiastolic: null,
    latestBloodPressureTimestamp: null,
    latestMedicationName: null,
    latestMedicationTimestamp: null,
    latestMood: null,
    latestMoodTimestamp: null,
  );

  factory TodaySummary.fromLogs(List<PregnancyLog> logs, DateTime now) {
    final todayLogs = logs.where(
      (log) =>
          log.timestamp.year == now.year &&
          log.timestamp.month == now.month &&
          log.timestamp.day == now.day,
    );

    int kicks = 0;
    int? latestKick;
    double waterMl = 0;
    double? weightKg;
    DateTime? weightTs;
    int? sys;
    int? dia;
    DateTime? bpTs;
    String? medName;
    DateTime? medTs;
    MoodType? mood;
    DateTime? moodTs;

    for (final log in todayLogs) {
      switch (log.type) {
        case PregnancyLogType.kickCounter:
          kicks++;
          latestKick ??= (log.metadata['durationSeconds'] as num?)?.toInt();
          break;
        case PregnancyLogType.waterIntake:
          waterMl += readWaterMl(log.metadata);
          break;
        case PregnancyLogType.weight:
          if (weightTs == null) {
            weightKg = readWeightKg(log.metadata);
            weightTs = log.timestamp;
          }
          break;
        case PregnancyLogType.bloodPressure:
          if (bpTs == null) {
            sys = (log.metadata['systolic'] as num?)?.toInt();
            dia = (log.metadata['diastolic'] as num?)?.toInt();
            bpTs = log.timestamp;
          }
          break;
        case PregnancyLogType.medication:
          if (medTs == null) {
            medName = (log.metadata['name'] as String?) ?? 'Logged';
            medTs = log.timestamp;
          }
          break;
        case PregnancyLogType.mood:
          if (moodTs == null) {
            mood = parseMood(log.metadata['mood'] as String?);
            moodTs = log.timestamp;
          }
          break;
      }
    }

    return TodaySummary(
      kickSessionsToday: kicks,
      latestKickDurationSeconds: latestKick,
      totalWaterMlToday: waterMl,
      latestWeightKg: weightKg,
      latestWeightTimestamp: weightTs,
      latestSystolic: sys,
      latestDiastolic: dia,
      latestBloodPressureTimestamp: bpTs,
      latestMedicationName: medName,
      latestMedicationTimestamp: medTs,
      latestMood: mood,
      latestMoodTimestamp: moodTs,
    );
  }
}

String formatDuration(Duration value) {
  final totalSeconds = value.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

Duration averageInterval(List<ContractionEntry> entries) {
  if (entries.length < 2) return Duration.zero;
  final ordered = [...entries]
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  int sumSeconds = 0;
  for (var i = 1; i < ordered.length; i++) {
    sumSeconds += ordered[i].startedAt
        .difference(ordered[i - 1].startedAt)
        .inSeconds;
  }
  return Duration(seconds: sumSeconds ~/ (ordered.length - 1));
}

enum ContractionGuidanceLevel { none, gettingReady, contactProvider }

class ContractionGuidance {
  const ContractionGuidance({
    required this.level,
    required this.title,
    required this.message,
  });

  final ContractionGuidanceLevel level;
  final String title;
  final String message;
}

ContractionGuidance evaluateContractionGuidance(
  List<ContractionEntry> entries,
  DateTime now,
) {
  final completed = entries.where((e) => e.endedAt != null).toList()
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  if (completed.length < 6) {
    return const ContractionGuidance(
      level: ContractionGuidanceLevel.none,
      title: '',
      message: '',
    );
  }

  final last12 = completed.length <= 12
      ? completed
      : completed.sublist(completed.length - 12);
  final avgDurationSeconds =
      last12.map((e) => e.duration!.inSeconds).reduce((a, b) => a + b) ~/
      last12.length;
  final avgIntervalValue = averageInterval(last12);
  final span = last12.last.startedAt.difference(last12.first.startedAt);
  final minutesSinceLatest = now.difference(last12.last.startedAt).inMinutes;

  final meets511 =
      last12.length >= 12 &&
      avgIntervalValue <= const Duration(minutes: 5) &&
      avgDurationSeconds >= 60 &&
      span >= const Duration(minutes: 55) &&
      minutesSinceLatest <= 10;

  if (meets511) {
    return const ContractionGuidance(
      level: ContractionGuidanceLevel.contactProvider,
      title: '5-1-1 detected',
      message:
          'Contractions are about 5 minutes apart, lasting around 1 minute, for about 1 hour. Contact your medical provider or head to hospital now.',
    );
  }

  final closeTo511 =
      last12.length >= 8 &&
      avgIntervalValue <= const Duration(minutes: 6) &&
      avgDurationSeconds >= 50 &&
      span >= const Duration(minutes: 35) &&
      minutesSinceLatest <= 10;

  if (closeTo511) {
    return const ContractionGuidance(
      level: ContractionGuidanceLevel.gettingReady,
      title: 'Close to 5-1-1',
      message:
          'Pattern is getting close to active labor. Start getting ready to leave and keep tracking contractions.',
    );
  }

  return const ContractionGuidance(
    level: ContractionGuidanceLevel.none,
    title: '',
    message: '',
  );
}

String pregnancyLogTitle(PregnancyLog log) {
  switch (log.type) {
    case PregnancyLogType.kickCounter:
      final duration = (log.metadata['durationSeconds'] as num?)?.toInt();
      return 'Kick counter: ${duration == null ? '--:--' : formatDuration(Duration(seconds: duration))}';
    case PregnancyLogType.waterIntake:
      final amount = (log.metadata['amount'] as num?)?.toDouble() ?? 0;
      final unit = (log.metadata['unit'] as String?) ?? 'ml';
      return 'Water: ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} $unit';
    case PregnancyLogType.weight:
      final amount = (log.metadata['amount'] as num?)?.toDouble() ?? 0;
      final unit = (log.metadata['unit'] as String?) ?? 'kg';
      return 'Weight: ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} $unit';
    case PregnancyLogType.bloodPressure:
      final sys = (log.metadata['systolic'] as num?)?.toInt() ?? 0;
      final dia = (log.metadata['diastolic'] as num?)?.toInt() ?? 0;
      return 'Blood pressure: $sys/$dia';
    case PregnancyLogType.medication:
      return 'Medication: ${log.metadata['name'] ?? 'Taken'}';
    case PregnancyLogType.mood:
      final mood = parseMood(log.metadata['mood'] as String?);
      return 'Mood: ${moodLabel(mood)}';
  }
}

MoodType? parseMood(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final mood in MoodType.values) {
    if (mood.name == raw) return mood;
  }
  return null;
}

String moodLabel(MoodType? mood) {
  if (mood == null) return '--';
  return '${mood.name[0].toUpperCase()}${mood.name.substring(1)}';
}

double readWaterMl(Map<String, dynamic> metadata) {
  final fromCanonical = (metadata['amountMl'] as num?)?.toDouble();
  if (fromCanonical != null) return fromCanonical;
  final amount = (metadata['amount'] as num?)?.toDouble() ?? 0;
  final unit = metadata['unit'] as String?;
  if (unit == VolumeUnit.oz.name) return amount * 29.5735;
  return amount;
}

double readWeightKg(Map<String, dynamic> metadata) {
  final fromCanonical = (metadata['weightKg'] as num?)?.toDouble();
  if (fromCanonical != null) return fromCanonical;
  final amount = (metadata['amount'] as num?)?.toDouble() ?? 0;
  final unit = metadata['unit'] as String?;
  if (unit == WeightUnit.lb.name) return amount * 0.453592;
  return amount;
}

double mlToUnit(double ml, VolumeUnit unit) {
  if (unit == VolumeUnit.oz) return ml / 29.5735;
  return ml;
}

double kgToUnit(double kg, WeightUnit unit) {
  if (unit == WeightUnit.lb) return kg / 0.453592;
  return kg;
}

String formatDate(DateTime? value) {
  if (value == null) return '--';
  return DateFormat.yMMMd().format(value);
}

String formatDateTime(DateTime? value) {
  if (value == null) return '--';
  return DateFormat.yMMMd().add_jm().format(value);
}
