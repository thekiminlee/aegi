import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

class ChildProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get gender => integer()();
  IntColumn get mode => integer()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get medicalProviderPhone => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get selectedChildId => text()();
  IntColumn get volumeUnit => integer()();
  IntColumn get weightUnit => integer()();
  IntColumn get lengthUnit => integer()();
  IntColumn get temperatureUnit => integer()();
  BoolColumn get notificationsEnabled => boolean()();
  BoolColumn get weeklyPregnancyReminderEnabled => boolean()();
  BoolColumn get trackingReminderEnabled => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppMetaTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class PregnancyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  IntColumn get type => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get metadataJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ContractionSessions extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ContractionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get intensity => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BabyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  IntColumn get type => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get metadataJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get body => text()();
  TextColumn get tagsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ChildProfiles,
    AppSettingsTable,
    AppMetaTable,
    PregnancyLogs,
    ContractionSessions,
    ContractionEntries,
    JournalEntries,
    BabyLogs,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());
  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(pregnancyLogs);
        await migrator.createTable(contractionSessions);
        await migrator.createTable(contractionEntries);
        await migrator.createTable(journalEntries);
      }
      if (from < 3) {
        await customStatement('ALTER TABLE journal_entries DROP COLUMN title');
      }
      if (from < 4) {
        await migrator.createTable(babyLogs);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aegi.db'));
    if (kDebugMode) {
      debugPrint('Aegi DB path: ${file.path}');
    }
    return NativeDatabase(file);
  });
}
