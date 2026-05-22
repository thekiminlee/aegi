import 'dart:math' as math;

import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/widgets/tracker_expanded.widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

// --- Tracker data variants ---------------------------------------------------

sealed class TrackerData {
  const TrackerData();
}

class WeekTrackerData extends TrackerData {
  const WeekTrackerData({
    required this.calc,
    required this.growthLabel,
    required this.growthMessage,
    required this.dueDate,
    required this.growthHeight,
    required this.growthWeight,
  });

  final PregnancyCalc calc;
  final String growthLabel;
  final String growthMessage;
  final DateTime? dueDate;
  final double? growthHeight;
  final int? growthWeight;
}

class MonthTrackerData extends TrackerData {
  const MonthTrackerData({required this.birthDate});

  final DateTime birthDate;

  int monthsAge(DateTime now) {
    int m = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) m--;
    return math.max(0, m);
  }

  int remainderDays(DateTime now) {
    final m = monthsAge(now);
    final adj = DateTime(
      birthDate.year + (birthDate.month + m - 1) ~/ 12,
      (birthDate.month + m - 1) % 12 + 1,
      birthDate.day,
    );
    return now.difference(adj).inDays;
  }
}

// --- TrackerCard -------------------------------------------------------------

class TrackerCard extends StatelessWidget {
  const TrackerCard({
    super.key,
    required this.data,
    required this.gradientColors,
    required this.textColor,
    required this.babyName,
    required this.childId,
    this.heroTag,
  });

  final TrackerData data;
  final List<Color> gradientColors;
  final Color textColor;
  final String babyName;
  final String childId;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final tag = heroTag ?? 'tracker-$childId';
        Navigator.of(context).push(
          createTrackerExpandRoute(
            data: data,
            babyName: babyName,
            childId: childId,
            gradientColors: gradientColors,
            textColor: textColor,
            heroTag: tag,
          ),
        );
      },
      child: Hero(
        tag: heroTag ?? 'tracker-$childId',
        child: ClipRRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: MeshGradient(
                  points: buildTrackerMeshPoints(gradientColors),
                  options: MeshGradientOptions(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContent(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    switch (data) {
      case final WeekTrackerData week:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Symbols.progress_activity, size: 16, fontWeight: FontWeight.w600, color: textColor.withAlpha(200)),
              const SizedBox(width: 6),
              Text(
                'Week ${week.calc.currentWeek}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor.withAlpha(200),
                ),
              ),
            ],
          ),
          if (week.dueDate != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Symbols.process_chart, size: 16, fontWeight: FontWeight.w600, color: textColor.withAlpha(200)),
                const SizedBox(width: 6),
                Text(
                  DateFormat("MMM d, yyyy").format(week.dueDate!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textColor.withAlpha(200),
                  ),
                ),
              ],
            ),
        ];
      case final MonthTrackerData month:
        final now = DateTime.now();
        final months = month.monthsAge(now);
        final days = month.remainderDays(now);
        final ageLabel = months > 0
            ? '$months mo, $days ${days == 1 ? 'day' : 'days'}'
            : '$days ${days == 1 ? 'day' : 'days'}';
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Symbols.progress_activity, size: 16, fontWeight: FontWeight.w600, color: textColor.withAlpha(200)),
              const SizedBox(width: 6),
              Text(
                ageLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor.withAlpha(200),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Symbols.process_chart, size: 16, fontWeight: FontWeight.w600, color: textColor.withAlpha(200)),
              const SizedBox(width: 6),
              Text(
                DateFormat("MMM d, yyyy").format(month.birthDate),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor.withAlpha(200),
                ),
              ),
            ],
          ),
        ];
    }
  }
}

// --- Shared mesh gradient helper ---------------------------------------------

List<MeshGradientPoint> buildTrackerMeshPoints(List<Color> colors) {
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
