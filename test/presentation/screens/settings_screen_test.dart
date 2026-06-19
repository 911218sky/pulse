import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';
import 'package:pulse/presentation/bloc/search/search_bloc.dart';
import 'package:pulse/presentation/bloc/search/search_event.dart';
import 'package:pulse/presentation/bloc/search/search_state.dart';
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/screens/settings_screen.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _MockPlaylistBloc extends MockBloc<PlaylistEvent, PlaylistState>
    implements PlaylistBloc {}

class _MockFileScannerBloc extends MockBloc<FileScannerEvent, FileScannerState>
    implements FileScannerBloc {}

class _MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packageInfoChannel = MethodChannel(
    'dev.fluttercommunity.plus/package_info',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, (call) async {
          if (call.method == 'getAll') {
            return <String, dynamic>{
              'appName': 'Pulse',
              'packageName': 'dev.pulse.app',
              'version': '0.1.28',
              'buildNumber': '28',
              'buildSignature': '',
            };
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, null);
  });

  Widget buildScreen({
    required SettingsBloc settingsBloc,
    required PlayerBloc playerBloc,
    required PlaylistBloc playlistBloc,
    required FileScannerBloc fileScannerBloc,
    required SearchBloc searchBloc,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>.value(value: settingsBloc),
      BlocProvider<PlayerBloc>.value(value: playerBloc),
      BlocProvider<PlaylistBloc>.value(value: playlistBloc),
      BlocProvider<FileScannerBloc>.value(value: fileScannerBloc),
      BlocProvider<SearchBloc>.value(value: searchBloc),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: <Locale>[
        Locale('zh', 'TW'),
        Locale('zh', 'CN'),
        Locale('en'),
      ],
      locale: Locale('en'),
      home: SettingsScreen(),
    ),
  );

  Future<void> openClearAllDataDialog(WidgetTester tester) async {
    final clearAllDataLabel = find.text('Clear All Data');
    await tester.scrollUntilVisible(
      clearAllDataLabel,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(clearAllDataLabel.first);
    await tester.tap(clearAllDataLabel.first);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'clear all data waits for success before clearing runtime state',
    (tester) async {
      final settingsBloc = _MockSettingsBloc();
      final playerBloc = _MockPlayerBloc();
      final playlistBloc = _MockPlaylistBloc();
      final fileScannerBloc = _MockFileScannerBloc();
      final searchBloc = _MockSearchBloc();
      final settingsController = StreamController<SettingsState>.broadcast();
      const loadedState = SettingsState(status: SettingsStatus.loaded);

      when(() => settingsBloc.state).thenReturn(loadedState);
      whenListen(
        settingsBloc,
        settingsController.stream,
        initialState: loadedState,
      );
      when(
        () => settingsBloc.stream,
      ).thenAnswer((_) => settingsController.stream);

      when(() => playerBloc.state).thenReturn(const PlayerState());
      whenListen(playerBloc, const Stream<PlayerState>.empty());
      when(
        () => playerBloc.stream,
      ).thenAnswer((_) => const Stream<PlayerState>.empty());

      when(() => playlistBloc.state).thenReturn(const PlaylistState());
      whenListen(playlistBloc, const Stream<PlaylistState>.empty());
      when(
        () => playlistBloc.stream,
      ).thenAnswer((_) => const Stream<PlaylistState>.empty());

      when(() => fileScannerBloc.state).thenReturn(const FileScannerState());
      whenListen(fileScannerBloc, const Stream<FileScannerState>.empty());
      when(
        () => fileScannerBloc.stream,
      ).thenAnswer((_) => const Stream<FileScannerState>.empty());

      when(() => searchBloc.state).thenReturn(const SearchState());
      whenListen(searchBloc, const Stream<SearchState>.empty());
      when(
        () => searchBloc.stream,
      ).thenAnswer((_) => const Stream<SearchState>.empty());

      await tester.pumpWidget(
        buildScreen(
          settingsBloc: settingsBloc,
          playerBloc: playerBloc,
          playlistBloc: playlistBloc,
          fileScannerBloc: fileScannerBloc,
          searchBloc: searchBloc,
        ),
      );
      await tester.pump();

      await openClearAllDataDialog(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Clear All Data'));
      await tester.pump();

      verify(() => playerBloc.add(const PlayerPrepareForHardReset())).called(1);
      verify(() => settingsBloc.add(const SettingsResetAll())).called(1);
      verifyNever(() => playerBloc.add(const PlayerHardReset()));

      settingsController.add(
        const SettingsState(status: SettingsStatus.saving),
      );
      await tester.pump();
      settingsController.add(loadedState);
      await tester.pump();
      await tester.pump();

      verify(() => playerBloc.add(const PlayerHardReset())).called(1);
      verify(
        () => playlistBloc.add(const PlaylistClearRuntimeState()),
      ).called(1);
      verify(
        () => fileScannerBloc.add(const FileScannerClearLibrary()),
      ).called(1);
      verify(() => searchBloc.add(const SearchSourceUpdated([]))).called(1);
      verify(() => searchBloc.add(const SearchCleared())).called(1);
      expect(find.text('All data cleared'), findsOneWidget);

      await settingsController.close();
    },
  );

  testWidgets('clear all data does not clear runtime state when reset fails', (
    tester,
  ) async {
    final settingsBloc = _MockSettingsBloc();
    final playerBloc = _MockPlayerBloc();
    final playlistBloc = _MockPlaylistBloc();
    final fileScannerBloc = _MockFileScannerBloc();
    final searchBloc = _MockSearchBloc();
    final settingsController = StreamController<SettingsState>.broadcast();
    const loadedState = SettingsState(status: SettingsStatus.loaded);

    when(() => settingsBloc.state).thenReturn(loadedState);
    whenListen(
      settingsBloc,
      settingsController.stream,
      initialState: loadedState,
    );
    when(
      () => settingsBloc.stream,
    ).thenAnswer((_) => settingsController.stream);

    when(() => playerBloc.state).thenReturn(const PlayerState());
    whenListen(playerBloc, const Stream<PlayerState>.empty());
    when(
      () => playerBloc.stream,
    ).thenAnswer((_) => const Stream<PlayerState>.empty());

    when(() => playlistBloc.state).thenReturn(const PlaylistState());
    whenListen(playlistBloc, const Stream<PlaylistState>.empty());
    when(
      () => playlistBloc.stream,
    ).thenAnswer((_) => const Stream<PlaylistState>.empty());

    when(() => fileScannerBloc.state).thenReturn(const FileScannerState());
    whenListen(fileScannerBloc, const Stream<FileScannerState>.empty());
    when(
      () => fileScannerBloc.stream,
    ).thenAnswer((_) => const Stream<FileScannerState>.empty());

    when(() => searchBloc.state).thenReturn(const SearchState());
    whenListen(searchBloc, const Stream<SearchState>.empty());
    when(
      () => searchBloc.stream,
    ).thenAnswer((_) => const Stream<SearchState>.empty());

    await tester.pumpWidget(
      buildScreen(
        settingsBloc: settingsBloc,
        playerBloc: playerBloc,
        playlistBloc: playlistBloc,
        fileScannerBloc: fileScannerBloc,
        searchBloc: searchBloc,
      ),
    );
    await tester.pump();

    await openClearAllDataDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Clear All Data'));
    await tester.pump();

    verify(() => playerBloc.add(const PlayerPrepareForHardReset())).called(1);

    settingsController.add(
      const SettingsState(
        status: SettingsStatus.error,
        errorMessage: 'Reset failed',
      ),
    );
    await tester.pump();
    await tester.pump();

    verify(
      () => playerBloc.add(const PlayerCancelPreparedHardReset()),
    ).called(1);
    verifyNever(() => playerBloc.add(const PlayerHardReset()));
    verifyNever(() => playlistBloc.add(const PlaylistClearRuntimeState()));
    verifyNever(() => fileScannerBloc.add(const FileScannerClearLibrary()));
    verifyNever(() => searchBloc.add(const SearchSourceUpdated([])));
    verifyNever(() => searchBloc.add(const SearchCleared()));
    expect(find.text('Reset failed'), findsOneWidget);
    expect(find.text('All data cleared'), findsNothing);

    await settingsController.close();
  });
}
