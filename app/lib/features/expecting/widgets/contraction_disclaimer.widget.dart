import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ContractionDisclaimer extends StatefulWidget {
  const ContractionDisclaimer({super.key});

  @override
  State<ContractionDisclaimer> createState() => _ContractionDisclaimerState();
}

class _ContractionDisclaimerState extends State<ContractionDisclaimer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Symbols.info, color: Colors.grey[600], size: 12),
                    SizedBox(width: 6,),
                    Text(
                      "Always consult your medical provider",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                        fontFamily: "Source Serif 4",
                        fontSize: 12
                      ),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Symbols.arrow_upward,
                    color: Colors.grey[500],
                    size: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'The timers are purely intended for informational and tracking purposes only. '
                        'It is not a medical device and should not be treated as a medical advice. '
                        'Always consult your healthcare provider with any concerns.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontFamily: "Source Serif 4"
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
  }
}
