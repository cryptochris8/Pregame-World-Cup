import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app_initializer.dart';
import 'app.dart';
import 'core/services/logging_service.dart';

/// Entry point for the Pregame World Cup app.
///
/// All initialization logic lives in [initializeApp] (see `app_initializer.dart`).
/// The widget tree is defined in [PregameApp] (see `app.dart`).
Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    await initializeApp();

    // Set up early error handlers so errors are caught before AnalyticsService init
    FlutterError.onError = (FlutterErrorDetails details) {
      LoggingService.error(
        'FlutterError: ${details.exceptionAsString()}',
        tag: 'ErrorHandler',
      );
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      LoggingService.error(
        'PlatformDispatcher error: $error',
        tag: 'ErrorHandler',
        error: error,
        stackTrace: stack,
      );
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };

    // Step 8: Launch App
    debugLog('INIT STEP 8: Launching App');
    try {
      runApp(const PregameApp());
      debugLog('INIT STEP 8: App Launch - SUCCESS');
    } catch (e) {
      debugLog('INIT STEP 8: App Launch - FAILED: $e');
    }
  }, (error, stack) {
    LoggingService.error(
      'Uncaught zone error: $error',
      tag: 'ErrorHandler',
      error: error,
      stackTrace: stack,
    );
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}
