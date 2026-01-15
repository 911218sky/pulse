import 'package:equatable/equatable.dart';

/// Events for SleepTimerBloc
sealed class SleepTimerEvent extends Equatable {
  const SleepTimerEvent();

  @override
  List<Object?> get props => [];
}

/// Start a sleep timer with the specified duration
class SleepTimerStart extends SleepTimerEvent {
  const SleepTimerStart({
    required this.duration,
    this.fadeOutEnabled = true,
    this.fadeOutSeconds = 5,
  });

  final Duration duration;
  final bool fadeOutEnabled;
  final int fadeOutSeconds;

  @override
  List<Object?> get props => [duration, fadeOutEnabled, fadeOutSeconds];
}

/// Cancel the active sleep timer
class SleepTimerCancel extends SleepTimerEvent {
  const SleepTimerCancel();
}

/// Extend the timer by additional duration
class SleepTimerExtend extends SleepTimerEvent {
  const SleepTimerExtend(this.additionalDuration);

  final Duration additionalDuration;

  @override
  List<Object?> get props => [additionalDuration];
}

/// Internal tick event for countdown
class SleepTimerTick extends SleepTimerEvent {
  const SleepTimerTick();
}

/// Timer has expired
class SleepTimerExpired extends SleepTimerEvent {
  const SleepTimerExpired();
}
