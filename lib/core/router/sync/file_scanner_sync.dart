import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
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
    return previous.libraryFiles.length != current.libraryFiles.length;
  }

  /// Update SearchBloc and sync playlists
  void _onStateChanged(BuildContext context, FileScannerState state) {
    context.read<SearchBloc>().add(SearchSourceUpdated(state.allFiles));

    if (state.status == FileScannerStatus.completed &&
        state.selectedFolders.isNotEmpty) {
      // Only create playlists on manual scan/import, not on initial load
      if (_isInitialLoad) {
        _isInitialLoad = false;
        // On initial load, just sync existing playlists with library files
        _syncExistingPlaylists(context, state);
      } else {
        _createPlaylistsForFolders(context, state);
      }
    }
  }

  /// Sync existing playlists with current library files (update file counts)
  void _syncExistingPlaylists(BuildContext context, FileScannerState state) {
    final playlistBloc = context.read<PlaylistBloc>();
    // Just reload playlists to get updated file info
    playlistBloc.add(const PlaylistLoadAll());
  }

  /// Create playlist for each scanned folder (only on manual scan/import)
  void _createPlaylistsForFolders(
    BuildContext context,
    FileScannerState state,
  ) {
    final playlistBloc = context.read<PlaylistBloc>();

    for (final folder in state.selectedFolders) {
      if (folder.files.isEmpty) continue;

      final existingPlaylist =
          playlistBloc.state.playlists
              .where((p) => p.name == folder.name)
              .firstOrNull;

      // If playlist exists, update its files instead of recreating
      if (existingPlaylist != null) {
        // Clear and re-add files to update the playlist
        playlistBloc.add(
          PlaylistAddFiles(
            playlistId: existingPlaylist.id,
            files: folder.files,
          ),
        );
      } else {
        // Create new playlist
        playlistBloc.add(PlaylistCreate(folder.name));

        Future.delayed(const Duration(milliseconds: 150), () {
          if (!context.mounted) return;
          final newPlaylist =
              playlistBloc.state.playlists
                  .where((p) => p.name == folder.name)
                  .firstOrNull;

          if (newPlaylist != null && folder.files.isNotEmpty) {
            playlistBloc.add(
              PlaylistAddFiles(playlistId: newPlaylist.id, files: folder.files),
            );
          }
        });
      }
    }
  }
}
