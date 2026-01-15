import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/data/models/playback_state_model.dart';
import 'package:pulse/domain/entities/playback_state.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 2: PlaybackState Persistence Round-Trip
/// **Validates: Requirements 2.2, 2.4**
///
/// For any valid PlaybackState object, saving to storage and then loading
/// SHALL produce an equivalent PlaybackState with the same audioFilePath,
/// position, volume, and playbackSpeed.

PlaybackState generateRandomPlaybackState() => PlaybackState(
  audioFilePath: '/music/${PropertyTest.randomNonEmptyString()}.mp3',
  position: PropertyTest.randomDuration(),
  savedAt: PropertyTest.randomDateTime(),
  volume: PropertyTest.randomDouble(),
  playbackSpeed: PropertyTest.randomDouble(min: 0.5, max: 2),
);

void main() {
  group('PlaybackStateModel', () {
    test(
      'Property 2: PlaybackState round-trip through model conversion preserves all fields (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: generateRandomPlaybackState,
          property: (playbackState) {
            // Convert to model
            final model = PlaybackStateModel.fromEntity(playbackState);

            // Convert back to entity
            final restored = model.toEntity();

            // Verify all fields are preserved
            expect(restored.audioFilePath, equals(playbackState.audioFilePath));
            expect(restored.position, equals(playbackState.position));
            expect(restored.savedAt, equals(playbackState.savedAt));
            expect(restored.volume, equals(playbackState.volume));
            expect(restored.playbackSpeed, equals(playbackState.playbackSpeed));
          },
        );
      },
    );

    test(
      'Property 2: PlaybackState round-trip through JSON preserves all fields (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: generateRandomPlaybackState,
          property: (playbackState) {
            // Convert to model then to JSON
            final model = PlaybackStateModel.fromEntity(playbackState);
            final json = model.toJson();

            // Convert back from JSON to model to entity
            final restoredModel = PlaybackStateModel.fromJson(json);
            final restored = restoredModel.toEntity();

            // Verify all fields are preserved
            expect(restored.audioFilePath, equals(playbackState.audioFilePath));
            expect(restored.position, equals(playbackState.position));
            expect(restored.savedAt, equals(playbackState.savedAt));
            expect(restored.volume, equals(playbackState.volume));
            expect(restored.playbackSpeed, equals(playbackState.playbackSpeed));
          },
        );
      },
    );

    test('PlaybackState.create sets savedAt to current time', () {
      final before = DateTime.now();
      final state = PlaybackState.create(
        audioFilePath: '/test/audio.mp3',
        position: const Duration(minutes: 5),
        volume: 0.8,
        playbackSpeed: 1.5,
      );
      final after = DateTime.now();

      expect(
        state.savedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        state.savedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
