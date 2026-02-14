import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../schedule/domain/entities/game_schedule.dart'; // Path to your GameSchedule model
import '../../domain/entities/place.dart'; // Path to your Place model
import '../../domain/entities/venue_filter.dart'; // Import for venue filter
// Import new usecase
// Import filter screen
import '../../../../injection_container.dart' as di; // Import dependency injection
// Import for DioException handling
// Import geocoding usecase
import '../../domain/repositories/places_repository.dart'; // Import PlacesRepository
// Performance test utility removed
import '../../../../core/services/venue_recommendation_service.dart';
import '../widgets/game_info_card.dart';
import '../widgets/performance_stats_dialog.dart';
import '../widgets/venue_discovery_section.dart';
import '../widgets/teams_info_card.dart';
import '../../../venues/screens/venue_map_screen.dart';
import '../../../venues/screens/venue_detail_screen.dart';
import '../../../schedule/presentation/widgets/enhanced_ai_insights_widget.dart';
import '../../../schedule/presentation/widgets/game_prediction_widget.dart';
import '../../../../core/services/user_learning_service.dart';
import '../../../../config/theme_helper.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// Enhanced game details screen with venue discovery
///
/// CODEMAGIC BUILD FIX: All latitude references properly scoped
/// Last updated: 2025-01-26 - Fixed latitude getter error
class GameDetailsScreen extends StatefulWidget {
  final GameSchedule game;

  const GameDetailsScreen({super.key, required this.game});

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  List<Place>? _nearbyPlaces;
  bool _isLoadingPlaces = false;
  String? _placesError;
  final VenueFilter _currentFilter = const VenueFilter(); // Default filter
  bool _isOfflineMode = false; // Flag to indicate offline mode
  double? _fallbackLatitude;
  double? _fallbackLongitude;

  // Request deduplication
  bool _isRequestInProgress = false;
  String? _lastRequestKey;

  // Enhanced venue discovery features
  VenueCategory? _selectedCategory;
  VenueSortOption _sortOption = VenueSortOption.distance;
  double? _stadiumLatitude;
  double? _stadiumLongitude;

  // Current coordinates for venue loading
  double? _currentLatitude;
  double? _currentLongitude;

  // User learning service
  final UserLearningService _userLearningService = UserLearningService();
  late DateTime _screenStartTime;

  @override
  void initState() {
    super.initState();
    _screenStartTime = DateTime.now();
    _fetchVenues();

    // Track game view interaction
    _trackGameView();
  }

  @override
  void dispose() {
    // Track viewing duration when user leaves the screen
    _trackViewingDuration();
    super.dispose();
  }

  /// Track game view interaction
  void _trackGameView() {
    _userLearningService.trackGameInteraction(
      gameId: widget.game.gameId,
      interactionType: 'view',
      homeTeam: widget.game.homeTeamName,
      awayTeam: widget.game.awayTeamName,
      additionalData: {
        'stadium': widget.game.stadium?.name,
        'venue_search': true,
        'screen': 'game_details',
      },
    );
  }

  /// Track viewing duration when user leaves
  void _trackViewingDuration() {
    final duration = DateTime.now().difference(_screenStartTime);
    _userLearningService.trackGameInteraction(
      gameId: widget.game.gameId,
      interactionType: 'view_duration',
      homeTeam: widget.game.homeTeamName,
      awayTeam: widget.game.awayTeamName,
      durationSeconds: duration.inSeconds,
      additionalData: {
        'screen': 'game_details',
        'duration_minutes': (duration.inSeconds / 60).round(),
      },
    );
  }

  /// Get venue context based on game timing
  String _getVenueContext() {
    final now = DateTime.now();
    final gameTime = widget.game.dateTime ?? DateTime.now();

    // If game is in the past
    if (gameTime.isBefore(now)) {
      return 'post_game';
    }

    // If game is within the next 6 hours
    final timeDifference = gameTime.difference(now);
    if (timeDifference.inHours <= 6) {
      return 'pre_game';
    }

    // Otherwise, general exploration
    return 'exploration';
  }

