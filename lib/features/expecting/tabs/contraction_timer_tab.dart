import 'dart:async';

import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/components/provider_call_helper.dart';
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
  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _contactPromptVisible = false;

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
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                "assets/img/disclaimer_banner.png",
                height: 300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'A commonly referenced guideline suggests noting when '
              'contractions occur about every 5 minutes, last around '
              '1 minute each, and continue for at least 1 hour.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "Source Serif 4",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is general information only and may not apply to '
              'every pregnancy. Always follow your healthcare '
              "provider's specific instructions for when to seek care.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "Source Serif 4",
              ),
            ),
            const SizedBox(height: 20),
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

        final sessionEntries = [...entries]
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final completedSessionEntries = sessionEntries
            .where((e) => e.endedAt != null)
            .toList();
        final olderEntries = historyEntries
            .where((e) => sessionEntries.isEmpty || e.sessionId != sessionEntries.first.sessionId)
            .toList();

        final showContactProviderBanner =
            completedSessionEntries.length >= 5 &&
            averageInterval(completedSessionEntries) < const Duration(minutes: 10);

        if (showContactProviderBanner && !_contactPromptVisible) {
          _contactPromptVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(analyticsServiceProvider).contactProviderPromptShown();
          });
        } else if (!showContactProviderBanner) {
          _contactPromptVisible = false;
        }

        return TabScaffold(
          children: [
            TabHeader(
              subheading: isActive ? 'IN PROGRESS' : 'READY',
              heading: 'Contraction',
              trailing: GestureDetector(
                onTap: () => _showInfoSheet(context),
                child: Text(
                  'INFO',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontFamily: "Inconsolata",
                    letterSpacing: 1.2,)
                ),
              ),
            ),
            const SizedBox(height: 16),

            ContractionActionButton(
              child: widget.child,
              openEntry: openEntry,
              duration: duration,
            ),

            if (showContactProviderBanner) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  ref.read(analyticsServiceProvider).contactProviderTapped();
                  callMedicalProvider(context, widget.child.medicalProviderPhone);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency, color: Colors.white),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "Your contractions appear to be getting closer together. Consider contacting your healthcare provider for guidance. ${widget.child.medicalProviderPhone == null ? "" : "Tap to call your medical provider"}",
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Source Serif 4',
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const ContractionDisclaimer(),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SessionStatTile(
                    label: 'AVG INTERVAL',
                    value: completedSessionEntries.length >= 2
                        ? formatDuration(averageInterval(completedSessionEntries))
                        : '--',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SessionStatTile(
                    label: 'AVG DURATION',
                    value: completedSessionEntries.isNotEmpty
                        ? formatDuration(averageDuration(completedSessionEntries))
                        : '--',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SectionHeader(
              label: 'Current Session',
              count: completedSessionEntries.length,
            ),
            const SizedBox(height: 8),
            if (sessionEntries.isEmpty)
              const EmptyPanel(message: 'No contractions in this session')
            else
              ContractionTable(entries: sessionEntries),

            if (olderEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionHeader(label: 'History', count: olderEntries.length),
              const SizedBox(height: 8),
              ContractionTable(entries: olderEntries, includeInterval: false,),
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
