import 'dart:convert';

import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:drift/drift.dart';

abstract class JournalRepository {
  Stream<List<JournalEntryModel>> watchEntriesForChild(String childId);
  Future<void> addEntry(JournalEntryModel entry);
  Future<void> updateEntry(JournalEntryModel entry);
  Future<void> deleteEntry(String entryId);
}

class DriftJournalRepository implements JournalRepository {
  DriftJournalRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<void> addEntry(JournalEntryModel entry) {
    return _database
        .into(_database.journalEntries)
        .insert(
          JournalEntriesCompanion.insert(
            id: entry.id,
            childId: entry.childId,
            timestamp: entry.timestamp,
            body: entry.body,
            tagsJson: jsonEncode(entry.tags),
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
          ),
        );
  }

  @override
  Future<void> updateEntry(JournalEntryModel entry) {
    return (_database.update(_database.journalEntries)
          ..where((tbl) => tbl.id.equals(entry.id)))
        .write(
      JournalEntriesCompanion(
        body: Value(entry.body),
        tagsJson: Value(jsonEncode(entry.tags)),
        updatedAt: Value(entry.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteEntry(String entryId) {
    return (_database.delete(_database.journalEntries)
          ..where((tbl) => tbl.id.equals(entryId)))
        .go();
  }

  @override
  Stream<List<JournalEntryModel>> watchEntriesForChild(String childId) {
    return (_database.select(_database.journalEntries)
          ..where((tbl) => tbl.childId.equals(childId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => JournalEntryModel(
                  id: row.id,
                  childId: row.childId,
                  timestamp: row.timestamp,
                  body: row.body,
                  tags: (jsonDecode(row.tagsJson) as List<dynamic>)
                      .map((item) => item.toString())
                      .toList(),
                  createdAt: row.createdAt,
                  updatedAt: row.updatedAt,
                ),
              )
              .toList(),
        );
  }
}
