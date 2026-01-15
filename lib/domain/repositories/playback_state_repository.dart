import 'package:pulse/domain/entities/playback_state.dart';

/// Repository interface for persisting playback state
abstract class PlaybackStateRepository {
  /// Saves the current playback state
  Future<void> savePlaybackState(PlaybackState state);

  /// Gets the last saved playback state
  Future<PlaybackState?> getLastPlaybackState();

  /// Clears all saved playback state
  Future<void> clearPlaybackState();

  /// Gets the saved position for a specific file
  Future<Duration?> getPositionForFile(String filePath);

  /// Saves the position for a specific file
  Future<void> savePositionForFile(String filePath, Duration position);

  /// Gets all saved file positions
  Future<Map<String, Duration>> getAllFilePositions();

  /// Clears the position for a specific file
  Future<void> clearPositionForFile(String filePath);
}
