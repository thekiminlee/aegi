import 'package:aegi/app/analytics.dart';
import 'package:flutter/widgets.dart';

void logTabScreen({
  required AnalyticsService analytics,
  required List<String> screenNames,
  required int tabIndex,
}) {
  analytics.logScreen(screenNames[tabIndex]);
}

void logResetTabScreen({
  required AnalyticsService analytics,
  required List<String> screenNames,
  required State state,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!state.mounted) return;
    analytics.logScreen(screenNames[0]);
  });
}
