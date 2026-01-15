import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/time_parser.dart';

import '../../helpers/property_test_helper.dart';

/// Feature: flutter-music-player, Property 11: Time Parser Round-Trip
/// **Validates: Requirements 3.2**
///
/// For any Duration D where D >= 0:
/// - format(D) produces a valid time string
/// - parse(format(D)) produces a Duration equivalent to D

void main() {
  group('TimeParser', () {
    test(
      'Property 11: Time parser round-trip preserves duration (100 iterations)',
      () {
        PropertyTest.forAll(
          generator: PropertyTest.randomDuration,
          property: (duration) {
            // Truncate to seconds (format doesn't preserve milliseconds)
            final truncated = Duration(seconds: duration.inSeconds);

            // Format then parse
            final formatted = TimeParser.format(truncated);
            final parsed = TimeParser.parse(formatted);

            // Should round-trip correctly
            expect(parsed, isNotNull);
            expect(parsed, equals(truncated));
          },
        );
      },
    );

    test(
      'Property 11b: fromHMS round-trip preserves components (100 iterations)',
      () {
        PropertyTest.forAll(
          generator:
              () => (
                PropertyTest.randomInt(max: 100), // hours
                PropertyTest.randomInt(max: 59), // minutes
                PropertyTest.randomInt(max: 59), // seconds
              ),
          property: (input) {
            final (hours, minutes, seconds) = input;

            // Create duration from HMS
            final duration = TimeParser.fromHMS(hours, minutes, seconds);

            // Extract components
            final extractedHours = TimeParser.getHours(duration);
            final extractedMinutes = TimeParser.getMinutes(duration);
            final extractedSeconds = TimeParser.getSeconds(duration);

            // Should match original
            expect(extractedHours, equals(hours));
            expect(extractedMinutes, equals(minutes));
            expect(extractedSeconds, equals(seconds));
          },
        );
      },
    );

    group('parse', () {
      test('parses HH:MM:SS format', () {
        expect(
          TimeParser.parse('01:30:45'),
          equals(const Duration(hours: 1, minutes: 30, seconds: 45)),
        );
        expect(
          TimeParser.parse('100:00:00'),
          equals(const Duration(hours: 100)),
        );
      });

      test('parses MM:SS format', () {
        expect(
          TimeParser.parse('05:30'),
          equals(const Duration(minutes: 5, seconds: 30)),
        );
        expect(TimeParser.parse('00:00'), equals(Duration.zero));
      });

      test('parses SS format', () {
        expect(TimeParser.parse('45'), equals(const Duration(seconds: 45)));
        expect(TimeParser.parse('0'), equals(Duration.zero));
      });

      test('returns null for invalid formats', () {
        expect(TimeParser.parse(''), isNull);
        expect(TimeParser.parse('abc'), isNull);
        expect(TimeParser.parse('1:2:3:4'), isNull);
        expect(TimeParser.parse('-1:00'), isNull);
        expect(TimeParser.parse('00:60'), isNull); // Invalid seconds
        expect(TimeParser.parse('00:60:00'), isNull); // Invalid minutes
      });
    });

    group('format', () {
      test('formats durations >= 1 hour as HH:MM:SS', () {
        expect(
          TimeParser.format(const Duration(hours: 1, minutes: 30, seconds: 45)),
          equals('01:30:45'),
        );
        expect(
          TimeParser.format(const Duration(hours: 100)),
          equals('100:00:00'),
        );
      });

      test('formats durations < 1 hour as MM:SS', () {
        expect(
          TimeParser.format(const Duration(minutes: 5, seconds: 30)),
          equals('05:30'),
        );
        expect(TimeParser.format(Duration.zero), equals('00:00'));
      });

      test('handles negative durations', () {
        expect(
          TimeParser.format(const Duration(minutes: -5, seconds: -30)),
          equals('-05:30'),
        );
      });
    });

    group('formatCompact', () {
      test('formats hours and minutes for long durations', () {
        expect(
          TimeParser.formatCompact(
            const Duration(hours: 2, minutes: 30, seconds: 45),
          ),
          equals('2h 30m'),
        );
      });

      test('formats minutes and seconds for medium durations', () {
        expect(
          TimeParser.formatCompact(const Duration(minutes: 5, seconds: 30)),
          equals('5m 30s'),
        );
      });

      test('formats just seconds for short durations', () {
        expect(
          TimeParser.formatCompact(const Duration(seconds: 45)),
          equals('45s'),
        );
      });
    });

    group('isValidTime', () {
      test('returns true for valid times', () {
        expect(
          TimeParser.isValidTime(
            const Duration(minutes: 30),
            const Duration(hours: 1),
          ),
          isTrue,
        );
        expect(
          TimeParser.isValidTime(Duration.zero, const Duration(hours: 1)),
          isTrue,
        );
        expect(
          TimeParser.isValidTime(
            const Duration(hours: 1),
            const Duration(hours: 1),
          ),
          isTrue,
        );
      });

      test('returns false for invalid times', () {
        expect(
          TimeParser.isValidTime(
            const Duration(hours: 2),
            const Duration(hours: 1),
          ),
          isFalse,
        );
        expect(
          TimeParser.isValidTime(
            const Duration(seconds: -1),
            const Duration(hours: 1),
          ),
          isFalse,
        );
      });
    });

    group('parseHMS', () {
      test('parses valid HMS strings', () {
        expect(
          TimeParser.parseHMS('1', '30', '45'),
          equals(const Duration(hours: 1, minutes: 30, seconds: 45)),
        );
        expect(
          TimeParser.parseHMS('', '5', '30'),
          equals(const Duration(minutes: 5, seconds: 30)),
        );
      });

      test('returns null for invalid HMS strings', () {
        expect(TimeParser.parseHMS('abc', '0', '0'), isNull);
        expect(TimeParser.parseHMS('0', '60', '0'), isNull);
        expect(TimeParser.parseHMS('0', '0', '60'), isNull);
        expect(TimeParser.parseHMS('-1', '0', '0'), isNull);
      });
    });
  });
}
