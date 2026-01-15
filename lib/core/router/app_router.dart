import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/main.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_bloc.dart';
import 'package:pulse/presentation/screens/screens.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String player = '/player';
  static const String playlist = '/playlist';
  static const String playlistDetail = '/playlist/:id';
  static const String settings = '/settings';
  static const String scanner = '/scanner';
}

/// App router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder:
            (context, state) => HomeScreen(
              onTrackSelected: (file) {
                // Get all files from SearchBloc
                final searchState = context.read<SearchBloc>().state;
                final allFiles = searchState.results;

                if (allFiles.isNotEmpty) {
                  // Find the index of the selected file
                  final index = allFiles.indexWhere((f) => f.id == file.id);

                  // Set temporary playback queue
                  context.read<PlaylistBloc>().add(
                    PlaylistSetTemporaryQueue(
                      files: allFiles,
                      startIndex: index >= 0 ? index : 0,
                    ),
                  );
                }

                // Load the audio file into PlayerBloc
                context.read<PlayerBloc>().add(PlayerLoadAudio(file));

                // Navigate to player screen
                context.push(AppRoutes.player);
              },
              onPlaylistPressed: () => context.push(AppRoutes.playlist),
              onSettingsPressed: () => context.push(AppRoutes.settings),
              onScanPressed: () => context.push(AppRoutes.scanner),
            ),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder:
            (context, state) => PlayerScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
      ),
      GoRoute(
        path: AppRoutes.playlist,
        builder:
            (context, state) => PlaylistScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              onPlaylistSelected: (playlist) {
                // Navigate to playlist detail screen
                context.push('/playlist/${playlist.id}');
              },
            ),
      ),
      GoRoute(
        path: '/playlist/:id',
        builder: (context, state) {
          final playlistId = state.pathParameters['id']!;
          return PlaylistDetailScreen(
            playlistId: playlistId,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.playlist);
              }
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder:
            (context, state) => SettingsScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              onSleepTimerPressed: () {
                // Show sleep timer dialog
              },
              onFolderScanPressed: () => context.push(AppRoutes.scanner),
            ),
      ),
      GoRoute(
        path: AppRoutes.scanner,
        builder:
            (context, state) => FileScannerScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              onComplete: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
      ),
    ],
  );
}

/// Widget that provides all BLoCs to the app
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<PlayerBloc>(create: (_) => sl<PlayerBloc>()),
      BlocProvider<PlaylistBloc>(create: (_) => sl<PlaylistBloc>()),
      BlocProvider<SearchBloc>(create: (_) => sl<SearchBloc>()),
      BlocProvider<SettingsBloc>(
        create: (_) => sl<SettingsBloc>()..add(const SettingsLoad()),
      ),
      BlocProvider<FileScannerBloc>(create: (_) => sl<FileScannerBloc>()),
    ],
    child: _SleepTimerProvider(
      child: _FileScannerToSearchSync(
        child: _PlaylistAudioHandlerSync(child: child),
      ),
    ),
  );
}

