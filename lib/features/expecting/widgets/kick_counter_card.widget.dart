import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class KickCounterCard extends ConsumerStatefulWidget {
  const KickCounterCard({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<KickCounterCard> createState() => _KickCounterCardState();
}

class _KickCounterCardState extends ConsumerState<KickCounterCard> {
  static const _green = Color(0xFF66BB6A);

  bool _isActive = false;
  DateTime? _startedAt;
  int _count = 0;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isActive ? _increment : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isActive ? _green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTopRow(context),
            const Spacer(),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    if (_isActive) {
      final mm = _elapsed.inMinutes.toString().padLeft(2, '0');
      final ss = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
      return Row(
        children: [
          Text(
            '$mm:$ss',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 20,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const Spacer(),
          _actionButton(
            Icons.stop_rounded,
            Colors.white,
            _stopSession,
          ),
          const SizedBox(width: 8),
          _actionButton(
            Icons.remove_rounded,
            Colors.white,
            _decrement,
          ),
          const SizedBox(width: 8),
          _actionButton(
            Icons.add_rounded,
            Colors.white,
            _increment,
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          'Kick Counter',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -1,
                color: Colors.grey[600]
              ),
        ),
        const Spacer(),
        _actionButton(
          Icons.play_arrow_rounded,
          _green,
          _startSession,
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final fillFraction = _isActive ? _count / 10 : 1.0;
        final fillWidth = totalWidth * fillFraction;

        final double barHeight = 16;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: barHeight,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: totalWidth,
                  height: barHeight,
                  color: _isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : _green,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: fillWidth,
                  height: barHeight,
                  color: _isActive
                      ? Colors.white.withValues(alpha: 0.5)
                      : _green,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
