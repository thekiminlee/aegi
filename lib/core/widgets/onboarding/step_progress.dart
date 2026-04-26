import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({required this.currentIndex, this.total = 3, super.key});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isActive = index <= currentIndex;
        return Container(
          width: isActive ? 38 : 12,
          height: 6,
          margin: EdgeInsets.only(right: index == total - 1 ? 0 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isActive ? colors.activeBorder : colors.progressInactive,
          ),
        );
      }),
    );
  }
}
