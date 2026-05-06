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
    final borderColor = selected ? colors.activeBorder : Colors.transparent;
    final titleColor = selected ? colors.activeBorder : Colors.black;

    return SizedBox(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 40, color: iconTint ?? colors.weakText),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: titleColor),
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.selectedAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
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
  const DateFieldButton({required this.text, required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: context.appColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
            ),
            Icon(Icons.calendar_month_outlined, color: Colors.red[500],),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.appColors.infoTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.info, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.appColors.weakText),
          ),
        ),
      ],
    );
  }
}
