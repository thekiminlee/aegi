import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:uuid/uuid.dart';

enum ArrivedEntryTab { feed, diaper, sleep }

const _entryTabs = [
  (tab: ArrivedEntryTab.feed, icon: Symbols.pediatrics_rounded, label: 'FEED'),
  (
    tab: ArrivedEntryTab.diaper,
    icon: Symbols.nest_eco_leaf,
    label: 'DIAPER',
  ),
  (tab: ArrivedEntryTab.sleep, icon: Icons.bedtime_outlined, label: 'SLEEP'),
];

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

Future<void> showArrivedEntrySheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child, {
  ArrivedEntryTab initialTab = ArrivedEntryTab.feed,
}) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  _logArrivedEntryOpened(ref, _entryTypeForArrivedTab(initialTab));
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.oz;

  final amountController = TextEditingController();
  final durationController = TextEditingController();
  final notesController = TextEditingController();

  var selectedTab = initialTab;
  var selectedDateTime = DateTime.now();

  // Subtypes
  String feedType = 'formula'; // 'formula' | 'expressed' | 'breast'
  String? breastSide; // 'left' | 'right' | 'both'
  String diaperType = 'wet'; // 'wet' | 'dirty'
  String sleepType = 'nap'; // 'nap' | 'night'

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
                              'NEW ACTIVITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add activity',
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                const SizedBox(height: 5),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
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
                      amountController: amountController,
                      durationController: durationController,
                      notesController: notesController,
                      feedType: feedType,
                      onFeedTypeChanged: (v) => setState(() {
                        feedType = v;
                        amountController.clear();
                        durationController.clear();
                      }),
                      breastSide: breastSide,
                      onBreastSideChanged: (v) =>
                          setState(() => breastSide = v),
                      diaperType: diaperType,
                      onDiaperTypeChanged: (v) =>
                          setState(() => diaperType = v),
                      sleepType: sleepType,
                      onSleepTypeChanged: (v) => setState(() {
                        sleepType = v;
                        durationController.clear();
                      }),
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
                        final metadata = _buildMetadata(
                          selectedTab,
                          volumeUnit: volumeUnit,
                          feedType: feedType,
                          diaperType: diaperType,
                          sleepType: sleepType,
                          amountController: amountController,
                          durationController: durationController,
                          notesController: notesController,
                          breastSide: breastSide,
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

  final logType = _resolveLogType(
    selectedTab,
    feedType: feedType,
    diaperType: diaperType,
    sleepType: sleepType,
  );
  final metadata = _buildMetadata(
    selectedTab,
    volumeUnit: volumeUnit,
    feedType: feedType,
    diaperType: diaperType,
    sleepType: sleepType,
    amountController: amountController,
    durationController: durationController,
    notesController: notesController,
    breastSide: breastSide,
  );
  if (metadata == null) {
    _logArrivedEntrySaved(
      ref,
      entryType: _entryTypeForArrivedTab(selectedTab),
      result: 'validation_error',
    );
    return;
  }

  try {
    await ref
        .read(babyLogRepositoryProvider)
        .addLog(
          BabyLog(
            id: const Uuid().v4(),
            childId: child.id,
            type: logType,
            timestamp: selectedDateTime,
            metadata: metadata,
            createdAt: selectedDateTime,
          ),
        );
    _logArrivedEntrySaved(
      ref,
      entryType: _entryTypeForArrivedTab(selectedTab),
      result: 'success',
    );
  } catch (_) {
    _logArrivedEntrySaved(
      ref,
      entryType: _entryTypeForArrivedTab(selectedTab),
      result: 'storage_error',
    );
    rethrow;
  }
}

// ---------------------------------------------------------------------------
// Journal entry sheet (arrived mode)
// ---------------------------------------------------------------------------

