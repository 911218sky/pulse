import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/screens/screens.dart';

export 'app_routes.dart';

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: _routes,
  );

  static final List<RouteBase> _routes = [
    GoRoute(
      path: AppRoutes.home,
      builder:
          (context, state) => HomeScreen(
            onTrackSelected: (file) => _handleTrackSelected(context, file),
            onPlaylistPressed: () => context.push(AppRoutes.playlist),
            onSettingsPressed: () => context.push(AppRoutes.settings),
            onScanPressed: () => context.push(AppRoutes.scanner),
          ),
    ),
    GoRoute(
      path: AppRoutes.player,
      builder:
          (context, state) =>
              PlayerScreen(onBack: () => _handleBack(context, AppRoutes.home)),
    ),
    GoRoute(
      path: AppRoutes.playlist,
      builder:
          (context, state) => PlaylistScreen(
            onBack: () => _handleBack(context, AppRoutes.home),
            onPlaylistSelected: (playlist) {
              context.push('/playlist/${playlist.id}');
            },
          ),
    ),
    GoRoute(
      path: AppRoutes.playlistDetail,
      builder: (context, state) {
        final playlistId = state.pathParameters['id']!;
        return PlaylistDetailScreen(
          playlistId: playlistId,
          onBack: () => _handleBack(context, AppRoutes.playlist),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder:
          (context, state) => SettingsScreen(
            onBack: () => _handleBack(context, AppRoutes.home),
            onFolderScanPressed: () => context.push(AppRoutes.scanner),
          ),
    ),
    GoRoute(
      path: AppRoutes.scanner,
      builder:
          (context, state) => FileScannerScreen(
            onBack: () => _handleBack(context, AppRoutes.home),
            onComplete: () => _handleBack(context, AppRoutes.home),
          ),
    ),
  ];

  /// Handle track selection from home screen
  static void _handleTrackSelected(BuildContext context, AudioFile file) {
    final searchState = context.read<SearchBloc>().state;
    final allFiles = searchState.results;

    if (allFiles.isNotEmpty) {
      final index = allFiles.indexWhere((f) => f.id == file.id);
      context.read<PlaylistBloc>().add(
        PlaylistSetTemporaryQueue(
          files: allFiles,
          startIndex: index >= 0 ? index : 0,
        ),
      );
    }

    context.read<PlayerBloc>().add(PlayerLoadAudio(file));
    context.push(AppRoutes.player);
  }

  /// Handle back navigation with fallback
  static void _handleBack(BuildContext context, String fallback) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback);
    }
  }
}
