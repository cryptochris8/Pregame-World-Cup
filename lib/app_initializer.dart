import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/services/cache_service.dart';
import 'core/ai/services/multi_provider_ai_service.dart';
import 'core/entities/game_intelligence.dart';
import 'core/entities/cached_venue_data.dart';
import 'core/entities/cached_geocoding_data.dart';
import 'core/services/firebase_app_check_service.dart';
import 'config/api_keys.dart';
import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/deep_link_navigator.dart';
import 'core/services/accessibility_service.dart';
import 'services/revenuecat_service.dart';
import 'features/worldcup/utils/timezone_utils.dart';

/// DIAGNOSTIC MODE
/// Automatically disabled in release builds for App Store compliance
/// Set to true during development for detailed logging
const bool _diagnosticModeOverride = true;
// ignore: non_constant_identifier_names
bool get DIAGNOSTIC_MODE => kDebugMode && _diagnosticModeOverride;

/// Production-safe logging function - only logs in debug mode
void debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (usually already done)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Note: debugLog not available here as it's a top-level isolate
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
}

/// Initialize the app with comprehensive error handling and logging.
///
/// This runs all initialization steps in the correct order before the app
/// widget tree is built. Steps include Flutter bindings, Firebase, Hive,
/// cache, timezone, dependency injection, API key validation, and several
/// background service initializations.
Future<void> initializeApp() async {
  // Step 1: Flutter Framework Initialization
  debugLog('INIT STEP 1: Flutter Framework');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugLog('INIT STEP 1: Flutter Framework - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 1: Flutter Framework - FAILED: $e');
    // Continue anyway - this is critical
  }

  // Step 2: Firebase Core Initialization
  debugLog('INIT STEP 2: Firebase Core');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Register background message handler for FCM
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached schedule data
    // This ensures the app doesn't fall back to cached 2024 data when offline
    await _disableFirestoreOfflinePersistence();

    debugLog('INIT STEP 2: Firebase Core - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 2: Firebase Core - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Firebase initialization failed. This could prevent app startup.');
      debugLog('DIAGNOSTIC: Check google-services.json configuration');
    }
  }

  // Step 3: Hive Database Initialization
  debugLog('INIT STEP 3: Hive Database');
  try {
    await Hive.initFlutter();
    debugLog('INIT STEP 3: Hive Database - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 3: Hive Database - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Hive database failed. This affects caching and may cause hangs.');
    }
  }

  // Step 4: Hive Adapters Registration
  debugLog('INIT STEP 4: Hive Adapters');
  try {
    // Register Hive adapters for custom objects
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedVenueDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedGeocodingDataAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(GameIntelligenceAdapter());
    }
    debugLog('INIT STEP 4: Hive Adapters - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 4: Hive Adapters - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Hive adapters failed. This may cause serialization issues.');
    }
  }

  // Step 5: Cache Service Initialization
  debugLog('INIT STEP 5: Cache Service');
  try {
    await CacheService.instance.initialize();

    // PRODUCTION FIX: Clear all old 2024 cache data on every app startup
    // This ensures the app ALWAYS starts with fresh 2025 data
    await _clearOld2024CacheData();

    debugLog('INIT STEP 5: Cache Service - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 5: Cache Service - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Cache service failed. App will continue without caching.');
    }
  }

  // Step 5.5: Timezone Database Initialization
  debugLog('INIT STEP 5.5: Timezone Database');
  try {
    await TimezoneUtils.initialize();
    debugLog('INIT STEP 5.5: Timezone Database - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 5.5: Timezone Database - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Timezone database failed. Match times may not convert correctly.');
    }
  }

  // Step 6: Dependency Injection Setup
  debugLog('INIT STEP 6: Dependency Injection');
  try {
    await di.setupLocator();
    debugLog('INIT STEP 6: Dependency Injection - SUCCESS');
  } catch (e) {
    debugLog('INIT STEP 6: Dependency Injection - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Service locator failed. This will prevent app features from working.');
      debugLog('DIAGNOSTIC: This is likely related to ESPN/API service initialization');
    }
  }

  // Step 6.5: API Keys Validation
  debugLog('INIT STEP 6.5: API Keys Validation');
  try {
    ApiKeys.validateApiKeys();
    debugLog('INIT STEP 6.5: API Keys Validation - COMPLETE');
  } catch (e) {
    debugLog('INIT STEP 6.5: API Keys Validation - FAILED: $e');
  }

  // Step 7: Firebase App Check (Background)
  debugLog('INIT STEP 7: Firebase App Check (Background)');
  // Initialize App Check in the background to avoid blocking the UI
  _initializeAppCheckBackground();

  // Step 7.5: AI Service Initialization (Background)
  debugLog('INIT STEP 7.5: AI Service Initialization (Background)');
  // Initialize AI services in the background to avoid blocking the UI
  _initializeAIServicesBackground();

  // Step 7.6: AI Knowledge Base Initialization (Background)
  // DISABLED: Legacy AI knowledge base not needed for World Cup app

  // Step 7.7: AdMob Initialization (Background)
  debugLog('INIT STEP 7.7: AdMob Initialization (Background)');
  _initializeAdMobBackground();

  // Step 7.8: RevenueCat Initialization (Background)
  debugLog('INIT STEP 7.8: RevenueCat Initialization (Background)');
  _initializeRevenueCatBackground();

  // Step 7.85: Stripe SDK Initialization (Background)
  debugLog('INIT STEP 7.85: Stripe SDK (Background)');
  _initializeStripeBackground();

  // Step 7.9: Analytics & Crashlytics Initialization (Background)
  debugLog('INIT STEP 7.9: Analytics & Crashlytics (Background)');
  _initializeAnalyticsBackground();

  // Step 7.10: Deep Link Service Initialization (Background)
  debugLog('INIT STEP 7.10: Deep Link Service (Background)');
  _initializeDeepLinkServiceBackground();

  // Step 7.11: Accessibility Service Initialization
  debugLog('INIT STEP 7.11: Accessibility Service');
  await _initializeAccessibilityService();

  if (DIAGNOSTIC_MODE) {
    debugLog('DIAGNOSTIC: All initialization steps completed');
    debugLog('DIAGNOSTIC: If app hangs after this point, check ESPN service initialization');
  }
}

