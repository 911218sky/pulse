/// Utility class for parsing and formatting time/duration values
class TimeParser {
  TimeParser._();

  /// Parses a time string into a Duration
  /// Supports formats: "HH:MM:SS", "MM:SS", "SS", "H:MM:SS"
  /// Returns null if the string is invalid
  static Duration? parse(String timeString) {
    final trimmed = timeString.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');

    try {
      switch (parts.length) {
        case 1:
          // Just seconds: "SS"
          final seconds = int.parse(parts[0]);
          if (seconds < 0) return null;
          return Duration(seconds: seconds);

        case 2:
          // Minutes and seconds: "MM:SS"
          final minutes = int.parse(parts[0]);
          final seconds = int.parse(parts[1]);
          if (minutes < 0 || seconds < 0 || seconds >= 60) return null;
          return Duration(minutes: minutes, seconds: seconds);

        case 3:
          // Hours, minutes, and seconds: "HH:MM:SS" or "H:MM:SS"
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          if (hours < 0 || minutes < 0 || seconds < 0) return null;
          if (minutes >= 60 || seconds >= 60) return null;
          return Duration(hours: hours, minutes: minutes, seconds: seconds);

        default:
          return null;
      }
    } on FormatException {
      return null;
    }
  }

  /// Creates a Duration from hours, minutes, and seconds
  static Duration fromHMS(int hours, int minutes, int seconds) =>
      Duration(hours: hours, minutes: minutes, seconds: seconds);

  /// Validates if a time is within the valid range (0 to maxDuration)
  static bool isValidTime(Duration time, Duration maxDuration) =>
      time >= Duration.zero && time <= maxDuration;

  /// Formats a Duration as a time string
  /// Returns "HH:MM:SS" for durations >= 1 hour, "MM:SS" otherwise
  static String format(Duration duration) {
    final isNegative = duration.isNegative;
    final absolute = duration.abs();

    final hours = absolute.inHours;
    final minutes = absolute.inMinutes.remainder(60);
    final seconds = absolute.inSeconds.remainder(60);

    final prefix = isNegative ? '-' : '';

    if (hours > 0) {
      return '$prefix${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$prefix${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Alias for format method
  static String formatDuration(Duration duration) => format(duration);

  /// Formats a Duration with milliseconds precision
  /// Returns "HH:MM:SS.mmm" or "MM:SS.mmm"
  static String formatWithMilliseconds(Duration duration) {
    final base = format(duration);
    final milliseconds = duration.inMilliseconds.remainder(1000);
    return '$base.${milliseconds.toString().padLeft(3, '0')}';
  }

  /// Formats a Duration for display (compact format)
  /// Returns "Xh Ym" for long durations, "Xm Ys" for shorter ones
  static String formatCompact(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Parses hours, minutes, seconds from separate string inputs
  /// Returns null if any value is invalid
  static Duration? parseHMS(String hours, String minutes, String seconds) {
    try {
      final h = hours.isEmpty ? 0 : int.parse(hours);
      final m = minutes.isEmpty ? 0 : int.parse(minutes);
      final s = seconds.isEmpty ? 0 : int.parse(seconds);

      if (h < 0 || m < 0 || s < 0) return null;
      if (m >= 60 || s >= 60) return null;

      return Duration(hours: h, minutes: m, seconds: s);
    } on FormatException {
      return null;
    }
  }

  /// Extracts hours component from a Duration
  static int getHours(Duration duration) => duration.inHours;

  /// Extracts minutes component (0-59) from a Duration
  static int getMinutes(Duration duration) => duration.inMinutes.remainder(60);

  /// Extracts seconds component (0-59) from a Duration
  static int getSeconds(Duration duration) => duration.inSeconds.remainder(60);
}
