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
          Row(
            children: [
              Icon(Icons.info, color: Colors.grey[600], size: 13),
              SizedBox(width: 6,),
              Text(
                "Always consult your medical provider",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  fontFamily: "Source Serif 4",
                  fontSize: 15
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This contraction timer is for informational and tracking purposes only. '
            'It is not a medical device and does not provide medical advice. '
            'Always consult your healthcare provider with any concerns.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: "Source Serif 4"
            ),
          ),
        ],
      ),
    );
  }
}
