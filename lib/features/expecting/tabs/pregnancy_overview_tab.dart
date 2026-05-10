import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
// import 'package:aegi/features/expecting/widgets/kick_counter_card.widget.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_daily_metrics.widget.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_timeline_screen.dart';
import 'package:aegi/features/expecting/widgets/week_tracker_card.widget.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PregnancyOverviewTab extends ConsumerWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  Widget header(BuildContext context, String childId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontFamily: "Inconsolata",
                  letterSpacing: 1.2,
                ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PregnancyTimelineScreen(childId: childId),
              ),
            ),
            // child: Icon(Icons.calendar_view_month_outlined, color: Colors.grey[300], size: 24),
            child: Text("VIEW ALL", style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontFamily: "Inconsolata",
                  letterSpacing: 1.2,))
          )
        ],
      ),
      const SizedBox(height: 6),
      Text(
        "How are you today?",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontFamily: "Source Serif 4",
            ),
      ),
    ],);
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        WeekTrackerCard(calc: calc, growthLabel: growthLabel, growthMessage: growthMessage, dueDate: dueDate, growthHeight: growthHeight, growthWeight: growthWeight, gradientColors: gradientColors, textColor: textColor, babyName: child.name, childId: child.id),
        const SizedBox(height: 16),
        header(context, child.id),
        // const SizedBox(height: 16),
        // KickCounterCard(childId: child.id),
        const SizedBox(height: 12),
        PregnancyDailyMetrics(summary: summary, volumeUnit: volumeUnit, weightUnit: weightUnit, childId: child.id),
      ],
    );
  }
}
