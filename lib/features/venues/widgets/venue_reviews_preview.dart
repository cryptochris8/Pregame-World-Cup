import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';

class VenueReviewsPreview extends StatelessWidget {
  final Place venue;

  const VenueReviewsPreview({
    super.key,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    // Generate sample reviews for demo purposes
    final reviews = _generateSampleReviews();
    
    if (reviews.isEmpty) {
      return _buildNoReviewsState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews header with rating summary
          _buildReviewsHeader(),
          
          const SizedBox(height: 24),
          
          // Reviews list
          ...reviews.asMap().entries.map((entry) {
            final index = entry.key;
            final review = entry.value;
            return Column(
              children: [
                _buildReviewCard(review),
                if (index < reviews.length - 1) const SizedBox(height: 16),
              ],
            );
          }),
          
          const SizedBox(height: 24),
          
          // View more reviews button
          _buildViewMoreButton(context),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews & Ratings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1810),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Average rating
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      venue.rating?.toStringAsFixed(1) ?? '4.2',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (venue.rating ?? 4.2).floor()
                              ? Icons.star
                              : index < (venue.rating ?? 4.2)
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Rating breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${venue.userRatingsTotal ?? 127} reviews',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D1810),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRatingBreakdown(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    // Sample rating distribution
    final ratingCounts = [
      {'stars': 5, 'count': 78, 'percentage': 0.61},
      {'stars': 4, 'count': 32, 'percentage': 0.25},
      {'stars': 3, 'count': 12, 'percentage': 0.09},
      {'stars': 2, 'count': 4, 'percentage': 0.03},
      {'stars': 1, 'count': 1, 'percentage': 0.01},
    ];

    return Column(
      children: ratingCounts.map((rating) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '${rating['stars']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                color: Color(0xFFFFD700),
                size: 12,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: rating['percentage'] as double,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${rating['count']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review['initials'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D1810),
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating']
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review text
          Text(
            review['text'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          
          // Review tags/highlights
          if (review['highlights'] != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (review['highlights'] as List<String>).map((highlight) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    highlight,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Helpful votes
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Helpful (${review['helpful']})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to leave a review for ${venue.name}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _writeReview(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Write a Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMoreButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () => _viewAllReviews(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8B4513),
          side: const BorderSide(color: Color(0xFF8B4513)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'View All Reviews',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleReviews() {
    // Generate sample reviews based on venue type and rating
    return [
      {
        'name': 'Sarah M.',
        'initials': 'SM',
        'rating': 5,
        'date': '2 weeks ago',
        'text': 'Amazing atmosphere and great food! The staff was super friendly and the location is perfect for game day. Highly recommend the wings and craft beer selection.',
        'highlights': ['Great Food', 'Game Day Spot', 'Friendly Staff'],
        'helpful': 12,
      },
      {
        'name': 'Mike R.',
        'initials': 'MR',
        'rating': 4,
        'date': '1 month ago',
        'text': 'Solid choice for watching games. Good selection of TVs and the crowd gets really into it. Food was decent but service was a bit slow during peak hours.',
        'highlights': ['Great for Games', 'Good TVs'],
        'helpful': 8,
      },
      {
        'name': 'Jessica L.',
        'initials': 'JL',
        'rating': 5,
        'date': '3 weeks ago',
        'text': 'Perfect spot for pre-match drinks! Walking distance to the stadium and has that authentic World Cup fan zone vibe. The outdoor seating is a plus when weather is nice.',
        'highlights': ['Pre-Match Spot', 'Walking Distance', 'Outdoor Seating'],
        'helpful': 15,
      },
    ];
  }

  void _viewAllReviews(BuildContext context) {
    // Navigate to full reviews screen
    // View all reviews action
  }

  void _writeReview() {
    // Navigate to write review screen
    // Write review action
  }
}

// Compact reviews summary widget for venue cards
class VenueReviewsSummary extends StatelessWidget {
  final Place venue;
  final bool showReviewCount;

  const VenueReviewsSummary({
    super.key,
    required this.venue,
    this.showReviewCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (venue.rating == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < venue.rating!.floor()
                  ? Icons.star
                  : index < venue.rating!
                      ? Icons.star_half
                      : Icons.star_border,
              color: const Color(0xFFFFD700),
              size: 14,
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          venue.rating!.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1810),
          ),
        ),
        if (showReviewCount && venue.userRatingsTotal != null) ...[
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
    );
  }
} 