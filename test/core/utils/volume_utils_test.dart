import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/volume_utils.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 5: Volume Setting Bounds
/// **Validates: Requirements 7.1**
///
/// For any volume value V:
/// - If 0.0 <= V <= 1.0, the resulting volume SHALL equal V
/// - If V < 0.0, the resulting volume SHALL equal 0.0
/// - If V > 1.0, the resulting volume SHALL equal 1.0

void main() {
  group('VolumeUtils', () {
    test(
      'Property 5: Volume clamp preserves valid values (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: PropertyTest.randomDouble,
          property: (volume) {
            final clamped = VolumeUtils.clamp(volume);
            expect(clamped, equals(volume));
          },
        );
      },
    );

    test(
      'Property 5: Volume clamp returns 0.0 for negative values (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: -100, max: 0),
          property: (volume) {
            final clamped = VolumeUtils.clamp(volume);
            expect(clamped, equals(0));
          },
        );
      },
    );

    test(
      'Property 5: Volume clamp returns 1.0 for values > 1.0 (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: 1, max: 100),
          property: (volume) {
            final clamped = VolumeUtils.clamp(volume);
            expect(clamped, equals(1));
          },
        );
      },
    );

    test(
      'Property 5: Clamped volume is always in valid range (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomDouble(min: -100, max: 100),
          property: (volume) {
            final clamped = VolumeUtils.clamp(volume);
            expect(clamped, greaterThanOrEqualTo(0));
            expect(clamped, lessThanOrEqualTo(1));
          },
        );
      },
    );

    group('increase/decrease', () {
      test('increase adds step and clamps to max', () {
        expect(VolumeUtils.increase(0.5), closeTo(0.55, 0.001));
        expect(VolumeUtils.increase(0.98), equals(1));
        expect(VolumeUtils.increase(1), equals(1));
      });

      test('decrease subtracts step and clamps to min', () {
        expect(VolumeUtils.decrease(0.5), closeTo(0.45, 0.001));
        expect(VolumeUtils.decrease(0.02), equals(0));
        expect(VolumeUtils.decrease(0), equals(0));
      });
    });

    group('percentage conversion', () {
      test('toPercentage converts correctly', () {
        expect(VolumeUtils.toPercentage(0), equals(0));
        expect(VolumeUtils.toPercentage(0.5), equals(50));
        expect(VolumeUtils.toPercentage(1), equals(100));
      });

      test('fromPercentage converts correctly', () {
        expect(VolumeUtils.fromPercentage(0), equals(0));
        expect(VolumeUtils.fromPercentage(50), equals(0.5));
        expect(VolumeUtils.fromPercentage(100), equals(1));
      });

      test('percentage round-trip preserves value (100 iterations)', () {
        PropertyTest.forAll(
          generator: () => PropertyTest.randomInt(max: 101),
          property: (percentage) {
            final volume = VolumeUtils.fromPercentage(percentage);
            final restored = VolumeUtils.toPercentage(volume);
            expect(restored, equals(percentage));
          },
        );
      });
    });

    group('utility methods', () {
      test('isMuted returns true for zero volume', () {
        expect(VolumeUtils.isMuted(0), isTrue);
        expect(VolumeUtils.isMuted(0.01), isFalse);
        expect(VolumeUtils.isMuted(1), isFalse);
      });

      test('isMaxVolume returns true for max volume', () {
        expect(VolumeUtils.isMaxVolume(1), isTrue);
        expect(VolumeUtils.isMaxVolume(0.99), isFalse);
        expect(VolumeUtils.isMaxVolume(0), isFalse);
      });

      test('formatAsPercentage formats correctly', () {
        expect(VolumeUtils.formatAsPercentage(0), equals('0%'));
        expect(VolumeUtils.formatAsPercentage(0.5), equals('50%'));
        expect(VolumeUtils.formatAsPercentage(1), equals('100%'));
      });
    });

    group('fade out', () {
      test('calculateFadeOutVolume fades correctly', () {
        expect(VolumeUtils.calculateFadeOutVolume(1, 0), equals(1));
        expect(VolumeUtils.calculateFadeOutVolume(1, 0.5), equals(0.5));
        expect(VolumeUtils.calculateFadeOutVolume(1, 1), equals(0));
        expect(
          VolumeUtils.calculateFadeOutVolume(0.8, 0.5),
          closeTo(0.4, 0.001),
        );
      });
    });
  });
}
