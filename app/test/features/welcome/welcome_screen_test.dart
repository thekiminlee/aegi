import 'package:aegi/features/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome page shows both entry actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
    );

    expect(find.text('Welcome to calm nights'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
  });
}
