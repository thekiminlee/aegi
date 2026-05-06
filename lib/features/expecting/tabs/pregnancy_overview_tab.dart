import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
import 'package:aegi/features/expecting/widgets/kick_counter_card.widget.dart';
import 'package:aegi/features/expecting/widgets/log_history_section.widget.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_daily_metrics.widget.dart';
import 'package:aegi/features/expecting/widgets/week_tracker_card.widget.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PregnancyOverviewTab extends ConsumerWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(expectingPregnancyLogsProvider(child.id));
    final now = DateTime.now();
    final dueDate = child.dueDate;

    final calc = PregnancyCalc.fromDueDate(dueDate, now);
    final growth = getFetusGrowthByWeek(calc.currentWeek);
    final growthLabel = (growth?['sizeLabel'] as String?) ?? 'Growing baby';
    final growthMessage =
        (growth?['message'] as String?) ?? 'Your baby keeps growing each week.';
    final growthHeight = growth?['approxLengthCm'] as double?;
    final growthWeight = growth?['approxWeightGrams'] as int?;

    final settingsAsync = ref.watch(activeChildContextProvider);
    final volumeUnit = settingsAsync.maybeWhen(
      data: (value) => value.settings.volumeUnit,
      orElse: () => VolumeUnit.ml,
    );
    final weightUnit = settingsAsync.maybeWhen(
      data: (value) => value.settings.weightUnit,
      orElse: () => WeightUnit.kg,
    );

    final summary = logs.maybeWhen(
      data: (items) => TodaySummary.fromLogs(items, now),
      orElse: TodaySummary.empty,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        WeekTrackerCard(calc: calc, growthLabel: growthLabel, growthMessage: growthMessage, dueDate: dueDate, growthHeight: growthHeight, growthWeight: growthWeight),
        const SizedBox(height: 16),
        KickCounterCard(childId: child.id, latestKickDurationSeconds: summary.latestKickDurationSeconds),
        const SizedBox(height: 12),
        PregnancyDailyMetrics(summary: summary, volumeUnit: volumeUnit, weightUnit: weightUnit),
        const SizedBox(height: 18),
        LogHistorySection(logs: logs),
      ],
    );
  }
}
