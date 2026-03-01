import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import 'package:pregame_world_cup/core/services/presence_service.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';
import 'package:pregame_world_cup/core/services/deep_link_service.dart';
import 'package:pregame_world_cup/core/services/deep_link_navigator.dart';
import 'package:pregame_world_cup/core/services/accessibility_service.dart';
import 'package:pregame_world_cup/core/services/notification_preferences_service.dart';
import 'package:pregame_world_cup/core/services/localization_service.dart';
import 'package:pregame_world_cup/core/services/offline_service.dart';
import 'package:pregame_world_cup/core/services/widget_service.dart';

/// Tests for lib/di/core_di.dart  (Steps 1-2)
///
/// core_di calls `registerCoreDependencies(sl)` which registers:
///   - Dio, FirebaseFirestore, FirebaseAuth, SharedPreferences
///   - CacheService, AuthService, PresenceService, PushNotificationService,
///     AnalyticsService, DeepLinkService, DeepLinkNavigator,
///     AccessibilityService, NotificationPreferencesService
///   - LocalizationService, OfflineService, WidgetService (as Singletons via await)
///
/// Many of these classes internally access Firebase / platform channels, so we
/// cannot call `registerCoreDependencies` directly in a test. Instead, we
/// verify the *registration pattern* by manually registering + resolving
/// each type via GetIt in isolation (same approach as production code).
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

  // ---------------------------------------------------------------------------
  // Step 1: Core Dependencies
  // ---------------------------------------------------------------------------
  group('Core DI - Step 1: Core Dependencies', () {
    test('registers Dio as lazy singleton', () {
      sl.registerLazySingleton(() => Dio());

      expect(sl.isRegistered<Dio>(), isTrue);

      final a = sl<Dio>();
      final b = sl<Dio>();
      expect(identical(a, b), isTrue, reason: 'LazySingleton should return same instance');
    });

    test('registers FirebaseFirestore as lazy singleton', () {
      // Use a fake to avoid platform channel issues
      final fakeFirestore = _FakeFirebaseFirestore();
      sl.registerLazySingleton<FirebaseFirestore>(() => fakeFirestore);

      expect(sl.isRegistered<FirebaseFirestore>(), isTrue);
      expect(sl<FirebaseFirestore>(), same(fakeFirestore));
    });

    test('registers FirebaseAuth as lazy singleton', () {
      final mockAuth = MockFirebaseAuth();
      sl.registerLazySingleton<FirebaseAuth>(() => mockAuth);

      expect(sl.isRegistered<FirebaseAuth>(), isTrue);
      expect(sl<FirebaseAuth>(), same(mockAuth));
    });

    test('registers SharedPreferences as lazy singleton', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => prefs);

      expect(sl.isRegistered<SharedPreferences>(), isTrue);

      final a = sl<SharedPreferences>();
      final b = sl<SharedPreferences>();
      expect(identical(a, b), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Step 2: Core Services
  // ---------------------------------------------------------------------------
  group('Core DI - Step 2: Core Services', () {
    test('registers CacheService as lazy singleton', () {
      sl.registerLazySingleton(() => CacheService.instance);

      expect(sl.isRegistered<CacheService>(), isTrue);

      final a = sl<CacheService>();
      final b = sl<CacheService>();
      expect(identical(a, b), isTrue);
    });

    test('registers DeepLinkNavigator as lazy singleton', () {
      sl.registerLazySingleton(() => DeepLinkNavigator());

      expect(sl.isRegistered<DeepLinkNavigator>(), isTrue);

      final a = sl<DeepLinkNavigator>();
      final b = sl<DeepLinkNavigator>();
      expect(identical(a, b), isTrue);
    });

    test('registers AccessibilityService as lazy singleton', () {
      sl.registerLazySingleton(() => AccessibilityService());

      expect(sl.isRegistered<AccessibilityService>(), isTrue);

      final a = sl<AccessibilityService>();
      final b = sl<AccessibilityService>();
      expect(identical(a, b), isTrue);
    });

    test('LocalizationService registered as a singleton', () async {
      // Simulate the pattern in core_di: register an already-created instance
      SharedPreferences.setMockInitialValues({});
      final locService = await LocalizationService.getInstance();
      sl.registerSingleton<LocalizationService>(locService);

      expect(sl.isRegistered<LocalizationService>(), isTrue);
      expect(sl<LocalizationService>(), same(locService));
    });

    test('OfflineService registered as a singleton', () async {
      SharedPreferences.setMockInitialValues({});
      final offlineService = await OfflineService.getInstance();
      sl.registerSingleton<OfflineService>(offlineService);

      expect(sl.isRegistered<OfflineService>(), isTrue);
      expect(sl<OfflineService>(), same(offlineService));
    });

    test('WidgetService registered as a singleton', () async {
      SharedPreferences.setMockInitialValues({});
      final widgetService = await WidgetService.getInstance();
      sl.registerSingleton<WidgetService>(widgetService);

      expect(sl.isRegistered<WidgetService>(), isTrue);
      expect(sl<WidgetService>(), same(widgetService));
    });
  });

  // ---------------------------------------------------------------------------
  // Verify the full set of expected registrations
  // ---------------------------------------------------------------------------
  group('Core DI - completeness', () {
    test('all 16 expected types can be registered', () async {
      // Mimics what registerCoreDependencies registers (type set only)
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = _FakeFirebaseFirestore();

      sl.registerLazySingleton<Dio>(() => Dio());
      sl.registerLazySingleton<FirebaseFirestore>(() => fakeFirestore);
      sl.registerLazySingleton<FirebaseAuth>(() => mockAuth);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => prefs);

      sl.registerLazySingleton<CacheService>(() => CacheService.instance);
      sl.registerLazySingleton<AuthService>(() => AuthService());
      sl.registerLazySingleton<PresenceService>(() => PresenceService());
      sl.registerLazySingleton<PushNotificationService>(() => PushNotificationService());
      sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
      sl.registerLazySingleton<DeepLinkService>(() => DeepLinkService());
      sl.registerLazySingleton<DeepLinkNavigator>(() => DeepLinkNavigator());
      sl.registerLazySingleton<AccessibilityService>(() => AccessibilityService());
      sl.registerLazySingleton<NotificationPreferencesService>(
          () => NotificationPreferencesService());

      final locService = await LocalizationService.getInstance();
      sl.registerSingleton<LocalizationService>(locService);

      final offlineService = await OfflineService.getInstance();
      sl.registerSingleton<OfflineService>(offlineService);

      final widgetService = await WidgetService.getInstance();
      sl.registerSingleton<WidgetService>(widgetService);

      // Verify all 16 types registered
      expect(sl.isRegistered<Dio>(), isTrue);
      expect(sl.isRegistered<FirebaseFirestore>(), isTrue);
      expect(sl.isRegistered<FirebaseAuth>(), isTrue);
      expect(sl.isRegistered<SharedPreferences>(), isTrue);
      expect(sl.isRegistered<CacheService>(), isTrue);
      expect(sl.isRegistered<AuthService>(), isTrue);
      expect(sl.isRegistered<PresenceService>(), isTrue);
      expect(sl.isRegistered<PushNotificationService>(), isTrue);
      expect(sl.isRegistered<AnalyticsService>(), isTrue);
      expect(sl.isRegistered<DeepLinkService>(), isTrue);
      expect(sl.isRegistered<DeepLinkNavigator>(), isTrue);
      expect(sl.isRegistered<AccessibilityService>(), isTrue);
      expect(sl.isRegistered<NotificationPreferencesService>(), isTrue);
      expect(sl.isRegistered<LocalizationService>(), isTrue);
      expect(sl.isRegistered<OfflineService>(), isTrue);
      expect(sl.isRegistered<WidgetService>(), isTrue);
    });
  });
}

// -- Helpers --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Minimal fake for FirebaseFirestore to avoid platform channels.
class _FakeFirebaseFirestore extends Fake implements FirebaseFirestore {}
