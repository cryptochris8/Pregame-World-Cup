import 'package:get_it/get_it.dart';

import '../features/social/data/datasources/social_datasource.dart';
import '../features/social/domain/services/social_service.dart';
import '../features/schedule/data/datasources/live_scores_datasource.dart';
import '../services/zapier_service.dart';
import '../config/api_keys.dart';

/// Step 8: Social features, Zapier, and live scores data source.
void registerSocialServices(GetIt sl) {
  sl.registerLazySingleton<SocialService>(() => SocialService());
  sl.registerLazySingleton<SocialDataSource>(
    () => SocialDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );

  sl.registerLazySingleton(() => ZapierService(dio: sl()));

  sl.registerLazySingleton<LiveScoresDataSource>(
    () => LiveScoresDataSourceImpl(
      dio: sl(),
      apiKey: ApiKeys.sportsDataIo,
    ),
  );
}
