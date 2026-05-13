import 'dart:math';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Round up to nearest "nice" number for y-axis ceiling.
/// Uses multiples of 1, 2, 5 × power-of-10 (e.g. 3→5, 7→10, 23→25, 130→150).
double _niceMax(double raw) {
  if (raw <= 0) return 0;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  final normalized = raw / magnitude;
  final nice = normalized <= 1
      ? 1.0
      : normalized <= 2
          ? 2.0
          : normalized <= 5
              ? 5.0
              : 10.0;
  return nice * magnitude;
}

// ---------------------------------------------------------------------------
// Bar data model
// ---------------------------------------------------------------------------

class BarData {
  BarData({required this.label, required this.primary, this.secondary = 0});
  final String label;
  final double primary;
  final double secondary;
  double get total => primary + secondary;
}

// ---------------------------------------------------------------------------
// Weekly Bar Chart
// ---------------------------------------------------------------------------

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    required this.bars,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isStacked,
    super.key,
  });

  final List<BarData> bars;
  final Color primaryColor;
  final Color secondaryColor;
  final String primaryLabel;
  final String secondaryLabel;
  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    final rawMax = bars.fold<double>(0, (m, b) => max(m, b.total));
    final maxVal = _niceMax(rawMax);

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

  Widget _buildStackedBar(BarData b, double barHeight) {
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
