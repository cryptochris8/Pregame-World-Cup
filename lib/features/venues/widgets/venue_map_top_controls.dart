import 'package:flutter/material.dart';
import '../../../core/services/venue_recommendation_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import 'venue_map_category_filter.dart';

/// Top overlay controls for the venue map screen.
///
/// Contains the back button, title bar, venue count, and
/// category filter chips.
class VenueMapTopControls extends StatelessWidget {
  final List<Place> allVenues;
  final List<Place> filteredVenues;
  final VenueCategory? selectedCategory;
  final ValueChanged<VenueCategory?> onCategorySelected;

  const VenueMapTopControls({
    super.key,
    required this.allVenues,
    required this.filteredVenues,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with back button and title
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF2D1810),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Venue Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1810),
                          ),
                        ),
                        Text(
                          '${filteredVenues.length} venues found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category filter chips
            VenueMapCategoryFilter(
              allVenues: allVenues,
              filteredVenues: filteredVenues,
              selectedCategory: selectedCategory,
              onCategorySelected: onCategorySelected,
            ),
          ],
        ),
      ),
    );
  }
}
