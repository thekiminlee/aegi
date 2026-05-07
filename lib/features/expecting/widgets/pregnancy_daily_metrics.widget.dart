import 'package:aegi/core/enums/units.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';

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
    final weakText = Colors.grey[600]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metric(
            context,
            icon: Icons.water_drop_outlined,
            tint: const Color(0xFFA8DADC),
            value: mlToUnit(summary.totalWaterMlToday, volumeUnit).toStringAsFixed(0),
            unit: volumeUnit.name,
            weakText: weakText,
          ),
          _metric(
            context,
            icon: Icons.monitor_weight_outlined,
            tint: const Color.fromARGB(255, 109, 190, 162),
            value: summary.latestWeightKg != null
                ? kgToUnit(summary.latestWeightKg!, weightUnit).toStringAsFixed(1)
                : '--',
            unit: summary.latestWeightKg != null ? weightUnit.name : '',
            weakText: weakText,
          ),
          _metric(
            context,
            icon: Icons.favorite_outline,
            tint: const Color(0xFFF28482),
            value: summary.latestSystolic != null && summary.latestDiastolic != null
                ? '${summary.latestSystolic}/${summary.latestDiastolic}'
                : '--',
            unit: '',
            weakText: weakText,
          ),
          _metric(
            context,
            icon: Icons.medication_outlined,
            tint: const Color(0xFFF6BD60),
            value: summary.latestMedicationName ?? '--',
            unit: '',
            weakText: weakText,
          ),
          _metric(
            context,
            icon: Icons.mood_outlined,
            tint: const Color(0xFF84A59D),
            value: moodLabel(summary.latestMood),
            unit: '',
            weakText: weakText,
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required String value,
    required String unit,
    required Color weakText,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            unit.isNotEmpty ? unit : ' ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: weakText,
                ),
          ),
        ],
      ),
    );
  }
}
