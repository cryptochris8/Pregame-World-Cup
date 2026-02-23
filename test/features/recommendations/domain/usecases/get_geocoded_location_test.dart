import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/domain/repositories/places_repository.dart';
import 'package:pregame_world_cup/features/recommendations/domain/usecases/get_geocoded_location.dart';

// ==================== MOCKS ====================

class MockPlacesRepository extends Mock implements PlacesRepository {}

// ==================== TESTS ====================

void main() {
  late MockPlacesRepository mockRepository;
  late GetGeocodedLocation useCase;

  setUp(() {
    mockRepository = MockPlacesRepository();
    useCase = GetGeocodedLocation(mockRepository);
  });

  group('GetGeocodedLocation', () {
    test('calls repository with correct address', () async {
      when(() => mockRepository.geocodeAddress(
            address: any(named: 'address'),
          )).thenAnswer((_) async => {
            'latitude': 40.7128,
            'longitude': -74.0060,
          });

      await useCase(address: 'MetLife Stadium, NJ');

      verify(() => mockRepository.geocodeAddress(
            address: 'MetLife Stadium, NJ',
          )).called(1);
    });

    test('returns coordinates from repository', () async {
      when(() => mockRepository.geocodeAddress(
            address: any(named: 'address'),
          )).thenAnswer((_) async => {
            'latitude': 40.8135,
            'longitude': -74.0745,
          });

      final result = await useCase(address: 'MetLife Stadium, NJ');

      expect(result['latitude'], equals(40.8135));
      expect(result['longitude'], equals(-74.0745));
    });

    test('returns correct coordinates for different addresses', () async {
      when(() => mockRepository.geocodeAddress(
            address: 'SoFi Stadium, CA',
          )).thenAnswer((_) async => {
            'latitude': 33.9534,
            'longitude': -118.3387,
          });

      final result = await useCase(address: 'SoFi Stadium, CA');

      expect(result['latitude'], equals(33.9534));
      expect(result['longitude'], equals(-118.3387));
    });

    test('propagates exceptions from repository', () async {
      when(() => mockRepository.geocodeAddress(
            address: any(named: 'address'),
          )).thenThrow(Exception('Address not found'));

      expect(
        () => useCase(address: 'Nonexistent Location'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles empty address', () async {
      when(() => mockRepository.geocodeAddress(
            address: '',
          )).thenThrow(Exception('Address cannot be empty'));

      expect(
        () => useCase(address: ''),
        throwsA(isA<Exception>()),
      );
    });

    test('result map contains latitude and longitude keys', () async {
      when(() => mockRepository.geocodeAddress(
            address: any(named: 'address'),
          )).thenAnswer((_) async => {
            'latitude': 25.7617,
            'longitude': -80.1918,
          });

      final result = await useCase(address: 'Hard Rock Stadium, Miami');

      expect(result.containsKey('latitude'), isTrue);
      expect(result.containsKey('longitude'), isTrue);
      expect(result.length, equals(2));
    });
  });
}
