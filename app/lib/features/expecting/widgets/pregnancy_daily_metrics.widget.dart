import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:aegi/core/widgets/metric_tile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class PregnancyDailyMetrics extends StatelessWidget {
  const PregnancyDailyMetrics({
    required this.summary,
    required this.volumeUnit,
    required this.weightUnit,
    required this.childId,
    this.onTileTap,
    this.activeTab,
    super.key,
  });

  final TodaySummary summary;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;
  final String childId;
  final void Function(EntryTab tab)? onTileTap;
  final EntryTab? activeTab;

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
            trailing: volumeUnit.name.toLowerCase(),
            subtitle: "Today",
            tab: EntryTab.water,
            isSelected: activeTab == EntryTab.water,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.water) : null,
          ),
          TileData(
            icon: Symbols.weight,
            iconColor: const Color(0xFF90BE6D),
            label: 'weight',
            value: summary.latestWeightKg != null
                ? summary.latestWeightKg!.toStringAsFixed(1)
                : '--',
            trailing: summary.latestWeightKg != null
                ? weightUnit.name.toLowerCase()
                : '',
            subtitle: summary.latestWeightTimestamp != null ? DateFormat.MMMd().format(summary.latestWeightTimestamp!) : null,
            tab: EntryTab.weight,
            isSelected: activeTab == EntryTab.weight,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.weight) : null,
          ),
          TileData(
            icon: Symbols.gesture,
            iconColor: const Color(0xFF84A59D),
            label: 'mood',
            value: summary.latestMood != null
                ? moodLabel(summary.latestMood).toLowerCase()
                : '--',
            trailing: '',
            subtitle: summary.latestMoodTimestamp != null ? DateFormat.MMMd().format(summary.latestMoodTimestamp!) : null,
            tab: EntryTab.mood,
            isSelected: activeTab == EntryTab.mood,
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
            trailing: summary.latestSystolic != null ? 'mmhg' : '',
            subtitle: summary.latestBloodPressureTimestamp != null ? DateFormat("MMM d hh:mm a").format(summary.latestBloodPressureTimestamp!) : null,
            tab: EntryTab.bp,
            isSelected: activeTab == EntryTab.bp,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.bp) : null,
            includeTime: true
          ),
          TileData(
            icon: Symbols.pill,
            iconColor: const Color(0xFFF6BD60),
            label: 'med',
            value: summary.latestMedicationName ?? '--',
            trailing: '',
            subtitle: summary.latestMedicationTimestamp != null ? DateFormat("MMM d hh:mm a").format(summary.latestMedicationTimestamp!) : null,
            tab: EntryTab.med,
            isSelected: activeTab == EntryTab.med,
            onTap: onTileTap != null ? () => onTileTap!(EntryTab.med) : null,
            includeTime: true
          ),
        ])
      ],
    );
  }
}
