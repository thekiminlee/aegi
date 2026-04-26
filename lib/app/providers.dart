import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:aegi/data/repositories/child_repository.dart';
import 'package:aegi/data/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(db.close);
  return db;
});

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return DriftChildRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(databaseProvider));
});

final appMetaRepositoryProvider = Provider<AppMetaRepository>((ref) {
  return DriftAppMetaRepository(ref.watch(databaseProvider));
});
