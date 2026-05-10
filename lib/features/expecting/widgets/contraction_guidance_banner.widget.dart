import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';

class ContractionGuidanceBanner extends StatelessWidget {
  const ContractionGuidanceBanner({required this.guidance, super.key});

  final ContractionGuidance guidance;

  @override
  Widget build(BuildContext context) {
    if (guidance.level == ContractionGuidanceLevel.none) {
      return const SizedBox.shrink();
    }

    final isUrgent =
        guidance.level == ContractionGuidanceLevel.contactProvider;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUrgent ? const Color(0xFFFFE5E5) : const Color(0xFFFFF3DF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isUrgent ? const Color(0xFFF28482) : const Color(0xFFF6BD60),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              guidance.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              guidance.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
