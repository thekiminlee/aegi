import 'dart:math';

import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// ---------------------------------------------------------------------------
// Trend category
// ---------------------------------------------------------------------------

enum _TrendCategory { feedFormula, feedBreastMilk, diaper, sleep }

// ---------------------------------------------------------------------------
// Bar data model
// ---------------------------------------------------------------------------

class _BarData {
  _BarData({required this.label, required this.primary, this.secondary = 0});
  final String label;
  final double primary;
  final double secondary;
  double get total => primary + secondary;
}

// ---------------------------------------------------------------------------
// Main Trends Tab
// ---------------------------------------------------------------------------

class ArrivedTrendsTab extends ConsumerStatefulWidget {
  const ArrivedTrendsTab({required this.child, super.key});
  final ChildProfile child;

  @override
  ConsumerState<ArrivedTrendsTab> createState() => _ArrivedTrendsTabState();
}

class _ArrivedTrendsTabState extends ConsumerState<ArrivedTrendsTab> {
  int _selectedPage = 0;

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < -100 && _selectedPage < 3) {
      setState(() => _selectedPage++);
    } else if (details.primaryVelocity! > 100 && _selectedPage > 0) {
      setState(() => _selectedPage--);
    }
  }

  // --- Helpers ---------------------------------------------------------------

  List<BabyLog> _logsForDay(List<BabyLog> all, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return all
        .where((l) => !l.timestamp.isBefore(start) && l.timestamp.isBefore(end))
        .toList();
  }

  double _formulaMl(List<BabyLog> logs) {
    double t = 0;
    for (final l in logs) {
      if (l.type != BabyLogType.bottleFeed) continue;
      final a = (l.metadata['amount'] as num?)?.toDouble() ?? 0;
      final u = (l.metadata['unit'] as String?) ?? 'ml';
      t += u == 'oz' ? a * 29.5735 : a;
    }
    return t;
  }

  int _breastCount(List<BabyLog> logs) =>
      logs.where((l) => l.type == BabyLogType.breastMilk).length;

  (int, int) _diapers(List<BabyLog> logs) {
    int w = 0, d = 0;
    for (final l in logs) {
      if (l.type == BabyLogType.diaperWet) w++;
      if (l.type == BabyLogType.diaperDirty) d++;
    }
    return (w, d);
  }

  (int, int) _sleepMin(List<BabyLog> logs) {
    int n = 0, s = 0;
    for (final l in logs) {
      if (l.type == BabyLogType.nap) {
        n += (l.metadata['durationMin'] as num?)?.toInt() ?? 0;
      }
      if (l.type == BabyLogType.nightSleep) {
        s += (l.metadata['durationMin'] as num?)?.toInt() ?? 0;
      }
    }
    return (n, s);
  }

  String _pct(double today, double yesterday) {
    if (yesterday == 0 && today == 0) return '--';
    if (yesterday == 0) return '+100%';
    final p = ((today - yesterday) / yesterday * 100).round();
    return p >= 0 ? '+$p%' : '$p%';
  }

  String _fmtMin(int m) {
    if (m == 0) return '0m';
    final h = m ~/ 60;
    final r = m % 60;
    if (h == 0) return '${r}m';
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }

  // --- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(arrivedBabyLogsProvider(widget.child.id));
    final allLogs = logsAsync.maybeWhen(
      data: (d) => d,
      orElse: () => <BabyLog>[],
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final tLogs = _logsForDay(allLogs, today);
    final yLogs = _logsForDay(allLogs, yesterday);

    // Today stats
    final fmlToday = _formulaMl(tLogs);
    final fmlYday = _formulaMl(yLogs);
    final bmToday = _breastCount(tLogs);
    final bmYday = _breastCount(yLogs);
    final (wetT, dirtyT) = _diapers(tLogs);
    final (wetY, dirtyY) = _diapers(yLogs);
    final (napT, nightT) = _sleepMin(tLogs);
    final (napY, nightY) = _sleepMin(yLogs);

    // Weekly data (last 7 days)
    final weekDays =
        List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final category = _TrendCategory.values[_selectedPage];

    final bars = weekDays.map((d) {
      final dl = _logsForDay(allLogs, d);
      final label = DateFormat.E().format(d).substring(0, 2);
      switch (category) {
        case _TrendCategory.feedFormula:
          return _BarData(label: label, primary: _formulaMl(dl));
        case _TrendCategory.feedBreastMilk:
          return _BarData(label: label, primary: _breastCount(dl).toDouble());
        case _TrendCategory.diaper:
          final (w, dd) = _diapers(dl);
          return _BarData(
              label: label, primary: w.toDouble(), secondary: dd.toDouble());
        case _TrendCategory.sleep:
          final (n, s) = _sleepMin(dl);
          return _BarData(
              label: label, primary: n / 60, secondary: s / 60);
      }
    }).toList();

    final (primaryColor, secondaryColor, primaryLabel, secondaryLabel) =
        switch (category) {
      _TrendCategory.feedFormula => (
          const Color(0xFFA8DADC),
          Colors.transparent,
          'Formula',
          '',
        ),
      _TrendCategory.feedBreastMilk => (
          const Color(0xFFB5C7ED),
          Colors.transparent,
          'Breast Milk',
          '',
        ),
      _TrendCategory.diaper => (
          const Color(0xFF90BE6D),
          const Color(0xFFF6BD60),
          'Wet',
          'Dirty',
        ),
      _TrendCategory.sleep => (
          const Color(0xFF84A59D),
          const Color(0xFFF28482),
          'Nap',
          'Night',
        ),
    };

    return TabScaffold(
      children: [
        TabHeader(
          subheading: DateFormat.MMMd().format(now).toUpperCase(),
          heading: "Trends",
        ),
        const SizedBox(height: 14),

        // --- Carousel ---
        SizedBox(
          height: 160,
          child: GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(_selectedPage),
              child: switch (_selectedPage) {
                0 => _FeedFormulaCard(
                    totalMl: fmlToday,
                    pctChange: _pct(fmlToday, fmlYday),
                    progress: (fmlToday / 1000).clamp(0.0, 1.0),
                  ),
                1 => _BreastMilkCard(
                    count: bmToday,
                    pctChange:
                        _pct(bmToday.toDouble(), bmYday.toDouble()),
                  ),
                2 => _DiaperCard(
                    wet: wetT,
                    dirty: dirtyT,
                    wetPct: _pct(wetT.toDouble(), wetY.toDouble()),
                    dirtyPct: _pct(dirtyT.toDouble(), dirtyY.toDouble()),
                  ),
                _ => _SleepCard(
                    napMin: napT,
                    nightMin: nightT,
                    napPct: _pct(napT.toDouble(), napY.toDouble()),
                    nightPct: _pct(nightT.toDouble(), nightY.toDouble()),
                    fmtMin: _fmtMin,
                  ),
              },
            ),
            ),
          ),
        ),

        // --- Weekly chart ---
        const SizedBox(height: 14),
        GestureDetector(
          onHorizontalDragEnd: _onSwipe,
          child: _WeeklyChart(
            bars: bars,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            primaryLabel: primaryLabel,
            secondaryLabel: secondaryLabel,
            isStacked: category == _TrendCategory.diaper ||
                category == _TrendCategory.sleep,
          ),
        ),

        // --- Page indicator ---
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _selectedPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color:
                    i == _selectedPage ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carousel Cards
