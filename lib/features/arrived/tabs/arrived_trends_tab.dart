import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/widgets/trend_carousel_cards.widget.dart';
import 'package:aegi/features/arrived/widgets/weekly_chart.widget.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Trend category
// ---------------------------------------------------------------------------

enum _TrendCategory { feedFormula, feedBreastMilk, diaper, sleep }

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
          return BarData(label: label, primary: _formulaMl(dl));
        case _TrendCategory.feedBreastMilk:
          return BarData(label: label, primary: _breastCount(dl).toDouble());
        case _TrendCategory.diaper:
          final (w, dd) = _diapers(dl);
          return BarData(
              label: label, primary: w.toDouble(), secondary: dd.toDouble());
        case _TrendCategory.sleep:
          final (n, s) = _sleepMin(dl);
          return BarData(
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
                0 => FeedFormulaCard(
                    totalMl: fmlToday,
                    pctChange: _pct(fmlToday, fmlYday),
                    progress: (fmlToday / 1000).clamp(0.0, 1.0),
                  ),
                1 => BreastMilkCard(
                    count: bmToday,
                    pctChange:
                        _pct(bmToday.toDouble(), bmYday.toDouble()),
                  ),
                2 => DiaperCard(
                    wet: wetT,
                    dirty: dirtyT,
                    wetPct: _pct(wetT.toDouble(), wetY.toDouble()),
                    dirtyPct: _pct(dirtyT.toDouble(), dirtyY.toDouble()),
                  ),
                _ => SleepCard(
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
          child: WeeklyChart(
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
