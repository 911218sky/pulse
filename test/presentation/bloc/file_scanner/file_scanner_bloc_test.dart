import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/media_file_delete_service.dart';
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

    const audioFile = AudioFile(
      id: 'song-1',
      path: '/music/song-1.mp3',
      title: 'Song 1',
      duration: Duration.zero,
      fileSizeBytes: 1234,
    );

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

    blocTest<FileScannerBloc, FileScannerState>(
      'deleteFromDisk success removes file and emits fileDeleted',
      build: () {
        when(
          () => repository.deleteFileFromDisk(audioFile.id, audioFile.path),
        ).thenAnswer((_) async => MediaDeleteOutcome.deleted);
        return bloc;
      },
      seed:
          () => const FileScannerState(
            status: FileScannerStatus.completed,
            libraryFiles: [audioFile],
            folders: [
              ScannedFolder(
                path: '/music',
                name: 'music',
                files: [audioFile],
                isSelected: true,
              ),
            ],
          ),
      act:
          (bloc) => bloc.add(
            FileScannerDeleteFile(
              audioFile.id,
              filePath: audioFile.path,
              deleteFromDisk: true,
            ),
          ),
      expect:
          () => [
            isA<FileScannerState>()
                .having(
                  (s) => s.status,
                  'status',
                  FileScannerStatus.fileDeleted,
                )
                .having((s) => s.libraryFiles, 'libraryFiles', isEmpty)
                .having((s) => s.folders, 'folders', isEmpty)
                .having((s) => s.lastDeletedTitle, 'title', 'Song 1'),
          ],
      verify: (_) {
        verify(
          () => repository.deleteFileFromDisk(audioFile.id, audioFile.path),
        ).called(1);
        verifyNever(() => repository.deleteFromLibrary(any()));
      },
    );

    blocTest<FileScannerBloc, FileScannerState>(
      'deleteFromDisk failure keeps library and emits deleteFailed',
      build: () {
        when(
          () => repository.deleteFileFromDisk(audioFile.id, audioFile.path),
        ).thenAnswer((_) async => MediaDeleteOutcome.failed);
        return bloc;
      },
      seed:
          () => const FileScannerState(
            status: FileScannerStatus.completed,
            libraryFiles: [audioFile],
          ),
      act:
          (bloc) => bloc.add(
            FileScannerDeleteFile(
              audioFile.id,
              filePath: audioFile.path,
              deleteFromDisk: true,
            ),
          ),
      expect:
          () => [
            isA<FileScannerState>()
                .having(
                  (s) => s.status,
                  'status',
                  FileScannerStatus.deleteFailed,
                )
                .having((s) => s.libraryFiles, 'libraryFiles', [audioFile]),
          ],
    );

    blocTest<FileScannerBloc, FileScannerState>(
      'deleteFromDisk cancelled keeps library and emits deleteCancelled',
      build: () {
        when(
          () => repository.deleteFileFromDisk(audioFile.id, audioFile.path),
        ).thenAnswer((_) async => MediaDeleteOutcome.cancelled);
        return bloc;
      },
      seed:
          () => const FileScannerState(
            status: FileScannerStatus.completed,
            libraryFiles: [audioFile],
          ),
      act:
          (bloc) => bloc.add(
            FileScannerDeleteFile(
              audioFile.id,
              filePath: audioFile.path,
              deleteFromDisk: true,
            ),
          ),
      expect:
          () => [
            isA<FileScannerState>().having(
              (s) => s.status,
              'status',
              FileScannerStatus.deleteCancelled,
            ),
          ],
      verify: (_) {
        expect(bloc.state.libraryFiles, [audioFile]);
      },
    );
  });
}

class _MockFileScannerRepository extends Mock
    implements FileScannerRepository {}
