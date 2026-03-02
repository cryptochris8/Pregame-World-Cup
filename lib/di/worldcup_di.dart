import 'package:get_it/get_it.dart';

import '../features/worldcup/worldcup.dart';
import '../features/worldcup/data/services/enhanced_match_data_service.dart';
import '../features/worldcup/data/services/local_prediction_engine.dart';
import '../features/worldcup/data/services/world_cup_ai_service.dart';
import '../features/worldcup/data/services/nearby_venues_service.dart';
import '../features/worldcup/data/services/match_reminder_service.dart';
import '../features/worldcup/domain/services/world_cup_payment_service.dart';
import '../features/recommendations/data/datasources/places_api_datasource.dart';
import '../features/venue_portal/venue_portal.dart';
import '../services/revenuecat_service.dart';
import '../config/api_keys.dart';

/// Step 9: World Cup 2026 data sources, repositories, cubits, and services.
void registerWorldCupServices(GetIt sl) {
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

  sl.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<PredictionsRepository>(
    () => PredictionsRepositoryImpl(
      sharedPreferences: sl(),
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // BLoC/Cubit
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

  // Enhanced Match Data Service
  sl.registerLazySingleton(() => EnhancedMatchDataService.instance);

  // Local Prediction Engine
  sl.registerLazySingleton(() => LocalPredictionEngine(
    enhancedDataService: sl<EnhancedMatchDataService>(),
  ));

  // AI Services for World Cup
  sl.registerLazySingleton(() => WorldCupAIService(
    localEngine: sl<LocalPredictionEngine>(),
  ));

  sl.registerFactory(() => WorldCupAICubit(
    aiService: sl<WorldCupAIService>(),
  ));

  // Nearby Venues Service
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

  sl.registerFactory(() => VenueOnboardingCubit(
    service: sl<VenueEnhancementService>(),
  ));

  // World Cup Payment Service
  sl.registerLazySingleton(() => WorldCupPaymentService());

  // RevenueCat Service
  sl.registerLazySingleton(() => RevenueCatService());
}
