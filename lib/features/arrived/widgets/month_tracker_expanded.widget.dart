import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class MonthTrackerExpandedPage extends StatefulWidget {
  const MonthTrackerExpandedPage({
    required this.birthDate,
    required this.babyName,
    required this.childId,
    required this.gradientColors,
    required this.textColor,
    super.key,
  });

  final DateTime birthDate;
  final String babyName;
  final String childId;
  final List<Color> gradientColors;
  final Color textColor;

  @override
  State<MonthTrackerExpandedPage> createState() =>
      _MonthTrackerExpandedPageState();
}

class _MonthTrackerExpandedPageState extends State<MonthTrackerExpandedPage>
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
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentAnimation.forward();
    });
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

    final now = DateTime.now();
    final months = _monthsBetween(widget.birthDate, now);
    final days = _remainderDays(widget.birthDate, now);

    final defaultContentStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontFamily: "Inconsolata",
              fontWeight: FontWeight.w500,
              color: widget.textColor,
            );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Hero(
          tag: 'month-tracker-${widget.childId}',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 0),
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _writeAnimation,
                              curve: Curves.easeIn,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.babyName,
                                  style: TextStyle(
                                    fontFamily: 'Playwright',
                                    fontSize: 42,
                                    letterSpacing: -0.5,
                                    color: widget.textColor,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Text(
                                  "born ${DateFormat.yMMMd().format(widget.birthDate)}",
                                  style: defaultContentStyle,
                                ),
                                if (months > 0)
                                  Text(
                                    "$months ${months == 1 ? 'month' : 'months'} and $days ${days == 1 ? 'day' : 'days'} old",
                                    style: defaultContentStyle,
                                  )
                                else
                                  Text(
                                    "$days ${days == 1 ? 'day' : 'days'} old",
                                    style: defaultContentStyle,
                                  ),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: widget.textColor,
                                        fontFamily: "Playwright",
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
    final monthAdjusted = DateTime(from.year + (from.month + months - 1) ~/ 12,
        (from.month + months - 1) % 12 + 1, from.day);
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
        MeshGradientPoint(
            position: jittered, color: colors[i % colors.length]),
      );
    }

    return points;
  }
}

Route createMonthTrackerExpandRoute({
  required DateTime birthDate,
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
      return MonthTrackerExpandedPage(
        birthDate: birthDate,
        babyName: babyName,
        childId: childId,
        gradientColors: gradientColors,
        textColor: textColor,
      );
    },
  );
}
