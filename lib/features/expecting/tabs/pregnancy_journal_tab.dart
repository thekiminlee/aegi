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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregnancy Milestones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Week ${PregnancyCalc.fromDueDate(child.dueDate, DateTime.now()).currentWeek}',
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 18),
        Text('Recent Thoughts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        entriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load entries: $e'),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return const EmptyPanel(
                message: 'No journal entries yet. Tap + to add one.',
              );
            }
            return Column(
              children: entries
                  .map((entry) => JournalEntryCard(entry: entry))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
