import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/features/arrived/arrived_shell_screen.dart';
import 'package:aegi/features/expecting/expecting_shell_screen.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeAwareHomeScreen extends ConsumerWidget {
  const ModeAwareHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeChildContextProvider);
    return active.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            'Unable to load home: $error',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (contextData) {
        switch (contextData.child.mode) {
          case AppMode.expecting:
            return ExpectingShellScreen(activeChild: contextData.child);
          case AppMode.arrived:
            return ArrivedShellScreen(activeChild: contextData.child);
        }
      },
    );
  }
}

