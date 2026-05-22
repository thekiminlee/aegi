import 'dart:math';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/components/arrived_helpers.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/widgets/trend_carousel_cards.widget.dart';
import 'package:aegi/features/arrived/widgets/weekly_chart.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// ---------------------------------------------------------------------------
// Trend category
// ---------------------------------------------------------------------------

enum _TrendCategory {
  feed,
  diaper,
  sleep,
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
  _TrendCategory _selected = _TrendCategory.feed;

  void _showFormulaInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formula Intake Reference',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: "Source Serif 4",
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'A commonly used reference point is 1000 ml or 32 oz in a day.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: "Source Serif 4"),
            ),
            const SizedBox(height: 12),
            Text(
              'This is general informational context for tracking trends and is not medical advice. Daily needs can vary, so follow any guidance you have been given for your baby.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: "Source Serif 4"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---------------------------------------------------------------

  List<BabyLog> _logsForDay(List<BabyLog> all, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return all
        .where(
          (l) => !l.timestamp.isBefore(start) && l.timestamp.isBefore(end),
        )
        .toList();
  }

  double _bottleMl(List<BabyLog> logs, String kind) {
    double t = 0;
    for (final l in logs) {
      if (l.type != BabyLogType.bottleFeed) continue;
      if (bottleFeedKind(l) != kind) continue;
      final amount = (l.metadata['displayAmount'] as num?)?.toDouble() ?? 0;
      t += amount;
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

  String _fmtAmount(double amount, VolumeUnit unit) {
    return unit == VolumeUnit.oz
        ? amount.toStringAsFixed(1)
        : '${amount.round()}';
  }

  // --- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(arrivedBabyLogsProvider(widget.child.id));
    final settingsAsync = ref.watch(appSettingsProvider);
    final volumeUnit =
        settingsAsync.maybeWhen(
          data: (s) => s?.volumeUnit,
          orElse: () => null,
        ) ??
        VolumeUnit.ml;
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
    final fmlToday = _bottleMl(tLogs, 'formula');
    final fmlYday = _bottleMl(yLogs, 'formula');
    final expToday = _bottleMl(tLogs, 'expressed');
    final expYday = _bottleMl(yLogs, 'expressed');
    final bmToday = _breastCount(tLogs);
    final (wetT, dirtyT) = _diapers(tLogs);
    final (wetY, dirtyY) = _diapers(yLogs);
    final (napT, nightT) = _sleepMin(tLogs);
    final (napY, nightY) = _sleepMin(yLogs);

    // Weekly data (last 7 days)
    final weekDays = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final category = _selected;

    final bars = weekDays.map((d) {
      final dl = _logsForDay(allLogs, d);
      final label = DateFormat.E().format(d).substring(0, 2);
      switch (category) {
        case _TrendCategory.feed:
          return BarData(
            label: label,
            primary: _bottleMl(dl, 'formula'),
            secondary: _bottleMl(dl, 'expressed'),
          );
        case _TrendCategory.diaper:
          final (w, dd) = _diapers(dl);
          return BarData(
            label: label,
            primary: w.toDouble(),
            secondary: dd.toDouble(),
          );
        case _TrendCategory.sleep:
          final (n, s) = _sleepMin(dl);
          return BarData(label: label, primary: n / 60, secondary: s / 60);
      }
    }).toList();

    final (primaryColor, secondaryColor) = switch (category) {
      _TrendCategory.feed => (
        const Color(0xFFA8DADC),
        const Color(0xFF7DB7E8),
      ),
      _TrendCategory.diaper => (
        const Color(0xFF90BE6D),
        const Color(0xFFF6BD60),
      ),
      _TrendCategory.sleep => (
        const Color(0xFF84A59D),
        const Color(0xFFF28482),
      ),
    };

    // Build selected trend card
    final totalIntake = fmlToday + expToday;
    final totalIntakeYday = fmlYday + expYday;

    final trendCard = switch (_selected) {
      _TrendCategory.feed => _FeedOverviewCard(
        totalAmount: totalIntake,
        pctChange: _pct(totalIntake, totalIntakeYday),
        formulaAmount: fmlToday,
        expressedAmount: expToday,
        breastCount: bmToday,
        volumeUnit: volumeUnit,
        onInfoTap: () => _showFormulaInfoSheet(context),
      ),
      _TrendCategory.diaper => DiaperCard(
        wet: wetT,
        dirty: dirtyT,
        wetPct: _pct(wetT.toDouble(), wetY.toDouble()),
        dirtyPct: _pct(dirtyT.toDouble(), dirtyY.toDouble()),
      ),
      _TrendCategory.sleep => SleepCard(
        napMin: napT,
        nightMin: nightT,
        napPct: _pct(napT.toDouble(), napY.toDouble()),
        nightPct: _pct(nightT.toDouble(), nightY.toDouble()),
        fmtMin: _fmtMin,
      ),
    };

    // Legend for dual-line categories
    final legendRow = switch (_selected) {
      _TrendCategory.feed => null, // breakdown chips serve as legend
      _TrendCategory.diaper => Row(
        children: [
          _LegendDot(color: const Color(0xFF90BE6D), label: 'Wet'),
          const SizedBox(width: 16),
          _LegendDot(color: const Color(0xFFF6BD60), label: 'Dirty'),
        ],
      ),
      _TrendCategory.sleep => Row(
        children: [
          _LegendDot(color: const Color(0xFF84A59D), label: 'Nap'),
          const SizedBox(width: 16),
          _LegendDot(color: const Color(0xFFF28482), label: 'Night'),
        ],
      ),
    };

    // Card + chart flipping together
    final flipContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 180, child: trendCard),
        if (legendRow != null) ...[
          const SizedBox(height: 10),
          legendRow,
        ],
        const SizedBox(height: 14),
        WeeklyChart(
          bars: bars,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          hasSecondary: true,
        ),
      ],
    );

    return TabPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                // --- Card + chart with flip animation ---
                _FlipTransition(
                  flipKey: _selected.index,
                  child: flipContent,
                ),

                // --- Metric tiles ---
                const SizedBox(height: 14),

                // Top: Feed
                _TrendTileRow(
                  tiles: [
                    _TrendTileData(
                      category: _TrendCategory.feed,
                      icon: Symbols.pediatrics_rounded,
                      tint: const Color(0xFFA8DADC),
                      label: 'feed',
                      value:
                          '${_fmtAmount(totalIntake, volumeUnit)} ${volumeUnit.name}',
                      subtitle: 'Today',
                    ),
                  ],
                  selected: _selected,
                  onSelect: (cat) => setState(() => _selected = cat),
                ),
                const SizedBox(height: 3),

                // Bottom: Diaper, Sleep
                _TrendTileRow(
                  tiles: [
                    _TrendTileData(
                      category: _TrendCategory.diaper,
                      icon: Icons.baby_changing_station_outlined,
                      tint: const Color(0xFF90BE6D),
                      label: 'diaper',
                      value: '$wetT / $dirtyT',
                      subtitle: 'Today',
                    ),
                    _TrendTileData(
                      category: _TrendCategory.sleep,
                      icon: Icons.bedtime_outlined,
                      tint: const Color(0xFF84A59D),
                      label: 'sleep',
                      value: _fmtMin(napT + nightT),
                      subtitle: 'Today',
                    ),
                  ],
                  selected: _selected,
                  onSelect: (cat) => setState(() => _selected = cat),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feed Overview Card — total intake + breakdown
// ---------------------------------------------------------------------------

class _FeedOverviewCard extends StatelessWidget {
  const _FeedOverviewCard({
    required this.totalAmount,
    required this.pctChange,
    required this.formulaAmount,
    required this.expressedAmount,
    required this.breastCount,
    required this.volumeUnit,
    required this.onInfoTap,
  });

  final double totalAmount;
  final String pctChange;
  final double formulaAmount;
  final double expressedAmount;
  final int breastCount;
  final VolumeUnit volumeUnit;
  final VoidCallback onInfoTap;

  String _fmt(double amount) {
    return volumeUnit == VolumeUnit.oz
        ? amount.toStringAsFixed(1)
        : '${amount.round()}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _fmt(totalAmount),
                  style: valueLargeStyle(context),
                ),
                const SizedBox(width: 5),
                Text(
                  volumeUnit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[400],
                        fontFamily: "Inconsolata",
                      ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onInfoTap,
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BreakdownChip(
              label: 'Formula',
              value: '${_fmt(formulaAmount)} ${volumeUnit.name}',
              tint: const Color(0xFFA8DADC),
            ),
            _BreakdownChip(
              label: 'Expressed',
              value: '${_fmt(expressedAmount)} ${volumeUnit.name}',
              tint: const Color(0xFF7DB7E8),
            ),
            _BreakdownChip(
              label: 'Breast',
              value: '$breastCount',
              tint: const Color(0xFFB5C7ED),
            ),
          ],
        ),
      ],
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({
    required this.label,
    required this.value,
    required this.tint,
  });

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: "Inconsolata",
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Legend dot
// ---------------------------------------------------------------------------

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
            fontFamily: "Inconsolata",
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Flip Transition — 3D X-axis flip when switching categories
// ---------------------------------------------------------------------------

