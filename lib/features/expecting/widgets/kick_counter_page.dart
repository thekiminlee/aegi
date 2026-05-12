import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class KickCounterPage extends ConsumerStatefulWidget {
  const KickCounterPage({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<KickCounterPage> createState() => _KickCounterPageState();
}

class _KickCounterPageState extends ConsumerState<KickCounterPage> {
  bool _isActive = false;
  DateTime? _startedAt;
  int _count = 0;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isActive = true;
      _startedAt = DateTime.now();
      _count = 0;
    });
    _elapsed = Duration.zero;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _stopSession() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _elapsed = Duration.zero;
    setState(() {
      _isActive = false;
      _startedAt = null;
      _count = 0;
    });
  }

  Future<void> _increment() async {
    if (!_isActive || _count >= 10) return;
    final next = _count + 1;
    setState(() => _count = next);

    if (next >= 10) {
      final now = DateTime.now();
      final startedAt = _startedAt ?? now;
      await ref
          .read(pregnancyRepositoryProvider)
          .addLog(
            PregnancyLog(
              id: const Uuid().v4(),
              childId: widget.childId,
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
      _elapsedTimer?.cancel();
      _elapsedTimer = null;
      _elapsed = Duration.zero;
      setState(() {
        _isActive = false;
        _startedAt = null;
        _count = 0;
      });
    }
  }

  void _decrement() {
    if (!_isActive || _count <= 0) return;
    setState(() => _count = _count - 1);
  }

  String _formatElapsed() {
    final h = _elapsed.inHours;
    final mm = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(expectingPregnancyLogsProvider(widget.childId));
    final recentSessions = logsAsync.maybeWhen(
      data: (logs) => logs
          .where((l) => l.type == PregnancyLogType.kickCounter)
          .take(5)
          .toList(),
      orElse: () => <PregnancyLog>[],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 24),
                  _buildSessionArea(context),
                  const SizedBox(height: 32),
                  if (recentSessions.isNotEmpty) ...[
                    SectionHeader(
                      label: 'Recent Sessions',
                      count: recentSessions.length,
                    ),
                    const SizedBox(height: 10),
                    ...recentSessions.map((log) => _buildSessionRow(context, log)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SESSION #${_sessionNumber()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Inconsolata',
                      letterSpacing: 1,
                      color: Colors.grey[400],
                    ),
              ),
              Text(
                'Kick Counter',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Source Serif 4",
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _sessionNumber() {
    final logsAsync = ref.read(expectingPregnancyLogsProvider(widget.childId));
    final count = logsAsync.maybeWhen(
      data: (logs) =>
          logs.where((l) => l.type == PregnancyLogType.kickCounter).length,
      orElse: () => 0,
    );
    return '${count + 1}';
  }

  Widget _buildSessionArea(BuildContext context) {
    if (!_isActive) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Session Complete',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                  fontFamily: 'Inconsolata'
                ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start new session',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: "Inconsolata"),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          'FELT',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: 'Inconsolata',
                letterSpacing: 1.2,
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_count',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 80,
                color: Colors.grey[800],
              ),
        ),
        Text(
          'of 10  ·  ${_formatElapsed()} elapsed',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
        ),
        const SizedBox(height: 16),
        _buildCountIndicators(),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _increment,
            // icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'I felt a kick',
              // style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: "Inconsolata"),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _decrement,
                icon: Icon(Icons.remove, size: 18, color: Colors.grey[600]),
                label: Text(
                  'Undo',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontFamily: "Inconsolata"),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _stopSession,
                icon: Icon(Icons.stop_rounded, size: 18, color: Colors.grey[600]),
                label: Text(
                  'End session',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontFamily: "Inconsolata"),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: List.generate(10, (index) {
          final filled = index < _count;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 6,
              margin: EdgeInsets.only(right: index < 9 ? 5 : 0),
              decoration: BoxDecoration(
                color: filled ? context.appColors.accent : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSessionRow(BuildContext context, PregnancyLog log) {
    final duration = (log.metadata['durationSeconds'] as num?)?.toInt();
    final addMinute = duration != null && duration ~/ 60 > 0;
    final durationText = duration != null ? '${addMinute ? '${duration ~/ 60}m' : ''} ${duration % 60}s' : '--';

    final now = DateTime.now();
    final logDate = log.timestamp;
    String dateLabel;
    String timeLabel = DateFormat("h:mm a").format(logDate);
    if (logDate.year == now.year &&
        logDate.month == now.month &&
        logDate.day == now.day) {
      dateLabel = 'Today';
    } else if (logDate.year == now.year &&
        logDate.month == now.month &&
        logDate.day == now.day - 1) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat.MMMd().format(logDate);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontFamily: "Saira"
                        ),
                  ),
                  Text(
                    timeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Inconsolata',
                        ),
                  ),
                ],
              ),
            ),
            Text(
              durationText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Inconsolata',
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
