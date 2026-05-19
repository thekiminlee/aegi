import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.tile,
    required this.width,
    super.key,
  });

  final TileData tile;
  final double width;

  @override
  Widget build(BuildContext context) {
    String dateFormat = 'MMMd';
    if (tile.includeTime) {
      dateFormat += ' hh:mm a';
    }
    final valueText = tile.trailing?.isEmpty ?? true ? tile.value : '${tile.value} ${tile.trailing}';

    return GestureDetector(
      onTap: () {
        if (tile.onTap != null) {
          tile.onTap!();
        }
      },
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.height * 0.17,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white70,
        ),
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
    );
  }
}
