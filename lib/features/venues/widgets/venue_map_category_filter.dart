import 'package:flutter/material.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';

/// Horizontal scrolling category filter chip bar for the venue map.
class VenueMapCategoryFilter extends StatelessWidget {
  final List<Place> allVenues;
  final List<Place> filteredVenues;
  final VenueCategory? selectedCategory;
  final ValueChanged<VenueCategory?> onCategorySelected;

  const VenueMapCategoryFilter({
    super.key,
    required this.allVenues,
    required this.filteredVenues,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(null, 'All', filteredVenues.length),
          const SizedBox(width: 8),
          ...VenueCategory.values.where((cat) => cat != VenueCategory.unknown).map((category) {
            final count = allVenues.where((venue) =>
                VenueRecommendationService.categorizeVenue(venue) == category).length;

            if (count == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(category, category.displayName, count),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(VenueCategory? category, String label, int count) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEA580C)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEA580C)
                : Colors.grey.withValues(alpha:0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
