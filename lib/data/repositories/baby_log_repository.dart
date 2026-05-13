import 'dart:convert';

import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/core/enums/units.dart';
import 'package:aegi/data/core/unit_conversions.dart';
import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/baby_log.dart' as model;
import 'package:drift/drift.dart';

abstract class BabyLogRepository {
  Stream<List<model.BabyLog>> watchLogsForChild(String childId);
  Future<void> addLog(model.BabyLog log);
  Future<void> updateLog(model.BabyLog log);
  Future<void> deleteLog(String id);
}

class DriftBabyLogRepository implements BabyLogRepository {
  DriftBabyLogRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<void> addLog(model.BabyLog log) async {
    final settings = await _readSettings();
    await _database
        .into(_database.babyLogs)
        .insert(
          BabyLogsCompanion.insert(
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
  Future<void> updateLog(model.BabyLog log) async {
    final settings = await _readSettings();
    await (_database.update(
      _database.babyLogs,
    )..where((tbl) => tbl.id.equals(log.id))).write(
      BabyLogsCompanion(
        type: Value(log.type.storedValue),
        timestamp: Value(log.timestamp),
        metadataJson: Value(
          jsonEncode(_canonicalizeMetadata(log.type, log.metadata, settings)),
        ),
      ),
    );
  }

  @override
  Future<void> deleteLog(String id) {
    return (_database.delete(
      _database.babyLogs,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Stream<List<model.BabyLog>> watchLogsForChild(String childId) {
    final logsStream =
        (_database.select(_database.babyLogs)
              ..where((tbl) => tbl.childId.equals(childId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
            .watch();
    final settingsStream =
        (_database.select(
          _database.appSettingsTable,
        )..where((tbl) => tbl.id.equals(1))).watchSingleOrNull().map((row) {
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
        });

    return Stream.multi((controller) {
      List<dynamic>? latestRows;
      AppSettings? latestSettings;
      var hasSettingsSnapshot = false;

      void emitIfReady() {
        final rows = latestRows;
        if (rows == null || !hasSettingsSnapshot) return;
        controller.add(
          rows.map((row) {
            final type = BabyLogTypeCodec.fromStoredValue(row.type);
            final metadata = Map<String, dynamic>.from(
              jsonDecode(row.metadataJson) as Map<String, dynamic>,
            );
            return model.BabyLog(
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
    BabyLogType type,
    Map<String, dynamic> metadata,
    AppSettings? settings,
  ) {
    final canonical = Map<String, dynamic>.from(metadata);
    if (type == BabyLogType.bottleFeed) {
      final amount = (metadata['amount'] as num?)?.toDouble();
      if (amount != null && amount > 0) {
        final unit = settings?.volumeUnit ?? VolumeUnit.ml;
        canonical
          ..clear()
          ..['amountMl'] = UnitConversions.volumeToCanonicalMl(amount, unit);
      }
    }
    return canonical;
  }

  Map<String, dynamic> _toDisplayMetadata(
    BabyLogType type,
    Map<String, dynamic> metadata,
    AppSettings? settings,
  ) {
    final display = Map<String, dynamic>.from(metadata);
    if (type == BabyLogType.bottleFeed) {
      final amountMl = (metadata['amountMl'] as num?)?.toDouble();
      if (amountMl != null) {
        final unit = settings?.volumeUnit ?? VolumeUnit.ml;
        display['displayAmount'] = UnitConversions.volumeFromCanonicalMl(
          amountMl,
          unit,
        );
      }
    }
    return display;
  }
}
