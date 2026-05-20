import 'dart:async';

import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:aegi/core/widgets/metric_tile.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/components/provider_call_helper.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/widgets/contraction_disclaimer.widget.dart';
import 'package:aegi/features/expecting/widgets/contraction_table.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

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
  int _kickCount = 0;
  DateTime? _kickStartedAt;
  bool _kickSessionSaved = false;
  bool _showKickCounterStats = false;
  bool _showContractionStats = false;
  _ContractionDetailMode _detailMode = _ContractionDetailMode.contraction;

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

  Future<void> _toggleContraction(ContractionEntry? openEntry) async {
    final repo = ref.read(contractionRepositoryProvider);
    setState((){
      _detailMode = _ContractionDetailMode.contraction;
      _showContractionStats = true;
    });
    if (openEntry == null) {
      ref.read(analyticsServiceProvider).contractionStarted();
      await repo.startContraction(widget.child.id);
      return;
    }
    ref.read(analyticsServiceProvider).contractionStopped();
    await repo.stopContraction(widget.child.id);
  }

  Future<void> _incrementKickCounter() async {
    if (_kickCount >= 10) return;

    final now = DateTime.now();
    setState(() {
      _detailMode = _ContractionDetailMode.kickCounter;
      _showKickCounterStats = true;
      _kickStartedAt ??= now;
      _kickSessionSaved = false;
      _kickCount += 1;
    });

    if (_kickCount < 10) return;

    if (_kickSessionSaved) return;

    final startedAt = _kickStartedAt ?? now;
    await ref
        .read(pregnancyRepositoryProvider)
        .addLog(
          PregnancyLog(
            id: const Uuid().v4(),
            childId: widget.child.id,
            type: PregnancyLogType.kickCounter,
            timestamp: now,
            metadata: {
              'kickTarget': 10,
              'kickCount': 10,
              'startedAtIso': startedAt.toIso8601String(),
              'endedAtIso': now.toIso8601String(),
              'durationSeconds': now.difference(startedAt).inSeconds,
            },
            createdAt: now,
          ),
        );
    if (!mounted) return;
    setState(() => _kickSessionSaved = true);
  }

  void _undoKickCounter() {
    if (_kickCount <= 0) return;
    setState(() {
      _detailMode = _ContractionDetailMode.kickCounter;
      _kickCount -= 1;
      _kickSessionSaved = false;
      if (_kickCount == 0) {
        _kickStartedAt = null;
      }
    });
  }

  void _stopKickCounter() {
    setState(() {
      _detailMode = _ContractionDetailMode.kickCounter;
      _kickCount = 0;
      _kickStartedAt = null;
      _kickSessionSaved = false;
    });
  }

  String _formatClock(Duration value) {
    final hours = value.inHours;
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
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
        final activeTimerStartedAt = openEntry?.startedAt ?? _kickStartedAt;
        final duration = activeTimerStartedAt == null
            ? Duration.zero
            : _now.difference(activeTimerStartedAt);
        final timerActive = activeTimerStartedAt != null;

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

        return TabPageScaffold(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _MinimalTimerCard(
                      elapsed: _formatClock(duration),
                      isActive: timerActive,
                      mode: isActive
                          ? 'contraction'
                          : _kickStartedAt != null
                          ? 'kick counter'
                          : null,
                    ),
                    AnimatedSize(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 220),
                      child: _showKickCounterStats
                      ? _KickCounterPanel(
                        key: const ValueKey('kick-panel'),
                        count: _kickCount,
                        onUndo: _undoKickCounter,
                        onStop: _stopKickCounter,
                        showActions: _kickStartedAt != null || _kickCount > 0,
                      )
                      : null,
                    ),
                    AnimatedSize(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 220),
                      child: _showContractionStats
                      ? _ContractionStatsPanel(
                        key: const ValueKey('contraction-panel'),
                        interval: completedSessionEntries.length >= 2
                            ? formatDuration(
                                averageInterval(completedSessionEntries),
                              )
                            : '--',
                        duration: completedSessionEntries.isNotEmpty
                            ? formatDuration(
                                averageDuration(completedSessionEntries),
                              )
                            : '--',
                      )
                      : null,
                    ),
                  ],
                )
              ),
          
              // if (showContactProviderBanner) ...[
              //   const SizedBox(height: 16),
              //   GestureDetector(
              //     onTap: () {
              //       ref.read(analyticsServiceProvider).contactProviderTapped();
              //       callMedicalProvider(context, widget.child.medicalProviderPhone);
              //     },
              //     child: Container(
              //       width: double.infinity,
              //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF3A3A3A),
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(Icons.emergency, color: Colors.white),
              //           const SizedBox(width: 20),
              //           Expanded(
              //             child: Text(
              //               "Your contractions appear to be getting closer together. Consider contacting your healthcare provider for guidance. ${widget.child.medicalProviderPhone == null ? "" : "Tap to call your medical provider"}",
              //               softWrap: true,
              //               style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w400,
              //                 fontFamily: 'Source Serif 4',
              //                 height: 1.5,
              //                 fontSize: 13,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ],
          
              // const ContractionDisclaimer(),
          
              // const SizedBox(height: 8),
              // if (sessionEntries.isEmpty)
              //   const EmptyPanel(message: 'No contractions in this session')
              // else
              //   ContractionTable(entries: sessionEntries),
          
              // if (olderEntries.isNotEmpty) ...[
              //   const SizedBox(height: 24),
              //   SectionHeader(label: 'History', count: olderEntries.length),
              //   const SizedBox(height: 8),
              //   ContractionTable(entries: olderEntries, includeInterval: false,),
              // ],
          
              MetricTileRow(
                tiles: [
                  TileData(
                    icon: Symbols.footprint,
                    iconColor: const Color(0xFF84A59D),
                    label: 'kick',
                    value: '$_kickCount/10',
                    trailing: '',
                    subtitle: _kickCount == 0 ? 'tap to count' : 'session',
                    tab: EntryTab.journal,
                    onTap: _incrementKickCounter,
                  ),
                  TileData(
                    icon: isActive ? Symbols.stop_circle : Symbols.timer,
                    iconColor: const Color(0xFFF28482),
                    label: 'contraction',
                    value: isActive ? 'stop' : 'start',
                    trailing: '',
                    subtitle: isActive ? _formatClock(duration) : 'timer',
                    tab: EntryTab.journal,
                    onTap: () => _toggleContraction(openEntry),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _ContractionDetailMode { contraction, kickCounter }

class _MinimalTimerCard extends StatelessWidget {
  const _MinimalTimerCard({
    required this.elapsed,
    required this.isActive,
    required this.mode,
  });

  final String elapsed;
  final bool isActive;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            elapsed,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.appColors.black,
              fontFamily: 'Inconsolata',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? '${mode ?? 'session'} in progress'
                : 'tap tile below to start',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _KickCounterPanel extends StatelessWidget {
  const _KickCounterPanel({
    required this.count,
    required this.onUndo,
    required this.onStop,
    required this.showActions,
    super.key,
  });

  final int count;
  final VoidCallback onUndo;
  final VoidCallback onStop;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(10, (index) {
              final filled = index < count;
              return AnimatedScale(
                duration: Duration(milliseconds: 160 + (index * 25)),
                scale: filled ? 1 : 0.92,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? context.appColors.accent
                        : Colors.grey[300],
                  ),
                ),
              );
            }),
          ),
          if (showActions) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: count > 0 ? onUndo : null,
                    child: const Text('Undo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onStop,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF84A59D),
                    ),
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContractionStatsPanel extends StatelessWidget {
  const _ContractionStatsPanel({
    required this.interval,
    required this.duration,
    super.key,
  });

  final String interval;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SessionStatTile(
          label: 'AVG INTERVAL',
          value: interval,
        ),
        _SessionStatTile(
          label: 'AVG DURATION',
          value: duration,
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.appColors.black
            ),
          ),
        ],
      ),
    );
  }
}
