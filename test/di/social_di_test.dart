import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pregame_world_cup/features/social/data/datasources/social_datasource.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_service.dart';
import 'package:pregame_world_cup/features/social/domain/services/notification_service.dart';
import 'package:pregame_world_cup/features/schedule/data/datasources/live_scores_datasource.dart';
import 'package:pregame_world_cup/services/zapier_service.dart';

import 'package:pregame_world_cup/di/social_di.dart';

/// Tests for lib/di/social_di.dart  (Step 8)
///
/// registerSocialServices registers:
///   - SocialService
///   - NotificationService
///   - SocialDataSource -> SocialDataSourceImpl (needs firestore + auth)
///   - ZapierService (needs Dio)
///   - LiveScoresDataSource -> LiveScoresDataSourceImpl (needs Dio + apiKey)
void main() {
  final sl = GetIt.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() async {
    await sl.reset();
    // Register prerequisite core dependencies
    sl.registerLazySingleton<FirebaseFirestore>(() => FakeFirebaseFirestore());
    sl.registerLazySingleton<FirebaseAuth>(() => MockFirebaseAuth());
    sl.registerLazySingleton<Dio>(() => Dio());
  });

  group('Social DI - registerSocialServices', () {
    setUp(() {
      registerSocialServices(sl);
    });

    test('registers all 5 expected types', () {
      expect(sl.isRegistered<SocialService>(), isTrue);
      expect(sl.isRegistered<NotificationService>(), isTrue);
      expect(sl.isRegistered<SocialDataSource>(), isTrue);
      expect(sl.isRegistered<ZapierService>(), isTrue);
      expect(sl.isRegistered<LiveScoresDataSource>(), isTrue);
    });

    test('SocialService is a lazy singleton', () {
      final a = sl<SocialService>();
      final b = sl<SocialService>();
      expect(identical(a, b), isTrue);
    });

    test('NotificationService is a lazy singleton', () {
      final a = sl<NotificationService>();
      final b = sl<NotificationService>();
      expect(identical(a, b), isTrue);
    });

    test('SocialDataSource is a lazy singleton', () {
      final a = sl<SocialDataSource>();
      final b = sl<SocialDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('SocialDataSource resolves to SocialDataSourceImpl', () {
      expect(sl<SocialDataSource>(), isA<SocialDataSourceImpl>());
    });

    test('ZapierService is a lazy singleton', () {
      final a = sl<ZapierService>();
      final b = sl<ZapierService>();
      expect(identical(a, b), isTrue);
    });

    test('LiveScoresDataSource is a lazy singleton', () {
      final a = sl<LiveScoresDataSource>();
      final b = sl<LiveScoresDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('LiveScoresDataSource resolves to LiveScoresDataSourceImpl', () {
      expect(sl<LiveScoresDataSource>(), isA<LiveScoresDataSourceImpl>());
    });
  });

  group('Social DI - dependency wiring', () {
    test('SocialDataSourceImpl receives Firestore and Auth from sl', () {
      registerSocialServices(sl);

      // Resolving would throw if dependencies are not properly wired
      final ds = sl<SocialDataSource>();
      expect(ds, isNotNull);
      expect(ds, isA<SocialDataSourceImpl>());
    });

    test('ZapierService receives Dio from sl', () {
      registerSocialServices(sl);

      final zapier = sl<ZapierService>();
      expect(zapier, isNotNull);
    });

    test('LiveScoresDataSourceImpl receives Dio from sl', () {
      registerSocialServices(sl);

      final ds = sl<LiveScoresDataSource>();
      expect(ds, isNotNull);
      expect(ds, isA<LiveScoresDataSourceImpl>());
    });
  });

  group('Social DI - duplicate registration guard', () {
    test('calling registerSocialServices twice throws', () {
      registerSocialServices(sl);
      expect(
        () => registerSocialServices(sl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
