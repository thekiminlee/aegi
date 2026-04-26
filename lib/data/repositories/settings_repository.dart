import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:drift/drift.dart';

abstract class SettingsRepository {
  Future<void> saveInitialSettings(AppSettings settings);
  Future<AppSettings?> getSettings();
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<void> saveInitialSettings(AppSettings settings) {
    return _database
        .into(_database.appSettingsTable)
        .insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            id: const Value(1),
            selectedChildId: settings.selectedChildId,
            volumeUnit: settings.volumeUnit.index,
            weightUnit: settings.weightUnit.index,
            lengthUnit: settings.lengthUnit.index,
            temperatureUnit: settings.temperatureUnit.index,
            notificationsEnabled: settings.notificationsEnabled,
            weeklyPregnancyReminderEnabled:
                settings.weeklyPregnancyReminderEnabled,
            trackingReminderEnabled: settings.trackingReminderEnabled,
          ),
        );
  }

  @override
  Future<AppSettings?> getSettings() async {
    final row = await (_database.select(
      _database.appSettingsTable,
    )..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    return AppSettings(
      selectedChildId: row.selectedChildId,
      volumeUnit: VolumeUnit.values[row.volumeUnit],
      weightUnit: WeightUnit.values[row.weightUnit],
      lengthUnit: LengthUnit.values[row.lengthUnit],
      temperatureUnit: TemperatureUnit.values[row.temperatureUnit],
      notificationsEnabled: row.notificationsEnabled,
      weeklyPregnancyReminderEnabled: row.weeklyPregnancyReminderEnabled,
      trackingReminderEnabled: row.trackingReminderEnabled,
    );
  }
}
