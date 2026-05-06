import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class KickCounterCard extends ConsumerStatefulWidget {
  const KickCounterCard({
    required this.childId,
    required this.latestKickDurationSeconds,
    super.key,
  });

  final String childId;
  final int? latestKickDurationSeconds;

  @override
  ConsumerState<KickCounterCard> createState() => _KickCounterCardState();
}

class _KickCounterCardState extends ConsumerState<KickCounterCard> {
  bool _isKickSessionActive = false;
  DateTime? _kickSessionStartAt;
  int _kickSessionCount = 0;

  Future<void> _handleKickTap() async {
    if (!_isKickSessionActive) {
      setState(() {
        _isKickSessionActive = true;
        _kickSessionStartAt = DateTime.now();
        _kickSessionCount = 1;
      });
      return;
    }

    final nextCount = _kickSessionCount + 1;
    if (nextCount < 10) {
      setState(() => _kickSessionCount = nextCount);
      return;
    }

    final now = DateTime.now();
    final startedAt = _kickSessionStartAt ?? now;
    final duration = now.difference(startedAt);

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
              'durationSeconds': duration.inSeconds,
            },
            createdAt: now,
          ),
        );

    if (!mounted) return;
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  void _cancelKickSession() {
    if (!_isKickSessionActive) return;
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleKickTap,
      onDoubleTap: _cancelKickSession,
      child: MetricTile(
        label: 'Kick Counter',
        value: _isKickSessionActive
            ? Text('$_kickSessionCount/10', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))
            : Text('Tap to start kick counter', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
        subtitle: _isKickSessionActive
            ? 'tap until 10 (double tap to cancel)'
            : (widget.latestKickDurationSeconds == null
                  ? ''
                  : 'at ${formatDuration(Duration(seconds: widget.latestKickDurationSeconds!))}'),
        icon: Icons.gesture_outlined,
        tint: const Color.fromARGB(255, 73, 195, 51),
        backgroundColor: _isKickSessionActive
            ? const Color.fromARGB(255, 218, 241, 215)
            : Colors.white,
      ),
    );
  }
}
