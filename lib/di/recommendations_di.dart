import 'package:get_it/get_it.dart';

import '../features/recommendations/data/datasources/places_api_datasource.dart';
import '../features/recommendations/data/repositories/places_repository_impl.dart';
import '../features/recommendations/domain/repositories/places_repository.dart';
import '../features/recommendations/domain/usecases/get_nearby_places.dart';
import '../features/recommendations/domain/usecases/get_filtered_venues.dart';
import '../features/recommendations/domain/usecases/get_geocoded_location.dart';
import '../config/api_keys.dart';

/// Step 7: Recommendation services (Places API, geocoding).
void registerRecommendationServices(GetIt sl) {
  sl.registerLazySingleton(() => GetNearbyPlaces(sl()));
  sl.registerLazySingleton(() => GetFilteredVenues(sl()));
  sl.registerLazySingleton(() => GetGeocodedLocation(sl()));

  sl.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PlacesApiDataSource>(
    () => PlacesApiDataSource(
      googleApiKey: ApiKeys.googlePlaces,
    ),
  );
}
