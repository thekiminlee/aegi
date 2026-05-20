import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class TabHeader extends StatelessWidget {
  const TabHeader({
    required this.subheading,
    required this.heading,
    this.extendedHeader,
    this.trailing,
    super.key,
  });

  final String subheading;
  final String heading;
  final Widget? trailing;
  final RichText? extendedHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subheading,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey[400],
                    fontFamily: "Inconsolata",
                    letterSpacing: 1.2,
                  ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 4),
        Text(
          heading,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontFamily: "Source Serif 4",
              ),
        ),
        if (extendedHeader != null) ...[
          const SizedBox(height: 6),
          extendedHeader!,
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.label, this.count, super.key});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label${count == null ? "" :  "  ·  $count"}',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        fontFamily: "Source Serif 4",
        color: Colors.grey[800],
      ),
    );
  }
}

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
  const PregnancyLogCard({
    required this.log,
    this.volumeUnit = VolumeUnit.ml,
    this.weightUnit = WeightUnit.kg,
    super.key,
  });

  final PregnancyLog log;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;

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
              pregnancyLogTitle(log, volumeUnit: volumeUnit, weightUnit: weightUnit),
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
  const JournalEntryCard({required this.entry, this.dueDate, this.birthDate, super.key});

  final JournalEntryModel entry;
  final DateTime? dueDate;
  final DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    final weekLabel = birthDate != null && entry.timestamp.isAfter(birthDate!)
        ? babyAgeAtDate(birthDate!, entry.timestamp)
        : dueDate != null
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
          color: context.appColors.cardBackground,
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

class _ExpandedJournalEntry extends ConsumerWidget {
  const _ExpandedJournalEntry({required this.entry, this.weekLabel});

  final JournalEntryModel entry;
  final String? weekLabel;

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    final bodyController = TextEditingController(text: entry.body);
    final tagsController = TextEditingController(text: entry.tags.join(', '));

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'EDIT JOURNAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Leave a memory...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontFamily: "Source Serif 4",
                    ),
                    fillColor: Colors.transparent,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Source Serif 4",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Tags (comma separated)',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                      fontFamily: "Inconsolata",
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: "Inconsolata",
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true && context.mounted) {
      final newBody = bodyController.text.trim();
      final newTags = tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await ref.read(journalRepositoryProvider).updateEntry(
            JournalEntryModel(
              id: entry.id,
              childId: entry.childId,
              timestamp: entry.timestamp,
              body: newBody,
              tags: newTags,
              createdAt: entry.createdAt,
              updatedAt: DateTime.now(),
            ),
          );

      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Journal'),
        content: const Text(
          'This journal entry will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(journalRepositoryProvider).deleteEntry(entry.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        onTap: () => _handleEdit(context, ref),
                        child: Icon(Symbols.stylus, color: Colors.grey[500], fontWeight: FontWeight.w600,)
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _handleDelete(context, ref),
                        child: Icon(Symbols.ink_eraser, color: Colors.grey[500], fontWeight: FontWeight.w600)
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
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
      child: Center(child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.grey[400]
        ))),
    );
  }
}
