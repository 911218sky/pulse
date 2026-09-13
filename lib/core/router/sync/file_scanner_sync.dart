import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path_lib;
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';

/// Syncs FileScannerBloc with SearchBloc and auto-creates playlists for folders
class FileScannerSync extends StatefulWidget {
  const FileScannerSync({required this.child, super.key});

  final Widget child;

  @override
  State<FileScannerSync> createState() => _FileScannerSyncState();
}

class _FileScannerSyncState extends State<FileScannerSync> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Load music library on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileScannerBloc>().add(const FileScannerLoadLibrary());
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<FileScannerBloc, FileScannerState>(
        listenWhen: _shouldListen,
        listener: _onStateChanged,
        child: widget.child,
      );

  /// Listen when scan completes or files change
  bool _shouldListen(FileScannerState previous, FileScannerState current) {
    if (_isInitialLoad &&
        previous.status == FileScannerStatus.loading &&
        (current.status == FileScannerStatus.initial ||
            current.status == FileScannerStatus.completed)) {
      return true;
    }
    if (current.status != FileScannerStatus.completed) return false;
    if (previous.status != FileScannerStatus.completed) return true;
    if (previous.selectedFolders.length != current.selectedFolders.length) {
      return true;
    }
    for (var i = 0; i < current.folders.length; i++) {
      if (i >= previous.folders.length ||
          previous.folders[i].isSelected != current.folders[i].isSelected) {
        return true;
      }
    }
    return previous.libraryFiles.length != current.libraryFiles.length ||
        previous.allFiles.length != current.allFiles.length;
  }

  /// Update SearchBloc and sync playlists
  void _onStateChanged(BuildContext context, FileScannerState state) {
    context.read<SearchBloc>().add(SearchSourceUpdated(state.allFiles));

    if (_isInitialLoad) {
      _isInitialLoad = false;
      if (state.status == FileScannerStatus.completed &&
          state.selectedFolders.isNotEmpty) {
        // On initial load, just sync existing playlists with library files.
        _syncExistingPlaylists(context);
      }
      if (state.allFiles.isNotEmpty) {
        context.read<PlayerBloc>().add(
          PlayerRestoreFromLibrary(state.allFiles),
        );
      }
      return;
    }

    if (state.status == FileScannerStatus.completed &&
        state.selectedFolders.isNotEmpty) {
      _createPlaylistsForFolders(context, state);
    }
  }

  /// Sync existing playlists with current library files (update file counts)
  void _syncExistingPlaylists(BuildContext context) {
    // Just reload playlists to get updated file info
    context.read<PlaylistBloc>().add(const PlaylistLoadAll());
  }

  /// Create/update playlist for each scanned folder (only on manual scan/import)
  void _createPlaylistsForFolders(
    BuildContext context,
    FileScannerState state,
  ) {
    final playlistBloc = context.read<PlaylistBloc>();
    final playlists = playlistBloc.state.playlists;

    for (final folder in state.selectedFolders) {
      if (folder.files.isEmpty) continue;

      final playlistName = resolveFolderPlaylistName(
        folder: folder,
        existingPlaylists: playlists,
      );
      final existingPlaylist = findPlaylistForFolder(
        folder: folder,
        playlistName: playlistName,
        existingPlaylists: playlists,
      );

      if (existingPlaylist != null) {
        final newFiles =
            folder.files
                .where((file) => !existingPlaylist.containsPath(file.path))
                .toList();
        if (newFiles.isEmpty) continue;

        playlistBloc.add(
          PlaylistAddFiles(playlistId: existingPlaylist.id, files: newFiles),
        );
      } else {
        playlistBloc.add(
          PlaylistCreateWithFiles(name: playlistName, files: folder.files),
        );
      }
    }
  }
}

/// Prefer basename; disambiguate when another folder already owns that name.
@visibleForTesting
String resolveFolderPlaylistName({
  required ScannedFolder folder,
  required List<Playlist> existingPlaylists,
}) {
  final folderPath = AudioPathUtils.canonicalize(folder.path);
  final baseName = folder.name;

  final sameName = existingPlaylists.where((p) => p.name == baseName).toList();
  if (sameName.isEmpty) return baseName;

  for (final playlist in sameName) {
    if (_playlistBelongsToFolder(playlist, folderPath)) {
      return baseName;
    }
  }

  final parentName = path_lib.basename(path_lib.dirname(folderPath));
  final disambiguated =
      parentName.isEmpty || parentName == '.' || parentName == '/'
          ? folderPath
          : '$parentName/$baseName';

  final collision = existingPlaylists.any((p) => p.name == disambiguated);
  if (!collision) return disambiguated;

  return folderPath;
}

@visibleForTesting
Playlist? findPlaylistForFolder({
  required ScannedFolder folder,
  required String playlistName,
  required List<Playlist> existingPlaylists,
}) {
  final folderPath = AudioPathUtils.canonicalize(folder.path);

  for (final playlist in existingPlaylists) {
    if (playlist.name == playlistName &&
        _playlistBelongsToFolder(playlist, folderPath)) {
      return playlist;
    }
  }

  for (final playlist in existingPlaylists) {
    if (playlist.name == playlistName && playlist.files.isEmpty) {
      return playlist;
    }
  }

  for (final playlist in existingPlaylists) {
    if (_playlistBelongsToFolder(playlist, folderPath)) {
      return playlist;
    }
  }

  return null;
}

bool _playlistBelongsToFolder(Playlist playlist, String folderPath) {
  if (playlist.files.isEmpty) return false;
  return playlist.files.every(
    (file) => AudioPathUtils.isUnderFolder(folderPath, file.path),
  );
}
