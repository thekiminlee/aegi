import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
import 'package:aegi/features/expecting/widgets/kick_counter_page.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_daily_metrics.widget.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_timeline_screen.dart';
import 'package:aegi/features/expecting/widgets/week_tracker_card.widget.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class PregnancyOverviewTab extends ConsumerWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  Widget header(BuildContext context, String childId) {
    return TabHeader(
      subheading: "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
      heading: "How are you today?",
      trailing: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PregnancyTimelineScreen(childId: childId),
          ),
        ),
        child: Text("VIEW ALL", style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[400],
              fontFamily: "Inconsolata",
              letterSpacing: 1.2,)),
      ),
    );
  }

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
    final gradientColors = (growth?['colors'] as List<Color>?) ?? const [Color(0xFFE0E0E0), Color(0xFFBDBDBD), Color(0xFF9E9E9E)];
    final textColor = (growth?['textColor'] as Color?) ?? const Color(0xFF1C1C1E);
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
        header(context, child.id),
        const SizedBox(height: 16),
        WeekTrackerCard(calc: calc, growthLabel: growthLabel, growthMessage: growthMessage, dueDate: dueDate, growthHeight: growthHeight, growthWeight: growthWeight, gradientColors: gradientColors, textColor: textColor, babyName: child.name, childId: child.id),

        // --- Stat tiles row ---
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewStatTile(
                label: 'DAYS LEFT',
                // value: '${calc.daysRemaining}',
                value: Text(
                  calc.daysRemaining.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inconsolata',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => KickCounterPage(childId: child.id),
                  ),
                ),
                child: _OverviewStatTile(
                  label: 'KICK COUNTER',
                  value: Icon(Symbols.footprint, size: 22, fontWeight: FontWeight.w500,),
                ),
              ),
            ),
          ],
        ),

        // --- Recent Log ---
        const SizedBox(height: 24),
        SectionHeader(
          label: "Recent Log"
        ),
        const SizedBox(height: 8),
        PregnancyDailyMetrics(
          summary: summary,
          volumeUnit: volumeUnit,
          weightUnit: weightUnit,
          childId: child.id,
          onTileTap: (tab) => showUnifiedEntrySheet(context, ref, child, initialTab: tab),
        ),
      ],
    );
  }
}

// int _loggedMetricsCount(TodaySummary s) {
//   int count = 0;
//   if (s.totalWaterMlToday > 0) count++;
//   if (s.latestWeightKg != null) count++;
//   if (s.latestSystolic != null) count++;
//   if (s.latestMedicationName != null) count++;
//   if (s.latestMood != null) count++;
//   return count;
// }

class _OverviewStatTile extends StatelessWidget {
  const _OverviewStatTile({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: Colors.grey[400],
              fontFamily: 'Inconsolata',
            ),
          ),
          const SizedBox(height: 4),
          value,
        ],
      ),
    );
  }
}
