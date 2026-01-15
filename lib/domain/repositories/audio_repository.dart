import 'package:pulse/domain/entities/audio_file.dart';

/// Loop mode options for playback
enum LoopMode { off, one, all }

/// Repository interface for audio playback operations
abstract class AudioRepository {
  /// Loads an audio file and prepares it for playback
  Future<void> loadAudio(AudioFile audioFile);

  /// Starts or resumes playback
  Future<void> play();

  /// Pauses playback
  Future<void> pause();

  /// Stops playback and releases resources
  Future<void> stop();

  /// Seeks to the specified position
  Future<void> seekTo(Duration position);

  /// Sets the playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Sets the playback speed (0.5 to 2.0)
  Future<void> setPlaybackSpeed(double speed);

  /// Sets the loop mode
  Future<void> setLoopMode(LoopMode mode);

  /// Stream of current playback position
  Stream<Duration> get positionStream;

  /// Stream of playback state (playing/paused)
  Stream<bool> get playingStream;

  /// Stream of buffered position for streaming files
  Stream<Duration> get bufferedPositionStream;

  /// Stream of current duration (may change for streaming)
  Stream<Duration?> get durationStream;

  /// Gets the current position
  Duration get currentPosition;

  /// Gets the current duration
  Duration? get currentDuration;

  /// Gets whether audio is currently playing
  bool get isPlaying;

  /// Gets the current volume
  double get currentVolume;

  /// Gets the current playback speed
  double get currentPlaybackSpeed;

  /// Releases all resources
  Future<void> dispose();
}
