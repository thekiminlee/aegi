import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/core/widgets/onboarding/primary_cta_button.dart';
import 'package:aegi/features/backup/backup_import_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _importing = false;

  Future<void> _startImport() async {
    if (_importing) return;
    setState(() => _importing = true);
    await startBackupImportFlow(
      context: context,
      ref: ref,
      completeOnboardingOnSuccess: true,
    );
    if (mounted) {
      setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x1A000000), Color(0x33000000), Color(0xA6000000)],
              stops: [0, 0.45, 1],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/img/logo/logo.png',
                    width: 72,
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      text: "Tiny moments\nBig ",
                      style: TextStyle(
                        fontFamily: "Instrument Serif",
                        fontSize: 42
                      ),
                      children: [
                        TextSpan(
                          text: "memories",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: context.appColors.accent
                          )
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 20),
                  PrimaryCtaButton(
                    label: 'Get Started',
                    onPressed: _importing
                        ? null
                        : () => context.go('/onboarding'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                      onPressed: _importing ? null : _startImport,
                      child: _importing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Import'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
