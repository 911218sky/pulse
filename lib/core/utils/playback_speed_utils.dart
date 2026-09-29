/// Utility class for playback speed operations
class PlaybackSpeedUtils {
  PlaybackSpeedUtils._();

  /// Minimum playback speed
  static const double minSpeed = 0.5;

  /// Maximum playback speed
  static const double maxSpeed = 2;

  /// Default playback speed (normal)
  static const double defaultSpeed = 1;

  /// Fine step for custom slider / +/- adjustments (0.05x)
  static const double fineStep = 0.05;

  /// Coarse step used by preset navigation helpers
  static const double speedStep = 0.25;

  /// Slider divisions for [minSpeed, maxSpeed] at [fineStep]
  static int get sliderDivisions => ((maxSpeed - minSpeed) / fineStep).round();

  /// Preset speed values for quick selection
  static const List<double> presets = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  /// Clamps a speed value to the valid range [0.5, 2.0]
  static double clamp(double speed) => speed.clamp(minSpeed, maxSpeed);

  /// Snaps a speed to the nearest fine step within the valid range
  static double quantize(double speed, {double step = fineStep}) {
    final clamped = clamp(speed);
    final steps = ((clamped - minSpeed) / step).round();
    // Round to avoid binary float noise (e.g. 1.1500000000000001)
    final quantized = minSpeed + steps * step;
    return double.parse(quantized.toStringAsFixed(2));
  }

  /// Increases speed by the step amount, clamped and quantized
  static double increase(double currentSpeed, {double step = fineStep}) =>
      quantize(currentSpeed + step, step: step);

  /// Decreases speed by the step amount, clamped and quantized
  static double decrease(double currentSpeed, {double step = fineStep}) =>
      quantize(currentSpeed - step, step: step);

  /// Returns true if two speeds are effectively equal
  static bool nearlyEquals(double a, double b, {double epsilon = 0.001}) =>
      (a - b).abs() < epsilon;

  /// Returns true if speed is at normal (1.0x)
  static bool isNormalSpeed(double speed) => nearlyEquals(speed, defaultSpeed);

  /// Returns true if speed is at minimum
  static bool isMinSpeed(double speed) => speed <= minSpeed + 0.001;

  /// Returns true if speed is at maximum
  static bool isMaxSpeed(double speed) => speed >= maxSpeed - 0.001;

  /// Formats speed as a display string (e.g., "1.5x")
  static String format(double speed) {
    final clamped = quantize(speed);
    // Remove trailing zeros for cleaner display
    if (clamped == clamped.roundToDouble()) {
      return '${clamped.toInt()}x';
    }
    return '${clamped.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}x';
  }

  /// Gets the next preset speed (cycles through presets)
  static double nextPreset(double currentSpeed) {
    final exactIndex = presets.indexWhere((s) => nearlyEquals(s, currentSpeed));
    if (exactIndex != -1) {
      return presets[(exactIndex + 1) % presets.length];
    }
    final nextIndex = presets.indexWhere((s) => s > currentSpeed + 0.001);
    if (nextIndex == -1) {
      return presets.first;
    }
    return presets[nextIndex];
  }

  /// Gets the previous preset speed (cycles through presets)
  static double previousPreset(double currentSpeed) {
    final exactIndex = presets.indexWhere((s) => nearlyEquals(s, currentSpeed));
    if (exactIndex != -1) {
      return presets[(exactIndex - 1 + presets.length) % presets.length];
    }
    final prevIndex = presets.lastIndexWhere((s) => s < currentSpeed - 0.001);
    if (prevIndex == -1) {
      return presets.last;
    }
    return presets[prevIndex];
  }

  /// Calculates adjusted duration based on playback speed
  /// Returns how long content will take to play at the given speed
  static Duration adjustedDuration(Duration originalDuration, double speed) {
    if (speed <= 0) return originalDuration;
    final adjustedMs = (originalDuration.inMilliseconds / speed).round();
    return Duration(milliseconds: adjustedMs);
  }
}
