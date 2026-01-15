/// Utility class for playback speed operations
class PlaybackSpeedUtils {
  PlaybackSpeedUtils._();

  /// Minimum playback speed
  static const double minSpeed = 0.5;

  /// Maximum playback speed
  static const double maxSpeed = 2;

  /// Default playback speed (normal)
  static const double defaultSpeed = 1;

  /// Speed step for increment/decrement operations
  static const double speedStep = 0.25;

  /// Preset speed values
  static const List<double> presets = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  /// Clamps a speed value to the valid range [0.5, 2.0]
  static double clamp(double speed) => speed.clamp(minSpeed, maxSpeed);

  /// Increases speed by the step amount, clamped to max
  static double increase(double currentSpeed, {double step = speedStep}) =>
      clamp(currentSpeed + step);

  /// Decreases speed by the step amount, clamped to min
  static double decrease(double currentSpeed, {double step = speedStep}) =>
      clamp(currentSpeed - step);

  /// Returns true if speed is at normal (1.0x)
  static bool isNormalSpeed(double speed) =>
      (speed - defaultSpeed).abs() < 0.01;

  /// Returns true if speed is at minimum
  static bool isMinSpeed(double speed) => speed <= minSpeed;

  /// Returns true if speed is at maximum
  static bool isMaxSpeed(double speed) => speed >= maxSpeed;

  /// Formats speed as a display string (e.g., "1.5x")
  static String format(double speed) {
    final clamped = clamp(speed);
    // Remove trailing zeros for cleaner display
    if (clamped == clamped.roundToDouble()) {
      return '${clamped.toInt()}x';
    }
    return '${clamped.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}x';
  }

  /// Gets the next preset speed (cycles through presets)
  static double nextPreset(double currentSpeed) {
    final currentIndex = presets.indexWhere((s) => s >= currentSpeed);
    if (currentIndex == -1 || currentIndex == presets.length - 1) {
      return presets.first;
    }
    return presets[currentIndex + 1];
  }

  /// Gets the previous preset speed (cycles through presets)
  static double previousPreset(double currentSpeed) {
    final currentIndex = presets.lastIndexWhere((s) => s <= currentSpeed);
    if (currentIndex <= 0) {
      return presets.last;
    }
    return presets[currentIndex - 1];
  }

  /// Calculates adjusted duration based on playback speed
  /// Returns how long content will take to play at the given speed
  static Duration adjustedDuration(Duration originalDuration, double speed) {
    if (speed <= 0) return originalDuration;
    final adjustedMs = (originalDuration.inMilliseconds / speed).round();
    return Duration(milliseconds: adjustedMs);
  }
}
