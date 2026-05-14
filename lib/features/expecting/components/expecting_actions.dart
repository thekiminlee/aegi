import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/mood_type.dart';
import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:aegi/features/expecting/components/expecting_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum EntryTab { water, weight, bp, med, mood, journal }

const _entryTabs = [
  (tab: EntryTab.water, icon: Icons.water_drop_outlined, label: 'WTR'),
  (tab: EntryTab.weight, icon: Icons.monitor_weight_outlined, label: 'WGT'),
  (tab: EntryTab.bp, icon: Icons.favorite_outline, label: 'BP'),
  (tab: EntryTab.med, icon: Icons.medication_outlined, label: 'MED'),
  (tab: EntryTab.mood, icon: Icons.mood_outlined, label: 'MOOD'),
  (tab: EntryTab.journal, icon: Icons.book_outlined, label: 'JRNL'),
];

PregnancyLogType? _tabToLogType(EntryTab tab) => switch (tab) {
  EntryTab.water => PregnancyLogType.waterIntake,
  EntryTab.weight => PregnancyLogType.weight,
  EntryTab.bp => PregnancyLogType.bloodPressure,
  EntryTab.med => PregnancyLogType.medication,
  EntryTab.mood => PregnancyLogType.mood,
  EntryTab.journal => null,
};

// ---------------------------------------------------------------------------
// Shared card styles
// ---------------------------------------------------------------------------

const _cardColor = Colors.white;
const _cardRadius = 20.0;
const _cardPadding = EdgeInsets.all(20);

final _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.0,
  color: Colors.grey[500],
);

const _valueInputStyle = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.w200,
  height: 1,
  letterSpacing: -1,
);

final _unitStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.grey[500],
);

const _valueDecoration = InputDecoration(
  border: InputBorder.none,
  fillColor: Colors.transparent,
  isDense: true,
  contentPadding: EdgeInsets.zero,
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
);

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

Future<void> showUnifiedEntrySheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child, {
  EntryTab initialTab = EntryTab.water,
}) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  _logExpectingEntryOpened(ref, _entryTypeForTab(initialTab));
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.ml;
  final weightUnit = settings?.weightUnit ?? WeightUnit.kg;

  final waterController = TextEditingController();
  final weightController = TextEditingController();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final medicationController = TextEditingController();
  final bodyController = TextEditingController();
  final tagsController = TextEditingController();

  var selectedTab = initialTab;
  MoodType? selectedMood;
  var selectedDateTime = DateTime.now();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[100],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Drag handle ---
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Header ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEW ENTRY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add to your log',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Source Serif 4",
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Tab selector ---
                  Row(
                    children: _entryTabs.map((item) {
                      final isSelected = selectedTab == item.tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => selectedTab = item.tab);
                          },
                          child: Container(
                            width: 48,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.appColors.accent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[500],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // --- Form content ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildFormForTab(
                      context,
                      selectedTab,
                      volumeUnit: volumeUnit,
                      weightUnit: weightUnit,
                      waterController: waterController,
                      weightController: weightController,
                      systolicController: systolicController,
                      diastolicController: diastolicController,
                      medicationController: medicationController,
                      selectedMood: selectedMood,
                      onMoodSelected: (mood) =>
                          setState(() => selectedMood = mood),
                      bodyController: bodyController,
                      tagsController: tagsController,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Date/time picker ---
                  _DateTimeRow(
                    dateTime: selectedDateTime,
                    onChanged: (dt) => setState(() => selectedDateTime = dt),
                  ),
                  const SizedBox(height: 16),

                  // --- Save button ---
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.appColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (selectedTab == EntryTab.journal) {
                          Navigator.of(context).pop(true);
                          return;
                        }
                        final logType = _tabToLogType(selectedTab);
                        if (logType == null) return;
                        final metadata = _buildMetadata(
                          logType,
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
                        Navigator.of(context).pop(true);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  if (saved != true) return;

  if (selectedTab == EntryTab.journal) {
    final body = bodyController.text.trim();
    final tags = tagsController.text
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
              childId: child.id,
              timestamp: selectedDateTime,
              body: body,
              tags: tags,
              createdAt: selectedDateTime,
              updatedAt: selectedDateTime,
            ),
          );
      _logExpectingEntrySaved(ref, entryType: 'journal', result: 'success');
    } catch (_) {
      _logExpectingEntrySaved(
        ref,
        entryType: 'journal',
        result: 'storage_error',
      );
      rethrow;
    }
  } else {
    final logType = _tabToLogType(selectedTab)!;
    final metadata = _buildMetadata(
      logType,
      volumeUnit: volumeUnit,
      weightUnit: weightUnit,
      waterController: waterController,
      weightController: weightController,
      systolicController: systolicController,
      diastolicController: diastolicController,
      medicationController: medicationController,
      selectedMood: selectedMood,
    );
    if (metadata == null) {
      _logExpectingEntrySaved(
        ref,
        entryType: _entryTypeForTab(selectedTab),
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
              childId: child.id,
              type: logType,
              timestamp: selectedDateTime,
              metadata: metadata,
              createdAt: selectedDateTime,
            ),
          );
      _logExpectingEntrySaved(
        ref,
        entryType: _entryTypeForTab(selectedTab),
        result: 'success',
      );
    } catch (_) {
      _logExpectingEntrySaved(
        ref,
        entryType: _entryTypeForTab(selectedTab),
        result: 'storage_error',
      );
      rethrow;
    }
  }
}

