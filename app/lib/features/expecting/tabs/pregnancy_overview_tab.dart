import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
import 'package:aegi/features/expecting/widgets/kick_counter_page.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_daily_metrics.widget.dart';
import 'package:aegi/features/arrived/baby_arrival_flow.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_timeline_screen.dart';
import 'package:aegi/features/expecting/widgets/week_tracker_card.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';

class PregnancyOverviewTab extends ConsumerWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  Widget header(BuildContext context, WidgetRef ref, String childId) {
    return TabHeader(
      subheading:
          "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
      heading: "How are you today?",
      trailing: Showcase(
        targetPadding: const EdgeInsets.all(4),
        targetBorderRadius: BorderRadius.circular(8),
        key: ExpectingShowcaseKeys.viewAll,
        title: 'View All',
        titleTextStyle: showCaseTitleStyle,
        descTextStyle: showcaseDescStyle,
        description: 'View your complete overview of pregnancy timeline',
        child: GestureDetector(
          onTap: () {
            ref.read(analyticsServiceProvider).dailyTimelineViewed(
              mode: AnalyticsMode.expecting,
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PregnancyTimelineScreen(childId: childId),
              ),
            );
          },
          child: Text(
            "VIEW ALL",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey[400],
              fontFamily: "Inconsolata",
              letterSpacing: 1.2,
            ),
          ),
        ),
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
    final gradientColors =
        (growth?['colors'] as List<Color>?) ??
        const [Color(0xFFE0E0E0), Color(0xFFBDBDBD), Color(0xFF9E9E9E)];
    final textColor =
        (growth?['textColor'] as Color?) ?? const Color(0xFF1C1C1E);
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

    final summary = logs.maybeWhen(
      data: (items) => TodaySummary.fromLogs(items, now),
      orElse: TodaySummary.empty,
    );

    return TabPageScaffold(
      child: Column(
        children: [
          Spacer(),
          // header(context, ref, child.id),
          // const SizedBox(height: 16),
          // WeekTrackerCard(
          //   calc: calc,
          //   growthLabel: growthLabel,
          //   growthMessage: growthMessage,
          //   dueDate: dueDate,
          //   growthHeight: growthHeight,
          //   growthWeight: growthWeight,
          //   gradientColors: gradientColors,
          //   textColor: textColor,
          //   babyName: child.name,
          //   childId: child.id,
          // ),
        
      
          // --- Stat tiles row ---
          // const SizedBox(height: 12),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _OverviewStatTile(
          //         label: 'DAYS LEFT',
          //         // value: '${calc.daysRemaining}',
          //         value: Text(
          //           calc.daysRemaining.toString(),
          //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //             fontWeight: FontWeight.w700,
          //             fontFamily: 'Inconsolata',
          //             fontSize: 20
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Showcase(
          //         targetPadding: const EdgeInsets.all(5),
          //         targetBorderRadius: BorderRadius.circular(8),
          //         key: ExpectingShowcaseKeys.kickCounter,
          //         title: 'Kick Counter',
          //         titleTextStyle: showCaseTitleStyle,
          //         descTextStyle: showcaseDescStyle,
          //         description: 'Monitor your baby\'s movements. Count to ten!',
          //         child: GestureDetector(
          //           onTap: () => Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (_) => KickCounterPage(childId: child.id),
          //             ),
          //           ),
          //           child: _OverviewStatTile(
          //             label: 'KICK COUNTER',
          //             value: Icon(
          //               Symbols.footprint,
          //               size: 26,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
      
          // --- Baby is here! ---
          // if (calc.currentWeek >= 38) ...[
          //   const SizedBox(height: 20),
          //   _BabyIsHereButton(child: child),
          // ],

          // --- View all ---
          GestureDetector(
            onTap: () {
              ref.read(analyticsServiceProvider).dailyTimelineViewed(
                mode: AnalyticsMode.expecting,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PregnancyTimelineScreen(childId: child.id),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "VIEW ALL",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Symbols.arrow_outward, size: 16, color: Colors.grey[400], fontWeight: FontWeight.w600),
              ],
            )
          ),
      
          // --- Recent Log ---
          const SizedBox(height: 8),
          PregnancyDailyMetrics(
            summary: summary,
            volumeUnit: volumeUnit,
            weightUnit: weightUnit,
            childId: child.id,
            onTileTap: (tab) =>
                showUnifiedEntrySheet(context, ref, child, initialTab: tab),
          ),
        ],
      ),
    );
  }
}

class _BabyIsHereButton extends StatelessWidget {
  const _BabyIsHereButton({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => BabyArrivalFlow(child: child))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9F0), Color(0xFFFFF3E6), Color(0xFFFFF0F5)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _ConfettiDotsPainter(),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB07C), Color(0xFFF28482)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Symbols.celebration_rounded,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Baby is here!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1C1C1E),
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inconsolata"
                      ),
                    ),
                    Text(
                      'Tap to switch to baby mode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inconsolata"
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiDotsPainter extends CustomPainter {
  static const _dots = [
    // (relativeX, relativeY, radius, color)
    (0.82, 0.18, 12.0, Color(0x38F28482)),
    (0.90, 0.70, 14.0, Color(0x38A8DADC)),
    (0.75, 0.80, 18.5, Color(0x38F6BD60)),
    (0.60, 0.12, 15.5, Color(0x3890BE6D)),
    (0.95, 0.40, 10.5, Color(0x38B5C7ED)),
    (0.68, 0.55, 28.0, Color(0x30F28482)),
    (0.50, 0.85, 16.0, Color(0x3084A59D)),
    (0.88, 0.90, 20.0, Color(0x30FFB07C)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (rx, ry, r, color) in _dots) {
      final center = Offset(size.width * rx, size.height * ry);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OverviewStatTile extends StatelessWidget {
  const _OverviewStatTile({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
