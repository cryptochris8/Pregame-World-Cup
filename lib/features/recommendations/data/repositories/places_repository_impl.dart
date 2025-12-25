import 'dart:convert';
import '../../domain/entities/place.dart';
import '../../domain/entities/venue_filter.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_api_datasource.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesApiDataSource remoteDataSource;
  final CacheService _cacheService = CacheService.instance;

  PlacesRepositoryImpl({required this.remoteDataSource});

  Future<bool> _hasInternetConnection() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radius = 2000,
    List<String> types = const ['restaurant', 'bar'],
  }) async {
    final cacheKey = 'venues_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}_${radius}_${types.join("_")}';
    
    try {
      // Check cache first
      final cachedData = await _cacheService.getCachedVenues(latitude, longitude, radius, types);
      if (cachedData != null) {
        PerformanceMonitor.recordCacheHit(cacheKey);
        LoggingService.info('Cache hit: Using cached venues for $latitude, $longitude', tag: 'PlacesRepo');
        final List<dynamic> cachedJson = jsonDecode(cachedData.venuesJson);
        return cachedJson.map((json) => Place.fromJson(json)).toList();
      }

      // Cache miss - need to fetch from API
      PerformanceMonitor.recordCacheMiss(cacheKey);

      // Check internet connection
      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        LoggingService.warning('No internet connection and no cached data available', tag: 'PlacesRepo');
        throw Exception('No internet connection and no cached data available');
      }

      LoggingService.info('Cache miss: Fetching venues from API for $latitude, $longitude', tag: 'PlacesRepo');
      
      // Track API call performance
      final apiCallId = 'venues_api_${DateTime.now().millisecondsSinceEpoch}';
      PerformanceMonitor.startApiCall(apiCallId);
      
      try {
        // Fetch from API
        final places = await remoteDataSource.fetchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          types: types,
        );

        PerformanceMonitor.endApiCall(apiCallId, success: true);

        // Cache the results
        final placesJson = jsonEncode(places.map((place) => place.toJson()).toList());
        await _cacheService.cacheVenues(latitude, longitude, radius, types, placesJson);
        
        LoggingService.info('Successfully cached ${places.length} venues', tag: 'PlacesRepo');
        return places;
      } catch (e) {
        PerformanceMonitor.endApiCall(apiCallId, success: false);
        rethrow;
      }
    } catch (e) {
      LoggingService.error('Error in getNearbyPlaces: $e', tag: 'PlacesRepo');
      
      // Try to return any available cached data as fallback
      final cachedData = await _cacheService.getCachedVenues(latitude, longitude, radius, types);
      if (cachedData != null) {
        LoggingService.info('Using expired cached data as fallback', tag: 'PlacesRepo');
        final List<dynamic> cachedJson = jsonDecode(cachedData.venuesJson);
        return cachedJson.map((json) => Place.fromJson(json)).toList();
      }
      
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getFilteredVenues({
    required double latitude,
    required double longitude,
    required VenueFilter filter,
  }) async {
    final apiCallId = 'filtered_venues_${DateTime.now().millisecondsSinceEpoch}';
    PerformanceMonitor.startApiCall(apiCallId);
    
    try {
      final places = await remoteDataSource.fetchFilteredVenues(
        lat: latitude,
        lng: longitude,
        radius: (filter.maxDistance * 1000).toInt(), // Convert km to meters
        types: filter.venueTypesToApi,
        minPrice: filter.priceLevel?.value,
        maxPrice: filter.priceLevel?.value,
        minRating: filter.minRating,
        openNow: filter.openNow,
      );
      
      PerformanceMonitor.endApiCall(apiCallId, success: true);
      return Right(places);
    } catch (e) {
      PerformanceMonitor.endApiCall(apiCallId, success: false);
      return Left(ServerFailure());
    }
  }

  @override
  Future<Map<String, double>> geocodeAddress({
    required String address,
  }) async {
    final cacheKey = 'geocoding_${address.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
    
    try {
      // Check cache first
      final cachedGeocode = await _cacheService.getCachedGeocodingData(address);
      if (cachedGeocode != null) {
        PerformanceMonitor.recordCacheHit(cacheKey);
        LoggingService.info('Cache hit: Using cached geocoding for "$address"', tag: 'PlacesRepo');
        return {
          'latitude': cachedGeocode.latitude,
          'longitude': cachedGeocode.longitude,
        };
      }

      // Cache miss - need to fetch from API
      PerformanceMonitor.recordCacheMiss(cacheKey);

      // Check internet connection
      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        LoggingService.warning('No internet connection and no cached geocoding data for "$address"', tag: 'PlacesRepo');
        throw Exception('No internet connection and no cached geocoding data available');
      }

      LoggingService.info('Cache miss: Geocoding address "$address" via API', tag: 'PlacesRepo');
      
      // Track API call performance
      final apiCallId = 'geocoding_api_${DateTime.now().millisecondsSinceEpoch}';
      PerformanceMonitor.startApiCall(apiCallId);
      
      try {
        // Fetch from API
        final result = await remoteDataSource.geocodeAddress(address: address);
        
        PerformanceMonitor.endApiCall(apiCallId, success: true);
        
        // Cache the results
        await _cacheService.cacheGeocodingData(
          address,
          result['latitude']!,
          result['longitude']!,
        );
        
        LoggingService.info('Successfully cached geocoding for "$address"', tag: 'PlacesRepo');
        return result;
      } catch (e) {
        PerformanceMonitor.endApiCall(apiCallId, success: false);
        rethrow;
      }
    } catch (e) {
      LoggingService.error('Error in geocodeAddress: $e', tag: 'PlacesRepo');
      
      // Try to return any available cached data as fallback
      final cachedGeocode = await _cacheService.getCachedGeocodingData(address);
      if (cachedGeocode != null) {
        LoggingService.info('Using expired cached geocoding data as fallback for "$address"', tag: 'PlacesRepo');
        return {
          'latitude': cachedGeocode.latitude,
          'longitude': cachedGeocode.longitude,
        };
      }
      
      rethrow;
    }
  }
} 