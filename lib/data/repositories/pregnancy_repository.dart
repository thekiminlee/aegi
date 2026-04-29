import 'dart:convert';

import 'package:aegi/core/enums/pregnancy_log_type.dart';
import 'package:aegi/data/local/local_database.dart';
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
  Future<void> addLog(model.PregnancyLog log) {
    return _database
        .into(_database.pregnancyLogs)
        .insert(
          PregnancyLogsCompanion.insert(
            id: log.id,
            childId: log.childId,
            type: log.type.storedValue,
            timestamp: log.timestamp,
            metadataJson: jsonEncode(log.metadata),
            createdAt: log.createdAt,
          ),
        );
  }

  @override
  Stream<List<model.PregnancyLog>> watchLogsForChild(String childId) {
    return (_database.select(_database.pregnancyLogs)
          ..where((tbl) => tbl.childId.equals(childId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => model.PregnancyLog(
                  id: row.id,
                  childId: row.childId,
                  type: PregnancyLogTypeCodec.fromStoredValue(row.type),
                  timestamp: row.timestamp,
                  metadata: Map<String, dynamic>.from(
                    jsonDecode(row.metadataJson) as Map<String, dynamic>,
                  ),
                  createdAt: row.createdAt,
                ),
              )
              .toList(),
        );
  }
}
