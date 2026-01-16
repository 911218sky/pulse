import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// Audio handler for background playback with notification controls
/// Uses media_kit for stable playback on Windows (replaces just_audio)
class MusicPlayerAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  MusicPlayerAudioHandler({
    this.onSkipToNext,
    this.onSkipToPrevious,
    this.onNotificationClick,
  }) {
    _player = Player();
    _initPlaybackState();
    _init();
  }

  /// Callback for skip to next track
  VoidCallback? onSkipToNext;

  /// Callback for skip to previous track
  VoidCallback? onSkipToPrevious;

  /// Callback for notification click
  VoidCallback? onNotificationClick;

  /// Set callbacks for skip controls (can be called after initialization)
  void setSkipCallbacks({VoidCallback? onNext, VoidCallback? onPrevious}) {
    onSkipToNext = onNext;
    onSkipToPrevious = onPrevious;
    debugPrint('AudioHandler: Skip callbacks set');
  }

  /// Set callback for notification click
  void setNotificationClickCallback(VoidCallback? callback) {
    onNotificationClick = callback;
    debugPrint('AudioHandler: Notification click callback set');
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

  Duration _position = Duration.zero;
  Duration? _duration;
  bool _playing = false;

  // Throttle position updates to reduce UI rebuilds
  DateTime _lastPositionUpdate = DateTime.now();
  static const _positionUpdateInterval = Duration(milliseconds: 250);

  void _init() {
    // Listen to position changes (throttled)
    _positionSub = _player.stream.position.listen((pos) {
      _position = pos;
      final now = DateTime.now();
      if (now.difference(_lastPositionUpdate) >= _positionUpdateInterval) {
        _lastPositionUpdate = now;
        _broadcastState();
      }
    });

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
      MediaControl.skipToPrevious, // 上一首
      if (_playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext, // 下一首
      MediaControl.fastForward, // 快轉
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.rewind,
          MediaAction.fastForward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [1, 2, 3], // 精簡模式顯示：上一首、播放/暫停、下一首
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
    if (_duration == null || _duration == Duration.zero) {
      return AudioProcessingState.loading;
    }
    if (_player.state.completed) {
      return AudioProcessingState.completed;
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
  }) async {
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

      // Load the audio file using media_kit
      await _player.open(Media(path), play: false);

      // Broadcast initial state to show notification
      _broadcastState();
    } on Exception catch (e) {
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      debugPrint('AudioHandler: play() called, current playing: $_playing');

      // media_kit needs playOrPause for toggle behavior
      if (!_player.state.playing) {
        await _player.play();
      }
    } on Exception catch (e) {
      debugPrint('Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      debugPrint('AudioHandler: pause() called, current playing: $_playing');

      if (_player.state.playing) {
        await _player.pause();
      }
    } on Exception catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _playing = false;
      _broadcastState();
    } on Exception catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      // Remember playing state before seek
      final wasPlaying = _playing;

      await _player.seek(position);

      // Ensure playback continues if it was playing
      if (wasPlaying && !_player.state.playing) {
        await _player.play();
      }
    } on Exception catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    debugPrint('AudioHandler: skipToNext() called');
    onSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    debugPrint('AudioHandler: skipToPrevious() called');
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
    debugPrint('AudioHandler: click() called with button: $button');
    // When notification is clicked, navigate to player screen
    onNotificationClick?.call();
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      await _player.setRate(speed);
    } on Exception catch (e) {
      debugPrint('Error setting speed: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume * 100); // media_kit uses 0-100
    } on Exception catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  // Expose streams for UI
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<Duration> get bufferedPositionStream => _player.stream.buffer;

  Duration get position => _position;
  Duration? get duration => _duration;
  bool get playing => _playing;
  double get volume => _player.state.volume / 100;
  double get speed => _player.state.rate;

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await dispose();
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
      debugPrint('Error disposing audio handler: $e');
    }
  }
}
