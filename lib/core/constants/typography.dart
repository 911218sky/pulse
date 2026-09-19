import 'package:flutter/material.dart';

/// Typography for Spotify-inspired compact music hierarchy.
///
/// Prefer Inter (system). Hierarchy via weight more than huge size jumps.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text styles - Dark theme
  static TextStyle displayLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: bold,
    color: color,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static TextStyle displayMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: bold,
    color: color,
    letterSpacing: -1,
    height: 1.2,
  );

  static TextStyle displaySmall(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    color: color,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static TextStyle headlineLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: bold,
    color: color,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headlineMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: color,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static TextStyle bodyLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: color,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: color,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodySmall(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: color,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle labelLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    color: color,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    color: color,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelSmall(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: medium,
    color: color,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Time display specific
  static TextStyle timeDisplay(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    color: color,
    letterSpacing: 0.5,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle timeLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: bold,
    color: color,
    letterSpacing: -1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
