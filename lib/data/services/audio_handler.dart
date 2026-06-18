import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pulse/core/utils/app_logger.dart';

/// Audio handler for background playback with notification controls
/// Uses media_kit for stable playback on Windows (replaces just_audio)
class MusicPlayerAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MusicPlayerAudioHandler({this.onSkipToNext, this.onSkipToPrevious}) {
    _player = Player();
    _initPlaybackState();
    _init();
  }

  /// Callback for skip to next track
  VoidCallback? onSkipToNext;

  /// Callback for skip to previous track
  VoidCallback? onSkipToPrevious;

  /// Set callbacks for skip controls
  void setSkipCallbacks({VoidCallback? onNext, VoidCallback? onPrevious}) {
    onSkipToNext = onNext;
    onSkipToPrevious = onPrevious;
    AppLogger.d('AudioHandler', 'Skip callbacks set');
    _broadcastState();
  }

  void _initPlaybackState() {
    // Initialize playback state for notification
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 2],
      ),
    );
  }

  late final Player _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _completedSub;
  Future<void> _playerOperation = Future<void>.value();

  Duration _position = Duration.zero;
  Duration? _duration;
  Duration? _resumePositionGuard;
  bool _playing = false;
  bool _hasLoadedMedia = false;
  String? _currentMediaPath;

  Future<T> _runPlayerOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    final pending = _playerOperation.then((_) => operation());
    _playerOperation = pending.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.e(
          'AudioHandler',
          'Player operation failed: $operationName',
          error,
          stackTrace,
        );
      },
    );
    return pending;
  }

  void _init() {
    // Listen to position changes (throttled)
    _positionSub = _player.stream.position.listen(_recordPlayerPosition);

    // Listen to duration changes
    _durationSub = _player.stream.duration.listen((dur) {
      _duration = dur;
      // Update media item with actual duration
      if (mediaItem.value != null && dur > Duration.zero) {
        mediaItem.add(mediaItem.value!.copyWith(duration: dur));
      }
      _broadcastState();
    });

    // Listen to playing state
    _playingSub = _player.stream.playing.listen((playing) {
      _playing = playing;
      _broadcastState();
    });

    // Listen to completion
    _completedSub = _player.stream.completed.listen((completed) {
      if (completed) {
        _playing = false;
        _broadcastState();
      }
    });
  }

  void _broadcastState() {
    final controls = <MediaControl>[
      MediaControl.rewind, // 倒轉
      if (onSkipToPrevious != null) MediaControl.skipToPrevious, // 上一首
      if (_playing) MediaControl.pause else MediaControl.play,
      if (onSkipToNext != null) MediaControl.skipToNext, // 下一首
      MediaControl.fastForward, // 快轉
    ];
    final playPauseIndex = controls.indexWhere(
      (control) =>
          control.action == MediaAction.play ||
          control.action == MediaAction.pause,
    );
    final compactActionIndices = <int>[
      controls.indexWhere(
        (control) => control.action == MediaAction.skipToPrevious,
      ),
      playPauseIndex,
      controls.indexWhere(
        (control) => control.action == MediaAction.skipToNext,
      ),
    ].where((index) => index >= 0).toList(growable: false);

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.rewind,
          MediaAction.fastForward,
          if (onSkipToNext != null) MediaAction.skipToNext,
          if (onSkipToPrevious != null) MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: compactActionIndices,
        processingState: _mapProcessingState(),
        playing: _playing,
        updatePosition: _position,
        bufferedPosition: _duration ?? Duration.zero,
        speed: _player.state.rate,
        updateTime: DateTime.now(),
      ),
    );
  }

  AudioProcessingState _mapProcessingState() {
    if (_player.state.buffering) {
      return AudioProcessingState.buffering;
    }
    if (_player.state.completed) {
      return AudioProcessingState.completed;
    }
    if (!_hasLoadedMedia && _player.state.playlist.medias.isEmpty) {
      return AudioProcessingState.loading;
    }
    return AudioProcessingState.ready;
  }

  /// Load audio file and update media item
  Future<void> loadAudio({
    required String path,
    required String title,
    String? artist,
    String? album,
    Duration? duration,
    String? artworkUri,
    Duration initialPosition = Duration.zero,
  }) => _runPlayerOperation('loadAudio', () async {
    try {
      // Update media item for notification
      final item = MediaItem(
        id: path,
        title: title,
        artist: artist ?? 'Unknown Artist',
        album: album ?? 'Unknown Album',
        duration: duration,
        // Artwork will show in notification if provided
        artUri: artworkUri != null ? Uri.file(artworkUri) : null,
        // Extra display info
        displayTitle: title,
        displaySubtitle: artist ?? 'Unknown Artist',
        displayDescription: album,
      );
      mediaItem.add(item);
      _currentMediaPath = path;
      _hasLoadedMedia = false;

      _resumePositionGuard =
          initialPosition > Duration.zero ? initialPosition : null;
      _position = initialPosition;
      _duration = duration;
      _broadcastState();

      // Load the audio file using media_kit
      await _player.open(Media(path), play: false);
      _hasLoadedMedia = true;
      if (initialPosition > Duration.zero) {
        await _player.seek(initialPosition);
        _position = initialPosition;
      }

      // Broadcast initial state to show notification
      _broadcastState();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error loading audio', e);
      rethrow;
    }
  });

  @override
  Future<void> play() => _runPlayerOperation('play', () async {
    try {
      AppLogger.d('AudioHandler', 'play() called, current playing: $_playing');

      final path = _currentMediaPath ?? mediaItem.value?.id;

      if (_player.state.completed) {
        _resumePositionGuard = null;
        await _player.seek(Duration.zero);
      }

      if (_resumePositionGuard != null) {
        await _player.seek(_resumePositionGuard!);
        _position = _resumePositionGuard!;
      }

      final resumePosition =
          _player.state.completed ? Duration.zero : _position;

      if (_player.state.playlist.medias.isEmpty && path != null) {
        await _reopenCurrentMedia(path, resumePosition, play: false);
      }

      await _player.play();
      if (!await _waitForPlayingState()) {
        AppLogger.w(
          'AudioHandler',
          'play() did not resume immediately; reopening current media',
        );
        if (path != null) {
          await _reopenCurrentMedia(path, resumePosition, play: true);
          await _waitForPlayingState();
        }
      }
      if (_resumePositionGuard != null) {
        await _player.seek(_resumePositionGuard!);
        _position = _resumePositionGuard!;
      }

      _playing = _player.state.playing;
      _broadcastState();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error playing', e);
      rethrow;
    }
  });

  Future<void> _reopenCurrentMedia(
    String path,
    Duration resumePosition, {
    required bool play,
  }) async {
    _currentMediaPath = path;
    _hasLoadedMedia = false;
    _resumePositionGuard =
        resumePosition > Duration.zero ? resumePosition : null;
    await _player.open(Media(path), play: false);
    _hasLoadedMedia = true;
    if (resumePosition > Duration.zero) {
      await _player.seek(resumePosition);
    }
    if (play) {
      await _player.play();
    }
  }

  Future<bool> _waitForPlayingState() async {
    if (_player.state.playing) return true;

    try {
      return await _player.stream.playing
          .firstWhere((playing) => playing)
          .timeout(const Duration(milliseconds: 700));
    } on TimeoutException {
      return _player.state.playing;
    }
  }

  @override
  Future<void> pause() => _runPlayerOperation('pause', () async {
    try {
      AppLogger.d('AudioHandler', 'pause() called, current playing: $_playing');

      await _player.pause();
      _playing = false;
      _broadcastState();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error pausing', e);
      rethrow;
    }
  });

  @override
  Future<void> stop() => _runPlayerOperation('stop', () async {
    try {
      await _player.stop();
      _playing = false;
      _broadcastState();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error stopping', e);
      rethrow;
    }
  });

  @override
  Future<void> seek(Duration position) => _runPlayerOperation('seek', () async {
    try {
      // Remember playing state before seek
      final wasPlaying = _playing;

      _resumePositionGuard = null;
      await _player.seek(position);

      // Ensure playback continues if it was playing
      if (wasPlaying && !_player.state.playing) {
        await _player.play();
      }
      _position = position;
      _broadcastState();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error seeking', e);
      rethrow;
    }
  });

  @override
  Future<void> skipToNext() async {
    AppLogger.d('AudioHandler', 'skipToNext() called');
    onSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    AppLogger.d('AudioHandler', 'skipToPrevious() called');
    onSkipToPrevious?.call();
  }

  @override
  Future<void> fastForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await seek(newPosition);
  }

  @override
  Future<void> rewind() async {
    final newPosition = _position - const Duration(seconds: 10);
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    AppLogger.d('AudioHandler', 'click() called with button: $button');
    switch (button) {
      case MediaButton.media:
        if (_playing) {
          await pause();
        } else {
          await play();
        }
        return;
      case MediaButton.next:
        await skipToNext();
        return;
      case MediaButton.previous:
        await skipToPrevious();
        return;
    }
  }

  @override
  Future<void> setSpeed(double speed) =>
      _runPlayerOperation('setSpeed', () async {
        try {
          await _player.setRate(speed);
        } on Exception catch (e) {
          AppLogger.e('AudioHandler', 'Error setting speed', e);
          rethrow;
        }
      });

  Future<void> setVolume(double volume) =>
      _runPlayerOperation('setVolume', () async {
        try {
          await _player.setVolume(volume * 100); // media_kit uses 0-100
        } on Exception catch (e) {
          AppLogger.e('AudioHandler', 'Error setting volume', e);
          rethrow;
        }
      });

  // Expose streams for UI
  Stream<Duration> get positionStream => _player.stream.position.map(
    (position) => _shouldHoldResumePosition(position) ? _position : position,
  );
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<Duration> get bufferedPositionStream => _player.stream.buffer;

  Duration get position => _position;
  Duration? get duration => _duration;
  bool get playing => _playing;
  double get volume => _player.state.volume / 100;
  double get speed => _player.state.rate;

  bool _shouldHoldResumePosition(Duration position) {
    final guard = _resumePositionGuard;
    return guard != null && position < guard;
  }

  void _recordPlayerPosition(Duration position) {
    if (_shouldHoldResumePosition(position)) return;
    _position = position;
    final guard = _resumePositionGuard;
    if (guard != null &&
        _playing &&
        position > guard + const Duration(seconds: 1)) {
      _resumePositionGuard = null;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    // Keep the media session alive so Android notification controls can resume
    // playback after the app task is swiped away.
    try {
      await pause();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error pausing after task removal', e);
    }
  }

  Future<void> dispose() async {
    try {
      await _positionSub?.cancel();
      await _durationSub?.cancel();
      await _playingSub?.cancel();
      await _completedSub?.cancel();
      _positionSub = null;
      _durationSub = null;
      _playingSub = null;
      _completedSub = null;
      await _player.dispose();
    } on Exception catch (e) {
      AppLogger.e('AudioHandler', 'Error disposing', e);
    }
  }
}
