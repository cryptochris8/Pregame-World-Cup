import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../../../core/services/venue_photo_service.dart';
import '../../../core/services/logging_service.dart';
import '../screens/venue_detail_screen.dart';
import 'venue_photo_gallery.dart';
import '../../../config/api_keys.dart';

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
            color: const Color(0xFF7C3AED).withOpacity(0.3),
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
              if (widget.showPhotos) _buildPhotoSection(category, isPopular),
              
              // Content Section
              _buildContentSection(category, isPopular),
              
              // Quick Actions (if enabled)
              if (widget.showQuickActions) _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(VenueCategory category, bool isPopular) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Photo or fallback
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: category.color.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: _loadingPhotos
                  ? Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _photoUrls.isNotEmpty
                      ? VenuePhotoGallery(
                          photoUrls: _photoUrls,
                          heroTag: 'venue_${widget.venue.placeId}',
                          height: 200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          showIndicators: _photoUrls.length > 1,
                          autoPlay: false,
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.15),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                size: 48,
                                color: category.color.withOpacity(0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: category.color.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          
          // Top badges overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Popular badge
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Photo count indicator
          if (_photoUrls.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_photoUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(VenueCategory category, bool isPopular) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue name
          Text(
            widget.venue.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Rating and details row
          Row(
            children: [
              // Rating stars
              if (widget.venue.rating != null) ...[
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
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.venue.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.venue.userRatingsTotal != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.venue.userRatingsTotal})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
              ],
              
              // Price level
              if (widget.venue.priceLevel != null && widget.venue.priceLevel! > 0) ...[
                Row(
                  children: [
                    Text(
                      '\$' * widget.venue.priceLevel!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    Text(
                      '\$' * (4 - widget.venue.priceLevel!),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Address and distance
          if (widget.venue.vicinity?.isNotEmpty == true) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.venue.vicinity!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          // Walking distance (if available)
          if (widget.gameLocation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Colors.greenAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _calculateWalkingTime(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ],
          
          // Operating status
          const SizedBox(height: 12),
          _buildOperatingStatus(),
        ],
      ),
    );
  }

  Widget _buildOperatingStatus() {
    // Use opening hours from venue data if available, otherwise show placeholder
    if (widget.venue.openingHours?.openNow != null) {
      final isOpen = widget.venue.openingHours!.openNow!;
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      );
    }
    
    // Fallback for venues without opening hours data
    return const Row(
      children: [
        Icon(
          Icons.schedule,
          color: Colors.white70,
          size: 16,
        ),
        SizedBox(width: 8),
        Text(
          'Hours vary',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
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

  String _calculateWalkingTime() {
    // This would integrate with the VenueRecommendationService
    // For now, showing a placeholder
    return '🚶 5 min walk';
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

// Compact venue card for lists
class CompactVenueCard extends StatelessWidget {
  final Place venue;
  final VoidCallback? onTap;
  final bool showCategory;

  const CompactVenueCard({
    super.key,
    required this.venue,
    this.onTap,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(venue);
    final isPopular = VenueRecommendationService.isPopular(venue);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Venue info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venue.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D1810),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          if (venue.rating != null) ...[
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
                                color: Color(0xFF2D1810),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (showCategory)
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 