import 'package:aegi/app/providers.dart';
import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/tab_screen_tracking.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/app_bottom_nav_bar.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/tabs/arrived_overview_tab.dart';
import 'package:aegi/features/arrived/tabs/arrived_trends_tab.dart';
import 'package:aegi/features/expecting/tabs/journal_tab.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/expecting/components/expecting_header.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:aegi/features/setting/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcaseview/showcaseview.dart';

class ArrivedShellScreen extends ConsumerStatefulWidget {
  const ArrivedShellScreen({required this.activeChild, super.key});

  final ChildProfile activeChild;

  @override
  ConsumerState<ArrivedShellScreen> createState() => _ArrivedShellScreenState();
}

class _ArrivedShellScreenState extends ConsumerState<ArrivedShellScreen> {
  int _tabIndex = 0;
  bool _showcaseChecked = false;
  static const _screenNames = [
    AnalyticsScreenName.arrivedOverview,
    AnalyticsScreenName.arrivedTrends,
    AnalyticsScreenName.arrivedJournal,
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
  void didUpdateWidget(covariant ArrivedShellScreen oldWidget) {
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
        .getValue(showcaseArrivedShownKey);
    if (shown == 'true' || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShowCaseWidget.of(ctx).startShowCase(ArrivedShowcaseKeys.all);
      }
    });
  }

  static const _navItems = [
    AppBottomNavItemData(icon: Symbols.home, activeIcon: Symbols.home_filled, tabName: 'Home'),
    AppBottomNavItemData(
      icon: Symbols.trending_up,
      activeIcon: Symbols.trending_up,
      tabName: 'Trends'
    ),
    AppBottomNavItemData(icon: Symbols.book_5, activeIcon: Symbols.book_5, tabName: 'Journal' ),
    AppBottomNavItemData(
      icon: Symbols.account_circle,
      activeIcon: Symbols.account_circle,
      tabName: 'Account'
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
          .setValue(showcaseArrivedShownKey, 'true'),
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
            child: Header(activeChild: activeChild),
          ),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              ArrivedOverviewTab(child: activeChild),
              ArrivedTrendsTab(child: activeChild),
              JournalTab(child: activeChild),
              SettingsTab(child: activeChild),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            items: _navItems,
            currentIndex: _tabIndex,
            onTap: (index) {
              setState(() => _tabIndex = index);
              logTabScreen(
                analytics: ref.read(analyticsServiceProvider),
                screenNames: _screenNames,
                tabIndex: index,
              );
            },
            customNavWidget: GestureDetector(
              onTap: () => showArrivedEntrySheet(ctx, ref, activeChild),
              child: Icon(
                Icons.add,
                color: context.appColors.accent,
                size: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
