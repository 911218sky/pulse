import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/constants/spacing.dart';

/// Toast notification types
enum ToastType {
  /// Success notification (green)
  success,

  /// Error notification (red)
  error,

  /// Info notification (blue/accent)
  info,

  /// Warning notification (yellow/orange)
  warning,
}

/// Shared toast notification component for consistent app-wide notifications
class AppToast {
  AppToast._();

  /// Show a toast notification
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (backgroundColor, icon, iconColor) = getStyleForType(
      type,
      isDark: isDark,
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        dismissDirection: DismissDirection.horizontal,
        elevation: 8,
        onVisible: onDismiss,
      ),
    );
  }

  /// Get styling for a toast type
  static (Color, IconData, Color) getStyleForType(
    ToastType type, {
    required bool isDark,
  }) => switch (type) {
    ToastType.success => (
      isDark ? AppColors.success.withValues(alpha: 0.95) : AppColors.success,
      Icons.check_circle_rounded,
      AppColors.white,
    ),
    ToastType.error => (
      isDark ? AppColors.error.withValues(alpha: 0.95) : AppColors.error,
      Icons.error_rounded,
      AppColors.white,
    ),
    ToastType.warning => (
      isDark ? AppColors.warning.withValues(alpha: 0.95) : AppColors.warning,
      Icons.warning_rounded,
      AppColors.black,
    ),
    ToastType.info => (
      isDark ? AppColors.accent.withValues(alpha: 0.95) : AppColors.accent,
      Icons.info_rounded,
      AppColors.white,
    ),
  };

  /// Show a success toast
  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  /// Show an error toast
  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  /// Show an info toast
  static void info(BuildContext context, String message) {
    show(context, message: message);
  }

  /// Show a warning toast
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }
}
