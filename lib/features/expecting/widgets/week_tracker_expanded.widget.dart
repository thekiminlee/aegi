import 'dart:math' as math;

import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class WeekTrackerExpandedPage extends StatefulWidget {
  const WeekTrackerExpandedPage({
    required this.calc,
    required this.dueDate,
    required this.babyName,
    required this.childId,
    required this.gradientColors,
    required this.textColor,
    super.key,
  });

  final PregnancyCalc calc;
  final DateTime? dueDate;
  final String babyName;
  final String childId;
  final List<Color> gradientColors;
  final Color textColor;

  @override
  State<WeekTrackerExpandedPage> createState() =>
      _WeekTrackerExpandedPageState();
}

class _WeekTrackerExpandedPageState extends State<WeekTrackerExpandedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentAnimation;

  @override
  void initState() {
    super.initState();
    _contentAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Delay content fade-in until Hero animation settles
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentAnimation.forward();
    });
  }

  @override
  void dispose() {
    _contentAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentFade = CurvedAnimation(
      parent: _contentAnimation,
      curve: Curves.easeOut,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Hero(
          tag: 'week-tracker-${widget.childId}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MeshGradient(
                  points: _buildMeshPoints(widget.gradientColors),
                  options: MeshGradientOptions(),
                ),
                SafeArea(
                  child: FadeTransition(
                    opacity: contentFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'WEEK ${widget.calc.currentWeek}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: widget.textColor,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 20,
                                    color: widget.textColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'D-${widget.calc.daysRemaining}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: widget.textColor,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.babyName,
                                  style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: widget.textColor,
                                      fontSize: 52,
                                      letterSpacing: -1.4
                                    ),
                                ),
                                SizedBox(height: 8),
                                if (widget.dueDate != null) ...[
                                Text(
                                    // widget.dueDate!.toString(),
                                    DateFormat.yMMMd().format(widget.dueDate!),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                      color: widget.textColor,
                                    ),
                                  )
                              ]]
                            )
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SvgPicture.asset("assets/img/logo/logo.svg"),
                                Text(
                                  'aegi',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: widget.textColor,
                                    letterSpacing: -1.1
                                  )
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

Route createWeekTrackerExpandRoute({
  required PregnancyCalc calc,
  required DateTime? dueDate,
  required String babyName,
  required String childId,
  required List<Color> gradientColors,
  required Color textColor,
}) {
  return PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black54,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return WeekTrackerExpandedPage(
        calc: calc,
        dueDate: dueDate,
        babyName: babyName,
        childId: childId,
        gradientColors: gradientColors,
        textColor: textColor,
      );
    },
  );
}
