import 'package:flutter/material.dart';
import 'package:pulse/core/constants/colors.dart';

/// Theme-aware tokens for Spotify-inspired charcoal music chrome.
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
    required this.interactive,
    required this.elevatedSurface,
    required this.border,
    required this.subtleBorder,
    required this.rowHover,
    required this.rowActive,
    required this.divider,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color disabledText;
  final Color background;
  final Color surface;
  final Color interactive;
  final Color elevatedSurface;
  final Color border;
  final Color subtleBorder;
  final Color rowHover;
  final Color rowActive;
  final Color divider;

  static const dark = AppThemePalette(
    primaryText: AppColors.white,
    secondaryText: AppColors.gray400,
    mutedText: AppColors.gray300,
    disabledText: AppColors.gray500,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    interactive: AppColors.darkInteractive,
    elevatedSurface: AppColors.darkElevated,
    border: AppColors.darkBorder,
    subtleBorder: AppColors.darkBorder,
    rowHover: Color(0x14FFFFFF),
    rowActive: Color(0x1A0070F3),
    divider: Color(0x14FFFFFF),
  );

  static const light = AppThemePalette(
    primaryText: AppColors.black,
    secondaryText: AppColors.gray500,
    mutedText: AppColors.gray300,
    disabledText: AppColors.gray300,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    interactive: AppColors.lightInteractive,
    elevatedSurface: AppColors.white,
    border: AppColors.lightBorder,
    subtleBorder: AppColors.gray200,
    rowHover: Color(0x0A000000),
    rowActive: Color(0x140070F3),
    divider: Color(0x14000000),
  );
}
