import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/data/datasources/local_storage_datasource.dart';
import 'package:pulse/data/repositories/file_scanner_repository_impl.dart';

void main() {
  group('FileScannerRepositoryImpl', () {
    late Directory tempDir;
    late _TestFileScannerRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'pulse_file_scanner_repository_test_',
      );
      repository = _TestFileScannerRepository(_MockLocalStorageDataSource(), [
        tempDir.path,
      ]);
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