// ---------------------------------------------------------------------------
// Private initialization helpers
// ---------------------------------------------------------------------------

/// Initialize Firebase App Check in the background to avoid blocking startup
void _initializeAppCheckBackground() async {
  try {
    debugLog('APP CHECK: Starting background initialization');

    // Use a timeout to prevent hanging
    await Future.any([
      FirebaseAppCheckService.initialize(),
      Future.delayed(const Duration(seconds: 10)), // 10 second timeout
    ]);

    debugLog('APP CHECK: Background initialization completed');
  } catch (e) {
    debugLog('APP CHECK: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: App Check failed but app will continue');
    }
  }
}

/// Initialize AI Services (OpenAI & Claude) in the background
void _initializeAIServicesBackground() async {
  try {
    debugLog('AI SERVICES: Starting background initialization');

    // Yield to the event loop so the UI renders first before starting network-heavy AI init.
    // AI services make HTTP calls to validate API keys, which should not compete with
    // initial UI rendering and Firebase listeners.
    await Future.microtask(() {});

    // Get the MultiProviderAIService from dependency injection and initialize it
    final multiProviderAI = di.sl<MultiProviderAIService>();
    await multiProviderAI.initialize();

    debugLog('AI SERVICES: Background initialization completed');
  } catch (e) {
    debugLog('AI SERVICES: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: AI Services failed but app will continue');
    }
  }
}

/// Initialize AdMob in the background
void _initializeAdMobBackground() async {
  if (kIsWeb) {
    debugLog('ADMOB: Skipping - not supported on web');
    return;
  }
  try {
    debugLog('ADMOB: Starting background initialization');

    // Yield to the event loop so the UI can render before AdMob SDK init,
    // which triggers platform channel calls and native SDK loading.
    await Future.microtask(() {});

    // Initialize AdMob SDK
    await AdService().initialize();

    // Pre-load an interstitial ad
    await AdService().loadInterstitialAd();

    debugLog('ADMOB: Background initialization completed');
  } catch (e) {
    debugLog('ADMOB: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: AdMob failed but app will continue');
    }
  }
}

/// Initialize RevenueCat in the background for native in-app purchases
void _initializeRevenueCatBackground() async {
  try {
    debugLog('REVENUECAT: Starting background initialization');

    // Yield to the event loop so the UI renders first.
    // RevenueCat SDK init involves platform channel setup and should not
    // compete with the first frame.
    await Future.microtask(() {});

    // Initialize RevenueCat SDK
    await RevenueCatService().initialize();

    // If user is already authenticated, login to RevenueCat
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await RevenueCatService().loginUser(currentUser.uid);
    }

    debugLog('REVENUECAT: Background initialization completed');
  } catch (e) {
    debugLog('REVENUECAT: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: RevenueCat failed but app will continue');
    }
  }
}

/// Initialize Stripe SDK in the background for Payment Sheet flows
void _initializeStripeBackground() async {
  try {
    debugLog('STRIPE: Starting background initialization');

    // Yield to the event loop so the UI renders first.
    // Stripe SDK init involves platform channel setup and should not
    // compete with the first frame.
    await Future.microtask(() {});

    // Only initialize if the publishable key is configured
    if (ApiKeys.stripePublishableKey.isNotEmpty) {
      Stripe.publishableKey = ApiKeys.stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.com.christophercampbell.pregameworldcup';
      await Stripe.instance.applySettings();
      debugLog('STRIPE: Background initialization completed');
    } else {
      debugLog('STRIPE: Publishable key not set - skipping initialization');
    }
  } catch (e) {
    debugLog('STRIPE: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Stripe failed but app will continue');
    }
  }
}

