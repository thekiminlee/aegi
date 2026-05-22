import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/data/tile.data.dart';
import 'package:aegi/core/widgets/metric_tile.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/widgets/arrived_day_view_screen.dart';
import 'package:aegi/features/arrived/widgets/quick_action_tile.widget.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class ArrivedOverviewTab extends ConsumerWidget {
  const ArrivedOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(arrivedBabyLogsProvider(child.id));
    final settings = ref.watch(appSettingsProvider);
    final volumeUnit =
        settings.maybeWhen(data: (s) => s?.volumeUnit, orElse: () => null) ??
        VolumeUnit.oz;

    final logs = logsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => <BabyLog>[],
    );

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

    final feedSubtitle = _feedSubtitle(lastBottle, volumeUnit);
    final sleepSubtitle = _sleepSubtitle(lastSleep);

    return TabPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),

                // --- Age display ---
                if (child.birthDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _friendlyAge(child.birthDate!),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: context.appColors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "born on ",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, y').format(child.birthDate!),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: context.appColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // --- Bottom section ---
                Column(
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(analyticsServiceProvider).dailyTimelineViewed(
                          mode: AnalyticsMode.arrived,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ArrivedDayViewScreen(childId: child.id),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "VIEW ALL",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Symbols.arrow_outward, size: 16, color: Colors.grey[400], fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Quick action metric tiles ---
                    MetricTileRow(tiles: [
                      TileData(
                        icon: Symbols.pediatrics_rounded,
                        iconColor: const Color.fromARGB(255, 142, 208, 210),
                        label: 'feed',
                        value: lastBottle?.timestamp != null
                            ? relativeTime(lastBottle!.timestamp)
                            : '--',
                        trailing: '',
                        subtitle: feedSubtitle,
                        tab: EntryTab.water,
                        onTap: () => _quickLogAndShowSuccess(
                          context, ref, child.id, BabyLogType.bottleFeed,
                        ),
                      ),
                      TileData(
                        icon: Icons.bedtime_outlined,
                        iconColor: const Color(0xFF84A59D),
                        label: 'sleep',
                        value: lastSleep?.timestamp != null
                            ? relativeTime(lastSleep!.timestamp)
                            : '--',
                        trailing: '',
                        subtitle: sleepSubtitle,
                        tab: EntryTab.water,
                        onTap: () => _quickLogAndShowSuccess(
                          context, ref, child.id, BabyLogType.nap,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    MetricTileRow(tiles: [
                      TileData(
                        icon: Icons.water_drop_outlined,
                        iconColor: const Color(0xFF90BE6D),
                        label: 'wet',
                        value: lastWet?.timestamp != null
                            ? relativeTime(lastWet!.timestamp)
                            : '--',
                        trailing: '',
                        subtitle: null,
                        tab: EntryTab.water,
                        onTap: () => _quickLogAndShowSuccess(
                          context, ref, child.id, BabyLogType.diaperWet,
                        ),
                      ),
                      TileData(
                        icon: Icons.cloud_outlined,
                        iconColor: const Color.fromARGB(255, 245, 185, 87),
                        label: 'dirty',
                        value: lastDirty?.timestamp != null
                            ? relativeTime(lastDirty!.timestamp)
                            : '--',
                        trailing: '',
                        subtitle: null,
                        tab: EntryTab.water,
                        onTap: () => _quickLogAndShowSuccess(
                          context, ref, child.id, BabyLogType.diaperDirty,
                        ),
                      ),
                    ]),

                    // --- Activity History ---
                    // const SizedBox(height: 16),
                    // SectionHeader(label: 'Activity History', count: history.length),
                    // const SizedBox(height: 8),
                    // Showcase(
                    //   targetPadding: const EdgeInsets.all(5),
                    //   targetBorderRadius: BorderRadius.circular(8),
                    //   key: ArrivedShowcaseKeys.activityHistory,
                    //   title: 'Activity History',
                    //   titleTextStyle: showCaseTitleStyle,
                    //   descTextStyle: showcaseDescStyle,
                    //   description: 'View your baby\'s recent activities at a glance',
                    //   child: history.isEmpty
                    //       ? EmptyPanel(message: 'No activities yet')
                    //       : Column(
                    //           children: history
                    //               .map(
                    //                 (log) => BabyLogCard(
                    //                   log: log,
                    //                   volumeUnit: volumeUnit,
                    //                   onTap: () => showEditBabyLogSheet(context, ref, log),
                    //                 ),
                    //               )
                    //               .toList(),
                    //         ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyAge(DateTime birthDate) {
    final now = DateTime.now();
    final totalDays = now.difference(birthDate).inDays;

    if (totalDays < 0) return '0 days';
    if (totalDays == 0) return 'newborn';
    if (totalDays < 7) return '$totalDays day${totalDays == 1 ? '' : 's'}';

    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    int days = now.day - birthDate.day;
    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }

    final weeks = days ~/ 7;

    if (months == 0) {
      return '$weeks week${weeks == 1 ? '' : 's'}';
    }

    if (weeks > 0) {
      return '$months mo $weeks week${weeks == 1 ? '' : 's'}';
    }
    return '$months mo';
  }

  String? _feedSubtitle(BabyLog? log, VolumeUnit unit) {
    if (log == null) return null;
    if (log.type == BabyLogType.breastMilk) return 'breast';
    final amount = (log.metadata['displayAmount'] as num?)?.toDouble();
    if (amount == null || amount == 0) return null;
    final label = amount % 1 == 0
        ? '${amount.toInt()} ${unit.name}'
        : '${amount.toStringAsFixed(1)} ${unit.name}';
    return label;
  }

  String? _sleepSubtitle(BabyLog? log) {
    if (log == null) return null;
    final min = (log.metadata['durationMin'] as num?)?.toInt() ?? 0;
    if (min <= 0) return null;
    final h = min ~/ 60;
    final m = min % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
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
