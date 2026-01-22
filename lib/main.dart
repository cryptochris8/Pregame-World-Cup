import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';

import 'services/payment_service.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';

import 'features/social/domain/entities/user_profile.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/services/cache_service.dart';
import './core/ai/services/ai_service.dart';
import './core/ai/services/ai_historical_knowledge_service.dart';
import './core/ai/services/multi_provider_ai_service.dart';
import 'core/entities/game_intelligence.dart';
import 'config/app_theme.dart';
import 'core/services/firebase_app_check_service.dart';
import 'config/api_keys.dart';
import 'core/services/logging_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/ad_service.dart';
import 'services/revenuecat_service.dart';
import 'core/services/presence_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/messaging/domain/services/messaging_service.dart';
import 'features/messaging/presentation/screens/chat_screen.dart';
import 'features/schedule/domain/usecases/get_college_football_schedule.dart';
import 'features/schedule/domain/usecases/get_upcoming_games.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'core/entities/cached_venue_data.dart';
import 'core/entities/cached_geocoding_data.dart';
import 'features/worldcup/utils/timezone_utils.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (usually already done)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Note: debugLog not available here as it's a top-level isolate
  if (kDebugMode) {
    print('📬 Background message received: ${message.messageId}');
  }
}

/// DIAGNOSTIC MODE
/// Automatically disabled in release builds for App Store compliance
/// Set to true during development for detailed logging
const bool _diagnosticModeOverride = true;
bool get DIAGNOSTIC_MODE => kDebugMode && _diagnosticModeOverride;

/// Production-safe logging function - only logs in debug mode
void debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

/// Initialize app with comprehensive error handling and logging
Future<void> main() async {
  // Step 1: Flutter Framework Initialization
  debugLog('🚀 INIT STEP 1: Flutter Framework');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugLog('✅ INIT STEP 1: Flutter Framework - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 1: Flutter Framework - FAILED: $e');
    // Continue anyway - this is critical
  }

  // Step 2: Firebase Core Initialization
  debugLog('🚀 INIT STEP 2: Firebase Core');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Register background message handler for FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached schedule data
    // This ensures the app doesn't fall back to cached 2024 data when offline
    await _disableFirestoreOfflinePersistence();

    debugLog('✅ INIT STEP 2: Firebase Core - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 2: Firebase Core - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Firebase initialization failed. This could prevent app startup.');
      debugLog('🔍 DIAGNOSTIC: Check google-services.json configuration');
    }
  }

  // Step 3: Hive Database Initialization
  debugLog('🚀 INIT STEP 3: Hive Database');
  try {
    await Hive.initFlutter();
    debugLog('✅ INIT STEP 3: Hive Database - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 3: Hive Database - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Hive database failed. This affects caching and may cause hangs.');
    }
  }

  // Step 4: Hive Adapters Registration
  debugLog('🚀 INIT STEP 4: Hive Adapters');
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
    debugLog('✅ INIT STEP 4: Hive Adapters - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 4: Hive Adapters - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Hive adapters failed. This may cause serialization issues.');
    }
  }

  // Step 5: Cache Service Initialization
  debugLog('🚀 INIT STEP 5: Cache Service');
  try {
    await CacheService.instance.initialize();

    // PRODUCTION FIX: Clear all old 2024 cache data on every app startup
    // This ensures the app ALWAYS starts with fresh 2025 data
    await _clearOld2024CacheData();

    debugLog('✅ INIT STEP 5: Cache Service - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 5: Cache Service - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Cache service failed. App will continue without caching.');
    }
  }

  // Step 5.5: Timezone Database Initialization
  debugLog('🚀 INIT STEP 5.5: Timezone Database');
  try {
    await TimezoneUtils.initialize();
    debugLog('✅ INIT STEP 5.5: Timezone Database - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 5.5: Timezone Database - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Timezone database failed. Match times may not convert correctly.');
    }
  }

  // Step 6: Dependency Injection Setup
  debugLog('🚀 INIT STEP 6: Dependency Injection');
  try {
    await di.setupLocator();
    debugLog('✅ INIT STEP 6: Dependency Injection - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 6: Dependency Injection - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: Service locator failed. This will prevent app features from working.');
      debugLog('🔍 DIAGNOSTIC: This is likely related to ESPN/API service initialization');
    }
  }

  // Step 6.5: API Keys Validation
  debugLog('🚀 INIT STEP 6.5: API Keys Validation');
  try {
    ApiKeys.validateApiKeys();
    debugLog('✅ INIT STEP 6.5: API Keys Validation - COMPLETE');
  } catch (e) {
    debugLog('❌ INIT STEP 6.5: API Keys Validation - FAILED: $e');
  }

  // Step 7: Firebase App Check (Background)
  debugLog('🚀 INIT STEP 7: Firebase App Check (Background)');
  // Initialize App Check in the background to avoid blocking the UI
  _initializeAppCheckBackground();

  // Step 7.5: AI Service Initialization (Background)
  debugLog('🚀 INIT STEP 7.5: AI Service Initialization (Background)');
  // Initialize AI services in the background to avoid blocking the UI
  _initializeAIServicesBackground();

  // Step 7.6: AI Knowledge Base Initialization (Background)
  // DISABLED: College football AI knowledge base not needed for World Cup app
  // debugLog('🚀 INIT STEP 7.6: AI Knowledge Base (Background)');
  // _initializeAIKnowledgeBaseBackground();

  // Step 7.7: AdMob Initialization (Background)
  debugLog('🚀 INIT STEP 7.7: AdMob Initialization (Background)');
  _initializeAdMobBackground();

  // Step 7.8: RevenueCat Initialization (Background)
  debugLog('🚀 INIT STEP 7.8: RevenueCat Initialization (Background)');
  _initializeRevenueCatBackground();

  // Step 8: Launch App
  debugLog('🚀 INIT STEP 8: Launching App');
  try {
    runApp(PregameApp());
    debugLog('✅ INIT STEP 8: App Launch - SUCCESS');
  } catch (e) {
    debugLog('❌ INIT STEP 8: App Launch - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: App launch failed. This is a critical error.');
    }
  }

  if (DIAGNOSTIC_MODE) {
    debugLog('📱 DIAGNOSTIC: All initialization steps completed');
    debugLog('📱 DIAGNOSTIC: If app hangs after this point, check ESPN service initialization');
  }
}