// ---------------------------------------------------------------------------

class _FeedFormulaCard extends StatelessWidget {
  const _FeedFormulaCard({
    required this.totalMl,
    required this.pctChange,
    required this.progress,
  });

  final double totalMl;
  final String pctChange;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CardLabel(
                  icon: Symbols.pediatrics_rounded,
                  tint: const Color(0xFFA8DADC),
                  text: 'Total Formula',
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${totalMl.round()}', style: _valueLarge(context)),
                    SizedBox(width: 5,),
                    Text('ml', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[400]
                    ))
                  ],
                ),
                _ChangeRow(pctChange: pctChange),
              ],
            ),
          ),
          _ProgressRing(
            progress: progress,
            color: const Color(0xFFA8DADC),
          ),
        ],
      ),
    );
  }
}

class _BreastMilkCard extends StatelessWidget {
  const _BreastMilkCard({
    required this.count,
    required this.pctChange,
  });

  final int count;
  final String pctChange;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CardLabel(
            icon: Symbols.breastfeeding_rounded,
            tint: const Color(0xFFB5C7ED),
            text: 'Total Breast Milk',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$count', style: _valueLarge(context)),
              const SizedBox(width: 5),
              Text(count == 1 ? 'feed' : 'feeds', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400]
              ))
            ],
          ),
          _ChangeRow(pctChange: pctChange),
        ],
      ),
    );
  }
}

class _DiaperCard extends StatelessWidget {
  const _DiaperCard({
    required this.wet,
    required this.dirty,
    required this.wetPct,
    required this.dirtyPct,
  });

