import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../features/recommendations/data/datasources/places_api_datasource.dart';
import '../../../core/services/venue_photo_service.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../widgets/venue_photo_gallery.dart';
import '../widgets/venue_operating_hours_card.dart';
import '../widgets/venue_action_buttons.dart';
import '../widgets/venue_reviews_preview.dart';
import '../widgets/enhanced_ai_venue_recommendations_widget.dart';
import '../../../config/api_keys.dart';

class VenueDetailScreen extends StatefulWidget {
  final Place venue;
  final String? gameLocation;
  final String? apiKey;

  const VenueDetailScreen({
    super.key,
    required this.venue,
    this.gameLocation,
    this.apiKey,
  });

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final VenuePhotoService _photoService = VenuePhotoService();
  
  List<String> _venuePhotos = [];
  bool _loadingPhotos = false;
  bool _photosLoaded = false;
  
  // Smart recommendations data
  List<Place> _nearbyVenues = [];
  bool _loadingNearbyVenues = false;
  
  // UI state managed through stateful logic when needed

  @override
  void initState() {
    super.initState();
    // Debug output removed
    _tabController = TabController(length: 4, vsync: this);
    _initializeAndLoadPhotos();
    _loadNearbyVenues();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadPhotos() async {
    try {
      await _photoService.initialize();
      await _loadVenuePhotos();
    } catch (e) {
      // Debug output removed
      setState(() {
        _loadingPhotos = false;
        _photosLoaded = true;
      });
    }
  }

  Future<void> _loadVenuePhotos() async {
    if (_photosLoaded) return;
    
    setState(() => _loadingPhotos = true);
    
    try {
      final photos = await _photoService.getVenuePhotos(
        widget.venue.placeId,
        apiKey: ApiKeys.googlePlaces,
        maxPhotos: 10,
        maxWidth: 800,
      );
      
      setState(() {
        _venuePhotos = photos;
        _loadingPhotos = false;
        _photosLoaded = true;
      });
    } catch (e) {
      // Debug output removed
      setState(() {
        _loadingPhotos = false;
        _photosLoaded = true;
      });
    }
  }

  Future<void> _loadNearbyVenues() async {
    if (_loadingNearbyVenues) return;
    
    setState(() => _loadingNearbyVenues = true);
    
    try {
      // Use the venue's location to find nearby venues
      final placesDataSource = PlacesApiDataSource(
        googleApiKey: ApiKeys.googlePlaces,
      );
      
      // If the venue has geometry/location, use it; otherwise use a default location
      double lat = 33.9425; // Default to Atlanta area
      double lng = -83.3431;
      
      // Try to get location from the venue if available
      if (widget.venue.geometry?.location != null) {
        lat = widget.venue.geometry!.location!.lat ?? lat;
        lng = widget.venue.geometry!.location!.lng ?? lng;
      } else if (widget.venue.latitude != null && widget.venue.longitude != null) {
        // Use the direct lat/lng if available
        lat = widget.venue.latitude!;
        lng = widget.venue.longitude!;
      }
      
      // Debug output removed
      
      // Find nearby restaurants and bars for recommendations
      final nearbyPlaces = await placesDataSource.fetchNearbyPlaces(
        latitude: lat,
        longitude: lng,
        radius: 1500.0, // 1.5km radius
        types: ['restaurant', 'bar', 'cafe'],
      );
      
      // Filter out the current venue from recommendations
      final filteredVenues = nearbyPlaces.where((place) => 
        place.placeId != widget.venue.placeId
      ).toList();
      
      // Debug output removed
      
      setState(() {
        _nearbyVenues = filteredVenues;
        _loadingNearbyVenues = false;
      });
    } catch (e) {
      // Debug output removed
      setState(() {
        _loadingNearbyVenues = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(widget.venue);
    final isPopular = VenueRecommendationService.isPopular(widget.venue);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Dark background for entire screen
      body: CustomScrollView(
        slivers: [
          // App bar with photo hero
          _buildSliverAppBar(category),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Venue header info
                _buildVenueHeader(category, isPopular),
                
                // Action buttons
                VenueActionButtons(venue: widget.venue),
                
                // Tabbed content
                _buildTabbedContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(VenueCategory category) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B), // Dark blue-gray background
      foregroundColor: Colors.white, // White text/icons
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or category background
            Container(
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
              ),
              child: _loadingPhotos
                  ? Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _venuePhotos.isNotEmpty
                      ? VenuePhotoGallery(
                          photoUrls: _venuePhotos,
                          heroTag: 'venue_detail_${widget.venue.placeId}',
                          height: 300,
                          showIndicators: _venuePhotos.length > 1,
                          autoPlay: true,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                size: 64,
                                color: category.color.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  color: category.color.withOpacity(0.8),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueHeader(VenueCategory category, bool isPopular) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Dark blue-gray background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and popular badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: category.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color: category.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPopular) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔥', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'Popular',
                        style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Venue name
          Text(
            widget.venue.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark background
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Rating and price
          Row(
            children: [
              if (widget.venue.rating != null) ...[
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        final rating = widget.venue.rating!;
                        return Icon(
                          index < rating.floor()
                              ? Icons.star
                              : index < rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.venue.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for dark background
                      ),
                    ),
                    if (widget.venue.userRatingsTotal != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${widget.venue.userRatingsTotal} reviews)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70, // Light text for dark background
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 24),
              ],
              if (widget.venue.priceLevel != null && widget.venue.priceLevel! > 0) ...[
                Row(
                  children: [
                    const Text('💰 ', style: TextStyle(fontSize: 18)),
                    Text(
                      '\$' * widget.venue.priceLevel!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D6A4F),
                      ),
                    ),
                    Text(
                      '\$' * (4 - widget.venue.priceLevel!),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white30, // Dim white for unselected price levels
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Address
          if (widget.venue.vicinity?.isNotEmpty == true) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF6B35), // Vibrant orange to match app theme
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:                   Text(
                    widget.venue.vicinity!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70, // Light text for dark background
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabbedContent() {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF334155), // Dark blue-gray for tab bar
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFFFF6B35), // Vibrant orange for selected tab
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60, // Light text for unselected tabs
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Photos'),
              Tab(text: 'Reviews'),
              Tab(text: 'Hours'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Tab content
        SizedBox(
          height: 600, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPhotosTab(),
              _buildReviewsTab(),
              _buildHoursTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced AI Recommendations - prominent position
          EnhancedAIVenueRecommendationsWidget(
            nearbyVenues: _nearbyVenues, // Real nearby venues for AI analysis
            customContext: 'Venue detail view for ${widget.venue.name}',
          ),
          
          const SizedBox(height: 24),
          
          // Quick info cards
          VenueOperatingHoursCard(venue: widget.venue),
          
          const SizedBox(height: 24),
          
          // Contact information
          _buildContactInfo(),
          
          const SizedBox(height: 24),
          
          // About section (if available)
          if (widget.venue.vicinity?.isNotEmpty == true)
            _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_loadingPhotos) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_venuePhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.white38, // Light icon for dark background
            ),
            const SizedBox(height: 16),
            Text(
              'No photos available',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white60, // Light text for dark background
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _venuePhotos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showPhotoGallery(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _venuePhotos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return VenueReviewsPreview(venue: widget.venue);
  }

  Widget _buildHoursTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: VenueOperatingHoursCard(
        venue: widget.venue,
        showFullSchedule: true,
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569)), // Lighter border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark background
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address
          if (widget.venue.vicinity?.isNotEmpty == true) ...[
            _buildContactRow(
              Icons.location_on,
              'Address',
              widget.venue.vicinity!,
            ),
            const SizedBox(height: 12),
          ],
          
          // Phone (placeholder)
          _buildContactRow(
            Icons.phone,
            'Phone',
            '+1 (555) 123-4567',
          ),
          
          const SizedBox(height: 12),
          
          // Website (placeholder)
          _buildContactRow(
            Icons.language,
            'Website',
            'www.${widget.venue.name.toLowerCase().replaceAll(' ', '')}.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B35), // Vibrant orange for icons
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for dark background
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70, // Light text for dark background
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569)), // Lighter border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark background
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Great venue for game day! Located in the heart of the action with excellent food and atmosphere.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70, // Light text for dark background
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Photos (${initialIndex + 1}/${_venuePhotos.length})'),
          ),
          body: VenuePhotoGallery(
            photoUrls: _venuePhotos,
            heroTag: 'photo_gallery_detail',
            showIndicators: true,
          ),
        ),
      ),
    );
  }
}

// Quick summary widget for compact displays
class VenueQuickSummary extends StatelessWidget {
  final Place venue;

  const VenueQuickSummary({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(venue);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)), // Lighter border
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Venue info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // White text for dark background
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                if (venue.rating != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        venue.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // White text for dark background
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60, // Light text for dark background
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _callVenue(),
                icon: const Icon(Icons.phone),
                iconSize: 20,
                color: const Color(0xFF2E7D32),
              ),
              IconButton(
                onPressed: () => _getDirections(),
                icon: const Icon(Icons.directions),
                iconSize: 20,
                color: const Color(0xFF1976D2),
              ),
              IconButton(
                onPressed: () => _openDetails(context),
                icon: const Icon(Icons.info),
                iconSize: 20,
                color: const Color(0xFFFF6B35), // Vibrant orange for consistency
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _callVenue() {
    // Debug output removed
    // Implementation for calling venue
  }

  void _getDirections() {
    // Debug output removed
    // Implementation for getting directions
  }

  void _openDetails(BuildContext context) {
    // Debug output removed
    // Implementation for opening venue details
  }
} 
