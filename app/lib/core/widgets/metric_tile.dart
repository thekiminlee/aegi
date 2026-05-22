import 'dart:math' as math;

import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:flutter/material.dart';

class MetricTileRow extends StatelessWidget {
  const MetricTileRow({
    required this.tiles,
    super.key,
  });

  final List<TileData> tiles;

  @override
  Widget build(BuildContext context) {
    final fullWidth = MediaQuery.sizeOf(context).width;
    final tileWidth = (fullWidth - 32 - 3 * (tiles.length - 1)) / tiles.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tiles.map((tile) => MetricTile(tile: tile, width: tileWidth)).toList(),
    );
  }
}

class MetricTile extends StatefulWidget {
  const MetricTile({
    required this.tile,
    required this.width,
    super.key,
  });

  final TileData tile;
  final double width;

  @override
  State<MetricTile> createState() => _MetricTileState();
}

class _MetricTileState extends State<MetricTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Offset? _tapPosition;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final onTap = widget.tile.onTap;
    if (onTap == null) return;
    // Color sweeps through the container to confirm the log was added.
    _controller
      ..reset()
      ..forward();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    final valueText = tile.trailing?.isEmpty ?? true ? tile.value : '${tile.value} ${tile.trailing}';
    final tileHeight = MediaQuery.of(context).size.height * 0.17;

    return GestureDetector(
      onTapDown: (details) => _tapPosition = details.localPosition,
      onTap: _handleTap,
      child: Container(
        width: widget.width,
        height: tileHeight,
        decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(color: tile.isSelected ? context.appColors.selectedAccent : Colors.transparent, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // Expanding color reaction — confirms quick log was added.
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    if (_controller.isDismissed) return const SizedBox.shrink();
                    return CustomPaint(
                      painter: _TileFillPainter(
                        progress: _controller.value,
                        origin: _tapPosition ?? Offset(widget.width / 2, tileHeight / 2),
                        color: tile.iconColor,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tile.label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey[500])),
                        Icon(tile.icon, color: tile.iconColor, size: 24, fontWeight: FontWeight.w600),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (tile.subtitle != null)
                              Text(
                                tile.subtitle!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400], fontWeight: FontWeight.w500),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                valueText,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a circle of [color] expanding radially from [origin], then fading out.
class _TileFillPainter extends CustomPainter {
  _TileFillPainter({
    required this.progress,
    required this.origin,
    required this.color,
  });

  final double progress;
  final Offset origin;
  final Color color;

  // Circle grows over the first portion of the animation, then fades.
  static const _expandEnd = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final expand = (progress / _expandEnd).clamp(0.0, 1.0);
    final fade = progress <= _expandEnd ? 1.0 : 1.0 - ((progress - _expandEnd) / (1 - _expandEnd));

    final radius = _maxRadius(size) * Curves.easeOut.transform(expand);
    final paint = Paint()..color = color.withValues(alpha: 0.45 * fade);
    canvas.drawCircle(origin, radius, paint);
  }

  double _maxRadius(Size size) {
    final dx = math.max(origin.dx, size.width - origin.dx);
    final dy = math.max(origin.dy, size.height - origin.dy);
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldRepaint(_TileFillPainter old) =>
      old.progress != progress || old.origin != origin || old.color != color;
}
