import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/services/audio_handler.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';

/// Global audio handler for background playback
MusicPlayerAudioHandler? audioHandler;

/// Global database instance
late AppDatabase database;

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      MediaKit.ensureInitialized();

      FlutterError.onError = (details) {
        debugPrint('Flutter error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      };

      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      if (!Platform.isAndroid && !Platform.isIOS) {
        await audioHandler?.dispose();
      }

      // Initialize audio service for background playback
      try {
        debugPrint('Initializing AudioService...');
        debugPrint('Platform: ${Platform.operatingSystem}');

        audioHandler = await AudioService.init(
          builder: MusicPlayerAudioHandler.new,
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'dev.pulse.app.audio',
            androidNotificationChannelName: '音樂播放',
            androidNotificationOngoing: true,
            androidShowNotificationBadge: true,
            notificationColor: Color(0xFF000000),
          ),
        );
        debugPrint('AudioService initialized successfully');
      } on Exception catch (e, stackTrace) {
        debugPrint('======== AudioService init FAILED ========');
        debugPrint('Error type: ${e.runtimeType}');
        debugPrint('Error message: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('==========================================');
        // Create handler directly without AudioService wrapper
        audioHandler = MusicPlayerAudioHandler();
        debugPrint('Fallback audio handler created (no background playback)');
      }

      if (audioHandler == null) {
        debugPrint('WARNING: audioHandler is still null, creating fallback');
        audioHandler = MusicPlayerAudioHandler();
      }

      debugPrint('audioHandler initialized: ${audioHandler != null}');

      database = AppDatabase();

      await initServiceLocator();

      runApp(const PulseApp());
    },
    (error, stack) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) => AppBlocProviders(
    child: BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen:
          (previous, current) =>
              previous.settings.darkMode != current.settings.darkMode ||
              previous.settings.locale != current.settings.locale,
      builder: (context, state) {
        final locale = _parseLocale(state.settings.locale);
        return MaterialApp.router(
          title: 'Pulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
        );
      },
    ),
  );

  Locale _parseLocale(String localeStr) {
    if (localeStr.contains('_')) {
      final parts = localeStr.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(localeStr);
  }
}
