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
        builder: (context, state) => const OnboardingScreen(),
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

      if (gate.isLoading) return isSplash ? null : '/splash';

      final completed = gate.value ?? false;
      if (!completed) return isOnboarding ? null : '/onboarding';
      if (completed && (isOnboarding || isSplash)) return '/home';
      return null;
    },
  );
});

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeOut = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppColors>()?.accent ??
        const Color(0xFFFFB07C);

    return FadeTransition(
      opacity: ReverseAnimation(_fadeOut),
      child: Scaffold(
        backgroundColor: accent,
        body: const Center(
          child: Text(
            'aegi',
            style: TextStyle(
              fontFamily: 'Playwright',
              fontSize: 72,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
