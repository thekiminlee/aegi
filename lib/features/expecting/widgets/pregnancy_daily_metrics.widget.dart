import 'package:aegi/core/enums/units.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Water Intake',
                value: Text(
                  '${mlToUnit(summary.totalWaterMlToday, volumeUnit).toStringAsFixed(1)} ${volumeUnit.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: 'today total',
                icon: Icons.water_drop_outlined,
                tint: const Color(0xFFA8DADC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Weight',
                value: summary.latestWeightKg == null
                    ? Text('--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400]))
                    : Text(
                        '${kgToUnit(summary.latestWeightKg!, weightUnit).toStringAsFixed(1)} ${weightUnit.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                subtitle: summary.latestWeightTimestamp == null ? '' : 'at ${formatDate(summary.latestWeightTimestamp)}',
                icon: Icons.monitor_weight_outlined,
                tint: const Color.fromARGB(255, 109, 190, 162),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Blood Pressure',
                value: summary.latestSystolic != null && summary.latestDiastolic != null
                    ? Text(
                        '${summary.latestSystolic}/${summary.latestDiastolic}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    : Text('--/--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400])),
                subtitle: summary.latestBloodPressureTimestamp == null ? '' : formatDateTime(summary.latestBloodPressureTimestamp),
                icon: Icons.favorite_outline,
                tint: const Color(0xFFF28482),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Medication',
                value: summary.latestMedicationName != null
                    ? Text(summary.latestMedicationName!, style: Theme.of(context).textTheme.titleLarge)
                    : Text('--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400])),
                subtitle: summary.latestMedicationTimestamp == null ? '' : formatDateTime(summary.latestMedicationTimestamp),
                icon: Icons.medication_outlined,
                tint: const Color(0xFFF6BD60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricTile(
          label: 'Mood / Mental Health',
          value: summary.latestMood != null
              ? Text(
                  moodLabel(summary.latestMood),
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : Text('--', style: Theme.of(context).textTheme.titleLarge),
          subtitle: formatDateTime(summary.latestMoodTimestamp),
          icon: Icons.mood_outlined,
          tint: const Color(0xFF84A59D),
        ),
      ],
    );
  }
}
