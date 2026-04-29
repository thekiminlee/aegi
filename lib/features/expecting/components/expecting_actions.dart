import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/mood_type.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

Future<void> showAddPregnancyLogSheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child,
) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.ml;
  final weightUnit = settings?.weightUnit ?? WeightUnit.kg;

  final type = await showModalBottomSheet<PregnancyLogType>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text('Water Intake'),
              onTap: () =>
                  Navigator.of(context).pop(PregnancyLogType.waterIntake),
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: const Text('Weight'),
              onTap: () => Navigator.of(context).pop(PregnancyLogType.weight),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Blood Pressure'),
              onTap: () =>
                  Navigator.of(context).pop(PregnancyLogType.bloodPressure),
            ),
            ListTile(
              leading: const Icon(Icons.mood_outlined),
              title: const Text('Mood / Mental Health'),
              onTap: () => Navigator.of(context).pop(PregnancyLogType.mood),
            ),
            ListTile(
              leading: const Icon(Icons.medication_outlined),
              title: const Text('Medication'),
              onTap: () =>
                  Navigator.of(context).pop(PregnancyLogType.medication),
            ),
          ],
        ),
      );
    },
  );
  if (type == null) return;
  if (!context.mounted) return;

  Map<String, dynamic>? metadata;
  switch (type) {
    case PregnancyLogType.waterIntake:
      metadata = await _showWaterLogForm(context, volumeUnit);
      break;
    case PregnancyLogType.weight:
      metadata = await _showWeightLogForm(context, weightUnit);
      break;
    case PregnancyLogType.bloodPressure:
      metadata = await _showBloodPressureLogForm(context);
      break;
    case PregnancyLogType.mood:
      metadata = await _showMoodLogForm(context);
      break;
    case PregnancyLogType.medication:
      metadata = await _showMedicationLogForm(context);
      break;
    case PregnancyLogType.kickCounter:
      metadata = null;
      break;
  }

  if (metadata == null) return;

  final now = DateTime.now();
  await ref
      .read(pregnancyRepositoryProvider)
      .addLog(
        PregnancyLog(
          id: const Uuid().v4(),
          childId: child.id,
          type: type,
          timestamp: now,
          metadata: metadata,
          createdAt: now,
        ),
      );
}

Future<Map<String, dynamic>?> _showWaterLogForm(
  BuildContext context,
  VolumeUnit unit,
) async {
  final controller = TextEditingController();
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: 'Amount (${unit.name})'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true) return null;
  final amount = double.tryParse(controller.text.trim());
  if (amount == null || amount <= 0) return null;
  final amountMl = unit == VolumeUnit.oz ? amount * 29.5735 : amount;
  return {'amount': amount, 'unit': unit.name, 'amountMl': amountMl};
}

Future<Map<String, dynamic>?> _showWeightLogForm(
  BuildContext context,
  WeightUnit unit,
) async {
  final controller = TextEditingController();
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: 'Weight (${unit.name})'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true) return null;
  final amount = double.tryParse(controller.text.trim());
  if (amount == null || amount <= 0) return null;
  final weightKg = unit == WeightUnit.lb ? amount * 0.453592 : amount;
  return {'amount': amount, 'unit': unit.name, 'weightKg': weightKg};
}

Future<Map<String, dynamic>?> _showBloodPressureLogForm(
  BuildContext context,
) async {
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Systolic'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Diastolic'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true) return null;
  final systolic = int.tryParse(systolicController.text.trim());
  final diastolic = int.tryParse(diastolicController.text.trim());
  if (systolic == null ||
      diastolic == null ||
      systolic <= 0 ||
      diastolic <= 0) {
    return null;
  }
  return {'systolic': systolic, 'diastolic': diastolic};
}

Future<Map<String, dynamic>?> _showMoodLogForm(BuildContext context) async {
  final mood = await showModalBottomSheet<MoodType>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: MoodType.values
              .map(
                (item) => ListTile(
                  title: Text(
                    '${item.name[0].toUpperCase()}${item.name.substring(1)}',
                  ),
                  onTap: () => Navigator.of(context).pop(item),
                ),
              )
              .toList(),
        ),
      );
    },
  );

  if (mood == null) return null;
  return {'mood': mood.name};
}

Future<Map<String, dynamic>?> _showMedicationLogForm(
  BuildContext context,
) async {
  final controller = TextEditingController();
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Medication type'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true) return null;
  final name = controller.text.trim();
  if (name.isEmpty) return null;
  return {'name': name};
}

Future<void> showAddJournalEntrySheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child,
) async {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final tagsController = TextEditingController();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (saved != true) return;

  final now = DateTime.now();
  final title = titleController.text.trim().isEmpty
      ? 'Journal Entry'
      : titleController.text.trim();
  final body = bodyController.text.trim();
  final tags = tagsController.text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  await ref
      .read(journalRepositoryProvider)
      .addEntry(
        JournalEntryModel(
          id: const Uuid().v4(),
          childId: child.id,
          timestamp: now,
          title: title,
          body: body,
          tags: tags,
          createdAt: now,
          updatedAt: now,
        ),
      );
}
