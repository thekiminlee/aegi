import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/onboarding/step_progress.dart';
import 'package:flutter/material.dart';

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    required this.currentStepIndex,
    required this.child,
    required this.footer,
    this.totalSteps = 3,
    this.onBack,
    super.key,
  });

  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback? onBack;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.appBackground,
      body: Container(
        decoration: BoxDecoration(
          color: colors.appBackground,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.white, Color(0x00FFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: onBack == null
                          ? const SizedBox.shrink()
                          : Material(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: onBack,
                                borderRadius: BorderRadius.circular(999),
                                child: const Icon(Icons.arrow_back, size: 20),
                              ),
                            ),
                    ),
                    Expanded(
                      child: Center(
                        child: StepProgress(currentIndex: currentStepIndex, total: totalSteps),
                      ),
                    ),
                    const SizedBox(width: 40, height: 40),
                  ],
                ),
              ),
              Expanded(child: child),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
