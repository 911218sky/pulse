import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/domain/repositories/file_scanner_repository.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_bloc.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_event.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';

void main() {
  group('FileScannerBloc', () {
    late _MockFileScannerRepository repository;
    late FileScannerBloc bloc;

    setUp(() {
      repository = _MockFileScannerRepository();
      bloc = FileScannerBloc(fileScannerRepository: repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('loads the repository scan result after progress completes', () async {
      const scanProgress = ScanProgress(
        filesFound: 1,
        foldersScanned: 1,
        currentFolder: '/music',
        isComplete: true,
      );
      const audioFile = AudioFile(
        id: 'song-1',
        path: '/music/song-1.mp3',
        title: 'Song 1',
        duration: Duration.zero,
        fileSizeBytes: 1234,
      );
      const scannedFolder = ScannedFolder(
        path: '/music',
        name: 'music',
        files: [audioFile],
      );

      when(
        () => repository.scanForMusicFiles(),
      ).thenAnswer((_) => Stream<ScanProgress>.value(scanProgress));
      when(
        () => repository.getScannedFolders(),
      ).thenAnswer((_) async => const [scannedFolder]);
      when(
        () => repository.getSavedFolderPreferences(),
      ).thenAnswer((_) async => const []);

      bloc.add(const FileScannerStartScan());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<FileScannerState>()
              .having(
                (state) => state.status,
                'status',
                FileScannerStatus.completed,
              )
              .having((state) => state.folders, 'folders', const [
                scannedFolder,
              ]),
        ),
      );

      verify(() => repository.scanForMusicFiles()).called(1);
      verify(() => repository.getScannedFolders()).called(1);
      verify(() => repository.getSavedFolderPreferences()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}

class _MockFileScannerRepository extends Mock
    implements FileScannerRepository {}
