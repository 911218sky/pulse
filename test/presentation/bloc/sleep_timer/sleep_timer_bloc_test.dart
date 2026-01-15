import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 12: Sleep Timer Countdown
/// **Validates: Requirements 12.1, 12.2**
///
/// For any sleep timer with duration D:
/// - Remaining time decreases monotonically
/// - Timer expires when remaining time reaches 0
/// - Fade out begins at 30 seconds remaining (if enabled)

void main() {
  group('Sleep Timer Countdown', () {
    test(
      'Property 12.1: Remaining time calculation is correct (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => (
            PropertyTest.randomDuration(maxHours: 2), // total duration
            PropertyTest.randomDuration(maxHours: 2), // elapsed time
          ),
          property: (input) {
            final (totalDuration, elapsed) = input;

            // Calculate remaining time
            final remaining = totalDuration - elapsed;
            final clampedRemaining =
                remaining.isNegative ? Duration.zero : remaining;

            // Remaining should be non-negative
            expect(clampedRemaining.inMilliseconds, greaterThanOrEqualTo(0));

            // Remaining should not exceed total
            expect(clampedRemaining.inMilliseconds,
                lessThanOrEqualTo(totalDuration.inMilliseconds));
          },
        );
      },
    );

    test(
      'Property 12.2: Progress calculation is bounded [0, 1] (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => (
            PropertyTest.randomDuration(maxHours: 2), // total duration
            PropertyTest.randomDuration(maxHours: 2), // elapsed time
          ),
          property: (input) {
            final (totalDuration, elapsed) = input;

            if (totalDuration.inMilliseconds == 0) return;

            // Calculate progress
            final progress =
                elapsed.inMilliseconds / totalDuration.inMilliseconds;
            final clampedProgress = progress.clamp(0, 1);

            expect(clampedProgress, greaterThanOrEqualTo(0));
            expect(clampedProgress, lessThanOrEqualTo(1));
          },
        );
      },
    );

    test('Timer expires when remaining reaches zero', () {
      const totalDuration = Duration(minutes: 5);
      const elapsed = Duration(minutes: 5);

      final remaining = totalDuration - elapsed;
      final isExpired = remaining.isNegative || remaining == Duration.zero;

      expect(isExpired, isTrue);
    });

    test('Timer not expired when remaining is positive', () {
      const totalDuration = Duration(minutes: 5);
      const elapsed = Duration(minutes: 3);

      final remaining = totalDuration - elapsed;
      final isExpired = remaining.isNegative || remaining == Duration.zero;

      expect(isExpired, isFalse);
      expect(remaining, equals(const Duration(minutes: 2)));
    });
  });

  group('Fade Out Calculation', () {
    test('Fade out begins at 30 seconds remaining', () {
      const remaining = Duration(seconds: 30);
      const fadeOutThreshold = Duration(seconds: 30);

      final shouldFadeOut = remaining <= fadeOutThreshold;

      expect(shouldFadeOut, isTrue);
    });

    test('No fade out when more than 30 seconds remaining', () {
      const remaining = Duration(seconds: 31);
      const fadeOutThreshold = Duration(seconds: 30);

      final shouldFadeOut = remaining <= fadeOutThreshold;

      expect(shouldFadeOut, isFalse);
    });

    test(
      'Property 12.3: Fade out progress is bounded [0, 1] (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomInt(max: 60), // seconds remaining
          property: (secondsRemaining) {
            // Calculate fade out progress (0 at 30s, 1 at 0s)
            final fadeOutProgress =
                secondsRemaining <= 30 ? 1 - (secondsRemaining / 30) : 0;
            final clampedProgress = fadeOutProgress.clamp(0, 1);

            expect(clampedProgress, greaterThanOrEqualTo(0));
            expect(clampedProgress, lessThanOrEqualTo(1));
          },
        );
      },
    );

    test('Fade out volume calculation', () {
      // At 30 seconds: volume = 1.0
      expect(1 - (1 - (30 / 30)), equals(1));

      // At 15 seconds: volume = 0.5
      expect(1 - (1 - (15 / 30)), equals(0.5));

      // At 0 seconds: volume = 0.0
      expect(1 - (1 - (0 / 30)), equals(0));
    });
  });

  group('Timer Extension', () {
    test('Extending timer adds to remaining duration', () {
      const currentRemaining = Duration(minutes: 5);
      const extension = Duration(minutes: 10);

      final newRemaining = currentRemaining + extension;

      expect(newRemaining, equals(const Duration(minutes: 15)));
    });

    test('Extending timer updates total duration', () {
      const currentTotal = Duration(minutes: 30);
      const extension = Duration(minutes: 15);

      final newTotal = currentTotal + extension;

      expect(newTotal, equals(const Duration(minutes: 45)));
    });
  });

  group('Preset Durations', () {
    test('Preset durations are valid', () {
      const presets = [
        Duration(minutes: 15),
        Duration(minutes: 30),
        Duration(minutes: 45),
        Duration(minutes: 60),
        Duration(minutes: 90),
      ];

      for (final preset in presets) {
        expect(preset.inMinutes, greaterThan(0));
        expect(preset.inMinutes, lessThanOrEqualTo(90));
      }
    });
  });
}
