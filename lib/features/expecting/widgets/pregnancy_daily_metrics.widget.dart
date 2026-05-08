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
        showDateOnly: true
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
        isMedication: true,
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
              Text("TODAY · ${DateFormat.yMMMd().format(DateTime.now())}", style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey[400],
                fontFamily: "Inconsolata",
                letterSpacing: 1.2
              )),
              Icon(Icons.calendar_today_rounded, color: Colors.grey[400], size: 20),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "Your day so far...",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.grey[800],
              fontFamily: "Saira"
            ),
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }
}

class _TileData {
  const _TileData({
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.isMedication = false,
    this.showDateOnly = false,
  });

  final String label;
  final String value;
  final String unit;
  final DateTime? timestamp;
  final bool isMedication;
  final bool showDateOnly;
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
        ? data.showDateOnly ? DateFormat.MMMd().format(data.timestamp!)
        : DateFormat.jm().format(data.timestamp!)
        : null;
    final valueFontSize = data.isMedication ? 20.0 : 32.0;
    final unitFontSize = data.isMedication ? 10.0 : 20.0;
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
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
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
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              stops: [0.85, 1.0],
              colors: [Colors.white, Colors.transparent],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    displayValue,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: valueFontSize,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                ),
                Text(
                  displayUnit,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: unitFontSize,
                        color: Colors.grey[400],
                      ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
