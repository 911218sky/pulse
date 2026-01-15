import 'package:flutter/material.dart';

/// Vercel-style color palette
class AppColors {
  AppColors._();

  // Primary colors - Pure black and white
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Gray scale - Vercel style
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEAEAEA);
  static const Color gray300 = Color(0xFFE1E1E1);
  static const Color gray400 = Color(0xFF999999);
  static const Color gray500 = Color(0xFF888888);
  static const Color gray600 = Color(0xFF666666);
  static const Color gray700 = Color(0xFF444444);
  static const Color gray800 = Color(0xFF333333);
  static const Color gray900 = Color(0xFF111111);

  // Accent colors (Blue)
  static const Color accent = Color(0xFF0070F3);
  static const Color accentLight = Color(0xFF3291FF);
  static const Color accentDark = Color(0xFF0761D1);

  // Alias for accent (blue theme)
  static const Color blue = accent;
  static const Color blueLight = accentLight;
  static const Color blueDark = accentDark;

  // Semantic colors
  static const Color success = Color(0xFF0070F3);
  static const Color error = Color(0xFFEE0000);
  static const Color errorDark = Color(0xFFCC0000);
  static const Color warning = Color(0xFFF5A623);

  // Dark theme specific
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF333333);

  // Light theme specific
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFEAEAEA);

  // Progress bar colors
  static const Color progressTrack = Color(0xFF333333);
  static const Color progressFill = Color(0xFFFFFFFF);
  static const Color progressBuffer = Color(0xFF666666);
}
