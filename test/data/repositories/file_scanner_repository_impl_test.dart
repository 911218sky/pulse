import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/media_file_delete_service.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/models/audio_file_model.dart';
import 'package:pulse/data/models/playback_state_model.dart';
import 'package:pulse/data/models/settings_model.dart';
import 'package:pulse/data/repositories/file_scanner_repository_impl.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(<AudioFileModel>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(SettingsModel.defaults());
  });

  group('FileScannerRepositoryImpl', () {
    late Directory tempDir;
    late _MockLocalStorageDataSource dataSource;
    late _TestFileScannerRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'pulse_file_scanner_repository_test_',
      );
      dataSource = _MockLocalStorageDataSource();
      repository = _TestFileScannerRepository(dataSource, [tempDir.path]);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'getScannedFolders returns the last scan result even if files disappear afterwards',
      () async {
        final audioFile = File(
          '${tempDir.path}${Platform.pathSeparator}song.mp3',
        );
        await audioFile.writeAsString('test-audio');

        await repository.scanForMusicFiles().last;
        await audioFile.delete();

        final folders = await repository.getScannedFolders();

        expect(folders, hasLength(1));
        expect(folders.single.files, hasLength(1));
        expect(
          folders.single.files.single.path,
          AudioPathUtils.canonicalize(audioFile.path),
        );
      },
    );

    test(
      'getScannedFolders does not include files added after the scan completed',
      () async {
        final firstFile = File(
          '${tempDir.path}${Platform.pathSeparator}first.mp3',
        );
        await firstFile.writeAsString('first-audio');

        await repository.scanForMusicFiles().last;

        final secondFile = File(
          '${tempDir.path}${Platform.pathSeparator}second.mp3',
        );
        await secondFile.writeAsString('second-audio');

        final folders = await repository.getScannedFolders();

        expect(folders, hasLength(1));
        expect(
          folders.single.files.map((file) => file.path),
          contains(AudioPathUtils.canonicalize(firstFile.path)),
        );
        expect(
          folders.single.files.map((file) => file.path),
          isNot(contains(AudioPathUtils.canonicalize(secondFile.path))),
        );
      },
    );

    test('scanFolder includes nested audio files recursively', () async {
      final nestedDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}Album',
      )..createSync();
      final nestedFile = File(
        '${nestedDir.path}${Platform.pathSeparator}nested.mp3',
      );
      await nestedFile.writeAsString('nested-audio');

      final files = await repository.scanFolder(tempDir.path);

      expect(
        files.map((file) => file.path),
        contains(AudioPathUtils.canonicalize(nestedFile.path)),
      );
    });

    test(
      'scan yields noMusicFolders sentinel when directories are empty',
      () async {
        final emptyRepo = _TestFileScannerRepository(dataSource, const []);
        final progress = await emptyRepo.scanForMusicFiles().last;

        expect(progress, ScanProgress.noMusicFolders);
        expect(progress.currentFolder, ScanProgress.noMusicFoldersSentinel);
      },
    );

    test('saveToLibrary dedupes by canonical path before upsert', () async {
      when(() => dataSource.saveAudioFiles(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as List<AudioFileModel>,
      );

      final path = AudioPathUtils.canonicalize(
        '${tempDir.path}${Platform.pathSeparator}song.mp3',
      );
      await repository.saveToLibrary([
        AudioFile(
          id: 'new-1',
          path: path,
          title: 'A',
          duration: Duration.zero,
          fileSizeBytes: 1,
        ),
        AudioFile(
          id: 'new-2',
          path: path,
          title: 'B',
          duration: Duration.zero,
          fileSizeBytes: 2,
        ),
      ]);

      final verification = verify(() => dataSource.saveAudioFiles(captureAny()))
        ..called(1);
      final saved = verification.captured.single as List<AudioFileModel>;
      expect(saved, hasLength(1));
      expect(saved.single.path, path);
      expect(saved.single.id, 'new-1');
    });

    test('clearLibrary also clears positions and playback state', () async {
      when(
        () => dataSource.getAllAudioFilePaths(),
      ).thenAnswer((_) async => ['/a.mp3', '/b.mp3']);
      when(() => dataSource.clearFilePositions(any())).thenAnswer((_) async {});
      when(() => dataSource.clearPlaybackState()).thenAnswer((_) async {});
      when(() => dataSource.clearAllAudioFiles()).thenAnswer((_) async {});

      await repository.clearLibrary();

      verify(
        () => dataSource.clearFilePositions(['/a.mp3', '/b.mp3']),
      ).called(1);
      verify(() => dataSource.clearPlaybackState()).called(1);
      verify(() => dataSource.clearAllAudioFiles()).called(1);
    });

    test('saveSelectedFolders persists canonical monitoredFolders', () async {
      when(
        () => dataSource.getSettings(),
      ).thenAnswer((_) async => SettingsModel.defaults());
      when(() => dataSource.saveSettings(any())).thenAnswer((_) async {});

      final folder = AudioPathUtils.canonicalize(
        '${tempDir.path}${Platform.pathSeparator}Music',
      );
      await repository.saveSelectedFolders([folder, folder]);

      final verification = verify(() => dataSource.saveSettings(captureAny()))
        ..called(1);
      final saved = verification.captured.single as SettingsModel;
      expect(saved.monitoredFolders, [folder]);
    });

    test('getSavedFolderPreferences returns monitoredFolders', () async {
      final folder = AudioPathUtils.canonicalize('/music');
      when(() => dataSource.getSettings()).thenAnswer(
        (_) async => SettingsModel(
          darkMode: true,
          locale: 'en',
          defaultVolume: 1,
          defaultPlaybackSpeed: 1,
          autoResume: true,
          resumePlaybackOnTrackTap: true,
          skipForwardSeconds: 10,
          skipBackwardSeconds: 10,
          monitoredFolders: [folder],
          sleepTimerFadeOutEnabled: true,
          sleepTimerFadeOutSeconds: 5,
          navigateToPlayerOnResume: false,
          autoUpdateEnabled: true,
        ),
      );

      expect(await repository.getSavedFolderPreferences(), [folder]);
    });

    test(
      'deleteFileFromDisk removes library row only after disk delete succeeds',
      () async {
        final audioPath = AudioPathUtils.canonicalize(
          '${tempDir.path}${Platform.pathSeparator}keep.mp3',
        );
        final deleteService = MediaFileDeleteService(
          ioDelete: (_) async => true,
        );
        final repo = FileScannerRepositoryImpl(
          dataSource,
          mediaFileDeleteService: deleteService,
        );

        when(() => dataSource.deleteAudioFile('id-1')).thenAnswer((_) async {});
        when(
          () => dataSource.clearFilePosition(audioPath),
        ).thenAnswer((_) async {});
        when(
          () => dataSource.getLastPlaybackState(),
        ).thenAnswer((_) async => null);

        final outcome = await repo.deleteFileFromDisk('id-1', audioPath);

        expect(outcome, MediaDeleteOutcome.deleted);
        verify(() => dataSource.deleteAudioFile('id-1')).called(1);
        verify(() => dataSource.clearFilePosition(audioPath)).called(1);
      },
    );

    test(
      'deleteFileFromDisk does not touch library when disk delete fails',
      () async {
        final audioPath = AudioPathUtils.canonicalize(
          '${tempDir.path}${Platform.pathSeparator}keep.mp3',
        );
        final deleteService = MediaFileDeleteService(
          ioDelete: (_) async => false,
        );
        final repo = FileScannerRepositoryImpl(
          dataSource,
          mediaFileDeleteService: deleteService,
        );

        final outcome = await repo.deleteFileFromDisk('id-1', audioPath);

        expect(outcome, MediaDeleteOutcome.failed);
        verifyNever(() => dataSource.deleteAudioFile(any()));
        verifyNever(() => dataSource.clearFilePosition(any()));
      },
    );

    test(
      'deleteFromLibrary also clears matching playback position/state',
      () async {
        final audioPath = AudioPathUtils.canonicalize(
          '${tempDir.path}${Platform.pathSeparator}track.mp3',
        );
        when(() => dataSource.getAudioFileById('id-1')).thenAnswer(
          (_) async => AudioFileModel(
            id: 'id-1',
            path: audioPath,
            title: 'Track',
            durationMilliseconds: 0,
            fileSizeBytes: 10,
          ),
        );
        when(() => dataSource.deleteAudioFile('id-1')).thenAnswer((_) async {});
        when(
          () => dataSource.clearFilePosition(audioPath),
        ).thenAnswer((_) async {});
        when(() => dataSource.getLastPlaybackState()).thenAnswer(
          (_) async => PlaybackStateModel(
            audioFilePath: audioPath,
            positionMilliseconds: 0,
            savedAt: DateTime.utc(2024),
            volume: 1,
            playbackSpeed: 1,
          ),
        );
        when(() => dataSource.clearPlaybackState()).thenAnswer((_) async {});

        await repository.deleteFromLibrary('id-1');

        verify(() => dataSource.deleteAudioFile('id-1')).called(1);
        verify(() => dataSource.clearFilePosition(audioPath)).called(1);
        verify(() => dataSource.clearPlaybackState()).called(1);
      },
    );
  });
}

class _MockLocalStorageDataSource extends Mock
    implements LocalStorageDataSource {}

class _TestFileScannerRepository extends FileScannerRepositoryImpl {
  _TestFileScannerRepository(super.dataSource, this.directories);

  final List<String> directories;

  @override
  Future<List<String>> getCommonMusicDirectories() async => directories;
}
