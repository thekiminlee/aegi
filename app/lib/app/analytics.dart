import 'package:aegi/app/analytics_constants.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsClient {
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });

  Future<void> setUserProperty({required String name, String? value});

  Future<void> logScreenView({required String screenName});
}

class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserProperty({required String name, String? value}) {
    return _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView({required String screenName}) {
    return _analytics.logScreenView(screenName: screenName);
  }
}

class AnalyticsService {
  AnalyticsService(this._client);

  final AnalyticsClient _client;

  static const Set<String> _blockedParamKeys = {
    'name',
    'phone',
    'notes',
    'body',
    'text',
    'message',
    'value',
    'amount',
    'systolic',
    'diastolic',
    'duration_min',
    'duration_seconds',
  };

  static const Map<String, Set<String>> _allowedParams = {
    'onboarding_started': {'add_child_flow'},
    'onboarding_step_viewed': {'step', 'add_child_flow'},
    'onboarding_step_completed': {'step', 'add_child_flow'},
    'onboarding_completed': {'mode_selected', 'add_child_flow'},
    'daily_timeline_viewed': {'mode'},
    'history_viewed': {'mode'},
    'quick_action_tapped': {'mode', 'entry_family', 'entry_type'},
    'log_entry_opened': {'mode', 'entry_family', 'entry_type'},
    'log_entry_saved': {'mode', 'entry_family', 'entry_type', 'result'},
    'log_entry_deleted': {'mode', 'entry_family', 'entry_type'},
    'contraction_started': {'mode'},
    'contraction_stopped': {'mode'},
    'contact_provider_prompt_shown': {'mode'},
    'contact_provider_tapped': {'mode'},
  };

  Future<void> setIdentityProperties({
    required String appMode,
    required String childrenCountBucket,
    required bool onboardingComplete,
  }) async {
    await _client.setUserProperty(name: 'app_mode', value: appMode);
    await _client.setUserProperty(
      name: 'children_count_bucket',
      value: childrenCountBucket,
    );
    await _client.setUserProperty(
      name: 'onboarding_complete',
      value: onboardingComplete.toString(),
    );
  }

  Future<void> logScreen(String screenName) {
    return _client.logScreenView(screenName: screenName);
  }

  Future<void> onboardingStarted({required bool addChildFlow}) {
    return _log('onboarding_started', {
      'add_child_flow': addChildFlow.toString(),
    });
  }

  Future<void> onboardingStepViewed({
    required String step,
    required bool addChildFlow,
  }) {
    return _log('onboarding_step_viewed', {
      'step': step,
      'add_child_flow': addChildFlow.toString(),
    });
  }

  Future<void> onboardingStepCompleted({
    required String step,
    required bool addChildFlow,
  }) {
    return _log('onboarding_step_completed', {
      'step': step,
      'add_child_flow': addChildFlow.toString(),
    });
  }

  Future<void> onboardingCompleted({
    required AppMode mode,
    required bool addChildFlow,
  }) {
    return _log('onboarding_completed', {
      'mode_selected': mode.name,
      'add_child_flow': addChildFlow.toString(),
    });
  }

  Future<void> dailyTimelineViewed({required String mode}) {
    return _log('daily_timeline_viewed', {'mode': mode});
  }

  Future<void> historyViewed({required String mode}) {
    return _log('history_viewed', {'mode': mode});
  }

  Future<void> quickActionTapped({required String entryType}) {
    return _logEntryEvent(
      'quick_action_tapped',
      AnalyticsMode.arrived,
      AnalyticsEntryFamily.baby,
      entryType,
    );
  }

  Future<void> logEntryOpened({
    required String mode,
    required String entryFamily,
    required String entryType,
  }) {
    return _logEntryEvent('log_entry_opened', mode, entryFamily, entryType);
  }

  Future<void> logEntrySaved({
    required String mode,
    required String entryFamily,
    required String entryType,
    required String result,
  }) {
    return _log('log_entry_saved', {
      'mode': mode,
      'entry_family': entryFamily,
      'entry_type': entryType,
      'result': result,
    });
  }

  Future<void> logEntryDeleted({
    required String mode,
    required String entryFamily,
    required String entryType,
  }) {
    return _logEntryEvent('log_entry_deleted', mode, entryFamily, entryType);
  }

  Future<void> contractionStarted() {
    return _log('contraction_started', {'mode': AnalyticsMode.expecting});
  }

  Future<void> contractionStopped() {
    return _log('contraction_stopped', {'mode': AnalyticsMode.expecting});
  }

  Future<void> contactProviderPromptShown() {
    return _log(
      'contact_provider_prompt_shown',
      {'mode': AnalyticsMode.expecting},
    );
  }

  Future<void> contactProviderTapped() {
    return _log('contact_provider_tapped', {'mode': AnalyticsMode.expecting});
  }

  Future<void> _logEntryEvent(
    String name,
    String mode,
    String entryFamily,
    String entryType,
  ) {
    return _log(name, {
      'mode': mode,
      'entry_family': entryFamily,
      'entry_type': entryType,
    });
  }

  Future<void> _log(String name, [Map<String, Object?> rawParams = const {}]) {
    final sanitized = _sanitize(name, rawParams);
    return _client.logEvent(name: name, parameters: sanitized);
  }

  Map<String, Object> _sanitize(String eventName, Map<String, Object?> input) {
    final allowed = _allowedParams[eventName] ?? const <String>{};
    final result = <String, Object>{};

    for (final entry in input.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!allowed.contains(key)) continue;
      if (_blockedParamKeys.contains(key)) continue;
      if (value == null) continue;
      if (value is String || value is num || value is bool) {
        result[key] = value;
      }
    }

    return result;
  }
}
