import '../repositories/places_repository.dart';

class GetGeocodedLocation {
  final PlacesRepository repository;

  GetGeocodedLocation(this.repository);

  Future<Map<String, double>> call({
    required String address,
  }) async {
    return await repository.geocodeAddress(
      address: address,
    );
  }
} 