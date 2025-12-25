import '../entities/place.dart';
import '../repositories/places_repository.dart';

class GetNearbyPlaces {
  final PlacesRepository repository;

  GetNearbyPlaces(this.repository);

  Future<List<Place>> call({
    required double latitude,
    required double longitude,
    double radius = 2000,
    List<String> types = const ['restaurant', 'bar'],
  }) async {
    return await repository.getNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      types: types,
    );
  }
} 