import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/contraction_entry.dart' as model;
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

abstract class ContractionRepository {
  Stream<List<model.ContractionEntry>> watchEntriesForActiveSession(
    String childId,
  );
  Stream<List<model.ContractionEntry>> watchEntriesForChild(String childId);
  Future<void> startContraction(String childId);
  Future<void> stopContraction(String childId, {int? intensity});
}

class DriftContractionRepository implements ContractionRepository {
  DriftContractionRepository(this._database);

  final LocalDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<void> startContraction(String childId) async {
    final sessionId = await _ensureActiveSession(childId);
    final openEntry = await _getOpenEntryForSession(sessionId);
    if (openEntry != null) return;

    await _database
        .into(_database.contractionEntries)
        .insert(
          ContractionEntriesCompanion.insert(
            id: _uuid.v4(),
            sessionId: sessionId,
            startedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> stopContraction(String childId, {int? intensity}) async {
    final session = await _getActiveSession(childId);
    if (session == null) return;

    final openEntry = await _getOpenEntryForSession(session.id);
    if (openEntry == null) return;

    final endTime = DateTime.now();
    await (_database.update(
      _database.contractionEntries,
    )..where((tbl) => tbl.id.equals(openEntry.id))).write(
      ContractionEntriesCompanion(
        endedAt: Value(endTime),
        intensity: Value(intensity),
      ),
    );
  }

  @override
  Stream<List<model.ContractionEntry>> watchEntriesForActiveSession(
    String childId,
  ) {
    final activeSessionStream =
        (_database.select(_database.contractionSessions)
              ..where(
                (tbl) => tbl.childId.equals(childId) & tbl.endedAt.isNull(),
              )
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
              ..limit(1))
            .watchSingleOrNull();

    return activeSessionStream.asyncExpand((session) {
      if (session == null) {
        return Stream.value(<model.ContractionEntry>[]);
      }

      return (_database.select(_database.contractionEntries)
            ..where((tbl) => tbl.sessionId.equals(session.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => model.ContractionEntry(
                    id: row.id,
                    sessionId: row.sessionId,
                    startedAt: row.startedAt,
                    endedAt: row.endedAt,
                    intensity: row.intensity,
                  ),
                )
                .toList(),
          );
    });
  }

  @override
  Stream<List<model.ContractionEntry>> watchEntriesForChild(String childId) {
    final query =
        _database.select(_database.contractionEntries).join([
            innerJoin(
              _database.contractionSessions,
              _database.contractionSessions.id.equalsExp(
                _database.contractionEntries.sessionId,
              ),
            ),
          ])
          ..where(_database.contractionSessions.childId.equals(childId))
          ..orderBy([
            OrderingTerm.desc(_database.contractionEntries.startedAt),
          ]);

    return query.watch().map(
      (rows) => rows
          .map((row) => row.readTable(_database.contractionEntries))
          .map(
            (entry) => model.ContractionEntry(
              id: entry.id,
              sessionId: entry.sessionId,
              startedAt: entry.startedAt,
              endedAt: entry.endedAt,
              intensity: entry.intensity,
            ),
          )
          .toList(),
    );
  }

  Future<String> _ensureActiveSession(String childId) async {
    final session = await _getActiveSession(childId);
    if (session != null) return session.id;
    final id = _uuid.v4();
    await _database
        .into(_database.contractionSessions)
        .insert(
          ContractionSessionsCompanion.insert(
            id: id,
            childId: childId,
            startedAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<ContractionSession?> _getActiveSession(String childId) {
    return (_database.select(_database.contractionSessions)
          ..where((tbl) => tbl.childId.equals(childId) & tbl.endedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<ContractionEntry?> _getOpenEntryForSession(String sessionId) {
    return (_database.select(_database.contractionEntries)
          ..where(
            (tbl) => tbl.sessionId.equals(sessionId) & tbl.endedAt.isNull(),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}
