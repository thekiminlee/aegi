import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/app_bottom_nav_bar.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_header.dart';
import 'package:aegi/features/expecting/tabs/contraction_timer_tab.dart';
import 'package:aegi/features/setting/settings_tab.dart';
import 'package:aegi/features/expecting/tabs/journal_tab.dart';
import 'package:aegi/features/expecting/tabs/pregnancy_overview_tab.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcaseview/showcaseview.dart';

class ExpectingShellScreen extends ConsumerStatefulWidget {
  const ExpectingShellScreen({required this.activeChild, super.key});

  final ChildProfile activeChild;

  @override
  ConsumerState<ExpectingShellScreen> createState() =>
      _ExpectingShellScreenState();
}

class _ExpectingShellScreenState extends ConsumerState<ExpectingShellScreen> {
  int _tabIndex = 0;
  bool _showcaseChecked = false;

  Future<void> _maybeStartShowcase(BuildContext ctx) async {
    final shown = await ref
        .read(appMetaRepositoryProvider)
        .getValue(showcaseExpectingShownKey);
    // if (shown == 'true' || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShowCaseWidget.of(ctx).startShowCase(ExpectingShowcaseKeys.all);
      }
    });
  }

  static const _navItems = [
    AppBottomNavItemData(icon: Symbols.home, activeIcon: Symbols.home_filled),
    AppBottomNavItemData(
      icon: Symbols.hourglass,
      activeIcon: Symbols.hourglass,
    ),
    AppBottomNavItemData(icon: Symbols.book_5, activeIcon: Symbols.book_5),
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

    return ShowCaseWidget(
      disableMovingAnimation: true,
      disableScaleAnimation: true,
      onFinish: () => ref
          .read(appMetaRepositoryProvider)
          .setValue(showcaseExpectingShownKey, 'true'),
      builder: (ctx) {
        if (!_showcaseChecked) {
          _showcaseChecked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeStartShowcase(ctx);
          });
        }
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
                  JournalTab(child: activeChild),
                  SettingsTab(child: activeChild),
                ],
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            items: _navItems,
            currentIndex: _tabIndex,
            onTap: (index) => setState(() => _tabIndex = index),
            centerWidget: Showcase(
              targetPadding: const EdgeInsets.all(5),
              targetBorderRadius: BorderRadius.circular(20),
              key: ExpectingShowcaseKeys.addButton,
              title: 'Add Entry',
              description: 'Tap to log a new entry',
              child: GestureDetector(
                onTap: () => showUnifiedEntrySheet(ctx, ref, activeChild),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.appColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
