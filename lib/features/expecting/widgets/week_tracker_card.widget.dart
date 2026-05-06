import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekTrackerCard extends StatelessWidget {
  const WeekTrackerCard({
    super.key,
    required this.calc,
    required this.growthLabel,
    required this.growthMessage,
    required this.dueDate,
    required this.growthHeight,
    required this.growthWeight,
  });

  final PregnancyCalc calc;
  final String growthLabel;
  final String growthMessage;
  final double? growthHeight;
  final int? growthWeight;
  final DateTime? dueDate;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEK ${calc.currentWeek}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            growthLabel,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          if (growthHeight != null && growthWeight != null) ...[
            Text(
              'Baby is about ${growthHeight!.toStringAsFixed(1)} cm and ${growthWeight! / 1000} kg',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
          Text(
            growthMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: calc.progress,
              backgroundColor: const Color(0xFFEDECEF),
              valueColor: calc.daysRemaining <= 0
                  ? AlwaysStoppedAnimation(Colors.green[300])
                  : const AlwaysStoppedAnimation(Color(0xFF1C1C1E)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 20,
                    color: Color(0xFF6A6A72),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dueDate == null
                        ? 'Add due date in settings'
                        : '${calc.daysRemaining} day${calc.daysRemaining <= 1 ? '' : 's'} to go',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                dueDate == null
                    ? 'Due date not set'
                    : 'Due ${DateFormat.yMMMd().format(dueDate!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
