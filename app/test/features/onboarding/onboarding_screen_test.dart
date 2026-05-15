import 'package:aegi/app/analytics.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:aegi/features/onboarding/onboarding_screen.dart';
import 'package:aegi/features/onboarding/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fakeAnalyticsClient = _FakeAnalyticsClient();

  testWidgets('back button hidden on step 1 and visible on step 2', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        analyticsClientProvider.overrideWithValue(fakeAnalyticsClient),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.byIcon(Icons.arrow_back), findsNothing);

    final vm = container.read(onboardingViewModelProvider.notifier);
    vm.setMode(AppMode.arrived);
    vm.setBirthDate(DateTime(2024, 10, 2));
    vm.nextPage();

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
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