void _logExpectingEntryOpened(WidgetRef ref, String entryType) {
  ref.read(analyticsServiceProvider).logEntryOpened(
    mode: AnalyticsMode.expecting,
    entryFamily: AnalyticsEntryFamily.pregnancy,
    entryType: entryType,
  );
}

void _logExpectingEntrySaved(
  WidgetRef ref, {
  required String entryType,
  required String result,
}) {
  ref.read(analyticsServiceProvider).logEntrySaved(
    mode: AnalyticsMode.expecting,
    entryFamily: AnalyticsEntryFamily.pregnancy,
    entryType: entryType,
    result: result,
  );
}

String _entryTypeForTab(EntryTab tab) => switch (tab) {
  EntryTab.water => AnalyticsEntryType.water,
  EntryTab.weight => AnalyticsEntryType.weight,
  EntryTab.bp => AnalyticsEntryType.bloodPressure,
  EntryTab.med => AnalyticsEntryType.medication,
  EntryTab.mood => AnalyticsEntryType.mood,
  EntryTab.journal => AnalyticsEntryType.journal,
};

// ---------------------------------------------------------------------------
// Form builders
// ---------------------------------------------------------------------------

Widget _buildFormForTab(
  BuildContext context,
  EntryTab tab, {
  required VolumeUnit volumeUnit,
  required WeightUnit weightUnit,
  required TextEditingController waterController,
  required TextEditingController weightController,
  required TextEditingController systolicController,
  required TextEditingController diastolicController,
  required TextEditingController medicationController,
  required MoodType? selectedMood,
  required ValueChanged<MoodType> onMoodSelected,
  required TextEditingController bodyController,
  required TextEditingController tagsController,
}) {
  return switch (tab) {
    EntryTab.water => _buildValueCard(
      label: 'WATER',
      unit: volumeUnit == VolumeUnit.oz ? 'OZ' : 'ML',
      controller: waterController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      hintText: '0',
    ),
    EntryTab.weight => _buildValueCard(
      label: 'WEIGHT',
      unit: weightUnit == WeightUnit.lb ? 'LB' : 'KG',
      controller: weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      hintText: '0',
    ),
    EntryTab.bp => _buildBPCard(
      systolicController: systolicController,
      diastolicController: diastolicController,
    ),
    EntryTab.med => _buildValueCard(
      label: 'MEDICATION',
      controller: medicationController,
      keyboardType: TextInputType.text,
      hintText: 'Medication',
      isText: true,
    ),
    EntryTab.mood => _buildMoodCard(
      context: context,
      selectedMood: selectedMood,
      onMoodSelected: onMoodSelected,
    ),
    EntryTab.journal => _buildJournalCard(
      bodyController: bodyController,
      tagsController: tagsController,
    ),
  };
}

/// Shared card for single-value inputs: water, weight, medication
Widget _buildValueCard({
  required String label,
  String? unit,
  required TextEditingController controller,
  required TextInputType keyboardType,
  required String hintText,
  bool isText = false,
}) {
  final unitSuffix = unit != null ? '  ·  $unit' : '';

  return Container(
    padding: _cardPadding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      children: [
        // Header
        Align(
          alignment: Alignment.centerLeft,
          child: Text('$label$unitSuffix', style: _headerStyle),
        ),
        const SizedBox(height: 20),
        // Large centered input
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48),
                  child: _AutoHideHintField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.center,
                    style: _valueInputStyle,
                    clipBehavior: Clip.antiAlias,
                    decoration: _valueDecoration,
                    hintText: hintText,
                    hintStyle:
                        (isText
                                ? const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w300,
                                    height: 1,
                                  )
                                : _valueInputStyle)
                            .copyWith(color: Colors.grey[300]),
                  ),
                ),
              ),
            ),
            if (unit != null && !isText)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(unit.toLowerCase(), style: _unitStyle),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

