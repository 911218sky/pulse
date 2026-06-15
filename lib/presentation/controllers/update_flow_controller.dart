import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/services/update_check_service.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/app_update.dart';
import 'package:pulse/presentation/widgets/common/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateCheckTrigger { automatic, manual }

enum UpdateCheckOutcome { updateAvailable, upToDate, failed, skipped }

enum _UpdatePromptAction { installNow, later, skipVersion }

class _UpdatePromptResult {
  const _UpdatePromptResult({required this.action, required this.asset});

  final _UpdatePromptAction action;
  final UpdateAsset asset;
}

/// Coordinates update checks, downloads, progress UI, and installer handoff.
class UpdateFlowController {
  const UpdateFlowController();

  static const _skippedVersionKey = 'skipped_update_version';
  static bool _isRunning = false;

  Future<UpdateCheckOutcome> checkForUpdate(
    BuildContext context, {
    UpdateCheckTrigger trigger = UpdateCheckTrigger.manual,
  }) async {
    final isManual = trigger == UpdateCheckTrigger.manual;
    final l10n = AppLocalizations.of(context);

    if (_isRunning) {
      if (isManual) AppToast.info(context, l10n.updateCheckInProgress);
      return UpdateCheckOutcome.skipped;
    }

    _isRunning = true;
    try {
      final update = await sl<UpdateCheckService>().checkForUpdate();
      if (!context.mounted) {
        return UpdateCheckOutcome.skipped;
      }

      if (update == null) {
        if (isManual) AppToast.success(context, l10n.updateUpToDate);
        return UpdateCheckOutcome.upToDate;
      }

      if (!isManual && await _isSkippedVersion(update.version)) {
        return UpdateCheckOutcome.skipped;
      }

      await sl<UpdateDownloadService>().cleanDownloadedInstallers();
      if (!context.mounted) {
        return UpdateCheckOutcome.skipped;
      }

      final promptResult = await _showUpdatePrompt(context, update);
      if (!context.mounted || promptResult == null) {
        return UpdateCheckOutcome.updateAvailable;
      }

      switch (promptResult.action) {
        case _UpdatePromptAction.installNow:
          await downloadAndOpen(
            context,
            update.selectAsset(promptResult.asset),
          );
          break;
        case _UpdatePromptAction.skipVersion:
          await _skipVersion(update.version);
          if (context.mounted) {
            AppToast.info(context, l10n.updateSkippedVersion(update.version));
          }
          break;
        case _UpdatePromptAction.later:
          break;
      }
      return UpdateCheckOutcome.updateAvailable;
    } on Exception catch (error, stackTrace) {
      AppLogger.w('UpdateFlowController', 'Update check failed: $error');
      AppLogger.d('UpdateFlowController', stackTrace.toString());
      if (isManual && context.mounted) {
        AppToast.error(context, l10n.updateCheckFailed);
      }
      return UpdateCheckOutcome.failed;
    } finally {
      _isRunning = false;
    }
  }

  Future<_UpdatePromptResult?> _showUpdatePrompt(
    BuildContext context,
    AppUpdate update,
  ) async {
    final l10n = AppLocalizations.of(context);
    final assets =
        update.availableAssets.isEmpty
            ? [update.selectedAsset]
            : update.availableAssets;
    var selectedAsset = assets.firstWhere(
      (asset) => asset.name == update.selectedAsset.name,
      orElse: () => assets.first,
    );

    return showDialog<_UpdatePromptResult>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.system_update_rounded),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.updateAvailable)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.updateAvailableMessage(
                          update.currentVersion,
                          update.version,
                          selectedAsset.name,
                        ),
                      ),
                      if (assets.length > 1) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<UpdateAsset>(
                          initialValue: selectedAsset,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.updatePackage,
                            border: const OutlineInputBorder(),
                          ),
                          items:
                              assets
                                  .map(
                                    (asset) => DropdownMenuItem(
                                      value: asset,
                                      child: Text(
                                        asset.isRecommended
                                            ? '${asset.name} (${l10n.recommended})'
                                            : asset.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (asset) {
                            if (asset != null) {
                              setState(() => selectedAsset = asset);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(
                            _UpdatePromptResult(
                              action: _UpdatePromptAction.skipVersion,
                              asset: selectedAsset,
                            ),
                          ),
                      child: Text(l10n.skipThisVersion),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(
                            _UpdatePromptResult(
                              action: _UpdatePromptAction.later,
                              asset: selectedAsset,
                            ),
                          ),
                      child: Text(l10n.maybeLater),
                    ),
                    FilledButton(
                      onPressed:
                          () => Navigator.of(context).pop(
                            _UpdatePromptResult(
                              action: _UpdatePromptAction.installNow,
                              asset: selectedAsset,
                            ),
                          ),
                      child: Text(l10n.installNow),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool> _isSkippedVersion(String version) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_skippedVersionKey) == version;
  }

  Future<void> _skipVersion(String version) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_skippedVersionKey, version);
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
    } on UpdateInstallPermissionException catch (error, stackTrace) {
      AppLogger.w(
        'UpdateFlowController',
        'Installer permission required: $error',
      );
      AppLogger.d('UpdateFlowController', stackTrace.toString());
      if (rootNavigator.mounted && dialogShown) {
        rootNavigator.pop();
      }
      if (context.mounted) {
        AppToast.warning(context, l10n.updateInstallPermissionRequired);
      }
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
