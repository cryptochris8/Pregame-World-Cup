import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Centralized Firebase imports
import 'core/firebase/firebase_exports.dart';

import 'features/schedule/data/datasources/espn_schedule_datasource.dart';
import 'features/schedule/data/datasources/live_scores_datasource.dart';
import 'features/schedule/data/repositories/schedule_repository_impl.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/domain/usecases/get_upcoming_games.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';

// Import for Recommendations feature
import 'features/recommendations/data/datasources/places_api_datasource.dart';
import 'features/recommendations/data/repositories/places_repository_impl.dart';
import 'features/recommendations/domain/repositories/places_repository.dart';
import 'features/recommendations/domain/usecases/get_nearby_places.dart';
import 'features/recommendations/domain/usecases/get_filtered_venues.dart';
import 'features/recommendations/domain/usecases/get_geocoded_location.dart';

// Import for Auth feature
import 'features/auth/domain/services/auth_service.dart';

// Push Notifications
import 'core/services/push_notification_service.dart';

// Social features
import 'features/social/data/datasources/social_datasource.dart';
import 'features/social/domain/services/social_service.dart';

// AI Integration
import './core/ai/services/ai_service.dart';
import './core/ai/services/claude_service.dart';
import './core/ai/services/multi_provider_ai_service.dart';
import './core/ai/services/claude_sports_integration_service.dart';
import './core/ai/services/user_preference_learning_service.dart';
import './core/ai/services/ai_historical_knowledge_service.dart';
import './core/ai/services/ai_game_analysis_service.dart';
import './core/services/user_learning_service.dart';

// Enhanced AI Services
import './core/ai/services/enhanced_ai_prediction_service.dart';
import './core/ai/services/enhanced_game_summary_service.dart';
import './core/ai/services/enhanced_player_service.dart';
import './core/ai/services/ai_team_season_summary_service.dart';
import './core/ai/services/enhanced_ai_game_analysis_service.dart';
import './core/services/historical_game_analysis_service.dart';

// Unified Services (replacing multiple overlapping services)
import './core/services/unified_game_analysis_service.dart';
import './core/services/unified_venue_service.dart';

// Enhanced Game Analysis
import './services/espn_service.dart';
import './services/comprehensive_series_service.dart';
import './services/enhanced_sports_data_service.dart';

// Zapier Integration
import './services/zapier_service.dart';
import './services/game_day_automation_service.dart';

// API Keys configuration
import 'config/api_keys.dart';

// Core Services
import 'core/services/cache_service.dart';
import 'core/services/presence_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/deep_link_navigator.dart';
import 'core/services/accessibility_service.dart';
import 'core/services/notification_preferences_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/widget_service.dart';

// World Cup 2026 Feature
import 'features/worldcup/worldcup.dart';
import 'features/worldcup/data/services/world_cup_ai_service.dart';
import 'features/worldcup/data/services/nearby_venues_service.dart';
import 'features/worldcup/data/services/match_reminder_service.dart';
import 'features/worldcup/presentation/bloc/nearby_venues_cubit.dart';
import 'features/worldcup/domain/services/world_cup_payment_service.dart';
import 'services/revenuecat_service.dart';

// Watch Party Feature
import 'features/watch_party/domain/services/watch_party_service.dart';
import 'features/watch_party/domain/services/watch_party_payment_service.dart';
import 'features/watch_party/presentation/bloc/watch_party_bloc.dart';

// Venue Portal Feature
import 'features/venue_portal/venue_portal.dart';

// Moderation Feature
import 'features/moderation/moderation.dart';

// Admin Feature
import 'features/admin/domain/services/admin_service.dart';

// Match Chat Feature
import 'features/match_chat/match_chat.dart';

// Calendar Feature
import 'features/calendar/calendar.dart';

// Sharing Feature
import 'features/sharing/sharing.dart';

// TODO: Token Feature - disabled pending legal review
// import 'features/token/token.dart';

// Global GetIt instance
final sl = GetIt.instance; // sl stands for Service Locator

/// Android diagnostic mode - set to false for production
const bool ANDROID_DIAGNOSTIC_MODE = false;

