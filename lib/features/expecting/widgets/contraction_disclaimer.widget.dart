import 'package:flutter/material.dart';

class ContractionDisclaimer extends StatelessWidget {
  const ContractionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Always consult your medical provider",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontFamily: "Source Serif 4"
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This contraction timer is for informational and tracking purposes only. '
            'It is not a medical device and does not provide medical advice. '
            'Always consult your healthcare provider with any concerns.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: "Source Serif 4"
            ),
          ),
        ],
      ),
    );
  }
}
