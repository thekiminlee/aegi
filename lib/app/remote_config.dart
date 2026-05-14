import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RemoteConfigKey { minimumAppVersion, appStoreLink, playStoreLink }

class RemoteConfigDefinition {
  const RemoteConfigDefinition({
    required this.firebaseKey,
    required this.defaultValue,
  });

  final String firebaseKey;
  final Object defaultValue;
}

const Map<RemoteConfigKey, RemoteConfigDefinition> remoteConfigDefinitions = {
  RemoteConfigKey.minimumAppVersion: RemoteConfigDefinition(
    firebaseKey: 'minimum_app_version',
    defaultValue: '1.0.0',
  ),
  RemoteConfigKey.appStoreLink: RemoteConfigDefinition(
    firebaseKey: 'app_store_link',
    defaultValue: 'myaegi.com',
  ),
  RemoteConfigKey.playStoreLink: RemoteConfigDefinition(
    firebaseKey: 'play_store_link',
    defaultValue: 'myaegi.com',
  ),
};

extension RemoteConfigKeyX on RemoteConfigKey {
  RemoteConfigDefinition get definition => remoteConfigDefinitions[this]!;
  String get firebaseKey => definition.firebaseKey;
  Object get defaultValue => definition.defaultValue;
}

final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

final remoteConfigClientProvider = Provider<RemoteConfigClient>((ref) {
  return FirebaseRemoteConfigClient(ref.watch(firebaseRemoteConfigProvider));
});

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.watch(remoteConfigClientProvider));
});

final remoteConfigInitializationProvider = FutureProvider<void>((ref) async {
  await ref.watch(remoteConfigServiceProvider).initialize();
});

abstract class RemoteConfigClient {
  Future<void> setConfigSettings(RemoteConfigSettings settings);
  Future<void> setDefaults(Map<String, dynamic> defaultParameters);
  Future<bool> fetchAndActivate();
  String getString(String key);
  int getInt(String key);
  bool getBool(String key);
}

class FirebaseRemoteConfigClient implements RemoteConfigClient {
  FirebaseRemoteConfigClient(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> setConfigSettings(RemoteConfigSettings settings) {
    return _remoteConfig.setConfigSettings(settings);
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    return _remoteConfig.setDefaults(defaultParameters);
  }

  @override
  Future<bool> fetchAndActivate() {
    return _remoteConfig.fetchAndActivate();
  }

  @override
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  @override
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  @override
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }
}

class RemoteConfigService {
  RemoteConfigService(this._client);

  final RemoteConfigClient _client;

  Future<void> initialize() async {
    await _client.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await _client.setDefaults(_defaultParameters);

    try {
      final updated = await _client.fetchAndActivate();
      debugPrint('Remote Config fetchAndActivate updated=$updated');
    } catch (error, stackTrace) {
      debugPrint('Remote Config fetch failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String getString(RemoteConfigKey key) {
    return _client.getString(key.firebaseKey).trim();
  }

  int getInt(RemoteConfigKey key) {
    return _client.getInt(key.firebaseKey);
  }

  bool getBool(RemoteConfigKey key) {
    return _client.getBool(key.firebaseKey);
  }

  Map<String, dynamic> getJson(RemoteConfigKey key) {
    final decoded = jsonDecode(getString(key));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map(
        (dynamic mapKey, dynamic value) => MapEntry(mapKey.toString(), value),
      );
    }
    throw FormatException(
      'Remote config "${key.firebaseKey}" must decode to a JSON object.',
    );
  }

  Map<String, dynamic> get _defaultParameters {
    return {
      for (final entry in remoteConfigDefinitions.entries)
        entry.value.firebaseKey: entry.value.defaultValue,
    };
  }
}
