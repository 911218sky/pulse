import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/core/constants/colors.dart';
import 'package:pulse/core/di/service_locator.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/core/router/app_bloc_providers.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/sync/update_check_sync.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/utils/app_logger.dart';
import 'package:pulse/data/database/app_database.dart';
import 'package:pulse/data/services/audio_handler.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      MediaKit.ensureInitialized();

      FlutterError.onError = (details) {
        AppLogger.e(
          'Flutter',
          'Error: ${details.exception}',
          details.exception,
          details.stack,
        );
      };

      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      late final MusicPlayerAudioHandler handler;
      try {
        AppLogger.i(
          'Main',
          'Initializing AudioService on ${Platform.operatingSystem}',
        );

        // Channel name is fixed at first creation on Android; keep English stable.
        handler = await AudioService.init(
          builder: MusicPlayerAudioHandler.new,
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'dev.pulse.app.audio',
            androidNotificationChannelName: 'Music playback',
            androidStopForegroundOnPause: false,
            androidShowNotificationBadge: true,
            notificationColor: AppColors.black,
          ),
        );
        AppLogger.i('Main', 'AudioService initialized successfully');
      } on Exception catch (e, stackTrace) {
        AppLogger.e('Main', 'AudioService init FAILED', e, stackTrace);
        handler = MusicPlayerAudioHandler();
        AppLogger.w(
          'Main',
          'Fallback audio handler created (no background playback)',
        );
      }

      final database = AppDatabase();
      await initServiceLocator(database: database, audioHandler: handler);

      runApp(const PulseApp());
    },
    (error, stack) {
      AppLogger.e('Main', 'Uncaught error', error, stack);
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
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('zh', 'CN'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
          builder:
              (context, child) =>
                  UpdateCheckSync(child: child ?? const SizedBox.shrink()),
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
