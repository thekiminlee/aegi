import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/gradient_container.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
import 'package:aegi/features/expecting/widgets/log_input.widget.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_daily_metrics.widget.dart';
import 'package:aegi/features/arrived/baby_arrival_flow.dart';
import 'package:aegi/features/expecting/widgets/pregnancy_timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcaseview/showcaseview.dart';

class PregnancyOverviewTab extends StatefulWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  State<PregnancyOverviewTab> createState() => _PregnancyOverviewTabState();
}

class _PregnancyOverviewTabState extends State<PregnancyOverviewTab> {
  bool _showDueDate = false;
  EntryTab? _activeTab;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final child = widget.child;
        final logs = ref.watch(expectingPregnancyLogsProvider(child.id));
        final now = DateTime.now();
        final dueDate = child.dueDate;

        final calc = PregnancyCalc.fromDueDate(dueDate, now);
        final growth = getFetusGrowthByWeek(calc.currentWeek);
        final growthLabel = (growth?['sizeLabel'] as String?) ?? 'Growing baby';
        final gradientColors =
            (growth?['colors'] as List<Color>?) ??
            const [Color(0xFFE0E0E0), Color(0xFFBDBDBD), Color(0xFF9E9E9E)];
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

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: TabPageScaffold(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _showDueDate = !_showDueDate),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "week ${calc.currentWeek}",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: context.appColors.black,
                                        ),
                                  ),
                                ],
                              ),
                              AnimatedRotation(
                                turns: _showDueDate ? 0.5 : 0,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  Symbols.arrow_downward,
                                  size: 20,
                                  color: context.appColors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "about the size of ",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.grey[500]
                          ),
                        ),
                        Text(
                          growthLabel.toLowerCase(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: context.appColors.black
                          ),
                        ),
                        SizedBox(width: 6),
                        GradientContainer(colors: gradientColors, height: 16, width: 16, borderRadius: 99)
                      ],
                    ),
                    // --- Baby is here! ---
                    if (calc.currentWeek >= 36) ...[
                      const SizedBox(height: 18),
                      _BabyIsHereButton(child: child),
                    ],
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.linear,
                      alignment: Alignment.topCenter,
                      child: _showDueDate && dueDate != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Row(
                                children: [
                                  Text(
                                    "due on ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: Colors.grey[500],
                                        ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, y').format(dueDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                          color: context.appColors.black,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
            Column(children: [

              // --- View all ---
              Align(
                alignment: Alignment.centerRight,
                child: Showcase(
                  key: ExpectingShowcaseKeys.timeline,
                  title: 'Timeline',
                  description: 'Tap to view your full pregnancy timeline.',
                  titleTextStyle: showCaseTitleStyle,
                  descTextStyle: showcaseDescStyle,
                  targetPadding: const EdgeInsets.all(8),
                  targetBorderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
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
                    child: Icon(Symbols.arrow_outward, size: 24, color: Colors.grey[400], fontWeight: FontWeight.w600)
                  ),
                ),
              ),

          // --- Recent Log ---
              const SizedBox(height: 8),
              Showcase(
                key: ExpectingShowcaseKeys.metrics,
                title: 'Daily Log',
                description: 'Tap a tile to quickly log water, weight, and more.',
                titleTextStyle: showCaseTitleStyle,
                descTextStyle: showcaseDescStyle,
                targetPadding: const EdgeInsets.all(6),
                targetBorderRadius: BorderRadius.circular(4),
                child: PregnancyDailyMetrics(
                  summary: summary,
                  volumeUnit: volumeUnit,
                  weightUnit: weightUnit,
                  childId: child.id,
                  activeTab: _activeTab,
                  onTileTap: (tab) => setState(() {
                    _activeTab = _activeTab == tab ? null : tab;
                  }),
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: _activeTab == null
                    ? const SizedBox.shrink()
                    : LogInput(
                        key: ValueKey(_activeTab),
                        child: child,
                        tab: _activeTab!,
                        onClose: () => setState(() => _activeTab = null),
                        onSaved: () => setState(() => _activeTab = null),
                      ),
              ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.appColors.accent, context.appColors.accent.withAlpha(180), context.appColors.accent.withAlpha(110)],
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Baby here? Tap here!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.appColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Symbols.arrow_forward, color: context.appColors.white, size: 20),
          ],
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
