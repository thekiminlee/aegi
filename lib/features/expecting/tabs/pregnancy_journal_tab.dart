import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PregnancyJournalTab extends ConsumerWidget {
  const PregnancyJournalTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(expectingJournalEntriesProvider(child.id));
    final calc = PregnancyCalc.fromDueDate(child.dueDate, DateTime.now());

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load entries: $e')),
      data: (entries) {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final thisWeekEntries = entries.where((e) =>
            e.timestamp.isAfter(weekStart) ||
            (e.timestamp.year == weekStart.year &&
                e.timestamp.month == weekStart.month &&
                e.timestamp.day == weekStart.day)).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'WEEK ${calc.currentWeek}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Text(
              'Journal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
                fontFamily: "Source Serif 4",
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

            // --- Milestones ---
            _SectionHeader(
              label: 'Milestones',
              count: 2,
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  child: MilestoneTile(
                    icon: Icons.favorite_border,
                    title: 'First Kick',
                    subtitle: 'Track movement',
                    tint: Color(0xFFA8DADC),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MilestoneTile(
                    icon: Icons.auto_awesome,
                    title: 'Weekly Growth',
                    subtitle: 'Week update',
                    tint: Color(0xFFB5C7ED),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Recent entries ---
            _SectionHeader(
              label: 'Recent Entries',
              count: entries.length,
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const EmptyPanel(
                message: 'No journal entries yet. Tap + to add one.',
              )
            else
              Column(
                children: entries
                    .map((entry) => JournalEntryCard(entry: entry))
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label  ·  $count',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        fontFamily: "Source Serif 4",
        color: Colors.grey[700],
      ),
    );
  }
}
