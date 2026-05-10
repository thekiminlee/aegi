import 'dart:async';

import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/widgets/contraction_action_button.widget.dart';
import 'package:aegi/features/expecting/widgets/contraction_disclaimer.widget.dart';
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

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The 5-1-1 Pattern',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: "Source Serif 4",
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                "assets/img/disclaimer_banner.png",
                height: 300,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A commonly referenced guideline suggests noting when '
              'contractions occur about every 5 minutes, last around '
              '1 minute each, and continue for at least 1 hour.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: "Source Serif 4",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is general information only and may not apply to '
              'every pregnancy. Always follow your healthcare '
              "provider's specific instructions for when to seek care.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: "Source Serif 4",
              ),
            ),
          ],
        ),
      ),
    );
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

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                isActive ? 'IN PROGRESS' : 'READY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'Contraction',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    fontFamily: "Source Serif 4",
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showInfoSheet(context),
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ContractionActionButton(
              child: widget.child,
              openEntry: openEntry,
              duration: duration,
            ),

            const SizedBox(height: 16),
            const ContractionDisclaimer(),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SessionStatTile(
                    label: 'AVG INTERVAL',
                    value: sessionEntries.length >= 2
                        ? formatDuration(averageInterval(sessionEntries))
                        : '--',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SessionStatTile(
                    label: 'AVG DURATION',
                    value: sessionEntries
                            .where((e) => e.endedAt != null)
                            .isNotEmpty
                        ? formatDuration(averageDuration(sessionEntries))
                        : '--',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _SectionHeader(
              label: 'Current Session',
              count: sessionEntries.where((e) => e.endedAt != null).length,
            ),
            const SizedBox(height: 8),
            if (sessionEntries.isEmpty)
              const EmptyPanel(message: 'No contractions logged yet.')
            else
              ContractionTable(entries: sessionEntries),

            if (olderEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: 'History', count: olderEntries.length),
              const SizedBox(height: 8),
              ContractionTable(entries: olderEntries),
            ],
          ],
        );
      },
    );
  }
}

class _SessionStatTile extends StatelessWidget {
  const _SessionStatTile({required this.label, required this.value});

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
          color: Colors.grey[700]
    ));
  }
}
