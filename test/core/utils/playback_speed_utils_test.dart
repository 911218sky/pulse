import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/playback_speed_utils.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 6: Playback Speed Clamping
/// **Validates: Requirements 7.6**
///
/// For any playback speed S:
/// - If 0.5 <= S <= 2.0, the resulting speed SHALL equal S
/// - If S < 0.5, the resulting speed SHALL equal 0.5
/// - If S > 2.0, the resulting speed SHALL equal 2.0

void main() {
  group('PlaybackSpeedUtils', () {
    test('Property 6: Speed clamp preserves valid values (100 iterations)', () {
      PropertyTest.forAll(
        generator: () => PropertyTest.randomDouble(min: 0.5, max: 2),
        property: (speed) {
          final clamped = PlaybackSpeedUtils.clamp(speed);
          expect(clamped, closeTo(speed, 0.0001));
        },
      );
    });

    test(
      'Property 6: Speed clamp returns 0.5 for values < 0.5 (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: -10, max: 0.5),
          property: (speed) {
            final clamped = PlaybackSpeedUtils.clamp(speed);
            expect(clamped, equals(0.5));
          },
        );
      },
    );

    test(
      'Property 6: Speed clamp returns 2.0 for values > 2.0 (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: 2, max: 10),
          property: (speed) {
            final clamped = PlaybackSpeedUtils.clamp(speed);
            expect(clamped, equals(2));
          },
        );
      },
    );

    test(
      'Property 6: Clamped speed is always in valid range (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: -10, max: 10),
          property: (speed) {
            final clamped = PlaybackSpeedUtils.clamp(speed);
            expect(clamped, greaterThanOrEqualTo(0.5));
            expect(clamped, lessThanOrEqualTo(2));
          },
        );
      },
    );

    group('increase/decrease', () {
      test('increase adds step and clamps to max', () {
        expect(PlaybackSpeedUtils.increase(1), equals(1.25));
        expect(PlaybackSpeedUtils.increase(1.75), equals(2));
        expect(PlaybackSpeedUtils.increase(2), equals(2));
      });

      test('decrease subtracts step and clamps to min', () {
        expect(PlaybackSpeedUtils.decrease(1), equals(0.75));
        expect(PlaybackSpeedUtils.decrease(0.75), equals(0.5));
        expect(PlaybackSpeedUtils.decrease(0.5), equals(0.5));
      });
    });

    group('utility methods', () {
      test('isNormalSpeed returns true for 1.0x', () {
        expect(PlaybackSpeedUtils.isNormalSpeed(1), isTrue);
        expect(PlaybackSpeedUtils.isNormalSpeed(1.001), isTrue);
        expect(PlaybackSpeedUtils.isNormalSpeed(0.5), isFalse);
        expect(PlaybackSpeedUtils.isNormalSpeed(2), isFalse);
      });

      test('isMinSpeed returns true for minimum speed', () {
        expect(PlaybackSpeedUtils.isMinSpeed(0.5), isTrue);
        expect(PlaybackSpeedUtils.isMinSpeed(0.4), isTrue);
        expect(PlaybackSpeedUtils.isMinSpeed(0.75), isFalse);
      });

      test('isMaxSpeed returns true for maximum speed', () {
        expect(PlaybackSpeedUtils.isMaxSpeed(2), isTrue);
        expect(PlaybackSpeedUtils.isMaxSpeed(2.1), isTrue);
        expect(PlaybackSpeedUtils.isMaxSpeed(1.75), isFalse);
      });
    });

    group('format', () {
      test('formats speeds correctly', () {
        expect(PlaybackSpeedUtils.format(1), equals('1x'));
        expect(PlaybackSpeedUtils.format(1.5), equals('1.5x'));
        expect(PlaybackSpeedUtils.format(0.75), equals('0.75x'));
        expect(PlaybackSpeedUtils.format(2), equals('2x'));
      });
    });

    group('presets', () {
      test('nextPreset cycles through presets', () {
        expect(PlaybackSpeedUtils.nextPreset(0.5), equals(0.75));
        expect(PlaybackSpeedUtils.nextPreset(1), equals(1.25));
        expect(PlaybackSpeedUtils.nextPreset(2), equals(0.5)); // Wraps around
      });

      test('previousPreset cycles through presets', () {
        expect(PlaybackSpeedUtils.previousPreset(1), equals(0.75));
        expect(PlaybackSpeedUtils.previousPreset(0.75), equals(0.5));
        expect(
          PlaybackSpeedUtils.previousPreset(0.5),
          equals(2),
        ); // Wraps around
      });
    });

    group('adjustedDuration', () {
      test('calculates adjusted duration correctly', () {
        const original = Duration(minutes: 10);

        // At 2x speed, 10 minutes becomes 5 minutes
        expect(
          PlaybackSpeedUtils.adjustedDuration(original, 2),
          equals(const Duration(minutes: 5)),
        );

        // At 0.5x speed, 10 minutes becomes 20 minutes
        expect(
          PlaybackSpeedUtils.adjustedDuration(original, 0.5),
          equals(const Duration(minutes: 20)),
        );

        // At 1x speed, duration is unchanged
        expect(
          PlaybackSpeedUtils.adjustedDuration(original, 1),
          equals(original),
        );
      });
    });
  });
}
