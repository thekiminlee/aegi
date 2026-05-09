import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/widgets/timeline/timeline_entry.dart';
import 'package:aegi/core/widgets/timeline/timeline_view.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
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
          cardBuilder: (context, entry) => PregnancyLogCard(log: entry.data),
        );
      },
    );
  }
}
