import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:aegi/features/expecting/providers/expecting_providers.dart';
import 'package:aegi/features/expecting/util/fetus_growth_tracker.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PregnancyOverviewTab extends ConsumerStatefulWidget {
  const PregnancyOverviewTab({required this.child, super.key});

  final ChildProfile child;

  @override
  ConsumerState<PregnancyOverviewTab> createState() =>
      _PregnancyOverviewTabState();
}

class _PregnancyOverviewTabState extends ConsumerState<PregnancyOverviewTab> {
  bool _isKickSessionActive = false;
  DateTime? _kickSessionStartAt;
  int _kickSessionCount = 0;

  Future<void> _handleKickTap() async {
    if (!_isKickSessionActive) {
      setState(() {
        _isKickSessionActive = true;
        _kickSessionStartAt = DateTime.now();
        _kickSessionCount = 1;
      });
      return;
    }

    final nextCount = _kickSessionCount + 1;
    if (nextCount < 10) {
      setState(() => _kickSessionCount = nextCount);
      return;
    }

    final now = DateTime.now();
    final startedAt = _kickSessionStartAt ?? now;
    final duration = now.difference(startedAt);

    await ref
        .read(pregnancyRepositoryProvider)
        .addLog(
          PregnancyLog(
            id: const Uuid().v4(),
            childId: widget.child.id,
            type: PregnancyLogType.kickCounter,
            timestamp: now,
            metadata: {
              'kickTarget': 10,
              'kickCount': 10,
              'startedAtIso': startedAt.toIso8601String(),
              'endedAtIso': now.toIso8601String(),
              'durationSeconds': duration.inSeconds,
            },
            createdAt: now,
          ),
        );

    if (!mounted) return;
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  void _cancelKickSession() {
    if (!_isKickSessionActive) return;
    setState(() {
      _isKickSessionActive = false;
      _kickSessionStartAt = null;
      _kickSessionCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(expectingPregnancyLogsProvider(widget.child.id));
    final now = DateTime.now();
    final dueDate = widget.child.dueDate;

    final calc = PregnancyCalc.fromDueDate(dueDate, now);
    final growth = getFetusGrowthByWeek(calc.currentWeek);
    final growthLabel = (growth?['sizeLabel'] as String?) ?? 'Growing baby';
    final growthMessage =
        (growth?['message'] as String?) ?? 'Your baby keeps growing each week.';
    final growthHeight = growth?['approxLengthCm'] as double?;
    final growthWeight = growth?['approxWeightGrams'] as int?;

    final settingsAsync = ref.watch(activeChildContextProvider);
    final volumeUnit = settingsAsync.maybeWhen(
      data: (value) => value.settings.volumeUnit,
      orElse: () => VolumeUnit.ml,
    );
    final weightUnit = settingsAsync.maybeWhen(
      data: (value) => value.settings.weightUnit,
      orElse: () => WeightUnit.kg,
    );

    final summary = logs.maybeWhen(
      data: (items) => TodaySummary.fromLogs(items, now),
      orElse: TodaySummary.empty,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEEK ${calc.currentWeek}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                growthLabel,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              if (growthHeight != null && growthWeight != null) ...[
                Text(
                  'Baby is about ${growthHeight.toStringAsFixed(1)} cm and ${growthWeight / 1000} kg',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
              Text(
                growthMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: calc.progress,
                  backgroundColor: const Color(0xFFEDECEF),
                  valueColor: calc.daysRemaining <= 0
                      ? AlwaysStoppedAnimation(Colors.green[300])
                      : const AlwaysStoppedAnimation(Color(0xFF1C1C1E)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 20,
                        color: Color(0xFF6A6A72),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dueDate == null
                            ? 'Add due date in settings'
                            : '${calc.daysRemaining} day${calc.daysRemaining <= 1 ? '' : 's'} to go',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.appColors.weakText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    dueDate == null
                        ? 'Due date not set'
                        : 'Due ${DateFormat.yMMMd().format(dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _handleKickTap,
          onDoubleTap: _cancelKickSession,
          child: MetricTile(
            label: 'Kick Counter',
            value: _isKickSessionActive
                ? Text('$_kickSessionCount/10', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))
                : Text('Tap to start kick counter', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
            subtitle: _isKickSessionActive
                ? 'tap until 10 (double tap to cancel)'
                : (summary.latestKickDurationSeconds == null
                      ? ''
                      : 'at ${formatDuration(Duration(seconds: summary.latestKickDurationSeconds!))}'),
            icon: Icons.gesture_outlined,
            tint: const Color.fromARGB(255, 73, 195, 51),
            backgroundColor: _isKickSessionActive
                ? const Color.fromARGB(255, 218, 241, 215)
                : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Water Intake',
                value: Text(
                  '${mlToUnit(summary.totalWaterMlToday, volumeUnit).toStringAsFixed(1)} ${volumeUnit.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: 'today total',
                icon: Icons.water_drop_outlined,
                tint: const Color(0xFFA8DADC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Weight',
                value: summary.latestWeightKg == null
                    ? Text('--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400]))
                    : Text(
                        '${kgToUnit(summary.latestWeightKg!, weightUnit).toStringAsFixed(1)} ${weightUnit.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                subtitle: summary.latestWeightTimestamp == null ? '' : 'at ${formatDate(summary.latestWeightTimestamp)}',
                icon: Icons.monitor_weight_outlined,
                tint: const Color.fromARGB(255, 109, 190, 162),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Blood Pressure',
                value: summary.latestSystolic != null && summary.latestDiastolic != null
                    ? Text(
                        '${summary.latestSystolic}/${summary.latestDiastolic}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    : Text('--/--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400])),
                subtitle: summary.latestBloodPressureTimestamp == null ? '' : formatDateTime(summary.latestBloodPressureTimestamp),
                icon: Icons.favorite_outline,
                tint: const Color(0xFFF28482),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Medication',
                value: summary.latestMedicationName != null
                    ? Text(summary.latestMedicationName!, style: Theme.of(context).textTheme.titleLarge)
                    : Text('--', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[400])),
                subtitle: summary.latestMedicationTimestamp == null ? '' : formatDateTime(summary.latestMedicationTimestamp),
                icon: Icons.medication_outlined,
                tint: const Color(0xFFF6BD60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricTile(
          label: 'Mood / Mental Health',
          value: summary.latestMood != null
              ? Text(
                  moodLabel(summary.latestMood),
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : Text('--', style: Theme.of(context).textTheme.titleLarge),
          subtitle: formatDateTime(summary.latestMoodTimestamp),
          icon: Icons.mood_outlined,
          tint: const Color(0xFF84A59D),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log History', style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () => _showAllLogs(context, logs),
              child: const Text('View All'),
            ),
          ],
        ),
        logs.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load logs: $e'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyPanel(
                message: 'No pregnancy logs yet. Tap + to add your first log.',
              );
            }
            return Column(
              children: items
                  .take(6)
                  .map((item) => PregnancyLogCard(log: item))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAllLogs(BuildContext context, AsyncValue<List<PregnancyLog>> logs) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load logs: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No logs yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return PregnancyLogCard(log: items[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
