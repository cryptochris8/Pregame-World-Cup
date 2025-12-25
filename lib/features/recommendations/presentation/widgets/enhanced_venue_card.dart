import 'package:flutter/material.dart';
import '../../domain/entities/place.dart';
import '../../../../core/services/venue_recommendation_service.dart';

class EnhancedVenueCard extends StatelessWidget {
  final Place venue;
  final double? stadiumLat;
  final double? stadiumLng;
  final VoidCallback? onTap;

  const EnhancedVenueCard({
    super.key,
    required this.venue,
    this.stadiumLat,
    this.stadiumLng,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = VenueRecommendationService.categorizeVenue(venue);
    final popularityScore = VenueRecommendationService.calculatePopularityScore(venue);
    final isPopular = VenueRecommendationService.isPopular(venue);
    
    String? walkingInfo;
    if (stadiumLat != null && stadiumLng != null) {
      final lat = venue.latitude ?? venue.geometry?.location?.lat;
      final lng = venue.longitude ?? venue.geometry?.location?.lng;
      
      if (lat != null && lng != null) {
        final distance = VenueRecommendationService.calculateWalkingDistance(
          stadiumLat!, stadiumLng!, lat, lng
        );
        final walkTime = VenueRecommendationService.estimateWalkingTime(distance);
        walkingInfo = VenueRecommendationService.formatWalkingTime(walkTime);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // Dark blue-gray background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF475569), // Lighter blue-gray border for separation
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
                 ],
       ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16), // Increased padding for better spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      venue.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isPopular) _buildPopularBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Category and status row
              Row(
                children: [
                  _buildCategoryChip(category),
                  if (venue.openingHours?.openNow == true) ...[
                    const SizedBox(width: 8),
                    _buildOpenNowChip(),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Rating and details row - flexible to prevent overflow
              Row(
                children: [
                  if (venue.rating != null) ...[
                    _buildRatingDisplay(),
                    const SizedBox(width: 12),
                  ],
                  if (venue.priceLevel != null) ...[
                    _buildPriceLevelDisplay(),
                    const SizedBox(width: 12),
                  ],
                  if (walkingInfo != null) ...[
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_walk, 
                               color: const Color(0xFFFF6B35), size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              walkingInfo,
                              style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              
              if (venue.vicinity != null) ...[
                const SizedBox(height: 4),
                Text(
                  venue.vicinity!,
                  style: const TextStyle(
                    color: Colors.white60, // Light text for dark background
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red[600],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Text(
            'Popular',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(VenueCategory category) {
    final color = Color(category.colorCodes.first);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenNowChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.2), // Success green from app theme
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981), width: 1), // Success green from app theme
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: const Color(0xFF10B981), size: 10), // Success green from app theme
          const SizedBox(width: 2),
          Text(
            'Open',
            style: TextStyle(
              color: const Color(0xFF10B981), // Success green from app theme
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDisplay() {
    final rating = venue.rating!;
    final reviewCount = venue.userRatingsTotal ?? 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: const Color(0xFFFBBF24), size: 16), // Championship gold from app theme
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              color: Colors.white38, // Light text for dark background
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceLevelDisplay() {
    final priceLevel = venue.priceLevel!;
    final dollarSigns = '\$' * priceLevel;
    final greyDollars = '\$' * (4 - priceLevel);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dollarSigns,
          style: TextStyle(
            color: const Color(0xFF10B981), // Success green from app theme
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (greyDollars.isNotEmpty)
          Text(
            greyDollars,
            style: const TextStyle(
              color: Colors.white30, // Dim white for unselected price levels
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class VenueCategoryFilterChips extends StatelessWidget {
  final VenueCategory? selectedCategory;
  final Function(VenueCategory?) onCategorySelected;
  final List<Place> venues;

  const VenueCategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.venues,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate venue counts per category
    final categoryColors = <VenueCategory, int>{};
    for (final venue in venues) {
      final category = VenueRecommendationService.categorizeVenue(venue);
      categoryColors[category] = (categoryColors[category] ?? 0) + 1;
    }

    final availableCategories = categoryColors.keys.where((cat) => 
        categoryColors[cat]! > 0 && cat != VenueCategory.unknown).toList();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                'All (${venues.length})',
                style: TextStyle(
                  color: selectedCategory == null ? Colors.white : Colors.grey[300],
                  fontWeight: selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              backgroundColor: const Color(0xFF334155), // Dark blue-gray for background
              selectedColor: const Color(0xFFEA580C), // Warm orange from app theme
              checkmarkColor: Colors.white,
            ),
          ),
          
          // Category filter chips
          ...availableCategories.map((category) {
            final count = categoryColors[category]!;
            final isSelected = selectedCategory == category;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji),
                    const SizedBox(width: 4),
                    Text(
                      '${category.displayName} ($count)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(isSelected ? null : category),
                backgroundColor: const Color(0xFF334155), // Dark blue-gray for background
                selectedColor: Color(category.colorCodes.first),
                checkmarkColor: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }
} 