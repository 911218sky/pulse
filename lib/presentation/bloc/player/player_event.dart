import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Events for PlayerBloc
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Load and prepare an audio file for playback
class PlayerLoadAudio extends PlayerEvent {
  const PlayerLoadAudio(this.audioFile);

  final AudioFile audioFile;

  @override
  List<Object?> get props => [audioFile];
}

/// Start or resume playback
class PlayerPlay extends PlayerEvent {
  const PlayerPlay();
}

/// Pause playback
class PlayerPause extends PlayerEvent {
  const PlayerPause();
}

/// Stop playback and release resources
class PlayerStop extends PlayerEvent {
  const PlayerStop();
}

/// Seek to a specific position
class PlayerSeekTo extends PlayerEvent {
  const PlayerSeekTo(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

/// Skip forward by configured seconds
class PlayerSkipForward extends PlayerEvent {
  const PlayerSkipForward();
}

/// Skip backward by configured seconds
class PlayerSkipBackward extends PlayerEvent {
  const PlayerSkipBackward();
}

/// Set volume level (0.0 to 1.0)
class PlayerSetVolume extends PlayerEvent {
  const PlayerSetVolume(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

/// Set playback speed (0.5 to 2.0)
class PlayerSetSpeed extends PlayerEvent {
  const PlayerSetSpeed(this.speed);

  final double speed;

  @override
  List<Object?> get props => [speed];
}

/// Toggle mute state
class PlayerToggleMute extends PlayerEvent {
  const PlayerToggleMute();
}

/// Update position from stream (internal event)
class PlayerPositionUpdated extends PlayerEvent {
  const PlayerPositionUpdated(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

/// Update duration from stream (internal event)
class PlayerDurationUpdated extends PlayerEvent {
  const PlayerDurationUpdated(this.duration);

  final Duration? duration;

  @override
  List<Object?> get props => [duration];
}

/// Update playing state from stream (internal event)
class PlayerPlayingStateUpdated extends PlayerEvent {
  const PlayerPlayingStateUpdated({required this.isPlaying});

  final bool isPlaying;

  @override
  List<Object?> get props => [isPlaying];
}

/// Save current playback state
class PlayerSaveState extends PlayerEvent {
  const PlayerSaveState();
}

/// Restore last playback state
class PlayerRestoreState extends PlayerEvent {
  const PlayerRestoreState();
}

/// Set temporary volume for sleep timer fade out (doesn't affect saved volume)
class PlayerSetSleepFadeVolume extends PlayerEvent {
  const PlayerSetSleepFadeVolume(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

/// Restore volume after sleep timer expires
class PlayerRestoreVolumeAfterSleep extends PlayerEvent {
  const PlayerRestoreVolumeAfterSleep();
}

/// Clear saved position for a completed track
class PlayerClearCompletedTrackPosition extends PlayerEvent {
  const PlayerClearCompletedTrackPosition(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}