/// Initialize Firebase App Check in the background to avoid blocking startup
void _initializeAppCheckBackground() async {
  try {
    debugLog('🛡️ APP CHECK: Starting background initialization');

    // Use a timeout to prevent hanging
    await Future.any([
      FirebaseAppCheckService.initialize(),
      Future.delayed(Duration(seconds: 10)), // 10 second timeout
    ]);

    debugLog('✅ APP CHECK: Background initialization completed');
  } catch (e) {
    debugLog('⚠️ APP CHECK: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: App Check failed but app will continue');
    }
  }
}

/// Initialize AI Services (OpenAI & Claude) in the background
void _initializeAIServicesBackground() async {
  try {
    debugLog('🤖 AI SERVICES: Starting background initialization');

    // Wait a bit for the app to fully load first
    await Future.delayed(Duration(seconds: 2));

    // Get the MultiProviderAIService from dependency injection and initialize it
    final multiProviderAI = di.sl<MultiProviderAIService>();
    await multiProviderAI.initialize();

    debugLog('✅ AI SERVICES: Background initialization completed');
  } catch (e) {
    debugLog('⚠️ AI SERVICES: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: AI Services failed but app will continue');
    }
  }
}

/// Initialize AI Knowledge Base in the background to build historical data
void _initializeAIKnowledgeBaseBackground() async {
  try {
    debugLog('🧠 AI KNOWLEDGE: Starting background initialization');

    // Wait a bit for the AI services to initialize first
    await Future.delayed(Duration(seconds: 5));

    // Initialize the AI knowledge base with historical data
    await AIHistoricalKnowledgeService.instance.initializeKnowledgeBase();

    debugLog('✅ AI KNOWLEDGE: Background initialization completed');
  } catch (e) {
    debugLog('⚠️ AI KNOWLEDGE: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: AI Knowledge Base failed but app will continue');
    }
  }
}

/// Initialize AdMob in the background
void _initializeAdMobBackground() async {
  try {
    debugLog('📢 ADMOB: Starting background initialization');

    // Wait a bit for the app to fully load first
    await Future.delayed(Duration(seconds: 1));

    // Initialize AdMob SDK
    await AdService().initialize();

    // Pre-load an interstitial ad
    await AdService().loadInterstitialAd();

    debugLog('✅ ADMOB: Background initialization completed');
  } catch (e) {
    debugLog('⚠️ ADMOB: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: AdMob failed but app will continue');
    }
  }
}

