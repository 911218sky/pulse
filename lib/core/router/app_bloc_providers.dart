import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/router/sync/file_scanner_sync.dart';
import 'package:pulse/core/router/sync/playlist_audio_sync.dart';
import 'package:pulse/core/router/sync/sleep_timer_provider.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';

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
    child: SleepTimerProvider(
      child: FileScannerSync(child: PlaylistAudioSync(child: child)),
    ),
  );
}
