import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';

/// Header section displayed below the sliver app bar in the venue detail screen.
///
/// Shows venue category badges, name, rating, price level, and address.
class VenueDetailHeader extends StatelessWidget {
  final Place venue;
  final VenueCategory category;
  final bool isPopular;

  const VenueDetailHeader({
    super.key,
    required this.venue,
    required this.category,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadges(),
          const SizedBox(height: 16),
          _buildVenueName(),
          const SizedBox(height: 12),
          _buildRatingAndPrice(),
          const SizedBox(height: 16),
          if (venue.vicinity?.isNotEmpty == true) _buildAddress(),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: category.color.withValues(alpha: 0.3)),
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
              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\u{1F525}', style: TextStyle(fontSize: 16)),
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
    );
  }

  Widget _buildVenueName() {
    return Text(
      venue.name,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _buildRatingAndPrice() {
    return Row(
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
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                venue.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (venue.userRatingsTotal != null) ...[
                const SizedBox(width: 6),
                Text(
                  '(${venue.userRatingsTotal} reviews)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 24),
        ],
        if (venue.priceLevel != null && venue.priceLevel! > 0) ...[
          Row(
            children: [
              const Text('\u{1F4B0} ', style: TextStyle(fontSize: 18)),
              Text(
                '\$' * venue.priceLevel!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              Text(
                '\$' * (4 - venue.priceLevel!),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          color: Color(0xFFFF6B35),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            venue.vicinity!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
