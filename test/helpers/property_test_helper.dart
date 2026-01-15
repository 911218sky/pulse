import 'dart:math';

/// Simple property-based testing helper
/// Runs a test function with randomly generated inputs
class PropertyTest {
  static final Random _random = Random();

  /// Runs a property test with the given number of iterations
  static void forAll<T>({
    required T Function() generator,
    required void Function(T) property,
    int iterations = 100,
  }) {
    for (var i = 0; i < iterations; i++) {
      final input = generator();
      property(input);
    }
  }

  /// Generates a random string of given length
  static String randomString({int minLength = 1, int maxLength = 50}) {
    final length = minLength + _random.nextInt(maxLength - minLength + 1);
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// Generates a random non-empty string
  static String randomNonEmptyString({int maxLength = 50}) =>
      randomString(maxLength: maxLength);

  /// Generates a random int in range [min, max)
  static int randomInt({int min = 0, int max = 1000000}) =>
      min + _random.nextInt(max - min);

  /// Generates a random positive int
  static int randomPositiveInt({int max = 1000000}) => _random.nextInt(max) + 1;

  /// Generates a random non-negative int
  static int randomNonNegativeInt({int max = 1000000}) => _random.nextInt(max);

  /// Generates a random double in range [min, max)
  static double randomDouble({double min = 0, double max = 1}) =>
      min + _random.nextDouble() * (max - min);

  /// Generates a random DateTime
  static DateTime randomDateTime() {
    final year = 2020 + _random.nextInt(10);
    final month = 1 + _random.nextInt(12);
    final day = 1 + _random.nextInt(28);
    final hour = _random.nextInt(24);
    final minute = _random.nextInt(60);
    final second = _random.nextInt(60);
    return DateTime(year, month, day, hour, minute, second);
  }

  /// Generates a random Duration
  static Duration randomDuration({int maxHours = 100}) {
    final hours = _random.nextInt(maxHours);
    final minutes = _random.nextInt(60);
    final seconds = _random.nextInt(60);
    final milliseconds = _random.nextInt(1000);
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  /// Generates a random bool
  static bool randomBool() => _random.nextBool();

  /// Picks a random element from a list
  static T randomElement<T>(List<T> list) => list[_random.nextInt(list.length)];
}
