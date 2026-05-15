import 'package:aegi/app/providers.dart';
import 'package:aegi/data/models/contraction_entry.dart';
import 'package:aegi/data/models/journal_entry.dart';
import 'package:aegi/data/models/pregnancy_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expectingPregnancyLogsProvider =
    StreamProvider.family<List<PregnancyLog>, String>((ref, childId) {
      return ref.watch(pregnancyRepositoryProvider).watchLogsForChild(childId);
    });

final expectingJournalEntriesProvider =
    StreamProvider.family<List<JournalEntryModel>, String>((ref, childId) {
      return ref.watch(journalRepositoryProvider).watchEntriesForChild(childId);
    });

final expectingContractionEntriesProvider =
    StreamProvider.family<List<ContractionEntry>, String>((ref, childId) {
      return ref
          .watch(contractionRepositoryProvider)
          .watchEntriesForActiveSession(childId);
    });

final expectingContractionHistoryEntriesProvider =
    StreamProvider.family<List<ContractionEntry>, String>((ref, childId) {
      return ref
          .watch(contractionRepositoryProvider)
          .watchEntriesForChild(childId);
    });
