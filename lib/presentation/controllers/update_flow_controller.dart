import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/services/update_check_service.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/app_update.dart';
import 'package:pulse/presentation/widgets/common/app_confirm_dialog.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateCheckTrigger { automatic, manual }

/// Coordinates update checks, downloads, progress UI, and installer handoff.
class UpdateFlowController {
  const UpdateFlowController();

  static bool _isRunning = false;

  Future<void> checkForUpdate(
    BuildContext context, {
    UpdateCheckTrigger trigger = UpdateCheckTrigger.manual,
  }) async {
    final isManual = trigger == UpdateCheckTrigger.manual;
    final l10n = AppLocalizations.of(context);

    if (_isRunning) {
      if (isManual) AppToast.info(context, l10n.updateCheckInProgress);
      return;
    }

    _isRunning = true;
    try {
      final update = await sl<UpdateCheckService>().checkForUpdate();
      if (!context.mounted) return;

      if (update == null) {
        if (isManual) AppToast.success(context, l10n.updateUpToDate);
        return;
      }

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

      if (confirmed && context.mounted) {
        await downloadAndOpen(context, update);
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.w('UpdateFlowController', 'Update check failed: $error');
      AppLogger.d('UpdateFlowController', stackTrace.toString());
      if (isManual && context.mounted) {
        AppToast.error(context, l10n.updateCheckFailed);
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> downloadAndOpen(BuildContext context, AppUpdate update) async {
    final l10n = AppLocalizations.of(context);

    if (!update.canDownloadDirectly) {
      await launchUrl(update.releaseUrl, mode: LaunchMode.externalApplication);
      return;
    }

    final progress = ValueNotifier<int?>(null);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var dialogShown = false;

    try {
      if (!context.mounted) return;
      dialogShown = true;
      unawaited(_showDownloadProgressDialog(rootNavigator.context, progress));

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

      if (rootNavigator.mounted && dialogShown) {
        rootNavigator.pop();
        dialogShown = false;
      }
      if (context.mounted) {
        AppToast.success(context, l10n.updateDownloadComplete);
      }

      await sl<UpdateDownloadService>().openInstaller(file);
    } on Exception catch (error, stackTrace) {
      AppLogger.e(
        'UpdateFlowController',
        'Update download failed',
        error,
        stackTrace,
      );
      if (rootNavigator.mounted && dialogShown) {
        rootNavigator.pop();
      }
      if (context.mounted) AppToast.error(context, l10n.updateDownloadFailed);
      await launchUrl(update.downloadUrl, mode: LaunchMode.externalApplication);
    } finally {
      progress.dispose();
    }
  }

  Future<void> _showDownloadProgressDialog(
    BuildContext context,
    ValueNotifier<int?> progress,
  ) async {
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
