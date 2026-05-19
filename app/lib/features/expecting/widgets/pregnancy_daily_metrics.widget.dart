import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:aegi/core/widgets/metric_tile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PregnancyDailyMetrics extends StatelessWidget {
  const PregnancyDailyMetrics({
    required this.summary,
    required this.volumeUnit,
    required this.weightUnit,
    required this.childId,
    this.onTileTap,
    super.key,
  });

  final TodaySummary summary;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;
  final String childId;
  final void Function(EntryTab tab)? onTileTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(),
        MetricTileRow(tiles: [
          TileData(
            icon: Symbols.water,
            iconColor: const Color(0xFFA8DADC),
            label: 'water',
            value: summary.totalWaterMlToday.toStringAsFixed(0),
            unit: volumeUnit.name.toUpperCase(),
            timestamp: null,
            tab: EntryTab.water,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.water) : null,
          ),
          TileData(
            icon: Symbols.weight,
            iconColor: const Color(0xFF90BE6D),
            label: 'weight',
            value: summary.latestWeightKg != null
                ? summary.latestWeightKg!.toStringAsFixed(1)
                : '--',
            unit: summary.latestWeightKg != null
                ? weightUnit.name.toLowerCase()
                : '',
            timestamp: summary.latestWeightTimestamp,
            tab: EntryTab.weight,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.weight) : null,
          ),
          TileData(
            icon: Symbols.gesture,
            iconColor: const Color(0xFF84A59D),
            label: 'mood',
            value: summary.latestMood != null
                ? moodLabel(summary.latestMood).toLowerCase()
                : '--',
            unit: '',
            timestamp: summary.latestMoodTimestamp,
            tab: EntryTab.mood,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.mood) : null,
          ),
        ]),
        SizedBox(height: 3),
        MetricTileRow(tiles: [
          TileData(
            icon: Symbols.favorite,
            iconColor: const Color(0xFFF28482),
            label: 'bp',
            value: summary.latestSystolic != null && summary.latestDiastolic != null
                ? '${summary.latestSystolic} / ${summary.latestDiastolic}'
                : '--',
            unit: summary.latestSystolic != null ? 'mmhg' : '',
            timestamp: summary.latestBloodPressureTimestamp,
            tab: EntryTab.bp,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.bp) : null,
            includeTime: true
          ),
          TileData(
            icon: Symbols.pill,
            iconColor: const Color(0xFFF6BD60),
            label: 'med',
            value: summary.latestMedicationName ?? '--',
            unit: '',
            timestamp: summary.latestMedicationTimestamp,
            tab: EntryTab.med,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.med) : null,
            includeTime: true
          ),
        ])
      ],
    );
  }
}
