import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
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

class _KickCounterCardState extends ConsumerState<KickCounterCard>
    with SingleTickerProviderStateMixin {
  // static const _activeColor = Color.fromARGB(255, 157, 249, 145);
  static const _tint = Color.fromARGB(255, 249, 160, 26);

  bool _isKickSessionActive = false;
  DateTime? _kickSessionStartAt;
  int _kickSessionCount = 0;
  bool _incrementing = true;

  int _tapCount = 0;
  Timer? _tapTimer;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  late AnimationController _pulseController;
  late Animation<Color?> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _bgAnimation = ColorTween(
      // begin: _activeColor,
      begin: Colors.white,
      end: const Color.fromARGB(255, 253, 184, 80).withValues(alpha: 0.25),
      // end: Colors.white,
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    _elapsedTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
    _elapsed = Duration.zero;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _elapsed = Duration.zero;
  }

  void _onTap() {
    if (!_isKickSessionActive) {
      _handleKickTap();
      return;
    }
    _tapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 350), () {
      final count = _tapCount;
      _tapCount = 0;
      if (count == 1) {
        _handleKickTap();
      } else if (count == 2) {
        _handleKickDecrement();
      } else if (count >= 3) {
        _cancelKickSession();
      }
    });
  }

  Future<void> _handleKickTap() async {
    if (!_isKickSessionActive) {
      setState(() {
        _isKickSessionActive = true;
        _kickSessionStartAt = DateTime.now();
        _kickSessionCount = 1;
        _incrementing = true;
      });
      _startPulse();
      return;
    }

    final nextCount = _kickSessionCount + 1;
    if (nextCount < 10) {
      setState(() {
        _incrementing = true;
        _kickSessionCount = nextCount;
      });
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
    _stopPulse();
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  void _handleKickDecrement() {
    if (!_isKickSessionActive) return;
    if (_kickSessionCount <= 1) {
      _cancelKickSession();
      return;
    }
    setState(() {
      _incrementing = false;
      _kickSessionCount = _kickSessionCount - 1;
    });
  }

  void _cancelKickSession() {
    if (!_isKickSessionActive) return;
    _stopPulse();
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) {
          return Container(
            height: 146,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isKickSessionActive
                  ? _bgAnimation.value
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isKickSessionActive
              ? _buildActive(context)
              : _buildInactive(context),
        ),
      ),
    );
  }

  Widget _buildInactive(BuildContext context) {
    return Column(
      key: const ValueKey('inactive'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _tint.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.gesture_outlined, color: _tint),
            ),
            Text(
              'kick counter',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: -0.5,
                    color: const Color.fromARGB(255, 49, 49, 49)
                  ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'tap to start',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[600]),
        ),
        if (widget.latestKickDurationSeconds != null)
          Text(
            'last session ${formatDuration(Duration(seconds: widget.latestKickDurationSeconds!))}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildActive(BuildContext context) {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      key: const ValueKey('active'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$minutes:$seconds',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 20,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              transitionBuilder: (child, animation) {
                final beginOffset = _incrementing
                    ? const Offset(0, 0.5)
                    : const Offset(0, -0.5);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: beginOffset,
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: Text(
                '$_kickSessionCount',
                key: ValueKey<int>(_kickSessionCount),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 50
                    ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'tap until 10\ndouble tap to desc\ntriple tap to end',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
