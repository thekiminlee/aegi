import 'package:aegi/app/providers.dart';
import 'package:aegi/data/backup/backup_service.dart';
import 'package:aegi/features/backup/backup_import_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ShareResultStatus.success => 'Backup saved to device.',
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
      await startBackupImportFlow(
        context: context,
        ref: ref,
        completeOnboardingOnSuccess: true,
      );
    } finally {
      if (mounted) {
        setState(() => _importLoading = false);
      }
    }
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
                    const SizedBox(width: 12),
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
                  child: Text(
                    'Your device may also restore app data automatically when backups are enabled. Importing a backup replaces current local data.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inconsolata',
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
                  onTap: _exportBusy || _importLoading
                      ? null
                      : _runManualBackup,
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
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x88000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Loading backup...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inconsolata',
                        ),
                      ),
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