Future<void> setupLocator() async {
  if (ANDROID_DIAGNOSTIC_MODE) {
    print('🔧 DEPENDENCY INJECTION: Starting in Android diagnostic mode');
  }

  try {
    // STEP 1: Core Dependencies (Essential)
    print('🔧 DI STEP 1: Core Dependencies');
    sl.registerLazySingleton(() => Dio());
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
    sl.registerLazySingleton(() => FirebaseAuth.instance);

    // Register SharedPreferences (async initialization)
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    print('✅ DI STEP 1: Core Dependencies - SUCCESS');

    // STEP 2: Core Services (Essential)
    print('🔧 DI STEP 2: Core Services');
    sl.registerLazySingleton(() => CacheService.instance);
    sl.registerLazySingleton(() => AuthService());
    sl.registerLazySingleton(() => PresenceService());
    sl.registerLazySingleton(() => PushNotificationService());
    sl.registerLazySingleton(() => AnalyticsService());
    sl.registerLazySingleton(() => DeepLinkService());
    sl.registerLazySingleton(() => DeepLinkNavigator());
    sl.registerLazySingleton(() => AccessibilityService());
    sl.registerLazySingleton(() => NotificationPreferencesService());

    // Initialize LocalizationService (async, for language detection and switching)
    final localizationService = await LocalizationService.getInstance();
    sl.registerSingleton<LocalizationService>(localizationService);

    // Initialize OfflineService (async, for connectivity and action queuing)
    final offlineService = await OfflineService.getInstance();
    sl.registerSingleton<OfflineService>(offlineService);

    // Initialize WidgetService (async, for home screen widgets)
    final widgetService = await WidgetService.getInstance();
    sl.registerSingleton<WidgetService>(widgetService);
    print('✅ DI STEP 2: Core Services - SUCCESS');

    // STEP 3: Basic Analysis Services (Important but not critical)
    print('🔧 DI STEP 3: Basic Analysis Services');
    try {
      sl.registerLazySingleton(() => UnifiedGameAnalysisService());
      sl.registerLazySingleton(() => UnifiedVenueService());
      print('✅ DI STEP 3: Basic Analysis Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 3: Basic Analysis Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Basic analysis services failed but continuing');
      }
    }

    // STEP 4: AI Services (Can be problematic on Android)
    print('🔧 DI STEP 4: AI Services');
    try {
      sl.registerLazySingleton(() => AIService());
      sl.registerLazySingleton(() => ClaudeService());
      sl.registerLazySingleton(() => MultiProviderAIService.instance);
      sl.registerLazySingleton(() => ClaudeSportsIntegrationService.instance);
      sl.registerLazySingleton(() => UserPreferenceLearningService(sl()));
      sl.registerLazySingleton(() => UserLearningService());
      
      // Register new AI services for historical knowledge and game analysis
      sl.registerLazySingleton(() => AIHistoricalKnowledgeService.instance);
      sl.registerLazySingleton(() => AIGameAnalysisService.instance);
      
      // Register enhanced AI services for better predictions and summaries
      sl.registerLazySingleton(() => EnhancedAIPredictionService.instance);
      sl.registerLazySingleton(() => EnhancedGameSummaryService.instance);
      sl.registerLazySingleton(() => EnhancedPlayerService.instance);
      sl.registerLazySingleton(() => AITeamSeasonSummaryService.instance);
      
      // Register enhanced AI game analysis service with team mapping
      sl.registerLazySingleton(() => EnhancedAIGameAnalysisService.instance);
      
      // Register historical game analysis service
      sl.registerLazySingleton(() => HistoricalGameAnalysisService());
      
      print('✅ DI STEP 4: AI Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 4: AI Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: AI services failed - this may cause hangs on Android');
      }
    }

    // STEP 5: ESPN and API Services (High risk for Android)
    print('🔧 DI STEP 5: ESPN and API Services');
    try {
      // Register ESPN services with timeout protection
      await Future.any([
        _registerESPNServices(),
        Future.delayed(Duration(seconds: 5)), // 5 second timeout
      ]);
      print('✅ DI STEP 5: ESPN and API Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 5: ESPN and API Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: ESPN services failed - this is likely the Android issue');
        print('🔍 DIAGNOSTIC: Registering fallback services instead');
      }
      // Register fallback services
      _registerFallbackServices();
    }

    // STEP 6: Schedule Services (Essential for app)
    print('🔧 DI STEP 6: Schedule Services');
    try {
      _registerScheduleServices();
      print('✅ DI STEP 6: Schedule Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 6: Schedule Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Schedule services failed - app will have limited functionality');
      }
    }

    // STEP 7: Recommendation Services
    print('🔧 DI STEP 7: Recommendation Services');
    try {
      _registerRecommendationServices();
      print('✅ DI STEP 7: Recommendation Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 7: Recommendation Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Recommendation services failed but app will continue');
      }
    }

    // STEP 8: Social and External Services
    print('🔧 DI STEP 8: Social and External Services');
    try {
      _registerSocialServices();
      print('✅ DI STEP 8: Social and External Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 8: Social and External Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Social services failed but app will continue');
      }
    }

    // STEP 9: World Cup 2026 Services
    print('🔧 DI STEP 9: World Cup 2026 Services');
    try {
      _registerWorldCupServices();
      print('✅ DI STEP 9: World Cup 2026 Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 9: World Cup 2026 Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: World Cup services failed but app will continue');
      }
    }

    // STEP 10: Watch Party Services
    print('🔧 DI STEP 10: Watch Party Services');
    try {
      _registerWatchPartyServices();
      print('✅ DI STEP 10: Watch Party Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 10: Watch Party Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Watch Party services failed but app will continue');
      }
    }

    // STEP 11: Moderation Services
    print('🔧 DI STEP 11: Moderation Services');
    try {
      _registerModerationServices();
      print('✅ DI STEP 11: Moderation Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 11: Moderation Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Moderation services failed but app will continue');
      }
    }

    // STEP 12: Admin Services
    print('🔧 DI STEP 12: Admin Services');
    try {
      _registerAdminServices();
      print('✅ DI STEP 12: Admin Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 12: Admin Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Admin services failed but app will continue');
      }
    }

    // STEP 13: Match Chat Services
    print('🔧 DI STEP 13: Match Chat Services');
    try {
      _registerMatchChatServices();
      print('✅ DI STEP 13: Match Chat Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 13: Match Chat Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Match Chat services failed but app will continue');
      }
    }

    // STEP 14: Calendar Services
    print('🔧 DI STEP 14: Calendar Services');
    try {
      _registerCalendarServices();
      print('✅ DI STEP 14: Calendar Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 14: Calendar Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Calendar services failed but app will continue');
      }
    }

    // STEP 15: Sharing Services
    print('🔧 DI STEP 15: Sharing Services');
    try {
      _registerSharingServices();
      print('✅ DI STEP 15: Sharing Services - SUCCESS');
    } catch (e) {
      print('⚠️ DI STEP 15: Sharing Services - FAILED: $e');
      if (ANDROID_DIAGNOSTIC_MODE) {
        print('🔍 DIAGNOSTIC: Sharing services failed but app will continue');
      }
    }

    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔧 DEPENDENCY INJECTION: All steps completed');
      print('🔧 REGISTERED SERVICES: Dependency injection setup complete');
    }

  } catch (e) {
    print('❌ DEPENDENCY INJECTION: Critical failure: $e');
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: This is a critical error that will prevent app startup');
    }
    rethrow;
  }
}

