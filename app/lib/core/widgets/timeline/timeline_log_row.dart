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
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontFamily: 'Inconsolata',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              // Dot + line connector
              Padding(
                padding: const EdgeInsets.only(top: 18, right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity detail card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              detailText,
                              style: const TextStyle(
                                fontFamily: 'Saira',
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
