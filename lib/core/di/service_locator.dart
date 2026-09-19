import 'package:get_it/get_it.dart';
import 'package:pulse/core/services/media_file_delete_service.dart';
import 'package:pulse/core/services/update_check_service.dart';
import 'package:pulse/core/services/update_download_service.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/repositories/audio_repository_impl.dart';
import 'package:pulse/data/repositories/file_scanner_repository_impl.dart';
import 'package:pulse/data/repositories/playback_state_repository_impl.dart';
import 'package:pulse/data/repositories/playlist_repository_impl.dart';
import 'package:pulse/data/repositories/settings_repository_impl.dart';
import 'package:pulse/data/services/audio_handler.dart';
import 'package:pulse/domain/repositories/audio_repository.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:pulse/domain/repositories/playback_state_repository.dart';
import 'package:pulse/domain/repositories/playlist_repository.dart';
import 'package:pulse/domain/repositories/settings_repository.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initServiceLocator({
  required AppDatabase database,
  required MusicPlayerAudioHandler audioHandler,
}) async {
  sl
    ..registerLazySingleton<AppDatabase>(() => database)
    ..registerLazySingleton<MusicPlayerAudioHandler>(() => audioHandler)
    // Data sources
    ..registerLazySingleton<LocalStorageDataSource>(
      () => LocalStorageDataSource(sl()),
    )
    // Repositories
    ..registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl(sl()))
    ..registerLazySingleton<PlaybackStateRepository>(
      () => PlaybackStateRepositoryImpl(sl()),
    )
    ..registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<MediaFileDeleteService>(MediaFileDeleteService.new)
    ..registerLazySingleton<FileScannerRepository>(
      () => FileScannerRepositoryImpl(sl(), mediaFileDeleteService: sl()),
    )
    ..registerLazySingleton<UpdateCheckService>(UpdateCheckService.new)
    ..registerLazySingleton<UpdateDownloadService>(UpdateDownloadService.new)
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
