import 'package:aegi/app/analytics.dart';
import 'package:aegi/core/enums/app_mode.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAnalyticsClient implements AnalyticsClient {
  final events = <({String name, Map<String, Object>? params})>[];
  final userProps = <String, String?>{};

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add((name: name, params: parameters));
  }

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> setUserProperty({required String name, String? value}) async {
    userProps[name] = value;
  }
}

void main() {
  test('log entry events keep only allowlisted metadata keys', () async {
    final client = _FakeAnalyticsClient();
    final analytics = AnalyticsService(client);

    await analytics.logEntrySaved(
      mode: 'expecting',
      entryFamily: 'pregnancy',
      entryType: 'blood_pressure',
      result: 'success',
    );

    final event = client.events.single;
    expect(event.name, 'log_entry_saved');
    expect(event.params, {
      'mode': 'expecting',
      'entry_family': 'pregnancy',
      'entry_type': 'blood_pressure',
      'result': 'success',
    });
    expect(event.params!.containsKey('systolic'), false);
    expect(event.params!.containsKey('notes'), false);
  });

  test('onboarding completed emits expected params', () async {
    final client = _FakeAnalyticsClient();
    final analytics = AnalyticsService(client);

    await analytics.onboardingCompleted(
      mode: AppMode.arrived,
      addChildFlow: true,
    );

    final event = client.events.single;
    expect(event.name, 'onboarding_completed');
    expect(event.params, {
      'mode_selected': 'arrived',
      'add_child_flow': 'true',
    });
  });

  test('identity user properties are set', () async {
    final client = _FakeAnalyticsClient();
    final analytics = AnalyticsService(client);

    await analytics.setIdentityProperties(
      appMode: 'mixed_if_multi_child',
      childrenCountBucket: '3_plus',
      onboardingComplete: true,
    );

    expect(client.userProps['app_mode'], 'mixed_if_multi_child');
    expect(client.userProps['children_count_bucket'], '3_plus');
    expect(client.userProps['onboarding_complete'], 'true');
  });
}
