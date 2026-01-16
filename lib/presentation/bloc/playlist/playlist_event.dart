import 'package:equatable/equatable.dart';
import 'package:pulse/domain/entities/audio_file.dart';

/// Events for PlaylistBloc
sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

/// Load all playlists
class PlaylistLoadAll extends PlaylistEvent {
  const PlaylistLoadAll();
}

/// Create a new playlist
class PlaylistCreate extends PlaylistEvent {
  const PlaylistCreate(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Delete a playlist
class PlaylistDelete extends PlaylistEvent {
  const PlaylistDelete(this.playlistId);

  final String playlistId;

  @override
  List<Object?> get props => [playlistId];
}

/// Rename a playlist
class PlaylistRename extends PlaylistEvent {
  const PlaylistRename({required this.playlistId, required this.newName});

  final String playlistId;
  final String newName;

  @override
  List<Object?> get props => [playlistId, newName];
}

/// Add a file to a playlist
class PlaylistAddFile extends PlaylistEvent {
  const PlaylistAddFile({required this.playlistId, required this.file});

  final String playlistId;
  final AudioFile file;

  @override
  List<Object?> get props => [playlistId, file];
}

/// Add multiple files to a playlist
class PlaylistAddFiles extends PlaylistEvent {
  const PlaylistAddFiles({required this.playlistId, required this.files});

  final String playlistId;
  final List<AudioFile> files;

  @override
  List<Object?> get props => [playlistId, files];
}

/// Remove a file from a playlist
class PlaylistRemoveFile extends PlaylistEvent {
  const PlaylistRemoveFile({required this.playlistId, required this.fileId});

  final String playlistId;
  final String fileId;

  @override
  List<Object?> get props => [playlistId, fileId];
}

/// Reorder files in a playlist
class PlaylistReorder extends PlaylistEvent {
  const PlaylistReorder({
    required this.playlistId,
    required this.oldIndex,
    required this.newIndex,
  });

  final String playlistId;
  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [playlistId, oldIndex, newIndex];
}

/// Select a playlist for playback
class PlaylistSelect extends PlaylistEvent {
  const PlaylistSelect(this.playlistId, {this.startIndex = 0});

  final String playlistId;
  final int startIndex;

  @override
  List<Object?> get props => [playlistId, startIndex];
}

/// Toggle shuffle mode
class PlaylistToggleShuffle extends PlaylistEvent {
  const PlaylistToggleShuffle();
}

/// Toggle repeat mode
class PlaylistToggleRepeat extends PlaylistEvent {
  const PlaylistToggleRepeat();
}

/// Play next track in playlist
class PlaylistPlayNext extends PlaylistEvent {
  const PlaylistPlayNext();
}

/// Play previous track in playlist
class PlaylistPlayPrevious extends PlaylistEvent {
  const PlaylistPlayPrevious();
}

/// Jump to specific track in playlist
class PlaylistJumpToTrack extends PlaylistEvent {
  const PlaylistJumpToTrack(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Set a temporary playback queue (for playing from library without creating playlist)
class PlaylistSetTemporaryQueue extends PlaylistEvent {
  const PlaylistSetTemporaryQueue({
    required this.files,
    required this.startIndex,
  });

  final List<AudioFile> files;
  final int startIndex;

  @override
  List<Object?> get props => [files, startIndex];
}