Future<void> showJournalEntrySheet(
  BuildContext context,
  WidgetRef ref,
  ChildProfile child,
) async {
  _logArrivedEntryOpened(ref, 'journal');
  final bodyController = TextEditingController();
  final tagsController = TextEditingController();
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
                              'NEW JOURNAL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Leave a memory',
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

                  // --- Journal form ---
                  Container(
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
                        _AutoHideHintField(
                          controller: bodyController,
                          maxLines: 3,
                          decoration: _valueDecoration.copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          hintText: 'What do you want to remember?',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: "Source Serif 4",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Source Serif 4",
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AutoHideHintField(
                          controller: tagsController,
                          decoration: _valueDecoration.copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 12,
                            ),
                          ),
                          hintText: 'Tags (comma separated)',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: "Source Serif 4",
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Source Serif 4",
                          ),
                        ),
                      ],
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
                      onPressed: () => Navigator.of(context).pop(true),
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

  final body = bodyController.text.trim();
  if (body.isEmpty) return;

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
    _logArrivedEntrySaved(ref, entryType: 'journal', result: 'success');
  } catch (_) {
    _logArrivedEntrySaved(ref, entryType: 'journal', result: 'storage_error');
    rethrow;
  }
}

// ---------------------------------------------------------------------------
// Resolve log type from tab + subtype
// ---------------------------------------------------------------------------

BabyLogType _resolveLogType(
  ArrivedEntryTab tab, {
  required String feedType,
  required String diaperType,
  required String sleepType,
}) {
  return switch (tab) {
    ArrivedEntryTab.feed =>
      feedType == 'breast' ? BabyLogType.breastMilk : BabyLogType.bottleFeed,
    ArrivedEntryTab.diaper =>
      diaperType == 'dirty' ? BabyLogType.diaperDirty : BabyLogType.diaperWet,
    ArrivedEntryTab.sleep =>
      sleepType == 'night' ? BabyLogType.nightSleep : BabyLogType.nap,
  };
}

// ---------------------------------------------------------------------------
// Form builders
// ---------------------------------------------------------------------------

Widget _buildFormForTab(
  BuildContext context,
  ArrivedEntryTab tab, {
  required VolumeUnit volumeUnit,
  required TextEditingController amountController,
  required TextEditingController durationController,
  required TextEditingController notesController,
  required String feedType,
  required ValueChanged<String> onFeedTypeChanged,
  required String? breastSide,
  required ValueChanged<String> onBreastSideChanged,
  required String diaperType,
  required ValueChanged<String> onDiaperTypeChanged,
  required String sleepType,
  required ValueChanged<String> onSleepTypeChanged,
}) {
  return switch (tab) {
    ArrivedEntryTab.feed => _buildFeedCard(
      context: context,
      volumeUnit: volumeUnit,
      feedType: feedType,
      onFeedTypeChanged: onFeedTypeChanged,
      amountController: amountController,
      durationController: durationController,
      breastSide: breastSide,
      onBreastSideChanged: onBreastSideChanged,
    ),
    ArrivedEntryTab.diaper => _buildDiaperCard(
      context: context,
      diaperType: diaperType,
      onDiaperTypeChanged: onDiaperTypeChanged,
      notesController: notesController,
    ),
    ArrivedEntryTab.sleep => _buildSleepCard(
      context: context,
      sleepType: sleepType,
      onSleepTypeChanged: onSleepTypeChanged,
      durationController: durationController,
    ),
  };
}

// ---------------------------------------------------------------------------
// Subtype pill selector
// ---------------------------------------------------------------------------

