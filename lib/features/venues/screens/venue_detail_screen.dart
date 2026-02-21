import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../features/recommendations/data/datasources/places_api_datasource.dart';
import '../../../core/services/venue_photo_service.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../widgets/venue_photo_gallery.dart';
import '../widgets/venue_operating_hours_card.dart';
import '../widgets/venue_action_buttons.dart';
import '../widgets/venue_reviews_preview.dart';
import '../../../config/api_keys.dart';
import 'venue_detail_header.dart';
import 'venue_detail_overview_tab.dart';
import 'venue_detail_photos_tab.dart';
import '../../venue_portal/presentation/widgets/manage_venue_button.dart';

// Re-export VenueQuickSummary so existing imports continue to work
export 'venue_quick_summary.dart';

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

  @override
  void initState() {
    super.initState();
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
      final placesDataSource = PlacesApiDataSource(
        googleApiKey: ApiKeys.googlePlaces,
      );

      double lat = 40.8128;
      double lng = -74.0742;

      if (widget.venue.geometry?.location != null) {
        lat = widget.venue.geometry!.location!.lat ?? lat;
        lng = widget.venue.geometry!.location!.lng ?? lng;
      } else if (widget.venue.latitude != null && widget.venue.longitude != null) {
        lat = widget.venue.latitude!;
        lng = widget.venue.longitude!;
      }

      final nearbyPlaces = await placesDataSource.fetchNearbyPlaces(
        latitude: lat,
        longitude: lng,
        radius: 1500.0,
        types: ['restaurant', 'bar', 'cafe'],
      );

      final filteredVenues = nearbyPlaces
          .where((place) => place.placeId != widget.venue.placeId)
          .toList();

      setState(() {
        _nearbyVenues = filteredVenues;
        _loadingNearbyVenues = false;
      });
    } catch (e) {
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
      backgroundColor: const Color(0xFF1E293B),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(category),
          SliverToBoxAdapter(
            child: Column(
              children: [
                VenueDetailHeader(
                  venue: widget.venue,
                  category: category,
                  isPopular: isPopular,
                ),
                VenueActionButtons(venue: widget.venue),
                ManageVenueButton(venue: widget.venue),
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
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
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
                                color: category.color.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  color: category.color.withValues(alpha: 0.8),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbedContent() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
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
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              VenueDetailOverviewTab(
                venue: widget.venue,
                nearbyVenues: _nearbyVenues,
              ),
              VenueDetailPhotosTab(
                venuePhotos: _venuePhotos,
                isLoading: _loadingPhotos,
              ),
              VenueReviewsPreview(venue: widget.venue),
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: VenueOperatingHoursCard(
                  venue: widget.venue,
                  showFullSchedule: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
