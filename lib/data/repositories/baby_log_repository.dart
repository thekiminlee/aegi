import 'dart:convert';

import 'package:aegi/core/enums/baby_log_type.dart';
import 'package:aegi/data/local/local_database.dart';
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
  Future<void> addLog(model.BabyLog log) {
    return _database
        .into(_database.babyLogs)
        .insert(
          BabyLogsCompanion.insert(
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
  Future<void> updateLog(model.BabyLog log) {
    return (_database.update(_database.babyLogs)
          ..where((tbl) => tbl.id.equals(log.id)))
        .write(
      BabyLogsCompanion(
        type: Value(log.type.storedValue),
        timestamp: Value(log.timestamp),
        metadataJson: Value(jsonEncode(log.metadata)),
      ),
    );
  }

  @override
  Future<void> deleteLog(String id) {
    return (_database.delete(_database.babyLogs)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  @override
  Stream<List<model.BabyLog>> watchLogsForChild(String childId) {
    return (_database.select(_database.babyLogs)
          ..where((tbl) => tbl.childId.equals(childId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => model.BabyLog(
                  id: row.id,
                  childId: row.childId,
                  type: BabyLogTypeCodec.fromStoredValue(row.type),
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
