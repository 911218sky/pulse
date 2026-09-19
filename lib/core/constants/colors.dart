import 'package:flutter/material.dart';

/// Color tokens for Spotify-inspired charcoal music chrome.
///
/// Accent stays Pulse blue — never ship Spotify Green as brand color.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Charcoal / gray ramp (dark listening + light settings)
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEAEAEA);
  static const Color gray300 = Color(0xFFA7A7A7);
  static const Color gray400 = Color(0xFFB3B3B3);
  static const Color gray500 = Color(0xFF6A6A6A);
  static const Color gray600 = Color(0xFF404040);
  static const Color gray700 = Color(0xFF333333);
  static const Color gray800 = Color(0xFF282828);
  static const Color gray900 = Color(0xFF181818);

  /// Pulse accent (Spotify-role green → Pulse blue)
  static const Color accent = Color(0xFF0070F3);
  static const Color accentLight = Color(0xFF3291FF);
  static const Color accentDark = Color(0xFF0761D1);

  static const Color blue = accent;
  static const Color blueLight = accentLight;
  static const Color blueDark = accentDark;

  static const Color success = Color(0xFF0070F3);
  static const Color error = Color(0xFFEE0000);
  static const Color errorDark = Color(0xFFC50000);
  static const Color warning = Color(0xFFF5A623);

  // Dark-first canvas
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkCard = Color(0xFF181818);
  static const Color darkInteractive = Color(0xFF1F1F1F);
  static const Color darkElevated = Color(0xFF282828);
  static const Color darkBorder = Color(0xFF292929);

  // Light theme (settings / optional)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInteractive = Color(0xFFEEEEEE);
  static const Color lightBorder = Color(0xFFEAEAEA);

  static const Color progressTrack = Color(0xFF333333);
  static const Color progressFill = Color(0xFFFFFFFF);
  static const Color progressBuffer = Color(0xFF6A6A6A);
}
