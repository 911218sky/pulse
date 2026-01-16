import 'package:logger/logger.dart';

/// Centralized logger for the app
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug message with component tag
  static void d(String component, String message) {
    _logger.d('[$component] $message');
  }

  /// Log info message with component tag
  static void i(String component, String message) {
    _logger.i('[$component] $message');
  }

  /// Log warning message with component tag
  static void w(String component, String message) {
    _logger.w('[$component] $message');
  }

  /// Log error message with component tag
  static void e(
    String component,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.e('[$component] $message', error: error, stackTrace: stackTrace);
  }
}
