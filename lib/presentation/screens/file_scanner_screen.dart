import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';
import 'package:pulse/presentation/widgets/file_scanner/file_import_dialog.dart';
import 'package:pulse/presentation/widgets/file_scanner/folder_scan_progress.dart';
import 'package:pulse/presentation/widgets/file_scanner/folder_selection_list.dart';

/// Screen for scanning and selecting music folders
class FileScannerScreen extends StatelessWidget {
  const FileScannerScreen({super.key, this.onBack, this.onComplete});

  final VoidCallback? onBack;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: onBack, isDark: isDark),
            Expanded(
              child: BlocBuilder<FileScannerBloc, FileScannerState>(
                builder: (context, state) {
                  switch (state.status) {
                    case FileScannerStatus.initial:
                      return _InitialState(
                        isDark: isDark,
                        onStartScan: () {
                          context.read<FileScannerBloc>().add(
                            const FileScannerStartScan(),
                          );
                        },
                      );
                    case FileScannerStatus.loading:
                    case FileScannerStatus.scanning:
                      return _ScanningState(
                        isDark: isDark,
                        progress: state.scanProgress,
                        onCancel: () {
                          context.read<FileScannerBloc>().add(
                            const FileScannerCancelScan(),
                          );
                        },
                      );
                    case FileScannerStatus.completed:
                      return _CompletedState(
                        state: state,
                        isDark: isDark,
                        onComplete: onComplete,
                      );
                    case FileScannerStatus.error:
                      return _ErrorState(
                        isDark: isDark,
                        message:
                            state.errorMessage ??
                            AppLocalizations.of(context).unknownError,
                        onRetry: () {
                          context.read<FileScannerBloc>().add(
                            const FileScannerStartScan(),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark, this.onBack});

  final bool isDark;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: isDark ? AppColors.white : AppColors.black,
              onPressed: onBack,
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.scanMusic,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState({required this.isDark, required this.onStartScan});

  final bool isDark;
  final VoidCallback onStartScan;

  Future<bool> _requestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final l10n = AppLocalizations.of(context);

    // Android 13+ needs READ_MEDIA_AUDIO
    // Android 12 and below needs READ_EXTERNAL_STORAGE
    final status = await Permission.audio.request();
    if (status.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) return true;

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.storagePermissionRequired),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [AppColors.gray800, AppColors.gray900]
                          : [
                            AppColors.accentLight.withValues(alpha: 0.2),
                            AppColors.accent.withValues(alpha: 0.3),
                          ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                color: isDark ? AppColors.gray400 : AppColors.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.addMusic,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.addMusicDesc,
              style: TextStyle(
                color: isDark ? AppColors.gray500 : AppColors.gray600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            VercelButton(
              label: l10n.autoScan,
              icon: Icons.search_rounded,
              isDark: isDark,
              onPressed: () async {
                final hasPermission = await _requestPermissions(context);
                if (hasPermission) {
                  onStartScan();
                }
              },
              fullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            VercelButton(
              label: l10n.manualImport,
              icon: Icons.add_rounded,
              variant: VercelButtonVariant.secondary,
              isDark: isDark,
              fullWidth: true,
              onPressed: () => _showImportDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final result = await FileImportDialog.show(context);
    if (result != null && !result.isEmpty && context.mounted) {
      context.read<FileScannerBloc>().add(
        FileScannerImportFiles(files: result.files, folders: result.folders),
      );
    }
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState({
    required this.isDark,
    required this.progress,
    required this.onCancel,
  });

  final bool isDark;
  final ScanProgress? progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FolderScanProgress(
            currentFolder: progress?.currentFolder ?? l10n.scanning,
            filesFound: progress?.filesFound ?? 0,
            isScanning: true,
            isDark: isDark,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.state,
    required this.isDark,
    this.onComplete,
  });

  final FileScannerState state;
  final bool isDark;
  final VoidCallback? onComplete;

  Future<void> _showImportDialog(BuildContext context) async {
    final result = await FileImportDialog.show(context);
    if (result != null && !result.isEmpty && context.mounted) {
      context.read<FileScannerBloc>().add(
        FileScannerImportFiles(files: result.files, folders: result.folders),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: FolderScanProgress(
                  currentFolder: l10n.scanComplete,
                  filesFound: state.totalFilesFound,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _AddMoreButton(
                isDark: isDark,
                onTap: () => _showImportDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: FolderSelectionList(
            folders: state.folders,
            isDark: isDark,
            onToggle: (path) {
              context.read<FileScannerBloc>().add(
                FileScannerToggleFolder(path),
              );
            },
            onSelectAll: () {
              context.read<FileScannerBloc>().add(const FileScannerSelectAll());
            },
            onDeselectAll: () {
              context.read<FileScannerBloc>().add(
                const FileScannerDeselectAll(),
              );
            },
          ),
        ),
        FolderSelectionSummary(
          selectedCount: state.selectedFolders.length,
          totalFileCount: state.selectedFilesCount,
          isDark: isDark,
          onSave: () {
            context.read<FileScannerBloc>().add(
              const FileScannerSaveSelection(),
            );
            onComplete?.call();
          },
        ),
      ],
    );
  }
}

class _AddMoreButton extends StatefulWidget {
  const _AddMoreButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_AddMoreButton> createState() => _AddMoreButtonState();
}

class _AddMoreButtonState extends State<_AddMoreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered
                    ? (widget.isDark
                        ? AppColors.gray800
                        : AppColors.accent.withValues(alpha: 0.1))
                    : (widget.isDark ? AppColors.gray900 : AppColors.gray100),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  _isHovered
                      ? (widget.isDark ? AppColors.gray600 : AppColors.accent)
                      : (widget.isDark ? AppColors.gray800 : AppColors.gray200),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                color:
                    _isHovered
                        ? (widget.isDark ? AppColors.white : AppColors.accent)
                        : (widget.isDark
                            ? AppColors.gray400
                            : AppColors.gray600),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.addMore,
                style: TextStyle(
                  color:
                      _isHovered
                          ? (widget.isDark ? AppColors.white : AppColors.accent)
                          : (widget.isDark
                              ? AppColors.gray400
                              : AppColors.gray600),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.scanFailed,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: TextStyle(
                color: isDark ? AppColors.gray500 : AppColors.gray600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            VercelButton(
              label: l10n.retry,
              icon: Icons.refresh_rounded,
              isDark: isDark,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
