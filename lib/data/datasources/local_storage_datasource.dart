import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/models/audio_file_model.dart';
import 'package:pulse/data/models/playback_state_model.dart';
import 'package:pulse/data/models/playlist_model.dart';
import 'package:pulse/data/models/settings_model.dart';

/// Local storage data source using Drift (SQLite)
class LocalStorageDataSource {
  LocalStorageDataSource(this._db);

  final AppDatabase _db;

  // Audio File Operations (Music Library)

  Future<void> saveAudioFile(AudioFileModel file) async {
    await _db.insertAudioFile(file.toCompanion());
  }

  Future<void> saveAudioFiles(List<AudioFileModel> files) async {
    for (final file in files) {
      await _db.insertAudioFile(file.toCompanion());
    }
  }

  Future<List<AudioFileModel>> getAllAudioFiles() async {
    final rows = await _db.getAllAudioFiles();
    return rows.map(AudioFileModel.fromDrift).toList();
  }

  Future<void> deleteAudioFile(String id) async {
    await _db.deleteAudioFile(id);
  }

  Future<void> deleteAudioFiles(List<String> ids) async {
    for (final id in ids) {
      await _db.deleteAudioFile(id);
    }
  }

  Future<void> clearAllAudioFiles() async {
    await _db.clearAllAudioFiles();
  }

  // Playback State Operations

  Future<void> savePlaybackState(PlaybackStateModel state) async {
    await _db.savePlaybackState(state.toCompanion());
  }

  Future<PlaybackStateModel?> getLastPlaybackState() async {
    final row = await _db.getLastPlaybackState();
    return row != null ? PlaybackStateModel.fromDrift(row) : null;
  }

  Future<void> clearPlaybackState() async {
    await _db.clearPlaybackState();
  }

  // File Position Operations

  Future<void> saveFilePosition(String filePath, int positionMs) async {
    await _db.saveFilePosition(filePath, positionMs);
  }

  Future<int?> getFilePosition(String filePath) async =>
      _db.getFilePosition(filePath);

  Future<Map<String, int>> getAllFilePositions() async =>
      _db.getAllFilePositions();

  Future<void> clearFilePosition(String filePath) async {
    await _db.clearFilePosition(filePath);
  }

  Future<void> clearFilePositions(List<String> filePaths) async {
    await _db.clearFilePositions(filePaths);
  }

  Future<List<String>> getAllAudioFilePaths() async =>
      _db.getAllAudioFilePaths();

  Future<List<String>> getAllFilePositionPaths() async =>
      _db.getAllFilePositionPaths();

  Future<int> deleteAudioFilesByPaths(List<String> paths) async =>
      _db.deleteAudioFilesByPaths(paths);

  // Settings Operations

  Future<void> saveSettings(SettingsModel settings) async {
    await _db.saveSettings(settings.toCompanion());
  }

  Future<SettingsModel> getSettings() async {
    final row = await _db.getSettings();
    return row != null
        ? SettingsModel.fromDrift(row)
        : SettingsModel.defaults();
  }

  Future<void> clearSettings() async {
    await _db.deleteSettings();
  }

  // Playlist Operations

  Future<void> savePlaylist(PlaylistModel playlist) async {
    // Insert playlist
    await _db.insertPlaylist(playlist.toCompanion());

    // Insert audio files and update playlist files
    final audioFileIds = <String>[];
    for (final file in playlist.files) {
      await _db.insertAudioFile(file.toCompanion());
      audioFileIds.add(file.id);
    }

    // Update playlist-file relationships
    await _db.updatePlaylistFiles(playlist.id, audioFileIds);
  }

  Future<PlaylistModel?> getPlaylist(String id) async {
    final playlist = await _db.getPlaylistById(id);
    if (playlist == null) return null;

    final audioFiles = await _db.getPlaylistFiles(id);
    final fileModels = audioFiles.map(AudioFileModel.fromDrift).toList();

    return PlaylistModel.fromDrift(playlist, fileModels);
  }

  Future<List<PlaylistModel>> getAllPlaylists() async {
    final playlists = await _db.getAllPlaylists();
    final result = <PlaylistModel>[];

    for (final playlist in playlists) {
      final audioFiles = await _db.getPlaylistFiles(playlist.id);
      final fileModels = audioFiles.map(AudioFileModel.fromDrift).toList();
      result.add(PlaylistModel.fromDrift(playlist, fileModels));
    }

    return result;
  }

  Future<void> deletePlaylist(String id) async {
    await _db.deletePlaylist(id);
  }

  Stream<List<PlaylistModel>> watchPlaylists() =>
      _db.watchAllPlaylists().asyncMap((playlists) async {
        final result = <PlaylistModel>[];
        for (final playlist in playlists) {
          final audioFiles = await _db.getPlaylistFiles(playlist.id);
          final fileModels = audioFiles.map(AudioFileModel.fromDrift).toList();
          result.add(PlaylistModel.fromDrift(playlist, fileModels));
        }
        return result;
      });

  // Clear All Data Operations

  /// Clears all data from the database (settings, music library, playlists, playback state, etc.)
  Future<void> clearAllData() async {
    await _db.clearAllData();
  }
}
