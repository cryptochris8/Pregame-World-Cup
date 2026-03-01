import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pregame_world_cup/features/recommendations/data/datasources/places_api_datasource.dart';
import 'package:pregame_world_cup/features/recommendations/data/repositories/places_repository_impl.dart';
import 'package:pregame_world_cup/features/recommendations/domain/repositories/places_repository.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_nearby_places.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_filtered_venues.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_geocoded_location.dart';

import 'package:pregame_world_cup/di/recommendations_di.dart';

/// Tests for lib/di/recommendations_di.dart  (Step 7)
///
/// registerRecommendationServices registers:
///   - PlacesApiDataSource (with ApiKeys.googlePlaces)
///   - PlacesRepository -> PlacesRepositoryImpl
///   - GetNearbyPlaces, GetFilteredVenues, GetGeocodedLocation
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

  group('Recommendations DI - registerRecommendationServices', () {
    setUp(() {
      // Call the real registration function
      registerRecommendationServices(sl);
    });

    test('registers all 5 expected types', () {
      expect(sl.isRegistered<PlacesApiDataSource>(), isTrue);
      expect(sl.isRegistered<PlacesRepository>(), isTrue);
      expect(sl.isRegistered<GetNearbyPlaces>(), isTrue);
      expect(sl.isRegistered<GetFilteredVenues>(), isTrue);
      expect(sl.isRegistered<GetGeocodedLocation>(), isTrue);
    });

    test('PlacesApiDataSource is a lazy singleton', () {
      final a = sl<PlacesApiDataSource>();
      final b = sl<PlacesApiDataSource>();
      expect(identical(a, b), isTrue);
    });

    test('PlacesRepository is a lazy singleton', () {
      final a = sl<PlacesRepository>();
      final b = sl<PlacesRepository>();
      expect(identical(a, b), isTrue);
    });

    test('PlacesRepository resolves to PlacesRepositoryImpl', () {
      expect(sl<PlacesRepository>(), isA<PlacesRepositoryImpl>());
    });

    test('GetNearbyPlaces is a lazy singleton', () {
      final a = sl<GetNearbyPlaces>();
      final b = sl<GetNearbyPlaces>();
      expect(identical(a, b), isTrue);
    });

    test('GetFilteredVenues is a lazy singleton', () {
      final a = sl<GetFilteredVenues>();
      final b = sl<GetFilteredVenues>();
      expect(identical(a, b), isTrue);
    });

    test('GetGeocodedLocation is a lazy singleton', () {
      final a = sl<GetGeocodedLocation>();
      final b = sl<GetGeocodedLocation>();
      expect(identical(a, b), isTrue);
    });
  });

  group('Recommendations DI - type correctness', () {
    setUp(() {
      registerRecommendationServices(sl);
    });

    test('all types resolve to correct concrete types', () {
      expect(sl<PlacesApiDataSource>(), isA<PlacesApiDataSource>());
      expect(sl<PlacesRepository>(), isA<PlacesRepositoryImpl>());
      expect(sl<GetNearbyPlaces>(), isA<GetNearbyPlaces>());
      expect(sl<GetFilteredVenues>(), isA<GetFilteredVenues>());
      expect(sl<GetGeocodedLocation>(), isA<GetGeocodedLocation>());
    });
  });

  group('Recommendations DI - duplicate registration guard', () {
    test('calling registerRecommendationServices twice throws', () {
      registerRecommendationServices(sl);
      expect(
        () => registerRecommendationServices(sl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