/// Register ESPN services with extra error handling
Future<void> _registerESPNServices() async {
  try {
    sl.registerLazySingleton(() => ESPNService());
    sl.registerLazySingleton(() => ComprehensiveSeriesService());
    sl.registerLazySingleton(() => EnhancedSportsDataService());
    
    // Register ESPN schedule datasource
    sl.registerLazySingleton(() => ESPNScheduleDataSource(
      espnService: sl(),
      cacheService: sl(),
    ));
  } catch (e) {
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔍 DIAGNOSTIC: ESPN service registration failed: $e');
    }
    rethrow;
  }
}

/// Register fallback services when ESPN fails
void _registerFallbackServices() {
  try {
    // Register mock ESPN service that doesn't make network calls
    sl.registerLazySingleton(() => ESPNService());
    
    // Register simple ESPN datasource
    sl.registerLazySingleton(() => ESPNScheduleDataSource(
      espnService: sl(),
      cacheService: sl(),
    ));
    
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('🔧 FALLBACK: Registered fallback ESPN services');
    }
  } catch (e) {
    if (ANDROID_DIAGNOSTIC_MODE) {
      print('⚠️ FALLBACK: Even fallback services failed: $e');
    }
  }
}

/// Register schedule-related services
void _registerScheduleServices() {
  // Register schedule BLoC
  sl.registerFactory(() => ScheduleBloc(
    getUpcomingGames: sl(),
    scheduleRepository: sl(),
  ));

  // Register use cases
  sl.registerLazySingleton(() => GetUpcomingGames(sl()));

  // Register repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(remoteDataSource: sl<ESPNScheduleDataSource>()),
  );
}

