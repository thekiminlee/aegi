import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/mood_type.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _logTypes = [
  (type: PregnancyLogType.waterIntake, icon: Icons.water_drop_outlined, label: 'Water', color: Color(0xFFA8DADC)),
  (type: PregnancyLogType.weight, icon: Icons.monitor_weight_outlined, label: 'Weight', color: Color(0xFF90BE6D)),
  (type: PregnancyLogType.bloodPressure, icon: Icons.favorite_outline, label: 'BP', color: Color(0xFFF28482)),
  (type: PregnancyLogType.medication, icon: Icons.medication_outlined, label: 'Meds', color: Color(0xFFF6BD60)),
  (type: PregnancyLogType.mood, icon: Icons.mood_outlined, label: 'Mood', color: Color(0xFF84A59D)),
];

Future<void> showAddPregnancyLogSheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child,
) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.ml;
  final weightUnit = settings?.weightUnit ?? WeightUnit.kg;

  final waterController = TextEditingController();
  final weightController = TextEditingController();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final medicationController = TextEditingController();

  var selectedType = PregnancyLogType.waterIntake;
  MoodType? selectedMood;

  final result =
      await showModalBottomSheet<(PregnancyLogType, Map<String, dynamic>)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Type selector row ---
                  Row(
                    children: _logTypes.map((item) {
                      final isSelected = selectedType == item.type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => selectedType = item.type);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 35,
                                color: isSelected
                                    ? item.color
                                    : Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // --- Form content ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildFormContent(
                      selectedType,
                      volumeUnit: volumeUnit,
                      weightUnit: weightUnit,
                      waterController: waterController,
                      weightController: weightController,
                      systolicController: systolicController,
                      diastolicController: diastolicController,
                      medicationController: medicationController,
                      selectedMood: selectedMood,
                      onMoodSelected: (mood) {
                        setState(() => selectedMood = mood);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // --- Save button ---
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final metadata = _buildMetadata(
                          selectedType,
                          volumeUnit: volumeUnit,
                          weightUnit: weightUnit,
                          waterController: waterController,
                          weightController: weightController,
                          systolicController: systolicController,
                          diastolicController: diastolicController,
                          medicationController: medicationController,
                          selectedMood: selectedMood,
                        );
                        if (metadata == null) return;
                        Navigator.of(context).pop((selectedType, metadata));
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result == null) return;
  final (type, metadata) = result;
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

Widget _buildFormContent(
  PregnancyLogType type, {
  required VolumeUnit volumeUnit,
  required WeightUnit weightUnit,
  required TextEditingController waterController,
  required TextEditingController weightController,
  required TextEditingController systolicController,
  required TextEditingController diastolicController,
  required TextEditingController medicationController,
  required MoodType? selectedMood,
  required ValueChanged<MoodType> onMoodSelected,
}) {
  return switch (type) {
    PregnancyLogType.waterIntake => TextField(
        controller: waterController,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration:
            InputDecoration(labelText: 'water (${volumeUnit.name})'),
      ),
    PregnancyLogType.weight => TextField(
        controller: weightController,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration:
            InputDecoration(labelText: 'weight (${weightUnit.name})'),
      ),
    PregnancyLogType.bloodPressure => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: systolicController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'systolic'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: diastolicController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'diastolic'),
          ),
        ],
      ),
    PregnancyLogType.medication => TextField(
        controller: medicationController,
        decoration:
            const InputDecoration(labelText: 'medication name'),
      ),
    PregnancyLogType.mood => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: MoodType.values.map((mood) {
          final isSelected = selectedMood == mood;
          return GestureDetector(
            onTap: () => onMoodSelected(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF84A59D).withValues(alpha: 0.25)
                    : const Color(0xFFF5F4F5),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFF84A59D), width: 1.5)
                    : null,
              ),
              child: Text(
                moodLabel(mood),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF84A59D)
                      : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    PregnancyLogType.kickCounter => const SizedBox.shrink(),
  };
}

Map<String, dynamic>? _buildMetadata(
  PregnancyLogType type, {
  required VolumeUnit volumeUnit,
  required WeightUnit weightUnit,
  required TextEditingController waterController,
  required TextEditingController weightController,
  required TextEditingController systolicController,
  required TextEditingController diastolicController,
  required TextEditingController medicationController,
  required MoodType? selectedMood,
}) {
  switch (type) {
    case PregnancyLogType.waterIntake:
      final amount = double.tryParse(waterController.text.trim());
      if (amount == null || amount <= 0) return null;
      final amountMl =
          volumeUnit == VolumeUnit.oz ? amount * 29.5735 : amount;
      return {'amount': amount, 'unit': volumeUnit.name, 'amountMl': amountMl};
    case PregnancyLogType.weight:
      final amount = double.tryParse(weightController.text.trim());
      if (amount == null || amount <= 0) return null;
      final weightKg =
          weightUnit == WeightUnit.lb ? amount * 0.453592 : amount;
      return {'amount': amount, 'unit': weightUnit.name, 'weightKg': weightKg};
    case PregnancyLogType.bloodPressure:
      final systolic = int.tryParse(systolicController.text.trim());
      final diastolic = int.tryParse(diastolicController.text.trim());
      if (systolic == null ||
          diastolic == null ||
          systolic <= 0 ||
          diastolic <= 0) {
        return null;
      }
      return {'systolic': systolic, 'diastolic': diastolic};
    case PregnancyLogType.medication:
      final name = medicationController.text.trim();
      if (name.isEmpty) return null;
      return {'name': name};
    case PregnancyLogType.mood:
      if (selectedMood == null) return null;
      return {'mood': selectedMood.name};
    case PregnancyLogType.kickCounter:
      return null;
  }
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
