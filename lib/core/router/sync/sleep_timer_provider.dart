import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_bloc.dart';

/// Provides SleepTimerBloc with access to PlayerBloc for pausing
class SleepTimerProvider extends StatelessWidget {
  const SleepTimerProvider({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<SleepTimerBloc>(
    create:
        (_) => SleepTimerBloc(
          onTimerExpired: () {
            context.read<PlayerBloc>().add(const PlayerPause());
            context.read<PlayerBloc>().add(
              const PlayerRestoreVolumeAfterSleep(),
            );
          },
          onFadeOutUpdate: (volume) {
            context.read<PlayerBloc>().add(PlayerSetSleepFadeVolume(volume));
          },
        ),
    child: child,
  );
}
