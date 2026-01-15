import 'package:equatable/equatable.dart';

/// Represents a sleep timer that pauses playback after a duration
class SleepTimer extends Equatable {
  const SleepTimer({
    required this.duration,
    required this.startedAt,
    this.fadeOutEnabled = true,
  });

  /// Creates a new sleep timer starting now
  factory SleepTimer.start({
    required Duration duration,
    bool fadeOutEnabled = true,
  }) => SleepTimer(
    duration: duration,
    startedAt: DateTime.now(),
    fadeOutEnabled: fadeOutEnabled,
  );

  final Duration duration;
  final DateTime startedAt;
  final bool fadeOutEnabled;

  /// Returns the remaining time until the timer expires
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns true if the timer has expired
  bool get isExpired => remainingTime == Duration.zero;

  /// Returns the elapsed time since the timer started
  Duration get elapsedTime => DateTime.now().difference(startedAt);

  /// Returns progress as a value between 0.0 and 1.0
  double get progress {
    if (duration.inMilliseconds == 0) return 1;
    final elapsed = elapsedTime.inMilliseconds;
    final total = duration.inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Preset durations for quick selection
  static const List<Duration> presets = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
    Duration(minutes: 90),
  ];

  @override
  List<Object?> get props => [duration, startedAt, fadeOutEnabled];
}