class _FlipTransition extends StatefulWidget {
  const _FlipTransition({
    required this.flipKey,
    required this.child,
  });

  final int flipKey;
  final Widget child;

  @override
  State<_FlipTransition> createState() => _FlipTransitionState();
}

class _FlipTransitionState extends State<_FlipTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Widget _oldChild = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _oldChild = widget.child;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _oldChild = widget.child;
        }
      });
  }

  @override
  void didUpdateWidget(_FlipTransition old) {
    super.didUpdateWidget(old);
    if (old.flipKey != widget.flipKey) {
      _oldChild = old.child;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final val = _ctrl.value;
        final showNew = val > 0.5;
        final child = showNew ? widget.child : _oldChild;

        // First half: rotate old content 0 → π/2 (edge-on)
        // Second half: rotate new content -π/2 → 0 (revealed)
        final angle = showNew ? (val - 1.0) * pi : val * pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle),
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Trend Tile — matches MetricTile style from core/widgets/metric_tile.dart
// ---------------------------------------------------------------------------

class _TrendTileData {
  const _TrendTileData({
    required this.category,
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final _TrendCategory category;
  final IconData icon;
  final Color tint;
  final String label;
  final String value;
  final String subtitle;
}

class _TrendTileRow extends StatelessWidget {
  const _TrendTileRow({
    required this.tiles,
    required this.selected,
    required this.onSelect,
  });

  final List<_TrendTileData> tiles;
  final _TrendCategory selected;
  final ValueChanged<_TrendCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final fullWidth = MediaQuery.sizeOf(context).width;
    final tileWidth =
        (fullWidth - 32 - 3 * (tiles.length - 1)) / tiles.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tiles
          .map(
            (tile) => _TrendTile(
              data: tile,
              width: tileWidth,
              isSelected: selected == tile.category,
              onTap: () => onSelect(tile.category),
            ),
          )
          .toList(),
    );
  }
}

class _TrendTile extends StatelessWidget {
  const _TrendTile({
    required this.data,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  final _TrendTileData data;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.height * 0.17,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(
            color: isSelected
                ? context.appColors.selectedAccent
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                ),
                Icon(
                  data.icon,
                  color: data.tint,
                  size: 24,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        data.value,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
