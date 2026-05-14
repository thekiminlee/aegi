import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalTab extends ConsumerWidget {
  const JournalTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(expectingJournalEntriesProvider(child.id));
    final now = DateTime.now();
    final isArrived = child.birthDate != null;

    final subheadingPrefix = isArrived
        ? babyAgeLabel(child.birthDate!, now)
        : 'WEEK ${PregnancyCalc.fromDueDate(child.dueDate, now).currentWeek}';

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load entries: $e')),
      data: (entries) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final thisWeekEntries = entries.where((e) =>
            e.timestamp.isAfter(weekStart) ||
            (e.timestamp.year == weekStart.year &&
                e.timestamp.month == weekStart.month &&
                e.timestamp.day == weekStart.day)).toList();

        return TabScaffold(
          children: [
            TabHeader(
              subheading: '$subheadingPrefix · ${entries.length} JOURNAL${entries.length > 1 ? 'S' : ''}',
              heading: 'Journal',
              trailing: GestureDetector(
                onTap: () => isArrived
                    ? showJournalEntrySheet(context, ref, child)
                    : showUnifiedEntrySheet(context, ref, child, initialTab: EntryTab.journal),
                child: Text("ADD", style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontFamily: "Inconsolata",
                      letterSpacing: 1.2,)),
              ),
            ),
            const SizedBox(height: 20),

            // --- Stats row ---
            Row(
              children: [
                Expanded(
                  child: _JournalStatTile(
                    label: 'TOTAL ENTRIES',
                    value: '${entries.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _JournalStatTile(
                    label: 'THIS WEEK',
                    value: '${thisWeekEntries.length}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Recent entries ---
            SectionHeader(
              label: 'Recent Memories',
              count: entries.length,
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const EmptyPanel(
                message: 'No journal entries yet.\nTap `ADD` to leave a memory.',
              )
            else
              Column(
                children: entries
                    .map((entry) => JournalEntryCard(
                          entry: entry,
                          dueDate: child.dueDate,
                          birthDate: child.birthDate,
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

class _JournalStatTile extends StatelessWidget {
  const _JournalStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: Colors.grey[400],
              fontFamily: 'Inconsolata',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFamily: 'Inconsolata',
            ),
          ),
        ],
      ),
    );
  }
}

