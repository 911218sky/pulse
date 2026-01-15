import 'package:get_it/get_it.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/repositories/audio_repository_impl.dart';
import 'package:pulse/data/repositories/file_scanner_repository_impl.dart';
import 'package:pulse/data/repositories/playback_state_repository_impl.dart';
import 'package:pulse/data/repositories/playlist_repository_impl.dart';
import 'package:pulse/data/repositories/settings_repository_impl.dart';
import 'package:pulse/domain/repositories/audio_repository.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:pulse/domain/repositories/playback_state_repository.dart';
import 'package:pulse/domain/repositories/playlist_repository.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/main.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initServiceLocator() async {
  // Database
  sl
    ..registerLazySingleton<AppDatabase>(() => database)
    // Data sources
    ..registerLazySingleton<LocalStorageDataSource>(
      () => LocalStorageDataSource(sl()),
    )
    // Repositories
    ..registerLazySingleton<AudioRepository>(AudioRepositoryImpl.new)
    ..registerLazySingleton<PlaybackStateRepository>(
      () => PlaybackStateRepositoryImpl(sl()),
    )
    ..registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<FileScannerRepository>(
      () => FileScannerRepositoryImpl(sl()),
    )
    // BLoCs
    ..registerFactory<PlayerBloc>(
      () => PlayerBloc(
        audioRepository: sl(),
        playbackStateRepository: sl(),
        settingsRepository: sl(),
      ),
    )
    ..registerFactory<PlaylistBloc>(
      () => PlaylistBloc(playlistRepository: sl()),
    )
    ..registerFactory<SearchBloc>(SearchBloc.new)
    ..registerFactory<SettingsBloc>(
      () => SettingsBloc(settingsRepository: sl()),
    )
    ..registerFactory<FileScannerBloc>(
      () => FileScannerBloc(fileScannerRepository: sl()),
    );
}

/// Reset all dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await sl.reset();
}
