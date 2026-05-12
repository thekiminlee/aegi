import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/data/models/baby_log.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:uuid/uuid.dart';

enum ArrivedEntryTab { feed, diaper, sleep }

const _entryTabs = [
  (tab: ArrivedEntryTab.feed, icon: Symbols.pediatrics_rounded, label: 'FEED'),
  (tab: ArrivedEntryTab.diaper, icon: Symbols.baby_changing_station, label: 'DIAPER'),
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
  final amountController = TextEditingController();
  final durationController = TextEditingController();
  final notesController = TextEditingController();

  var selectedTab = initialTab;
  var selectedDateTime = DateTime.now();

  // Subtypes
  String feedType = 'bottle'; // 'bottle' | 'breast'
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
                              'Any updates?',
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
                      onBreastSideChanged: (v) => setState(() => breastSide = v),
                      diaperType: diaperType,
                      onDiaperTypeChanged: (v) => setState(() => diaperType = v),
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
                    onChanged: (dt) =>
                        setState(() => selectedDateTime = dt),
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

  final logType = _resolveLogType(selectedTab, feedType: feedType, diaperType: diaperType, sleepType: sleepType);
  final metadata = _buildMetadata(
    selectedTab,
    feedType: feedType,
    diaperType: diaperType,
    sleepType: sleepType,
    amountController: amountController,
    durationController: durationController,
    notesController: notesController,
    breastSide: breastSide,
  );
  if (metadata == null) return;

  await ref.read(babyLogRepositoryProvider).addLog(
        BabyLog(
          id: const Uuid().v4(),
          childId: child.id,
          type: logType,
          timestamp: selectedDateTime,
          metadata: metadata,
          createdAt: selectedDateTime,
        ),
      );
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
    ArrivedEntryTab.feed => feedType == 'breast' ? BabyLogType.breastMilk : BabyLogType.bottleFeed,
    ArrivedEntryTab.diaper => diaperType == 'dirty' ? BabyLogType.diaperDirty : BabyLogType.diaperWet,
    ArrivedEntryTab.sleep => sleepType == 'night' ? BabyLogType.nightSleep : BabyLogType.nap,
  };
}

// ---------------------------------------------------------------------------
// Form builders
// ---------------------------------------------------------------------------

