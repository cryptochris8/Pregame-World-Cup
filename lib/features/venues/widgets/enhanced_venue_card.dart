import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../../../core/services/venue_photo_service.dart';
import '../../../core/services/logging_service.dart';
import '../screens/venue_detail_screen.dart';
import '../../../config/api_keys.dart';
import 'venue_card_photo_section.dart';
import 'venue_card_content_section.dart';

// Re-export CompactVenueCard so existing imports still work
export 'compact_venue_card.dart';

class EnhancedVenueCard extends StatefulWidget {
  final Place venue;
  final String? gameLocation;
  final bool showPhotos;
  final bool showQuickActions;
  final VoidCallback? onTap;
  final String? apiKey;

  const EnhancedVenueCard({
    super.key,
    required this.venue,
    this.gameLocation,
    this.showPhotos = true,
    this.showQuickActions = false,
    this.onTap,
    this.apiKey,
  });

  @override
  State<EnhancedVenueCard> createState() => _EnhancedVenueCardState();
}

class _EnhancedVenueCardState extends State<EnhancedVenueCard> {
  final VenuePhotoService _photoService = VenuePhotoService();
  List<String> _photoUrls = [];
  bool _loadingPhotos = false;
  bool _photosLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.showPhotos) {
      _initializeAndLoadPhotos();
    }
  }

  Future<void> _initializeAndLoadPhotos() async {
    try {
      await _photoService.initialize();
      await _loadVenuePhotos();
    } catch (e) {
      LoggingService.warning('Error initializing photo service: $e', tag: 'VenueCard');
      setState(() {
        _loadingPhotos = false;
        _photosLoaded = true;
      });
    }
  }

  Future<void> _loadVenuePhotos() async {
    if (_photosLoaded || !widget.showPhotos) return;

    try {
      final photos = await _photoService.getVenuePhotos(
        widget.venue.placeId,
        apiKey: ApiKeys.googlePlaces,
        maxPhotos: 3,
        maxWidth: 400,
      );

      if (mounted) {
        setState(() {
          _photoUrls = photos;
          _loadingPhotos = false;
          _photosLoaded = true;
        });
      }
    } catch (e) {
      LoggingService.warning('Error loading venue photos: $e', tag: 'VenueCard');
      if (mounted) {
        setState(() {
          _loadingPhotos = false;
          _photosLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(widget.venue);
    final isPopular = VenueRecommendationService.isPopular(widget.venue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED), // Vibrant purple
            Color(0xFF3B82F6), // Electric blue
            Color(0xFFEA580C), // Warm orange
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _trackVenueInteraction('venue_card_tap');
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              _navigateToDetails();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section (200px height)
              if (widget.showPhotos)
                VenueCardPhotoSection(
                  category: category,
                  isPopular: isPopular,
                  loadingPhotos: _loadingPhotos,
                  photoUrls: _photoUrls,
                  placeId: widget.venue.placeId,
                ),

              // Content Section
              VenueCardContentSection(
                venue: widget.venue,
                gameLocation: widget.gameLocation,
              ),

              // Quick Actions (if enabled)
              if (widget.showQuickActions) _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.phone,
            label: 'Call',
            color: const Color(0xFF2E7D32),
            onTap: () => _callVenue(),
          ),
          _buildActionButton(
            icon: Icons.directions,
            label: 'Directions',
            color: const Color(0xFF1976D2),
            onTap: () => _getDirections(),
          ),
          _buildActionButton(
            icon: Icons.info,
            label: 'Details',
            color: const Color(0xFF8B4513),
            onTap: () => _navigateToDetails(),
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            color: const Color(0xFF7B1FA2),
            onTap: () => _shareVenue(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails() {
    _trackVenueInteraction('venue_details_view');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venue: widget.venue,
          gameLocation: widget.gameLocation,
          apiKey: widget.apiKey,
        ),
      ),
    );
  }

  void _callVenue() {
    _trackVenueInteraction('venue_call');
    // Implementation would go here - call venue phone number
  }

  void _getDirections() {
    _trackVenueInteraction('venue_directions');
    // Implementation would go here - open maps with directions
  }

  void _shareVenue() {
    _trackVenueInteraction('venue_share');
    // Implementation would go here - share venue details
  }

  /// Track venue interactions for analytics
  void _trackVenueInteraction(String action) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Log the interaction for analytics
        LoggingService.info('Venue interaction: $action for ${widget.venue.name}', tag: 'VenueCard');

        // Future: Could integrate with analytics service or user learning service
        // For now, just log the interaction
      }
    } catch (e) {
      LoggingService.warning('Failed to track venue interaction: $e', tag: 'VenueCard');
      // Don't throw - this is non-critical
    }
  }
}
