import 'package:aegi/app/remote_config.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final forceUpdateStateProvider = FutureProvider<ForceUpdateState>((ref) async {
  await ref.watch(remoteConfigInitializationProvider.future);

  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version.trim();
  final remoteConfigService = ref.read(remoteConfigServiceProvider);
  final minimumVersion = remoteConfigService.getString(
    RemoteConfigKey.minimumAppVersion,
  );
  final storeUrl = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => remoteConfigService.getString(
      RemoteConfigKey.appStoreLink,
    ),
    TargetPlatform.android => remoteConfigService.getString(
      RemoteConfigKey.playStoreLink,
    ),
    _ => '',
  };

  return ForceUpdateState(
    currentAppVersion: currentVersion,
    minimumAppVersion: minimumVersion,
    storeUrl: storeUrl,
    isUpdateRequired:
        minimumVersion.isNotEmpty &&
        compareVersions(currentVersion, minimumVersion) < 0,
  );
});

int compareVersions(String current, String minimum) {
  final currentParts = _parseVersion(current);
  final minimumParts = _parseVersion(minimum);

  final length = currentParts.length > minimumParts.length
      ? currentParts.length
      : minimumParts.length;

  for (var index = 0; index < length; index++) {
    final currentPart = index < currentParts.length ? currentParts[index] : 0;
    final minimumPart = index < minimumParts.length ? minimumParts[index] : 0;
    if (currentPart != minimumPart) {
      return currentPart.compareTo(minimumPart);
    }
  }

  return 0;
}

List<int> _parseVersion(String version) {
  return version
      .split(RegExp(r'[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map(int.parse)
      .toList();
}

@immutable
class ForceUpdateState {
  const ForceUpdateState({
    required this.currentAppVersion,
    required this.minimumAppVersion,
    required this.storeUrl,
    required this.isUpdateRequired,
  });

  final String currentAppVersion;
  final String minimumAppVersion;
  final String storeUrl;
  final bool isUpdateRequired;
}

class ForceUpdateGate extends ConsumerWidget {
  const ForceUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forceUpdate = ref.watch(forceUpdateStateProvider).asData?.value;

    if (forceUpdate == null || !forceUpdate.isUpdateRequired) {
      return child;
    }

    final theme = Theme.of(context);
    final colors = context.appColors;
    final hasStoreUrl = forceUpdate.storeUrl.isNotEmpty;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: colors.appBackground,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: colors.outline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update required',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontFamily: "Inconsolata",
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This version of aegi is no longer supported. Please update to the latest version.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: "Inconsolata",
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Installed: ${forceUpdate.currentAppVersion}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: "Inconsolata",
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Minimum: ${forceUpdate.minimumAppVersion}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: "Inconsolata",
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: hasStoreUrl
                                    ? () => _openStoreLink(
                                        context,
                                        forceUpdate.storeUrl,
                                      )
                                    : null,
                                child: Text(
                                  hasStoreUrl
                                      ? 'Update'
                                      : 'Store link unavailable',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openStoreLink(BuildContext context, String rawUrl) async {
  final url = _normalizeExternalUrl(rawUrl);
  if (url == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invalid store link.')));
    return;
  }

  final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open store link.')));
  }
}

Uri? _normalizeExternalUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return null;

  final normalized = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
    return null;
  }

  return uri;
}
