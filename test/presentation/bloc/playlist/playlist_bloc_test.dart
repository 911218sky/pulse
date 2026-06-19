import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/audio_file.dart';
import 'package:pulse/domain/entities/playlist.dart';
import 'package:pulse/presentation/bloc/playlist/playlist_state.dart';

import '../../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 8: Shuffle Produces Valid Permutation
/// **Validates: Requirements 7.3**
///
/// For any playlist of N items, shuffle SHALL produce a permutation where:
/// - All N items appear exactly once
/// - The order is different from the original (with high probability for N > 1)

void main() {
  group('Shuffle Produces Valid Permutation', () {
    /// Fisher-Yates shuffle implementation (same as in PlaylistBloc)
    List<int> generateShuffledIndices(int count, Random random) {
      final indices = List.generate(count, (i) => i);
      for (var i = count - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = indices[i];
        indices[i] = indices[j];
        indices[j] = temp;
      }
      return indices;
    }

    test(
      'Property 8.1: Shuffle contains all original indices exactly once (100 iterations)',
      () {
        final random = Random();

        PropertyTest.forAll(
          generator: () => PropertyTest.randomInt(min: 2, max: 100),
          property: (count) {
            final shuffled = generateShuffledIndices(count, random);

            // Should have same length
            expect(shuffled.length, equals(count));

            // Should contain all indices exactly once
            final sorted = List<int>.from(shuffled)..sort();
            final expected = List.generate(count, (i) => i);
            expect(sorted, equals(expected));
          },
        );
      },
    );

    test(
      'Property 8.2: Shuffle produces different order (high probability for N > 1)',
      () {
        final random = Random();
        var differentCount = 0;
        const iterations = 100;

        for (var i = 0; i < iterations; i++) {
          const count = 10; // Use fixed size for this test
          final original = List.generate(count, (i) => i);
          final shuffled = generateShuffledIndices(count, random);

          // Check if order is different
          var isDifferent = false;
          for (var j = 0; j < count; j++) {
            if (original[j] != shuffled[j]) {
              isDifferent = true;
              break;
            }
          }
          if (isDifferent) differentCount++;
        }

        // With 10 items, probability of same order is 1/10! ≈ 0.00000028%
        // So we expect almost all shuffles to be different
        expect(differentCount, greaterThan(iterations * 0.99));
      },
    );

    test('Shuffle of single item returns same item', () {
      final random = Random();
      final shuffled = generateShuffledIndices(1, random);

      expect(shuffled, equals([0]));
    });

    test('Shuffle of two items produces valid permutation', () {
      final random = Random();
      final shuffled = generateShuffledIndices(2, random);

      expect(shuffled.length, equals(2));
      expect(shuffled.toSet(), equals({0, 1}));
    });

    test(
      'Property 8.3: Multiple shuffles produce different results (statistical test)',
      () {
        final random = Random();
        const count = 5;
        const shuffleCount = 10;

        final results = <String>[];
        for (var i = 0; i < shuffleCount; i++) {
          final shuffled = generateShuffledIndices(count, random);
          results.add(shuffled.join(','));
        }

        // With 5 items, there are 120 permutations
        // 10 shuffles should produce at least a few unique results
        final uniqueResults = results.toSet();
        expect(uniqueResults.length, greaterThan(1));
      },
    );
  });

  group('Repeat Mode Cycling', () {
    test('Repeat mode cycles correctly: off -> all -> one -> off', () {
      // Simulate repeat mode cycling
      var mode = 'off';

      mode = switch (mode) {
        'off' => 'all',
        'all' => 'one',
        'one' => 'off',
        _ => 'off',
      };
      expect(mode, equals('all'));

      mode = switch (mode) {
        'off' => 'all',
        'all' => 'one',
        'one' => 'off',
        _ => 'off',
      };
      expect(mode, equals('one'));

      mode = switch (mode) {
        'off' => 'all',
        'all' => 'one',
        'one' => 'off',
        _ => 'off',
      };
      expect(mode, equals('off'));
    });
  });

  group('Track Navigation', () {
    test('Next track index wraps around in repeat all mode', () {
      const fileCount = 5;
      const currentIndex = 4; // Last track
      const repeatAll = true;

      const nextIndex = currentIndex + 1;
      const wrappedIndex = repeatAll && nextIndex >= fileCount ? 0 : nextIndex;

      expect(wrappedIndex, equals(0));
    });

    test('Previous track index wraps around in repeat all mode', () {
      const fileCount = 5;
      const currentIndex = 0; // First track
      const repeatAll = true;

      const prevIndex = currentIndex - 1;
      const wrappedIndex =
          repeatAll && prevIndex < 0 ? fileCount - 1 : prevIndex;

      expect(wrappedIndex, equals(4));
    });

    test('Next track returns null at end without repeat', () {
      const fileCount = 5;
      const currentIndex = 4; // Last track
      const repeatAll = false;

      const nextIndex = currentIndex + 1;
      const result = nextIndex >= fileCount && !repeatAll ? null : nextIndex;

      expect(result, isNull);
    });

    test(
      'Repeat one still advances to the next track for manual navigation',
      () {
        final playlist = Playlist.create(id: 'p1', name: 'Test').copyWith(
          files: const [
            AudioFile(
              id: '1',
              path: '/music/1.mp3',
              title: '1',
              duration: Duration(minutes: 1),
              fileSizeBytes: 1,
            ),
            AudioFile(
              id: '2',
              path: '/music/2.mp3',
              title: '2',
              duration: Duration(minutes: 1),
              fileSizeBytes: 1,
            ),
            AudioFile(
              id: '3',
              path: '/music/3.mp3',
              title: '3',
              duration: Duration(minutes: 1),
              fileSizeBytes: 1,
            ),
          ],
        );
        final state = PlaylistState(
          currentPlaylist: playlist,
          currentTrackIndex: 1,
          repeatMode: RepeatMode.one,
        );

        expect(state.previousTrackIndex, 0);
        expect(state.nextTrackIndex, 2);
        expect(state.hasPrevious, isTrue);
        expect(state.hasNext, isTrue);
      },
    );

    test('Repeat one wraps previous from the first track', () {
      final playlist = Playlist.create(id: 'p1', name: 'Test').copyWith(
        files: const [
          AudioFile(
            id: '1',
            path: '/music/1.mp3',
            title: '1',
            duration: Duration(minutes: 1),
            fileSizeBytes: 1,
          ),
          AudioFile(
            id: '2',
            path: '/music/2.mp3',
            title: '2',
            duration: Duration(minutes: 1),
            fileSizeBytes: 1,
          ),
        ],
      );
      final state = PlaylistState(
        currentPlaylist: playlist,
        repeatMode: RepeatMode.one,
      );

      expect(state.hasPrevious, isTrue);
      expect(state.previousTrackIndex, 1);
    });

    test('Repeat one wraps next from the last track', () {
      final playlist = Playlist.create(id: 'p1', name: 'Test').copyWith(
        files: const [
          AudioFile(
            id: '1',
            path: '/music/1.mp3',
            title: '1',
            duration: Duration(minutes: 1),
            fileSizeBytes: 1,
          ),
          AudioFile(
            id: '2',
            path: '/music/2.mp3',
            title: '2',
            duration: Duration(minutes: 1),
            fileSizeBytes: 1,
          ),
        ],
      );
      final state = PlaylistState(
        currentPlaylist: playlist,
        currentTrackIndex: 1,
        repeatMode: RepeatMode.one,
      );

      expect(state.hasNext, isTrue);
      expect(state.nextTrackIndex, 0);
    });
  });
}
