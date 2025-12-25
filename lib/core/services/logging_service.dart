import 'dart:developer' as developer;

/// Centralized logging service for the Pregame app
class LoggingService {
  static const String _defaultTag = 'Pregame';

  /// Log an info message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 800, // Info level
    );
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 900, // Warning level
    );
  }

  /// Log an error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log debug information (only in debug builds)
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 700, // Debug level
    );
  }

  /// Log API call information
  static void api(String message, {String? tag}) {
    developer.log(
      '🌐 $message',
      name: tag ?? '${_defaultTag}API',
      level: 800,
    );
  }

  /// Log navigation events
  static void navigation(String message, {String? tag}) {
    developer.log(
      '🧭 $message',
      name: tag ?? '${_defaultTag}Nav',
      level: 800,
    );
  }

  /// Log social interaction events
  static void social(String message, {String? tag}) {
    developer.log(
      '👥 $message',
      name: tag ?? '${_defaultTag}Social',
      level: 800,
    );
  }

  /// Log messaging events
  static void messaging(String message, {String? tag}) {
    developer.log(
      '💬 $message',
      name: tag ?? '${_defaultTag}Messaging',
      level: 800,
    );
  }

  /// Log venue-related events
  static void venue(String message, {String? tag}) {
    developer.log(
      '🏟️ $message',
      name: tag ?? '${_defaultTag}Venue',
      level: 800,
    );
  }

  /// Log schedule-related events
  static void schedule(String message, {String? tag}) {
    developer.log(
      '📅 $message',
      name: tag ?? '${_defaultTag}Schedule',
      level: 800,
    );
  }
} 