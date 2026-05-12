import 'dart:io';

import 'package:aegi/app/providers.dart';
import 'package:aegi/core/widgets/tab_page_scaffold.dart';
import 'package:aegi/data/local/local_database.dart' as db;
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/features/expecting/components/expecting_common_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({required this.child, super.key});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabScaffold(
      children: [
        TabHeader(subheading: DateFormat.MMMd().format(DateTime.now()).toUpperCase(), heading: "Settings"),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: Colors.white,
          title: const Text('Baby Name'),
          subtitle: Text(child.name),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: Colors.white,
          title: const Text('Mode'),
          subtitle: const Text('Expecting'),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: Colors.white,
          title: const Text('Due Date'),
          subtitle: Text(
            child.dueDate == null
                ? 'Not set'
                : DateFormat.yMMMd().format(child.dueDate!),
          ),
        ),
        if (kDebugMode) ...[
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
              final db = ref.read(databaseProvider);
              await _showDbInspector(context, db);
            },
          ),
        ],
      ],
    );
  }
}

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
