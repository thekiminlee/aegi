import 'dart:async';

import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/widgets/contraction_action_button.widget.dart';
import 'package:aegi/features/expecting/widgets/contraction_disclaimer.widget.dart';
import 'package:aegi/features/expecting/widgets/contraction_guidance_banner.widget.dart';
import 'package:aegi/features/expecting/widgets/contraction_table.widget.dart';
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
  static const _sessionWindowMinutes = 90;
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
    final historyEntriesAsync = ref.watch(
      expectingContractionHistoryEntriesProvider(widget.child.id),
    );
    final historyEntries = historyEntriesAsync.value ?? const [];

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load contractions: $e')),
      data: (entries) {
        final openEntries = entries.where((e) => e.endedAt == null).toList();
        final openEntry = openEntries.isEmpty ? null : openEntries.first;
        final isActive = openEntry != null;
        final duration = openEntry == null
            ? Duration.zero
            : _now.difference(openEntry.startedAt);

        final sessionCutoff = _now.subtract(
          const Duration(minutes: _sessionWindowMinutes),
        );
        final sessionEntries = historyEntries
            .where((e) => e.startedAt.isAfter(sessionCutoff))
            .toList();
        final olderEntries = historyEntries
            .where((e) => !e.startedAt.isAfter(sessionCutoff))
            .toList();

        final guidance = evaluateContractionGuidance(historyEntries, _now);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                isActive ? 'TIMING' : 'READY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Text(
              'Contraction',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll watch for the 5-1-1 pattern and tell you "
              "when it's time to head in.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appColors.weakText,
              ),
            ),
            const SizedBox(height: 20),

            ContractionActionButton(
              child: widget.child,
              openEntry: openEntry,
              duration: duration,
            ),

            const SizedBox(height: 16),
            const ContractionDisclaimer(),

            ContractionGuidanceBanner(guidance: guidance),

            const SizedBox(height: 24),
            _SectionHeader(
              label: 'CURRENT SESSION',
              count: sessionEntries.where((e) => e.endedAt != null).length,
            ),
            const SizedBox(height: 8),
            if (sessionEntries.isEmpty)
              const EmptyPanel(message: 'No contractions logged yet.')
            else
              ContractionTable(entries: sessionEntries),

            if (olderEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: 'HISTORY', count: olderEntries.length),
              const SizedBox(height: 8),
              ContractionTable(entries: olderEntries),
            ],
          ],
        );
      },
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
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        color: context.appColors.weakText,
      ),
    );
  }
}
