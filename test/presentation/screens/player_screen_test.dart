import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/l10n/app_localizations.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/player/player_bloc.dart';
import 'package:pulse/presentation/bloc/player/player_event.dart';
import 'package:pulse/presentation/bloc/player/player_state.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_event.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart'
    as playlist_state;
import 'package:pulse/presentation/bloc/settings/settings_bloc.dart';
import 'package:pulse/presentation/bloc/settings/settings_event.dart';
import 'package:pulse/presentation/bloc/settings/settings_state.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_bloc.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_event.dart';
import 'package:pulse/presentation/bloc/sleep_timer/sleep_timer_state.dart';
import 'package:pulse/presentation/screens/player_screen.dart';

class _MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _MockPlaylistBloc
    extends MockBloc<PlaylistEvent, playlist_state.PlaylistState>
    implements PlaylistBloc {}

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _MockSleepTimerBloc extends MockBloc<SleepTimerEvent, SleepTimerState>
    implements SleepTimerBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const audioFile = AudioFile(
    id: 'resume-track',
    path: '/music/resume.mp3',
    title: 'Resume Track',
    duration: Duration(minutes: 4),
    fileSizeBytes: 1024,
  );

  Widget buildScreen({
    required PlayerBloc playerBloc,
    required PlaylistBloc playlistBloc,
    required SettingsBloc settingsBloc,
    required SleepTimerBloc sleepTimerBloc,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider<PlayerBloc>.value(value: playerBloc),
      BlocProvider<PlaylistBloc>.value(value: playlistBloc),
      BlocProvider<SettingsBloc>.value(value: settingsBloc),
      BlocProvider<SleepTimerBloc>.value(value: sleepTimerBloc),
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
      home: PlayerScreen(),
    ),
  );

  testWidgets('resume playback prompt auto-hides after 3 seconds', (
    tester,
  ) async {
    final playerBloc = _MockPlayerBloc();
    final playlistBloc = _MockPlaylistBloc();
    final settingsBloc = _MockSettingsBloc();
    final sleepTimerBloc = _MockSleepTimerBloc();
    const resumePromptState = PlayerState(
      status: PlayerStatus.playing,
      currentAudio: audioFile,
      duration: Duration(minutes: 4),
      pendingResumePosition: Duration(minutes: 1, seconds: 23),
    );

    when(() => playerBloc.state).thenReturn(resumePromptState);
    whenListen(
      playerBloc,
      const Stream<PlayerState>.empty(),
      initialState: resumePromptState,
    );

    when(
      () => playlistBloc.state,
    ).thenReturn(const playlist_state.PlaylistState());
    whenListen(
      playlistBloc,
      const Stream<playlist_state.PlaylistState>.empty(),
      initialState: const playlist_state.PlaylistState(),
    );

    when(() => settingsBloc.state).thenReturn(const SettingsState());
    whenListen(
      settingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(status: SettingsStatus.loaded),
    );

    when(() => sleepTimerBloc.state).thenReturn(const SleepTimerState());
    whenListen(sleepTimerBloc, const Stream<SleepTimerState>.empty());

    await tester.pumpWidget(
      buildScreen(
        playerBloc: playerBloc,
        playlistBloc: playlistBloc,
        settingsBloc: settingsBloc,
        sleepTimerBloc: sleepTimerBloc,
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Resume playback?'), findsOneWidget);
    expect(find.textContaining('Resume Track'), findsWidgets);
    expect(find.textContaining('1:23'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Start from beginning'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    verify(() => playerBloc.add(const PlayerDismissResumePrompt())).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('resume playback prompt actions dispatch expected events', (
    tester,
  ) async {
    final playerBloc = _MockPlayerBloc();
    final playlistBloc = _MockPlaylistBloc();
    final settingsBloc = _MockSettingsBloc();
    final sleepTimerBloc = _MockSleepTimerBloc();
    const resumePromptState = PlayerState(
      status: PlayerStatus.playing,
      currentAudio: audioFile,
      duration: Duration(minutes: 4),
      pendingResumePosition: Duration(minutes: 1, seconds: 23),
    );

    when(() => playerBloc.state).thenReturn(resumePromptState);
    whenListen(
      playerBloc,
      const Stream<PlayerState>.empty(),
      initialState: resumePromptState,
    );

    when(
      () => playlistBloc.state,
    ).thenReturn(const playlist_state.PlaylistState());
    whenListen(
      playlistBloc,
      const Stream<playlist_state.PlaylistState>.empty(),
      initialState: const playlist_state.PlaylistState(),
    );

    when(
      () => settingsBloc.state,
    ).thenReturn(const SettingsState(status: SettingsStatus.loaded));
    whenListen(
      settingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(status: SettingsStatus.loaded),
    );

    when(() => sleepTimerBloc.state).thenReturn(const SleepTimerState());
    whenListen(
      sleepTimerBloc,
      const Stream<SleepTimerState>.empty(),
      initialState: const SleepTimerState(),
    );

    await tester.pumpWidget(
      buildScreen(
        playerBloc: playerBloc,
        playlistBloc: playlistBloc,
        settingsBloc: settingsBloc,
        sleepTimerBloc: sleepTimerBloc,
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Resume'));
    await tester.pump();
    verify(
      () => playerBloc.add(const PlayerResumeFromSavedPosition()),
    ).called(1);

    clearInteractions(playerBloc);
    when(() => playerBloc.state).thenReturn(resumePromptState);

    await tester.pumpWidget(
      buildScreen(
        playerBloc: playerBloc,
        playlistBloc: playlistBloc,
        settingsBloc: settingsBloc,
        sleepTimerBloc: sleepTimerBloc,
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Start from beginning'));
    await tester.pump();
    verify(() => playerBloc.add(const PlayerDismissResumePrompt())).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
    'repeat-one mode keeps manual previous and next buttons enabled',
    (tester) async {
      final playerBloc = _MockPlayerBloc();
      final playlistBloc = _MockPlaylistBloc();
      final settingsBloc = _MockSettingsBloc();
      final sleepTimerBloc = _MockSleepTimerBloc();
      final playlist = Playlist.create(
        id: 'repeat-one',
        name: 'Repeat One',
      ).copyWith(
        files: const [
          AudioFile(
            id: 'prev-track',
            path: '/music/prev.mp3',
            title: 'Prev',
            duration: Duration(minutes: 4),
            fileSizeBytes: 1024,
          ),
          audioFile,
          AudioFile(
            id: 'next-track',
            path: '/music/next.mp3',
            title: 'Next',
            duration: Duration(minutes: 4),
            fileSizeBytes: 1024,
          ),
        ],
      );

      when(() => playerBloc.state).thenReturn(
        const PlayerState(
          status: PlayerStatus.playing,
          currentAudio: audioFile,
          duration: Duration(minutes: 4),
        ),
      );
      whenListen(
        playerBloc,
        const Stream<PlayerState>.empty(),
        initialState: const PlayerState(
          status: PlayerStatus.playing,
          currentAudio: audioFile,
          duration: Duration(minutes: 4),
        ),
      );

      when(() => playlistBloc.state).thenReturn(
        playlist_state.PlaylistState(
          currentPlaylist: playlist,
          currentTrackIndex: 1,
          repeatMode: playlist_state.RepeatMode.one,
        ),
      );
      whenListen(
        playlistBloc,
        const Stream<playlist_state.PlaylistState>.empty(),
        initialState: playlist_state.PlaylistState(
          currentPlaylist: playlist,
          currentTrackIndex: 1,
          repeatMode: playlist_state.RepeatMode.one,
        ),
      );

      when(
        () => settingsBloc.state,
      ).thenReturn(const SettingsState(status: SettingsStatus.loaded));
      whenListen(
        settingsBloc,
        const Stream<SettingsState>.empty(),
        initialState: const SettingsState(status: SettingsStatus.loaded),
      );

      when(() => sleepTimerBloc.state).thenReturn(const SleepTimerState());
      whenListen(sleepTimerBloc, const Stream<SleepTimerState>.empty());

      await tester.pumpWidget(
        buildScreen(
          playerBloc: playerBloc,
          playlistBloc: playlistBloc,
          settingsBloc: settingsBloc,
          sleepTimerBloc: sleepTimerBloc,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final prevIcon = find.byIcon(Icons.skip_previous_rounded);
      final nextIcon = find.byIcon(Icons.skip_next_rounded);

      final prevGestureDetector = tester.widget<GestureDetector>(
        find
            .ancestor(of: prevIcon, matching: find.byType(GestureDetector))
            .first,
      );
      final nextGestureDetector = tester.widget<GestureDetector>(
        find
            .ancestor(of: nextIcon, matching: find.byType(GestureDetector))
            .first,
      );

      expect(prevGestureDetector.onTap, isNotNull);
      expect(nextGestureDetector.onTap, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

  testWidgets('repeat-one mode keeps edge previous and next buttons enabled', (
    tester,
  ) async {
    final playerBloc = _MockPlayerBloc();
    final playlistBloc = _MockPlaylistBloc();
    final settingsBloc = _MockSettingsBloc();
    final sleepTimerBloc = _MockSleepTimerBloc();
    final playlist = Playlist.create(
      id: 'repeat-one-edge',
      name: 'Repeat One Edge',
    ).copyWith(
      files: const [
        AudioFile(
          id: 'first-track',
          path: '/music/first.mp3',
          title: 'First',
          duration: Duration(minutes: 4),
          fileSizeBytes: 1024,
        ),
        audioFile,
      ],
    );

    when(() => playerBloc.state).thenReturn(
      const PlayerState(
        status: PlayerStatus.playing,
        currentAudio: audioFile,
        duration: Duration(minutes: 4),
      ),
    );
    whenListen(
      playerBloc,
      const Stream<PlayerState>.empty(),
      initialState: const PlayerState(
        status: PlayerStatus.playing,
        currentAudio: audioFile,
        duration: Duration(minutes: 4),
      ),
    );

    when(() => playlistBloc.state).thenReturn(
      playlist_state.PlaylistState(
        currentPlaylist: playlist,
        repeatMode: playlist_state.RepeatMode.one,
      ),
    );
    whenListen(
      playlistBloc,
      const Stream<playlist_state.PlaylistState>.empty(),
      initialState: playlist_state.PlaylistState(
        currentPlaylist: playlist,
        repeatMode: playlist_state.RepeatMode.one,
      ),
    );

    when(
      () => settingsBloc.state,
    ).thenReturn(const SettingsState(status: SettingsStatus.loaded));
    whenListen(
      settingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(status: SettingsStatus.loaded),
    );

    when(() => sleepTimerBloc.state).thenReturn(const SleepTimerState());
    whenListen(
      sleepTimerBloc,
      const Stream<SleepTimerState>.empty(),
      initialState: const SleepTimerState(),
    );

    await tester.pumpWidget(
      buildScreen(
        playerBloc: playerBloc,
        playlistBloc: playlistBloc,
        settingsBloc: settingsBloc,
        sleepTimerBloc: sleepTimerBloc,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final prevIcon = find.byIcon(Icons.skip_previous_rounded);
    final nextIcon = find.byIcon(Icons.skip_next_rounded);

    final prevGestureDetector = tester.widget<GestureDetector>(
      find.ancestor(of: prevIcon, matching: find.byType(GestureDetector)).first,
    );
    final nextGestureDetector = tester.widget<GestureDetector>(
      find.ancestor(of: nextIcon, matching: find.byType(GestureDetector)).first,
    );

    expect(prevGestureDetector.onTap, isNotNull);
    expect(nextGestureDetector.onTap, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}
