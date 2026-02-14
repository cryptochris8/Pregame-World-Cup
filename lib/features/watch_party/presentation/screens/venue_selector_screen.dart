import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../features/recommendations/data/datasources/places_api_datasource.dart';
import '../../../../features/recommendations/domain/entities/place.dart';
import '../../../../injection_container.dart';

/// Screen for selecting a venue for a watch party
class VenueSelectorScreen extends StatefulWidget {
  const VenueSelectorScreen({Key? key}) : super(key: key);

  @override
  State<VenueSelectorScreen> createState() => _VenueSelectorScreenState();
}

class _VenueSelectorScreenState extends State<VenueSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesApiDataSource _placesDataSource = sl<PlacesApiDataSource>();

  List<Place> _venues = [];
  List<Place> _allVenues = [];
  bool _isLoading = false;
  bool _isMapView = false;
  String? _error;
  Position? _currentPosition;
  String _selectedCategory = 'Sports Bars';

  @override
  void initState() {
    super.initState();
    _loadNearbyVenues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyVenues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current location
      final position = await _getCurrentPosition();
      if (position == null) {
        setState(() {
          _error = 'Unable to get your location. Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      _currentPosition = position;

      // Fetch nearby venues (bars, restaurants, sports venues)
      final venues = await _placesDataSource.fetchNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 5000, // 5km radius
        types: ['bar', 'restaurant', 'night_club', 'cafe'],
      );

      setState(() {
        _allVenues = venues;
        _venues = _filterByCategory(venues);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load venues: $e';
        _isLoading = false;
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return null;
        }
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  List<Place> _filterByCategory(List<Place> venues) {
    if (_selectedCategory == 'All Venues') return venues;

    final categoryTypes = <String, List<String>>{
      'Sports Bars': ['bar', 'night_club'],
      'Restaurants': ['restaurant'],
      'Breweries': ['bar', 'cafe'],
    };

    final types = categoryTypes[_selectedCategory];
    if (types == null) return venues;

    return venues.where((v) {
      final venueTypes = v.types ?? [];
      return venueTypes.any((t) => types.contains(t));
    }).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _venues = _filterByCategory(_allVenues);
    });
  }

  Future<void> _searchVenues(String query) async {
    if (query.isEmpty) {
      _loadNearbyVenues();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For text search, use the current position or default to a central location
      final lat = _currentPosition?.latitude ?? 40.7128;
      final lng = _currentPosition?.longitude ?? -74.0060;

      final venues = await _placesDataSource.fetchNearbyPlaces(
        latitude: lat,
        longitude: lng,
        radius: 25000, // Larger radius for search
        types: ['bar', 'restaurant', 'night_club', 'cafe'],
      );

      // Filter by query (client-side filtering)
      final filtered = venues.where((v) =>
          v.name.toLowerCase().contains(query.toLowerCase()) ||
          (v.vicinity?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();

      setState(() {
        _allVenues = filtered;
        _venues = _filterByCategory(filtered);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Venue'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sports bars, restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: _searchVenues,
            ),
          ),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('Sports Bars', Icons.sports_bar, _selectedCategory == 'Sports Bars'),
                const SizedBox(width: 8),
                _buildCategoryChip('Restaurants', Icons.restaurant, _selectedCategory == 'Restaurants'),
                const SizedBox(width: 8),
                _buildCategoryChip('Breweries', Icons.local_drink, _selectedCategory == 'Breweries'),
                const SizedBox(width: 8),
                _buildCategoryChip('All Venues', Icons.place, _selectedCategory == 'All Venues'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _isMapView
                        ? _buildMapView()
                        : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool selected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (value) {
        _onCategorySelected(label);
      },
    );
  }

  Widget _buildListView() {
    if (_venues.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        final venue = _venues[index];
        return _buildVenueCard(venue);
      },
    );
  }

  Widget _buildMapView() {
    // Placeholder for map view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Map view coming soon',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _isMapView = false),
            child: const Text('Switch to List View'),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(Place venue) {
    final name = venue.name;
    final address = venue.vicinity ?? '';
    final rating = venue.rating;
    // Note: photoReference is a reference, not a URL - would need Google Places API to get actual URL
    final hasPhoto = venue.photoReference != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectVenue(venue),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Venue image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(
                    hasPhoto ? Icons.local_bar : Icons.sports_bar,
                    size: 32,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Venue info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (address.isNotEmpty)
                      Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Select button
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No venues found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNearbyVenues,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _selectVenue(Place venue) {
    final result = {
      'venueId': venue.placeId,
      'venueName': venue.name,
      'venueAddress': venue.vicinity,
      'venueLatitude': venue.latitude,
      'venueLongitude': venue.longitude,
    };

    Navigator.pop(context, result);
  }
}
