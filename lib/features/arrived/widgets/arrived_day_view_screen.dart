import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/widgets/timeline/timeline_date_selector.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/arrived/components/arrived_helpers.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class ArrivedDayViewScreen extends ConsumerStatefulWidget {
  const ArrivedDayViewScreen({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<ArrivedDayViewScreen> createState() =>
      _ArrivedDayViewScreenState();
}

class _ArrivedDayViewScreenState extends ConsumerState<ArrivedDayViewScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  List<DateTime> get _past7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  List<BabyLog> _logsForDate(List<BabyLog> logs, DateTime date) {
    return logs
        .where((l) =>
            l.timestamp.year == date.year &&
            l.timestamp.month == date.month &&
            l.timestamp.day == date.day)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Map<DateTime, int> _entryCounts(List<BabyLog> logs) {
    final counts = <DateTime, int>{};
    for (final log in logs) {
      final key =
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  int _weekEntryCount(List<BabyLog> logs) {
    final dates = _past7Days;
    final start = dates.first;
    final end = dates.last.add(const Duration(days: 1));
    return logs
        .where((l) => !l.timestamp.isBefore(start) && l.timestamp.isBefore(end))
        .length;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(arrivedBabyLogsProvider(widget.childId));

    final allLogs = logsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => <BabyLog>[],
    );

    final dayLogs = _logsForDate(allLogs, _selectedDate);
    final summary = _DaySummary.fromLogs(dayLogs);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabHeader(
                subheading:
                    '${_weekEntryCount(allLogs)} ENTRIES PAST 7 DAYS',
                heading: 'Activity Log',
              ),
            ),
            const SizedBox(height: 8),

            // Date selector
            TimelineDateSelector(
              dates: _past7Days,
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
              entryCounts: _entryCounts(allLogs),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // --- Summary tiles ---
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'Feed',
                          icon: Symbols.pediatrics_rounded,
                          tint: const Color(0xFFA8DADC),
                          primary: summary.totalFeedMl > 0
                              ? '${summary.totalFeedMl.toStringAsFixed(0)} ml'
                              : '--',
                          secondary: summary.breastFeedCount > 0
                              ? '${summary.breastFeedCount}x breast'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Diapers',
                          icon: Icons.water_drop_outlined,
                          tint: const Color(0xFF90BE6D),
                          primary: '${summary.wetCount + summary.dirtyCount}',
                          secondary:
                              '${summary.wetCount} wet · ${summary.dirtyCount} dirty',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Sleep',
                          icon: Icons.bedtime_outlined,
                          tint: const Color(0xFF84A59D),
                          primary: summary.totalSleepMin > 0
                              ? _formatMinutes(summary.totalSleepMin)
                              : '--',
                          secondary: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Day label ---
                  Text(
                    _dayLabel(_selectedDate),
                    style: const TextStyle(
                      fontFamily: 'Source Serif 4',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(_selectedDate).toUpperCase()} · ${dayLogs.length} ${dayLogs.length == 1 ? 'ENTRY' : 'ENTRIES'}',
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Timeline ---
                  if (dayLogs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No entries for this day',
                          style: TextStyle(
                            fontFamily: 'Source Serif 4',
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  else
                    ...dayLogs.map((log) => _TimelineRow(
                          log: log,
                          onTap: () => showEditBabyLogSheet(context, ref, log),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day summary data
// ---------------------------------------------------------------------------

class _DaySummary {
  const _DaySummary({
    required this.totalFeedMl,
    required this.bottleFeedCount,
    required this.breastFeedCount,
    required this.wetCount,
    required this.dirtyCount,
    required this.totalSleepMin,
  });

  final double totalFeedMl;
  final int bottleFeedCount;
  final int breastFeedCount;
  final int wetCount;
  final int dirtyCount;
  final int totalSleepMin;

  factory _DaySummary.fromLogs(List<BabyLog> logs) {
    double feedMl = 0;
    int bottleCount = 0;
    int breastCount = 0;
    int wet = 0;
    int dirty = 0;
    int sleepMin = 0;

    for (final log in logs) {
      switch (log.type) {
        case BabyLogType.bottleFeed:
          bottleCount++;
          final ml = (log.metadata['amountMl'] as num?)?.toDouble() ?? 0;
          feedMl += ml;
        case BabyLogType.breastMilk:
          breastCount++;
        case BabyLogType.diaperWet:
          wet++;
        case BabyLogType.diaperDirty:
          dirty++;
        case BabyLogType.nap:
        case BabyLogType.nightSleep:
          final dur = (log.metadata['durationMin'] as num?)?.toInt() ?? 0;
          sleepMin += dur;
      }
    }

    return _DaySummary(
      totalFeedMl: feedMl,
      bottleFeedCount: bottleCount,
      breastFeedCount: breastCount,
      wetCount: wet,
      dirtyCount: dirty,
      totalSleepMin: sleepMin,
    );
  }
}

// ---------------------------------------------------------------------------
// Summary tile
// ---------------------------------------------------------------------------

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.primary,
    this.secondary,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inconsolata',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            primary,
            style: const TextStyle(
              fontFamily: 'Saira',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
          Text(
            secondary ?? "",
            style: TextStyle(
              fontFamily: 'Saira',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline row: time on left, activity detail on right
// ---------------------------------------------------------------------------

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.log, this.onTap});

  final BabyLog log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = babyLogIconAndColor(log.type);
    final labels = babyLogTitle(log);
    final timeText = DateFormat('h:mm a').format(log.timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: 64,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              // Dot + line connector
              Padding(
                padding: const EdgeInsets.only(top: 18, right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity detail card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labels[0],
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              labels[1],
                              style: const TextStyle(
                                fontFamily: 'Saira',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF232323),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}
