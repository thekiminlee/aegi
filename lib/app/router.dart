import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/features/home/mode_aware_home_screen.dart';
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
        builder: (context, state) => OnboardingScreen(
          isAddChildFlow: state.uri.queryParameters['addChild'] == '1',
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ModeAwareHomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final gate = ref.read(onboardingGateProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';
      final isAddChildFlow = state.uri.queryParameters['addChild'] == '1';

      if (isSplash) return null;

      if (gate.isLoading) return isSplash ? null : '/splash';

      final completed = gate.value ?? false;
      if (!completed) return isOnboarding ? null : '/onboarding';
      if (completed && isOnboarding && !isAddChildFlow) return '/home';
      return null;
    },
  );
});

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _runSplashFlow();
  }

  Future<void> _runSplashFlow() async {
    final onboardingDoneFuture = ref.read(onboardingGateProvider.future);
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 3)),
      onboardingDoneFuture,
    ]);
    if (!mounted) return;
    final completed = await onboardingDoneFuture;
    if (!mounted) return;
    context.go(completed ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppColors>()?.accent ??
        const Color(0xFFFFB07C);

    return Scaffold(
      backgroundColor: accent,
      body: const Center(
        child: Text(
          'aegi',
          style: TextStyle(
            fontFamily: 'Playwright',
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