/// Register recommendation services
void _registerRecommendationServices() {
  // Use Cases
  sl.registerLazySingleton(() => GetNearbyPlaces(sl()));
  sl.registerLazySingleton(() => GetFilteredVenues(sl()));
  sl.registerLazySingleton(() => GetGeocodedLocation(sl()));
  
  // Repositories
  sl.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Data Sources
  sl.registerLazySingleton<PlacesApiDataSource>(
    () => PlacesApiDataSource(
      googleApiKey: ApiKeys.googlePlaces,
    ),
  );
}

/// Register social and external services
void _registerSocialServices() {
  // Social features
  sl.registerLazySingleton<SocialService>(() => SocialService());
  sl.registerLazySingleton<SocialDataSource>(
    () => SocialDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // Zapier Integration Service
  sl.registerLazySingleton(() => ZapierService(dio: sl()));

  // Game Day Automation Service
  sl.registerLazySingleton(() => GameDayAutomationService());

  // Data sources
  sl.registerLazySingleton<LiveScoresDataSource>(
    () => LiveScoresDataSourceImpl(
      dio: sl(),
      apiKey: ApiKeys.sportsDataIo,
    ),
  );
}

/// Register World Cup 2026 services
void _registerWorldCupServices() {
  // Data Sources
  sl.registerLazySingleton<WorldCupApiDataSource>(
    () => WorldCupApiDataSource(
      dio: sl(),
      apiKey: ApiKeys.sportsDataIo,
    ),
  );

  sl.registerLazySingleton<WorldCupFirestoreDataSource>(
    () => WorldCupFirestoreDataSource(
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<WorldCupCacheDataSource>(
    () => WorldCupCacheDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<WorldCupMatchRepository>(
    () => WorldCupMatchRepositoryImpl(
      apiDataSource: sl(),
      firestoreDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<NationalTeamRepository>(
    () => NationalTeamRepositoryImpl(
      apiDataSource: sl(),
      firestoreDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      apiDataSource: sl(),
      firestoreDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<BracketRepository>(
    () => BracketRepositoryImpl(
      firestoreDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  // User Preferences Repository (for favorites)
  sl.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(
      sharedPreferences: sl(),
    ),
  );

  // Predictions Repository
  sl.registerLazySingleton<PredictionsRepository>(
    () => PredictionsRepositoryImpl(
      sharedPreferences: sl(),
    ),
  );

  // BLoC/Cubit (using Factory pattern for fresh instances)
  sl.registerFactory(() => MatchListCubit(
    matchRepository: sl(),
  ));

  sl.registerFactory(() => GroupStandingsCubit(
    groupRepository: sl(),
  ));

  sl.registerFactory(() => BracketCubit(
    bracketRepository: sl(),
  ));

  sl.registerFactory(() => TeamsCubit(
    teamRepository: sl(),
  ));

  sl.registerFactory(() => FavoritesCubit(
    preferencesRepository: sl(),
    teamRepository: sl(),
    matchRepository: sl(),
  ));

  sl.registerFactory(() => PredictionsCubit(
    predictionsRepository: sl(),
    matchRepository: sl(),
  ));

  // AI Services for World Cup
  sl.registerLazySingleton(() => WorldCupAIService(
    multiProviderAI: sl<MultiProviderAIService>(),
  ));

  sl.registerFactory(() => WorldCupAICubit(
    aiService: sl<WorldCupAIService>(),
  ));

  // Nearby Venues Service (find bars/restaurants near stadiums)
  sl.registerLazySingleton(() => NearbyVenuesService(
    placesDataSource: sl<PlacesApiDataSource>(),
  ));

  sl.registerFactory(() => NearbyVenuesCubit(
    service: sl<NearbyVenuesService>(),
  ));

  // Match Reminder Service
  sl.registerLazySingleton(() => MatchReminderService());

  // Venue Enhancement Services
  sl.registerLazySingleton(() => VenueEnhancementService());

  sl.registerFactory(() => VenueEnhancementCubit(
    service: sl<VenueEnhancementService>(),
  ));

  sl.registerFactory(() => VenueFilterCubit(
    service: sl<VenueEnhancementService>(),
  ));

  // World Cup Payment Service
  sl.registerLazySingleton(() => WorldCupPaymentService());

  // RevenueCat Service (native in-app purchases)
  sl.registerLazySingleton(() => RevenueCatService());

  // TODO: Token Services - disabled pending legal review
  // When re-enabling, uncomment the following:
  // print('🔧 DI STEP 10: Token Services');
  // try {
  //   _registerTokenServices();
  //   print('✅ DI STEP 10: Token Services - SUCCESS');
  // } catch (e) {
  //   print('⚠️ DI STEP 10: Token Services - FAILED: $e');
  //   if (ANDROID_DIAGNOSTIC_MODE) {
  //     print('🔍 DIAGNOSTIC: Token services failed but app will continue');
  //   }
  // }
}

/// Register Watch Party services
void _registerWatchPartyServices() {
  // Services (Singleton - maintain state across app)
  sl.registerLazySingleton<WatchPartyService>(() => WatchPartyService());
  sl.registerLazySingleton<WatchPartyPaymentService>(() => WatchPartyPaymentService());

  // BLoC (Factory - fresh instance per screen)
  sl.registerFactory<WatchPartyBloc>(() => WatchPartyBloc(
    watchPartyService: sl(),
    paymentService: sl(),
  ));
}

/// Register Moderation services
void _registerModerationServices() {
  // Profanity Filter Service (Singleton)
  sl.registerLazySingleton<ProfanityFilterService>(() => ProfanityFilterService());

  // Moderation Service (Singleton)
  sl.registerLazySingleton<ModerationService>(() => ModerationService(
    profanityFilter: sl(),
  ));
}

/// Register Admin services
void _registerAdminServices() {
  // Admin Service (Singleton)
  sl.registerLazySingleton<AdminService>(() => AdminService());
}

/// Register Match Chat services
void _registerMatchChatServices() {
  // Match Chat Service (Singleton)
  sl.registerLazySingleton<MatchChatService>(() => MatchChatService());

  // Match Chat Cubit (Factory for fresh instances)
  sl.registerFactory<MatchChatCubit>(() => MatchChatCubit(
        chatService: sl(),
      ));
}

/// Register Calendar services
void _registerCalendarServices() {
  // Calendar Service (Singleton)
  sl.registerLazySingleton<CalendarService>(() => CalendarService());
}

/// Register Sharing services
void _registerSharingServices() {
  // Social Sharing Service (Singleton)
  sl.registerLazySingleton<SocialSharingService>(() => SocialSharingService());
}

// TODO: Token Feature - disabled pending legal review
// See docs/TODO_TOKEN_FEATURE.md for re-enabling instructions
// void _registerTokenServices() {
//   // Services
//   sl.registerLazySingleton<BaseBlockchainService>(
//     () => BaseBlockchainService(),
//   );
//
//   sl.registerLazySingleton<TokenService>(
//     () => TokenService(blockchainService: sl()),
//   );
//
//   // Repository
//   sl.registerLazySingleton<TokenRepository>(
//     () => TokenRepository(prefs: sl<SharedPreferences>()),
//   );
//
//   // Cubit (Factory for fresh instances per screen)
//   sl.registerFactory<TokenCubit>(
//     () => TokenCubit(
//       tokenService: sl(),
//       repository: sl(),
//     ),
//   );
// } 