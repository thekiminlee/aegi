import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineLogRow extends StatelessWidget {
  const TimelineLogRow({
    required this.timestamp,
    required this.icon,
    required this.color,
    required this.categoryLabel,
    required this.detailText,
    this.onTap,
    super.key,
  });

  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final String categoryLabel;
  final String detailText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeText = DateFormat('h:mm a').format(timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: 64,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              // Dot + line connector
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 6, right: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              // Activity detail card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icon, color: color, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  categoryLabel,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              detailText,
                              // overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF232323),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
