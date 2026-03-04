import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/core/services/analytics_service.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_service.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_payment_service.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/bloc/watch_party_bloc.dart';

import 'package:pregame_world_cup/di/watch_party_di.dart';

/// Tests for lib/di/watch_party_di.dart  (Step 10)
///
/// registerWatchPartyServices registers:
///   - WatchPartyService (lazy singleton)
///   - WatchPartyPaymentService (lazy singleton)
///   - WatchPartyBloc (factory)
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();
    // Register prerequisites needed by WatchPartyService
    sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  });

  group('Watch Party DI - registerWatchPartyServices', () {
    setUp(() {
      registerWatchPartyServices(sl);
    });

    test('registers all 3 expected types', () {
      expect(sl.isRegistered<WatchPartyService>(), isTrue);
      expect(sl.isRegistered<WatchPartyPaymentService>(), isTrue);
      expect(sl.isRegistered<WatchPartyBloc>(), isTrue);
    });

    test('WatchPartyService is a lazy singleton', () {
      final a = sl<WatchPartyService>();
      final b = sl<WatchPartyService>();
      expect(identical(a, b), isTrue);
    });

    test('WatchPartyPaymentService is a lazy singleton', () {
      final a = sl<WatchPartyPaymentService>();
      final b = sl<WatchPartyPaymentService>();
      expect(identical(a, b), isTrue);
    });

    test('WatchPartyBloc is a factory - returns new instance each time', () {
      final a = sl<WatchPartyBloc>();
      final b = sl<WatchPartyBloc>();
      expect(identical(a, b), isFalse, reason: 'Factory should create new instances');
    });
  });

  group('Watch Party DI - type correctness', () {
    setUp(() {
      registerWatchPartyServices(sl);
    });

    test('all types resolve to correct concrete types', () {
      expect(sl<WatchPartyService>(), isA<WatchPartyService>());
      expect(sl<WatchPartyPaymentService>(), isA<WatchPartyPaymentService>());
      expect(sl<WatchPartyBloc>(), isA<WatchPartyBloc>());
    });
  });

  group('Watch Party DI - dependency wiring', () {
    test('WatchPartyBloc receives services from sl', () {
      registerWatchPartyServices(sl);

      // If wiring is broken, resolving would throw
      final bloc = sl<WatchPartyBloc>();
      expect(bloc, isNotNull);
      expect(bloc, isA<WatchPartyBloc>());
    });
  });

  group('Watch Party DI - duplicate registration guard', () {
    test('calling registerWatchPartyServices twice throws', () {
      registerWatchPartyServices(sl);
      expect(
        () => registerWatchPartyServices(sl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
