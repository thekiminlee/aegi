import 'dart:math';

import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

List<String> _buildYAxisLabels(double maxVal) {
  final labels = <String>[];
  int? previousValue;

  for (final i in [4, 3, 2, 1]) {
    final tickValue = (maxVal / 4 * i).floor();
    if (tickValue < 1 || tickValue == previousValue) {
      labels.add('');
      continue;
    }
    labels.add('$tickValue');
    previousValue = tickValue;
  }

  return labels;
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class BarData {
  BarData({required this.label, required this.primary, this.secondary = 0});
  final String label;
  final double primary;
  final double secondary;
  double get total => primary + secondary;
}

// ---------------------------------------------------------------------------
// Weekly Line Chart
// ---------------------------------------------------------------------------

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    required this.bars,
    required this.primaryColor,
    required this.secondaryColor,
    required this.hasSecondary,
    super.key,
  });

  final List<BarData> bars;
  final Color primaryColor;
  final Color secondaryColor;
  final bool hasSecondary;

  @override
  Widget build(BuildContext context) {
    final primaryMax = bars.fold<double>(0, (m, b) => max(m, b.primary));
    final secondaryMax =
        bars.fold<double>(0, (m, b) => max(m, b.secondary));
    final rawMax = hasSecondary
        ? max(primaryMax, secondaryMax)
        : bars.fold<double>(0, (m, b) => max(m, b.total));
    final maxVal = _niceMax(rawMax);
    final yAxisLabels = _buildYAxisLabels(maxVal);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
      child: SizedBox(
        height: 150,
        child: maxVal == 0
            ? Center(
                child: Text(
                  'No trends to display',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontFamily: "Inconsolata",
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
                      children: yAxisLabels.map((label) {
                        return Text(
                          label,
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
                  // Line chart + X-axis labels
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _LineChartPainter(
                              data: bars,
                              maxVal: maxVal,
                              primaryColor: primaryColor,
                              secondaryColor: secondaryColor,
                              hasSecondary: hasSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: bars.map((b) {
                            return Text(
                              b.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Line Chart Painter — smooth cubic bezier curves
// ---------------------------------------------------------------------------

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.maxVal,
    required this.primaryColor,
    required this.secondaryColor,
    required this.hasSecondary,
  });

  final List<BarData> data;
  final double maxVal;
  final Color primaryColor;
  final Color secondaryColor;
  final bool hasSecondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxVal == 0) return;

    final w = size.width;
    final h = size.height;
    final n = data.length;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    for (var i = 1; i <= 4; i++) {
      final y = h - (h * i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Compute points
    final xStep = n > 1 ? w / (n - 1) : w / 2;
    List<Offset> buildPoints(double Function(BarData) getValue) {
      return List.generate(n, (i) {
        final x = n > 1 ? i * xStep : w / 2;
        final val = getValue(data[i]);
        final y = h - (val / maxVal * h);
        return Offset(x, y);
      });
    }

    final primaryPoints =
        buildPoints((b) => hasSecondary ? b.primary : b.total);
    _drawSmoothLine(canvas, size, primaryPoints, primaryColor);

    if (hasSecondary) {
      final secondaryPoints = buildPoints((b) => b.secondary);
      _drawSmoothLine(canvas, size, secondaryPoints, secondaryColor);
    }
  }

  /// Draws a smooth cubic-bezier curve through [points] with gradient fill.
  void _drawSmoothLine(
    Canvas canvas,
    Size size,
    List<Offset> points,
    Color color,
  ) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      canvas.drawCircle(points.first, 4, Paint()..color = color);
      return;
    }

    // Build smooth path using cubic bezier with midpoint control points
    Path buildCurvePath() {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cpx = (p0.dx + p1.dx) / 2;
        path.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
      }
      return path;
    }

    final curvePath = buildCurvePath();

    // Gradient fill under curve
    final fillPath = Path.from(curvePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(curvePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = color;
    final dotBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.data != data ||
      old.maxVal != maxVal ||
      old.primaryColor != primaryColor ||
      old.secondaryColor != secondaryColor ||
      old.hasSecondary != hasSecondary;
}
