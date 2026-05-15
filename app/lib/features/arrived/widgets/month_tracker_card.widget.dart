import 'dart:math' as math;

import 'package:aegi/features/arrived/widgets/month_tracker_expanded.widget.dart';
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class MonthTrackerCard extends StatelessWidget {
  const MonthTrackerCard({
    super.key,
    required this.birthDate,
    required this.babyName,
    required this.childId,
    required this.gradientColors,
    required this.textColor,
  });

  final DateTime birthDate;
  final String babyName;
  final String childId;
  final List<Color> gradientColors;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = _monthsBetween(birthDate, now);
    final days = _remainderDays(birthDate, now);
    final weakTextColor = textColor.withValues(alpha: 0.7);

    final ageDisplay = months > 0 ? '$months' : '${days}D';
    final ageUnit = months > 0 ? (months == 1 ? 'MONTH' : 'MONTHS') : '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          createMonthTrackerExpandRoute(
            birthDate: birthDate,
            babyName: babyName,
            childId: childId,
            gradientColors: gradientColors,
            textColor: textColor,
          ),
        );
      },
      child: Hero(
        tag: 'month-tracker-$childId',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: MeshGradient(
                    points: _buildMeshPoints(gradientColors),
                    options: MeshGradientOptions(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            months > 0 ? 'MO $months' : 'DAY $days',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Inconsolata",
                                  fontSize: 16,
                                  color: textColor.withAlpha(255),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 68),
                      Text(
                        "$babyName is now",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: weakTextColor,
                          fontFamily: "Saira",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (months > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              ageDisplay,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: textColor,
                                    fontSize: 43,
                                    fontFamily: "Saira",
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.8,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ageUnit,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: weakTextColor,
                                    fontSize: 20,
                                    fontFamily: "Saira",
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        )
                      else
                        Text(
                          ageDisplay,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: textColor,
                                fontSize: 43,
                                fontFamily: "Saira",
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.8,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _monthsBetween(DateTime from, DateTime to) {
    int months = (to.year - from.year) * 12 + (to.month - from.month);
    if (to.day < from.day) months--;
    return math.max(0, months);
  }

  int _remainderDays(DateTime from, DateTime to) {
    int months = _monthsBetween(from, to);
    final monthAdjusted = DateTime(
      from.year + (from.month + months - 1) ~/ 12,
      (from.month + months - 1) % 12 + 1,
      from.day,
    );
    return to.difference(monthAdjusted).inDays;
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
