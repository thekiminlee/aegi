import 'dart:math' as math;

import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class WeekTrackerCard extends StatelessWidget {
  const WeekTrackerCard({
    super.key,
    required this.calc,
    required this.growthLabel,
    required this.growthMessage,
    required this.dueDate,
    required this.growthHeight,
    required this.growthWeight,
    required this.gradientColors,
    required this.textColor,
  });

  final PregnancyCalc calc;
  final String growthLabel;
  final String growthMessage;
  final double? growthHeight;
  final int? growthWeight;
  final DateTime? dueDate;
  final List<Color> gradientColors;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final weakTextColor = textColor.withValues(alpha: 0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(
            child: MeshGradient(
              points: _buildMeshPoints(gradientColors),
              options: MeshGradientOptions(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEK ${calc.currentWeek}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: weakTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  growthLabel,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (growthHeight != null && growthWeight != null) ...[
                  Text(
                    'Baby is about ${growthHeight!.toStringAsFixed(1)} cm and ${growthWeight! / 1000} kg',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: weakTextColor,
                    ),
                  ),
                ],
                Text(
                  growthMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: weakTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: calc.progress,
                    backgroundColor: textColor.withValues(alpha: 0.12),
                    valueColor: calc.daysRemaining <= 0
                        ? AlwaysStoppedAnimation(Colors.green[300])
                        : AlwaysStoppedAnimation(textColor.withValues(alpha: 0.8)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 20,
                          color: weakTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dueDate == null
                              ? 'Add due date in settings'
                              : '${calc.daysRemaining} day${calc.daysRemaining <= 1 ? '' : 's'} to go',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: weakTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dueDate == null
                          ? 'Due date not set'
                          : 'Due ${DateFormat.yMMMd().format(dueDate!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: weakTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MeshGradientPoint> _buildMeshPoints(List<Color> colors) {
    final seed = Object.hashAll(colors.map((c) => c.toARGB32()));
    final random = math.Random(seed);

    const anchors = <Offset>[
      Offset(0.15, 0.18),
      Offset(0.82, 0.20),
      Offset(0.28, 0.58),
      Offset(0.76, 0.68),
      Offset(0.40, 0.90),
      Offset(0.08, 0.74),
      Offset(0.62, 0.10),
    ];

    final pointCount = math.max(4, math.min(colors.length, anchors.length));
    final points = <MeshGradientPoint>[];

    for (var i = 0; i < pointCount; i++) {
      final base = anchors[i];
      final jittered = Offset(
        (base.dx + (random.nextDouble() - 0.5) * 0.18).clamp(0.0, 1.0),
        (base.dy + (random.nextDouble() - 0.5) * 0.18).clamp(0.0, 1.0),
      );
      points.add(
        MeshGradientPoint(position: jittered, color: colors[i % colors.length]),
      );
    }

    return points;
  }
}
