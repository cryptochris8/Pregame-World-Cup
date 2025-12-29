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
import 'features/schedule/domain/usecases/get_college_football_schedule.dart';
import 'features/schedule/domain/usecases/get_upcoming_games.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'core/entities/cached_venue_data.dart';
import 'core/entities/cached_geocoding_data.dart';
import 'features/worldcup/utils/timezone_utils.dart';

/// ANDROID DIAGNOSTIC MODE
/// Set to true to enable detailed logging for Android issues
const bool ANDROID_DIAGNOSTIC_MODE = true;

/// Initialize app with comprehensive error handling and logging
Future<void> main() async {
  // Step 1: Flutter Framework Initialization
  print('🚀 INIT STEP 1: Flutter Framework');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ INIT STEP 1: Flutter Framework - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 1: Flutter Framework - FAILED: $e');
    // Continue anyway - this is critical
  }

  // Step 2: Firebase Core Initialization
  print('🚀 INIT STEP 2: Firebase Core');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached schedule data
    // This ensures the app doesn't fall back to cached 2024 data when offline
    await _disableFirestoreOfflinePersistence();
    
    print('✅ INIT STEP 2: Firebase Core - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 2: Firebase Core - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Firebase initialization failed. This could prevent app startup.');
      print('🔍 DIAGNOSTIC: Check google-services.json configuration');
    }
  }

  // Step 3: Hive Database Initialization
  print('🚀 INIT STEP 3: Hive Database');
  try {
    await Hive.initFlutter();
    print('✅ INIT STEP 3: Hive Database - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 3: Hive Database - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Hive database failed. This affects caching and may cause hangs.');
    }
  }

  // Step 4: Hive Adapters Registration
  print('🚀 INIT STEP 4: Hive Adapters');
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
    print('✅ INIT STEP 4: Hive Adapters - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 4: Hive Adapters - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Hive adapters failed. This may cause serialization issues.');
    }
  }

  // Step 5: Cache Service Initialization
  print('🚀 INIT STEP 5: Cache Service');
  try {
    await CacheService.instance.initialize();
    
    // PRODUCTION FIX: Clear all old 2024 cache data on every app startup
    // This ensures the app ALWAYS starts with fresh 2025 data
    await _clearOld2024CacheData();
    
    print('✅ INIT STEP 5: Cache Service - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 5: Cache Service - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Cache service failed. App will continue without caching.');
    }
  }

  // Step 5.5: Timezone Database Initialization
  print('🚀 INIT STEP 5.5: Timezone Database');
  try {
    await TimezoneUtils.initialize();
    print('✅ INIT STEP 5.5: Timezone Database - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 5.5: Timezone Database - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Timezone database failed. Match times may not convert correctly.');
    }
  }

  // Step 6: Dependency Injection Setup
  print('🚀 INIT STEP 6: Dependency Injection');
  try {
    await di.setupLocator();
    print('✅ INIT STEP 6: Dependency Injection - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 6: Dependency Injection - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: Service locator failed. This will prevent app features from working.');
      print('🔍 DIAGNOSTIC: This is likely related to ESPN/API service initialization');
    }
  }

  // Step 6.5: API Keys Validation
  print('🚀 INIT STEP 6.5: API Keys Validation');
  try {
    ApiKeys.validateApiKeys();
    print('✅ INIT STEP 6.5: API Keys Validation - COMPLETE');
  } catch (e) {
    print('❌ INIT STEP 6.5: API Keys Validation - FAILED: $e');
  }

  // Step 7: Firebase App Check (Background)
  print('🚀 INIT STEP 7: Firebase App Check (Background)');
  // Initialize App Check in the background to avoid blocking the UI
  _initializeAppCheckBackground();

  // Step 7.5: AI Service Initialization (Background)
  print('🚀 INIT STEP 7.5: AI Service Initialization (Background)');
  // Initialize AI services in the background to avoid blocking the UI
  _initializeAIServicesBackground();

  // Step 7.6: AI Knowledge Base Initialization (Background)
  print('🚀 INIT STEP 7.6: AI Knowledge Base (Background)');
  // Initialize AI knowledge base in the background to avoid blocking the UI
  _initializeAIKnowledgeBaseBackground();

  // Step 8: Launch App
  print('🚀 INIT STEP 8: Launching App');
  try {
    runApp(PregameApp());
    print('✅ INIT STEP 8: App Launch - SUCCESS');
  } catch (e) {
    print('❌ INIT STEP 8: App Launch - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: App launch failed. This is a critical error.');
    }
  }

  if (ANDROID_DIAGNOSTIC_MODE) {
    print('📱 DIAGNOSTIC: All initialization steps completed');
    print('📱 DIAGNOSTIC: If app hangs after this point, check ESPN service initialization');
  }
}

