import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/arrived/components/arrived_actions.dart';
import 'package:aegi/features/arrived/components/arrived_helpers.dart';
import 'package:aegi/features/arrived/providers/arrived_providers.dart';
import 'package:aegi/features/arrived/widgets/arrived_day_view_screen.dart';
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

    final lastActivity = logs.isNotEmpty ? logs.first : null;

    // Last timestamps per quick action type
    final lastBottle = _lastOfTypes(logs, [BabyLogType.bottleFeed, BabyLogType.breastMilk]);
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

        // --- Last Activity ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Last Activity'),
        const SizedBox(height: 8),
        if (lastActivity != null)
          _LastActivityCard(log: lastActivity)
        else
          EmptyPanel(message: 'No activity logged yet'),

        // --- Quick Actions ---
        const SizedBox(height: 16),
        SectionHeader(label: 'Quick Actions'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                label: 'Last Feed',
                icon: Symbols.pediatrics_rounded,
                tint: const Color(0xFFA8DADC),
                lastTimestamp: lastBottle?.timestamp,
                onTap: () => _quickLog(ref, child.id, BabyLogType.bottleFeed),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionTile(
                label: 'Last Wet',
                icon: Icons.water_drop_outlined,
                tint: const Color(0xFF90BE6D),
                lastTimestamp: lastWet?.timestamp,
                onTap: () => _quickLog(ref, child.id, BabyLogType.diaperWet),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionTile(
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
          ...history.map((log) => _BabyLogCard(
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

// ---------------------------------------------------------------------------
// Last Activity Card
// ---------------------------------------------------------------------------

class _LastActivityCard extends StatelessWidget {
  const _LastActivityCard({required this.log});

  final BabyLog log;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = babyLogIconAndColor(log.type);
    final List<String> labels = babyLogTitle(log);
    final timeAgo = _relativeTime(log.timestamp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels.join(" - "),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 35, 35, 35),
                    fontFamily: "Saira",
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    fontFamily: "Saira",
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('h:mm a').format(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              fontFamily: "Inconsolata",
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Tile
// ---------------------------------------------------------------------------

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.lastTimestamp,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final DateTime? lastTimestamp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tint, size: 20, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                fontFamily: "Inconsolata"
              ),
            ),
            Text(
              lastTimestamp != null
                  ? _relativeTime(lastTimestamp!)
                  : '--',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Baby Log Card (for history list)
// ---------------------------------------------------------------------------

class _BabyLogCard extends StatelessWidget {
  const _BabyLogCard({required this.log, this.onTap});

  final BabyLog log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = babyLogIconAndColor(log.type);
    final List<String> labels = babyLogTitle(log);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[1],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 35, 35, 35),
                    fontFamily: "Saira",
                  ),
                ),
                Text(
                  labels[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontFamily: "Saira"
                  )
                )
              ],
            ),
          ),
          Text(
            DateFormat('MMM d, h:mm a').format(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              fontFamily: "Inconsolata",
              fontSize: 13,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Relative time helper
// ---------------------------------------------------------------------------

String _relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) {
    final minutes = diff.inMinutes.remainder(60);
    if (minutes > 0) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ago';
    }
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}
