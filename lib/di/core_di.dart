import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_exports.dart';
import '../features/auth/domain/services/auth_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/cache_service.dart';
import '../core/services/presence_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/deep_link_service.dart';
import '../core/services/deep_link_navigator.dart';
import '../core/services/accessibility_service.dart';
import '../core/services/notification_preferences_service.dart';
import '../core/services/localization_service.dart';
import '../core/services/offline_service.dart';
import '../core/services/widget_service.dart';
import '../core/services/haptic_service.dart';
import '../core/services/live_activity_service.dart';

/// Steps 1-2: Core dependencies and essential services.
Future<void> registerCoreDependencies(GetIt sl) async {
  // STEP 1: Core Dependencies (Essential)
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // STEP 2: Core Services (Essential)
  sl.registerLazySingleton(() => CacheService.instance);
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => PresenceService());
  sl.registerLazySingleton(() => PushNotificationService());
  sl.registerLazySingleton(() => AnalyticsService());
  sl.registerLazySingleton(() => DeepLinkService());
  sl.registerLazySingleton(() => DeepLinkNavigator());
  sl.registerLazySingleton(() => AccessibilityService());
  sl.registerLazySingleton(() => NotificationPreferencesService());

  final localizationService = await LocalizationService.getInstance();
  sl.registerSingleton<LocalizationService>(localizationService);

  final offlineService = await OfflineService.getInstance();
  sl.registerSingleton<OfflineService>(offlineService);

  final widgetService = await WidgetService.getInstance();
  sl.registerSingleton<WidgetService>(widgetService);

  // Haptic Match Experience
  sl.registerLazySingleton(() => HapticService());

  // Live Activities (iOS Dynamic Island + Lock Screen)
  final liveActivityService = LiveActivityService();
  await liveActivityService.init();
  sl.registerSingleton<LiveActivityService>(liveActivityService);
}
