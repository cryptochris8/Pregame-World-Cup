import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';

/// Displays the content section of a venue card: name, rating, price level,
/// address, walking distance, and operating status.
class VenueCardContentSection extends StatelessWidget {
  final Place venue;
  final String? gameLocation;

  const VenueCardContentSection({
    super.key,
    required this.venue,
    this.gameLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue name
          Text(
            venue.name,
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
          _buildRatingRow(),

          const SizedBox(height: 12),

          // Address and distance
          if (venue.vicinity?.isNotEmpty == true) _buildAddressRow(),

          // Walking distance (if available)
          if (gameLocation != null) ...[
            const SizedBox(height: 8),
            _buildWalkingDistance(),
          ],

          // Operating status
          const SizedBox(height: 12),
          _buildOperatingStatus(),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        // Rating stars
        if (venue.rating != null) ...[
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
                size: 18,
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            venue.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (venue.userRatingsTotal != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${venue.userRatingsTotal})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(width: 16),
        ],

        // Price level
        if (venue.priceLevel != null && venue.priceLevel! > 0) ...[
          Row(
            children: [
              Text(
                '\$' * venue.priceLevel!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              Text(
                '\$' * (4 - venue.priceLevel!),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddressRow() {
    return Row(
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
            venue.vicinity!,
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
    );
  }

  Widget _buildWalkingDistance() {
    return Row(
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
    );
  }

  Widget _buildOperatingStatus() {
    // Use opening hours from venue data if available, otherwise show placeholder
    if (venue.openingHours?.openNow != null) {
      final isOpen = venue.openingHours!.openNow!;
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

  String _calculateWalkingTime() {
    // This would integrate with the VenueRecommendationService
    // For now, showing a placeholder
    return '\u{1F6B6} 5 min walk';
  }
}