Widget _buildFormForTab(
  BuildContext context,
  ArrivedEntryTab tab, {
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
  required List<(String value, String label)> options,
  required String selected,
  required ValueChanged<String> onChanged,
}) {
  return Row(
    children: options.map((opt) {
      final isSelected = selected == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              opt.$2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ---------------------------------------------------------------------------
// Feed card (bottle / breast)
// ---------------------------------------------------------------------------

Widget _buildFeedCard({
  required BuildContext context,
  required String feedType,
  required ValueChanged<String> onFeedTypeChanged,
  required TextEditingController amountController,
  required TextEditingController durationController,
  required String? breastSide,
  required ValueChanged<String> onBreastSideChanged,
}) {
  return Container(
    padding: _cardPadding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FEED', style: _headerStyle),
        const SizedBox(height: 12),
        _subtypeSelector(
          options: [('bottle', 'Bottle'), ('breast', 'Breast')],
          selected: feedType,
          onChanged: onFeedTypeChanged,
        ),
        const SizedBox(height: 20),
        if (feedType == 'bottle') ...[
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: _valueInputStyle,
                      clipBehavior: Clip.antiAlias,
                      decoration: _valueDecoration,
                      hintText: '0',
                      hintStyle: _valueInputStyle.copyWith(color: Colors.grey[300]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text('oz', style: _unitStyle),
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
                      hintStyle: _valueInputStyle.copyWith(color: Colors.grey[300]),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Left', 'Right', 'Both'].map((side) {
              final val = side.toLowerCase();
              final isSelected = breastSide == val;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onBreastSideChanged(val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      side,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
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
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DIAPER', style: _headerStyle),
        const SizedBox(height: 12),
        _subtypeSelector(
          options: [('wet', 'Wet'), ('dirty', 'Dirty')],
          selected: diaperType,
          onChanged: onDiaperTypeChanged,
        ),
        const SizedBox(height: 16),
        _AutoHideHintField(
          controller: notesController,
          maxLines: 2,
          decoration: _valueDecoration.copyWith(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          hintText: 'Notes (optional)',
          hintStyle: TextStyle(color: Colors.grey[300], fontSize: 16, fontFamily: "Source Serif 4"),
          style: const TextStyle(fontSize: 16, fontFamily: "Source Serif 4"),
        ),
        const SizedBox(height: 8),
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
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(_cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SLEEP', style: _headerStyle),
        const SizedBox(height: 12),
        _subtypeSelector(
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
                    hintStyle: _valueInputStyle.copyWith(color: Colors.grey[300]),
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
    final formatted =
        DateFormat('EEE · h:mm a').format(dateTime).toUpperCase();

    final nowColor = const Color.fromARGB(255, 57, 57, 57);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
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
      if (feedType == 'bottle') {
        final amount = double.tryParse(amountController.text.trim());
        if (amount == null || amount <= 0) return null;
        return {'amountOz': amount};
      } else {
        final duration = int.tryParse(durationController.text.trim());
        if (duration == null || duration <= 0) return null;
        return {
          'durationMin': duration,
          if (breastSide case final side?) 'side': side,
        };
      }
    case ArrivedEntryTab.diaper:
      final notes = notesController.text.trim();
      return {
        'type': diaperType,
        if (notes.isNotEmpty) 'notes': notes,
      };
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
  // Determine tab + subtype from log type
  final (tab, feedType, diaperType, sleepType) = switch (log.type) {
    BabyLogType.bottleFeed => (ArrivedEntryTab.feed, 'bottle', 'wet', 'nap'),
    BabyLogType.breastMilk => (ArrivedEntryTab.feed, 'breast', 'wet', 'nap'),
    BabyLogType.diaperWet => (ArrivedEntryTab.diaper, 'bottle', 'wet', 'nap'),
    BabyLogType.diaperDirty => (ArrivedEntryTab.diaper, 'bottle', 'dirty', 'nap'),
    BabyLogType.nap => (ArrivedEntryTab.sleep, 'bottle', 'wet', 'nap'),
    BabyLogType.nightSleep => (ArrivedEntryTab.sleep, 'bottle', 'wet', 'night'),
  };

  // Pre-fill controllers from existing metadata
  final amountController = TextEditingController(
    text: log.metadata['amountOz'] != null
        ? (log.metadata['amountOz'] as num).toString()
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
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
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

                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EDIT ACTIVITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Update details',
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

                  // Form
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildFormForTab(
                      context,
                      currentTab,
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
                      onBreastSideChanged: (v) => setState(() => breastSide = v),
                      diaperType: currentDiaperType,
                      onDiaperTypeChanged: (v) => setState(() => currentDiaperType = v),
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

                  // Save / Delete buttons
                  Row(
                    children: [
                      // Delete
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('delete'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Save
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: context.appColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop('save'),
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
    feedType: currentFeedType,
    diaperType: currentDiaperType,
    sleepType: currentSleepType,
    amountController: amountController,
    durationController: durationController,
    notesController: notesController,
    breastSide: breastSide,
  );

  await ref.read(babyLogRepositoryProvider).updateLog(
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

/// Like _buildMetadata but allows empty values (for editing quick-logged entries)
Map<String, dynamic> _buildEditMetadata(
  ArrivedEntryTab tab, {
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
      if (feedType == 'bottle') {
        final amount = double.tryParse(amountController.text.trim());
        return {if (amount != null && amount > 0) 'amountOz': amount};
      } else {
        final duration = int.tryParse(durationController.text.trim());
        return {
          if (duration != null && duration > 0) 'durationMin': duration,
          if (breastSide case final side?) 'side': side,
        };
      }
    case ArrivedEntryTab.diaper:
      final notes = notesController.text.trim();
      return {
        'type': diaperType,
        if (notes.isNotEmpty) 'notes': notes,
      };
    case ArrivedEntryTab.sleep:
      final duration = int.tryParse(durationController.text.trim());
      return {
        if (duration != null && duration > 0) 'durationMin': duration,
        'type': sleepType,
      };
  }
}
