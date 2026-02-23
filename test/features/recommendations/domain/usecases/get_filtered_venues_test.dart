import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/venue_filter.dart';
import 'package:pregame_world_cup/features/recommendations/domain/repositories/places_repository.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_filtered_venues.dart';

// ==================== MOCKS ====================

class MockPlacesRepository extends Mock implements PlacesRepository {}

class FakeVenueFilter extends Fake implements VenueFilter {}

// ==================== TESTS ====================

void main() {
  late MockPlacesRepository mockRepository;
  late GetFilteredVenues useCase;

  setUpAll(() {
    registerFallbackValue(FakeVenueFilter());
  });

  setUp(() {
    mockRepository = MockPlacesRepository();
    useCase = GetFilteredVenues(mockRepository);
  });

  group('GetFilteredVenues', () {
    const testLat = 40.7128;
    const testLng = -74.0060;
    const testFilter = VenueFilter(
      venueTypes: [VenueType.bar, VenueType.restaurant],
      maxDistance: 3.0,
      minRating: 4.0,
      priceLevel: PriceLevel.moderate,
      openNow: true,
    );

    final testPlaces = [
      const Place(
        placeId: 'place_1',
        name: 'Bar One',
        rating: 4.5,
        priceLevel: 2,
      ),
      const Place(
        placeId: 'place_2',
        name: 'Restaurant Two',
        rating: 4.2,
        priceLevel: 2,
      ),
    ];

    test('calls repository with correct parameters', () async {
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: testFilter,
      );

      verify(() => mockRepository.getFilteredVenues(
            latitude: testLat,
            longitude: testLng,
            filter: testFilter,
          )).called(1);
    });

    test('returns Right with list of places on success', () async {
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: testFilter,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (places) {
          expect(places, hasLength(2));
          expect(places[0].name, equals('Bar One'));
          expect(places[1].name, equals('Restaurant Two'));
        },
      );
    });

    test('returns Right with empty list when no venues match', () async {
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => const Right([]));

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: testFilter,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (places) => expect(places, isEmpty),
      );
    });

    test('returns Left with ServerFailure on error', () async {
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: testFilter,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, equals('Server error occurred'));
        },
        (places) => fail('Expected Left but got Right'),
      );
    });

    test('returns Left with NetworkFailure on network error', () async {
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Left(NetworkFailure()));

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: testFilter,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, equals('Network error occurred'));
        },
        (places) => fail('Expected Left but got Right'),
      );
    });

    test('works with default filter', () async {
      const defaultFilter = VenueFilter();
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: defaultFilter,
      );

      verify(() => mockRepository.getFilteredVenues(
            latitude: testLat,
            longitude: testLng,
            filter: defaultFilter,
          )).called(1);
    });

    test('works with barsOnly filter', () async {
      final barsFilter = VenueFilter.barsOnly();
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: barsFilter,
      );

      verify(() => mockRepository.getFilteredVenues(
            latitude: testLat,
            longitude: testLng,
            filter: barsFilter,
          )).called(1);
    });

    test('works with restaurantsOnly filter', () async {
      final restaurantsFilter = VenueFilter.restaurantsOnly();
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: restaurantsFilter,
      );

      verify(() => mockRepository.getFilteredVenues(
            latitude: testLat,
            longitude: testLng,
            filter: restaurantsFilter,
          )).called(1);
    });

    test('works with filter.all()', () async {
      final allFilter = VenueFilter.all();
      when(() => mockRepository.getFilteredVenues(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => Right(testPlaces));

      await useCase(
        latitude: testLat,
        longitude: testLng,
        filter: allFilter,
      );

      verify(() => mockRepository.getFilteredVenues(
            latitude: testLat,
            longitude: testLng,
            filter: allFilter,
          )).called(1);
    });
  });
}
