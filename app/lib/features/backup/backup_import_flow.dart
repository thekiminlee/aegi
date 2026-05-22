import 'dart:io';
import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/app/theme/app_theme.dart';
import 'package:aegi/data/backup/backup_service.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

Future<void> startBackupImportFlow({
  required BuildContext context,
  required WidgetRef ref,
  bool completeOnboardingOnSuccess = false,
}) async {
  try {
    final useUnfilteredPicker = defaultTargetPlatform == TargetPlatform.iOS;
    final picked = await FilePicker.platform.pickFiles(
      type: useUnfilteredPicker ? FileType.any : FileType.custom,
      allowedExtensions: useUnfilteredPicker
          ? null
          : const [backupFileExtension],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty || !context.mounted) return;

    final pickedFile = picked.files.single;
    _validateBackupFileExtension(pickedFile);
    final bytes = await _readPickedFileBytes(pickedFile);
    final preview = await ref
        .read(backupServiceProvider)
        .inspectBackupBytes(bytes);
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ImportBackupConfirmScreen(
          preview: preview,
          backupBytes: bytes,
          completeOnboardingOnSuccess: completeOnboardingOnSuccess,
        ),
      ),
    );
  } on BackupException catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.message)));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to restore backup right now.')),
    );
  }
}

Future<Uint8List> _readPickedFileBytes(PlatformFile file) async {
  if (file.bytes != null) return file.bytes!;
  final path = file.path;
  if (path == null || path.isEmpty) {
    throw const BackupException('Selected backup file could not be read.');
  }
  return File(path).readAsBytes();
}

void _validateBackupFileExtension(PlatformFile file) {
  final extension = (file.extension ?? _extensionFromPath(file.path) ?? '')
      .toLowerCase();
  if (extension != backupFileExtension) {
    throw const BackupException('Please choose an .aegi backup file.');
  }
}

String? _extensionFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  final segments = path.split('.');
  if (segments.length < 2) return null;
  return segments.last;
}

void _refreshAppStateAfterRestore(WidgetRef ref) {
  ref.invalidate(appSettingsProvider);
  ref.invalidate(backupStatusProvider);
  ref.invalidate(activeChildContextProvider);
  ref.invalidate(allChildrenProvider);
  ref.invalidate(onboardingGateProvider);
  ref.invalidate(analyticsIdentitySyncProvider);
}

class _ImportBackupConfirmScreen extends StatelessWidget {
  const _ImportBackupConfirmScreen({
    required this.preview,
    required this.backupBytes,
    required this.completeOnboardingOnSuccess,
  });

  final BackupPreview preview;
  final Uint8List backupBytes;
  final bool completeOnboardingOnSuccess;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Import Backup',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup ready to import.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Created ${_formatBackupTimestamp(preview.createdAt)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'App version ${preview.appVersion}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${preview.childCount} child profile(s) in archive',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Importing will replace current local data on this device.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => _RestoreBackupProgressScreen(
                          backupBytes: backupBytes,
                          completeOnboardingOnSuccess:
                              completeOnboardingOnSuccess,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    backgroundColor: context.appColors.accent
                  ),
                  child: const Text(
                    'Confirm Import',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestoreBackupProgressScreen extends ConsumerStatefulWidget {
  const _RestoreBackupProgressScreen({
    required this.backupBytes,
    required this.completeOnboardingOnSuccess,
  });

  final Uint8List backupBytes;
  final bool completeOnboardingOnSuccess;

  @override
  ConsumerState<_RestoreBackupProgressScreen> createState() =>
      _RestoreBackupProgressScreenState();
}

class _RestoreBackupProgressScreenState
    extends ConsumerState<_RestoreBackupProgressScreen> {
  bool _completed = false;
  String? _errorMessage;
  BackupRestoreResult? _result;

  @override
  void initState() {
    super.initState();
    _runRestore();
  }

  Future<void> _runRestore() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final result = await ref
          .read(backupServiceProvider)
          .restoreBackupBytes(widget.backupBytes);
      if (!mounted) return;
      setState(() {
        _result = result;
        _completed = true;
      });
    } on BackupException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to restore backup right now.');
    }
  }

  Future<void> _finishSuccess() async {
    if (widget.completeOnboardingOnSuccess) {
      await ref.read(onboardingGateProvider.notifier).markComplete();
    }
    _refreshAppStateAfterRestore(ref);
    if (!mounted) return;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final doneEnabled = _completed || _errorMessage != null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_completed)
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFDFF4E4),
                          child: Icon(
                            Icons.check,
                            size: 50,
                            color: Color(0xFF2F7D32),
                          ),
                        )
                      else if (_errorMessage != null)
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFFDE2E2),
                          child: Icon(
                            Icons.close,
                            size: 36,
                            color: Color(0xFFD64545),
                          ),
                        )
                      else
                        const SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(strokeWidth: 6),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        _completed
                            ? 'Backup imported successfully.'
                            : _errorMessage != null
                            ? 'Backup import failed.'
                            : 'Restoring backup now...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_completed && _errorMessage == null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(minHeight: 10),
                        ),
                      if (_completed)
                        Text(
                          'Restored ${_result?.restoredChildCount ?? 0} child profile(s).',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: const Color(0xFFD64545),
                              ),
                        ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appColors.accent,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: doneEnabled
                      ? () async {
                          if (_completed) {
                            await _finishSuccess();
                            return;
                          }
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(_completed ? 'Done' : 'Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatBackupTimestamp(DateTime timestamp) {
  return DateFormat.yMMMd().add_jm().format(timestamp.toLocal());
}
