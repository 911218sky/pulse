/// Vercel-style 8px grid spacing system
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double unit = 8;

  // Spacing values
  static const double xs = 4; // 0.5x
  static const double sm = 8; // 1x
  static const double md = 16; // 2x
  static const double lg = 24; // 3x
  static const double xl = 32; // 4x
  static const double xxl = 48; // 6x

  // Component specific
  static const double buttonPaddingH = 16;
  static const double buttonPaddingV = 12;
  static const double cardPadding = 24;
  static const double screenPadding = 24;
  static const double listItemSpacing = 12;

  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 9999;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Progress bar
  static const double progressBarHeight = 4;
  static const double progressBarHeightExpanded = 8;
  static const double progressThumbSize = 12;
}
