import 'dart:math' as math;

import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.lastTimestamp,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final DateTime? lastTimestamp;
  final VoidCallback onTap;

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 210),
  );

  bool _isAnimatingTap = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isAnimatingTap) return;
    _isAnimatingTap = true;
    widget.onTap();
    await _controller.forward(from: 0);
    await _controller.reverse();
    _isAnimatingTap = false;
  }

  @override
  Widget build(BuildContext context) {
    const tileHeight = 120.0;
    const tileRadius = 20.0;
    const circleCenter = Offset(36, 36);
    const circleBaseRadius = 22.0;

    return GestureDetector(
      onTap: _handleTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = tileHeight;
          final maxDx = math.max(circleCenter.dx, w - circleCenter.dx);
          final maxDy = math.max(circleCenter.dy, h - circleCenter.dy);
          final expandedRadius = math.sqrt((maxDx * maxDx) + (maxDy * maxDy));
          final maxScale = expandedRadius / circleBaseRadius;

          return Container(
            height: tileHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(tileRadius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = Curves.easeOutCubic.transform(_controller.value);
                    final scale = 1 + (maxScale - 1) * t;
                    return Positioned(
                      left: circleCenter.dx - circleBaseRadius,
                      top: circleCenter.dy - circleBaseRadius,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: circleBaseRadius * 2,
                          height: circleBaseRadius * 2,
                          decoration: BoxDecoration(
                            color: widget.tint.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.tint.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.tint,
                          size: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontFamily: "Inconsolata",
                        ),
                      ),
                      Text(
                        widget.lastTimestamp != null
                            ? relativeTime(widget.lastTimestamp!)
                            : '--',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) {
    final minutes = diff.inMinutes.remainder(60);
    if (minutes > 0) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ago';
    }
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}
