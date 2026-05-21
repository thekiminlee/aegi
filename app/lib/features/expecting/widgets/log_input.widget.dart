import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/mood_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_actions.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class LogInput extends ConsumerStatefulWidget {
  const LogInput({
    required this.child,
    required this.tab,
    required this.onClose,
    required this.onSaved,
    super.key,
  });

  final ChildProfile child;
  final EntryTab tab;
  final VoidCallback onClose;
  final VoidCallback onSaved;

  @override
  ConsumerState<LogInput> createState() => _LogInputState();
}

class _LogInputState extends ConsumerState<LogInput> {
  final _waterController = TextEditingController();
  final _weightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _medicationController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();

  MoodType? _selectedMood;
  DateTime _selectedDateTime = DateTime.now();
  VolumeUnit _volumeUnit = VolumeUnit.ml;
  WeightUnit _weightUnit = WeightUnit.kg;
  bool _saving = false;

  static const _inputStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static final _hintStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey[300],
  );

  static final _inputDecoration = InputDecoration(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    fillColor: Colors.transparent
  );

  @override
  void initState() {
    super.initState();
    _loadUnits();
    logExpectingEntryOpened(ref, entryTypeForTab(widget.tab));
  }

  Future<void> _loadUnits() async {
    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    if (!mounted) return;
    setState(() {
      _volumeUnit = settings?.volumeUnit ?? VolumeUnit.ml;
      _weightUnit = settings?.weightUnit ?? WeightUnit.kg;
    });
  }

  @override
  void dispose() {
    _waterController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _medicationController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (widget.tab == EntryTab.journal) {
        final body = _bodyController.text.trim();
        final tags = _tagsController.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
        try {
          await ref
              .read(journalRepositoryProvider)
              .addEntry(
                JournalEntryModel(
                  id: const Uuid().v4(),
                  childId: widget.child.id,
                  timestamp: _selectedDateTime,
                  body: body,
                  tags: tags,
                  createdAt: _selectedDateTime,
                  updatedAt: _selectedDateTime,
                ),
              );
          logExpectingEntrySaved(
            ref,
            entryType: 'journal',
            result: 'success',
          );
        } catch (_) {
          logExpectingEntrySaved(
            ref,
            entryType: 'journal',
            result: 'storage_error',
          );
          rethrow;
        }
      } else {
        final logType = tabToLogType(widget.tab);
        if (logType == null) return;
        final metadata = buildMetadata(
          logType,
          volumeUnit: _volumeUnit,
          weightUnit: _weightUnit,
          waterController: _waterController,
          weightController: _weightController,
          systolicController: _systolicController,
          diastolicController: _diastolicController,
          medicationController: _medicationController,
          selectedMood: _selectedMood,
        );
        if (metadata == null) {
          logExpectingEntrySaved(
            ref,
            entryType: entryTypeForTab(widget.tab),
            result: 'validation_error',
          );
          return;
        }
        try {
          await ref
              .read(pregnancyRepositoryProvider)
              .addLog(
                PregnancyLog(
                  id: const Uuid().v4(),
                  childId: widget.child.id,
                  type: logType,
                  timestamp: _selectedDateTime,
                  metadata: metadata,
                  createdAt: _selectedDateTime,
                ),
              );
          logExpectingEntrySaved(
            ref,
            entryType: entryTypeForTab(widget.tab),
            result: 'success',
          );
        } catch (_) {
          logExpectingEntrySaved(
            ref,
            entryType: entryTypeForTab(widget.tab),
            result: 'storage_error',
          );
          rethrow;
        }
      }
      if (!mounted) return;
      widget.onSaved();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime picked = _selectedDateTime;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: CupertinoColors.systemBackground.resolveFrom(context),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onPressed: () {
                    setState(() => _selectedDateTime = picked);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _selectedDateTime,
                minimumDate: DateTime(2020),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return switch (widget.tab) {
      EntryTab.water => Row(
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: _waterController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: _inputStyle,
              decoration: _inputDecoration.copyWith(
                hintText: '0',
                hintStyle: _hintStyle,
              ),
            ),
          ),
          Text(_volumeUnit == VolumeUnit.oz ? 'oz' : 'ml',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          )
        ],
      ),
      EntryTab.weight => Row(
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: _inputStyle,
              decoration: _inputDecoration.copyWith(
                hintText: '0',
                hintStyle: _hintStyle,
              ),
            ),
          ),
          Text(_weightUnit == WeightUnit.lb ? 'lb' : 'kg',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          )
        ],
      ),
      EntryTab.bp => Row(
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: _systolicController,
              keyboardType: TextInputType.number,
              style: _inputStyle,
              decoration: _inputDecoration.copyWith(
                hintText: '120',
                hintStyle: _hintStyle,
              ),
            ),
          ),
          Text(' / ', style: _inputStyle.copyWith(color: Colors.grey[400])),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _diastolicController,
              keyboardType: TextInputType.number,
              style: _inputStyle,
              decoration: _inputDecoration.copyWith(
                hintText: '80',
                hintStyle: _hintStyle,
              ),
            ),
          ),
          Text(' mmhg',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
      EntryTab.med => TextField(
        controller: _medicationController,
        keyboardType: TextInputType.text,
        style: _inputStyle,
        decoration: _inputDecoration.copyWith(
          hintText: 'Medication',
          hintStyle: _hintStyle,
        ),
      ),
      EntryTab.mood => GestureDetector(
        onTap: () => _showMoodPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _selectedMood != null ? moodLabel(_selectedMood!) : 'Mood',
            style: _inputStyle.copyWith(
              color: _selectedMood == null ? Colors.grey[300] : null,
            ),
          ),
        ),
      ),
      EntryTab.journal => TextField(
        controller: _bodyController,
        style: _inputStyle,
        decoration: _inputDecoration.copyWith(
          hintText: 'Leave a memory...',
          hintStyle: _hintStyle,
        ),
      ),
    };
  }

  void _showMoodPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              setState(() => _selectedMood = MoodType.values[index]);
            },
            children: MoodType.values.map((mood) {
              return Center(child: Text(moodLabel(mood)));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.transparent,
          border: Border.all(color: backgroundColor ?? context.appColors.outline),
        ),
        child: Icon(
          icon,
          size: 16,
          color: iconColor ?? context.appColors.outline,
        ),
      ),
    );
  }

  bool get _isNow =>
      DateTime.now().difference(_selectedDateTime).inMinutes.abs() < 1;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        _isNow ? 'Now' : DateFormat('h:mm a').format(_selectedDateTime);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: _buildInput()),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.appColors.black)
              ),
              child: Center(
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _circleButton(
            icon: Icons.check,
            onTap: _saving ? null : _save,
            backgroundColor: context.appColors.accent,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 6),
          _circleButton(
            icon: Icons.close,
            onTap: widget.onClose,
          ),
        ],
      ),
    );
  }
}
