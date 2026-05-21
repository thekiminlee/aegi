import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AppBottomNavItemData {
  const AppBottomNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.tabName,
  });

  final IconData icon;
  final IconData activeIcon;
  final String tabName;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.onAddTap,
    this.addLabel = '+',
    super.key,
  });

  final List<AppBottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAddTap;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          children: [
            tabs(context),
            const Spacer(),
            if (onAddTap != null) _buildAddIcon(context),
          ],
        )
      ));
    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //   decoration: BoxDecoration(color: context.appColors.appBackground),
    //   child: SafeArea(
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         ...List.generate(
    //           items.length,
    //           (i) =>
    //               _buildNavItem(context, i),
    //         ),
    //         Spacer(),
    //         if (onAddTap != null) _buildAddItem(context),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget tabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.appColors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          ...List.generate(
            items.length,
            (i) => _buildNavIcon(context, i),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, int index) {
    final item = items[index];
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        width: 50,
        height: 50,
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(right: items.length - 1 == index ? 0 : 5),
        decoration: BoxDecoration(
          color: selected ? context.appColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(item.activeIcon, color: selected ? context.appColors.accent : Colors.grey[400], size: 26, fontWeight: FontWeight.w500,),
      ),
    );
  }

  Widget _buildAddIcon(BuildContext context) {
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.appColors.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          Symbols.add,
          color: context.appColors.white,
        ),
      )
    );
  }

  Widget _buildAddItem(BuildContext context) {
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          addLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.appColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
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
          border: Border(
            bottom: BorderSide(
              color: selected ? context.appColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          item.tabName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? context.appColors.black : Colors.grey[400],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
