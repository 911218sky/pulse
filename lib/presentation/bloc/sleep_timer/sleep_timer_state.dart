import 'package:equatable/equatable.dart';

/// Status of the sleep timer
enum SleepTimerStatus { inactive, active, expired }

/// State for SleepTimerBloc
class SleepTimerState extends Equatable {
  const SleepTimerState({
    this.status = SleepTimerStatus.inactive,
    this.totalDuration = Duration.zero,
    this.remainingDuration = Duration.zero,
    this.fadeOutEnabled = true,
    this.fadeOutSeconds = 5,
  });

  final SleepTimerStatus status;
  final Duration totalDuration;
  final Duration remainingDuration;
  final bool fadeOutEnabled;
  final int fadeOutSeconds;

  /// Whether the timer is currently active
  bool get isActive => status == SleepTimerStatus.active;

  /// Progress as a value between 0.0 (just started) and 1.0 (expired)
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0;
    final elapsed = totalDuration - remainingDuration;
    return (elapsed.inMilliseconds / totalDuration.inMilliseconds).clamp(0, 1);
  }

  /// Remaining progress (1.0 at start, 0.0 at end)
  double get remainingProgress => 1 - progress;

  /// Whether fade out should be applied (last N seconds based on fadeOutSeconds)
  bool get shouldFadeOut {
    if (!fadeOutEnabled) return false;
    return remainingDuration.inSeconds <= fadeOutSeconds && isActive;
  }

  /// Fade out progress (0.0 at fadeOutSeconds remaining, 1.0 at 0s remaining)
  double get fadeOutProgress {
    if (!shouldFadeOut || fadeOutSeconds == 0) return 0;
    return 1 - (remainingDuration.inSeconds / fadeOutSeconds).clamp(0, 1);
  }

  SleepTimerState copyWith({
    SleepTimerStatus? status,
    Duration? totalDuration,
    Duration? remainingDuration,
    bool? fadeOutEnabled,
    int? fadeOutSeconds,
  }) => SleepTimerState(
    status: status ?? this.status,
    totalDuration: totalDuration ?? this.totalDuration,
    remainingDuration: remainingDuration ?? this.remainingDuration,
    fadeOutEnabled: fadeOutEnabled ?? this.fadeOutEnabled,
    fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
  );

  @override
  List<Object?> get props => [
    status,
    totalDuration,
    remainingDuration,
    fadeOutEnabled,
    fadeOutSeconds,
  ];
}
