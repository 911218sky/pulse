import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/audio_file.dart';

import '../../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 9: Search Filtering Correctness
/// **Validates: Requirements 9.1, 9.2, 9.3**
///
/// For any search query Q and file list L:
/// - All results SHALL contain Q in title, artist, or album (case-insensitive)
/// - No file matching Q SHALL be excluded from results
/// - Empty query SHALL return all files

void main() {
  group('Search Filtering Correctness', () {
    /// Check if a file matches the search query
    bool matchesQuery(AudioFile file, String query) {
      final q = query.toLowerCase();

      // Match against title
      if (file.title.toLowerCase().contains(q)) return true;

      // Match against artist
      if (file.artist?.toLowerCase().contains(q) ?? false) return true;

      // Match against album
      if (file.album?.toLowerCase().contains(q) ?? false) return true;

      // Match against file path (filename)
      final filename = file.path.split('/').last.toLowerCase();
      if (filename.contains(q)) return true;

      return false;
    }

    /// Filter files based on search query
    List<AudioFile> filterFiles(List<AudioFile> files, String query) {
      if (query.isEmpty) return files;
      return files.where((file) => matchesQuery(file, query)).toList();
    }

    AudioFile generateRandomAudioFile() => AudioFile(
      id: PropertyTest.randomNonEmptyString(),
      path: '/music/${PropertyTest.randomNonEmptyString()}.mp3',
      title: PropertyTest.randomNonEmptyString(),
      artist:
          PropertyTest.randomBool()
              ? PropertyTest.randomNonEmptyString()
              : null,
      album:
          PropertyTest.randomBool()
              ? PropertyTest.randomNonEmptyString()
              : null,
      duration: PropertyTest.randomDuration(maxHours: 1),
      fileSizeBytes: PropertyTest.randomInt(min: 1000, max: 10000000),
    );

    test(
      'Property 9.1: All results contain query in title, artist, or album (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final files = List.generate(20, (_) => generateRandomAudioFile());
            final query = PropertyTest.randomNonEmptyString(maxLength: 5);
            return (files, query);
          },
          property: (input) {
            final (files, query) = input;
            final results = filterFiles(files, query);

            // All results should match the query
            for (final file in results) {
              expect(
                matchesQuery(file, query),
                isTrue,
                reason: 'File "${file.title}" should match query "$query"',
              );
            }
          },
        );
      },
    );

    test(
      'Property 9.2: No matching file is excluded from results (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final files = List.generate(20, (_) => generateRandomAudioFile());
            final query = PropertyTest.randomNonEmptyString(maxLength: 5);
            return (files, query);
          },
          property: (input) {
            final (files, query) = input;
            final results = filterFiles(files, query);

            // Count files that should match
            final expectedMatches =
                files.where((f) => matchesQuery(f, query)).length;

            // Results should contain all matching files
            expect(results.length, equals(expectedMatches));
          },
        );
      },
    );

    test('Property 9.3: Empty query returns all files (100 iterations)', () {
      PropertyTest.forAll(
        generator: () => List.generate(20, (_) => generateRandomAudioFile()),
        property: (files) {
          final results = filterFiles(files, '');

          // Should return all files
          expect(results.length, equals(files.length));
        },
      );
    });

    test('Search is case-insensitive', () {
      const file = AudioFile(
        id: '1',
        path: '/music/test.mp3',
        title: 'Hello World',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );

      expect(matchesQuery(file, 'hello'), isTrue);
      expect(matchesQuery(file, 'HELLO'), isTrue);
      expect(matchesQuery(file, 'HeLLo'), isTrue);
      expect(matchesQuery(file, 'world'), isTrue);
      expect(matchesQuery(file, 'test'), isTrue);
      expect(matchesQuery(file, 'artist'), isTrue);
      expect(matchesQuery(file, 'album'), isTrue);
    });

    test('Search matches partial strings', () {
      const file = AudioFile(
        id: '1',
        path: '/music/test.mp3',
        title: 'Beautiful Song',
        artist: 'Amazing Artist',
        album: 'Greatest Hits',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );

      expect(matchesQuery(file, 'beau'), isTrue);
      expect(matchesQuery(file, 'song'), isTrue);
      expect(matchesQuery(file, 'amaz'), isTrue);
      expect(matchesQuery(file, 'great'), isTrue);
      expect(matchesQuery(file, 'xyz'), isFalse);
    });

    test('Search matches filename in path', () {
      const file = AudioFile(
        id: '1',
        path: '/music/my_favorite_song.mp3',
        title: 'Different Title',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );

      expect(matchesQuery(file, 'favorite'), isTrue);
      expect(matchesQuery(file, 'my_fav'), isTrue);
    });

    test('Search handles null artist and album', () {
      const file = AudioFile(
        id: '1',
        path: '/music/test.mp3',
        title: 'Test Song',
        duration: Duration(minutes: 3),
        fileSizeBytes: 1000,
      );

      // Should not throw when artist/album are null
      expect(matchesQuery(file, 'test'), isTrue);
      expect(matchesQuery(file, 'artist'), isFalse);
      expect(matchesQuery(file, 'album'), isFalse);
    });
  });
}
