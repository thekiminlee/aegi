import 'package:aegi/data/local/local_database.dart';

const String onboardingCompletedKey = 'onboarding_completed';
const String selectedThemeKey = 'selected_theme';

abstract class AppMetaRepository {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete(bool isComplete);
  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
}

class DriftAppMetaRepository implements AppMetaRepository {
  DriftAppMetaRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<String?> getValue(String key) async {
    final row = await (_database.select(
      _database.appMetaTable,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final value = await getValue(onboardingCompletedKey);
    return value == 'true';
  }

  @override
  Future<void> setOnboardingComplete(bool isComplete) {
    return setValue(onboardingCompletedKey, isComplete.toString());
  }

  @override
  Future<void> setValue(String key, String value) {
    return _database
        .into(_database.appMetaTable)
        .insertOnConflictUpdate(
          AppMetaTableCompanion.insert(key: key, value: value),
        );
  }
}
