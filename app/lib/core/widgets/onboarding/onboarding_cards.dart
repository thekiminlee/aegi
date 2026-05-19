import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.iconTint,
    super.key,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconTint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderColor = selected ? colors.selectedAccent : Colors.grey[400]!;
    final titleColor = selected ? colors.activeBorder : Colors.grey[400]!;

    return GestureDetector(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w500
          )
        ),
      ),
    );
  }
}

class InputSectionCard extends StatelessWidget {
  const InputSectionCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class DateFieldButton extends StatelessWidget {
  const DateFieldButton({required this.text, required this.onTap, required this.hasDate, super.key});

  final String text;
  final VoidCallback onTap;
  final bool hasDate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: hasDate ? context.appColors.selectedAccent : context.appColors.outline),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: hasDate ? Colors.black : Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.calendar_month_outlined, color: context.appColors.accent),
          ],
        ),
      ),
    );
  }
}

class MiniFeatureCard extends StatelessWidget {
  const MiniFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class InfoHintCard extends StatelessWidget {
  const InfoHintCard({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontFamily: "Source Serif 4"),
        ),
      ],
    );
  }
}
