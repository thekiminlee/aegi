import 'dart:convert';

import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/core/unit_conversions.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/pregnancy_log.dart' as model;
import 'package:drift/drift.dart';

abstract class PregnancyRepository {
  Stream<List<model.PregnancyLog>> watchLogsForChild(String childId);
  Future<void> addLog(model.PregnancyLog log);
}

class DriftPregnancyRepository implements PregnancyRepository {
  DriftPregnancyRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<void> addLog(model.PregnancyLog log) async {
    final settings = await _readSettings();
    await _database
        .into(_database.pregnancyLogs)
        .insert(
          PregnancyLogsCompanion.insert(
            id: log.id,
            childId: log.childId,
            type: log.type.storedValue,
            timestamp: log.timestamp,
            metadataJson: jsonEncode(
              _canonicalizeMetadata(log.type, log.metadata, settings),
            ),
            createdAt: log.createdAt,
          ),
        );
  }

  @override
  Stream<List<model.PregnancyLog>> watchLogsForChild(String childId) {
    final logsStream =
        (_database.select(_database.pregnancyLogs)
              ..where((tbl) => tbl.childId.equals(childId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
            .watch();
    final settingsStream =
        (_database.select(_database.appSettingsTable)
              ..where((tbl) => tbl.id.equals(1)))
            .watchSingleOrNull()
            .map(_settingsFromRow);

    return Stream.multi((controller) {
      List<dynamic>? latestRows;
      AppSettings? latestSettings;
      var hasSettingsSnapshot = false;

      void emitIfReady() {
        final rows = latestRows;
        if (rows == null || !hasSettingsSnapshot) return;
        controller.add(
          rows.map((row) {
            final type = PregnancyLogTypeCodec.fromStoredValue(row.type);
            final metadata = Map<String, dynamic>.from(
              jsonDecode(row.metadataJson) as Map<String, dynamic>,
            );
            return model.PregnancyLog(
              id: row.id,
              childId: row.childId,
              type: type,
              timestamp: row.timestamp,
              metadata: _toDisplayMetadata(type, metadata, latestSettings),
              createdAt: row.createdAt,
            );
          }).toList(),
        );
      }

      final logsSub = logsStream.listen((rows) {
        latestRows = rows;
        emitIfReady();
      }, onError: controller.addError);
      final settingsSub = settingsStream.listen((settings) {
        latestSettings = settings;
        hasSettingsSnapshot = true;
        emitIfReady();
      }, onError: controller.addError);

      controller.onCancel = () async {
        await logsSub.cancel();
        await settingsSub.cancel();
      };
    });
  }

  Future<AppSettings?> _readSettings() async {
    final row = await (_database.select(
      _database.appSettingsTable,
    )..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
    return _settingsFromRow(row);
  }

  AppSettings? _settingsFromRow(AppSettingsTableData? row) {
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

  Map<String, dynamic> _canonicalizeMetadata(
    PregnancyLogType type,
    Map<String, dynamic> metadata,
    AppSettings? settings,
  ) {
    final canonical = Map<String, dynamic>.from(metadata);
    switch (type) {
      case PregnancyLogType.waterIntake:
        final amount = (metadata['amount'] as num?)?.toDouble();
        if (amount != null && amount > 0) {
          final unit = settings?.volumeUnit ?? VolumeUnit.ml;
          canonical
            ..clear()
            ..['amountMl'] = UnitConversions.volumeToCanonicalMl(amount, unit);
        }
      case PregnancyLogType.weight:
        final amount = (metadata['amount'] as num?)?.toDouble();
        if (amount != null && amount > 0) {
          final unit = settings?.weightUnit ?? WeightUnit.kg;
          canonical
            ..clear()
            ..['weightKg'] = UnitConversions.weightToCanonicalKg(amount, unit);
        }
      case PregnancyLogType.kickCounter:
      case PregnancyLogType.bloodPressure:
      case PregnancyLogType.medication:
      case PregnancyLogType.mood:
        break;
    }
    return canonical;
  }

  Map<String, dynamic> _toDisplayMetadata(
    PregnancyLogType type,
    Map<String, dynamic> metadata,
    AppSettings? settings,
  ) {
    final display = Map<String, dynamic>.from(metadata);
    switch (type) {
      case PregnancyLogType.waterIntake:
        final amountMl = (metadata['amountMl'] as num?)?.toDouble();
        if (amountMl != null) {
          final unit = settings?.volumeUnit ?? VolumeUnit.ml;
          display['displayAmount'] = UnitConversions.volumeFromCanonicalMl(
            amountMl,
            unit,
          );
        }
      case PregnancyLogType.weight:
        final weightKg = (metadata['weightKg'] as num?)?.toDouble();
        if (weightKg != null) {
          final unit = settings?.weightUnit ?? WeightUnit.kg;
          display['displayWeight'] = UnitConversions.weightFromCanonicalKg(
            weightKg,
            unit,
          );
        }
      case PregnancyLogType.kickCounter:
      case PregnancyLogType.bloodPressure:
      case PregnancyLogType.medication:
      case PregnancyLogType.mood:
        break;
    }
    return display;
  }
}