/// Blood pressure card: systolic / diastolic
Widget _buildBPCard({
  required TextEditingController systolicController,
  required TextEditingController diastolicController,
}) {
  return Container(
    padding: _cardPadding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('BLOOD PRESSURE  ·  MMHG', style: _headerStyle),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Systolic
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: _AutoHideHintField(
                  controller: systolicController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: _valueInputStyle,
                  decoration: _valueDecoration,
                  hintText: '120',
                  hintStyle: _valueInputStyle.copyWith(color: Colors.grey[300]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '/',
                style: _valueInputStyle.copyWith(color: Colors.grey[400]),
              ),
            ),
            // Diastolic
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: _AutoHideHintField(
                  controller: diastolicController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: _valueInputStyle,
                  decoration: _valueDecoration,
                  hintText: '80',
                  hintStyle: _valueInputStyle.copyWith(color: Colors.grey[300]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

void _showDialog(BuildContext context, Widget child) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      // The Bottom margin is provided to align the popup above the system navigation bar.
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // Provide a background color for the popup.
      color: CupertinoColors.systemBackground.resolveFrom(context),
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(top: false, child: child),
    ),
  );
}

/// Mood card: styled dropdown
Widget _buildMoodCard({
  required BuildContext context,
  required MoodType? selectedMood,
  required ValueChanged<MoodType> onMoodSelected,
}) {
  return Container(
    padding: _cardPadding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('MOOD', style: _headerStyle),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showDialog(
            context,
            CupertinoPicker(
              itemExtent: 40,
              onSelectedItemChanged: (selectedMood) {
                final MoodType mood = MoodType.values[selectedMood];
                onMoodSelected(mood);
              },
              children: MoodType.values.map((mood) {
                return Center(child: Text(moodLabel(mood)));
              }).toList(),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              selectedMood != null ? selectedMood.name : "Mood",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 29,
                color: selectedMood == null
                    ? Colors.grey[300]
                    : Colors.grey[800],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Journal card: body, tags
Widget _buildJournalCard({
  required TextEditingController bodyController,
  required TextEditingController tagsController,
}) {
  return Container(
    padding: _cardPadding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('JOURNAL', style: _headerStyle),
        ),
        const SizedBox(height: 16),
        _cardTextField(
          controller: bodyController,
          hintText: 'Leave a memory...',
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _cardTextField(
          controller: tagsController,
          hintText: 'Tags (comma separated)',
          // fontFamily: 'Inconsolata',
          // fontSize: 13,
        ),
      ],
    ),
  );
}

Widget _cardTextField({
  required TextEditingController controller,
  required String hintText,
  int maxLines = 1,
  String fontFamily = "Source Serif 4",
  double fontSize = 14,
}) {
  return _AutoHideHintField(
    controller: controller,
    maxLines: maxLines,
    decoration: _valueDecoration.copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
    ),
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: fontSize,
      fontFamily: fontFamily,
    ),
    style: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
  );
}

// ---------------------------------------------------------------------------
// Text field that hides hint on focus
// ---------------------------------------------------------------------------

class _AutoHideHintField extends StatefulWidget {
  const _AutoHideHintField({
    required this.controller,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.style,
    this.decoration = const InputDecoration(),
    this.hintText,
    this.hintStyle,
    this.maxLines = 1,
    this.clipBehavior = Clip.hardEdge,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextStyle? style;
  final InputDecoration decoration;
  final String? hintText;
  final TextStyle? hintStyle;
  final int maxLines;
  final Clip clipBehavior;

  @override
  State<_AutoHideHintField> createState() => _AutoHideHintFieldState();
}

class _AutoHideHintFieldState extends State<_AutoHideHintField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      style: widget.style,
      maxLines: widget.maxLines,
      clipBehavior: widget.clipBehavior,
      decoration: widget.decoration.copyWith(
        hintText: _hasFocus ? null : widget.hintText,
        hintStyle: widget.hintStyle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date/time picker row
// ---------------------------------------------------------------------------

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.dateTime, required this.onChanged});

  final DateTime dateTime;
  final ValueChanged<DateTime> onChanged;

  bool get _isNow => DateTime.now().difference(dateTime).inMinutes.abs() < 1;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('EEE · h:mm a').format(dateTime).toUpperCase();

    final nowColor = Color.fromARGB(255, 57, 57, 57);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // "Now" button
          GestureDetector(
            onTap: () => onChanged(DateTime.now()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isNow ? nowColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: _isNow
                    ? Border.all(color: nowColor)
                    : Border.all(color: const Color(0xFFE8E5E3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _isNow ? Colors.white : Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _isNow ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Tappable date/time display
          GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Text(
              formatted,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime picked = dateTime;
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
                    onChanged(picked);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: dateTime,
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
}

// ---------------------------------------------------------------------------
// Metadata builder
// ---------------------------------------------------------------------------

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
      return {'amount': amount};
    case PregnancyLogType.weight:
      final amount = double.tryParse(weightController.text.trim());
      if (amount == null || amount <= 0) return null;
      return {'amount': amount};
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
