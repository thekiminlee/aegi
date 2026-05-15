import 'package:aegi/app/force_update_gate.dart';
import 'package:aegi/app/remote_config.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareVersions', () {
    test('returns negative when current version is below minimum', () {
      expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
    });

    test('returns zero when versions are equivalent', () {
      expect(compareVersions('1.2', '1.2.0'), 0);
    });

    test('returns positive when current version is above minimum', () {
      expect(compareVersions('2.0.0', '1.9.9'), greaterThan(0));
    });
  });

  group('remote config definitions', () {
    test('maps minimum app version key', () {
      expect(
        RemoteConfigKey.minimumAppVersion.firebaseKey,
        'minimum_app_version',
      );
    });

    test('maps app store key', () {
      expect(RemoteConfigKey.appStoreLink.firebaseKey, 'app_store_link');
    });

    test('maps play store key', () {
      expect(RemoteConfigKey.playStoreLink.firebaseKey, 'play_store_link');
    });
  });

  group('RemoteConfigService', () {
    late _FakeRemoteConfigClient client;
    late RemoteConfigService service;

    setUp(() {
      client = _FakeRemoteConfigClient(
        strings: {
          'minimum_app_version': ' 1.2.3 ',
          'app_store_link': ' https://apps.apple.com/app ',
          'play_store_link': 'https://play.google.com/store/apps/details?id=x',
          'json_key': '{"enabled":true,"count":3}',
          'invalid_json': 'not-json',
          'json_list': '["a"]',
        },
        ints: {'minimum_app_version': 123, 'some_int': 42},
        bools: {'play_store_link': true},
      );
      service = RemoteConfigService(client);
    });

    test('initializes remote config client', () async {
      await service.initialize();

      expect(client.configSettingsSet, isTrue);
      expect(
        client.defaultsSet['minimum_app_version'],
        RemoteConfigKey.minimumAppVersion.defaultValue,
      );
      expect(
        client.defaultsSet['app_store_link'],
        RemoteConfigKey.appStoreLink.defaultValue,
      );
      expect(
        client.defaultsSet['play_store_link'],
        RemoteConfigKey.playStoreLink.defaultValue,
      );
      expect(client.fetchCalled, isTrue);
    });

    test('returns trimmed string', () {
      expect(service.getString(RemoteConfigKey.minimumAppVersion), '1.2.3');
    });

    test('returns int value', () {
      expect(service.getInt(RemoteConfigKey.minimumAppVersion), 123);
    });

    test('returns bool value', () {
      expect(service.getBool(RemoteConfigKey.playStoreLink), isTrue);
    });

    test('decodes json object', () {
      client.strings['app_store_link'] = '{"enabled":true,"count":3}';
      expect(service.getJson(RemoteConfigKey.appStoreLink), {
        'enabled': true,
        'count': 3,
      });
    });

    test('throws on invalid json', () {
      client.strings['app_store_link'] = 'not-json';
      expect(
        () => service.getJson(RemoteConfigKey.appStoreLink),
        throwsFormatException,
      );
    });

    test('throws when json is not object', () {
      client.strings['app_store_link'] = '["a"]';
      expect(
        () => service.getJson(RemoteConfigKey.appStoreLink),
        throwsFormatException,
      );
    });
  });
}

class _FakeRemoteConfigClient implements RemoteConfigClient {
  _FakeRemoteConfigClient({
    required this.strings,
    required this.ints,
    required this.bools,
  });

  final Map<String, String> strings;
  final Map<String, int> ints;
  final Map<String, bool> bools;

  bool configSettingsSet = false;
  bool fetchCalled = false;
  Map<String, dynamic> defaultsSet = const {};

  @override
  Future<bool> fetchAndActivate() async {
    fetchCalled = true;
    return true;
  }

  @override
  bool getBool(String key) {
    return bools[key] ?? false;
  }

  @override
  int getInt(String key) {
    return ints[key] ?? 0;
  }

  @override
  String getString(String key) {
    return strings[key] ?? '';
  }

  @override
  Future<void> setConfigSettings(RemoteConfigSettings settings) async {
    configSettingsSet = true;
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) async {
    defaultsSet = defaultParameters;
  }
}
