import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/recommendations/domain/repositories/places_repository.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_nearby_places.dart';

// ==================== MOCKS ====================

class MockPlacesRepository extends Mock implements PlacesRepository {}

// ==================== TESTS ====================

void main() {
  late MockPlacesRepository mockRepository;
  late GetNearbyPlaces useCase;

  setUp(() {
    mockRepository = MockPlacesRepository();
    useCase = GetNearbyPlaces(mockRepository);
  });

  group('GetNearbyPlaces', () {
    const testLat = 40.7128;
    const testLng = -74.0060;

    final testPlaces = [
      const Place(
        placeId: 'place_1',
        name: 'Sports Bar A',
        rating: 4.5,
        latitude: 40.7130,
        longitude: -74.0055,
      ),
      const Place(
        placeId: 'place_2',
        name: 'Restaurant B',
        rating: 4.2,
        latitude: 40.7125,
        longitude: -74.0065,
      ),
    ];

    test('calls repository with correct parameters', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => testPlaces);

      await useCase(
        latitude: testLat,
        longitude: testLng,
        radius: 3000,
        types: ['bar', 'restaurant'],
      );

      verify(() => mockRepository.getNearbyPlaces(
            latitude: testLat,
            longitude: testLng,
            radius: 3000,
            types: ['bar', 'restaurant'],
          )).called(1);
    });

    test('returns list of places from repository', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => testPlaces);

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
      );

      expect(result, hasLength(2));
      expect(result[0].name, equals('Sports Bar A'));
      expect(result[1].name, equals('Restaurant B'));
    });

    test('returns empty list when no places found', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => []);

      final result = await useCase(
        latitude: testLat,
        longitude: testLng,
      );

      expect(result, isEmpty);
    });

    test('uses default radius of 2000 when not specified', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => []);

      await useCase(
        latitude: testLat,
        longitude: testLng,
      );

      verify(() => mockRepository.getNearbyPlaces(
            latitude: testLat,
            longitude: testLng,
            radius: 2000,
            types: ['restaurant', 'bar'],
          )).called(1);
    });

    test('uses default types when not specified', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => []);

      await useCase(
        latitude: testLat,
        longitude: testLng,
      );

      verify(() => mockRepository.getNearbyPlaces(
            latitude: testLat,
            longitude: testLng,
            radius: 2000,
            types: ['restaurant', 'bar'],
          )).called(1);
    });

    test('propagates exceptions from repository', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenThrow(Exception('Network error'));

      expect(
        () => useCase(latitude: testLat, longitude: testLng),
        throwsA(isA<Exception>()),
      );
    });

    test('passes custom radius to repository', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => []);

      await useCase(
        latitude: testLat,
        longitude: testLng,
        radius: 5000,
      );

      verify(() => mockRepository.getNearbyPlaces(
            latitude: testLat,
            longitude: testLng,
            radius: 5000,
            types: ['restaurant', 'bar'],
          )).called(1);
    });

    test('passes custom types to repository', () async {
      when(() => mockRepository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => []);

      await useCase(
        latitude: testLat,
        longitude: testLng,
        types: ['cafe', 'nightclub'],
      );

      verify(() => mockRepository.getNearbyPlaces(
            latitude: testLat,
            longitude: testLng,
            radius: 2000,
            types: ['cafe', 'nightclub'],
          )).called(1);
    });
  });
}
