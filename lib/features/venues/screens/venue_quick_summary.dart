import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';

/// Quick summary widget for compact displays of a venue.
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
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
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
                    color: Colors.white,
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
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
                color: const Color(0xFFFF6B35),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _callVenue() {
    // Implementation for calling venue
  }

  void _getDirections() {
    // Implementation for getting directions
  }

  void _openDetails(BuildContext context) {
    // Implementation for opening venue details
  }
}
