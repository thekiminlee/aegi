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
      child: Text(
        'This contraction timer is for informational and tracking purposes only. '
        'It is not a medical device and does not provide medical advice. '
        'Always consult your healthcare provider with any concerns.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: Colors.grey[400],
          fontFamily: "Inconsolata"
        ),
      ),
    );
  }
}
