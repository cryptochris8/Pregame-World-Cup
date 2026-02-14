import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/nearby_venues_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_venue.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/bloc/nearby_venues_cubit.dart';

// Mock
class MockNearbyVenuesService extends Mock implements NearbyVenuesService {}

void main() {
  late MockNearbyVenuesService mockService;
  late NearbyVenuesCubit cubit;

  // Test stadium
  const testStadium = WorldCupVenue(
    venueId: 'metlife',
    name: 'MetLife Stadium',
    worldCupName: 'New York New Jersey Stadium',
    city: 'East Rutherford',
    state: 'New Jersey',
    country: HostCountry.usa,
    capacity: 82500,
    latitude: 40.8128,
    longitude: -74.0742,
  );

  // Test places
  const barPlace = Place(
    placeId: 'bar_1',
    name: 'Sports Bar NYC',
    vicinity: '123 Main St',
    rating: 4.5,
    types: ['bar', 'point_of_interest'],
    latitude: 40.8130,
    longitude: -74.0740,
  );

  const restaurantPlace = Place(
    placeId: 'rest_1',
    name: 'Italian Restaurant',
    vicinity: '456 Oak Ave',
    rating: 4.2,
    types: ['restaurant', 'food', 'point_of_interest'],
    latitude: 40.8135,
    longitude: -74.0750,
  );

  const cafePlace = Place(
    placeId: 'cafe_1',
    name: 'Corner Cafe',
    vicinity: '789 Elm St',
    rating: 4.0,
    types: ['cafe', 'point_of_interest'],
    latitude: 40.8140,
    longitude: -74.0760,
  );

  const barRestaurantPlace = Place(
    placeId: 'barrest_1',
    name: 'Pub & Grill',
    vicinity: '101 Pine St',
    rating: 4.3,
    types: ['bar', 'restaurant', 'point_of_interest'],
    latitude: 40.8125,
    longitude: -74.0735,
  );

  // Test NearbyVenueResult objects
  final testVenueResults = [
    const NearbyVenueResult(
      place: barPlace,
      distanceMeters: 150.0,
      stadium: testStadium,
    ),
    const NearbyVenueResult(
      place: restaurantPlace,
      distanceMeters: 300.0,
      stadium: testStadium,
    ),
    const NearbyVenueResult(
      place: cafePlace,
      distanceMeters: 500.0,
      stadium: testStadium,
    ),
    const NearbyVenueResult(
      place: barRestaurantPlace,
      distanceMeters: 200.0,
      stadium: testStadium,
    ),
  ];

  setUp(() {
    mockService = MockNearbyVenuesService();
    cubit = NearbyVenuesCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(testStadium);
  });

  group('NearbyVenuesCubit', () {
    // ---------------------------------------------------------------
    // 1. Initial state is correct
    // ---------------------------------------------------------------
    test('initial state is correct', () {
      expect(cubit.state.venues, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.stadium, isNull);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.radiusMeters, 2000);
      expect(cubit.state.selectedType, 'all');
    });

    // ---------------------------------------------------------------
    // 2. loadNearbyVenues loads venues for a stadium
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'loadNearbyVenues loads venues for a stadium and emits loaded state',
      build: () {
        when(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            )).thenAnswer((_) async => testVenueResults);
        return cubit;
      },
      act: (cubit) => cubit.loadNearbyVenues(testStadium),
      expect: () => [
        // First emission: loading true, stadium set, error cleared
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.stadium, 'stadium', testStadium)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second emission: loading false, venues populated
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.venues.length, 'venues length', 4)
            .having((s) => s.stadium, 'stadium', testStadium),
      ],
      verify: (_) {
        verify(() => mockService.getNearbyVenues(
              stadium: testStadium,
              radiusMeters: 2000,
            )).called(1);
      },
    );

    // ---------------------------------------------------------------
    // 3. loadNearbyVenues handles errors
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'loadNearbyVenues handles errors',
      build: () {
        when(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            )).thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadNearbyVenues(testStadium),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.stadium, 'stadium', testStadium),
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having(
              (s) => s.errorMessage,
              'error contains message',
              contains('Failed to load nearby venues'),
            ),
      ],
    );

    // ---------------------------------------------------------------
    // 4. loadNearbyVenuesByStadiumId loads venues for a valid stadium
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'loadNearbyVenuesByStadiumId loads venues for a valid stadium',
      build: () {
        when(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            )).thenAnswer((_) async => testVenueResults);
        return cubit;
      },
      act: (cubit) => cubit.loadNearbyVenuesByStadiumId('metlife'),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.stadium?.venueId, 'stadium venueId', 'metlife'),
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.venues.length, 'venues length', 4),
      ],
    );

    // ---------------------------------------------------------------
    // 5. loadNearbyVenuesByStadiumId emits error for invalid stadium
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'loadNearbyVenuesByStadiumId emits error for invalid stadium',
      build: () => cubit,
      act: (cubit) => cubit.loadNearbyVenuesByStadiumId('nonexistent_stadium'),
      expect: () => [
        isA<NearbyVenuesState>()
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Stadium not found',
            )
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
      verify: (_) {
        verifyNever(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            ));
      },
    );

    // ---------------------------------------------------------------
    // 6. setRadius updates radius and reloads venues
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'setRadius updates radius and reloads venues when stadium is loaded',
      build: () {
        when(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            )).thenAnswer((_) async => testVenueResults);
        return cubit;
      },
      seed: () => NearbyVenuesState(
        stadium: testStadium,
        venues: testVenueResults,
      ),
      act: (cubit) => cubit.setRadius(5000),
      expect: () => [
        // First: radius updated
        isA<NearbyVenuesState>()
            .having((s) => s.radiusMeters, 'radiusMeters', 5000),
        // Then loadNearbyVenues is called, which emits loading
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.stadium, 'stadium', testStadium),
        // Then loaded
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.venues.length, 'venues length', 4),
      ],
    );

    // ---------------------------------------------------------------
    // 7. setRadius only updates state if no stadium loaded
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'setRadius only updates state if no stadium loaded',
      build: () => cubit,
      act: (cubit) => cubit.setRadius(3000),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.radiusMeters, 'radiusMeters', 3000)
            .having((s) => s.stadium, 'stadium', isNull)
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
      verify: (_) {
        verifyNever(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            ));
      },
    );

    // ---------------------------------------------------------------
    // 8. setTypeFilter updates selected type filter
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'setTypeFilter updates selected type filter',
      build: () => cubit,
      act: (cubit) => cubit.setTypeFilter('bar'),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.selectedType, 'selectedType', 'bar'),
      ],
    );

    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'setTypeFilter can cycle through all types',
      build: () => cubit,
      act: (cubit) {
        cubit.setTypeFilter('bar');
        cubit.setTypeFilter('restaurant');
        cubit.setTypeFilter('cafe');
        cubit.setTypeFilter('all');
      },
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.selectedType, 'selectedType', 'bar'),
        isA<NearbyVenuesState>()
            .having((s) => s.selectedType, 'selectedType', 'restaurant'),
        isA<NearbyVenuesState>()
            .having((s) => s.selectedType, 'selectedType', 'cafe'),
        isA<NearbyVenuesState>()
            .having((s) => s.selectedType, 'selectedType', 'all'),
      ],
    );

    // ---------------------------------------------------------------
    // 9. refresh reloads venues for current stadium
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'refresh reloads venues for current stadium',
      build: () {
        when(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            )).thenAnswer((_) async => testVenueResults);
        return cubit;
      },
      seed: () => NearbyVenuesState(
        stadium: testStadium,
        venues: testVenueResults,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.stadium, 'stadium', testStadium),
        isA<NearbyVenuesState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.venues.length, 'venues length', 4),
      ],
      verify: (_) {
        verify(() => mockService.getNearbyVenues(
              stadium: testStadium,
              radiusMeters: 2000,
            )).called(1);
      },
    );

    // ---------------------------------------------------------------
    // 10. refresh does nothing when no stadium loaded
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'refresh does nothing when no stadium loaded',
      build: () => cubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockService.getNearbyVenues(
              stadium: any(named: 'stadium'),
              radiusMeters: any(named: 'radiusMeters'),
            ));
      },
    );

    // ---------------------------------------------------------------
    // 11. clearError clears error message
    // ---------------------------------------------------------------
    blocTest<NearbyVenuesCubit, NearbyVenuesState>(
      'clearError clears error message',
      build: () => cubit,
      seed: () => const NearbyVenuesState(
        errorMessage: 'Some error occurred',
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<NearbyVenuesState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    // ---------------------------------------------------------------
    // 12. State filteredVenues returns correct results for 'all' type
    // ---------------------------------------------------------------
    test('filteredVenues returns all venues when selectedType is all', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        selectedType: 'all',
      );

      expect(state.filteredVenues.length, 4);
      expect(state.filteredVenues, equals(testVenueResults));
    });

    // ---------------------------------------------------------------
    // 13. State filteredVenues filters by bar/restaurant/cafe types
    // ---------------------------------------------------------------
    test('filteredVenues filters by bar type', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        selectedType: 'bar',
      );

      final filtered = state.filteredVenues;
      // barPlace has ['bar', 'point_of_interest']
      // barRestaurantPlace has ['bar', 'restaurant', 'point_of_interest']
      expect(filtered.length, 2);
      expect(
        filtered.every((v) => (v.place.types ?? []).contains('bar')),
        isTrue,
      );
    });

    test('filteredVenues filters by restaurant type', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        selectedType: 'restaurant',
      );

      final filtered = state.filteredVenues;
      // restaurantPlace has ['restaurant', 'food', 'point_of_interest']
      // barRestaurantPlace has ['bar', 'restaurant', 'point_of_interest']
      expect(filtered.length, 2);
      expect(
        filtered.every((v) => (v.place.types ?? []).contains('restaurant')),
        isTrue,
      );
    });

    test('filteredVenues filters by cafe type', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        selectedType: 'cafe',
      );

      final filtered = state.filteredVenues;
      // Only cafePlace has ['cafe', 'point_of_interest']
      expect(filtered.length, 1);
      expect(filtered.first.place.name, 'Corner Cafe');
    });

    test('filteredVenues returns all for unknown type', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        selectedType: 'unknown',
      );

      // The default case in the switch returns true, so all venues pass
      expect(state.filteredVenues.length, 4);
    });

    // ---------------------------------------------------------------
    // 14. State barCount/restaurantCount/cafeCount return correct values
    // ---------------------------------------------------------------
    test('barCount returns correct count', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
      );

      // barPlace and barRestaurantPlace both have 'bar' in types
      expect(state.barCount, 2);
    });

    test('restaurantCount returns correct count', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
      );

      // restaurantPlace and barRestaurantPlace both have 'restaurant' in types
      expect(state.restaurantCount, 2);
    });

    test('cafeCount returns correct count', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
      );

      // Only cafePlace has 'cafe' in types
      expect(state.cafeCount, 1);
    });

    test('counts are zero when no venues', () {
      const state = NearbyVenuesState();
      expect(state.barCount, 0);
      expect(state.restaurantCount, 0);
      expect(state.cafeCount, 0);
    });

    // ---------------------------------------------------------------
    // Additional: NearbyVenuesState Equatable and copyWith tests
    // ---------------------------------------------------------------
    test('NearbyVenuesState supports value equality', () {
      const state1 = NearbyVenuesState();
      const state2 = NearbyVenuesState();
      expect(state1, equals(state2));
    });

    test('copyWith preserves existing values when no arguments given', () {
      final state = NearbyVenuesState(
        venues: testVenueResults,
        stadium: testStadium,
        isLoading: true,
        errorMessage: 'error',
        radiusMeters: 5000,
        selectedType: 'bar',
      );

      final copied = state.copyWith();
      expect(copied.venues, state.venues);
      expect(copied.stadium, state.stadium);
      expect(copied.isLoading, state.isLoading);
      expect(copied.errorMessage, state.errorMessage);
      expect(copied.radiusMeters, state.radiusMeters);
      expect(copied.selectedType, state.selectedType);
    });

    test('copyWith with clearError sets errorMessage to null', () {
      const state = NearbyVenuesState(
        errorMessage: 'Something went wrong',
      );

      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });
}
