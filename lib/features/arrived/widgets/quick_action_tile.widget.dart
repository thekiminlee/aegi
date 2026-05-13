import 'package:flutter/material.dart';

class QuickActionTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, color: tint, size: 28, fontWeight: FontWeight.w500)
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.grey[800],
                fontFamily: "Inconsolata",
              ),
            ),
            Text(
              lastTimestamp != null ? relativeTime(lastTimestamp!) : '--',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
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
