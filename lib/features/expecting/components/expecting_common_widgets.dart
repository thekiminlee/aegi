import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  const JournalEntryCard({required this.entry, this.dueDate, super.key});

  final JournalEntryModel entry;
  final DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    final weekLabel = dueDate != null
        ? 'WK ${PregnancyCalc.fromDueDate(dueDate, entry.timestamp).currentWeek}'
        : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, _) =>
              _ExpandedJournalEntry(entry: entry, weekLabel: weekLabel),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF28482),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat.MMMd().format(entry.timestamp).toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[500],
                    fontFamily: "Inconsolata"
                  ),
                ),
                if (weekLabel != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '· $weekLabel',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[400],
                      fontFamily: "Inconsolata",
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey[500], size: 12)
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "Source Serif 4",
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800]
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
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
      ),
    );
  }
}

class _ExpandedJournalEntry extends StatelessWidget {
  const _ExpandedJournalEntry({required this.entry, this.weekLabel});

  final JournalEntryModel entry;
  final String? weekLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Symbols.stylus, color: Colors.grey[500], fontWeight: FontWeight.w600,)
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Symbols.ink_eraser, color: Colors.grey[500], fontWeight: FontWeight.w600)
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                "${weekLabel ?? ''}\n"
                "${DateFormat.yMMMd().format(entry.timestamp)}\n"
                "${DateFormat("HH:mm a").format(entry.timestamp)}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontFamily: "Inconsolata",
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: "Source Serif 4",
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
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
              ),
            ),
            Center(child: Text('aegi', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: "Playwright",
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]
            ),))
          ],
        ),
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
        fontFamily: "Inconsolata",
        color: Colors.grey[400]
      ))),
    );
  }
}
