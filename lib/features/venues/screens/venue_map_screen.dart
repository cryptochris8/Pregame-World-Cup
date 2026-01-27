import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../widgets/venue_map_info_card.dart';
import '../widgets/venue_route_panel.dart';
import '../screens/venue_detail_screen.dart';

class VenueMapScreen extends StatefulWidget {
  final List<Place> venues;
  final LatLng? stadiumLocation;
  final String? gameLocation;
  final String? apiKey;
  
  const VenueMapScreen({
    super.key,
    required this.venues,
    this.stadiumLocation,
    this.gameLocation,
    this.apiKey,
  });

  @override
  State<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends State<VenueMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLngBounds? _mapBounds;
  
  // Map state
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  
  // UI state
  Place? _selectedVenue;
  bool _showDistanceRings = false;
  bool _showRoutePanel = false;
  VenueCategory? _selectedCategory;
  
  // Animation controllers
  late AnimationController _panelController;
  late AnimationController _markerController;
  
  // Filter state
  List<Place> _filteredVenues = [];

  @override
  void initState() {
    super.initState();
    
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _markerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _filteredVenues = widget.venues;
    _initializeMap();
  }

  @override
  void dispose() {
    _panelController.dispose();
    _markerController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() {
    _createMarkers();
    _createDistanceRings();
    _calculateMapBounds();
  }

  void _createMarkers() {
    final Set<Marker> markers = {};
    
    // Add stadium marker if available
    if (widget.stadiumLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('stadium'),
        position: widget.stadiumLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Stadium',
          snippet: widget.gameLocation ?? 'Game Location',
        ),
        onTap: () => _onStadiumTap(),
      ));
    }
    
    // Add venue markers
    for (final venue in _filteredVenues) {
      final lat = venue.latitude ?? venue.geometry?.location?.lat;
      final lng = venue.longitude ?? venue.geometry?.location?.lng;
      
      if (lat != null && lng != null) {
        final category = VenueRecommendationService.categorizeVenue(venue);
        final isPopular = VenueRecommendationService.isPopular(venue);
        
        markers.add(Marker(
          markerId: MarkerId(venue.placeId ?? venue.name),
          position: LatLng(lat, lng),
          icon: _getMarkerIcon(category, isPopular),
          infoWindow: InfoWindow(
            title: venue.name,
            snippet: _getMarkerSnippet(venue, category),
          ),
          onTap: () => _onVenueTap(venue),
        ));
      }
    }
    
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  BitmapDescriptor _getMarkerIcon(VenueCategory category, bool isPopular) {
    // Color-code markers by category
    double hue;
    switch (category) {
      case VenueCategory.sportsBar:
        hue = BitmapDescriptor.hueGreen;
        break;
      case VenueCategory.restaurant:
        hue = BitmapDescriptor.hueOrange;
        break;
      case VenueCategory.brewery:
        hue = BitmapDescriptor.hueYellow;
        break;
      case VenueCategory.cafe:
        hue = BitmapDescriptor.hueBlue;
        break;
      case VenueCategory.nightclub:
        hue = BitmapDescriptor.hueMagenta;
        break;
      case VenueCategory.fastFood:
        hue = BitmapDescriptor.hueRose;
        break;
      case VenueCategory.fineDining:
        hue = BitmapDescriptor.hueViolet;
        break;
      default:
        hue = BitmapDescriptor.hueAzure;
    }
    
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  String _getMarkerSnippet(Place venue, VenueCategory category) {
    final List<String> snippetParts = [];
    
    snippetParts.add(category.displayName);
    
    if (venue.rating != null) {
      snippetParts.add('⭐ ${venue.rating!.toStringAsFixed(1)}');
    }
    
    if (venue.priceLevel != null && venue.priceLevel! > 0) {
      snippetParts.add('\$' * venue.priceLevel!);
    }
    
    // Add walking distance if stadium location is available
    if (widget.stadiumLocation != null) {
      final lat = venue.latitude ?? venue.geometry?.location?.lat;
      final lng = venue.longitude ?? venue.geometry?.location?.lng;
      
      if (lat != null && lng != null) {
        final distance = VenueRecommendationService.calculateWalkingDistance(
          widget.stadiumLocation!.latitude,
          widget.stadiumLocation!.longitude,
          lat,
          lng,
        );
        final walkTime = VenueRecommendationService.estimateWalkingTime(distance);
        snippetParts.add('🚶 ${VenueRecommendationService.formatWalkingTime(walkTime)}');
      }
    }
    
    return snippetParts.join(' • ');
  }

  void _createDistanceRings() {
    if (!_showDistanceRings || widget.stadiumLocation == null) {
          if (mounted) {
      setState(() {
        _circles = {};
      });
    }
      return;
    }
    
    final Set<Circle> circles = {};
    final List<double> distances = [0.5, 1.0, 1.5, 2.0]; // km
    final List<Color> colors = [
      Colors.green.withOpacity(0.1),
      Colors.orange.withOpacity(0.1),
      Colors.red.withOpacity(0.1),
      Colors.purple.withOpacity(0.1),
    ];
    
    for (int i = 0; i < distances.length; i++) {
      circles.add(Circle(
        circleId: CircleId('ring_$i'),
        center: widget.stadiumLocation!,
        radius: distances[i] * 1000, // Convert km to meters
        strokeColor: colors[i].withOpacity(0.5),
        strokeWidth: 2,
        fillColor: colors[i],
      ));
    }
    
    if (mounted) {
      setState(() {
        _circles = circles;
      });
    }
  }

  void _calculateMapBounds() {
    if (_filteredVenues.isEmpty) return;
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    // Include stadium in bounds
    if (widget.stadiumLocation != null) {
      minLat = math.min(minLat, widget.stadiumLocation!.latitude);
      maxLat = math.max(maxLat, widget.stadiumLocation!.latitude);
      minLng = math.min(minLng, widget.stadiumLocation!.longitude);
      maxLng = math.max(maxLng, widget.stadiumLocation!.longitude);
    }
    
    // Include all venue locations
    for (final venue in _filteredVenues) {
      final lat = venue.latitude ?? venue.geometry?.location?.lat;
      final lng = venue.longitude ?? venue.geometry?.location?.lng;
      
      if (lat != null && lng != null) {
        minLat = math.min(minLat, lat);
        maxLat = math.max(maxLat, lat);
        minLng = math.min(minLng, lng);
        maxLng = math.max(maxLng, lng);
      }
    }
    
    if (minLat != double.infinity) {
      _mapBounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.stadiumLocation ?? const LatLng(33.9519, -83.3576), // Default to Athens, GA
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) => _onMapTap(),
          ),
          
          // Top controls
          _buildTopControls(),
          
          // Venue info card (when venue selected)
          if (_selectedVenue != null)
            _buildVenueInfoCard(),
          
          // Route panel (when showing route)
          if (_showRoutePanel)
            _buildRoutePanel(),
          
          // Bottom controls
          _buildBottomControls(),
          
          // Floating action buttons
          _buildFloatingActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with back button and title
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF2D1810),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Venue Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1810),
                          ),
                        ),
                        Text(
                          '${_filteredVenues.length} venues found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Category filter chips
            _buildCategoryFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(null, 'All', _filteredVenues.length),
          const SizedBox(width: 8),
          ...VenueCategory.values.where((cat) => cat != VenueCategory.unknown).map((category) {
            final count = widget.venues.where((venue) => 
                VenueRecommendationService.categorizeVenue(venue) == category).length;
            
            if (count == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(category, category.displayName, count),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(VenueCategory? category, String label, int count) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () => _onCategoryFilter(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFEA580C) // Warm orange from app theme
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFEA580C) // Warm orange from app theme
                : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueInfoCard() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: VenueMapInfoCard(
        venue: _selectedVenue!,
        onDetailsPressed: () => _navigateToVenueDetails(_selectedVenue!),
        onDirectionsPressed: () => _showDirectionsToVenue(_selectedVenue!),
        onCallPressed: () => _callVenue(_selectedVenue!),
        onClose: () => setState(() => _selectedVenue = null),
      ),
    );
  }

  Widget _buildRoutePanel() {
    return VenueRoutePanel(
      venue: _selectedVenue!,
      stadiumLocation: widget.stadiumLocation,
      onClose: () => setState(() => _showRoutePanel = false),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.layers,
            label: 'Rings',
            isActive: _showDistanceRings,
            onPressed: () => _toggleDistanceRings(),
          ),
          _buildControlButton(
            icon: Icons.list,
            label: 'List View',
            onPressed: () => Navigator.of(context).pop(),
          ),
          _buildControlButton(
            icon: Icons.my_location,
            label: 'My Location',
            onPressed: () => _goToMyLocation(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEA580C) : Colors.white, // Warm orange from app theme
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF2D1810),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 200,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "venue_map_zoom_fab",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1810),
            onPressed: () => _zoomToFitAllMarkers(),
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "venue_map_stadium_fab",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1810),
            onPressed: () => _focusOnStadium(),
            child: const Icon(Icons.stadium),
          ),
        ],
      ),
    );
  }

  // Event handlers and helper methods
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _zoomToFitAllMarkers();
  }

  void _onMapTap() {
    setState(() {
      _selectedVenue = null;
      _showRoutePanel = false;
    });
  }

  void _onVenueTap(Place venue) {
    setState(() {
      _selectedVenue = venue;
      _showRoutePanel = false;
    });
  }

  void _onStadiumTap() {
    // Show stadium info or options
  }

  void _onCategoryFilter(VenueCategory? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredVenues = widget.venues;
      } else {
        _filteredVenues = widget.venues.where((venue) => 
            VenueRecommendationService.categorizeVenue(venue) == category).toList();
      }
    });
    
    _createMarkers();
    _calculateMapBounds();
    _zoomToFitAllMarkers();
  }

  void _toggleDistanceRings() {
    setState(() {
      _showDistanceRings = !_showDistanceRings;
    });
    _createDistanceRings();
  }

  void _zoomToFitAllMarkers() {
    if (_mapBounds != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_mapBounds!, 50.0),
      );
    }
  }

  void _focusOnStadium() {
    if (widget.stadiumLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(widget.stadiumLocation!, 16.0),
      );
    }
  }

  void _goToMyLocation() async {
    // Implementation for getting current location
    // Debug output removed
  }

  void _navigateToVenueDetails(Place venue) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venue: venue,
          gameLocation: widget.gameLocation,
          apiKey: widget.apiKey,
        ),
      ),
    );
  }

  void _showDirectionsToVenue(Place venue) {
    setState(() {
      _showRoutePanel = true;
    });
  }

  void _callVenue(Place venue) {
    // Debug output removed
  }
} 
