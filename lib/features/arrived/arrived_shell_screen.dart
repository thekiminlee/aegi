import 'package:aegi/app/providers.dart';
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

  @override
  void didUpdateWidget(covariant ArrivedShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeChild.id != widget.activeChild.id && _tabIndex != 0) {
      setState(() => _tabIndex = 0);
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
    AppBottomNavItemData(icon: Symbols.home, activeIcon: Symbols.home_filled),
    AppBottomNavItemData(
      icon: Symbols.trending_up,
      activeIcon: Symbols.trending_up,
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
            child: ExpectingHeader(activeChild: activeChild),
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
            onTap: (index) => setState(() => _tabIndex = index),
            centerWidget: Showcase(
              targetPadding: const EdgeInsets.all(5),
              targetBorderRadius: BorderRadius.circular(8),
              key: ArrivedShowcaseKeys.addButton,
              title: 'Add Activity',
              description: 'Tap to add a new activity',
              titleTextStyle: showCaseTitleStyle,
              descTextStyle: showcaseDescStyle,
              child: GestureDetector(
                onTap: () => showArrivedEntrySheet(ctx, ref, activeChild),
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
