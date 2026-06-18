import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/core/utils/playback_speed_utils.dart';
import 'package:pulse/core/utils/volume_utils.dart';
import 'package:pulse/domain/entities/playback_state.dart';
import 'package:pulse/domain/repositories/audio_repository.dart';
import 'package:pulse/domain/repositories/playback_state_repository.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';

/// BLoC for managing audio playback
/// Optimized for large files with throttled position updates
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({
    required AudioRepository audioRepository,
    required PlaybackStateRepository playbackStateRepository,
    required SettingsRepository settingsRepository,
  }) : _audioRepository = audioRepository,
       _playbackStateRepository = playbackStateRepository,
       _settingsRepository = settingsRepository,
       super(const PlayerState()) {
    on<PlayerLoadAudio>(_onLoadAudio);
    on<PlayerPlay>(_onPlay);
    on<PlayerPause>(_onPause);
    on<PlayerStop>(_onStop);
    on<PlayerSeekTo>(_onSeekTo);
    on<PlayerSkipForward>(_onSkipForward);
    on<PlayerSkipBackward>(_onSkipBackward);
    on<PlayerSetVolume>(_onSetVolume);
    on<PlayerSetSpeed>(_onSetSpeed);
    on<PlayerToggleMute>(_onToggleMute);
    on<PlayerPositionUpdated>(_onPositionUpdated);
    on<PlayerDurationUpdated>(_onDurationUpdated);
    on<PlayerPlayingStateUpdated>(_onPlayingStateUpdated);
    on<PlayerSaveState>(_onSaveState);
    on<PlayerRestoreState>(_onRestoreState);
    on<PlayerRestoreFromLibrary>(_onRestoreFromLibrary);
    on<PlayerSetSleepFadeVolume>(_onSetSleepFadeVolume);
    on<PlayerRestoreVolumeAfterSleep>(_onRestoreVolumeAfterSleep);
    on<PlayerClearCompletedTrackPosition>(_onClearCompletedTrackPosition);

    _subscribeToStreams();
  }

  final AudioRepository _audioRepository;
  final PlaybackStateRepository _playbackStateRepository;
  final SettingsRepository _settingsRepository;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<bool>? _playingSubscription;
  Timer? _autoSaveTimer;
  Timer? _positionThrottleTimer;

  int _skipForwardSeconds = 10;
  int _skipBackwardSeconds = 10;

  // Track the last loaded audio to avoid reloading the same file
  String? _lastLoadedAudioPath;

  // Throttle position updates to reduce UI rebuilds
  Duration? _pendingPosition;
  Duration? _resumePositionGuard;
  static const _positionUpdateInterval = Duration(milliseconds: 250);

  void _subscribeToStreams() {
    // Throttle position updates for smoother UI with large files
    _positionSubscription = _audioRepository.positionStream.listen((position) {
      _pendingPosition = position;
      _positionThrottleTimer ??= Timer(_positionUpdateInterval, () {
        if (_pendingPosition != null) {
          add(PlayerPositionUpdated(_pendingPosition!));
        }
        _positionThrottleTimer = null;
      });
    });

    _durationSubscription = _audioRepository.durationStream.listen(
      (duration) => add(PlayerDurationUpdated(duration)),
    );

    _playingSubscription = _audioRepository.playingStream.listen(
      (isPlaying) => add(PlayerPlayingStateUpdated(isPlaying: isPlaying)),
    );
  }

  Future<void> _onLoadAudio(
    PlayerLoadAudio event,
    Emitter<PlayerState> emit,
  ) async {
    // Skip reloading if it's the same audio file and already playing/ready
    if (!event.forceRestart &&
        _lastLoadedAudioPath == event.audioFile.path &&
        (state.isPlaying ||
            state.status == PlayerStatus.paused ||
            state.status == PlayerStatus.ready)) {
      // Just ensure playback continues without interruption
      return;
    }

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentAudio: event.audioFile,
        position: Duration.zero,
        duration: () => null,
      ),
    );

    try {
      // Load settings for skip durations
      final settings = await _settingsRepository.loadSettings();
      _skipForwardSeconds = settings.skipForwardSeconds;
      _skipBackwardSeconds = settings.skipBackwardSeconds;

      // Check for saved position
      final savedPosition = await _playbackStateRepository.getPositionForFile(
        event.audioFile.path,
      );
      _resumePositionGuard = savedPosition;

      // Load audio file at its saved position before play starts.
      await _audioRepository.loadAudio(
        event.audioFile,
        initialPosition: savedPosition ?? Duration.zero,
      );

      // Track the loaded audio path
      _lastLoadedAudioPath = event.audioFile.path;

      // Apply default settings
      await _audioRepository.setVolume(settings.defaultVolume);
      await _audioRepository.setPlaybackSpeed(settings.defaultPlaybackSpeed);

      emit(
        state.copyWith(
          status: PlayerStatus.ready,
          currentAudio: event.audioFile,
          position: savedPosition ?? Duration.zero,
          duration: () => event.audioFile.duration,
          volume: settings.defaultVolume,
          speed: settings.defaultPlaybackSpeed,
        ),
      );

      // Start auto-save timer
      _startAutoSaveTimer();

      // Auto-play the loaded audio
      await _audioRepository.play();
      emit(state.copyWith(status: PlayerStatus.playing));
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPlay(PlayerPlay event, Emitter<PlayerState> emit) async {
    if (!state.isReady && state.status != PlayerStatus.paused) return;

    try {
      if (state.status == PlayerStatus.paused &&
          state.position > Duration.zero) {
        await _audioRepository.seekTo(state.position);
      }
      await _audioRepository.play();
      emit(state.copyWith(status: PlayerStatus.playing));
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onPause(PlayerPause event, Emitter<PlayerState> emit) async {
    if (!state.isPlaying) return;

    try {
      await _audioRepository.pause();
      emit(state.copyWith(status: PlayerStatus.paused));
      add(const PlayerSaveState());
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onStop(PlayerStop event, Emitter<PlayerState> emit) async {
    try {
      add(const PlayerSaveState());
      await _audioRepository.stop();
      _resumePositionGuard = null;
      emit(
        state.copyWith(status: PlayerStatus.stopped, position: Duration.zero),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSeekTo(PlayerSeekTo event, Emitter<PlayerState> emit) async {
    if (!state.isReady) return;

    try {
      // Remember if we were playing before seek
      final wasPlaying = state.isPlaying;

      // Clamp position to valid range
      final maxDuration = state.duration ?? Duration.zero;
      var targetPosition = event.position;
      _resumePositionGuard = null;

      if (targetPosition.isNegative) {
        targetPosition = Duration.zero;
      } else if (targetPosition > maxDuration) {
        targetPosition = maxDuration;
      }

      await _audioRepository.seekTo(targetPosition);
      emit(state.copyWith(position: targetPosition));
      await _saveCurrentPlaybackState();

      // Resume playback if we were playing before seek
      if (wasPlaying) {
        await _audioRepository.play();
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSkipForward(
    PlayerSkipForward event,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.isReady) return;

    final newPosition = state.position + Duration(seconds: _skipForwardSeconds);
    add(PlayerSeekTo(newPosition));
  }

  Future<void> _onSkipBackward(
    PlayerSkipBackward event,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.isReady) return;

    final newPosition =
        state.position - Duration(seconds: _skipBackwardSeconds);
    add(PlayerSeekTo(newPosition));
  }

  Future<void> _onSetVolume(
    PlayerSetVolume event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final clampedVolume = VolumeUtils.clamp(event.volume);
      await _audioRepository.setVolume(clampedVolume);
      emit(
        state.copyWith(
          volume: clampedVolume,
          isMuted: false,
          previousVolume: state.volume,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSetSpeed(
    PlayerSetSpeed event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final clampedSpeed = PlaybackSpeedUtils.clamp(event.speed);
      await _audioRepository.setPlaybackSpeed(clampedSpeed);
      emit(state.copyWith(speed: clampedSpeed));
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onToggleMute(
    PlayerToggleMute event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (state.isMuted) {
        // Unmute - restore previous volume
        await _audioRepository.setVolume(state.previousVolume);
        emit(state.copyWith(isMuted: false, volume: state.previousVolume));
      } else {
        // Mute - save current volume and set to 0
        await _audioRepository.setVolume(0);
        emit(state.copyWith(isMuted: true, previousVolume: state.volume));
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onPositionUpdated(
    PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) {
    final resumePositionGuard = _resumePositionGuard;
    if (resumePositionGuard != null && event.position < resumePositionGuard) {
      return;
    }
    if (resumePositionGuard != null &&
        state.isPlaying &&
        event.position > resumePositionGuard + const Duration(seconds: 1)) {
      _resumePositionGuard = null;
    }
    emit(state.copyWith(position: event.position));
  }

  void _onDurationUpdated(
    PlayerDurationUpdated event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(duration: () => event.duration));
  }

  Future<void> _onPlayingStateUpdated(
    PlayerPlayingStateUpdated event,
    Emitter<PlayerState> emit,
  ) async {
    final shouldPersistOnPause =
        !event.isPlaying && state.status == PlayerStatus.playing;

    if (!event.isPlaying &&
        state.status != PlayerStatus.playing &&
        state.status != PlayerStatus.paused) {
      return;
    }

    emit(
      state.copyWith(
        status: event.isPlaying ? PlayerStatus.playing : PlayerStatus.paused,
      ),
    );

    if (shouldPersistOnPause) {
      try {
        await _saveCurrentPlaybackState();
      } on Exception {
        // Silently fail - saving state is not critical
      }
    }
  }

  Future<void> _onSaveState(
    PlayerSaveState event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      await _saveCurrentPlaybackState();
    } on Exception {
      // Silently fail - saving state is not critical
    }
  }

  Future<void> _onRestoreState(
    PlayerRestoreState event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final lastState = await _playbackStateRepository.getLastPlaybackState();
      if (lastState != null) {
        emit(
          state.copyWith(
            volume: lastState.volume,
            speed: lastState.playbackSpeed,
          ),
        );
      }
    } on Exception {
      // Silently fail - restoring state is not critical
    }
  }

  Future<void> _onRestoreFromLibrary(
    PlayerRestoreFromLibrary event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentAudio != null || event.libraryFiles.isEmpty) return;

    try {
      final settings = await _settingsRepository.loadSettings();
      _skipForwardSeconds = settings.skipForwardSeconds;
      _skipBackwardSeconds = settings.skipBackwardSeconds;

      if (!settings.autoResume) return;

      final lastState = await _playbackStateRepository.getLastPlaybackState();
      if (lastState == null) return;

      final audioFile =
          event.libraryFiles
              .where(
                (file) =>
                    AudioPathUtils.canonicalize(file.path) ==
                    AudioPathUtils.canonicalize(lastState.audioFilePath),
              )
              .firstOrNull;
      if (audioFile == null) return;

      emit(
        state.copyWith(
          status: PlayerStatus.loading,
          currentAudio: audioFile,
          position: Duration.zero,
          duration: () => null,
        ),
      );

      _resumePositionGuard = lastState.position;
      await _audioRepository.loadAudio(
        audioFile,
        initialPosition: lastState.position,
      );
      await _audioRepository.setVolume(lastState.volume);
      await _audioRepository.setPlaybackSpeed(lastState.playbackSpeed);

      _lastLoadedAudioPath = audioFile.path;

      emit(
        state.copyWith(
          status: PlayerStatus.ready,
          currentAudio: audioFile,
          position: lastState.position,
          duration: () => audioFile.duration,
          volume: lastState.volume,
          speed: lastState.playbackSpeed,
        ),
      );

      _startAutoSaveTimer();
      await _audioRepository.play();
      emit(state.copyWith(status: PlayerStatus.playing));
    } on Exception catch (e) {
      emit(
        state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Handle sleep timer fade out - only affects audio, not saved volume state
  Future<void> _onSetSleepFadeVolume(
    PlayerSetSleepFadeVolume event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final clampedVolume = VolumeUtils.clamp(event.volume);
      // Only set audio volume, don't update state.volume to preserve original
      await _audioRepository.setVolume(clampedVolume);
    } on Exception {
      // Silently fail - fade out is not critical
    }
  }

  /// Restore volume after sleep timer expires
  Future<void> _onRestoreVolumeAfterSleep(
    PlayerRestoreVolumeAfterSleep event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      // Restore the original volume that was saved in state
      await _audioRepository.setVolume(state.volume);
    } on Exception {
      // Silently fail - restoring volume is not critical
    }
  }

  /// Clear saved position for a completed track
  Future<void> _onClearCompletedTrackPosition(
    PlayerClearCompletedTrackPosition event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final lastState = await _playbackStateRepository.getLastPlaybackState();
      if (lastState?.audioFilePath == event.filePath) {
        await _playbackStateRepository.clearPlaybackState();
      }
      await _playbackStateRepository.clearPositionForFile(event.filePath);
      AppLogger.d(
        'PlayerBloc',
        'Cleared position for completed track: ${event.filePath}',
      );
    } on Exception {
      // Silently fail - clearing position is not critical
    }
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.isPlaying) {
        add(const PlayerSaveState());
      }
    });
  }

  Future<void> _saveCurrentPlaybackState() async {
    if (state.currentAudio == null) return;
    final duration = state.duration;

    if (duration != null &&
        duration > Duration.zero &&
        state.position >= duration) {
      await _playbackStateRepository.clearPlaybackState();
      await _playbackStateRepository.clearPositionForFile(
        state.currentAudio!.path,
      );
      return;
    }

    final playbackState = PlaybackState.create(
      audioFilePath: state.currentAudio!.path,
      position: state.position,
      volume: state.volume,
      playbackSpeed: state.speed,
    );

    await _playbackStateRepository.savePlaybackState(playbackState);
    await _playbackStateRepository.savePositionForFile(
      state.currentAudio!.path,
      state.position,
    );
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playingSubscription?.cancel();
    _autoSaveTimer?.cancel();
    _positionThrottleTimer?.cancel();

    // Save state before closing
    try {
      await _saveCurrentPlaybackState();
    } on Exception {
      // Silently fail - saving state is not critical during shutdown
    }

    await _audioRepository.dispose();
    return super.close();
  }
}
