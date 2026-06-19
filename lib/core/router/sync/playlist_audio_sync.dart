import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/main.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart'
    as playlist;
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';

class TemporaryQueueResolution {
  const TemporaryQueueResolution({
    required this.files,
    required this.startIndex,
  });

  final List<AudioFile> files;
  final int startIndex;
}

int? findAudioFileIndexByCanonicalPath({
  required AudioFile currentAudio,
  required List<AudioFile> candidateFiles,
}) {
  final currentPath = AudioPathUtils.canonicalize(currentAudio.path);

  for (var i = 0; i < candidateFiles.length; i++) {
    if (AudioPathUtils.canonicalize(candidateFiles[i].path) == currentPath) {
      return i;
    }
  }

  return null;
}

TemporaryQueueResolution? resolveTemporaryQueueForCurrentAudio({
  required AudioFile currentAudio,
  required List<AudioFile> candidateFiles,
}) {
  final startIndex = findAudioFileIndexByCanonicalPath(
    currentAudio: currentAudio,
    candidateFiles: candidateFiles,
  );
  if (startIndex == null) {
    return null;
  }

  return TemporaryQueueResolution(
    files: candidateFiles,
    startIndex: startIndex,
  );
}

/// Syncs PlaylistBloc with AudioHandler and handles app lifecycle navigation
class PlaylistAudioSync extends StatefulWidget {
  const PlaylistAudioSync({required this.child, super.key});

  final Widget child;

  @override
  State<PlaylistAudioSync> createState() => _PlaylistAudioSyncState();
}

class _PlaylistAudioSyncState extends State<PlaylistAudioSync>
    with WidgetsBindingObserver {
  bool _wasInBackground = false;
  String _lastKnownPath = AppRoutes.home;
  StreamSubscription<bool>? _completedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAudioHandlerCallbacks();
    _setupCompletionListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _completedSubscription?.cancel();
    super.dispose();
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<PlayerBloc>().add(const PlayerSaveState());
    }

    if (state == AppLifecycleState.paused) {
      // Save path before going to background
      _lastKnownPath =
          AppRouter.router.routerDelegate.currentConfiguration.fullPath;
      AppLogger.d(
        'PlaylistAudioSync',
        'App paused, saving path: $_lastKnownPath',
      );
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _handleAppResumed();
    }
  }

  /// Handle app resume from background
  void _handleAppResumed() {
    final handler = audioHandler;
    if (handler == null) return;

    final settings = context.read<SettingsBloc>().state.settings;
    final hasMusic = handler.mediaItem.value != null;

    AppLogger.d('PlaylistAudioSync', 'App resumed, hasMusic: $hasMusic');

    if (hasMusic && settings.navigateToPlayerOnResume) {
      _navigateToPlayerIfNeeded();
    }
  }

  /// Navigate to player if not already there
  void _navigateToPlayerIfNeeded() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final isOnPlayer =
          _lastKnownPath == AppRoutes.player ||
          _lastKnownPath.startsWith('${AppRoutes.player}/');

      if (!isOnPlayer) {
        AppLogger.d('PlaylistAudioSync', 'Navigating to player');
        AppRouter.router.go(AppRoutes.player);
      }
    });
  }

  /// Listen for track completion to play next and clear position
  void _setupCompletionListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final handler = audioHandler;
      if (handler == null) return;

      _completedSubscription = handler.playbackState
          .map((s) => s.processingState == AudioProcessingState.completed)
          .distinct()
          .listen((completed) {
            if (completed && mounted) {
              // Clear saved position for completed track
              final playerState = context.read<PlayerBloc>().state;
              final completedTrackPath = playerState.currentAudio?.path;

              if (completedTrackPath != null) {
                AppLogger.d(
                  'PlaylistAudioSync',
                  'Track completed: $completedTrackPath',
                );
                context.read<PlayerBloc>().add(
                  PlayerClearCompletedTrackPosition(completedTrackPath),
                );
              }

              final playlistState = context.read<PlaylistBloc>().state;
              final currentTrack = playlistState.currentTrack;

              if (playlistState.repeatMode == playlist.RepeatMode.one &&
                  currentTrack != null) {
                AppLogger.d('PlaylistAudioSync', 'Repeating current track');
                context.read<PlayerBloc>().add(
                  PlayerLoadAudio(currentTrack, forceRestart: true),
                );
                return;
              }

              AppLogger.d('PlaylistAudioSync', 'Playing next track');
              context.read<PlaylistBloc>().add(const PlaylistPlayNext());
            }
          });
    });
  }

  /// Setup callbacks for notification controls
  void _setupAudioHandlerCallbacks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAudioHandlerSkipCallbacks(context.read<PlaylistBloc>().state);
    });
  }

  void _syncAudioHandlerSkipCallbacks(playlist.PlaylistState playlistState) {
    final handler = audioHandler;
    if (handler == null) {
      AppLogger.w('PlaylistAudioSync', 'AudioHandler not available');
      return;
    }

    handler.setSkipCallbacks(
      onNext:
          playlistState.hasNext
              ? () {
                if (!mounted) return;
                AppLogger.d(
                  'PlaylistAudioSync',
                  'Skip to next from notification',
                );
                context.read<PlaylistBloc>().add(const PlaylistPlayNext());
              }
              : null,
      onPrevious:
          playlistState.hasPrevious
              ? () {
                if (!mounted) return;
                AppLogger.d(
                  'PlaylistAudioSync',
                  'Skip to previous from notification',
                );
                context.read<PlaylistBloc>().add(const PlaylistPlayPrevious());
              }
              : null,
    );
  }

  /// Load track into PlayerBloc when playlist track changes
  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<PlaylistBloc, playlist.PlaylistState>(
        listenWhen:
            (prev, curr) =>
                prev.currentTrackIndex != curr.currentTrackIndex ||
                prev.currentPlaylist?.id != curr.currentPlaylist?.id ||
                prev.repeatMode != curr.repeatMode,
        listener: (context, state) {
          _syncAudioHandlerSkipCallbacks(state);
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            context.read<PlayerBloc>().add(PlayerLoadAudio(currentTrack));
          }
        },
      ),
      BlocListener<PlayerBloc, PlayerState>(
        listenWhen:
            (prev, curr) =>
                prev.currentAudio?.path != curr.currentAudio?.path &&
                curr.currentAudio != null,
        listener: (context, state) {
          final currentAudio = state.currentAudio;
          if (currentAudio == null) return;

          final playlistBloc = context.read<PlaylistBloc>();
          final playlistState = playlistBloc.state;
          final playlistFiles =
              playlistState.currentPlaylist?.files ?? const [];
          final existingIndex = findAudioFileIndexByCanonicalPath(
            currentAudio: currentAudio,
            candidateFiles: playlistFiles,
          );

          if (existingIndex != null) {
            if (playlistState.currentTrackIndex != existingIndex) {
              playlistBloc.add(PlaylistJumpToTrack(existingIndex));
            }
            return;
          }

          final fileScannerState = context.read<FileScannerBloc>().state;
          final queue = resolveTemporaryQueueForCurrentAudio(
            currentAudio: currentAudio,
            candidateFiles: fileScannerState.allFiles,
          );
          if (queue == null) {
            return;
          }

          playlistBloc.add(
            PlaylistSetTemporaryQueue(
              files: queue.files,
              startIndex: queue.startIndex,
            ),
          );
        },
      ),
    ],
    child: widget.child,
  );
}
