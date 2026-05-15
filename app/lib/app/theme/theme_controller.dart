import 'dart:async';

import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeControllerProvider = NotifierProvider<ThemeController, AppThemeKey>(
  ThemeController.new,
);

class ThemeController extends Notifier<AppThemeKey> {
  @override
  AppThemeKey build() {
    final repo = ref.watch(appMetaRepositoryProvider);
    unawaited(_hydrate(repo));
    return AppThemeKey.nurtureLight;
  }

  Future<void> setTheme(AppThemeKey key) async {
    state = key;
    final repo = ref.read(appMetaRepositoryProvider);
    await repo.setValue(selectedThemeKey, key.name);
  }

  Future<void> _hydrate(AppMetaRepository repo) async {
    final value = await repo.getValue(selectedThemeKey);
    if (value == null) return;
    state = AppThemeKey.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeKey.nurtureLight,
    );
  }
}
