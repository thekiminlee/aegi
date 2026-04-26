import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/features/home/home_placeholder_screen.dart';
import 'package:aegi/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(onboardingGateProvider, (previous, next) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePlaceholderScreen(),
      ),
    ],
    redirect: (context, state) {
      final gate = ref.read(onboardingGateProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';

      if (gate.isLoading) return isSplash ? null : '/splash';

      final completed = gate.valueOrNull ?? false;
      if (!completed) return isOnboarding ? null : '/onboarding';
      if (completed && (isOnboarding || isSplash)) return '/home';
      return null;
    },
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
