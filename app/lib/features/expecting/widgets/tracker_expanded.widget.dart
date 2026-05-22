import 'package:aegi/features/expecting/widgets/tracker_card.widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class TrackerExpandedPage extends StatefulWidget {
  const TrackerExpandedPage({
    required this.data,
    required this.babyName,
    required this.childId,
    required this.gradientColors,
    required this.textColor,
    required this.heroTag,
    super.key,
  });

  final TrackerData data;
  final String babyName;
  final String childId;
  final List<Color> gradientColors;
  final Color textColor;
  final String heroTag;

  @override
  State<TrackerExpandedPage> createState() => _TrackerExpandedPageState();
}

class _TrackerExpandedPageState extends State<TrackerExpandedPage>
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

    final defaultContentStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      // fontFamily: "Instrument Serif",
      color: widget.textColor,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Hero(
          tag: widget.heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MeshGradient(
                  points: buildTrackerMeshPoints(widget.gradientColors),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.babyName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Playwright',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 42,
                                    color: widget.textColor,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ..._buildDetailLines(context, defaultContentStyle),
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

  List<Widget> _buildDetailLines(BuildContext context, TextStyle? style) {
    switch (widget.data) {
      case final WeekTrackerData week:
        return [
          SizedBox(height: 12,),
          if (week.dueDate != null)
            Text(
              "due ${DateFormat.yMMMd().format(week.dueDate!)}",
              style: style,
            ),
          Text(
            "week ${week.calc.currentWeek}",
            style: style,
          ),
          Text(
            week.growthLabel.toLowerCase(),
            style: style,
          ),
        ];
      case final MonthTrackerData month:
        final now = DateTime.now();
        final months = month.monthsAge(now);
        final days = month.remainderDays(now);
        return [
          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat.yMMMd().format(month.birthDate),
                style: style,
              ),
            ],
          ),
          if (months > 0)
            Text(
              "$months mo, $days ${days == 1 ? 'day' : 'days'}",
              style: style,
            )
          else
            Text(
              "$days ${days == 1 ? 'day' : 'days'}",
              style: style,
            ),
        ];
    }
  }
}

Route createTrackerExpandRoute({
  required TrackerData data,
  required String babyName,
  required String childId,
  required List<Color> gradientColors,
  required Color textColor,
  required String heroTag,
}) {
  return PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black54,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return TrackerExpandedPage(
        data: data,
        babyName: babyName,
        childId: childId,
        gradientColors: gradientColors,
        textColor: textColor,
        heroTag: heroTag,
      );
    },
  );
}
