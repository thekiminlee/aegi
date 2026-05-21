import 'package:aegi/app/providers.dart';
import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/tab_screen_tracking.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/app_bottom_nav_bar.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';
import 'package:aegi/data/models/child_profile.dart';
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
  static const int _timerTabIndex = 1;
  static const int _journalTabIndex = 2;
  static const int _accountTabIndex = 3;

  int _tabIndex = 0;
  bool _showcaseChecked = false;
  static const _screenNames = [
    AnalyticsScreenName.expectingOverview,
    AnalyticsScreenName.expectingContractionTimer,
    AnalyticsScreenName.expectingJournal,
    AnalyticsScreenName.settings,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      logTabScreen(
        analytics: ref.read(analyticsServiceProvider),
        screenNames: _screenNames,
        tabIndex: _tabIndex,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ExpectingShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeChild.id != widget.activeChild.id && _tabIndex != 0) {
      setState(() => _tabIndex = 0);
      logResetTabScreen(
        analytics: ref.read(analyticsServiceProvider),
        screenNames: _screenNames,
        state: this,
      );
    }
  }

  Future<void> _maybeStartShowcase(BuildContext ctx) async {
    final shown = await ref
        .read(appMetaRepositoryProvider)
        .getValue(showcaseExpectingShownKey);
    if (shown == 'true' || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShowCaseWidget.of(ctx).startShowCase(ExpectingShowcaseKeys.all);
      }
    });
  }

  static const _navItems = [
    AppBottomNavItemData(
      icon: Symbols.home,
      activeIcon: Symbols.home_filled,
      tabName: 'Home',
    ),
    AppBottomNavItemData(
      icon: Symbols.hourglass,
      activeIcon: Symbols.hourglass,
      tabName: 'Timer',
    ),
  ];

  void _setTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    logTabScreen(
      analytics: ref.read(analyticsServiceProvider),
      screenNames: _screenNames,
      tabIndex: index,
    );
  }

  void _handleAddTap(BuildContext context, ChildProfile activeChild) {
    showJournalEntryModal(context, ref, activeChild);
  }

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
            child: Header(
              activeChild: activeChild,
              onNotesTap: () => _setTab(_journalTabIndex),
              onMenuTap: () => _setTab(_accountTabIndex),
              isNotesSelected: _tabIndex == _journalTabIndex,
              isMenuSelected: _tabIndex == _accountTabIndex,
            ),
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
            currentIndex: _tabIndex <= _timerTabIndex ? _tabIndex : -1,
            onTap: _setTab,
            onAddTap: _tabIndex == _journalTabIndex
                ? () => _handleAddTap(ctx, activeChild)
                : null,
          ),
        );
      },
    );
  }
}