/// Initialize RevenueCat in the background for native in-app purchases
void _initializeRevenueCatBackground() async {
  try {
    debugLog('💰 REVENUECAT: Starting background initialization');

    // Wait a bit for the app to fully load first
    await Future.delayed(Duration(seconds: 2));

    // Initialize RevenueCat SDK
    await RevenueCatService().initialize();

    // If user is already authenticated, login to RevenueCat
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await RevenueCatService().loginUser(currentUser.uid);
    }

    debugLog('✅ REVENUECAT: Background initialization completed');
  } catch (e) {
    debugLog('⚠️ REVENUECAT: Background initialization failed: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: RevenueCat failed but app will continue');
    }
  }
}

/// PRODUCTION FIX: Clear all old 2024 cache data to ensure app always starts with 2025 data
Future<void> _clearOld2024CacheData() async {
  try {
    debugLog('🧹 STARTUP: Clearing ALL old 2024 cache data...');
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
    
    debugLog('🧹 STARTUP: Cleared ${keysToRemove.length} potential 2024 cache keys');
    debugLog('✅ STARTUP: App will now ONLY show 2025 season data');
  } catch (e) {
    debugLog('⚠️ STARTUP: Error clearing 2024 cache data: $e');
    // Continue anyway - this is not critical
  }
}

/// PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached data
Future<void> _disableFirestoreOfflinePersistence() async {
  try {
    debugLog('🔥 FIRESTORE: Skipping offline persistence disable - needed for World Cup data');

    // DISABLED: This was preventing players/managers from loading from Firestore
    // The disableNetwork() call was making Firestore unavailable

    // Import Firestore here to avoid issues if Firebase isn't initialized yet
    // final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Disable offline persistence - this prevents the app from using cached data
    // when it can't reach the Firestore backend
    // await firestore.disableNetwork();
    // await firestore.clearPersistence();
    // await firestore.enableNetwork();

    debugLog('✅ FIRESTORE: Network enabled - World Cup data can now be fetched');
  } catch (e) {
    debugLog('⚠️ FIRESTORE: Error disabling offline persistence: $e');
    // Continue anyway - this is not critical for app functionality
    // The app doesn't actually store schedule data in Firestore anyway
  }
}

/// Error handling wrapper for initialization steps
Future<T?> _safeInitialize<T>(
  String stepName,
  Future<T> Function() initFunction,
) async {
  try {
    debugLog('🚀 INIT: Starting $stepName');
    final result = await initFunction();
    debugLog('✅ INIT: $stepName - SUCCESS');
    return result;
  } catch (e) {
    debugLog('❌ INIT: $stepName - FAILED: $e');
    if (DIAGNOSTIC_MODE) {
      debugLog('🔍 DIAGNOSTIC: $stepName failed - continuing with degraded functionality');
    }
    return null;
  }
}

