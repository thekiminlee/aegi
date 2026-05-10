import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    this.onTap,
    this.backgroundColor,
    super.key,
  });

  final String label;
  final Widget value;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      height: 146,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tint),
          ),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          value,
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: content,
    );
  }
}

class PregnancyLogCard extends StatelessWidget {
  const PregnancyLogCard({required this.log, super.key});

  final PregnancyLog log;

  @override
  Widget build(BuildContext context) {
    final iconAndColor = switch (log.type) {
      PregnancyLogType.kickCounter => (
        Icons.gesture_outlined,
        const Color(0xFFB5C7ED),
      ),
      PregnancyLogType.waterIntake => (
        Icons.water_drop_outlined,
        const Color(0xFFA8DADC),
      ),
      PregnancyLogType.weight => (
        Icons.monitor_weight_outlined,
        const Color(0xFF90BE6D),
      ),
      PregnancyLogType.bloodPressure => (
        Icons.favorite_outline,
        const Color(0xFFF28482),
      ),
      PregnancyLogType.medication => (
        Icons.medication_outlined,
        const Color(0xFFF6BD60),
      ),
      PregnancyLogType.mood => (Icons.mood_outlined, const Color(0xFF84A59D)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconAndColor.$2.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconAndColor.$1, color: iconAndColor.$2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pregnancyLogTitle(log),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            DateFormat.jm().format(log.timestamp),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appColors.weakText),
          ),
        ],
      ),
    );
  }
}

class ContractionEntryCard extends StatelessWidget {
  const ContractionEntryCard({required this.entry, super.key});

  final ContractionEntry entry;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF28482).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.waves, color: Color(0xFFF28482)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              duration == null
                  ? 'In progress'
                  : 'Duration ${formatDuration(duration)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            DateFormat.jm().format(entry.startedAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appColors.weakText),
          ),
        ],
      ),
    );
  }
}

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({required this.entry, super.key});

  final JournalEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMd().format(entry.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.weakText,
                ),
              ),
            ],
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDEC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appColors.weakText),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    super.key,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appColors.weakText),
          ),
        ],
      ),
    );
  }
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Center(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontFamily: "Source Serif 4",
        color: Colors.grey[400]
      ))),
    );
  }
}
