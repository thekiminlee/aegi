import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget contractionRowItem(
  BuildContext context,
  String label,
  String value,
  Widget? subTrailing,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
      subTrailing ??
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: context.appColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
    ],
  );
}

class ContractionTable extends StatelessWidget {
  const ContractionTable({required this.entries, this.includeInterval = true, super.key});

  final List<ContractionEntry> entries;
  final bool includeInterval;

  @override
  Widget build(BuildContext context) {
    final completedEntries = entries.where((e) => e.endedAt != null).toList();

    return Column(
      children: [
        if (includeInterval && completedEntries.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              // color: context.appColors.cardBackground,
              // borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.accent)
            ),
            child: Column(
              children: [
                contractionRowItem(
                  context,
                  "Avg Duration",
                  formatDuration(averageDuration(completedEntries)),
                  null,
                ),
                if (completedEntries.length >= 2) ...[
                  const SizedBox(height: 2),
                  contractionRowItem(
                    context,
                    "Avg Interval",
                    formatDuration(averageInterval(completedEntries)),
                    null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        for (var i = 0; i < entries.length; i++) ...[
          ContractionRow(entry: entries[i], interval: includeInterval && i < entries.length - 1 && entries[i + 1].endedAt != null
              ? entries[i].startedAt.difference(entries[i + 1].endedAt!)
              : null,
          ),
          // if (includeInterval && i < entries.length - 1 && entries[i + 1].endedAt != null)
          //   ContractionIntervalRow(
          //     interval:
          //         entries[i].startedAt.difference(entries[i + 1].endedAt!),
          //   ),
          // if (!includeInterval)
          //   const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class ContractionIntervalRow extends StatelessWidget {
  const ContractionIntervalRow({required this.interval, super.key});

  final Duration interval;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(interval),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[400],
      ),
    );
  }
}

class ContractionRow extends StatelessWidget {
  const ContractionRow({required this.entry, this.interval, super.key});

  final ContractionEntry entry;
  final Duration? interval;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    final timeStr = DateFormat('MMM d, h:mm a').format(entry.startedAt);
    final durationStr = duration == null ? '--:--' : formatDuration(duration);
    final intensityStr = _intensityLabel(entry.intensity);

    Widget? subTrailing;
    if (duration == null) {
      subTrailing = Text(
            'IN PROGRESS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFF28482),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: 14
            ),
          );
    }

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: intensityStr.isEmpty ? context.appColors.weakText : const Color(0xFFF28482),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            // decoration: BoxDecoration(
            //   border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: context.appColors.weakText,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                contractionRowItem(context, "Duration", durationStr, subTrailing),
                if (interval != null)
                contractionRowItem(context, "Interval", formatDuration(interval!), null)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _intensityLabel(int? intensity) {
  if (intensity == null) return '';
  return switch (intensity) {
    1 => 'MILD',
    2 => 'MODERATE',
    3 => 'STRONG',
    _ => '',
  };
}
