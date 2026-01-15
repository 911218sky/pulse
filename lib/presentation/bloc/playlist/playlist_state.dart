import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';

/// Repeat mode options
enum RepeatMode { off, all, one }

/// Status of playlist operations
enum PlaylistStatus { initial, loading, loaded, error }

/// State for PlaylistBloc
class PlaylistState extends Equatable {
  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.playlists = const [],
    this.currentPlaylist,
    this.currentTrackIndex = 0,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.shuffledIndices = const [],
    this.errorMessage,
  });

  final PlaylistStatus status;
  final List<Playlist> playlists;
  final Playlist? currentPlaylist;
  final int currentTrackIndex;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final List<int> shuffledIndices;
  final String? errorMessage;

  /// Current track being played
  AudioFile? get currentTrack {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return null;
    final index = _effectiveIndex(currentTrackIndex);
    if (index < 0 || index >= currentPlaylist!.fileCount) return null;
    return currentPlaylist!.files[index];
  }

  /// Whether there is a next track
  bool get hasNext {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return false;
    if (repeatMode == RepeatMode.all) return true;
    return currentTrackIndex < currentPlaylist!.fileCount - 1;
  }

  /// Whether there is a previous track
  bool get hasPrevious {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return false;
    if (repeatMode == RepeatMode.all) return true;
    return currentTrackIndex > 0;
  }

  /// Get the effective index considering shuffle mode
  int _effectiveIndex(int index) {
    if (!shuffleEnabled || shuffledIndices.isEmpty) return index;
    if (index < 0 || index >= shuffledIndices.length) return index;
    return shuffledIndices[index];
  }

  /// Get next track index
  int? get nextTrackIndex {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return null;

    if (repeatMode == RepeatMode.one) {
      return currentTrackIndex;
    }

    final nextIndex = currentTrackIndex + 1;
    if (nextIndex >= currentPlaylist!.fileCount) {
      if (repeatMode == RepeatMode.all) {
        return 0;
      }
      return null;
    }
    return nextIndex;
  }

  /// Get previous track index
  int? get previousTrackIndex {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return null;

    if (repeatMode == RepeatMode.one) {
      return currentTrackIndex;
    }

    final prevIndex = currentTrackIndex - 1;
    if (prevIndex < 0) {
      if (repeatMode == RepeatMode.all) {
        return currentPlaylist!.fileCount - 1;
      }
      return null;
    }
    return prevIndex;
  }

  PlaylistState copyWith({
    PlaylistStatus? status,
    List<Playlist>? playlists,
    Playlist? Function()? currentPlaylist,
    int? currentTrackIndex,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    List<int>? shuffledIndices,
    String? errorMessage,
  }) => PlaylistState(
    status: status ?? this.status,
    playlists: playlists ?? this.playlists,
    currentPlaylist:
        currentPlaylist != null ? currentPlaylist() : this.currentPlaylist,
    currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffledIndices: shuffledIndices ?? this.shuffledIndices,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    playlists,
    currentPlaylist,
    currentTrackIndex,
    shuffleEnabled,
    repeatMode,
    shuffledIndices,
    errorMessage,
  ];
}