  final int wet;
  final int dirty;
  final String wetPct;
  final String dirtyPct;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CardLabel(
            icon: Icons.baby_changing_station_outlined,
            tint: const Color(0xFF90BE6D),
            text: 'Diapers',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(
                icon: Icons.water_drop_outlined,
                tint: const Color(0xFF90BE6D),
                value: '$wet',
                label: 'Wet',
                pctChange: wetPct,
              ),
              // const SizedBox(width: 32),
              _StatColumn(
                icon: Icons.cloud_outlined,
                tint: const Color(0xFFF6BD60),
                value: '$dirty',
                label: 'Dirty',
                pctChange: dirtyPct,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChangeRow(pctChange: wetPct),
              _ChangeRow(pctChange: dirtyPct)
            ],
          )
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({
    required this.napMin,
    required this.nightMin,
    required this.napPct,
    required this.nightPct,
    required this.fmtMin,
  });

  final int napMin;
  final int nightMin;
  final String napPct;
  final String nightPct;
  final String Function(int) fmtMin;

  @override
  Widget build(BuildContext context) {
    return _CarouselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CardLabel(
            icon: Icons.bedtime_outlined,
            tint: const Color(0xFF84A59D),
            text: 'Sleep',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(
                icon: Icons.bedtime_outlined,
                tint: const Color(0xFF84A59D),
                value: fmtMin(napMin),
                label: 'Nap',
                pctChange: napPct,
              ),
              const SizedBox(width: 32),
              _StatColumn(
                icon: Icons.nights_stay_outlined,
                tint: const Color(0xFFF28482),
                value: fmtMin(nightMin),
                label: 'Night',
                pctChange: nightPct,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChangeRow(pctChange: napPct),
              _ChangeRow(pctChange: nightPct)
            ],
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared carousel helpers
// ---------------------------------------------------------------------------

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({
    required this.icon,
    required this.tint,
    required this.text,
  });
  final IconData icon;
  final Color tint;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Icon(icon, size: 20, color: tint, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
    required this.pctChange,
  });
  final IconData icon;
  final Color tint;
  final String value;
  final String label;
  final String pctChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: _valueLarge(context)),
            SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400]
              )
            ),
          ],
        ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.pctChange});
  final String pctChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$pctChange from yesterday',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontFamily: "Saira",
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress Ring (donut chart for feed formula)
// ---------------------------------------------------------------------------

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;
  static const double size = 90;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontFamily: 'Inconsolata',
              fontWeight: FontWeight.w700,
              fontSize: size * 0.22,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    const sw = 10.0;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.grey[200]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// Weekly Bar Chart
// ---------------------------------------------------------------------------

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.bars,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isStacked,
  });

  final List<_BarData> bars;
  final Color primaryColor;
  final Color secondaryColor;
  final String primaryLabel;
  final String secondaryLabel;
  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.fold<double>(0, (m, b) => max(m, b.total));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
      child: Column(
        children: [
          // Legend (only for stacked bars)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Weekly Trend", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3
              )),
              if (isStacked)
                Row(
                  children: [
                    _LegendDot(color: primaryColor, label: primaryLabel),
                    const SizedBox(width: 16),
                    _LegendDot(color: secondaryColor, label: secondaryLabel),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12),

          // Chart area
          SizedBox(
            height: 150,
            child: maxVal == 0
                ? Center(
                    child: Text(
                      'No trends to display',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Y-axis labels
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [4, 3, 2, 1].map((i) {
                            final v = (maxVal / 4 * i).round();
                            return Text(
                              '$v',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                                fontFamily: "Inconsolata",
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bars
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: bars.map((b) {
                            final ratio = b.total / maxVal;
                            final barHeight =
                                max(ratio * 120, b.total > 0 ? 4.0 : 0.0);

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isStacked)
                                      _buildStackedBar(b, barHeight)
                                    else
                                      Container(
                                        width: 28,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      b.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontFamily: "Inconsolata",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedBar(_BarData b, double barHeight) {
    if (barHeight <= 0) return const SizedBox.shrink();

    final hasPrimary = b.primary > 0;
    final hasSecondary = b.secondary > 0;
    final pRatio = b.total > 0 ? b.primary / b.total : 0.0;

    return SizedBox(
      height: barHeight,
      width: 28,
      child: Column(
        children: [
          if (hasSecondary)
            Expanded(
              flex: ((1 - pRatio) * 100).round().clamp(1, 100),
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(6),
                    bottom:
                        hasPrimary ? Radius.zero : const Radius.circular(6),
                  ),
                ),
              ),
            ),
          if (hasPrimary)
            Expanded(
              flex: (pRatio * 100).round().clamp(1, 100),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(
                    top: hasSecondary
                        ? Radius.zero
                        : const Radius.circular(6),
                    bottom: const Radius.circular(6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: "Saira",
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Text style helpers
// ---------------------------------------------------------------------------

TextStyle _valueLarge(BuildContext context) => TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: Colors.grey[800],
      // fontFamily: "Saira",
      height: 1.1,
    );