class PregameApp extends StatelessWidget {
  const PregameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleBloc(
        getCollegeFootballSchedule: di.sl<GetCollegeFootballSchedule>(),
        getUpcomingGames: di.sl<GetUpcomingGames>(),
        scheduleRepository: di.sl<ScheduleRepository>(),
      ),
      child: MaterialApp(
        title: 'Pregame',
        // Localization support
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Use the beautiful gradient dark theme by default
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        // Always use dark theme to show off the gradient design
        themeMode: ThemeMode.dark,
        home: const AuthenticationWrapper(),
        debugShowCheckedModeBanner: false,
        // Premium app styling
        builder: (context, child) {
          return MediaQuery(
            // Ensure consistent text scaling
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}

/// Authentication wrapper that shows login screen or main app based on auth state
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> with WidgetsBindingObserver {
  late Stream<User?> _authStream;
  bool _pushNotificationsInitialized = false;
  bool _presenceInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize the auth stream
    _authStream = FirebaseAuth.instance.authStateChanges();
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleAppLifecycleChange(state);
  }

  /// Handle app lifecycle changes for presence tracking
  void _handleAppLifecycleChange(AppLifecycleState state) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || !_presenceInitialized) return;

    final presenceService = di.sl<PresenceService>();

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - mark user as online
        debugLog('📱 LIFECYCLE: App resumed - setting user online');
        presenceService.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - mark user as offline
        debugLog('📱 LIFECYCLE: App paused/inactive - setting user offline');
        presenceService.setOffline();
        break;
    }
  }

  /// Initialize push notifications, RevenueCat, and presence service for the authenticated user
  void _initializeAuthenticatedUserServices() {
    // Only initialize once per session
    if (_pushNotificationsInitialized) return;
    _pushNotificationsInitialized = true;

    // Initialize in background to avoid blocking UI
    Future.microtask(() async {
      // Initialize Push Notifications
      try {
        debugLog('📱 PUSH: Initializing push notifications for authenticated user');
        final pushService = di.sl<PushNotificationService>();
        await pushService.initialize();
        debugLog('✅ PUSH: Push notifications initialized successfully');
      } catch (e) {
        debugLog('⚠️ PUSH: Failed to initialize push notifications: $e');
        // Non-critical - app continues to work without push notifications
      }

      // Login to RevenueCat for the authenticated user
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          debugLog('💰 REVENUECAT: Logging in user for purchases');
          await RevenueCatService().loginUser(user.uid);
          debugLog('✅ REVENUECAT: User logged in successfully');
        }
      } catch (e) {
        debugLog('⚠️ REVENUECAT: Failed to login user: $e');
        // Non-critical - app continues to work without RevenueCat
      }

      // Initialize Presence Service for online status tracking
      try {
        debugLog('👤 PRESENCE: Initializing presence service for online status');
        final presenceService = di.sl<PresenceService>();
        await presenceService.initialize();
        _presenceInitialized = true;
        debugLog('✅ PRESENCE: Presence service initialized - user is now online');
      } catch (e) {
        debugLog('⚠️ PRESENCE: Failed to initialize presence service: $e');
        // Non-critical - app continues to work without presence tracking
      }

      // Set up notification tap handler for navigation
      _setupNotificationNavigation();
    });
  }

  /// Set up notification tap handler for navigating to appropriate screens
  void _setupNotificationNavigation() {
    PushNotificationService.onNotificationTap = (String type, Map<String, dynamic> data) {
      debugLog('🔔 NOTIFICATION TAP: type=$type, data=$data');

      // Ensure we have a valid context
      if (!mounted) return;

      switch (type) {
        case 'new_message':
          _navigateToChat(data);
          break;
        case 'friend_request':
          _navigateToFriendRequests();
          break;
        case 'watch_party_invite':
          _navigateToWatchParty(data['watchPartyId'] as String?);
          break;
        default:
          debugLog('🔔 NOTIFICATION: Unhandled notification type: $type');
      }
    };
  }

  /// Navigate to chat screen when message notification is tapped
  Future<void> _navigateToChat(Map<String, dynamic> data) async {
    final chatId = data['chatId'] as String?;
    if (chatId == null) {
      debugLog('⚠️ NOTIFICATION: No chatId in notification data');
      return;
    }

    try {
      debugLog('🔔 NOTIFICATION: Navigating to chat $chatId');

      // Get the chat from MessagingService
      final messagingService = MessagingService();
      final chat = await messagingService.getChatById(chatId);

      if (chat != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      } else {
        debugLog('⚠️ NOTIFICATION: Chat not found: $chatId');
      }
    } catch (e) {
      debugLog('⚠️ NOTIFICATION: Error navigating to chat: $e');
    }
  }

  /// Navigate to friend requests screen
  void _navigateToFriendRequests() {
    debugLog('🔔 NOTIFICATION: Navigating to friend requests');
    // The navigation will be handled by the main navigation system
    // For now, just log it
  }

  /// Navigate to watch party screen
  void _navigateToWatchParty(String? watchPartyId) {
    if (watchPartyId == null) return;
    debugLog('🔔 NOTIFICATION: Navigating to watch party $watchPartyId');
    // The navigation will be handled by the main navigation system
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Only proceed if widget is still mounted
        if (!mounted) {
          return const SizedBox.shrink();
        }
        
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1a1a1a),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/logos/pregame_logo.png'),
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.orange),
                ],
              ),
            ),
          );
        }
        
        // Show main app if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          // Initialize authenticated user services (push, RevenueCat, presence)
          _initializeAuthenticatedUserServices();
          return const MainNavigationScreen();
        }
        
        // Show login screen if user is not authenticated
        return const LoginScreen();
      },
    );
  }
  
  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Dispose presence service
    if (_presenceInitialized) {
      try {
        final presenceService = di.sl<PresenceService>();
        presenceService.dispose();
      } catch (e) {
        debugLog('⚠️ PRESENCE: Error disposing presence service: $e');
      }
    }

    super.dispose();
  }
} 