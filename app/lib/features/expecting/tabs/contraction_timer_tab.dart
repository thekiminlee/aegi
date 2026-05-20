import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:aegi/core/widgets/metric_tile.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
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
import 'package:intl/intl.dart';
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
  bool _showKickSessions = false;
  bool _showContractionSessions = false;
  int _kickCount = 0;
  DateTime? _kickStartedAt;
  bool _kickSessionSaved = false;

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
    setState(() => _showContractionSessions = true);
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
      _showKickSessions = true;
      _kickStartedAt ??= now;
      _kickSessionSaved = false;
      _kickCount += 1;
    });

    if (_kickCount < 10 || _kickSessionSaved) return;

    final startedAt = _kickStartedAt ?? now;
    await ref.read(pregnancyRepositoryProvider).addLog(
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
    setState(() {
      _kickSessionSaved = true;
      _kickCount = 0;
      _kickStartedAt = null;
    });
  }

  void _undoKickCounter() {
    if (_kickCount <= 0) return;
    setState(() {
      _kickCount -= 1;
      _kickSessionSaved = false;
      if (_kickCount == 0) {
        _kickStartedAt = null;
      }
    });
  }

  void _stopKickCounter() {
    setState(() {
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
                fontFamily: 'Source Serif 4',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/img/disclaimer_banner.png',
                height: 300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'A commonly referenced guideline suggests noting when contractions occur about every 5 minutes, last around 1 minute each, and continue for at least 1 hour.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Source Serif 4',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "This is general information only and may not apply to every pregnancy. Always follow your healthcare provider's specific instructions for when to seek care.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Source Serif 4',
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
    final logsAsync = ref.watch(expectingPregnancyLogsProvider(widget.child.id));

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load contractions: $e')),
      data: (entries) {
        final historyEntries = historyEntriesAsync.value ?? const <ContractionEntry>[];
        final openEntry = entries.cast<ContractionEntry?>().firstWhere(
          (e) => e?.endedAt == null,
          orElse: () => null,
        );
        final sessionEntries = [...entries]
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final completedSessionEntries = sessionEntries
            .where((e) => e.endedAt != null)
            .toList();
        final olderEntries = historyEntries
            .where(
              (e) =>
                  sessionEntries.isEmpty || e.sessionId != sessionEntries.first.sessionId,
            )
            .toList();
        final recentKickSessions = logsAsync.maybeWhen(
          data: (logs) => logs
              .where((log) => log.type == PregnancyLogType.kickCounter)
              .take(8)
              .toList(),
          orElse: () => <PregnancyLog>[],
        );

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
                child: _ExpandableSectionsLayout(
                  showContractionSessions: _showContractionSessions,
                  showKickSessions: _showKickSessions,
                  contractionSection: _ExpandableSessionSection(
                    title: 'Contraction',
                    expanded: _showContractionSessions,
                    active: openEntry != null,
                    onTap: () => setState(
                      () => _showContractionSessions = !_showContractionSessions,
                    ),
                    child: _ContractionSessionList(
                      currentEntries: sessionEntries,
                      historyEntries: olderEntries,
                    ),
                  ),
                  kickSection: _ExpandableSessionSection(
                    title: 'Kick Counter',
                    expanded: _showKickSessions,
                    active: _kickStartedAt != null,
                    onTap: () => setState(
                      () => _showKickSessions = !_showKickSessions,
                    ),
                    child: _KickSessionList(
                      kickStartedAt: _kickStartedAt,
                      kickCount: _kickCount,
                      activeDurationLabel: _kickStartedAt != null
                          ? _formatClock(_now.difference(_kickStartedAt!))
                          : null,
                      undoKickCounter: _undoKickCounter,
                      stopKickCounter: _stopKickCounter,
                    ),
                  ),
                ),
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
                            "Your contractions appear to be getting closer together. Consider contacting your healthcare provider for guidance. ${widget.child.medicalProviderPhone == null ? '' : 'Tap to call your medical provider'}",
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
              const SizedBox(height: 24),
              MetricTileRow(
                tiles: [
                  TileData(
                    icon: Symbols.eraser_size_4,
                    iconColor: const Color(0xFF84A59D),
                    label: 'kick',
                    value: '$_kickCount/10',
                    trailing: '',
                    subtitle: _kickStartedAt != null
                        ? _formatClock(_now.difference(_kickStartedAt!))
                        : 'tap to count',
                    tab: EntryTab.journal,
                    onTap: _incrementKickCounter,
                  ),
                  TileData(
                    icon: openEntry != null ? Symbols.check_box_outline_blank_rounded : Symbols.radio_button_unchecked,
                    iconColor: const Color(0xFFF28482),
                    label: 'contraction',
                    value: openEntry != null ? 'stop' : 'start',
                    trailing: '',
                    subtitle: openEntry != null
                        ? _formatClock(_now.difference(openEntry.startedAt))
                        : 'timer',
                    tab: EntryTab.journal,
                    onTap: () => _toggleContraction(openEntry),
                  ),
                ],
              ),
              // if (_kickStartedAt != null || _kickCount > 0) ...[
              //   const SizedBox(height: 12),
              //   Row(
              //     children: [
              //       Expanded(
              //         child: OutlinedButton(
              //           onPressed: _kickCount > 0 ? _undoKickCounter : null,
              //           child: const Text('Undo'),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: FilledButton(
              //           onPressed: _stopKickCounter,
              //           style: FilledButton.styleFrom(
              //             backgroundColor: const Color(0xFF84A59D),
              //           ),
              //           child: const Text('Stop'),
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        );
      },
    );
  }
}