Widget _subtypeSelector({
  required BuildContext context,
  required List<(String value, String label)> options,
  required String selected,
  required ValueChanged<String> onChanged,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: options.map((opt) {
      final isSelected = selected == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? context.appColors.selectedAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? context.appColors.selectedAccent : Colors.grey[300]!,
              ),
            ),
            child: Text(
              opt.$2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? context.appColors.white : Colors.grey[400],
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ---------------------------------------------------------------------------
// Feed card (formula / expressed / breast)
// ---------------------------------------------------------------------------

Widget _buildFeedCard({
  required BuildContext context,
  required VolumeUnit volumeUnit,
  required String feedType,
  required ValueChanged<String> onFeedTypeChanged,
  required TextEditingController amountController,
  required TextEditingController durationController,
  required String? breastSide,
  required ValueChanged<String> onBreastSideChanged,
}) {
  final unitLabel = volumeUnit == VolumeUnit.oz ? 'oz' : 'ml';
  return Container(
    padding: _cardPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtypeSelector(
            context: context,
            options: [
              ('formula', 'Formula'),
              ('expressed', 'Expressed'),
              ('breast', 'Breast Feed'),
            ],
            selected: feedType,
            onChanged: onFeedTypeChanged,
          ),
        const SizedBox(height: 20),
        if (feedType != 'breast') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48),
                    child: _AutoHideHintField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: _valueInputStyle,
                      clipBehavior: Clip.antiAlias,
                      decoration: _valueDecoration,
                      hintText: '0',
                      hintStyle: _valueInputStyle.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(unitLabel, style: _unitStyle),
              ),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48),
                    child: _AutoHideHintField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: _valueInputStyle,
                      clipBehavior: Clip.antiAlias,
                      decoration: _valueDecoration,
                      hintText: '0',
                      hintStyle: _valueInputStyle.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text('min', style: _unitStyle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ['Left', 'Right', 'Both'].map((side) {
              final val = side.toLowerCase();
              final isSelected = breastSide == val;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onBreastSideChanged(val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? context.appColors.selectedAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? context.appColors.selectedAccent : Colors.grey[300]!,
                      )
                    ),
                    child: Text(
                      side,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Diaper card (wet / dirty)
// ---------------------------------------------------------------------------

Widget _buildDiaperCard({
  required BuildContext context,
  required String diaperType,
  required ValueChanged<String> onDiaperTypeChanged,
  required TextEditingController notesController,
}) {
  return Container(
    padding: _cardPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtypeSelector(
          context: context,
          options: [('wet', 'Wet'), ('dirty', 'Dirty')],
          selected: diaperType,
          onChanged: onDiaperTypeChanged,
        ),
        const SizedBox(height: 20),
        _AutoHideHintField(
          controller: notesController,
          maxLines: 1,
          decoration: _valueDecoration.copyWith(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          hintText: 'Notes (optional)',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontFamily: "Source Serif 4",
          ),
          style: const TextStyle(fontSize: 14, fontFamily: "Source Serif 4"),
        ),
        const SizedBox(height: 7),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Sleep card (nap / night)
// ---------------------------------------------------------------------------

Widget _buildSleepCard({
  required BuildContext context,
  required String sleepType,
  required ValueChanged<String> onSleepTypeChanged,
  required TextEditingController durationController,
}) {
  return Container(
    padding: _cardPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtypeSelector(
          context: context,
          options: [('nap', 'Nap'), ('night', 'Night')],
          selected: sleepType,
          onChanged: onSleepTypeChanged,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48),
                  child: _AutoHideHintField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: _valueInputStyle,
                    clipBehavior: Clip.antiAlias,
                    decoration: _valueDecoration,
                    hintText: '0',
                    hintStyle: _valueInputStyle.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Text('min', style: _unitStyle),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(DateTime.now()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _isNow ? context.appColors.black : Colors.grey[300],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _isNow ? context.appColors.black : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
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
  ArrivedEntryTab tab, {
  required VolumeUnit volumeUnit,
  required String feedType,
  required String diaperType,
  required String sleepType,
  required TextEditingController amountController,
  required TextEditingController durationController,
  required TextEditingController notesController,
  required String? breastSide,
}) {
  switch (tab) {
    case ArrivedEntryTab.feed:
      if (feedType != 'breast') {
        final amount = double.tryParse(amountController.text.trim());
        if (amount == null || amount <= 0) return null;
        return {'amount': amount, 'feedKind': feedType};
      } else {
        final duration = int.tryParse(durationController.text.trim());
        if (duration == null || duration <= 0) return null;
        final metadata = <String, dynamic>{'durationMin': duration};
        if (breastSide != null) metadata['side'] = breastSide;
        return metadata;
      }
    case ArrivedEntryTab.diaper:
      final notes = notesController.text.trim();
      return {'type': diaperType, if (notes.isNotEmpty) 'notes': notes};
    case ArrivedEntryTab.sleep:
      final duration = int.tryParse(durationController.text.trim());
      if (duration == null || duration <= 0) return null;
      return {'durationMin': duration, 'type': sleepType};
  }
}

// ---------------------------------------------------------------------------
// Edit baby log sheet
// ---------------------------------------------------------------------------

Future<void> showEditBabyLogSheet(
  BuildContext context,
  WidgetRef ref,
  BabyLog log,
) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.oz;

  // Determine tab + subtype from log type
  final (tab, feedType, diaperType, sleepType) = switch (log.type) {
    BabyLogType.bottleFeed => (
      ArrivedEntryTab.feed,
      (log.metadata['feedKind'] as String?) == 'expressed'
          ? 'expressed'
          : 'formula',
      'wet',
      'nap',
    ),
    BabyLogType.breastMilk => (ArrivedEntryTab.feed, 'breast', 'wet', 'nap'),
    BabyLogType.diaperWet => (ArrivedEntryTab.diaper, 'formula', 'wet', 'nap'),
    BabyLogType.diaperDirty => (
      ArrivedEntryTab.diaper,
      'formula',
      'dirty',
      'nap',
    ),
    BabyLogType.nap => (ArrivedEntryTab.sleep, 'formula', 'wet', 'nap'),
    BabyLogType.nightSleep => (
      ArrivedEntryTab.sleep,
      'formula',
      'wet',
      'night',
    ),
  };

  // Pre-fill controllers from existing metadata — read the value matching current unit
  final amountValue = (log.metadata['displayAmount'] as num?);
  final amountController = TextEditingController(
    text: amountValue != null
        ? (amountValue % 1 == 0
              ? amountValue.toInt().toString()
              : amountValue.toStringAsFixed(1))
        : '',
  );
  final durationController = TextEditingController(
    text: log.metadata['durationMin'] != null
        ? (log.metadata['durationMin'] as num).toString()
        : '',
  );
  final notesController = TextEditingController(
    text: (log.metadata['notes'] as String?) ?? '',
  );

  var currentTab = tab;
  var currentFeedType = feedType;
  var currentDiaperType = diaperType;
  var currentSleepType = sleepType;
  String? breastSide = log.metadata['side'] as String?;
  var selectedDateTime = log.timestamp;

  final result = await showModalBottomSheet<String>(
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
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Symbols.arrow_back,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('delete'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: context.appColors.outline
                            )
                          ),
                          child: Icon(
                            Symbols.delete,
                            size: 20,
                            color: context.appColors.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('save'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.appColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Symbols.check,
                            size: 20,
                            color: context.appColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tab selector
                  Row(
                    children: _entryTabs.map((item) {
                      final isSelected = currentTab == item.tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => currentTab = item.tab);
                          },
                          child: SizedBox(
                            child: Column(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 30,
                                  color: isSelected
                                      ? context.appColors.accent
                                      : Colors.grey[500],
                                ),
                                Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? context.appColors.accent
                                        : Colors.grey[500],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildFormForTab(
                      context,
                      currentTab,
                      volumeUnit: volumeUnit,
                      amountController: amountController,
                      durationController: durationController,
                      notesController: notesController,
                      feedType: currentFeedType,
                      onFeedTypeChanged: (v) => setState(() {
                        currentFeedType = v;
                        amountController.clear();
                        durationController.clear();
                      }),
                      breastSide: breastSide,
                      onBreastSideChanged: (v) =>
                          setState(() => breastSide = v),
                      diaperType: currentDiaperType,
                      onDiaperTypeChanged: (v) =>
                          setState(() => currentDiaperType = v),
                      sleepType: currentSleepType,
                      onSleepTypeChanged: (v) => setState(() {
                        currentSleepType = v;
                        durationController.clear();
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date/time
                  _DateTimeRow(
                    dateTime: selectedDateTime,
                    onChanged: (dt) => setState(() => selectedDateTime = dt),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result == null) return;

  if (result == 'delete') {
    _logArrivedEntryDeleted(ref, _entryTypeForLogType(log.type));
    await ref.read(babyLogRepositoryProvider).deleteLog(log.id);
    return;
  }

  // Save — build updated log
  final logType = _resolveLogType(
    currentTab,
    feedType: currentFeedType,
    diaperType: currentDiaperType,
    sleepType: currentSleepType,
  );
  final metadata = _buildEditMetadata(
    currentTab,
    volumeUnit: volumeUnit,
    feedType: currentFeedType,
    diaperType: currentDiaperType,
    sleepType: currentSleepType,
    amountController: amountController,
    durationController: durationController,
    notesController: notesController,
    breastSide: breastSide,
  );

  await ref
      .read(babyLogRepositoryProvider)
      .updateLog(
        BabyLog(
          id: log.id,
          childId: log.childId,
          type: logType,
          timestamp: selectedDateTime,
          metadata: metadata,
          createdAt: log.createdAt,
        ),
      );
}

// ---------------------------------------------------------------------------
// Add baby log sheet (edit-modal design, creates new entry)
// ---------------------------------------------------------------------------

Future<void> showAddBabyLogSheet(
  BuildContext context,
  WidgetRef ref,
  String childId, {
  ArrivedEntryTab initialTab = ArrivedEntryTab.feed,
}) async {
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  if (!context.mounted) return;
  _logArrivedEntryOpened(ref, _entryTypeForArrivedTab(initialTab));
  final volumeUnit = settings?.volumeUnit ?? VolumeUnit.oz;

  final amountController = TextEditingController();
  final durationController = TextEditingController();
  final notesController = TextEditingController();

  var currentTab = initialTab;
  String feedType = 'formula';
  String? breastSide;
  String diaperType = 'wet';
  String sleepType = 'nap';
  var selectedDateTime = DateTime.now();

  final result = await showModalBottomSheet<String>(
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
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Symbols.arrow_back,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('save'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.appColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Symbols.check,
                            size: 20,
                            color: context.appColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tab selector
                  Row(
                    children: _entryTabs.map((item) {
                      final isSelected = currentTab == item.tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => currentTab = item.tab);
                          },
                          child: SizedBox(
                            child: Column(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 30,
                                  color: isSelected
                                      ? context.appColors.accent
                                      : Colors.grey[500],
                                ),
                                Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? context.appColors.accent
                                        : Colors.grey[500],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildFormForTab(
                      context,
                      currentTab,
                      volumeUnit: volumeUnit,
                      amountController: amountController,
                      durationController: durationController,
                      notesController: notesController,
                      feedType: feedType,
                      onFeedTypeChanged: (v) => setState(() {
                        feedType = v;
                        amountController.clear();
                        durationController.clear();
                      }),
                      breastSide: breastSide,
                      onBreastSideChanged: (v) =>
                          setState(() => breastSide = v),
                      diaperType: diaperType,
                      onDiaperTypeChanged: (v) =>
                          setState(() => diaperType = v),
                      sleepType: sleepType,
                      onSleepTypeChanged: (v) => setState(() {
                        sleepType = v;
                        durationController.clear();
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date/time
                  _DateTimeRow(
                    dateTime: selectedDateTime,
                    onChanged: (dt) => setState(() => selectedDateTime = dt),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result != 'save') return;

  final logType = _resolveLogType(
    currentTab,
    feedType: feedType,
    diaperType: diaperType,
    sleepType: sleepType,
  );
  final metadata = _buildEditMetadata(
    currentTab,
    volumeUnit: volumeUnit,
    feedType: feedType,
    diaperType: diaperType,
    sleepType: sleepType,
    amountController: amountController,
    durationController: durationController,
    notesController: notesController,
    breastSide: breastSide,
  );

  try {
    await ref
        .read(babyLogRepositoryProvider)
        .addLog(
          BabyLog(
            id: const Uuid().v4(),
            childId: childId,
            type: logType,
            timestamp: selectedDateTime,
            metadata: metadata,
            createdAt: selectedDateTime,
          ),
        );
    _logArrivedEntrySaved(
      ref,
      entryType: _entryTypeForArrivedTab(currentTab),
      result: 'success',
    );
  } catch (_) {
    _logArrivedEntrySaved(
      ref,
      entryType: _entryTypeForArrivedTab(currentTab),
      result: 'storage_error',
    );
    rethrow;
  }
}

String _entryTypeForArrivedTab(ArrivedEntryTab tab) => switch (tab) {
  ArrivedEntryTab.feed => AnalyticsEntryType.feed,
  ArrivedEntryTab.diaper => AnalyticsEntryType.diaper,
  ArrivedEntryTab.sleep => AnalyticsEntryType.sleep,
};

String _entryTypeForLogType(BabyLogType type) => switch (type) {
  BabyLogType.bottleFeed => AnalyticsEntryType.feed,
  BabyLogType.breastMilk => AnalyticsEntryType.feed,
  BabyLogType.diaperWet => AnalyticsEntryType.diaper,
  BabyLogType.diaperDirty => AnalyticsEntryType.diaper,
  BabyLogType.nap => AnalyticsEntryType.sleep,
  BabyLogType.nightSleep => AnalyticsEntryType.sleep,
};

void _logArrivedEntryOpened(WidgetRef ref, String entryType) {
  ref
      .read(analyticsServiceProvider)
      .logEntryOpened(
        mode: AnalyticsMode.arrived,
        entryFamily: AnalyticsEntryFamily.baby,
        entryType: entryType,
      );
}

void _logArrivedEntrySaved(
  WidgetRef ref, {
  required String entryType,
  required String result,
}) {
  ref
      .read(analyticsServiceProvider)
      .logEntrySaved(
        mode: AnalyticsMode.arrived,
        entryFamily: AnalyticsEntryFamily.baby,
        entryType: entryType,
        result: result,
      );
}

void _logArrivedEntryDeleted(WidgetRef ref, String entryType) {
  ref
      .read(analyticsServiceProvider)
      .logEntryDeleted(
        mode: AnalyticsMode.arrived,
        entryFamily: AnalyticsEntryFamily.baby,
        entryType: entryType,
      );
}

/// Like _buildMetadata but allows empty values (for editing quick-logged entries)
Map<String, dynamic> _buildEditMetadata(
  ArrivedEntryTab tab, {
  required VolumeUnit volumeUnit,
  required String feedType,
  required String diaperType,
  required String sleepType,
  required TextEditingController amountController,
  required TextEditingController durationController,
  required TextEditingController notesController,
  required String? breastSide,
}) {
  switch (tab) {
    case ArrivedEntryTab.feed:
      if (feedType != 'breast') {
        final amount = double.tryParse(amountController.text.trim());
        if (amount != null && amount > 0) {
          return {'amount': amount, 'feedKind': feedType};
        }
        return {'feedKind': feedType};
      } else {
        final duration = int.tryParse(durationController.text.trim());
        final metadata = <String, dynamic>{};
        if (duration != null && duration > 0) {
          metadata['durationMin'] = duration;
        }
        if (breastSide != null) metadata['side'] = breastSide;
        return metadata;
      }
    case ArrivedEntryTab.diaper:
      final notes = notesController.text.trim();
      return {'type': diaperType, if (notes.isNotEmpty) 'notes': notes};
    case ArrivedEntryTab.sleep:
      final duration = int.tryParse(durationController.text.trim());
      return {
        if (duration != null && duration > 0) 'durationMin': duration,
        'type': sleepType,
      };
  }
}
