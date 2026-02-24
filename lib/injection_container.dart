import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import 'di/core_di.dart';
import 'di/ai_di.dart';
import 'di/data_services_di.dart';
import 'di/recommendations_di.dart';
import 'di/social_di.dart';
import 'di/worldcup_di.dart';
import 'di/watch_party_di.dart';
import 'di/moderation_admin_di.dart';
import 'di/extended_features_di.dart';

// Global GetIt instance
final sl = GetIt.instance; // sl stands for Service Locator

/// Android diagnostic mode - set to false for production
// ignore: constant_identifier_names
const bool ANDROID_DIAGNOSTIC_MODE = false;

/// Debug-only log helper. Stripped by tree-shaking in release builds.
void _diLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

Future<void> setupLocator() async {
  if (ANDROID_DIAGNOSTIC_MODE) {
    _diLog('DI: Starting in Android diagnostic mode');
  }

  try {
    // Steps 1-2: Core dependencies and essential services (must succeed)
    _diLog('DI STEPS 1-2: Core Dependencies & Services');
    await registerCoreDependencies(sl);
    _diLog('DI STEPS 1-2: Core Dependencies & Services - SUCCESS');

    // Steps 3-4: AI services (non-critical)
    _diLog('DI STEPS 3-4: AI Services');
    try {
      registerAIServices(sl);
      _diLog('DI STEPS 3-4: AI Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEPS 3-4: AI Services - FAILED: $e');
    }

    // Steps 5-6: ESPN/API and Schedule services
    _diLog('DI STEPS 5-6: Data & Schedule Services');
    try {
      await registerDataServices(sl);
      _diLog('DI STEPS 5-6: Data & Schedule Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEPS 5-6: Data & Schedule Services - FAILED: $e');
    }

    // Step 7: Recommendation services
    _diLog('DI STEP 7: Recommendation Services');
    try {
      registerRecommendationServices(sl);
      _diLog('DI STEP 7: Recommendation Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEP 7: Recommendation Services - FAILED: $e');
    }

    // Step 8: Social and external services
    _diLog('DI STEP 8: Social & External Services');
    try {
      registerSocialServices(sl);
      _diLog('DI STEP 8: Social & External Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEP 8: Social & External Services - FAILED: $e');
    }

    // Step 9: World Cup 2026 services
    _diLog('DI STEP 9: World Cup 2026 Services');
    try {
      registerWorldCupServices(sl);
      _diLog('DI STEP 9: World Cup 2026 Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEP 9: World Cup 2026 Services - FAILED: $e');
    }

    // Step 10: Watch Party services
    _diLog('DI STEP 10: Watch Party Services');
    try {
      registerWatchPartyServices(sl);
      _diLog('DI STEP 10: Watch Party Services - SUCCESS');
    } catch (e) {
      _diLog('DI STEP 10: Watch Party Services - FAILED: $e');
    }

    // Steps 11-13: Moderation, Admin, Match Chat services
    _diLog('DI STEPS 11-13: Moderation, Admin & Match Chat');
    try {
      registerModerationAdminServices(sl);
      _diLog('DI STEPS 11-13: Moderation, Admin & Match Chat - SUCCESS');
    } catch (e) {
      _diLog('DI STEPS 11-13: Moderation, Admin & Match Chat - FAILED: $e');
    }

    // Steps 14-16: Chatbot, Calendar, Sharing services
    _diLog('DI STEPS 14-16: Extended Features');
    try {
      registerExtendedFeatures(sl);
      _diLog('DI STEPS 14-16: Extended Features - SUCCESS');
    } catch (e) {
      _diLog('DI STEPS 14-16: Extended Features - FAILED: $e');
    }

    if (ANDROID_DIAGNOSTIC_MODE) {
      _diLog('DI: All steps completed');
    }

  } catch (e) {
    _diLog('DI: Critical failure: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      _diLog('DIAGNOSTIC: This is a critical error that will prevent app startup');
    }
    rethrow;
  }
}