class _ExpandableSectionsLayout extends StatelessWidget {
  const _ExpandableSectionsLayout({
    required this.showContractionSessions,
    required this.showKickSessions,
    required this.contractionSection,
    required this.kickSection,
  });

  final bool showContractionSessions;
  final bool showKickSessions;
  final Widget contractionSection;
  final Widget kickSection;

  static const _headerEstimate = 32.0;
  static const _sectionGap = 12.0;
  static const _bodyGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final openCount =
            (showContractionSessions ? 1 : 0) + (showKickSessions ? 1 : 0);
        final availableBodyHeight =
            constraints.maxHeight -
            (_headerEstimate * 2) -
            _sectionGap -
            (_bodyGap * openCount);
        final bodyHeightPerSection =
            openCount == 0 ? 0.0 : (availableBodyHeight > 0 ? availableBodyHeight / openCount : 0.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionBodyHeightScope(
              bodyHeight: showContractionSessions ? bodyHeightPerSection : 0,
              child: contractionSection,
            ),
            const SizedBox(height: _sectionGap),
            _SectionBodyHeightScope(
              bodyHeight: showKickSessions ? bodyHeightPerSection : 0,
              child: kickSection,
            ),
          ],
        );
      },
    );
  }
}

class _SectionBodyHeightScope extends InheritedWidget {
  const _SectionBodyHeightScope({
    required this.bodyHeight,
    required super.child,
  });

  final double bodyHeight;

  static double of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SectionBodyHeightScope>();
    return scope?.bodyHeight ?? 0;
  }

  @override
  bool updateShouldNotify(_SectionBodyHeightScope oldWidget) =>
      bodyHeight != oldWidget.bodyHeight;
}

class _ExpandableSessionSection extends StatelessWidget {
  const _ExpandableSessionSection({
    required this.title,
    required this.expanded,
    required this.active,
    required this.onTap,
    required this.child,
  });

  final String title;
  final bool expanded;
  final bool active;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bodyHeight = _SectionBodyHeightScope.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: context.appColors.black,
                    ),
                  ),
                  if (active) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF28482),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: Icon(
                  Symbols.arrow_downward,
                  size: 20,
                  color: context.appColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: expanded ? bodyHeight : 0),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Column(
                children: [
                  SizedBox(height: value > 0 ? 12 : 0),
                  ClipRect(
                    child: SizedBox(
                      height: value,
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ContractionSessionList extends StatelessWidget {
  const _ContractionSessionList({
    required this.currentEntries,
    required this.historyEntries,
  });

  final List<ContractionEntry> currentEntries;
  final List<ContractionEntry> historyEntries;

  @override
  Widget build(BuildContext context) {
    if (currentEntries.isEmpty && historyEntries.isEmpty) {
      return const EmptyPanel(message: 'No contraction sessions yet');
    }

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentEntries.isNotEmpty) ...[
              ContractionTable(entries: currentEntries),
            ],
            // if (historyEntries.isNotEmpty) ...[
            //   if (currentEntries.isNotEmpty) const SizedBox(height: 16),
            //   SectionHeader(label: 'History', count: historyEntries.length),
            //   const SizedBox(height: 8),
            //   ContractionTable(
            //     entries: historyEntries,
            //     includeInterval: false,
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}

class _KickSessionList extends StatelessWidget {
  const _KickSessionList({
    required this.undoKickCounter,
    required this.stopKickCounter,
    this.kickStartedAt,
    this.kickCount = 0,
    this.activeDurationLabel,
  });

  final DateTime? kickStartedAt;
  final int kickCount;
  final String? activeDurationLabel;
  final VoidCallback undoKickCounter;
  final VoidCallback stopKickCounter;

  @override
  Widget build(BuildContext context) {
    if (kickStartedAt == null && kickCount == 0) {
      return const EmptyPanel(message: 'Tap on the kick counter tile to start a session');
    }

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kickStartedAt != null || kickCount > 0) ...[
              _ActiveKickSessionCard(
                count: kickCount,
                durationLabel: activeDurationLabel ?? '--:--',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.appColors.black,
                          width: 1,
                        ),
                      ),
                      onPressed: kickCount > 0 ? undoKickCounter : null,
                      child: Text(
                        'Undo',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.appColors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: stopKickCounter,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.appColors.accent,
                      ),
                      child: const Text('Stop'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveKickSessionCard extends StatelessWidget {
  const _ActiveKickSessionCard({
    required this.count,
    required this.durationLabel,
  });

  final int count;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          durationLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(10, (index) {
            final filled = index < count;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: 12,
                height: 12,
                margin: EdgeInsets.only(right: index < 9 ? 5 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? context.appColors.accent : Colors.grey[300],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
