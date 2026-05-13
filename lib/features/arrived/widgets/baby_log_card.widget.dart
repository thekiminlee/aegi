import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/features/arrived/components/arrived_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BabyLogCard extends StatelessWidget {
  const BabyLogCard({required this.log, this.onTap, super.key});

  final BabyLog log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = babyLogIconAndColor(log.type);
    final List<String> labels = babyLogTitle(log);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[1],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 35, 35, 35),
                    fontFamily: "Saira",
                  ),
                ),
                Text(
                  labels[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontFamily: "Saira"
                  )
                )
              ],
            ),
          ),
          Text(
            DateFormat('MMM d, h:mm a').format(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              fontFamily: "Inconsolata",
              fontSize: 13,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
