import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import '../../../../core/services/performance_monitor.dart'; // Import PerformanceMonitor
// Performance test utility removed
import '../../../../core/services/venue_recommendation_service.dart';
import '../widgets/enhanced_venue_card.dart';
import '../../../venues/screens/venue_map_screen.dart';
import '../../../venues/screens/venue_detail_screen.dart';
import '../../../schedule/presentation/widgets/enhanced_ai_insights_widget.dart';
import '../../../schedule/presentation/widgets/game_prediction_widget.dart';
import '../widgets/smart_venue_discovery_widget.dart';
import '../../../../core/services/user_learning_service.dart';
import '../../../../config/theme_helper.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../../config/api_keys.dart';

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
      // Using class members instead of local variables
      
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
        // Use a default location (you can customize this based on your needs)
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
        radius: (_currentFilter.maxDistance * 1000).toDouble(), // Convert km to meters as double
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

  /// Handle category filter change
  void _onCategorySelected(VenueCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  /// Handle sort option change
  void _onSortOptionChanged(VenueSortOption? option) {
    if (option != null) {
      setState(() {
        _sortOption = option;
      });
    }
  }

  void _showPerformanceStats() {
    final stats = PerformanceMonitor.getStats();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B), // Dark blue-gray to match app theme
          title: Text(
            '📊 Performance Dashboard',
            style: TextStyle(color: Colors.orange[300]),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Cache Hits', '${stats['cache_hits']}', Colors.green),
                _buildStatRow('Cache Misses', '${stats['cache_misses']}', Colors.red),
                _buildStatRow('Hit Rate', '${stats['cache_hit_rate']}%', Colors.blue),
                const SizedBox(height: 8),
                _buildStatRow('API Calls', '${stats['api_calls']}', Colors.orange),
                _buildStatRow('Avg Response', '${stats['average_api_time_ms']}ms', Colors.purple),
                _buildStatRow('Pending', '${stats['pending_calls']}', Colors.yellow),
                const SizedBox(height: 16),
                Text(
                  '🎯 Performance Grade',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPerformanceGrade(stats),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Performance test functionality removed
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Performance test feature has been removed for production.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: Text('Run Full Test', style: TextStyle(color: Colors.green[300])),
            ),
            TextButton(
              onPressed: () {
                PerformanceMonitor.printSummary();
                Navigator.of(context).pop();
              },
              child: Text('Print Summary', style: TextStyle(color: Colors.orange[300])),
            ),
            TextButton(
              onPressed: () {
                PerformanceMonitor.reset();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Performance stats reset')),
                );
              },
              child: Text('Reset', style: TextStyle(color: Colors.red[300])),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.orange[300])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrade(Map<String, dynamic> stats) {
    final hitRate = double.tryParse(stats['cache_hit_rate']) ?? 0.0;
    final avgTime = double.tryParse(stats['average_api_time_ms']) ?? 0.0;
    
    Color gradeColor = Colors.red;
    String gradeText = 'Needs Improvement';
    IconData gradeIcon = Icons.trending_down;
    
    if (hitRate >= 80 && avgTime <= 1000) {
      gradeColor = Colors.green;
      gradeText = 'Excellent 🚀';
      gradeIcon = Icons.trending_up;
    } else if (hitRate >= 60 && avgTime <= 2000) {
      gradeColor = Colors.orange;
      gradeText = 'Good 👍';
      gradeIcon = Icons.trending_flat;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gradeColor),
      ),
      child: Row(
        children: [
          Icon(gradeIcon, color: gradeColor),
          const SizedBox(width: 8),
          Text(
            gradeText,
            style: TextStyle(
              color: gradeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format game time using the existing structure
    String gameTime = 'Time TBD';
    if (widget.game.dateTimeUTC != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy h:mm a').format(widget.game.dateTimeUTC!.toLocal());
    } else if (widget.game.dateTime != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy h:mm a').format(widget.game.dateTime!);
    } else if (widget.game.day != null) {
      gameTime = DateFormat('EEE, MMM d, yyyy').format(widget.game.day!);
    }

    // Get venue info from stadium
    String venueInfo = widget.game.stadium?.name ?? 'Venue TBD';
    if (widget.game.stadium?.city != null && widget.game.stadium?.state != null) {
      venueInfo += ', ${widget.game.stadium!.city}, ${widget.game.stadium!.state}';
    }

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
        backgroundColor: ThemeHelper.primaryColor(context), // Consistent primary color
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
                Container(
                  decoration: AppTheme.cardGradientDecoration,
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeHelper.favoriteColor, // Orange title
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Teams Row with Logos
                          Row(
                            children: [
                              // Away Team with Logo
                              Expanded(
                                child: Row(
                                  children: [
                                    TeamLogoHelper.getTeamLogoWidget(
                                      teamName: widget.game.awayTeamName,
                                      size: 28,
                                      fallbackColor: Colors.white70,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.game.awayTeamName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // @ indicator
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.sports_football, 
                                  color: ThemeHelper.favoriteColor, 
                                  size: 24
                                ),
                              ),
                              
                              // Home Team with Logo
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.game.homeTeamName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    TeamLogoHelper.getTeamLogoWidget(
                                      teamName: widget.game.homeTeamName,
                                      size: 28,
                                      fallbackColor: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Icon(Icons.access_time, color: ThemeHelper.favoriteColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  gameTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: ThemeHelper.favoriteColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  venueInfo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.game.week != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: ThemeHelper.favoriteColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Week ${widget.game.week}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (widget.game.channel != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.tv, color: ThemeHelper.favoriteColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'TV: ${widget.game.channel}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              
                const SizedBox(height: 16),
                
                // Enhanced AI Game Analysis - Summary View
                EnhancedAIInsightsWidget(
                  game: widget.game,
                  isCompact: true, // Show condensed summary in game details
                ),
                
                // Game Predictions
                GamePredictionWidget(
                  game: widget.game,
                  onPredictionMade: () {
                    // Optional: Refresh insights or show success message
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Venues section placeholder
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Dark blue-gray background to match app theme
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, color: ThemeHelper.favoriteColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Venue Discovery',
                                style: ThemeHelper.h3(context, color: ThemeHelper.favoriteColor),
                              ),
                            ),
                            if (_nearbyPlaces != null && _nearbyPlaces!.isNotEmpty) ...[
                              // Map View Button
                              GestureDetector(
                                onTap: () => _openMapView(),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA580C), // Warm orange from app theme
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Map View',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Venue Count Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[300]!.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange[300]!),
                                ),
                                child: Text(
                                  '${_nearbyPlaces!.length} found',
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find sports bars, restaurants, and venues near the stadium with smart filtering and recommendations.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPlacesSection(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Team Information Card
                Container(
                  decoration: ThemeHelper.cardDecoration(context, elevated: true),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teams',
                          style: ThemeHelper.h3(context, color: ThemeHelper.favoriteColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.sports_football,
                                    size: 48,
                                    color: Colors.white70, // Light white icon
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.game.awayTeamName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // White text
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Away',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70, // Light white text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 80,
                              color: Colors.white30, // Light divider for dark background
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.home,
                                    size: 48,
                                    color: Colors.orange[300], // Orange for home team
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.game.homeTeamName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // White text
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Home',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70, // Light white text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesSection() {
    if (_isLoadingPlaces) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_placesError != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF334155), // Dark blue-gray for info box
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF6B35)), // Vibrant orange border
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFFF6B35), // Vibrant orange icon
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  _placesError!,
                  style: const TextStyle(
                    color: Colors.white, // White text
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This feature will help you find restaurants, bars, hotels, and other venues near the game location.',
                  style: TextStyle(
                    color: Colors.white70, // Light white text
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_nearbyPlaces == null || _nearbyPlaces!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No nearby venues found.',
          style: TextStyle(
            color: Colors.white70, // Light white text
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final displayVenues = _getDisplayVenues();
    final filterCounts = VenueRecommendationService.getFilterCounts(_nearbyPlaces!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Stats Row
        _buildQuickStats(filterCounts),
        
        const SizedBox(height: 16),
        
        // Smart Venue Discovery
        SmartVenueDiscoveryWidget(
          venues: _nearbyPlaces!,
          game: widget.game,
          context: _getVenueContext(),
          onVenueSelected: (venue) => _navigateToVenueDetail(venue),
        ),
        
        const SizedBox(height: 16),
        
        // Category Filter Chips
        VenueCategoryFilterChips(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          venues: _nearbyPlaces!,
        ),
        
        const SizedBox(height: 16),
        
        // Sort Options Row
        _buildSortOptions(),
        
        const SizedBox(height: 16),
        
        // Popular Venues Section (if not filtered by category)
        if (_selectedCategory == null && _sortOption == VenueSortOption.distance) ...[
          _buildPopularVenuesSection(),
          const SizedBox(height: 16),
        ],
        
        // Results Count
        Text(
          '${displayVenues.length} venues found',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Venue List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayVenues.length,
          itemBuilder: (context, index) {
            final venue = displayVenues[index];
            return EnhancedVenueCard(
              venue: venue,
              stadiumLat: _stadiumLatitude,
              stadiumLng: _stadiumLongitude,
              onTap: () => _navigateToVenueDetail(venue),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray for quick stats
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF475569)), // Lighter blue-gray border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🔥', '${stats['popular']}', 'Popular'),
          _buildStatItem('⭐', '${stats['highly_rated']}', '4.0+ Rating'),
          _buildStatItem('🕒', '${stats['open_now']}', 'Open Now'),
          _buildStatItem('🏈', '${stats['sports_bars']}', 'Sports Bars'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String count, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: VenueSortOption.values.map((option) {
          final isSelected = _sortOption == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, size: 16, color: isSelected ? Colors.white : ThemeHelper.textSecondaryColor(context)),
                  const SizedBox(width: 4),
                  Text(
                    option.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : ThemeHelper.textSecondaryColor(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onPressed: () => _onSortOptionChanged(option),
              backgroundColor: isSelected ? ThemeHelper.favoriteColor : ThemeHelper.backgroundColor(context),
              elevation: isSelected ? 4 : 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularVenuesSection() {
    final popularVenues = VenueRecommendationService.getPopularVenues(_nearbyPlaces!, limit: 5);
    
    if (popularVenues.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Popular Near Stadium',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularVenues.length,
            itemBuilder: (context, index) {
              final venue = popularVenues[index];
              return SizedBox(
                width: 280,
                child: EnhancedVenueCard(
                  venue: venue,
                  stadiumLat: _stadiumLatitude,
                  stadiumLng: _stadiumLongitude,
                  onTap: () => _navigateToVenueDetail(venue),
                ),
              );
            },
          ),
        ),
      ],
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