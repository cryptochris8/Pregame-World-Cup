import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/local_prediction_engine.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/world_cup_ai_service.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/nearby_venues_service.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/match_reminder_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/world_cup_payment_service.dart';
import 'package:pregame_world_cup/features/recommendations/data/datasources/places_api_datasource.dart';
import 'package:pregame_world_cup/features/venue_portal/venue_portal.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';

import 'package:pregame_world_cup/di/worldcup_di.dart';

/// Tests for lib/di/worldcup_di.dart  (Step 9)
///
/// registerWorldCupServices registers a large number of types:
///   Data Sources: WorldCupApiDataSource, WorldCupFirestoreDataSource, WorldCupCacheDataSource
///   Repositories: WorldCupMatchRepository, NationalTeamRepository, GroupRepository,
///                 BracketRepository, UserPreferencesRepository, PredictionsRepository
///   Cubits (factory): MatchListCubit, GroupStandingsCubit, BracketCubit, TeamsCubit,
///                     FavoritesCubit, PredictionsCubit, WorldCupAICubit, NearbyVenuesCubit,
///                     VenueEnhancementCubit, VenueFilterCubit, VenueOnboardingCubit
///   Services: EnhancedMatchDataService, LocalPredictionEngine, WorldCupAIService,
///             NearbyVenuesService, MatchReminderService, VenueEnhancementService,
///             WorldCupPaymentService, RevenueCatService
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();

    // Register all prerequisite core dependencies
    sl.registerLazySingleton<Dio>(() => Dio());
    sl.registerLazySingleton<FirebaseFirestore>(() => FakeFirebaseFirestore());
    sl.registerLazySingleton<FirebaseAuth>(() => MockFirebaseAuth());
    sl.registerLazySingleton<CacheService>(() => CacheService.instance);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => prefs);

    // PlacesApiDataSource is required by NearbyVenuesService
    sl.registerLazySingleton<PlacesApiDataSource>(
      () => PlacesApiDataSource(googleApiKey: 'test-key'),
    );
  });

  group('World Cup DI - Data Sources', () {
    setUp(() {
      registerWorldCupServices(sl);
    });

    test('registers WorldCupApiDataSource as lazy singleton', () {
      expect(sl.isRegistered<WorldCupApiDataSource>(), isTrue);
      final a = sl<WorldCupApiDataSource>();
      final b = sl<WorldCupApiDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('registers WorldCupFirestoreDataSource as lazy singleton', () {
      expect(sl.isRegistered<WorldCupFirestoreDataSource>(), isTrue);
      final a = sl<WorldCupFirestoreDataSource>();
      final b = sl<WorldCupFirestoreDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('registers WorldCupCacheDataSource as lazy singleton', () {
      expect(sl.isRegistered<WorldCupCacheDataSource>(), isTrue);
      final a = sl<WorldCupCacheDataSource>();
      final b = sl<WorldCupCacheDataSource>();
      expect(identical(a, b), isTrue);
    });
  });

  group('World Cup DI - Repositories', () {
    setUp(() {
      registerWorldCupServices(sl);
    });

    test('registers all 6 repository interfaces', () {
      expect(sl.isRegistered<WorldCupMatchRepository>(), isTrue);
      expect(sl.isRegistered<NationalTeamRepository>(), isTrue);
      expect(sl.isRegistered<GroupRepository>(), isTrue);
      expect(sl.isRegistered<BracketRepository>(), isTrue);
      expect(sl.isRegistered<UserPreferencesRepository>(), isTrue);
      expect(sl.isRegistered<PredictionsRepository>(), isTrue);
    });

    test('WorldCupMatchRepository resolves to WorldCupMatchRepositoryImpl', () {
      expect(sl<WorldCupMatchRepository>(), isA<WorldCupMatchRepositoryImpl>());
    });

    test('NationalTeamRepository resolves to NationalTeamRepositoryImpl', () {
      expect(sl<NationalTeamRepository>(), isA<NationalTeamRepositoryImpl>());
    });

    test('GroupRepository resolves to GroupRepositoryImpl', () {
      expect(sl<GroupRepository>(), isA<GroupRepositoryImpl>());
    });

    test('BracketRepository resolves to BracketRepositoryImpl', () {
      expect(sl<BracketRepository>(), isA<BracketRepositoryImpl>());
    });

    test('UserPreferencesRepository resolves to UserPreferencesRepositoryImpl', () {
      expect(sl<UserPreferencesRepository>(), isA<UserPreferencesRepositoryImpl>());
    });

    test('PredictionsRepository resolves to PredictionsRepositoryImpl', () {
      expect(sl<PredictionsRepository>(), isA<PredictionsRepositoryImpl>());
    });

    test('repositories are singletons', () {
      final a = sl<WorldCupMatchRepository>();
      final b = sl<WorldCupMatchRepository>();
      expect(identical(a, b), isTrue);

      final c = sl<NationalTeamRepository>();
      final d = sl<NationalTeamRepository>();
      expect(identical(c, d), isTrue);
    });
  });

  group('World Cup DI - Cubits (factory registrations)', () {
    setUp(() {
      registerWorldCupServices(sl);
    });

    test('registers all 11 cubits/blocs', () {
      expect(sl.isRegistered<MatchListCubit>(), isTrue);
      expect(sl.isRegistered<GroupStandingsCubit>(), isTrue);
      expect(sl.isRegistered<BracketCubit>(), isTrue);
      expect(sl.isRegistered<TeamsCubit>(), isTrue);
      expect(sl.isRegistered<FavoritesCubit>(), isTrue);
      expect(sl.isRegistered<PredictionsCubit>(), isTrue);
      expect(sl.isRegistered<WorldCupAICubit>(), isTrue);
      expect(sl.isRegistered<NearbyVenuesCubit>(), isTrue);
      expect(sl.isRegistered<VenueEnhancementCubit>(), isTrue);
      expect(sl.isRegistered<VenueFilterCubit>(), isTrue);
      expect(sl.isRegistered<VenueOnboardingCubit>(), isTrue);
    });

    test('MatchListCubit is a factory - returns new instance each time', () {
      final a = sl<MatchListCubit>();
      final b = sl<MatchListCubit>();
      expect(identical(a, b), isFalse);
    });

    test('GroupStandingsCubit is a factory', () {
      final a = sl<GroupStandingsCubit>();
      final b = sl<GroupStandingsCubit>();
      expect(identical(a, b), isFalse);
    });

    test('BracketCubit is a factory', () {
      final a = sl<BracketCubit>();
      final b = sl<BracketCubit>();
      expect(identical(a, b), isFalse);
    });

    test('TeamsCubit is a factory', () {
      final a = sl<TeamsCubit>();
      final b = sl<TeamsCubit>();
      expect(identical(a, b), isFalse);
    });

    test('FavoritesCubit is a factory', () {
      final a = sl<FavoritesCubit>();
      final b = sl<FavoritesCubit>();
      expect(identical(a, b), isFalse);
    });

    test('PredictionsCubit is a factory', () {
      final a = sl<PredictionsCubit>();
      final b = sl<PredictionsCubit>();
      expect(identical(a, b), isFalse);
    });

    test('WorldCupAICubit is a factory', () {
      final a = sl<WorldCupAICubit>();
      final b = sl<WorldCupAICubit>();
      expect(identical(a, b), isFalse);
    });

    test('NearbyVenuesCubit is a factory', () {
      final a = sl<NearbyVenuesCubit>();
      final b = sl<NearbyVenuesCubit>();
      expect(identical(a, b), isFalse);
    });

    test('VenueEnhancementCubit is a factory', () {
      final a = sl<VenueEnhancementCubit>();
      final b = sl<VenueEnhancementCubit>();
      expect(identical(a, b), isFalse);
    });

    test('VenueFilterCubit is a factory', () {
      final a = sl<VenueFilterCubit>();
      final b = sl<VenueFilterCubit>();
      expect(identical(a, b), isFalse);
    });

    test('VenueOnboardingCubit is a factory', () {
      final a = sl<VenueOnboardingCubit>();
      final b = sl<VenueOnboardingCubit>();
      expect(identical(a, b), isFalse);
    });
  });

  group('World Cup DI - Services', () {
    setUp(() {
      registerWorldCupServices(sl);
    });

    test('registers all 8 service types', () {
      expect(sl.isRegistered<EnhancedMatchDataService>(), isTrue);
      expect(sl.isRegistered<LocalPredictionEngine>(), isTrue);
      expect(sl.isRegistered<WorldCupAIService>(), isTrue);
      expect(sl.isRegistered<NearbyVenuesService>(), isTrue);
      expect(sl.isRegistered<MatchReminderService>(), isTrue);
      expect(sl.isRegistered<VenueEnhancementService>(), isTrue);
      expect(sl.isRegistered<WorldCupPaymentService>(), isTrue);
      expect(sl.isRegistered<RevenueCatService>(), isTrue);
    });

    test('EnhancedMatchDataService is a lazy singleton', () {
      final a = sl<EnhancedMatchDataService>();
      final b = sl<EnhancedMatchDataService>();
      expect(identical(a, b), isTrue);
    });

    test('LocalPredictionEngine is a lazy singleton', () {
      final a = sl<LocalPredictionEngine>();
      final b = sl<LocalPredictionEngine>();
      expect(identical(a, b), isTrue);
    });

    test('WorldCupAIService is a lazy singleton', () {
      final a = sl<WorldCupAIService>();
      final b = sl<WorldCupAIService>();
      expect(identical(a, b), isTrue);
    });

    test('NearbyVenuesService is a lazy singleton', () {
      final a = sl<NearbyVenuesService>();
      final b = sl<NearbyVenuesService>();
      expect(identical(a, b), isTrue);
    });

    test('MatchReminderService is a lazy singleton', () {
      final a = sl<MatchReminderService>();
      final b = sl<MatchReminderService>();
      expect(identical(a, b), isTrue);
    });

    test('VenueEnhancementService is a lazy singleton', () {
      final a = sl<VenueEnhancementService>();
      final b = sl<VenueEnhancementService>();
      expect(identical(a, b), isTrue);
    });

    test('WorldCupPaymentService is a lazy singleton', () {
      final a = sl<WorldCupPaymentService>();
      final b = sl<WorldCupPaymentService>();
      expect(identical(a, b), isTrue);
    });

    test('RevenueCatService is a lazy singleton', () {
      final a = sl<RevenueCatService>();
      final b = sl<RevenueCatService>();
      expect(identical(a, b), isTrue);
    });
  });

  group('World Cup DI - completeness', () {
    test('all 28 registrations present', () {
      registerWorldCupServices(sl);

      // 3 data sources
      expect(sl.isRegistered<WorldCupApiDataSource>(), isTrue);
      expect(sl.isRegistered<WorldCupFirestoreDataSource>(), isTrue);
      expect(sl.isRegistered<WorldCupCacheDataSource>(), isTrue);

      // 6 repositories
      expect(sl.isRegistered<WorldCupMatchRepository>(), isTrue);
      expect(sl.isRegistered<NationalTeamRepository>(), isTrue);
      expect(sl.isRegistered<GroupRepository>(), isTrue);
      expect(sl.isRegistered<BracketRepository>(), isTrue);
      expect(sl.isRegistered<UserPreferencesRepository>(), isTrue);
      expect(sl.isRegistered<PredictionsRepository>(), isTrue);

      // 11 cubits
      expect(sl.isRegistered<MatchListCubit>(), isTrue);
      expect(sl.isRegistered<GroupStandingsCubit>(), isTrue);
      expect(sl.isRegistered<BracketCubit>(), isTrue);
      expect(sl.isRegistered<TeamsCubit>(), isTrue);
      expect(sl.isRegistered<FavoritesCubit>(), isTrue);
      expect(sl.isRegistered<PredictionsCubit>(), isTrue);
      expect(sl.isRegistered<WorldCupAICubit>(), isTrue);
      expect(sl.isRegistered<NearbyVenuesCubit>(), isTrue);
      expect(sl.isRegistered<VenueEnhancementCubit>(), isTrue);
      expect(sl.isRegistered<VenueFilterCubit>(), isTrue);
      expect(sl.isRegistered<VenueOnboardingCubit>(), isTrue);

      // 8 services
      expect(sl.isRegistered<EnhancedMatchDataService>(), isTrue);
      expect(sl.isRegistered<LocalPredictionEngine>(), isTrue);
      expect(sl.isRegistered<WorldCupAIService>(), isTrue);
      expect(sl.isRegistered<NearbyVenuesService>(), isTrue);
      expect(sl.isRegistered<MatchReminderService>(), isTrue);
      expect(sl.isRegistered<VenueEnhancementService>(), isTrue);
      expect(sl.isRegistered<WorldCupPaymentService>(), isTrue);
      expect(sl.isRegistered<RevenueCatService>(), isTrue);
    });
  });
}

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
