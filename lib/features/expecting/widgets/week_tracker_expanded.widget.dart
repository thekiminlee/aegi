import 'dart:math' as math;

import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
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
    required this.growthLabel,
    super.key,
  });

  final PregnancyCalc calc;
  final DateTime? dueDate;
  final String babyName;
  final String childId;
  final List<Color> gradientColors;
  final Color textColor;
  final String growthLabel;

  @override
  State<WeekTrackerExpandedPage> createState() =>
      _WeekTrackerExpandedPageState();
}

class _WeekTrackerExpandedPageState extends State<WeekTrackerExpandedPage>
    with TickerProviderStateMixin {
  late AnimationController _contentAnimation;
  late AnimationController _writeAnimation;

  @override
  void initState() {
    super.initState();
    _contentAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _writeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // Delay content fade-in until Hero animation settles
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentAnimation.forward();
    });
    // Start writing animation after content fades in
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _writeAnimation.forward();
    });
  }

  @override
  void dispose() {
    _contentAnimation.dispose();
    _writeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentFade = CurvedAnimation(
      parent: _contentAnimation,
      curve: Curves.easeOut,
    );

    final defaultContentStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      fontFamily: "Inconsolata",
                                      fontWeight: FontWeight.w500,
                                      color: widget.textColor
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
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 0),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _writeAnimation,
                              curve: Curves.easeIn,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.babyName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Playwright',
                                    fontSize: 50,
                                    letterSpacing: -0.5,
                                    color: widget.textColor,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                if (widget.dueDate != null) ...[
                                  Text(
                                    "due ${DateFormat.yMMMd().format(widget.dueDate!)}",
                                    style: defaultContentStyle,
                                  ),
                                ],
                                Text(
                                    "week ${widget.calc.currentWeek}",
                                    style: defaultContentStyle,
                                  ),
                                Text(
                                  widget.growthLabel.toLowerCase(),
                                  style: defaultContentStyle
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'aegi',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: widget.textColor,
                                    fontFamily: "Playwright",
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
  required String growthLabel,
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
        growthLabel: growthLabel
      );
    },
  );
}
