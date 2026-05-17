import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/util/month_tracker_color_scheme.dart';
import 'package:aegi/features/arrived/widgets/arrived_day_view_screen.dart';
import 'package:aegi/features/arrived/widgets/baby_log_card.widget.dart';
import 'package:aegi/features/arrived/widgets/month_tracker_card.widget.dart';
import 'package:aegi/features/arrived/widgets/quick_action_tile.widget.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:aegi/core/widgets/showcase/showcase_keys.dart';
import 'package:uuid/uuid.dart';

class ArrivedOverviewTab extends ConsumerWidget {
  const ArrivedOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAge = child.birthDate != null
        ? monthAgeFromBirthDate(child.birthDate!)
        : 0;
    final monthTrackerScheme = monthTrackerColorSchemeForMonth(monthAge);

    final logsAsync = ref.watch(arrivedBabyLogsProvider(child.id));
    final settings = ref.watch(appSettingsProvider);
    final volumeUnit =
        settings.maybeWhen(data: (s) => s?.volumeUnit, orElse: () => null) ??
        VolumeUnit.oz;

    final logs = logsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => <BabyLog>[],
    );

    // Last timestamps per quick action type
    final lastBottle = _lastOfTypes(logs, [
      BabyLogType.bottleFeed,
      BabyLogType.breastMilk,
    ]);
    final lastSleep = _lastOfTypes(logs, [
      BabyLogType.nap,
      BabyLogType.nightSleep,
    ]);
    final lastWet = _lastOfTypes(logs, [BabyLogType.diaperWet]);
    final lastDirty = _lastOfTypes(logs, [BabyLogType.diaperDirty]);

    final history = logs.take(5).toList();

    return TabScaffold(
      children: [
        TabHeader(
          subheading:
              "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
          heading: "${greeting(DateTime.now())},",
          extendedHeader: RichText(text: TextSpan(
            text: "how's ",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
                fontFamily: "Source Serif 4",
              ),
            children: [
              TextSpan(text: child.name, style: TextStyle(
                color: context.appColors.accent
              )),
              TextSpan(text: "?"),
            ]
          )),
          trailing: Showcase(
            targetPadding: const EdgeInsets.all(4),
            targetBorderRadius: BorderRadius.circular(8),
            key: ArrivedShowcaseKeys.viewAll,
            title: 'View All',
            titleTextStyle: showCaseTitleStyle,
            description: 'Easily track ${child.name}\'s daily activities',
            descTextStyle: showcaseDescStyle,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(analyticsServiceProvider)
                    .dailyTimelineViewed(mode: AnalyticsMode.arrived);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArrivedDayViewScreen(childId: child.id),
                  ),
                );
              },
              child: Text(
                "VIEW ALL",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey[400],
                  fontFamily: "Inconsolata",
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),

        // --- Month Tracker ---
        const SizedBox(height: 16),
        if (child.birthDate != null)
          Showcase(
            targetPadding: const EdgeInsets.all(5),
            targetBorderRadius: BorderRadius.circular(8),
            key: ArrivedShowcaseKeys.monthTracker,
            title: 'Month Tracker',
            titleTextStyle: showCaseTitleStyle,
            description:
                'Track your baby\'s growth milestones. You can also tap on this card to view expanded version.',
            descTextStyle: showcaseDescStyle,
            child: MonthTrackerCard(
              birthDate: child.birthDate!,
              babyName: child.name,
              childId: child.id,
              gradientColors: monthTrackerScheme.gradientColors,
              textColor: monthTrackerScheme.textColor,
            ),
          ),

        // --- Quick Actions ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Quick Actions'),
        const SizedBox(height: 8),
        Showcase(
          targetPadding: const EdgeInsets.all(5),
          targetBorderRadius: BorderRadius.circular(8),
          key: ArrivedShowcaseKeys.quickActions,
          title: 'Quick Actions',
          titleTextStyle: showCaseTitleStyle,
          description: 'Easily log common activities with single tap!',
          descTextStyle: showcaseDescStyle,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: QuickActionTile(
                      label: 'Last Feed',
                      icon: Symbols.pediatrics_rounded,
                      tint: const Color.fromARGB(255, 142, 208, 210),
                      lastTimestamp: lastBottle?.timestamp,
                      onTap: () async => _quickLogAndShowSuccess(
                        context,
                        ref,
                        child.id,
                        BabyLogType.bottleFeed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      label: 'Last Sleep',
                      icon: Icons.bedtime_outlined,
                      tint: const Color(0xFF84A59D),
                      lastTimestamp: lastSleep?.timestamp,
                      onTap: () async => _quickLogAndShowSuccess(
                        context,
                        ref,
                        child.id,
                        BabyLogType.nap,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: QuickActionTile(
                      label: 'Last Wet',
                      icon: Icons.water_drop_outlined,
                      tint: const Color(0xFF90BE6D),
                      lastTimestamp: lastWet?.timestamp,
                      onTap: () async => _quickLogAndShowSuccess(
                        context,
                        ref,
                        child.id,
                        BabyLogType.diaperWet,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionTile(
                      label: 'Last Dirty',
                      icon: Icons.cloud_outlined,
                      tint: const Color.fromARGB(255, 245, 185, 87),
                      lastTimestamp: lastDirty?.timestamp,
                      onTap: () async => _quickLogAndShowSuccess(
                        context,
                        ref,
                        child.id,
                        BabyLogType.diaperDirty,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- Activity History ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Activity History', count: history.length),
        const SizedBox(height: 8),
        Showcase(
          targetPadding: const EdgeInsets.all(5),
          targetBorderRadius: BorderRadius.circular(8),
          key: ArrivedShowcaseKeys.activityHistory,
          title: 'Activity History',
          titleTextStyle: showCaseTitleStyle,
          descTextStyle: showcaseDescStyle,
          description: 'View your baby\'s recent activities at a glance',
          child: history.isEmpty
              ? EmptyPanel(message: 'No activities yet')
              : Column(
                  children: history
                      .map(
                        (log) => BabyLogCard(
                          log: log,
                          volumeUnit: volumeUnit,
                          onTap: () => showEditBabyLogSheet(context, ref, log),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  BabyLog? _lastOfTypes(List<BabyLog> logs, List<BabyLogType> types) {
    for (final log in logs) {
      if (types.contains(log.type)) return log;
    }
    return null;
  }

  Future<void> _quickLog(
    WidgetRef ref,
    String childId,
    BabyLogType type,
  ) async {
    final now = DateTime.now();
    final metadata = switch (type) {
      BabyLogType.bottleFeed => <String, dynamic>{'feedKind': 'formula'},
      BabyLogType.diaperWet => <String, dynamic>{'type': 'wet'},
      BabyLogType.diaperDirty => <String, dynamic>{'type': 'dirty'},
      BabyLogType.nap => <String, dynamic>{'durationMin': 0},
      _ => <String, dynamic>{},
    };

    await ref
        .read(babyLogRepositoryProvider)
        .addLog(
          BabyLog(
            id: const Uuid().v4(),
            childId: childId,
            type: type,
            timestamp: now,
            metadata: metadata,
            createdAt: now,
          ),
        );
  }

  Future<void> _quickLogAndShowSuccess(
    BuildContext context,
    WidgetRef ref,
    String childId,
    BabyLogType type,
  ) async {
    await _quickLog(ref, childId, type);
    ref
        .read(analyticsServiceProvider)
        .quickActionTapped(
          entryType: switch (type) {
            BabyLogType.bottleFeed => AnalyticsEntryType.feed,
            BabyLogType.nap => AnalyticsEntryType.sleep,
            BabyLogType.diaperWet => AnalyticsEntryType.diaper,
            BabyLogType.diaperDirty => AnalyticsEntryType.diaper,
            _ => AnalyticsEntryType.feed,
          },
        );
    if (!context.mounted) return;

    final message = switch (type) {
      BabyLogType.bottleFeed => 'Feed added',
      BabyLogType.nap => 'Sleep added',
      BabyLogType.diaperWet => 'Wet diaper added',
      BabyLogType.diaperDirty => 'Dirty diaper added',
      _ => 'Entry added',
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Inconsolata",
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
  }
}
