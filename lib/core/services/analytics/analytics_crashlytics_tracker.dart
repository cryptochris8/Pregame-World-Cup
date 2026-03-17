import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../logging_service.dart';

/// Extracted Crashlytics-specific tracking methods.
///
/// Provides error recording, breadcrumbs, and custom keys for crash reports.
/// Used by [AnalyticsService] via its extension import.
class AnalyticsCrashlyticsTracker {
  final FirebaseCrashlytics _crashlytics;

  AnalyticsCrashlyticsTracker(this._crashlytics);

  /// Log a fatal error (crash)
  Future<void> logFatalError({
    required Object error,
    required StackTrace stackTrace,
    String? context,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: context ?? 'Fatal error',
      fatal: true,
    );
  }

  /// Set custom Crashlytics key-value pair
  Future<void> setCrashlyticsKey(String key, Object value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }
    } catch (e) {
      LoggingService.error('Failed to set Crashlytics key: $e', tag: 'Analytics');
    }
  }

  /// Log a breadcrumb for crash context
  Future<void> logBreadcrumb(String message) async {
    await _crashlytics.log(message);
  }
}
