import 'dart:io';
import 'dart:convert';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/local/local_database.dart' as db;
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({required this.child, super.key});

  final ChildProfile child;

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await ref.read(settingsRepositoryProvider).getSettings();
    if (mounted && s != null) setState(() => _settings = s);
  }

  Future<void> _saveSettings(AppSettings updated) async {
    setState(() => _settings = updated);
    await ref.read(settingsRepositoryProvider).updateSettings(updated);
    ref.invalidate(appSettingsProvider);
  }

  // --- Child profile helpers ------------------------------------------------

  Future<void> _updateChild(ChildProfile updated) async {
    await ref.read(childRepositoryProvider).updateChild(updated);
    ref.invalidate(activeChildContextProvider);
  }

  ChildProfile _childWith({
    String? name,
    DateTime? dueDate,
    DateTime? birthDate,
    AppMode? mode,
    Gender? gender,
    String? medicalProviderPhone,
    bool clearMedicalProviderPhone = false,
  }) {
    return ChildProfile(
      id: widget.child.id,
      name: name ?? widget.child.name,
      gender: gender ?? widget.child.gender,
      mode: mode ?? widget.child.mode,
      dueDate: dueDate ?? widget.child.dueDate,
      birthDate: birthDate ?? widget.child.birthDate,
      medicalProviderPhone: clearMedicalProviderPhone
          ? null
          : (medicalProviderPhone ?? widget.child.medicalProviderPhone),
      createdAt: widget.child.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // --- Editing actions ------------------------------------------------------

  void _editName() {
    final controller = TextEditingController(text: widget.child.name);
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Baby Name'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Name',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                _updateChild(_childWith(name: text));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editDate({required bool isDueDate}) {
    final current = isDueDate ? widget.child.dueDate : widget.child.birthDate;
    var selected = current ?? DateTime.now();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isDueDate) {
                      _updateChild(_childWith(dueDate: selected));
                    } else {
                      _updateChild(_childWith(birthDate: selected));
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selected,
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2030),
                onDateTimeChanged: (dt) => selected = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Select Mode'),
        actions: AppMode.values.map((mode) {
          final label = mode.name[0].toUpperCase() + mode.name.substring(1);
          return CupertinoActionSheetAction(
            isDefaultAction: mode == widget.child.mode,
            onPressed: () async {
              Navigator.pop(context);
              if (mode == widget.child.mode) return;
              _updateChild(_childWith(mode: mode));
            },
            child: Text(label),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Select Gender'),
        actions: Gender.values.map((gender) {
          final label = switch (gender) {
            Gender.male => 'Male',
            Gender.female => 'Female',
            Gender.unspecified => 'Unspecified',
          };
          return CupertinoActionSheetAction(
            isDefaultAction: gender == widget.child.gender,
            onPressed: () {
              Navigator.pop(context);
              if (gender == widget.child.gender) return;
              _updateChild(_childWith(gender: gender));
            },
            child: Text(label),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _editMedicalProviderPhone() {
    final controller = TextEditingController(
      text: widget.child.medicalProviderPhone ?? '',
    );
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Medical Provider Phone'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Phone number',
            keyboardType: TextInputType.phone,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _updateChild(_childWith(clearMedicalProviderPhone: true));
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                _updateChild(_childWith(clearMedicalProviderPhone: true));
              } else {
                _updateChild(_childWith(medicalProviderPhone: text));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteChild() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Child Profile?'),
        content: Text(
          'This will remove ${widget.child.name} from active profiles. Existing logs stay stored.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final appMetaRepo = ref.read(appMetaRepositoryProvider);
    final children = await ref.read(childRepositoryProvider).watchAll().first;
    final deletedRaw = await appMetaRepo.getValue(deletedChildIdsKey);
    final deletedIds = <String>{};
    if (deletedRaw != null && deletedRaw.isNotEmpty) {
      final decoded = jsonDecode(deletedRaw);
      if (decoded is List) {
        deletedIds.addAll(decoded.whereType<String>());
      }
    }

    deletedIds.add(widget.child.id);
    await appMetaRepo.setValue(
      deletedChildIdsKey,
      jsonEncode(deletedIds.toList()),
    );

    final activeChildren =
        children.where((c) => !deletedIds.contains(c.id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (activeChildren.isEmpty) {
      await appMetaRepo.setOnboardingComplete(false);
      ref.invalidate(onboardingGateProvider);
      ref.invalidate(activeChildContextProvider);
      ref.invalidate(allChildrenProvider);
      if (!mounted) return;
      context.go('/onboarding');
      return;
    }

    await ref
        .read(settingsRepositoryProvider)
        .updateSelectedChildId(activeChildren.first.id);
    ref.invalidate(activeChildContextProvider);
    ref.invalidate(allChildrenProvider);
    if (!mounted) return;
    context.go('/home');
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final settings = _settings;
    final hasBirthDate = child.birthDate != null;

    return TabScaffold(
      children: [
        TabHeader(
          subheading: DateFormat.MMMd().format(DateTime.now()).toUpperCase(),
          heading: 'Settings',
        ),

        // --- Profile section ------------------------------------------------
        const SizedBox(height: 16),
        SectionHeader(label: 'Profile'),
        const SizedBox(height: 8),
        _SettingsTile(title: 'Baby Name', value: child.name, onTap: _editName),
        const SizedBox(height: 6),
        _SettingsTile(
          title: 'Due Date',
          value: child.dueDate != null
              ? DateFormat.yMMMd().format(child.dueDate!)
              : 'Not set',
          onTap: () => _editDate(isDueDate: true),
        ),
        const SizedBox(height: 6),
        if (hasBirthDate) ...[
          _SettingsTile(
            title: 'Birthday',
            value: child.birthDate != null
                ? DateFormat.yMMMd().format(child.birthDate!)
                : 'Not set',
            onTap: () => _editDate(isDueDate: false),
          ),
          const SizedBox(height: 6),
        ],
        _SettingsTile(
          title: 'Gender',
          value: switch (child.gender) {
            Gender.male => 'Boy',
            Gender.female => 'Girl',
            Gender.unspecified => 'Skip'
          },
          onTap: _showGenderPicker,
        ),
        const SizedBox(height: 6),
        _SettingsTile(
          title: 'Medical Provider Phone',
          value: child.medicalProviderPhone?.trim().isNotEmpty == true
              ? child.medicalProviderPhone!
              : 'Not set',
          onTap: _editMedicalProviderPhone,
        ),
        const SizedBox(height: 6),

        // --- Units section --------------------------------------------------
        if (settings != null) ...[
          const SizedBox(height: 16),
          SectionHeader(label: 'Units'),
          const SizedBox(height: 8),
          _UnitToggleTile(
            title: 'Volume',
            options: const ['ml', 'oz'],
            selectedIndex: settings.volumeUnit.index,
            onChanged: (i) => _saveSettings(
              AppSettings(
                selectedChildId: settings.selectedChildId,
                volumeUnit: VolumeUnit.values[i],
                weightUnit: settings.weightUnit,
                lengthUnit: settings.lengthUnit,
                temperatureUnit: settings.temperatureUnit,
                notificationsEnabled: settings.notificationsEnabled,
                weeklyPregnancyReminderEnabled:
                    settings.weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: settings.trackingReminderEnabled,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _UnitToggleTile(
            title: 'Weight',
            options: const ['kg', 'lb'],
            selectedIndex: settings.weightUnit.index,
            onChanged: (i) => _saveSettings(
              AppSettings(
                selectedChildId: settings.selectedChildId,
                volumeUnit: settings.volumeUnit,
                weightUnit: WeightUnit.values[i],
                lengthUnit: settings.lengthUnit,
                temperatureUnit: settings.temperatureUnit,
                notificationsEnabled: settings.notificationsEnabled,
                weeklyPregnancyReminderEnabled:
                    settings.weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: settings.trackingReminderEnabled,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _UnitToggleTile(
            title: 'Temperature',
            options: const ['\u00B0C', '\u00B0F'],
            selectedIndex: settings.temperatureUnit.index,
            onChanged: (i) => _saveSettings(
              AppSettings(
                selectedChildId: settings.selectedChildId,
                volumeUnit: settings.volumeUnit,
                weightUnit: settings.weightUnit,
                lengthUnit: settings.lengthUnit,
                temperatureUnit: TemperatureUnit.values[i],
                notificationsEnabled: settings.notificationsEnabled,
                weeklyPregnancyReminderEnabled:
                    settings.weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: settings.trackingReminderEnabled,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _UnitToggleTile(
            title: 'Length',
            options: const ['cm', 'in'],
            selectedIndex: settings.lengthUnit.index,
            onChanged: (i) => _saveSettings(
              AppSettings(
                selectedChildId: settings.selectedChildId,
                volumeUnit: settings.volumeUnit,
                weightUnit: settings.weightUnit,
                lengthUnit: LengthUnit.values[i],
                temperatureUnit: settings.temperatureUnit,
                notificationsEnabled: settings.notificationsEnabled,
                weeklyPregnancyReminderEnabled:
                    settings.weeklyPregnancyReminderEnabled,
                trackingReminderEnabled: settings.trackingReminderEnabled,
              ),
            ),
          ),
        ],

        const SizedBox(height: 120),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD64545),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _confirmDeleteChild,
            child: const Text(
              'Delete Child Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inconsolata',
              ),
            ),
          ),
        ),

        // --- Debug section --------------------------------------------------
        if (kDebugMode) ...[
          // --- Mode section ---------------------------------------------------
          const SizedBox(height: 16),
          _SettingsTile(
            title: 'Current Mode',
            value:
                child.mode.name[0].toUpperCase() + child.mode.name.substring(1),
            onTap: hasBirthDate ? _showModePicker : null,
            enabled: hasBirthDate,
          ),
          const SizedBox(height: 16),

          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.storage_outlined),
            title: const Text('DB Inspector'),
            subtitle: const Text('Debug only: path + row counts + recent rows'),
            onTap: () async {
              final database = ref.read(databaseProvider);
              await _showDbInspector(context, database);
            },
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings tile (tappable row with title + value + chevron)
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.value,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: Colors.white,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFamily: "Inconsolata",
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: "Inconsolata",
          fontStyle: FontStyle.italic,
          color: enabled ? null : Colors.grey[400],
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: enabled ? Colors.grey : Colors.grey[300],
            )
          : null,
      onTap: enabled ? onTap : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Unit toggle tile (row with title + segmented control)
// ---------------------------------------------------------------------------

class _UnitToggleTile extends StatelessWidget {
  const _UnitToggleTile({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "Inconsolata",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: selectedIndex,
            children: {
              for (int i = 0; i < options.length; i++)
                i: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    options[i],
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Inconsolata",
                    ),
                  ),
                ),
            },
            onValueChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DB Inspector (debug only, unchanged)
// ---------------------------------------------------------------------------

class _DbInspectData {
  const _DbInspectData({
    required this.path,
    required this.counts,
    required this.latestLogs,
    required this.latestJournal,
  });

  final String path;
  final Map<String, int> counts;
  final List<Map<String, Object?>> latestLogs;
  final List<Map<String, Object?>> latestJournal;
}

Future<void> _showDbInspector(
  BuildContext context,
  db.LocalDatabase database,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: FutureBuilder<_DbInspectData>(
          future: _loadDbInspectData(database),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Inspector failed: ${snapshot.error}'),
              );
            }

            final data = snapshot.data!;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Text(
                    'Database Path',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  SelectableText(data.path),
                  const SizedBox(height: 12),
                  Text(
                    'Row Counts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  ...data.counts.entries.map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Latest Pregnancy Logs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  if (data.latestLogs.isEmpty) const Text('(none)'),
                  ...data.latestLogs.map((row) => Text(row.toString())),
                  const SizedBox(height: 12),
                  Text(
                    'Latest Journal Entries',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  if (data.latestJournal.isEmpty) const Text('(none)'),
                  ...data.latestJournal.map((row) => Text(row.toString())),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<_DbInspectData> _loadDbInspectData(db.LocalDatabase database) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(docsDir.path, 'aegi.db');
  final file = File(dbPath);

  final counts = <String, int>{
    'child_profiles': await _count(database, 'child_profiles'),
    'app_settings_table': await _count(database, 'app_settings_table'),
    'app_meta_table': await _count(database, 'app_meta_table'),
    'pregnancy_logs': await _count(database, 'pregnancy_logs'),
    'contraction_sessions': await _count(database, 'contraction_sessions'),
    'contraction_entries': await _count(database, 'contraction_entries'),
    'journal_entries': await _count(database, 'journal_entries'),
  };

  final latestLogs = await _recentRows(
    database,
    'pregnancy_logs',
    orderBy: 'timestamp DESC',
    limit: 5,
  );
  final latestJournal = await _recentRows(
    database,
    'journal_entries',
    orderBy: 'timestamp DESC',
    limit: 5,
  );

  return _DbInspectData(
    path: file.path,
    counts: counts,
    latestLogs: latestLogs,
    latestJournal: latestJournal,
  );
}

Future<int> _count(db.LocalDatabase database, String table) async {
  final result = await database
      .customSelect('SELECT COUNT(*) AS c FROM $table')
      .getSingle();
  return result.read<int>('c');
}

Future<List<Map<String, Object?>>> _recentRows(
  db.LocalDatabase db,
  String table, {
  required String orderBy,
  int limit = 5,
}) async {
  final rows = await db
      .customSelect('SELECT * FROM $table ORDER BY $orderBy LIMIT $limit')
      .get();
  return rows.map((row) => row.data).toList();
}


// A4Cq5h3FhGWA6mW<