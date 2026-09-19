import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/router/sync/file_scanner_sync.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
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

class _MockFileScannerBloc extends MockBloc<FileScannerEvent, FileScannerState>
    implements FileScannerBloc {}

class _MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState>
    implements PlayerBloc {}

class _MockPlaylistBloc extends MockBloc<PlaylistEvent, PlaylistState>
    implements PlaylistBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const SearchSourceUpdated([]));
    registerFallbackValue(const PlayerRestoreFromLibrary([]));
    registerFallbackValue(const PlaylistLoadAll());
    registerFallbackValue(const FileScannerLoadLibrary());
  });

  testWidgets(
    'initial sync restores player from all available files when library is empty',
    (tester) async {
      final fileScannerBloc = _MockFileScannerBloc();
      final playerBloc = _MockPlayerBloc();
      final playlistBloc = _MockPlaylistBloc();
      final searchBloc = SearchBloc();
      const audioFile = AudioFile(
        id: 'folder-only',
        path: '/music/folder-only.mp3',
        title: 'Folder Only',
        duration: Duration(minutes: 3),
        fileSizeBytes: 2048,
      );
      const folder = ScannedFolder(
        path: '/music',
        name: 'Music',
        files: [audioFile],
        isSelected: true,
      );
      const initialState = FileScannerState(status: FileScannerStatus.loading);
      const completedState = FileScannerState(
        status: FileScannerStatus.completed,
        folders: [folder],
      );

      when(() => fileScannerBloc.state).thenReturn(completedState);
      whenListen(
        fileScannerBloc,
        Stream<FileScannerState>.fromIterable([completedState]),
        initialState: initialState,
      );
      when(() => playerBloc.state).thenReturn(const PlayerState());
      whenListen(
        playerBloc,
        const Stream<PlayerState>.empty(),
        initialState: const PlayerState(),
      );
      when(() => playlistBloc.state).thenReturn(const PlaylistState());
      whenListen(
        playlistBloc,
        const Stream<PlaylistState>.empty(),
        initialState: const PlaylistState(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<FileScannerBloc>.value(value: fileScannerBloc),
            BlocProvider<PlayerBloc>.value(value: playerBloc),
            BlocProvider<PlaylistBloc>.value(value: playlistBloc),
            BlocProvider<SearchBloc>.value(value: searchBloc),
          ],
          child: const MaterialApp(
            home: FileScannerSync(child: SizedBox.shrink()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      verify(
        () => fileScannerBloc.add(const FileScannerLoadLibrary()),
      ).called(1);
      verify(
        () => playerBloc.add(const PlayerRestoreFromLibrary([audioFile])),
      ).called(1);
      expect(searchBloc.state.sourceFiles, [audioFile]);
    },
  );

  testWidgets('fileDeleted status syncs search and reloads playlists', (
    tester,
  ) async {
    final fileScannerBloc = _MockFileScannerBloc();
    final playerBloc = _MockPlayerBloc();
    final playlistBloc = _MockPlaylistBloc();
    final searchBloc = SearchBloc();
    const audioFile = AudioFile(
      id: 'keep',
      path: '/music/keep.mp3',
      title: 'Keep',
      duration: Duration(minutes: 2),
      fileSizeBytes: 1024,
    );
    const before = FileScannerState(
      status: FileScannerStatus.completed,
      libraryFiles: [
        AudioFile(
          id: 'gone',
          path: '/music/gone.mp3',
          title: 'Gone',
          duration: Duration(minutes: 1),
          fileSizeBytes: 512,
        ),
        audioFile,
      ],
    );
    const after = FileScannerState(
      status: FileScannerStatus.fileDeleted,
      libraryFiles: [audioFile],
      lastDeletedTitle: 'Gone',
    );

    when(() => fileScannerBloc.state).thenReturn(after);
    whenListen(
      fileScannerBloc,
      Stream<FileScannerState>.fromIterable([after]),
      initialState: before,
    );
    when(() => playerBloc.state).thenReturn(const PlayerState());
    whenListen(
      playerBloc,
      const Stream<PlayerState>.empty(),
      initialState: const PlayerState(),
    );
    when(() => playlistBloc.state).thenReturn(const PlaylistState());
    whenListen(
      playlistBloc,
      const Stream<PlaylistState>.empty(),
      initialState: const PlaylistState(),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<FileScannerBloc>.value(value: fileScannerBloc),
          BlocProvider<PlayerBloc>.value(value: playerBloc),
          BlocProvider<PlaylistBloc>.value(value: playlistBloc),
          BlocProvider<SearchBloc>.value(value: searchBloc),
        ],
        child: const MaterialApp(
          home: FileScannerSync(child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(searchBloc.state.sourceFiles, [audioFile]);
    verify(() => playlistBloc.add(const PlaylistLoadAll())).called(1);
  });
}
