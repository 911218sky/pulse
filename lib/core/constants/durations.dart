/// Animation durations for Vercel-style smooth transitions
class AppDurations {
  AppDurations._();

  // Transition durations
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);

  // Specific animations
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration fadeIn = Duration(milliseconds: 200);
  static const Duration slideIn = Duration(milliseconds: 300);
  static const Duration progressUpdate = Duration(milliseconds: 16); // ~60fps

  // Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration saveDebounce = Duration(seconds: 5);
}