/// Provides SleepTimerBloc with access to PlayerBloc for pausing
class _SleepTimerProvider extends StatelessWidget {
  const _SleepTimerProvider({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<SleepTimerBloc>(
    create:
        (_) => SleepTimerBloc(
          onTimerExpired: () {
            // Pause playback when timer expires
            context.read<PlayerBloc>().add(const PlayerPause());
          },
          onFadeOutUpdate: (volume) {
            // Gradually reduce volume during fade out
            context.read<PlayerBloc>().add(PlayerSetVolume(volume));
          },
        ),
    child: child,
  );
}

/// Syncs FileScannerBloc state to SearchBloc and loads library on startup
class _FileScannerToSearchSync extends StatefulWidget {
  const _FileScannerToSearchSync({required this.child});

  final Widget child;

  @override
  State<_FileScannerToSearchSync> createState() =>
      _FileScannerToSearchSyncState();
}

class _FileScannerToSearchSyncState extends State<_FileScannerToSearchSync> {
  @override
  void initState() {
    super.initState();
    // Load music library from database on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileScannerBloc>().add(const FileScannerLoadLibrary());
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<FileScannerBloc, FileScannerState>(
        listenWhen: (previous, current) {
          // Always listen when status becomes completed
          if (current.status == FileScannerStatus.completed) {
            // Check if folders changed or status just became completed
            if (previous.status != FileScannerStatus.completed) {
              return true;
            }
            // Check if selected folders changed
            final prevSelected = previous.selectedFolders;
            final currSelected = current.selectedFolders;
            if (prevSelected.length != currSelected.length) {
              return true;
            }
            // Check if any folder selection changed
            for (var i = 0; i < current.folders.length; i++) {
              if (i >= previous.folders.length ||
                  previous.folders[i].isSelected !=
                      current.folders[i].isSelected) {
                return true;
              }
            }
            // Check if library files changed (for delete operations)
            if (previous.libraryFiles.length != current.libraryFiles.length) {
              return true;
            }
          }
          return false;
        },
        listener: (context, state) {
          // Use allFiles which includes library files
          final allFiles = state.allFiles;

          // Update SearchBloc with the new files
          context.read<SearchBloc>().add(SearchSourceUpdated(allFiles));

          // Auto-create playlists for each scanned folder
          if (state.status == FileScannerStatus.completed &&
              state.selectedFolders.isNotEmpty) {
            final playlistBloc = context.read<PlaylistBloc>();

            // Create a playlist for each selected folder
            for (final folder in state.selectedFolders) {
              if (folder.files.isEmpty) continue;

              // Check if playlist for this folder already exists
              final existingPlaylist =
                  playlistBloc.state.playlists
                      .where((p) => p.name == folder.name)
                      .firstOrNull;

              if (existingPlaylist == null) {
                // Create new playlist for this folder
                playlistBloc.add(PlaylistCreate(folder.name));

                // Wait a bit for playlist creation, then add files
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!context.mounted) return;

                  final newPlaylist =
                      playlistBloc.state.playlists
                          .where((p) => p.name == folder.name)
                          .firstOrNull;

                  if (newPlaylist != null && folder.files.isNotEmpty) {
                    playlistBloc.add(
                      PlaylistAddFiles(
                        playlistId: newPlaylist.id,
                        files: folder.files,
                      ),
                    );
                  }
                });
              } else {
                // Update existing playlist with current folder files
                playlistBloc.add(
                  PlaylistAddFiles(
                    playlistId: existingPlaylist.id,
                    files: folder.files,
                  ),
                );
              }
            }
          }
        },
        child: widget.child,
      );
}

/// Syncs PlaylistBloc with AudioHandler for next/previous track controls
class _PlaylistAudioHandlerSync extends StatefulWidget {
  const _PlaylistAudioHandlerSync({required this.child});

  final Widget child;

  @override
  State<_PlaylistAudioHandlerSync> createState() =>
      _PlaylistAudioHandlerSyncState();
}

class _PlaylistAudioHandlerSyncState extends State<_PlaylistAudioHandlerSync> {
  @override
  void initState() {
    super.initState();
    _setupAudioHandlerCallbacks();
  }

  void _setupAudioHandlerCallbacks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final handler = audioHandler;
      if (handler == null) {
        debugPrint('AudioHandler not available for skip callbacks');
        return;
      }

      // Set up callbacks for next/previous track
      handler.setSkipCallbacks(
        onNext: () {
          if (!mounted) return;
          debugPrint('Skip to next triggered from notification');
          context.read<PlaylistBloc>().add(const PlaylistPlayNext());
        },
        onPrevious: () {
          if (!mounted) return;
          debugPrint('Skip to previous triggered from notification');
          context.read<PlaylistBloc>().add(const PlaylistPlayPrevious());
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<PlaylistBloc, PlaylistState>(
        listenWhen:
            (previous, current) =>
                previous.currentTrackIndex != current.currentTrackIndex ||
                previous.currentPlaylist?.id != current.currentPlaylist?.id,
        listener: (context, state) {
          // When playlist track changes, load it into PlayerBloc
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            context.read<PlayerBloc>().add(PlayerLoadAudio(currentTrack));
          }
        },
        child: widget.child,
      );
}
