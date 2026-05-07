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
    AppBottomNavItemData(icon: Icons.home_outlined, activeIcon: Icons.home),
    AppBottomNavItemData(icon: Icons.timer_outlined, activeIcon: Icons.timer),
    AppBottomNavItemData(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
    ),
    AppBottomNavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
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

    return Scaffold(
      backgroundColor: context.appColors.appBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ExpectingHeader(activeChild: activeChild),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          PregnancyOverviewTab(child: activeChild),
          ContractionTimerTab(child: activeChild),
          PregnancyJournalTab(child: activeChild),
          ExpectingSettingsTab(child: activeChild),
        ],
      ),
      floatingActionButton: _buildFabForTab(activeChild),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavBar(
        items: _navItems,
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
      ),
    );
  }

  Widget? _buildFabForTab(ChildProfile child) {
    if (_tabIndex == 0) {
      return FloatingActionButton(
        onPressed: () => showAddPregnancyLogSheet(context, ref, child),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 60, 60, 60),
        child: const Icon(Icons.add),
      );
    }
    if (_tabIndex == 2) {
      return FloatingActionButton(
        onPressed: () => showAddJournalEntrySheet(context, ref, child),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
