import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';

/// Repository interface for playlist management
abstract class PlaylistRepository {
  /// Creates a new playlist
  Future<Playlist> createPlaylist(String name);

  /// Gets a playlist by ID
  Future<Playlist?> getPlaylist(String id);

  /// Gets all playlists
  Future<List<Playlist>> getAllPlaylists();

  /// Updates a playlist
  Future<void> updatePlaylist(Playlist playlist);

  /// Deletes a playlist
  Future<void> deletePlaylist(String id);

  /// Adds a file to a playlist
  Future<Playlist> addFileToPlaylist(String playlistId, AudioFile file);

  /// Adds multiple files to a playlist
  Future<Playlist> addFilesToPlaylist(String playlistId, List<AudioFile> files);

  /// Removes a file from a playlist
  Future<Playlist> removeFileFromPlaylist(String playlistId, String fileId);

  /// Reorders files in a playlist
  Future<Playlist> reorderPlaylist(
    String playlistId,
    int oldIndex,
    int newIndex,
  );

  /// Stream of playlist changes
  Stream<List<Playlist>> get playlistsStream;
}
