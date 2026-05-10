import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ContractionDisclaimer extends StatelessWidget {
  const ContractionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'This tool is for tracking only and does not replace '
        'medical advice. Contact your provider if unsure.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.appColors.weakText,
        ),
      ),
    );
  }
}
