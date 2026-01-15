import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pulse/data/services/audio_handler.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/repositories/audio_repository.dart';
import 'package:pulse/main.dart';

/// Implementation of AudioRepository using audio_service for background playback
class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl();

  MusicPlayerAudioHandler get _handler {
    final handler = audioHandler;
    if (handler == null) {
      debugPrint('ERROR: AudioHandler not initialized, creating new one');
      // Create a fallback handler if not initialized
      audioHandler = MusicPlayerAudioHandler();
      return audioHandler!;
    }
    return handler;
  }

  // Debounce seek to prevent crashes on large files
  Timer? _seekDebounceTimer;
  Duration? _pendingSeekPosition;
  bool _isSeeking = false;

  @override
  Future<void> loadAudio(AudioFile audioFile) async {
    try {
      await _handler.loadAudio(
        path: audioFile.path,
        title: audioFile.displayTitle,
        artist: audioFile.artist,
        album: audioFile.album,
        duration: audioFile.duration,
      );
    } on Exception catch (e) {
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _handler.play();
    } on Exception catch (e) {
      debugPrint('Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _handler.pause();
    } on Exception catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _handler.stop();
    } on Exception catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    // Cancel any pending seek
    _seekDebounceTimer?.cancel();
    _pendingSeekPosition = position;

    // Debounce seek operations to prevent crashes on large files
    _seekDebounceTimer = Timer(const Duration(milliseconds: 100), () async {
      if (_isSeeking || _pendingSeekPosition == null) return;

      _isSeeking = true;
      final targetPosition = _pendingSeekPosition!;
      _pendingSeekPosition = null;

      try {
        await _handler.seek(targetPosition);
      } on Exception catch (e) {
        debugPrint('Error seeking: $e');
      } finally {
        _isSeeking = false;
      }
    });
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _handler.setVolume(clampedVolume);
    } on Exception catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _handler.setSpeed(clampedSpeed);
    } on Exception catch (e) {
      debugPrint('Error setting speed: $e');
    }
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    // Loop mode handled at playlist level
  }

  @override
  Stream<Duration> get positionStream => _handler.positionStream.handleError(
    (Object error) => debugPrint('Position stream error: $error'),
  );

  @override
  Stream<bool> get playingStream => _handler.playingStream.handleError(
    (Object error) => debugPrint('Playing stream error: $error'),
  );

  @override
  Stream<Duration> get bufferedPositionStream =>
      _handler.bufferedPositionStream.handleError(
        (Object error) => debugPrint('Buffered position stream error: $error'),
      );

  @override
  Stream<Duration?> get durationStream => _handler.durationStream
      .map<Duration?>((d) => d)
      .handleError(
        (Object error) => debugPrint('Duration stream error: $error'),
      );

  @override
  Duration get currentPosition => _handler.position;

  @override
  Duration? get currentDuration => _handler.duration;

  @override
  bool get isPlaying => _handler.playing;

  @override
  double get currentVolume => _handler.volume;

  @override
  double get currentPlaybackSpeed => _handler.speed;

  @override
  Future<void> dispose() async {
    _seekDebounceTimer?.cancel();
  }
}
