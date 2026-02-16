import 'package:flutter/material.dart';
import '../../../core/services/venue_recommendation_service.dart';
import 'venue_photo_gallery.dart';

/// Displays the photo section of a venue card with category/popular badges
/// and a photo count indicator.
class VenueCardPhotoSection extends StatelessWidget {
  final VenueCategory category;
  final bool isPopular;
  final bool loadingPhotos;
  final List<String> photoUrls;
  final String placeId;

  const VenueCardPhotoSection({
    super.key,
    required this.category,
    required this.isPopular,
    required this.loadingPhotos,
    required this.photoUrls,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context) {
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
              color: category.color.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: loadingPhotos
                  ? Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : photoUrls.isNotEmpty
                      ? VenuePhotoGallery(
                          photoUrls: photoUrls,
                          heroTag: 'venue_$placeId',
                          height: 200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          showIndicators: photoUrls.length > 1,
                          autoPlay: false,
                        )
                      : _buildFallbackPhoto(),
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
                    Colors.black.withValues(alpha: 0.15),
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
                _buildCategoryBadge(),
                if (isPopular) _buildPopularBadge(),
              ],
            ),
          ),

          // Photo count indicator
          if (photoUrls.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: _buildPhotoCountIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackPhoto() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
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
            color: category.color.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: category.color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\u{1F525}', style: TextStyle(fontSize: 14)),
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
    );
  }

  Widget _buildPhotoCountIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
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
            '${photoUrls.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
