import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../widgets/venue_map_info_card.dart';
import '../widgets/venue_route_panel.dart';
import '../widgets/venue_map_top_controls.dart';
import '../widgets/venue_map_controls.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.stadiumLocation ?? const LatLng(33.9519, -83.3576),
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
          VenueMapTopControls(
            allVenues: widget.venues,
            filteredVenues: _filteredVenues,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategoryFilter,
          ),

          // Venue info card (when venue selected)
          if (_selectedVenue != null)
            Positioned(
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
            ),

          // Route panel (when showing route)
          if (_showRoutePanel)
            VenueRoutePanel(
              venue: _selectedVenue!,
              stadiumLocation: widget.stadiumLocation,
              onClose: () => setState(() => _showRoutePanel = false),
            ),

          // Bottom controls
          VenueMapBottomControls(
            showDistanceRings: _showDistanceRings,
            onToggleRings: _toggleDistanceRings,
            onListView: () => Navigator.of(context).pop(),
            onMyLocation: _goToMyLocation,
          ),

          // Floating action buttons
          VenueMapFloatingButtons(
            onZoomToFit: _zoomToFitAllMarkers,
            onFocusStadium: _focusOnStadium,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Marker and map setup
  // ---------------------------------------------------------------------------

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
          markerId: MarkerId(venue.placeId),
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
      snippetParts.add(venue.rating!.toStringAsFixed(1));
    }

    if (venue.priceLevel != null && venue.priceLevel! > 0) {
      snippetParts.add('\$' * venue.priceLevel!);
    }

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
        snippetParts.add(VenueRecommendationService.formatWalkingTime(walkTime));
      }
    }

    return snippetParts.join(' \u2022 ');
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
      Colors.green.withValues(alpha:0.1),
      Colors.orange.withValues(alpha:0.1),
      Colors.red.withValues(alpha:0.1),
      Colors.purple.withValues(alpha:0.1),
    ];

    for (int i = 0; i < distances.length; i++) {
      circles.add(Circle(
        circleId: CircleId('ring_$i'),
        center: widget.stadiumLocation!,
        radius: distances[i] * 1000,
        strokeColor: colors[i].withValues(alpha:0.5),
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

    if (widget.stadiumLocation != null) {
      minLat = math.min(minLat, widget.stadiumLocation!.latitude);
      maxLat = math.max(maxLat, widget.stadiumLocation!.latitude);
      minLng = math.min(minLng, widget.stadiumLocation!.longitude);
      maxLng = math.max(maxLng, widget.stadiumLocation!.longitude);
    }

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

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

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
    // Call venue implementation
  }
}
