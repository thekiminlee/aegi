import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/app/theme/theme_controller.dart';
import 'package:aegi/data/repositories/app_meta_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMetaRepository implements AppMetaRepository {
  final Map<String, String> values = {};

  @override
  Future<String?> getValue(String key) async => values[key];

  @override
  Future<bool> isOnboardingComplete() async =>
      values[onboardingCompletedKey] == 'true';

  @override
  Future<void> setOnboardingComplete(bool isComplete) async {
    values[onboardingCompletedKey] = isComplete.toString();
  }

  @override
  Future<void> setValue(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  test('setTheme updates state and persists key', () async {
    final repo = _FakeMetaRepository();
    final container = ProviderContainer(
      overrides: [appMetaRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final controller = container.read(themeControllerProvider.notifier);
    await controller.setTheme(AppThemeKey.softMint);

    expect(container.read(themeControllerProvider), AppThemeKey.softMint);
    expect(repo.values[selectedThemeKey], AppThemeKey.softMint.name);
  });
}
