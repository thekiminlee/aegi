import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/widgets/arrived_day_view_screen.dart';
import 'package:aegi/features/arrived/widgets/baby_log_card.widget.dart';
import 'package:aegi/features/arrived/widgets/month_tracker_card.widget.dart';
import 'package:aegi/features/arrived/widgets/quick_action_tile.widget.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
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

    final logs = logsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => <BabyLog>[],
    );

    // Last timestamps per quick action type
    final lastBottle = _lastOfTypes(logs, [BabyLogType.bottleFeed, BabyLogType.breastMilk]);
    final lastSleep = _lastOfTypes(logs, [BabyLogType.nap, BabyLogType.nightSleep]);
    final lastWet = _lastOfTypes(logs, [BabyLogType.diaperWet]);
    final lastDirty = _lastOfTypes(logs, [BabyLogType.diaperDirty]);

    final history = logs.take(10).toList();

    return TabScaffold(
      children: [
        TabHeader(
          subheading: "TODAY · ${DateFormat('EEEE MMM d').format(DateTime.now()).toUpperCase()}",
          heading: "How's ${child.name}?",
          trailing: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArrivedDayViewScreen(childId: child.id),
              ),
            ),
            child: Text("VIEW ALL", style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[400],
              fontFamily: "Inconsolata",
              letterSpacing: 1.2,)
            ),
        )
      ),

        // --- Month Tracker ---
        const SizedBox(height: 16),
        if (child.birthDate != null)
          MonthTrackerCard(
            birthDate: child.birthDate!,
            babyName: child.name,
            childId: child.id,
            gradientColors: const [
              Color(0xFFFCE4EC),
              Color(0xFFF8BBD0),
              Color(0xFFF48FB1),
              Color(0xFFE1BEE7),
            ],
            textColor: const Color(0xFF4A2040),
          ),

        // --- Quick Actions ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Quick Actions'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: QuickActionTile(
                label: 'Last Feed',
                icon: Symbols.pediatrics_rounded,
                tint: const Color(0xFFA8DADC),
                lastTimestamp: lastBottle?.timestamp,
                onTap: () => _quickLog(ref, child.id, BabyLogType.bottleFeed),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionTile(
                label: 'Last Sleep',
                icon: Icons.bedtime_outlined,
                tint: const Color(0xFF84A59D),
                lastTimestamp: lastSleep?.timestamp,
                onTap: () => _quickLog(ref, child.id, BabyLogType.nap),
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
                onTap: () => _quickLog(ref, child.id, BabyLogType.diaperWet),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionTile(
                label: 'Last Dirty',
                icon: Icons.cloud_outlined,
                tint: const Color(0xFFF6BD60),
                lastTimestamp: lastDirty?.timestamp,
                onTap: () => _quickLog(ref, child.id, BabyLogType.diaperDirty),
              ),
            ),
          ],
        ),

        // --- Activity History ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Activity History', count: history.length),
        const SizedBox(height: 8),
        if (history.isEmpty)
          EmptyPanel(message: 'No activities yet')
        else
          ...history.map((log) => BabyLogCard(
                log: log,
                onTap: () => showEditBabyLogSheet(context, ref, log),
              )),
      ],
    );
  }

  BabyLog? _lastOfTypes(List<BabyLog> logs, List<BabyLogType> types) {
    for (final log in logs) {
      if (types.contains(log.type)) return log;
    }
    return null;
  }

  Future<void> _quickLog(WidgetRef ref, String childId, BabyLogType type) async {
    final now = DateTime.now();
    final metadata = switch (type) {
      BabyLogType.bottleFeed => <String, dynamic>{},
      BabyLogType.diaperWet => <String, dynamic>{'type': 'wet'},
      BabyLogType.diaperDirty => <String, dynamic>{'type': 'dirty'},
      BabyLogType.nap => <String, dynamic>{'durationMin': 0},
      _ => <String, dynamic>{},
    };

    await ref.read(babyLogRepositoryProvider).addLog(
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
}
