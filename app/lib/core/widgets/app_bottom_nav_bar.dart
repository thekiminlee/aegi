import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppBottomNavItemData {
  const AppBottomNavItemData({required this.icon, required this.activeIcon, required this.tabName});

  final IconData icon;
  final IconData activeIcon;
  final String tabName;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.customNavWidget,
    super.key,
  });

  final List<AppBottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? customNavWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container( 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: context.appColors.appBackground,
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ...List.generate(splitIndex, (i) => _buildNavItem(context, i)),
                // ?customNavWidget,
                ...List.generate(
                  items.length,
                  (i) => Expanded(child: _buildNavItem(context, i)),
                ),
                customNavWidget ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = items[index];
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // color: Colors.amber,
          border: Border(
            bottom: BorderSide(
              color: selected ? context.appColors.accent : Colors.transparent,
              width: 2,
            ),
          )
        ),
        child: Text(
          item.tabName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? context.appColors.black : Colors.grey[400],
            fontWeight: FontWeight.w600,
            fontSize: 15,
            // letterSpacing: 0.5
          ),
        ),
      )
    );
  }
}
