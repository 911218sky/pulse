/// Utility class for volume-related operations
class VolumeUtils {
  VolumeUtils._();

  /// Minimum volume value
  static const double minVolume = 0;

  /// Maximum volume value
  static const double maxVolume = 1;

  /// Default volume value
  static const double defaultVolume = 1;

  /// Volume step for increment/decrement operations
  static const double volumeStep = 0.05;

  /// Clamps a volume value to the valid range [0.0, 1.0]
  static double clamp(double volume) => volume.clamp(minVolume, maxVolume);

  /// Increases volume by the step amount, clamped to max
  static double increase(double currentVolume, {double step = volumeStep}) =>
      clamp(currentVolume + step);

  /// Decreases volume by the step amount, clamped to min
  static double decrease(double currentVolume, {double step = volumeStep}) =>
      clamp(currentVolume - step);

  /// Converts volume (0.0-1.0) to percentage (0-100)
  static int toPercentage(double volume) => (clamp(volume) * 100).round();

  /// Converts percentage (0-100) to volume (0.0-1.0)
  static double fromPercentage(int percentage) => clamp(percentage / 100.0);

  /// Returns true if volume is muted (0)
  static bool isMuted(double volume) => volume <= 0.0;

  /// Returns true if volume is at maximum
  static bool isMaxVolume(double volume) => volume >= maxVolume;

  /// Formats volume as a percentage string
  static String formatAsPercentage(double volume) => '${toPercentage(volume)}%';

  /// Calculates fade-out volume for sleep timer
  /// progress: 0.0 (start) to 1.0 (end of fade)
  static double calculateFadeOutVolume(double originalVolume, double progress) {
    final fadeProgress = progress.clamp(0.0, 1.0);
    return originalVolume * (1.0 - fadeProgress);
  }
}
