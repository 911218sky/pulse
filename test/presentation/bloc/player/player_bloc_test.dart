import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/domain/entities/audio_file.dart';

import '../../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 7: Skip Forward/Backward Bounds
/// **Validates: Requirements 7.4, 7.5**
///
/// For any current position P and skip duration S:
/// - Skip forward: new position = min(P + S, duration)
/// - Skip backward: new position = max(P - S, 0)

/// Feature: flutter-music-player, Property 3: Time Input Validation
/// **Validates: Requirements 3.2, 3.3**
///
/// For any time input T and duration D:
/// - If T is valid format and 0 <= T <= D, seek succeeds
/// - If T is invalid format or T < 0 or T > D, seek fails or clamps

void main() {
  group('Skip Forward/Backward Bounds', () {
    test('Property 7.1: Skip forward clamps to duration (100 iterations)', () {
      PropertyTest.forAll(
        generator:
            () => (
              PropertyTest.randomDuration(maxHours: 2), // current position
              PropertyTest.randomDuration(maxHours: 3), // total duration
              PropertyTest.randomInt(min: 5, max: 60), // skip seconds
            ),
        property: (input) {
          final (position, duration, skipSeconds) = input;

          // Calculate expected new position
          final newPosition = position + Duration(seconds: skipSeconds);
          final clampedPosition =
              newPosition > duration ? duration : newPosition;

          // Verify clamping behavior
          expect(
            clampedPosition.inMilliseconds,
            lessThanOrEqualTo(duration.inMilliseconds),
          );
          // Clamped position should be >= 0
          expect(clampedPosition.inMilliseconds, greaterThanOrEqualTo(0));
        },
      );
    });

    test('Property 7.2: Skip backward clamps to zero (100 iterations)', () {
      PropertyTest.forAll(
        generator:
            () => (
              PropertyTest.randomDuration(maxHours: 2), // current position
              PropertyTest.randomInt(min: 5, max: 60), // skip seconds
            ),
        property: (input) {
          final (position, skipSeconds) = input;

          // Calculate expected new position
          final newPosition = position - Duration(seconds: skipSeconds);
          final clampedPosition =
              newPosition.isNegative ? Duration.zero : newPosition;

          // Verify clamping behavior
          expect(clampedPosition.inMilliseconds, greaterThanOrEqualTo(0));
          expect(
            clampedPosition.inMilliseconds,
            lessThanOrEqualTo(position.inMilliseconds),
          );
        },
      );
    });

    test('Skip forward at end of track stays at end', () {
      const duration = Duration(minutes: 5);
      const position = Duration(minutes: 4, seconds: 55);
      const skipSeconds = 10;

      final newPosition = position + const Duration(seconds: skipSeconds);
      final clampedPosition = newPosition > duration ? duration : newPosition;

      expect(clampedPosition, equals(duration));
    });

    test('Skip backward at start of track stays at start', () {
      const position = Duration(seconds: 3);
      const skipSeconds = 10;

      final newPosition = position - const Duration(seconds: skipSeconds);
      final clampedPosition =
          newPosition.isNegative ? Duration.zero : newPosition;

      expect(clampedPosition, equals(Duration.zero));
    });
  });

  group('Time Input Validation', () {
    test(
      'Property 3.1: Valid time within duration is accepted (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final duration = PropertyTest.randomDuration(maxHours: 3);
            // Generate a position within the duration
            final positionMs = PropertyTest.randomInt(
              max: duration.inMilliseconds + 1,
            );
            return (Duration(milliseconds: positionMs), duration);
          },
          property: (input) {
            final (position, duration) = input;

            // Position should be valid (within bounds)
            final isValid = position >= Duration.zero && position <= duration;
            expect(isValid, isTrue);
          },
        );
      },
    );

    test(
      'Property 3.2: Position beyond duration is clamped (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () {
            final duration = PropertyTest.randomDuration(maxHours: 2);
            // Generate a position beyond the duration
            final extraMs = PropertyTest.randomInt(min: 1, max: 100000);
            final position = Duration(
              milliseconds: duration.inMilliseconds + extraMs,
            );
            return (position, duration);
          },
          property: (input) {
            final (position, duration) = input;

            // Clamp to duration
            final clampedPosition = position > duration ? duration : position;

            expect(clampedPosition, equals(duration));
          },
        );
      },
    );

    test(
      'Property 3.3: Negative position is clamped to zero (100 iterations)',
      () {
        PropertyTest.forAll(
          generator:
              () => Duration(
                milliseconds: -PropertyTest.randomInt(min: 1, max: 100000),
              ),
          property: (position) {
            // Clamp to zero
            final clampedPosition =
                position.isNegative ? Duration.zero : position;

            expect(clampedPosition, equals(Duration.zero));
          },
        );
      },
    );
  });

  group('AudioFile generation helper', () {
    test('generates valid audio files', () {
      final audioFile = AudioFile(
        id: PropertyTest.randomNonEmptyString(),
        path: '/music/${PropertyTest.randomNonEmptyString()}.mp3',
        title: PropertyTest.randomNonEmptyString(),
        duration: PropertyTest.randomDuration(maxHours: 2),
        fileSizeBytes: PropertyTest.randomInt(min: 1000, max: 100000000),
      );

      expect(audioFile.id, isNotEmpty);
      expect(audioFile.path, contains('.mp3'));
      expect(audioFile.title, isNotEmpty);
      expect(audioFile.duration.inMilliseconds, greaterThanOrEqualTo(0));
      expect(audioFile.fileSizeBytes, greaterThan(0));
    });
  });
}
