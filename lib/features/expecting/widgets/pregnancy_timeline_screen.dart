import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/timeline/timeline_entry.dart';
import 'package:aegi/core/widgets/timeline/timeline_log_row.dart';
import 'package:aegi/core/widgets/timeline/timeline_view.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart'
    show formatDuration, moodLabel, parseMood;
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _filterCategories = [
  TimelineFilterCategory(key: 'all', label: 'All', matchesAll: true),
  TimelineFilterCategory(key: 'vitals', label: 'Vitals'),
  TimelineFilterCategory(key: 'movement', label: 'Movement'),
  TimelineFilterCategory(key: 'mood', label: 'Mood'),
  TimelineFilterCategory(key: 'supplements', label: 'Supplements'),
];

String _categoryForLogType(PregnancyLogType type) => switch (type) {
  PregnancyLogType.weight => 'vitals',
  PregnancyLogType.bloodPressure => 'vitals',
  PregnancyLogType.waterIntake => 'vitals',
  PregnancyLogType.kickCounter => 'movement',
  PregnancyLogType.mood => 'mood',
  PregnancyLogType.medication => 'supplements',
};

class PregnancyTimelineScreen extends ConsumerWidget {
  const PregnancyTimelineScreen({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(expectingPregnancyLogsProvider(childId));
    final settingsAsync = ref.watch(appSettingsProvider);
    final volumeUnit =
        settingsAsync.maybeWhen(
          data: (s) => s?.volumeUnit,
          orElse: () => null,
        ) ??
        VolumeUnit.ml;
    final weightUnit =
        settingsAsync.maybeWhen(
          data: (s) => s?.weightUnit,
          orElse: () => null,
        ) ??
        WeightUnit.kg;

    return logsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Failed to load logs: $e'))),
      data: (logs) {
        final entries = logs
            .map(
              (log) => TimelineEntry<PregnancyLog>(
                id: log.id,
                timestamp: log.timestamp,
                category: _categoryForLogType(log.type),
                data: log,
              ),
            )
            .toList();

        return TimelineView<PregnancyLog>(
          entries: entries,
          filterCategories: _filterCategories,
          cardBuilder: (context, entry) {
            final log = entry.data;
            final (icon, iconColor) = _pregnancyLogIconAndColor(log.type);
            final (label, value, unit) = _logDisplayData(
              log,
              volumeUnit: volumeUnit,
              weightUnit: weightUnit,
            );
            final detail = unit.isNotEmpty ? '$value $unit' : value;
            return TimelineLogRow(
              timestamp: log.timestamp,
              icon: icon,
              color: iconColor,
              categoryLabel: label,
              detailText: detail,
            );
          },
        );
      },
    );
  }
}

(IconData, Color) _pregnancyLogIconAndColor(PregnancyLogType type) =>
    switch (type) {
      PregnancyLogType.kickCounter => (
        Icons.gesture_outlined,
        const Color(0xFFB5C7ED),
      ),
      PregnancyLogType.waterIntake => (
        Icons.water_drop_outlined,
        const Color(0xFFA8DADC),
      ),
      PregnancyLogType.weight => (
        Icons.monitor_weight_outlined,
        const Color(0xFF90BE6D),
      ),
      PregnancyLogType.bloodPressure => (
        Icons.favorite_outline,
        const Color(0xFFF28482),
      ),
      PregnancyLogType.medication => (
        Icons.medication_outlined,
        const Color(0xFFF6BD60),
      ),
      PregnancyLogType.mood => (Icons.mood_outlined, const Color(0xFF84A59D)),
    };

(String label, String value, String unit) _logDisplayData(
  PregnancyLog log, {
  VolumeUnit volumeUnit = VolumeUnit.ml,
  WeightUnit weightUnit = WeightUnit.kg,
}) {
  switch (log.type) {
    case PregnancyLogType.kickCounter:
      final duration = (log.metadata['durationSeconds'] as num?)?.toInt();
      final label = duration != null
          ? 'Movement · ${formatDuration(Duration(seconds: duration))}'
          : 'Movement';
      final kicks = (log.metadata['kickCount'] as num?)?.toInt();
      return (
        label,
        kicks != null ? '$kicks' : '--',
        kicks != null ? 'KICKS' : '',
      );
    case PregnancyLogType.waterIntake:
      final amount = (log.metadata['displayAmount'] as num?)?.toDouble() ?? 0;
      return (
        'Water',
        amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1),
        volumeUnit.name.toUpperCase(),
      );
    case PregnancyLogType.weight:
      final amount = (log.metadata['displayWeight'] as num?)?.toDouble() ?? 0;
      return (
        'Weight',
        amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1),
        weightUnit.name.toUpperCase(),
      );
    case PregnancyLogType.bloodPressure:
      final sys = (log.metadata['systolic'] as num?)?.toInt() ?? 0;
      final dia = (log.metadata['diastolic'] as num?)?.toInt() ?? 0;
      return ('Blood pressure', '$sys / $dia', 'MMHG');
    case PregnancyLogType.medication:
      final name = (log.metadata['name'] as String?) ?? 'Medication';
      return (name, 'MEDICATION', '');
    case PregnancyLogType.mood:
      final mood = parseMood(log.metadata['mood'] as String?);
      return ('Mood', moodLabel(mood).toUpperCase(), '');
  }
}
