import 'package:aegi/core/enums/units.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final tiles = [
      _TileData(
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFFA8DADC),
        label: 'Water',
        value: summary.totalWaterMlToday.toStringAsFixed(0),
        unit: volumeUnit.name.toUpperCase(),
        timestamp: null,
        tab: EntryTab.water,
      ),
      _TileData(
        icon: Icons.monitor_weight_outlined,
        iconColor: const Color(0xFF90BE6D),
        label: 'Weight',
        value: summary.latestWeightKg != null
            ? summary.latestWeightKg!.toStringAsFixed(1)
            : '--',
        unit: summary.latestWeightKg != null
            ? weightUnit.name.toUpperCase()
            : '',
        timestamp: summary.latestWeightTimestamp,
        tab: EntryTab.weight,
      ),
      _TileData(
        icon: Icons.favorite_outline,
        iconColor: const Color(0xFFF28482),
        label: 'Blood Pressure',
        value: summary.latestSystolic != null && summary.latestDiastolic != null
            ? '${summary.latestSystolic} / ${summary.latestDiastolic}'
            : '--',
        unit: summary.latestSystolic != null ? 'MMHG' : '',
        timestamp: summary.latestBloodPressureTimestamp,
        tab: EntryTab.bp,
      ),
      _TileData(
        icon: Icons.medication_outlined,
        iconColor: const Color(0xFFF6BD60),
        label: summary.latestMedicationName ?? 'Medication',
        value: summary.latestMedicationName != null ? 'MEDICATION' : '--',
        unit: '',
        timestamp: summary.latestMedicationTimestamp,
        tab: EntryTab.med,
      ),
      _TileData(
        icon: Icons.mood_outlined,
        iconColor: const Color(0xFF84A59D),
        label: 'Mood',
        value: summary.latestMood != null
            ? moodLabel(summary.latestMood).toUpperCase()
            : '--',
        unit: '',
        timestamp: summary.latestMoodTimestamp,
        tab: EntryTab.mood,
      ),
    ];

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tiles.map(
            (tile) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: onTileTap != null ? () => onTileTap!(tile.tab) : null,
                child: _LogRow(data: tile),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileData {
  const _TileData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.tab,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final DateTime? timestamp;
  final EntryTab tab;
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final hasValue = data.value != '--' && data.value != '0';
    final displayValue = hasValue ? data.value : '--';
    final displayUnit = data.unit.isNotEmpty ? ' ${data.unit}' : '';
    final timeText = data.timestamp != null
        // ? DateFormat.jm().format(data.timestamp!)
        ? DateFormat('MMM d, h:mm a').format(data.timestamp!)
        : null;

    return Row(
      children: [
        // Container(
        //   width: 10,
        //   height: 10,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: hasValue ? const Color(0xFFFFB07C) : Colors.transparent,
        //     border: Border.all(
        //       color: hasValue ? const Color(0xFFFFB07C) : const Color.fromARGB(255, 228, 228, 228),
        //       width: 1.5,
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(data.icon, color: data.iconColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: const Color.fromARGB(255, 35, 35, 35),
                          fontFamily: "Inconsolata",
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            displayValue,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Inconsolata",
                                ),
                          ),
                          if (displayUnit.isNotEmpty)
                            Text(
                              displayUnit,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Inconsolata",
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (timeText != null)
                  Text(
                    timeText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inconsolata",
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
