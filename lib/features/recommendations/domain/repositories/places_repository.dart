import '../../domain/entities/place.dart';
import '../entities/venue_filter.dart';
import 'package:dartz/dartz.dart';

// Define Failure abstract class for error handling
abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure() : super('Server error occurred');
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('Network error occurred');
}

abstract class PlacesRepository {
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radius = 2000,
    List<String> types = const ['restaurant', 'bar'],
  });
  
  Future<Either<Failure, List<Place>>> getFilteredVenues({
    required double latitude,
    required double longitude,
    required VenueFilter filter,
  });
  
  Future<Map<String, double>> geocodeAddress({
    required String address,
  });
} 