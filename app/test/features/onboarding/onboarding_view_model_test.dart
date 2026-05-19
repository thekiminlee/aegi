import 'package:aegi/app/analytics.dart';
import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/core/enums/gender.dart';
import 'package:aegi/data/models/app_settings.dart';
import 'package:aegi/data/models/child_profile.dart';
import 'package:aegi/data/repositories/child_repository.dart';
import 'package:aegi/data/repositories/settings_repository.dart';
import 'package:aegi/features/onboarding/onboarding_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChildRepository implements ChildRepository {
  ChildProfile? saved;

  @override
  Future<void> createInitialChild(ChildProfile child) async {
    saved = child;
  }

  @override
  Future<ChildProfile?> getById(String id) async => null;

  @override
  Stream<List<ChildProfile>> watchAll() async* {
    yield const [];
  }

  @override
  Future<void> updateChild(ChildProfile child) async {
    saved = child;
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings? saved;

  @override
  Future<AppSettings?> getSettings() async => saved;

  @override
  Future<void> saveInitialSettings(AppSettings settings) async {
    saved = settings;
  }

  @override
  Future<void> updateSelectedChildId(String childId) async {}

  @override
  Future<void> updateSettings(AppSettings settings) async {
    saved = settings;
  }
}

class _FakeOnboardingGate extends OnboardingGate {
  bool marked = false;

  @override
  Future<bool> build() async => false;

  @override
  Future<void> markComplete() async {
    marked = true;
    state = const AsyncData(true);
  }
}

class _FakeAnalyticsClient implements AnalyticsClient {
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> setUserProperty({required String name, String? value}) async {}
}

void main() {
  test('step 1 requires mode and required date', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    expect(container.read(onboardingViewModelProvider).mode, isNull);
    expect(container.read(onboardingViewModelProvider).canContinueStep1, false);

    final now = DateTime.now();
    notifier.setDueDate(now.add(const Duration(days: 60)));
    expect(container.read(onboardingViewModelProvider).canContinueStep1, false);

    notifier.setMode(AppMode.expecting);
    expect(container.read(onboardingViewModelProvider).canContinueStep1, true);

    notifier.setDueDate(now.add(const Duration(days: 500)));
    expect(container.read(onboardingViewModelProvider).canContinueStep1, false);
  });

  test('empty name falls back to Baby', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(onboardingViewModelProvider.notifier);

    notifier.setBabyName('   ');
    expect(
      container.read(onboardingViewModelProvider).normalizedBabyName,
      'Baby',
    );
  });

  test('step 2 requires selected gender and valid name', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    expect(container.read(onboardingViewModelProvider).canContinueStep2, false);

    notifier.setBabyName('  Ada  ');
    expect(container.read(onboardingViewModelProvider).canContinueStep2, false);

    notifier.setGender(Gender.female);
    expect(container.read(onboardingViewModelProvider).canContinueStep2, true);

    notifier.setBabyName('   ');
    expect(container.read(onboardingViewModelProvider).canContinueStep2, false);
  });

  test('step 2 allows explicit skip gender selection', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    notifier.setBabyName('Milo');
    expect(container.read(onboardingViewModelProvider).canContinueStep2, false);

    notifier.setGender(Gender.unspecified);
    expect(container.read(onboardingViewModelProvider).hasSelectedGender, true);
    expect(container.read(onboardingViewModelProvider).canContinueStep2, true);
  });

  test('completion writes child and settings for arrived mode', () async {
    final childRepo = _FakeChildRepository();
    final settingsRepo = _FakeSettingsRepository();

    final container = ProviderContainer(
      overrides: [
        childRepositoryProvider.overrideWithValue(childRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        onboardingGateProvider.overrideWith(_FakeOnboardingGate.new),
        analyticsClientProvider.overrideWithValue(_FakeAnalyticsClient()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(onboardingViewModelProvider.notifier);
    notifier.setMode(AppMode.arrived);
    notifier.setBirthDate(DateTime.now().subtract(const Duration(days: 30)));
    notifier.setGender(Gender.female);
    notifier.setBabyName('Luna');

    final completed = await notifier.completeOnboarding();
    expect(completed, true);
    expect(childRepo.saved, isNotNull);
    expect(childRepo.saved!.name, 'Luna');
    expect(childRepo.saved!.mode, AppMode.arrived);
    expect(childRepo.saved!.birthDate, isNotNull);
    expect(childRepo.saved!.dueDate, isNull);
    expect(settingsRepo.saved, isNotNull);
    expect(settingsRepo.saved!.selectedChildId, childRepo.saved!.id);
    expect(settingsRepo.saved!.weeklyPregnancyReminderEnabled, false);
  });
}
