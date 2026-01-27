import '../../domain/entities/place.dart'; // Corrected import path
import 'package:dio/dio.dart';
import '../../../../injection_container.dart'; // For Dio instance
import '../../../../config/api_keys.dart'; // For centralized API configuration
import '../../../../core/services/logging_service.dart';


/// Data source for fetching places data from Google Places API
class PlacesApiDataSource {
  final String _googleApiKey;
  final Dio _dio;
  
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  static const String _placesBaseUrl = '$_baseUrl/place/nearbysearch/json';
  static const String _geocodingBaseUrl = '$_baseUrl/geocode/json';
  static const String _cloudFunctionBaseUrl = 'https://us-central1-pregame-b089e.cloudfunctions.net';
  
  PlacesApiDataSource({required String googleApiKey}) 
    : _googleApiKey = googleApiKey,
      _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
    
  }

  /// Get nearby places using direct Google Places API
  Future<List<Place>> getNearbyPlacesDirect({
    required double latitude,
    required double longitude,
    required double radius,
    required List<String> types,
  }) async {
    try {
      // Prepare the URL and parameters
      final typesQuery = types.isNotEmpty ? types.first : 'restaurant'; // Use first type or default
      
      final queryParameters = {
        'location': '$latitude,$longitude',
        'radius': radius.toInt(),
        'type': typesQuery,
        'key': _googleApiKey,
      };
      
      final response = await _dio.get(_placesBaseUrl, queryParameters: queryParameters);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check for API-specific errors
        if (data['status'] != 'OK') {
          final status = data['status'];
          final errorMessage = data['error_message'] ?? 'Unknown API error';

          // Provide specific error messages based on status
          switch (status) {
            case 'REQUEST_DENIED':
              throw Exception('Google Places API request denied. Please check your API key and ensure Places API is enabled. Error: $errorMessage');
            case 'OVER_QUERY_LIMIT':
              throw Exception('Google Places API quota exceeded. Please check your billing account or wait for quota reset.');
            case 'ZERO_RESULTS':
              return [];
            case 'INVALID_REQUEST':
              throw Exception('Invalid request to Google Places API. Error: $errorMessage');
            default:
              throw Exception('Google Places API error ($status): $errorMessage');
          }
        }
        
        final results = data['results'] as List<dynamic>? ?? [];

        // Convert API response to Place objects
        final places = results.map<Place?>((json) {
          try {
            return Place.fromJson(json);
          } catch (e) {
            return null;
          }
        }).where((place) => place != null).cast<Place>().toList();

        return places;
      } else {
        throw Exception('Failed to fetch places: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please try again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Google Places API access forbidden. Please check your API key and billing account.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Geocode an address to get coordinates using Google Geocoding API
  Future<Map<String, double>> geocodeAddress({
    required String address,
  }) async {
    try {
      final queryParameters = {
        'address': address,
        'key': _googleApiKey,
      };

      final response = await _dio.get(
        _geocodingBaseUrl,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check for API-specific errors
        if (data['status'] != 'OK') {
          final status = data['status'];
          final errorMessage = data['error_message'] ?? 'Unknown API error';

          switch (status) {
            case 'REQUEST_DENIED':
              throw Exception('Google Geocoding API request denied. Please check your API key.');
            case 'OVER_QUERY_LIMIT':
              throw Exception('Google Geocoding API quota exceeded.');
            case 'ZERO_RESULTS':
              throw Exception('Address not found: $address');
            default:
              throw Exception('Geocoding API error ($status): $errorMessage');
          }
        }
        
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) {
          throw Exception('No results found for address: $address');
        }
        
        final location = results.first['geometry']['location'];
        final Map<String, double> coordinates = {
          'latitude': location['lat'].toDouble(),
          'longitude': location['lng'].toDouble(),
        };

        return coordinates;
      } else {
        throw Exception('Failed to geocode address: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error during geocoding: ${e.message}');
    } catch (e) {
      throw Exception('Geocoding failed: $e');
    }
  }

  /// Fetches nearby places (restaurants and bars) based on latitude and longitude.
  /// First tries the Cloud Function, then falls back to direct API calls.
  Future<List<Place>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    double radius = 2000, // Search radius in meters (e.g., 2km)
    List<String> types = const ['restaurant', 'bar'], // Default to restaurants and bars
  }) async {
    try {
      // First try using direct Google Places API
      final directPlaces = await getNearbyPlacesDirect(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        types: types,
      );
      
      return directPlaces;
    } catch (directApiError) {
      // Fall back to Cloud Function approach
      try {
        return await _fetchFromCloudFunction(latitude, longitude, radius, types);
      } catch (cloudFunctionError) {
        
        // If both fail, throw the more specific error from direct API
        throw Exception('Both direct API and Cloud Function failed. Last error: $directApiError');
      }
    }
  }

  /// Fallback method using Cloud Function
  Future<List<Place>> _fetchFromCloudFunction(
    double latitude,
    double longitude,
    double radius,
    List<String> types,
  ) async {
    // Construct query parameters
    final queryParameters = {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radius.toInt().toString(),
      'types': types.join('|'), // Cloud function expects pipe-separated for its logic
    };

    final String functionUrl = '$_cloudFunctionBaseUrl/getNearbyVenuesHttp';

    try {
      final response = await _dio.get(
        functionUrl,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> responseData = response.data;
        final List<Place> places = responseData.map((item) {
          // The Cloud Function should return data that matches Place.fromJson structure
          return Place.fromJson(item as Map<String, dynamic>);
        }).toList();
        return places;
      } else {
        throw Exception('Failed to fetch nearby places from Cloud Function. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cloud Function error: $e');
    }
  }

  /// Fetches venues based on filter options
  Future<List<Place>> fetchFilteredVenues({
    required double lat,
    required double lng,
    int radius = 2000,
    List<String> types = const ['bar', 'restaurant'],
    int? minPrice,
    int? maxPrice,
    double? minRating,
    bool? openNow,
  }) async {
    final String functionUrl = '$_cloudFunctionBaseUrl/getFilteredVenuesHttp';

    final Map<String, dynamic> queryParameters = {
      'lat': lat,
      'lng': lng,
      'radius': radius,
      'types': types.join('|'),
    };

    if (minPrice != null) queryParameters['minPrice'] = minPrice;
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice;
    if (minRating != null) queryParameters['minRating'] = minRating;
    if (openNow != null) queryParameters['openNow'] = openNow;

    try {
      LoggingService.info('Calling Filtered Venues Cloud Function: $functionUrl with params: $queryParameters', tag: 'PlacesAPI');
      final response = await _dio.get(
        functionUrl,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> responseData = response.data;
        final List<Place> places = responseData.map((item) {
          return Place.fromJson(item as Map<String, dynamic>);
        }).toList();
        LoggingService.info('Fetched ${places.length} filtered venues from Cloud Function.', tag: 'PlacesAPI');
        return places;
      } else if (response.statusCode == 404) {
        LoggingService.warning('Cloud Function not found (404). Falling back to direct Google Places API call.', tag: 'PlacesAPI');
        return await _fetchPlacesFromGoogleApi(lat, lng, radius, types, minPrice, maxPrice, minRating, openNow);
      } else {
        LoggingService.error('Unexpected response from Cloud Function: ${response.statusCode} - ${response.data}', tag: 'PlacesAPI');
        throw Exception('Unexpected response from Cloud Function: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('DioException calling fetchFilteredVenues Cloud Function: $e', tag: 'PlacesAPI');
      if (e is DioException && e.response?.statusCode == 404) {
                  LoggingService.warning('Cloud Function not found (404). Falling back to direct Google Places API call.', tag: 'PlacesAPI');
        return await _fetchPlacesFromGoogleApi(lat, lng, radius, types, minPrice, maxPrice, minRating, openNow);
      }
              LoggingService.error('Error in _fetchVenues: $e', tag: 'PlacesAPI');
      throw Exception('Network error: $e');
    }
  }

  Future<List<Place>> _fetchPlacesFromGoogleApi(
    double lat,
    double lng,
    int radius,
    List<String> types,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    bool? openNow,
  ) async {
    const String apiUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final Map<String, dynamic> queryParameters = {
      'location': '$lat,$lng',
      'radius': radius,
      'type': types.join('|'),
      'key': _googleApiKey,
    };

    if (openNow == true) {
      queryParameters['opennow'] = 'true';
    }

    try {
      final response = await _dio.get(apiUrl, queryParameters: queryParameters);
      if (response.statusCode == 200 && response.data['results'] != null) {
        final List<dynamic> results = response.data['results'];
        List<Place> places = results.map((json) => Place.fromJson(json)).toList();

        // Apply additional filters manually if provided
        if (minPrice != null) {
          places = places.where((place) => place.priceLevel != null && place.priceLevel! >= minPrice).toList();
        }
        if (maxPrice != null) {
          places = places.where((place) => place.priceLevel != null && place.priceLevel! <= maxPrice).toList();
        }
        if (minRating != null) {
          places = places.where((place) => place.rating != null && place.rating! >= minRating).toList();
        }

        LoggingService.info('Fetched ${places.length} places directly from Google Places API.', tag: 'PlacesAPI');
        return places;
      } else {
        LoggingService.error('Failed to fetch places from Google API: ${response.statusCode} - ${response.data}', tag: 'PlacesAPI');
        return [];
      }
    } catch (e) {
      LoggingService.error('Error fetching places from Google API: $e', tag: 'PlacesAPI');
      return [];
    }
  }

  // You might add other methods here later, like fetchPlaceDetails(String placeId)
} 