import 'dart:io';

import 'package:aegi/app/onboarding_gate.dart';
import 'package:aegi/app/providers.dart';
import 'package:aegi/data/backup/backup_service.dart';
import 'package:aegi/features/home/home_context_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ManageDataScreen extends ConsumerStatefulWidget {
  const ManageDataScreen({super.key});

  @override
  ConsumerState<ManageDataScreen> createState() => _ManageDataScreenState();
}

class _ManageDataScreenState extends ConsumerState<ManageDataScreen> {
  bool _exportBusy = false;
  bool _importLoading = false;

  Future<void> _runManualBackup() async {
    if (_exportBusy || _importLoading) return;
    setState(() => _exportBusy = true);
    try {
      final artifact = await ref
          .read(backupServiceProvider)
          .createBackupExport();
      if (!mounted) return;

      final shareBox = context.findRenderObject() as RenderBox?;
      final shareResult = await Share.shareXFiles(
        [XFile(artifact.file.path, mimeType: 'application/octet-stream')],
        subject: 'aegi backup',
        text: 'Aegi backup archive (.aegi)',
        sharePositionOrigin: shareBox == null
            ? null
            : shareBox.localToGlobal(Offset.zero) & shareBox.size,
      );

      if (shareResult.status != ShareResultStatus.dismissed) {
        await ref
            .read(backupServiceProvider)
            .recordManualBackup(artifact.preview.createdAt);
        ref.invalidate(backupStatusProvider);
      }

      if (!mounted) return;
      final message = switch (shareResult.status) {
        ShareResultStatus.success => 'Backup ready to save.',
        ShareResultStatus.dismissed => 'Backup export canceled.',
        ShareResultStatus.unavailable => 'Backup archive created.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on BackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create backup right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _exportBusy = false);
      }
    }
  }

  Future<void> _restoreFromBackup() async {
    if (_exportBusy || _importLoading) return;

    setState(() => _importLoading = true);
    try {
      final useUnfilteredPicker = defaultTargetPlatform == TargetPlatform.iOS;
      final picked = await FilePicker.platform.pickFiles(
        type: useUnfilteredPicker ? FileType.any : FileType.custom,
        allowedExtensions: useUnfilteredPicker
            ? null
            : const [backupFileExtension],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      final pickedFile = picked.files.single;
      _validateBackupFileExtension(pickedFile);
      final bytes = await _readPickedFileBytes(pickedFile);
      final backupService = ref.read(backupServiceProvider);
      final preview = await backupService.inspectBackupBytes(bytes);
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ImportBackupConfirmScreen(
            preview: preview,
            backupBytes: bytes,
            onRestoreComplete: _refreshAppStateAfterRestore,
          ),
        ),
      );
    } on BackupException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to restore backup right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _importLoading = false);
      }
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

  void _refreshAppStateAfterRestore() {
    ref.invalidate(appSettingsProvider);
    ref.invalidate(backupStatusProvider);
    ref.invalidate(activeChildContextProvider);
    ref.invalidate(allChildrenProvider);
    ref.invalidate(onboardingGateProvider);
    ref.invalidate(analyticsIdentitySyncProvider);
  }

  @override
  Widget build(BuildContext context) {
    final backupStatus = ref.watch(backupStatusProvider).asData?.value;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.chevron_left),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Backups',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inconsolata',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  child: Text(
                    'Your device may also restore app data automatically when backups are enabled. Importing a backup replaces current local data.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inconsolata',
                      // fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ManageDataTile(
                  title: 'Export Backup',
                  subtitle: _exportBusy
                      ? 'Preparing backup...'
                      : backupStatus?.lastManualBackupAt == null
                      ? 'Create and share .aegi archive'
                      : 'Last backup ${_formatBackupTimestamp(backupStatus!.lastManualBackupAt!)}',
                  onTap: _exportBusy || _importLoading ? null : _runManualBackup,
                ),
                const SizedBox(height: 8),
                _ManageDataTile(
                  title: 'Import Backup',
                  subtitle: _importLoading
                      ? 'Loading selected backup...'
                      : backupStatus?.lastRestoreAt == null
                      ? 'Import .aegi archive and replace local data'
                      : 'Last restore ${_formatBackupTimestamp(backupStatus!.lastRestoreAt!)}',
                  onTap: _exportBusy || _importLoading
                      ? null
                      : _restoreFromBackup,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (_importLoading)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0x88000000),
                child: Center(
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text('Loading backup...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontFamily: "Inconsolata"
                      )),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImportBackupConfirmScreen extends StatelessWidget {
  const _ImportBackupConfirmScreen({
    required this.preview,
    required this.backupBytes,
    required this.onRestoreComplete,
  });

  final BackupPreview preview;
  final Uint8List backupBytes;
  final VoidCallback onRestoreComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 12),
                  Text("Import Backup", style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Inconsolata',
                    fontWeight: FontWeight.w700,
                  ),),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup ready to import.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inconsolata',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Created ${_formatBackupTimestamp(preview.createdAt)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Inconsolata',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'App version ${preview.appVersion}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Inconsolata',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${preview.childCount} child profile(s) in archive',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Inconsolata',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Importing will replace current local data on this device.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inconsolata',
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _RestoreBackupProgressScreen(
                        backupBytes: backupBytes,
                        onRestoreComplete: onRestoreComplete,
                      ),
                    ),
                  );
                },
                child: const Text('Confirm Import', style: TextStyle(fontFamily: "Inconsolata"),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestoreBackupProgressScreen extends ConsumerStatefulWidget {
  const _RestoreBackupProgressScreen({
    required this.backupBytes,
    required this.onRestoreComplete,
  });

  final Uint8List backupBytes;
  final VoidCallback onRestoreComplete;

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
      widget.onRestoreComplete();
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

  @override
  Widget build(BuildContext context) {
    final doneEnabled = _completed || _errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Restoring Backup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    if (_completed)
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Color(0xFFDFF4E4),
                        child: Icon(
                          Icons.check,
                          size: 36,
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
                        fontFamily: 'Inconsolata',
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Inconsolata',
                        ),
                      ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Inconsolata',
                          color: const Color(0xFFD64545),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: doneEnabled ? () => context.go('/home') : null,
                child: Text(_completed ? 'Done' : 'Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageDataTile extends StatelessWidget {
  const _ManageDataTile({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Colors.white,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFamily: 'Inconsolata',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'Inconsolata',
          fontStyle: FontStyle.italic,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

String _formatBackupTimestamp(DateTime timestamp) {
  return DateFormat.yMMMd().add_jm().format(timestamp.toLocal());
}