  Future<void> _launchMapsUrl(double? lat, double? lng, String? placeName, String? vicinity) async {
    if (lat == null || lng == null) {
      // Try to launch with name and address if lat/lng are missing
      if (placeName != null && vicinity != null) {
        final query = Uri.encodeComponent('$placeName, $vicinity');
        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open map for this location.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location data not available to open map.')),
          );
        }
      }
      return;
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map for this location.')),
        );
      }
    }
  }

  String _generateRequestKey() {
    final stadiumName = widget.game.stadium?.name ?? '';
    final stadiumCity = widget.game.stadium?.city ?? '';
    final stadiumState = widget.game.stadium?.state ?? '';
    final filterTypes = _currentFilter.venueTypesToApi.join('_');
    final maxDistance = _currentFilter.maxDistance.toString();

    return '${stadiumName}_${stadiumCity}_${stadiumState}_${filterTypes}_$maxDistance';
  }

  // Method to fetch venues with the current filter
  Future<void> _fetchVenues() async {
    // Generate request key for deduplication
    final requestKey = _generateRequestKey();

    // Check if same request is already in progress
    if (_isRequestInProgress && _lastRequestKey == requestKey) {
      return;
    }

    // Check if we recently loaded the same data
    if (_lastRequestKey == requestKey && _nearbyPlaces != null && !_isLoadingPlaces) {
      return;
    }

    _isRequestInProgress = true;
    _lastRequestKey = requestKey;

    if (mounted) {
      setState(() {
        _isLoadingPlaces = true;
        _placesError = null;
      });
    }

    try {
      // Get the places repository from dependency injection
      final placesRepository = di.sl<PlacesRepository>();

      // First, try to get coordinates from the game's stadium

      // Check if stadium already has coordinates
      if (widget.game.stadium?.geoLat != null && widget.game.stadium?.geoLong != null) {
        _currentLatitude = widget.game.stadium!.geoLat!;
        _currentLongitude = widget.game.stadium!.geoLong!;
      } else if (widget.game.stadium?.name != null) {
        try {
          // Try to geocode the stadium address as fallback
          String address = widget.game.stadium!.name!;
          if (widget.game.stadium?.city != null && widget.game.stadium?.state != null) {
            address += ', ${widget.game.stadium!.city}, ${widget.game.stadium!.state}';
          }

          final coordinates = await placesRepository.geocodeAddress(address: address);
          _currentLatitude = coordinates['latitude'];
          _currentLongitude = coordinates['longitude'];
        } catch (e) {
          // Geocoding failed, will use fallback coordinates
        }
      }

      // If no stadium coordinates found, use fallback coordinates
      if (_currentLatitude == null || _currentLongitude == null) {
        _currentLatitude = _fallbackLatitude ?? 40.8128; // Default: MetLife Stadium area
        _currentLongitude = _fallbackLongitude ?? -74.0742;

        if (mounted) {
          setState(() {
            _isOfflineMode = true;
          });
        }
      }

      // Fetch nearby places using the current filter
      final places = await placesRepository.getNearbyPlaces(
        latitude: _currentLatitude!,
        longitude: _currentLongitude!,
        radius: (_currentFilter.maxDistance * 1000).toDouble(),
        types: _currentFilter.venueTypesToApi,
      );

      // Filter places based on additional criteria
      List<Place> filteredPlaces = places;

      if (_currentFilter.minRating != null) {
        filteredPlaces = filteredPlaces.where((place) =>
          place.rating != null && place.rating! >= _currentFilter.minRating!
        ).toList();
      }

      if (_currentFilter.openNow) {
        filteredPlaces = filteredPlaces.where((place) =>
          place.openingHours?.openNow == true
        ).toList();
      }

      if (_currentFilter.keyword != null && _currentFilter.keyword!.isNotEmpty) {
        final keyword = _currentFilter.keyword!.toLowerCase();
        filteredPlaces = filteredPlaces.where((place) =>
          place.name.toLowerCase().contains(keyword) ||
          (place.vicinity?.toLowerCase().contains(keyword) ?? false) ||
          (place.types?.any((type) => type.toLowerCase().contains(keyword)) ?? false)
        ).toList();
      }

      // Store stadium coordinates for distance calculations
      _stadiumLatitude = _currentLatitude;
      _stadiumLongitude = _currentLongitude;

      if (mounted) {
        setState(() {
          _nearbyPlaces = filteredPlaces;
          _isLoadingPlaces = false;
          _placesError = null;
          _isOfflineMode = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
          _placesError = 'Failed to load nearby venues. ${e.toString().contains('connection') ? 'Please check your internet connection.' : ''}';
        });
      }
    } finally {
      _isRequestInProgress = false;
    }
  }

  /// Get filtered and sorted venues for display
  List<Place> _getDisplayVenues() {
    if (_nearbyPlaces == null) return [];

    List<Place> venues = _nearbyPlaces!;

    // Filter by category if selected
    if (_selectedCategory != null) {
      venues = VenueRecommendationService.getVenuesByCategory(venues, _selectedCategory!);
    }

    // Sort venues by selected option
    venues = VenueRecommendationService.sortVenues(
      venues,
      _sortOption,
      fromLat: _stadiumLatitude,
      fromLng: _stadiumLongitude
    );

    return venues;
  }

  void _showPerformanceStats() {
    PerformanceStatsDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep dark background
      appBar: AppBar(
        title: Row(
          children: [
            TeamLogoHelper.getPregameLogo(height: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.game.awayTeamName} @ ${widget.game.homeTeamName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: ThemeHelper.primaryColor(context),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppTheme.backgroundCard,
          onRefresh: _fetchVenues,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Information Card
                GameInfoCard(game: widget.game),

                const SizedBox(height: 16),

                // Enhanced AI Game Analysis - Summary View
                EnhancedAIInsightsWidget(
                  game: widget.game,
                  isCompact: true,
                ),

                // Game Predictions
                GamePredictionWidget(
                  game: widget.game,
                  onPredictionMade: () {
                    // Optional: Refresh insights or show success message
                  },
                ),

                const SizedBox(height: 24),

                // Venue Discovery Section
                VenueDiscoverySection(
                  nearbyPlaces: _nearbyPlaces,
                  isLoadingPlaces: _isLoadingPlaces,
                  placesError: _placesError,
                  selectedCategory: _selectedCategory,
                  sortOption: _sortOption,
                  stadiumLatitude: _stadiumLatitude,
                  stadiumLongitude: _stadiumLongitude,
                  game: widget.game,
                  venueContext: _getVenueContext(),
                  onOpenMapView: _openMapView,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onSortOptionChanged: (option) {
                    if (option != null) {
                      setState(() {
                        _sortOption = option;
                      });
                    }
                  },
                  onVenueSelected: (venue) => _navigateToVenueDetail(venue),
                  getDisplayVenues: _getDisplayVenues,
                ),

                const SizedBox(height: 24),

                // Team Information Card
                TeamsInfoCard(
                  awayTeamName: widget.game.awayTeamName,
                  homeTeamName: widget.game.homeTeamName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMapView() {
    if (_nearbyPlaces == null || _nearbyPlaces!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No venues available to show on map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Determine stadium location
    LatLng? stadiumLocation;
    String? gameLocation;

    if (_stadiumLatitude != null && _stadiumLongitude != null) {
      stadiumLocation = LatLng(_stadiumLatitude!, _stadiumLongitude!);
      gameLocation = widget.game.stadium?.name ?? widget.game.stadium?.city ?? 'Game Location';
    } else if (_nearbyPlaces!.isNotEmpty) {
      // Fallback to first venue location if stadium location not available
      final firstVenue = _nearbyPlaces!.first;
      final lat = firstVenue.latitude ?? firstVenue.geometry?.location?.lat;
      final lng = firstVenue.longitude ?? firstVenue.geometry?.location?.lng;

      if (lat != null && lng != null) {
        stadiumLocation = LatLng(lat, lng);
        gameLocation = 'Near ${firstVenue.name}';
      }
    }

    if (stadiumLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location data not available for map view'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to map screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueMapScreen(
          venues: _nearbyPlaces!,
          stadiumLocation: stadiumLocation,
          gameLocation: gameLocation,
        ),
      ),
    );
  }

  void _navigateToVenueDetail(Place venue) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venue: venue,
          gameLocation: widget.game.stadium?.name ?? widget.game.stadium?.city,
        ),
      ),
    );
  }
}
