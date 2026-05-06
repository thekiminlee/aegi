import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    required this.colors,
    required this.height,
    required this.width,
    this.borderRadius = 0,
    this.child,
    super.key,
  }) : assert(colors.length >= 2 && colors.length <= 6, 'GradientContainer needs 2-6 colors');

  final List<Color> colors;
  final double borderRadius;
  final double height;
  final double width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final seed = Object.hashAll([borderRadius, ...colors.map((c) => c.toARGB32())]);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MeshGradient(
              points: _buildPoints(colors: colors, seed: seed),
              options: MeshGradientOptions(),
            ),
            if (child != null) Center(child: child),
          ],
        ),
      ),
    );
  }

  List<MeshGradientPoint> _buildPoints({
    required List<Color> colors,
    required int seed,
  }) {
    final random = math.Random(seed);
    final anchors = <Offset>[
      const Offset(0.15, 0.18),
      const Offset(0.82, 0.20),
      const Offset(0.28, 0.58),
      const Offset(0.76, 0.68),
      const Offset(0.40, 0.90),
      const Offset(0.08, 0.74),
      const Offset(0.62, 0.10),
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
