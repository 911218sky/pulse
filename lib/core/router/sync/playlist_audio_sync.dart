import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/main.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';

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

              // Play next track
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

      final handler = audioHandler;
      if (handler == null) {
        AppLogger.w('PlaylistAudioSync', 'AudioHandler not available');
        return;
      }

      handler.setSkipCallbacks(
        onNext: () {
          if (!mounted) return;
          AppLogger.d('PlaylistAudioSync', 'Skip to next from notification');
          context.read<PlaylistBloc>().add(const PlaylistPlayNext());
        },
        onPrevious: () {
          if (!mounted) return;
          AppLogger.d(
            'PlaylistAudioSync',
            'Skip to previous from notification',
          );
          context.read<PlaylistBloc>().add(const PlaylistPlayPrevious());
        },
      );
    });
  }

  /// Load track into PlayerBloc when playlist track changes
  @override
  Widget build(BuildContext context) =>
      BlocListener<PlaylistBloc, PlaylistState>(
        listenWhen:
            (prev, curr) =>
                prev.currentTrackIndex != curr.currentTrackIndex ||
                prev.currentPlaylist?.id != curr.currentPlaylist?.id,
        listener: (context, state) {
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            context.read<PlayerBloc>().add(PlayerLoadAudio(currentTrack));
          }
        },
        child: widget.child,
      );
}