/// Initialize Analytics and Crashlytics in the background
void _initializeAnalyticsBackground() async {
  try {
    debugLog('ANALYTICS: Starting background initialization');

    // Yield to the event loop so the UI renders first.
    // Analytics/Crashlytics init is lightweight but should not block the first frame.
    await Future.microtask(() {});

    // Initialize Analytics and Crashlytics
    await AnalyticsService().initialize();

    debugLog('ANALYTICS: Background initialization completed');
  } catch (e) {
    debugLog('ANALYTICS: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Analytics failed but app will continue');
    }
  }
}

/// Initialize Deep Link Service in the background
void _initializeDeepLinkServiceBackground() async {
  try {
    debugLog('DEEP LINKS: Starting background initialization');

    // Yield to the event loop so the UI renders and the navigator context is available.
    // Deep links need the navigator to be mounted before they can trigger navigation,
    // so we allow the first frame to complete.
    await Future.microtask(() {});

    // Initialize Deep Link Service
    final deepLinkService = DeepLinkService();
    await deepLinkService.initialize();

    // Register the deep link handler
    deepLinkService.addHandler((data) {
      debugLog('DEEP LINKS: Received deep link: $data');
      DeepLinkNavigator().handleDeepLink(data);
    });

    debugLog('DEEP LINKS: Background initialization completed');
  } catch (e) {
    debugLog('DEEP LINKS: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Deep links failed but app will continue');
    }
  }
}

/// Initialize Accessibility Service
Future<void> _initializeAccessibilityService() async {
  try {
    debugLog('ACCESSIBILITY: Starting initialization');
    final accessibilityService = AccessibilityService();
    await accessibilityService.initialize();
    debugLog('ACCESSIBILITY: Initialization completed');
  } catch (e) {
    debugLog('ACCESSIBILITY: Initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('DIAGNOSTIC: Accessibility failed but app will continue');
    }
  }
}

/// PRODUCTION FIX: Clear all old 2024 cache data to ensure app always starts with fresh data.
/// Uses a SharedPreferences flag so this only runs once, not on every startup.
Future<void> _clearOld2024CacheData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const flagKey = 'cache_2024_cleared';

    // Skip if we already cleared 2024 cache on a previous launch
    if (prefs.getBool(flagKey) == true) {
      debugLog('STARTUP: 2024 cache already cleared on a previous launch - skipping');
      return;
    }

    debugLog('STARTUP: Clearing ALL old 2024 cache data (first time)...');
    final cacheService = CacheService.instance;

    // Clear all possible 2024 cache keys
    final keysToRemove = [
      'full_season_schedule_2024',
      'upcoming_games_2024_100_24_v2',
      'upcoming_games_2024_100_24_v3',
      'upcoming_games_100_24_v2',
      'upcoming_games_100_24_v3',
    ];

    // Clear cache keys for all possible days
    for (int day = 1; day <= 31; day++) {
      keysToRemove.addAll([
        'upcoming_games_100_${day}_v2',
        'upcoming_games_2024_100_${day}_v2',
        'upcoming_games_2024_100_${day}_v3',
        'upcoming_games_${day}_v2',
        'upcoming_games_2024_${day}_v2',
        'upcoming_games_2024_${day}_v3',
      ]);
    }

    // Remove all old cache keys
    for (final key in keysToRemove) {
      await cacheService.remove(key);
    }

    // Set the flag so we don't repeat this on future startups
    await prefs.setBool(flagKey, true);

    debugLog('STARTUP: Cleared ${keysToRemove.length} potential 2024 cache keys');
    debugLog('STARTUP: App will now ONLY show current season data');
  } catch (e) {
    debugLog('STARTUP: Error clearing 2024 cache data: $e');
    // Continue anyway - this is not critical
  }
}

/// PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached data
Future<void> _disableFirestoreOfflinePersistence() async {
  try {
    debugLog('FIRESTORE: Skipping offline persistence disable - needed for World Cup data');

    // DISABLED: This was preventing players/managers from loading from Firestore
    // The disableNetwork() call was making Firestore unavailable

    debugLog('FIRESTORE: Network enabled - World Cup data can now be fetched');
  } catch (e) {
    debugLog('FIRESTORE: Error disabling offline persistence: $e');
    // Continue anyway - this is not critical for app functionality
    // The app doesn't actually store schedule data in Firestore anyway
  }
}
