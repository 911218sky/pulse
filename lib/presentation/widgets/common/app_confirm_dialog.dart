import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';
import 'package:pulse/core/constants/typography.dart';
import 'package:pulse/core/theme/app_theme_tokens.dart';

enum AppConfirmDialogTone { danger, warning }

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    super.key,
    this.tone = AppConfirmDialogTone.danger,
    this.icon = Icons.warning_rounded,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final AppConfirmDialogTone tone;
  final IconData icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    AppConfirmDialogTone tone = AppConfirmDialogTone.danger,
    IconData icon = Icons.warning_rounded,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder:
            (_) => AppConfirmDialog(
              title: title,
              message: message,
              confirmLabel: confirmLabel,
              cancelLabel: cancelLabel,
              tone: tone,
              icon: icon,
            ),
      ) ??
      false;

  Color get _accentColor =>
      tone == AppConfirmDialogTone.warning
          ? AppColors.warning
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AlertDialog(
      backgroundColor: palette.elevatedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: palette.subtleBorder),
      ),
      title: Row(
        children: [
          Icon(icon, color: _accentColor, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.headlineLarge(_accentColor),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium(palette.secondaryText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: AppTypography.labelLarge(palette.secondaryText),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: _accentColor),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
