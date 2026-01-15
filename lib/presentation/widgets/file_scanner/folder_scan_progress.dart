import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/presentation/widgets/common/vercel_button.dart';

/// A widget showing the progress of folder scanning
class FolderScanProgress extends StatelessWidget {
  const FolderScanProgress({
    required this.currentFolder,
    required this.filesFound,
    super.key,
    this.progress,
    this.isScanning = false,
    this.isDark,
    this.onCancel,
  });

  final String currentFolder;
  final int filesFound;
  final double? progress;
  final bool isScanning;
  final bool? isDark;
  final VoidCallback? onCancel;

  bool _isDark(BuildContext context) =>
      isDark ?? Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: dark ? AppColors.gray900 : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: dark ? AppColors.gray700 : AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (isScanning)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      dark ? AppColors.white : AppColors.accent,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.check_circle_rounded,
                  color: dark ? AppColors.success : AppColors.accent,
                  size: 20,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isScanning ? l10n.scanning : l10n.scanComplete,
                  style: TextStyle(
                    color: dark ? AppColors.white : AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isScanning && onCancel != null)
                VercelButton(
                  label: l10n.cancel,
                  variant: VercelButtonVariant.ghost,
                  size: VercelButtonSize.small,
                  isDark: dark,
                  onPressed: onCancel,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: dark ? AppColors.gray700 : AppColors.gray300,
                valueColor: AlwaysStoppedAnimation(
                  dark ? AppColors.white : AppColors.accent,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            currentFolder,
            style: TextStyle(
              color: dark ? AppColors.gray400 : AppColors.gray600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.filesFound(filesFound),
            style: TextStyle(
              color: dark ? AppColors.gray400 : AppColors.gray600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact scanning indicator
class ScanningIndicator extends StatelessWidget {
  const ScanningIndicator({super.key, this.filesFound = 0, this.isDark});

  final int filesFound;
  final bool? isDark;

  bool _isDark(BuildContext context) =>
      isDark ?? Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.gray900 : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                dark ? AppColors.white : AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${l10n.scanning} ($filesFound)',
            style: TextStyle(
              color: dark ? AppColors.gray300 : AppColors.gray700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
