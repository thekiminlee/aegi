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
        label: 'Water',
        value: mlToUnit(summary.totalWaterMlToday, volumeUnit)
            .toStringAsFixed(0),
        unit: volumeUnit.name,
        timestamp: null,
      ),
      _TileData(
        label: 'Weight',
        value: summary.latestWeightKg != null
            ? kgToUnit(summary.latestWeightKg!, weightUnit).toStringAsFixed(1)
            : '--',
        unit: summary.latestWeightKg != null ? weightUnit.name : '',
        timestamp: summary.latestWeightTimestamp,
      ),
      _TileData(
        label: 'Blood Pressure',
        value: summary.latestSystolic != null && summary.latestDiastolic != null
            ? '${summary.latestSystolic}/${summary.latestDiastolic}'
            : '--',
        unit: '',
        timestamp: summary.latestBloodPressureTimestamp,
      ),
      _TileData(
        label: 'Medication',
        value: summary.latestMedicationName ?? '--',
        unit: '',
        timestamp: summary.latestMedicationTimestamp,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < tiles.length ? 12 : 0),
            child: Row(
              children: [
                Expanded(child: _LogTile(data: tiles[i])),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < tiles.length
                      ? _LogTile(data: tiles[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TileData {
  const _TileData({
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  final String label;
  final String value;
  final String unit;
  final DateTime? timestamp;
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.data});

  final _TileData data;

  @override
  Widget build(BuildContext context) {
    final hasValue = data.value != '--' && data.value != '0';
    final displayValue = hasValue
        ? data.value
        : '--';
    final displayUnit = data.unit.isNotEmpty ? ' ${data.unit}' : '';
    final timeText = data.timestamp != null
        ? DateFormat.jm().format(data.timestamp!)
        : null;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 35, 35, 35),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (timeText != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 226, 255, 227),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                  child: Text(
                    timeText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Text(
                displayValue,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 32
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                displayUnit,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.grey[400]
                    ),
                maxLines: 1
              ),
            ],
          ),
        ],
      ),
    );
  }
}
