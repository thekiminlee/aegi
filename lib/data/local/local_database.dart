import 'dart:io';

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

@DriftDatabase(tables: [ChildProfiles, AppSettingsTable, AppMetaTable])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());
  LocalDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aegi.db'));
    return NativeDatabase(file);
  });
}
