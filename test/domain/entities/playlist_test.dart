import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 4: Playlist Operations Consistency
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.4**
///
/// For any playlist:
/// - Creating a playlist SHALL assign a unique non-empty ID
/// - Adding N files SHALL increase file count by N
/// - Removing a file SHALL decrease file count by 1 and the file SHALL not appear in the list
/// - Reordering SHALL preserve all files (same count, same IDs, different order)

AudioFile generateRandomAudioFile() => AudioFile(
      id: PropertyTest.randomNonEmptyString(),
      path: '/music/${PropertyTest.randomNonEmptyString()}.mp3',
      title: PropertyTest.randomNonEmptyString(),
      artist:
          PropertyTest.randomBool() ? PropertyTest.randomNonEmptyString() : null,
      album:
          PropertyTest.randomBool() ? PropertyTest.randomNonEmptyString() : null,
      duration: PropertyTest.randomDuration(maxHours: 2),
      fileSizeBytes: PropertyTest.randomInt(min: 1000, max: 100000000),
      addedAt: PropertyTest.randomDateTime(),
    );

Playlist generateRandomPlaylist({int minFiles = 0, int maxFiles = 10}) {
  final fileCount = PropertyTest.randomInt(min: minFiles, max: maxFiles);
  final files = List.generate(fileCount, (_) => generateRandomAudioFile());
  return Playlist(
    id: PropertyTest.randomNonEmptyString(),
    name: PropertyTest.randomNonEmptyString(),
    files: files,
    createdAt: PropertyTest.randomDateTime(),
    updatedAt: PropertyTest.randomDateTime(),
  );
}

void main() {
  group('Playlist Operations', () {
    test(
      'Property 4.1: Creating a playlist assigns a unique non-empty ID (100 iterations)',
      () {
        final ids = <String>{};

        PropertyTest.forAll(
          generator: PropertyTest.randomNonEmptyString,
          property: (name) {
            final playlist = Playlist.create(
              id: PropertyTest.randomNonEmptyString(),
              name: name,
            );

            // ID should be non-empty
            expect(playlist.id, isNotEmpty);

            // ID should be unique (not seen before in this test)
            expect(ids.contains(playlist.id), isFalse);
            ids.add(playlist.id);

            // Name should match
            expect(playlist.name, equals(name));

            // Should start empty
            expect(playlist.files, isEmpty);
          },
        );
      },
    );

    test(
      'Property 4.2: Adding N files increases file count by N (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => (
            generateRandomPlaylist(maxFiles: 5),
            List.generate(
              PropertyTest.randomInt(min: 1, max: 5),
              (_) => generateRandomAudioFile(),
            ),
          ),
          property: (input) {
            final (playlist, filesToAdd) = input;
            final initialCount = playlist.fileCount;

            // Add files one by one
            var updated = playlist;
            for (final file in filesToAdd) {
              updated = updated.addFile(file);
            }

            // File count should increase by number of files added
            expect(updated.fileCount, equals(initialCount + filesToAdd.length));

            // All added files should be in the playlist
            for (final file in filesToAdd) {
              expect(
                updated.files.any((f) => f.id == file.id),
                isTrue,
                reason: 'File ${file.id} should be in playlist',
              );
            }
          },
        );
      },
    );

    test(
      'Property 4.2b: Adding multiple files at once increases file count correctly (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => (
            generateRandomPlaylist(maxFiles: 5),
            List.generate(
              PropertyTest.randomInt(min: 1, max: 5),
              (_) => generateRandomAudioFile(),
            ),
          ),
          property: (input) {
            final (playlist, filesToAdd) = input;
            final initialCount = playlist.fileCount;

            // Add all files at once
            final updated = playlist.addFiles(filesToAdd);

            // File count should increase by number of files added
            expect(updated.fileCount, equals(initialCount + filesToAdd.length));
          },
        );
      },
    );

    test(
      'Property 4.3: Removing a file decreases count by 1 and file is not in list (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => generateRandomPlaylist(minFiles: 1),
          property: (playlist) {
            // Pick a random file to remove
            final fileToRemove = PropertyTest.randomElement(playlist.files);
            final initialCount = playlist.fileCount;

            // Remove the file
            final updated = playlist.removeFile(fileToRemove.id);

            // File count should decrease by 1
            expect(updated.fileCount, equals(initialCount - 1));

            // Removed file should not be in the list
            expect(
              updated.files.any((f) => f.id == fileToRemove.id),
              isFalse,
              reason: 'Removed file should not be in playlist',
            );
          },
        );
      },
    );

    test(
      'Property 4.4: Reordering preserves all files with same IDs (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => generateRandomPlaylist(minFiles: 2),
          property: (playlist) {
            final fileCount = playlist.fileCount;
            final originalIds = playlist.files.map((f) => f.id).toSet();

            // Pick random indices to swap
            final oldIndex = PropertyTest.randomInt(max: fileCount);
            var newIndex = PropertyTest.randomInt(max: fileCount);
            if (newIndex > oldIndex) newIndex--; // Adjust for removal

            // Reorder
            final updated = playlist.reorder(oldIndex, newIndex);

            // File count should be the same
            expect(updated.fileCount, equals(fileCount));

            // All original IDs should still be present
            final newIds = updated.files.map((f) => f.id).toSet();
            expect(newIds, equals(originalIds));
          },
        );
      },
    );

    test('Playlist.totalDuration sums all file durations', () {
      final files = [
        const AudioFile(
          id: '1',
          path: '/a.mp3',
          title: 'A',
          duration: Duration(minutes: 3),
          fileSizeBytes: 1000,
        ),
        const AudioFile(
          id: '2',
          path: '/b.mp3',
          title: 'B',
          duration: Duration(minutes: 5),
          fileSizeBytes: 2000,
        ),
        const AudioFile(
          id: '3',
          path: '/c.mp3',
          title: 'C',
          duration: Duration(minutes: 2, seconds: 30),
          fileSizeBytes: 1500,
        ),
      ];

      final playlist = Playlist(
        id: 'test',
        name: 'Test',
        files: files,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        playlist.totalDuration,
        equals(const Duration(minutes: 10, seconds: 30)),
      );
    });
  });
}
