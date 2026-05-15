import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppBottomNavItemData {
  const AppBottomNavItemData({required this.icon, required this.activeIcon});

  final IconData icon;
  final IconData activeIcon;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerWidget,
    super.key,
  });

  final List<AppBottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final splitIndex = items.length ~/ 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: centerWidget != null ? 290 : 240,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...List.generate(splitIndex, (i) => _buildNavItem(context, i)),
              ?centerWidget,
              ...List.generate(
                items.length - splitIndex,
                (i) => _buildNavItem(context, i + splitIndex),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = items[index];
    final selected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(999),
      child: Icon(
        selected ? item.activeIcon : item.icon,
        color: selected ? context.appColors.accent : const Color.fromARGB(255, 186, 186, 192),
        fontWeight: FontWeight.w600,
        size: 28
      ),
    );
  }
}
