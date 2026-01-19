import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/domain/repositories/playlist_repository.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';

/// BLoC for managing playlists
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc({required PlaylistRepository playlistRepository})
    : _playlistRepository = playlistRepository,
      super(const PlaylistState()) {
    on<PlaylistLoadAll>(_onLoadAll);
    on<PlaylistCreate>(_onCreate);
    on<PlaylistDelete>(_onDelete);
    on<PlaylistRename>(_onRename);
    on<PlaylistAddFile>(_onAddFile);
    on<PlaylistAddFiles>(_onAddFiles);
    on<PlaylistRemoveFile>(_onRemoveFile);
    on<PlaylistReorder>(_onReorder);
    on<PlaylistSelect>(_onSelect);
    on<PlaylistToggleShuffle>(_onToggleShuffle);
    on<PlaylistToggleRepeat>(_onToggleRepeat);
    on<PlaylistPlayNext>(_onPlayNext);
    on<PlaylistPlayPrevious>(_onPlayPrevious);
    on<PlaylistJumpToTrack>(_onJumpToTrack);
    on<PlaylistSetTemporaryQueue>(_onSetTemporaryQueue);

    _subscribeToPlaylists();
  }

  final PlaylistRepository _playlistRepository;
  final Random _random = Random();
  StreamSubscription<dynamic>? _playlistsSubscription;

  void _subscribeToPlaylists() {
    _playlistsSubscription = _playlistRepository.playlistsStream.listen((
      playlists,
    ) {
      add(const PlaylistLoadAll());
    });
  }

  Future<void> _onLoadAll(
    PlaylistLoadAll event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));

    try {
      final playlists = await _playlistRepository.getAllPlaylists();
      emit(state.copyWith(status: PlaylistStatus.loaded, playlists: playlists));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreate(
    PlaylistCreate event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      await _playlistRepository.createPlaylist(event.name);
      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(
    PlaylistDelete event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      // Check if the playlist being deleted is the current playlist
      final wasCurrentPlaylist = state.currentPlaylist?.id == event.playlistId;

      await _playlistRepository.deletePlaylist(event.playlistId);

      // Clear current playlist if it was deleted
      if (wasCurrentPlaylist) {
        emit(
          state.copyWith(
            currentPlaylist: () => null,
            currentTrackIndex: 0,
            shuffledIndices: const [],
            // Mark that the current playlist was deleted
            status: PlaylistStatus.playlistDeleted,
          ),
        );
      }

      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRename(
    PlaylistRename event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final playlist = await _playlistRepository.getPlaylist(event.playlistId);
      if (playlist != null) {
        final updated = playlist.copyWith(name: event.newName);
        await _playlistRepository.updatePlaylist(updated);
        // Stream subscription will trigger reload automatically
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddFile(
    PlaylistAddFile event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final updated = await _playlistRepository.addFileToPlaylist(
        event.playlistId,
        event.file,
      );

      // Update current playlist if it's the one being modified
      if (state.currentPlaylist?.id == event.playlistId) {
        emit(state.copyWith(currentPlaylist: () => updated));
        _regenerateShuffleIfNeeded(emit);
      }

      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddFiles(
    PlaylistAddFiles event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final updated = await _playlistRepository.addFilesToPlaylist(
        event.playlistId,
        event.files,
      );

      // Update current playlist if it's the one being modified
      if (state.currentPlaylist?.id == event.playlistId) {
        emit(state.copyWith(currentPlaylist: () => updated));
        _regenerateShuffleIfNeeded(emit);
      }

      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRemoveFile(
    PlaylistRemoveFile event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final updated = await _playlistRepository.removeFileFromPlaylist(
        event.playlistId,
        event.fileId,
      );

      // Update current playlist if it's the one being modified
      if (state.currentPlaylist?.id == event.playlistId) {
        var newIndex = state.currentTrackIndex;
        if (newIndex >= updated.fileCount) {
          newIndex = updated.fileCount - 1;
        }
        if (newIndex < 0) newIndex = 0;

        emit(
          state.copyWith(
            currentPlaylist: () => updated,
            currentTrackIndex: newIndex,
          ),
        );
        _regenerateShuffleIfNeeded(emit);
      }

      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReorder(
    PlaylistReorder event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final updated = await _playlistRepository.reorderPlaylist(
        event.playlistId,
        event.oldIndex,
        event.newIndex,
      );

      // Update current playlist if it's the one being modified
      if (state.currentPlaylist?.id == event.playlistId) {
        // Adjust current track index if needed
        var newIndex = state.currentTrackIndex;
        if (state.currentTrackIndex == event.oldIndex) {
          newIndex = event.newIndex;
        } else if (event.oldIndex < state.currentTrackIndex &&
            event.newIndex >= state.currentTrackIndex) {
          newIndex--;
        } else if (event.oldIndex > state.currentTrackIndex &&
            event.newIndex <= state.currentTrackIndex) {
          newIndex++;
        }

        emit(
          state.copyWith(
            currentPlaylist: () => updated,
            currentTrackIndex: newIndex,
          ),
        );
      }

      // Stream subscription will trigger reload automatically
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSelect(
    PlaylistSelect event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final playlist = await _playlistRepository.getPlaylist(event.playlistId);
      if (playlist != null) {
        // Validate startIndex
        final startIndex = event.startIndex.clamp(
          0,
          playlist.fileCount > 0 ? playlist.fileCount - 1 : 0,
        );

        emit(
          state.copyWith(
            currentPlaylist: () => playlist,
            currentTrackIndex: startIndex,
            shuffledIndices:
                state.shuffleEnabled
                    ? _generateShuffledIndices(playlist.fileCount)
                    : const [],
          ),
        );
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PlaylistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onToggleShuffle(
    PlaylistToggleShuffle event,
    Emitter<PlaylistState> emit,
  ) {
    final newShuffleEnabled = !state.shuffleEnabled;

    if (newShuffleEnabled && state.currentPlaylist != null) {
      // Generate shuffled indices
      final shuffled = _generateShuffledIndices(
        state.currentPlaylist!.fileCount,
      );
      emit(state.copyWith(shuffleEnabled: true, shuffledIndices: shuffled));
    } else {
      emit(state.copyWith(shuffleEnabled: false, shuffledIndices: const []));
    }
  }

  void _onToggleRepeat(
    PlaylistToggleRepeat event,
    Emitter<PlaylistState> emit,
  ) {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: nextMode));
  }

  void _onPlayNext(PlaylistPlayNext event, Emitter<PlaylistState> emit) {
    final nextIndex = state.nextTrackIndex;
    if (nextIndex != null) {
      emit(state.copyWith(currentTrackIndex: nextIndex));
    }
  }

  void _onPlayPrevious(
    PlaylistPlayPrevious event,
    Emitter<PlaylistState> emit,
  ) {
    final prevIndex = state.previousTrackIndex;
    if (prevIndex != null) {
      emit(state.copyWith(currentTrackIndex: prevIndex));
    }
  }

  void _onJumpToTrack(PlaylistJumpToTrack event, Emitter<PlaylistState> emit) {
    if (state.currentPlaylist == null) return;
    if (event.index < 0 || event.index >= state.currentPlaylist!.fileCount) {
      return;
    }
    emit(state.copyWith(currentTrackIndex: event.index));
  }

  /// Generate shuffled indices using Fisher-Yates algorithm
  List<int> _generateShuffledIndices(int count) {
    final indices = List.generate(count, (i) => i);
    for (var i = count - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }
    return indices;
  }

  void _regenerateShuffleIfNeeded(Emitter<PlaylistState> emit) {
    if (state.shuffleEnabled && state.currentPlaylist != null) {
      final shuffled = _generateShuffledIndices(
        state.currentPlaylist!.fileCount,
      );
      emit(state.copyWith(shuffledIndices: shuffled));
    }
  }

  void _onSetTemporaryQueue(
    PlaylistSetTemporaryQueue event,
    Emitter<PlaylistState> emit,
  ) {
    // Create a temporary in-memory playlist
    final tempPlaylist = Playlist.create(
      id: 'temp_queue',
      name: 'Now Playing',
    ).copyWith(files: event.files);

    emit(
      state.copyWith(
        currentPlaylist: () => tempPlaylist,
        currentTrackIndex: event.startIndex,
        shuffledIndices: const <int>[],
      ),
    );
  }

  @override
  Future<void> close() async {
    await _playlistsSubscription?.cancel();
    return super.close();
  }
}
