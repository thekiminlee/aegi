import 'package:aegi/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingGateProvider = AsyncNotifierProvider<OnboardingGate, bool>(
  OnboardingGate.new,
);

class OnboardingGate extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = ref.watch(appMetaRepositoryProvider);
    return repo.isOnboardingComplete();
  }

  Future<void> markComplete() async {
    final repo = ref.read(appMetaRepositoryProvider);
    await repo.setOnboardingComplete(true);
    state = const AsyncData(true);
  }
}
