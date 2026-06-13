import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';

/// Theme-aware color tokens for custom widgets that do not use Material styles.
extension AppThemeTokens on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  AppThemePalette get appPalette =>
      isDarkMode ? AppThemePalette.dark : AppThemePalette.light;
}

class AppThemePalette {
  const AppThemePalette({
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.disabledText,
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.border,
    required this.subtleBorder,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color disabledText;
  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color border;
  final Color subtleBorder;

  static const dark = AppThemePalette(
    primaryText: AppColors.white,
    secondaryText: AppColors.gray400,
    mutedText: AppColors.gray500,
    disabledText: AppColors.gray600,
    background: AppColors.black,
    surface: AppColors.darkSurface,
    elevatedSurface: AppColors.gray900,
    border: AppColors.gray700,
    subtleBorder: AppColors.gray800,
  );

  static const light = AppThemePalette(
    primaryText: AppColors.gray900,
    secondaryText: AppColors.gray600,
    mutedText: AppColors.gray500,
    disabledText: AppColors.gray400,
    background: AppColors.white,
    surface: AppColors.lightSurface,
    elevatedSurface: AppColors.white,
    border: AppColors.gray300,
    subtleBorder: AppColors.gray200,
  );
}
