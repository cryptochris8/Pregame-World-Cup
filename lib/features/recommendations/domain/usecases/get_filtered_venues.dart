import '../entities/place.dart';
import '../entities/venue_filter.dart';
import '../repositories/places_repository.dart';
import 'package:dartz/dartz.dart';

class GetFilteredVenues {
  final PlacesRepository repository;

  GetFilteredVenues(this.repository);

  Future<Either<Failure, List<Place>>> call({
    required double latitude,
    required double longitude,
    required VenueFilter filter,
  }) async {
    return await repository.getFilteredVenues(
      latitude: latitude,
      longitude: longitude,
      filter: filter,
    );
  }
} 