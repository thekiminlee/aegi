import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogHistorySection extends StatelessWidget {
  const LogHistorySection({
    required this.logs,
    this.volumeUnit = VolumeUnit.ml,
    this.weightUnit = WeightUnit.kg,
    super.key,
  });

  final AsyncValue<List<PregnancyLog>> logs;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log History', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: () => _showAllLogs(context), 
              icon: Icon(Icons.menu, size: 22)
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
                  .map((item) => PregnancyLogCard(log: item, volumeUnit: volumeUnit, weightUnit: weightUnit))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAllLogs(BuildContext context) {
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
                    return PregnancyLogCard(log: items[index], volumeUnit: volumeUnit, weightUnit: weightUnit);
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
