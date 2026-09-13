import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/audio_path_utils.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/scanned_folder.dart';
import 'package:pulse/presentation/bloc/file_scanner/file_scanner_state.dart';

void main() {
  group('FileScannerState.allFiles', () {
    test('merges library and folder files by canonical path', () {
      final sharedPath = AudioPathUtils.canonicalize('/music/a.mp3');
      const libraryFile = AudioFile(
        id: 'db-id',
        path: '/music/a.mp3',
        title: 'From DB',
        duration: Duration.zero,
        fileSizeBytes: 1,
      );
      const scannedFile = AudioFile(
        id: 'scan-id',
        path: '/music/a.mp3',
        title: 'From Scan',
        duration: Duration.zero,
        fileSizeBytes: 1,
      );
      const importedOnly = AudioFile(
        id: 'new-id',
        path: '/music/b.mp3',
        title: 'Imported',
        duration: Duration.zero,
        fileSizeBytes: 1,
      );

      const state = FileScannerState(
        libraryFiles: [libraryFile],
        folders: [
          ScannedFolder(
            path: '/music',
            name: 'music',
            files: [scannedFile, importedOnly],
            isSelected: true,
          ),
        ],
      );

      final files = state.allFiles;
      expect(files, hasLength(2));
      expect(
        files
            .singleWhere(
              (file) => AudioPathUtils.canonicalize(file.path) == sharedPath,
            )
            .id,
        'db-id',
      );
      expect(files.any((file) => file.id == 'new-id'), isTrue);
    });
  });
}
