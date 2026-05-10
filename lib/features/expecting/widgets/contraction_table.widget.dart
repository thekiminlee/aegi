import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractionTable extends StatelessWidget {
  const ContractionTable({required this.entries, super.key});

  final List<ContractionEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          ContractionRow(entry: entries[i]),
          if (i < entries.length - 1 && entries[i + 1].endedAt != null)
            ContractionIntervalRow(
              interval:
                  entries[i].startedAt.difference(entries[i + 1].endedAt!),
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          formatDuration(interval),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
            fontFamily: "Saira"
          ),
        ),
      ),
    );
  }
}

class ContractionRow extends StatelessWidget {
  const ContractionRow({required this.entry, super.key});

  final ContractionEntry entry;

  @override
  Widget build(BuildContext context) {
    final duration = entry.duration;
    final timeStr = DateFormat('MMM d, h:mm a').format(entry.startedAt);
    final durationStr = duration == null ? '--:--' : formatDuration(duration);
    final intensityStr = _intensityLabel(entry.intensity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              timeStr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
                fontFamily: 'Inconsolata',
              ),
            ),
          ),
          if (intensityStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                intensityStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.weakText,
                  letterSpacing: 0.5,
                  fontFamily: 'Inconsolata',
                ),
              ),
            ),
          if (duration == null)
            Text(
              'IN PROGRESS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFF28482),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontFamily: 'Inconsolata',
              ),
            )
          else
            Text(
              durationStr,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'Inconsolata',
              ),
            ),
        ],
      ),
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
