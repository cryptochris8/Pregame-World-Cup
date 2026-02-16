import 'package:flutter/material.dart';

import 'app_initializer.dart';
import 'app.dart';

/// Entry point for the Pregame World Cup app.
///
/// All initialization logic lives in [initializeApp] (see `app_initializer.dart`).
/// The widget tree is defined in [PregameApp] (see `app.dart`).
Future<void> main() async {
  await initializeApp();

  // Step 8: Launch App
  debugLog('INIT STEP 8: Launching App');
  try {
    runApp(const PregameApp());
    debugLog('INIT STEP 8: App Launch - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 8: App Launch - FAILED: $e');
  }
}
