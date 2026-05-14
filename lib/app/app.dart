import 'package:aegi/app/router.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/app/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Aegi extends ConsumerWidget {
  const Aegi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(analyticsIdentitySyncProvider);
    final themeKey = ref.watch(themeControllerProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'aegi',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(themeKey),
      routerConfig: router,
    );
  }
}
