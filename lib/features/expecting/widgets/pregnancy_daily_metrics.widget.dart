import 'package:aegi/core/enums/units.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PregnancyDailyMetrics extends StatelessWidget {
  const PregnancyDailyMetrics({
    required this.summary,
    required this.volumeUnit,
    required this.weightUnit,
    super.key,
  });

  final TodaySummary summary;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _TileData(
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFFA8DADC),
        label: 'Water',
        value: mlToUnit(summary.totalWaterMlToday, volumeUnit)
            .toStringAsFixed(0),
        unit: volumeUnit.name.toUpperCase(),
        timestamp: null,
      ),
      _TileData(
        icon: Icons.monitor_weight_outlined,
        iconColor: const Color(0xFF90BE6D),
        label: 'Weight',
        value: summary.latestWeightKg != null
            ? kgToUnit(summary.latestWeightKg!, weightUnit).toStringAsFixed(1)
            : '--',
        unit: summary.latestWeightKg != null
            ? weightUnit.name.toUpperCase()
            : '',
        timestamp: summary.latestWeightTimestamp,
      ),
      _TileData(
        icon: Icons.favorite_outline,
        iconColor: const Color(0xFFF28482),
        label: 'Blood pressure',
        value: summary.latestSystolic != null && summary.latestDiastolic != null
            ? '${summary.latestSystolic} / ${summary.latestDiastolic}'
            : '--',
        unit: summary.latestSystolic != null ? 'MMHG' : '',
        timestamp: summary.latestBloodPressureTimestamp,
      ),
      _TileData(
        icon: Icons.medication_outlined,
        iconColor: const Color(0xFFF6BD60),
        label: summary.latestMedicationName ?? 'Medication',
        value: summary.latestMedicationName != null ? 'TAKEN' : '--',
        unit: '',
        timestamp: summary.latestMedicationTimestamp,
      ),
      _TileData(
        icon: Icons.mood_outlined,
        iconColor: const Color(0xFF84A59D),
        label: 'Mood',
        value: summary.latestMood != null
            ? '${moodLabel(summary.latestMood).toUpperCase()}'
            : '--',
        unit: '',
        timestamp: summary.latestMoodTimestamp,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontFamily: "Inconsolata",
                      letterSpacing: 1.2,
                    ),
              ),
              Icon(Icons.calendar_view_month_outlined, color: Colors.grey[300], size: 24)
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "How are you today?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  fontFamily: "Saira",
                ),
          ),
          const SizedBox(height: 16),
          ...tiles.map((tile) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LogRow(data: tile),
              )),
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
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final DateTime? timestamp;
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final hasValue = data.value != '--' && data.value != '0';
    final displayValue = hasValue ? data.value : '--';
    final displayUnit =
        data.unit.isNotEmpty ? ' ${data.unit}' : '';
    final timeText = data.timestamp != null
        ? DateFormat.jm().format(data.timestamp!)
        : null;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasValue ? const Color(0xFFFFB07C) : Colors.transparent,
            border: Border.all(
              color: hasValue ? const Color(0xFFFFB07C) : const Color.fromARGB(255, 228, 228, 228),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
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
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 35, 35, 35),
                              fontFamily: "Saira"
                            ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            displayValue,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Saira"
                                    ),
                          ),
                          if (displayUnit.isNotEmpty)
                            Text(
                              displayUnit,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Saira"
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