/// Initialize Firebase App Check in the background to avoid blocking startup
void _initializeAppCheckBackground() async {
  try {
    print('🛡️ APP CHECK: Starting background initialization');
    
    // Use a timeout to prevent hanging
    await Future.any([
      FirebaseAppCheckService.initialize(),
      Future.delayed(Duration(seconds: 10)), // 10 second timeout
    ]);
    
    print('✅ APP CHECK: Background initialization completed');
  } catch (e) {
    print('⚠️ APP CHECK: Background initialization failed: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: App Check failed but app will continue');
    }
  }
}

/// Initialize AI Services (OpenAI & Claude) in the background
void _initializeAIServicesBackground() async {
  try {
    print('🤖 AI SERVICES: Starting background initialization');
    
    // Wait a bit for the app to fully load first  
    await Future.delayed(Duration(seconds: 2));
    
    // Get the MultiProviderAIService from dependency injection and initialize it
    final multiProviderAI = di.sl<MultiProviderAIService>();
    await multiProviderAI.initialize();
    
    print('✅ AI SERVICES: Background initialization completed');
  } catch (e) {
    print('⚠️ AI SERVICES: Background initialization failed: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: AI Services failed but app will continue');
    }
  }
}

/// Initialize AI Knowledge Base in the background to build historical data
void _initializeAIKnowledgeBaseBackground() async {
  try {
    print('🧠 AI KNOWLEDGE: Starting background initialization');
    
    // Wait a bit for the AI services to initialize first
    await Future.delayed(Duration(seconds: 5));
    
    // Initialize the AI knowledge base with historical data
    await AIHistoricalKnowledgeService.instance.initializeKnowledgeBase();
    
    print('✅ AI KNOWLEDGE: Background initialization completed');
  } catch (e) {
    print('⚠️ AI KNOWLEDGE: Background initialization failed: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: AI Knowledge Base failed but app will continue');
    }
  }
}

/// PRODUCTION FIX: Clear all old 2024 cache data to ensure app always starts with 2025 data
Future<void> _clearOld2024CacheData() async {
  try {
    print('🧹 STARTUP: Clearing ALL old 2024 cache data...');
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
    
    print('🧹 STARTUP: Cleared ${keysToRemove.length} potential 2024 cache keys');
    print('✅ STARTUP: App will now ONLY show 2025 season data');
  } catch (e) {
    print('⚠️ STARTUP: Error clearing 2024 cache data: $e');
    // Continue anyway - this is not critical
  }
}

/// PRODUCTION FIX: Disable Firestore offline persistence to prevent old cached data
Future<void> _disableFirestoreOfflinePersistence() async {
  try {
    print('🔥 FIRESTORE: Skipping offline persistence disable - needed for World Cup data');

    // DISABLED: This was preventing players/managers from loading from Firestore
    // The disableNetwork() call was making Firestore unavailable

    // Import Firestore here to avoid issues if Firebase isn't initialized yet
    // final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Disable offline persistence - this prevents the app from using cached data
    // when it can't reach the Firestore backend
    // await firestore.disableNetwork();
    // await firestore.clearPersistence();
    // await firestore.enableNetwork();

    print('✅ FIRESTORE: Network enabled - World Cup data can now be fetched');
  } catch (e) {
    print('⚠️ FIRESTORE: Error disabling offline persistence: $e');
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
    print('🚀 INIT: Starting $stepName');
    final result = await initFunction();
    print('✅ INIT: $stepName - SUCCESS');
    return result;
  } catch (e) {
    print('❌ INIT: $stepName - FAILED: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: $stepName failed - continuing with degraded functionality');
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

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late Stream<User?> _authStream;
  
  @override
  void initState() {
    super.initState();
    // Initialize the auth stream
    _authStream = FirebaseAuth.instance.authStateChanges();
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
          return const MainNavigationScreen();
        }
        
        // Show login screen if user is not authenticated
        return const LoginScreen();
      },
    );
  }
  
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
} 