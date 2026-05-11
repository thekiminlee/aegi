import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/app_bottom_nav_bar.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_header.dart';
import 'package:aegi/features/expecting/tabs/contraction_timer_tab.dart';
import 'package:aegi/features/expecting/tabs/expecting_settings_tab.dart';
import 'package:aegi/features/expecting/tabs/pregnancy_journal_tab.dart';
import 'package:aegi/features/expecting/tabs/pregnancy_overview_tab.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class ExpectingShellScreen extends ConsumerStatefulWidget {
  const ExpectingShellScreen({required this.activeChild, super.key});

  final ChildProfile activeChild;

  @override
  ConsumerState<ExpectingShellScreen> createState() =>
      _ExpectingShellScreenState();
}

class _ExpectingShellScreenState extends ConsumerState<ExpectingShellScreen> {
  int _tabIndex = 0;

  static const _navItems = [
    AppBottomNavItemData(icon: Symbols.home, activeIcon: Symbols.home_filled),
    AppBottomNavItemData(icon: Symbols.hourglass, activeIcon: Symbols.hourglass),
    AppBottomNavItemData(
      icon: Symbols.book_5,
      activeIcon: Symbols.book_5,
    ),
    AppBottomNavItemData(
      icon: Symbols.account_circle,
      activeIcon: Symbols.account_circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeChild = ref
        .watch(activeChildContextProvider)
        .maybeWhen(
          data: (value) => value.child,
          orElse: () => widget.activeChild,
        );

    final bgColor = context.appColors.appBackground;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ExpectingHeader(activeChild: activeChild),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _tabIndex,
            children: [
              PregnancyOverviewTab(child: activeChild),
              ContractionTimerTab(child: activeChild),
              PregnancyJournalTab(child: activeChild),
              ExpectingSettingsTab(child: activeChild),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: _navItems,
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        centerWidget: GestureDetector(
          onTap: () => showUnifiedEntrySheet(context, ref, activeChild),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.appColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
