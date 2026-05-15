import 'package:aegi/data/local/local_database.dart';
import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/data/backup/backup_service.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart' as model;
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:aegi/app/analytics.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/data/repositories/child_repository.dart';
import 'package:aegi/data/repositories/contraction_repository.dart';
import 'package:aegi/data/repositories/journal_repository.dart';
import 'package:aegi/data/repositories/baby_log_repository.dart';
import 'package:aegi/data/repositories/pregnancy_repository.dart';
import 'package:aegi/data/repositories/settings_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backupAppInfoProvider = Provider<BackupAppInfoProvider>((ref) {
  return const PackageInfoBackupAppInfoProvider();
});

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

final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) {
  return DriftPregnancyRepository(ref.watch(databaseProvider));
});

final contractionRepositoryProvider = Provider<ContractionRepository>((ref) {
  return DriftContractionRepository(ref.watch(databaseProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return DriftJournalRepository(ref.watch(databaseProvider));
});

final babyLogRepositoryProvider = Provider<BabyLogRepository>((ref) {
  return DriftBabyLogRepository(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return DriftBackupService(
    ref.watch(databaseProvider),
    ref.watch(appMetaRepositoryProvider),
    ref.watch(backupAppInfoProvider),
  );
});

final appSettingsProvider = FutureProvider<AppSettings?>((ref) {
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final backupStatusProvider = FutureProvider<BackupStatus>((ref) {
  return ref.watch(backupServiceProvider).getStatus();
});

final analyticsClientProvider = Provider<AnalyticsClient>((ref) {
  return FirebaseAnalyticsClient(FirebaseAnalytics.instance);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(analyticsClientProvider));
});

final analyticsIdentitySyncProvider = FutureProvider<void>((ref) async {
  final analytics = ref.read(analyticsServiceProvider);
  final settings = await ref.read(settingsRepositoryProvider).getSettings();
  final children = await ref.read(childRepositoryProvider).watchAll().first;
  final onboardingComplete = await ref
      .read(appMetaRepositoryProvider)
      .isOnboardingComplete();

  final childCount = children.length;
  final childrenBucket = childCount <= 1
      ? '1'
      : childCount == 2
      ? '2'
      : '3_plus';

  final appMode = _computeAppMode(settings?.selectedChildId, children);
  await analytics.setIdentityProperties(
    appMode: appMode,
    childrenCountBucket: childrenBucket,
    onboardingComplete: onboardingComplete,
  );
});

String _computeAppMode(String? selectedChildId, List<dynamic> children) {
  final typedChildren = children.whereType<model.ChildProfile>().toList();
  if (typedChildren.isEmpty) return AnalyticsMode.expecting;
  final modes = typedChildren.map((c) => c.mode).toSet();
  if (modes.length > 1) return AnalyticsMode.mixedIfMultiChild;
  if (selectedChildId != null) {
    for (final child in typedChildren) {
      if (child.id == selectedChildId) {
        return child.mode.name;
      }
    }
  }
  final first = modes.isEmpty ? AppMode.expecting : modes.first;
  return first.name;
}
