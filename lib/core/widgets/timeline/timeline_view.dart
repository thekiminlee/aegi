import 'package:aegi/core/widgets/timeline/timeline_date_selector.dart';
import 'package:aegi/core/widgets/timeline/timeline_entry.dart';
import 'package:aegi/core/widgets/timeline/timeline_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineView<T> extends StatefulWidget {
  const TimelineView({
    required this.entries,
    required this.filterCategories,
    required this.cardBuilder,
    this.title = 'Log',
    this.backgroundColor,
    super.key,
  });

  final List<TimelineEntry<T>> entries;
  final List<TimelineFilterCategory> filterCategories;
  final Widget Function(BuildContext, TimelineEntry<T>) cardBuilder;
  final String title;
  final Color? backgroundColor;

  @override
  State<TimelineView<T>> createState() => _TimelineViewState<T>();
}

class _TimelineViewState<T> extends State<TimelineView<T>> {
  late DateTime _selectedDate;
  late String _selectedFilterKey;
  final ScrollController _scrollController = ScrollController();
  int _displayCount = 20;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedFilterKey = widget.filterCategories.isNotEmpty
        ? widget.filterCategories.first.key
        : '';
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final filtered = _filteredEntries;
      if (_displayCount < filtered.length) {
        setState(() => _displayCount += 20);
      }
    }
  }

  List<DateTime> get _past7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  List<TimelineEntry<T>> get _filteredEntries {
    final byDate = widget.entries.where((e) =>
        e.timestamp.year == _selectedDate.year &&
        e.timestamp.month == _selectedDate.month &&
        e.timestamp.day == _selectedDate.day);

    final selectedCat = widget.filterCategories
        .where((c) => c.key == _selectedFilterKey)
        .firstOrNull;

    final byFilter = (selectedCat == null || selectedCat.matchesAll)
        ? byDate
        : byDate.where((e) => e.category == _selectedFilterKey);

    final list = byFilter.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int get _weekEntryCount {
    final dates = _past7Days;
    final start = dates.first;
    final endDate = dates.last.add(const Duration(days: 1));
    return widget.entries
        .where((e) =>
            !e.timestamp.isBefore(start) && e.timestamp.isBefore(endDate))
        .length;
  }

  Map<DateTime, int> get _entryCounts {
    final counts = <DateTime, int>{};
    for (final entry in widget.entries) {
      final key = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
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
    final bgColor =
        widget.backgroundColor ?? const Color(0xFFFAF9F7);
    final filtered = _filteredEntries;
    final visible =
        filtered.length > _displayCount ? filtered.sublist(0, _displayCount) : filtered;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_weekEntryCount ENTRIES PAST 7 DAYS',
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Source Serif 4',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Date selector
            TimelineDateSelector(
              dates: _past7Days,
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() {
                _selectedDate = date;
                _displayCount = 20;
              }),
              entryCounts: _entryCounts,
            ),
            const SizedBox(height: 12),

            // Filter chips
            TimelineFilterChips(
              categories: widget.filterCategories,
              selectedKey: _selectedFilterKey,
              onSelected: (key) => setState(() {
                _selectedFilterKey = key;
                _displayCount = 20;
              }),
            ),
            const SizedBox(height: 16),

            // Day section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    '${DateFormat('MMM d').format(_selectedDate).toUpperCase()} · ${filtered.length} ${filtered.length == 1 ? 'ENTRY' : 'ENTRIES'}',
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Entry list
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
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
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        return widget.cardBuilder(context, visible[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
