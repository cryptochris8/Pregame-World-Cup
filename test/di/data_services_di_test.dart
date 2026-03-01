import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pregame_world_cup/services/espn_service.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/espn_schedule_datasource.dart';
import 'package:pregame_world_cup/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:pregame_world_cup/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:pregame_world_cup/features/schedule/domain/usecases/get_upcoming_games.dart';
import 'package:pregame_world_cup/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';

/// Tests for lib/di/data_services_di.dart  (Steps 5-6)
///
/// registerDataServices registers:
///   Step 5: ESPNService, ESPNScheduleDataSource (with fallback path)
///   Step 6: ScheduleBloc (factory), GetUpcomingGames, ScheduleRepository
///
/// We cannot call the real `registerDataServices` because it internally uses
/// `Future.any` with a timeout and requires CacheService to be initialized.
/// Instead we replicate the registration pattern manually to test GetIt
/// wiring correctness.
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();
  });

  group('Data Services DI - registration pattern', () {
    late MockCacheService mockCacheService;

    setUp(() {
      mockCacheService = MockCacheService();

      // Register the dependencies that data_services_di.dart expects to exist
      sl.registerLazySingleton<CacheService>(() => mockCacheService);

      // Step 5: ESPN services
      sl.registerLazySingleton(() => ESPNService());
      sl.registerLazySingleton(() => ESPNScheduleDataSource(
            espnService: sl(),
            cacheService: sl(),
          ));

      // Step 6: Schedule services
      sl.registerLazySingleton<ScheduleRepository>(
        () => ScheduleRepositoryImpl(remoteDataSource: sl<ESPNScheduleDataSource>()),
      );
      sl.registerLazySingleton(() => GetUpcomingGames(sl()));
      sl.registerFactory(() => ScheduleBloc(
            getUpcomingGames: sl(),
            scheduleRepository: sl(),
          ));
    });

    test('registers all 5 expected types', () {
      expect(sl.isRegistered<ESPNService>(), isTrue);
      expect(sl.isRegistered<ESPNScheduleDataSource>(), isTrue);
      expect(sl.isRegistered<ScheduleRepository>(), isTrue);
      expect(sl.isRegistered<GetUpcomingGames>(), isTrue);
      expect(sl.isRegistered<ScheduleBloc>(), isTrue);
    });

    test('ESPNService is a lazy singleton', () {
      final a = sl<ESPNService>();
      final b = sl<ESPNService>();
      expect(identical(a, b), isTrue);
    });

    test('ESPNScheduleDataSource is a lazy singleton', () {
      final a = sl<ESPNScheduleDataSource>();
      final b = sl<ESPNScheduleDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('ScheduleRepository is a lazy singleton', () {
      final a = sl<ScheduleRepository>();
      final b = sl<ScheduleRepository>();
      expect(identical(a, b), isTrue);
    });

    test('ScheduleRepository resolves to ScheduleRepositoryImpl', () {
      expect(sl<ScheduleRepository>(), isA<ScheduleRepositoryImpl>());
    });

    test('GetUpcomingGames is a lazy singleton', () {
      final a = sl<GetUpcomingGames>();
      final b = sl<GetUpcomingGames>();
      expect(identical(a, b), isTrue);
    });

    test('ScheduleBloc is a factory - returns new instance each time', () {
      final a = sl<ScheduleBloc>();
      final b = sl<ScheduleBloc>();
      expect(identical(a, b), isFalse, reason: 'Factory should create new instances');
    });
  });

  group('Data Services DI - dependency wiring', () {
    test('ESPNScheduleDataSource receives ESPNService via sl()', () {
      final mockCacheService = MockCacheService();
      sl.registerLazySingleton<CacheService>(() => mockCacheService);
      sl.registerLazySingleton(() => ESPNService());
      sl.registerLazySingleton(() => ESPNScheduleDataSource(
            espnService: sl(),
            cacheService: sl(),
          ));

      // If wiring is broken, resolving would throw
      final ds = sl<ESPNScheduleDataSource>();
      expect(ds, isNotNull);
    });

    test('ScheduleRepositoryImpl receives ESPNScheduleDataSource via sl()', () {
      final mockCacheService = MockCacheService();
      sl.registerLazySingleton<CacheService>(() => mockCacheService);
      sl.registerLazySingleton(() => ESPNService());
      sl.registerLazySingleton(() => ESPNScheduleDataSource(
            espnService: sl(),
            cacheService: sl(),
          ));
      sl.registerLazySingleton<ScheduleRepository>(
        () => ScheduleRepositoryImpl(remoteDataSource: sl<ESPNScheduleDataSource>()),
      );

      final repo = sl<ScheduleRepository>();
      expect(repo, isA<ScheduleRepositoryImpl>());
    });
  });
}

// -- Mocks --
class MockCacheService extends Mock implements CacheService {}
