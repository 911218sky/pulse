import 'dart:async';

import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/playlist_model.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/domain/repositories/playlist_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of PlaylistRepository using local storage
class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(this._dataSource) : _uuid = const Uuid();

  final LocalStorageDataSource _dataSource;
  final Uuid _uuid;
  final _playlistsController = StreamController<List<Playlist>>.broadcast();

  @override
  Future<Playlist> createPlaylist(String name) async {
    // Check if playlist with same name already exists
    final existing = await getAllPlaylists();
    final existingWithName = existing.where((p) => p.name == name).firstOrNull;
    if (existingWithName != null) {
      // Return existing playlist instead of creating duplicate
      return existingWithName;
    }

    final playlist = Playlist.create(id: _uuid.v4(), name: name);
    final model = PlaylistModel.fromEntity(playlist);
    await _dataSource.savePlaylist(model);
    await _notifyPlaylistsChanged();
    return playlist;
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    final model = await _dataSource.getPlaylist(id);
    return model?.toEntity();
  }

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final models = await _dataSource.getAllPlaylists();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final model = PlaylistModel.fromEntity(playlist);
    await _dataSource.savePlaylist(model);
    await _notifyPlaylistsChanged();
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _dataSource.deletePlaylist(id);
    await _notifyPlaylistsChanged();
  }

  @override
  Future<Playlist> addFileToPlaylist(String playlistId, AudioFile file) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }
    final updated = playlist.addFile(file);
    await updatePlaylist(updated);
    return updated;
  }

  @override
  Future<Playlist> addFilesToPlaylist(
    String playlistId,
    List<AudioFile> files,
  ) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }
    final updated = playlist.addFiles(files);
    await updatePlaylist(updated);
    return updated;
  }

  @override
  Future<Playlist> removeFileFromPlaylist(
    String playlistId,
    String fileId,
  ) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }
    final updated = playlist.removeFile(fileId);
    await updatePlaylist(updated);
    return updated;
  }

  @override
  Future<Playlist> reorderPlaylist(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final playlist = await getPlaylist(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }
    final updated = playlist.reorder(oldIndex, newIndex);
    await updatePlaylist(updated);
    return updated;
  }

  @override
  Stream<List<Playlist>> get playlistsStream => _playlistsController.stream;

  Future<void> _notifyPlaylistsChanged() async {
    final playlists = await getAllPlaylists();
    _playlistsController.add(playlists);
  }

  void dispose() {
    _playlistsController.close();
  }
}
