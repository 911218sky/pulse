import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/services/update_check_service.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/app_update.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/widgets/common/app_confirm_dialog.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Runs one silent startup update check when the user enables it.
class UpdateCheckSync extends StatefulWidget {
  const UpdateCheckSync({required this.child, super.key});

  final Widget child;

  @override
  State<UpdateCheckSync> createState() => _UpdateCheckSyncState();
}

class _UpdateCheckSyncState extends State<UpdateCheckSync> {
  bool _hasChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeCheckForUpdate(context.read<SettingsBloc>().state);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SettingsBloc, SettingsState>(
        listenWhen:
            (previous, current) =>
                previous.status != current.status ||
                previous.settings.autoUpdateEnabled !=
                    current.settings.autoUpdateEnabled,
        listener: (context, state) => _maybeCheckForUpdate(state),
        child: widget.child,
      );

  void _maybeCheckForUpdate(SettingsState state) {
    if (_hasChecked ||
        state.status != SettingsStatus.loaded ||
        !state.settings.autoUpdateEnabled) {
      return;
    }

    _hasChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final update = await sl<UpdateCheckService>().checkForUpdate();
      if (update == null || !mounted) return;

      final l10n = AppLocalizations.of(context);
      final confirmed = await AppConfirmDialog.show(
        context,
        title: l10n.updateAvailable,
        message: l10n.updateAvailableMessage(
          update.currentVersion,
          update.version,
          update.assetName,
        ),
        confirmLabel: l10n.downloadUpdate,
        cancelLabel: l10n.maybeLater,
        tone: AppConfirmDialogTone.warning,
        icon: Icons.system_update_rounded,
      );

      if (confirmed && mounted) {
        await _downloadAndOpen(update);
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.w('UpdateCheckSync', 'Update check skipped: $error');
      AppLogger.d('UpdateCheckSync', stackTrace.toString());
    }
  }

  Future<void> _downloadAndOpen(AppUpdate update) async {
    final l10n = AppLocalizations.of(context);

    if (!update.canDownloadDirectly) {
      await launchUrl(update.releaseUrl, mode: LaunchMode.externalApplication);
      return;
    }

    final progress = ValueNotifier<int?>(null);
    var dialogShown = false;

    try {
      if (!mounted) return;
      dialogShown = true;
      unawaited(_showDownloadProgressDialog(progress));

      final file = await sl<UpdateDownloadService>().download(
        update,
        onProgress: (received, total) {
          if (total == null || total <= 0) {
            progress.value = null;
          } else {
            progress.value = ((received / total) * 100).clamp(0, 100).round();
          }
        },
      );

      if (mounted && dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
      if (mounted) AppToast.success(context, l10n.updateDownloadComplete);

      await sl<UpdateDownloadService>().openInstaller(file);
    } on Exception catch (error, stackTrace) {
      AppLogger.e(
        'UpdateCheckSync',
        'Update download failed',
        error,
        stackTrace,
      );
      if (mounted && dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) AppToast.error(context, l10n.updateDownloadFailed);
      await launchUrl(update.downloadUrl, mode: LaunchMode.externalApplication);
    } finally {
      progress.dispose();
    }
  }

  Future<void> _showDownloadProgressDialog(ValueNotifier<int?> progress) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => ValueListenableBuilder<int?>(
            valueListenable: progress,
            builder: (context, percent, _) {
              final hasPercent = percent != null;
              return AlertDialog(
                title: Text(l10n.downloadUpdate),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPercent
                          ? l10n.updateDownloadProgress(percent)
                          : l10n.updateDownloadPreparing,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: hasPercent ? percent / 100 : null,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
