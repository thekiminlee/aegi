import 'dart:math';

import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// ---------------------------------------------------------------------------
// Carousel Cards
// ---------------------------------------------------------------------------

class FeedFormulaCard extends StatelessWidget {
  const FeedFormulaCard({
    required this.totalAmount,
    required this.pctChange,
    required this.progress,
    required this.volumeUnit,
    required this.onInfoTap,
    super.key,
  });

  final double totalAmount;
  final String pctChange;
  final double progress;
  final VolumeUnit volumeUnit;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: CardLabel(
                          icon: Symbols.pediatrics_rounded,
                          tint: Color(0xFFA8DADC),
                          text: 'Total Formula',
                        ),
                      ),
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
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        volumeUnit == VolumeUnit.oz
                            ? totalAmount.toStringAsFixed(1)
                            : '${totalAmount.round()}',
                        style: valueLargeStyle(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        volumeUnit.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.grey[400],
                              fontFamily: "Urbanist",
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ChangeRow(pctChange: pctChange),
                ],
              ),
            ),
            ProgressRing(progress: progress, color: const Color(0xFFA8DADC)),
          ],
        ),
      ],
    );
  }
}

class FeedExpressedCard extends StatelessWidget {
  const FeedExpressedCard({
    required this.totalAmount,
    required this.pctChange,
    required this.volumeUnit,
    super.key,
  });

  final double totalAmount;
  final String pctChange;
  final VolumeUnit volumeUnit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CardLabel(
          icon: Icons.local_drink_outlined,
          tint: const Color(0xFF7DB7E8),
          text: 'Total Expressed',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              volumeUnit == VolumeUnit.oz
                  ? totalAmount.toStringAsFixed(1)
                  : '${totalAmount.round()}',
              style: valueLargeStyle(context),
            ),
            const SizedBox(width: 5),
            Text(
              volumeUnit.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
                fontFamily: "Urbanist",
              ),
            ),
          ],
        ),
        ChangeRow(pctChange: pctChange),
      ],
    );
  }
}

class BreastMilkCard extends StatelessWidget {
  const BreastMilkCard({
    required this.count,
    required this.pctChange,
    super.key,
  });

  final int count;
  final String pctChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CardLabel(
          icon: Symbols.breastfeeding_rounded,
          tint: const Color(0xFFB5C7ED),
          text: 'Total Breast Feed',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$count', style: valueLargeStyle(context)),
            const SizedBox(width: 5),
            Text(
              count == 1 ? 'feed' : 'feeds',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
                fontFamily: "Urbanist",
              ),
            ),
          ],
        ),
        ChangeRow(pctChange: pctChange),
      ],
    );
  }
}

class DiaperCard extends StatelessWidget {
  const DiaperCard({
    required this.wet,
    required this.dirty,
    required this.wetPct,
    required this.dirtyPct,
    super.key,
  });

  final int wet;
  final int dirty;
  final String wetPct;
  final String dirtyPct;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatColumn(
              icon: Symbols.humidity_high,
              tint: const Color(0xFF90BE6D),
              value: '$wet',
              label: 'Wet',
              pctChange: wetPct,
            ),
            StatColumn(
              icon: Icons.cloud_outlined,
              tint: const Color(0xFFF6BD60),
              value: '$dirty',
              label: 'Dirty',
              pctChange: dirtyPct,
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     ChangeRow(pctChange: wetPct),
        //     ChangeRow(pctChange: dirtyPct),
        //   ],
        // ),
      ],
    );
  }
}

class SleepCard extends StatelessWidget {
  const SleepCard({
    required this.napMin,
    required this.nightMin,
    required this.napPct,
    required this.nightPct,
    required this.fmtMin,
    super.key,
  });

  final int napMin;
  final int nightMin;
  final String napPct;
  final String nightPct;
  final String Function(int) fmtMin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatColumn(
              icon: Icons.bedtime_outlined,
              tint: const Color(0xFF84A59D),
              value: fmtMin(napMin),
              label: 'Nap',
              pctChange: napPct,
            ),
            const SizedBox(width: 32),
            StatColumn(
              icon: Icons.nights_stay_outlined,
              tint: const Color(0xFFF28482),
              value: fmtMin(nightMin),
              label: 'Night',
              pctChange: nightPct,
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     ChangeRow(pctChange: napPct),
        //     ChangeRow(pctChange: nightPct),
        //   ],
        // ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared carousel helpers
// ---------------------------------------------------------------------------

class CarouselCard extends StatelessWidget {
  const CarouselCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
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

class CardLabel extends StatelessWidget {
  const CardLabel({
    required this.icon,
    required this.tint,
    required this.text,
    super.key,
  });
  final IconData icon;
  final Color tint;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class StatColumn extends StatelessWidget {
  const StatColumn({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
    required this.pctChange,
    super.key,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value, style: valueLargeStyle(context)),
            SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChangeRow extends StatelessWidget {
  const ChangeRow({required this.pctChange, super.key});
  final String pctChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$pctChange from yesterday',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[500],
            fontFamily: "Urbanist",
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress Ring (donut chart for feed formula)
// ---------------------------------------------------------------------------

class ProgressRing extends StatelessWidget {
  const ProgressRing({required this.progress, required this.color, super.key});

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
              fontFamily: 'Urbanist',
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
// Text style helpers
// ---------------------------------------------------------------------------

TextStyle valueLargeStyle(BuildContext context) => TextStyle(
  fontSize: 72,
  fontWeight: FontWeight.w600,
  color: context.appColors.black,
  letterSpacing: -0.5,
  height: 1.1,
);
