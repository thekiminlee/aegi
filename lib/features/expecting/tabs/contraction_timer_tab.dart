import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContractionTimerTab extends ConsumerStatefulWidget {
  const ContractionTimerTab({required this.child, super.key});

  final ChildProfile child;

  @override
  ConsumerState<ContractionTimerTab> createState() =>
      _ContractionTimerTabState();
}

class _ContractionTimerTabState extends ConsumerState<ContractionTimerTab> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(
      expectingContractionEntriesProvider(widget.child.id),
    );
    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load contractions: $e')),
      data: (entries) {
        final openEntries = entries.where((e) => e.endedAt == null).toList();
        final openEntry = openEntries.isEmpty ? null : openEntries.first;
        final duration = openEntry == null
            ? Duration.zero
            : _now.difference(openEntry.startedAt);
        final completed = entries.where((e) => e.endedAt != null).toList();
        final avgDuration = completed.isEmpty
            ? Duration.zero
            : Duration(
                seconds:
                    completed
                        .map((e) => e.duration!.inSeconds)
                        .reduce((a, b) => a + b) ~/
                    completed.length,
              );
        final avgInterval = averageInterval(completed);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: GestureDetector(
                  onTap: () async {
                    final repo = ref.read(contractionRepositoryProvider);
                    if (openEntry == null) {
                      await repo.startContraction(widget.child.id);
                    } else {
                      await repo.stopContraction(widget.child.id);
                    }
                  },
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE7E6EA),
                        width: 6,
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DURATION',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDuration(duration),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          openEntry == null ? 'Tap to Start' : 'Tap to Stop',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.appColors.weakText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Frequency',
                    value: formatDuration(avgInterval),
                    subtitle: 'avg interval',
                    icon: Icons.sync_alt,
                    tint: const Color(0xFFF28482),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Duration',
                    value: formatDuration(avgDuration),
                    subtitle: 'avg contraction',
                    icon: Icons.av_timer,
                    tint: const Color(0xFFF6BD60),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'This tool is for tracking only and does not replace medical advice. Contact your provider if unsure.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appColors.weakText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recent History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const EmptyPanel(message: 'No contractions in this session yet.')
            else
              ...entries.map((entry) => ContractionEntryCard(entry: entry)),
          ],
        );
      },
    );
  }
}
