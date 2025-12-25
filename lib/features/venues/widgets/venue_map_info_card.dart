import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';

class VenueMapInfoCard extends StatelessWidget {
  final Place venue;
  final VoidCallback onDetailsPressed;
  final VoidCallback onDirectionsPressed;
  final VoidCallback onCallPressed;
  final VoidCallback onClose;

  const VenueMapInfoCard({
    super.key,
    required this.venue,
    required this.onDetailsPressed,
    required this.onDirectionsPressed,
    required this.onCallPressed,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(venue);
    final isPopular = VenueRecommendationService.isPopular(venue);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with category and close button
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: category.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: category.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'Popular',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Close button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onClose();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Venue name
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Rating and price row
                Row(
                  children: [
                    if (venue.rating != null) ...[
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              final rating = venue.rating!;
                              return Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : index < rating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: const Color(0xFFFFD700),
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            venue.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D1810),
                            ),
                          ),
                          if (venue.userRatingsTotal != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${venue.userRatingsTotal})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    if (venue.priceLevel != null && venue.priceLevel! > 0) ...[
                      Row(
                        children: [
                          Text(
                            '\$' * venue.priceLevel!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D6A4F),
                            ),
                          ),
                          Text(
                            '\$' * (4 - venue.priceLevel!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                // Address (if available)
                if (venue.vicinity?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.vicinity!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Action buttons section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Directions button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.directions,
                    label: 'Directions',
                    color: const Color(0xFF1976D2),
                    onPressed: onDirectionsPressed,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Call button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone,
                    label: 'Call',
                    color: const Color(0xFF2E7D32),
                    onPressed: onCallPressed,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Details button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.info,
                    label: 'Details',
                    color: const Color(0xFF8B4513),
                    onPressed: onDetailsPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact version for smaller screens or quick preview
class VenueMapInfoChip extends StatelessWidget {
  final Place venue;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const VenueMapInfoChip({
    super.key,
    required this.venue,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(venue);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            // Category icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 12,
                color: category.color,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Venue name (truncated)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                venue.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1810),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Rating
            if (venue.rating != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.star,
                size: 12,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(width: 2),
              Text(
                venue.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D1810),
                ),
              ),
            ],
            
            // Close button
            if (onClose != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 