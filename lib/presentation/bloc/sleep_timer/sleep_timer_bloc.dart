import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_event.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_state.dart';

/// BLoC for managing sleep timer
class SleepTimerBloc extends Bloc<SleepTimerEvent, SleepTimerState> {
  SleepTimerBloc({this.onTimerExpired, this.onFadeOutUpdate})
    : super(const SleepTimerState()) {
    on<SleepTimerStart>(_onStart);
    on<SleepTimerCancel>(_onCancel);
    on<SleepTimerExtend>(_onExtend);
    on<SleepTimerTick>(_onTick);
    on<SleepTimerExpired>(_onExpired);
  }

  /// Callback when timer expires (to pause playback)
  final void Function()? onTimerExpired;

  /// Callback for fade out volume updates (0.0 to 1.0)
  final void Function(double volume)? onFadeOutUpdate;

  Timer? _timer;
  DateTime? _startTime;
  Duration? _targetDuration;

  void _onStart(SleepTimerStart event, Emitter<SleepTimerState> emit) {
    // Cancel any existing timer
    _timer?.cancel();

    _startTime = DateTime.now();
    _targetDuration = event.duration;

    emit(
      state.copyWith(
        status: SleepTimerStatus.active,
        totalDuration: event.duration,
        remainingDuration: event.duration,
        fadeOutEnabled: event.fadeOutEnabled,
        fadeOutSeconds: event.fadeOutSeconds,
      ),
    );

    // Start countdown timer (tick every second)
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const SleepTimerTick()),
    );
  }

  void _onCancel(SleepTimerCancel event, Emitter<SleepTimerState> emit) {
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _targetDuration = null;

    emit(const SleepTimerState());
  }

  void _onExtend(SleepTimerExtend event, Emitter<SleepTimerState> emit) {
    if (!state.isActive) return;

    final newRemaining = state.remainingDuration + event.additionalDuration;
    final newTotal = state.totalDuration + event.additionalDuration;

    _targetDuration = newTotal;

    emit(
      state.copyWith(totalDuration: newTotal, remainingDuration: newRemaining),
    );
  }

  void _onTick(SleepTimerTick event, Emitter<SleepTimerState> emit) {
    if (!state.isActive || _startTime == null || _targetDuration == null) {
      return;
    }

    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = _targetDuration! - elapsed;

    if (remaining.isNegative || remaining == Duration.zero) {
      add(const SleepTimerExpired());
      return;
    }

    emit(state.copyWith(remainingDuration: remaining));

    // Handle fade out in last N seconds (based on fadeOutSeconds setting)
    final fadeOutMs = state.fadeOutSeconds * 1000;
    if (state.fadeOutEnabled &&
        fadeOutMs > 0 &&
        remaining.inMilliseconds <= fadeOutMs) {
      // Gradually reduce volume from 1.0 to 0.0 over fadeOutSeconds
      // Use milliseconds for smoother fade
      final fadeProgress = 1 - (remaining.inMilliseconds / fadeOutMs);
      final volume = (1 - fadeProgress).clamp(0.0, 1.0);
      onFadeOutUpdate?.call(volume);
    }
  }

  void _onExpired(SleepTimerExpired event, Emitter<SleepTimerState> emit) {
    _timer?.cancel();
    _timer = null;

    emit(
      state.copyWith(
        status: SleepTimerStatus.expired,
        remainingDuration: Duration.zero,
      ),
    );

    // Trigger callback to pause playback
    onTimerExpired?.call();
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }
}
