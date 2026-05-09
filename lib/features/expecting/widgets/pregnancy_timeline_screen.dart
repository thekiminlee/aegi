import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/widgets/timeline/timeline_entry.dart';
import 'package:aegi/core/widgets/timeline/timeline_view.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart'
    show formatDuration, moodLabel, parseMood;
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

    return logsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load logs: $e')),
      ),
      data: (logs) {
        final entries = logs
            .map((log) => TimelineEntry<PregnancyLog>(
                  id: log.id,
                  timestamp: log.timestamp,
                  category: _categoryForLogType(log.type),
                  data: log,
                ))
            .toList();

        return TimelineView<PregnancyLog>(
          entries: entries,
          filterCategories: _filterCategories,
          cardBuilder: (context, entry) =>
              _TimelineLogCard(log: entry.data),
        );
      },
    );
  }
}

class _TimelineLogCard extends StatelessWidget {
  const _TimelineLogCard({required this.log});

  final PregnancyLog log;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = switch (log.type) {
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
      PregnancyLogType.mood => (
        Icons.mood_outlined,
        const Color(0xFF84A59D),
      ),
    };

    final (label, value, unit) = _logDisplayData(log);
    final timeText = DateFormat.jm().format(log.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 35, 35, 35),
                          fontFamily: 'Saira',
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        value,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Saira',
                                ),
                      ),
                      if (unit.isNotEmpty)
                        Text(
                          ' $unit',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Saira',
                                  ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              timeText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inconsolata',
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

(String label, String value, String unit) _logDisplayData(PregnancyLog log) {
  switch (log.type) {
    case PregnancyLogType.kickCounter:
      final duration = (log.metadata['durationSeconds'] as num?)?.toInt();
      final label = duration != null
          ? 'Movement · ${formatDuration(Duration(seconds: duration))}'
          : 'Movement';
      final kicks = (log.metadata['kickCount'] as num?)?.toInt();
      return (label, kicks != null ? '$kicks' : '--', kicks != null ? 'KICKS' : '');
    case PregnancyLogType.waterIntake:
      final amount = (log.metadata['amount'] as num?)?.toDouble() ?? 0;
      final unit = (log.metadata['unit'] as String?) ?? 'ml';
      return ('Water', amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1), unit.toUpperCase());
    case PregnancyLogType.weight:
      final amount = (log.metadata['amount'] as num?)?.toDouble() ?? 0;
      final unit = (log.metadata['unit'] as String?) ?? 'kg';
      return ('Weight', amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1), unit.toUpperCase());
    case PregnancyLogType.bloodPressure:
      final sys = (log.metadata['systolic'] as num?)?.toInt() ?? 0;
      final dia = (log.metadata['diastolic'] as num?)?.toInt() ?? 0;
      return ('Blood pressure', '$sys / $dia', 'MMHG');
    case PregnancyLogType.medication:
      final name = (log.metadata['name'] as String?) ?? 'Medication';
      return (name, 'TAKEN', '');
    case PregnancyLogType.mood:
      final mood = parseMood(log.metadata['mood'] as String?);
      return ('Mood', moodLabel(mood).toUpperCase(), '');
  }
}
