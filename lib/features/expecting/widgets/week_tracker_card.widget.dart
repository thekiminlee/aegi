import 'dart:math' as math;

import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/widgets/week_tracker_expanded.widget.dart';
import 'package:flutter/material.dart';
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
    required this.babyName,
    required this.childId,
  });

  final PregnancyCalc calc;
  final String growthLabel;
  final String growthMessage;
  final double? growthHeight;
  final int? growthWeight;
  final DateTime? dueDate;
  final List<Color> gradientColors;
  final Color textColor;
  final String babyName;
  final String childId;

  @override
  Widget build(BuildContext context) {
    final weakTextColor = textColor.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          createWeekTrackerExpandRoute(
            calc: calc,
            dueDate: dueDate,
            babyName: babyName,
            childId: childId,
            gradientColors: gradientColors,
            textColor: textColor,
          ),
        );
      },
      child: Hero(
        tag: 'week-tracker-$childId',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: MeshGradient(
                  points: _buildMeshPoints(gradientColors),
                  options: MeshGradientOptions(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WEEK ${calc.currentWeek}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 16,
                              color: textColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'D-${calc.daysRemaining}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                    // Text(
                    //   growthMessage,
                    //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //         color: weakTextColor,
                    //       ),
                    // ),
                    Text(
                      "$babyName is about the size of",
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: weakTextColor,
                              ),
                    ),
                    Text(
                      growthLabel,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.3
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        MeshGradientPoint(
            position: jittered, color: colors[i % colors.length]),
      );
    }

    return points;
  }
}
