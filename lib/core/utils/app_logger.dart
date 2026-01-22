import 'dart:developer' as dev;

/// Centralized logger for the app
class AppLogger {
  AppLogger._();

  /// Log debug message with component tag
  static void d(String component, String message) {
    dev.log('[$component] $message', name: 'DEBUG');
  }

  /// Log info message with component tag
  static void i(String component, String message) {
    dev.log('[$component] $message', name: 'INFO');
  }

  /// Log warning message with component tag
  static void w(String component, String message) {
    dev.log('[$component] $message', name: 'WARN');
  }

  /// Log error message with component tag
  static void e(
    String component,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    dev.log(
      '[$component] $message',
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
