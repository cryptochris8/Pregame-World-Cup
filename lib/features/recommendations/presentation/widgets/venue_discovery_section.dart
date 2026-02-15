import 'package:flutter/material.dart';
import '../../domain/entities/place.dart';
import '../../../../config/theme_helper.dart';
import '../../../../core/services/venue_recommendation_service.dart';
import 'enhanced_venue_card.dart';
import 'smart_venue_discovery_widget.dart';
import '../../../schedule/domain/entities/game_schedule.dart';

/// Section displaying venue discovery with filtering, sorting, and recommendations.
class VenueDiscoverySection extends StatelessWidget {
  final List<Place>? nearbyPlaces;
  final bool isLoadingPlaces;
  final String? placesError;
  final VenueCategory? selectedCategory;
  final VenueSortOption sortOption;
  final double? stadiumLatitude;
  final double? stadiumLongitude;
  final GameSchedule game;
  final String venueContext;
  final VoidCallback onOpenMapView;
  final ValueChanged<VenueCategory?> onCategorySelected;
  final ValueChanged<VenueSortOption?> onSortOptionChanged;
  final ValueChanged<Place> onVenueSelected;
  final List<Place> Function() getDisplayVenues;

  const VenueDiscoverySection({
    super.key,
    required this.nearbyPlaces,
    required this.isLoadingPlaces,
    required this.placesError,
    required this.selectedCategory,
    required this.sortOption,
    required this.stadiumLatitude,
    required this.stadiumLongitude,
    required this.game,
    required this.venueContext,
    required this.onOpenMapView,
    required this.onCategorySelected,
    required this.onSortOptionChanged,
    required this.onVenueSelected,
    required this.getDisplayVenues,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            const Text(
              'Find sports bars, restaurants, and venues near the stadium with smart filtering and recommendations.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlacesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.restaurant, color: ThemeHelper.favoriteColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Venue Discovery',
            style: ThemeHelper.h3(context, color: ThemeHelper.favoriteColor),
          ),
        ),
        if (nearbyPlaces != null && nearbyPlaces!.isNotEmpty) ...[
          // Map View Button
          GestureDetector(
            onTap: onOpenMapView,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Map View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Venue Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[300]!.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Text(
              '${nearbyPlaces!.length} found',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlacesSection(BuildContext context) {
    if (isLoadingPlaces) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (placesError != null) {
      return _buildErrorState();
    }

    if (nearbyPlaces == null || nearbyPlaces!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No nearby venues found.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final displayVenues = getDisplayVenues();
    final filterCounts = VenueRecommendationService.getFilterCounts(nearbyPlaces!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Stats Row
        _buildQuickStats(filterCounts),

        const SizedBox(height: 16),

        // Smart Venue Discovery
        SmartVenueDiscoveryWidget(
          venues: nearbyPlaces!,
          game: game,
          context: venueContext,
          onVenueSelected: (venue) => onVenueSelected(venue),
        ),

        const SizedBox(height: 16),

        // Category Filter Chips
        VenueCategoryFilterChips(
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            onCategorySelected(category);
          },
          venues: nearbyPlaces!,
        ),

        const SizedBox(height: 16),

        // Sort Options Row
        _buildSortOptions(context),

        const SizedBox(height: 16),

        // Popular Venues Section (if not filtered by category)
        if (selectedCategory == null && sortOption == VenueSortOption.distance) ...[
          _buildPopularVenuesSection(),
          const SizedBox(height: 16),
        ],

        // Results Count
        Text(
          '${displayVenues.length} venues found',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        // Venue List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayVenues.length,
          itemBuilder: (context, index) {
            final venue = displayVenues[index];
            return EnhancedVenueCard(
              venue: venue,
              stadiumLat: stadiumLatitude,
              stadiumLng: stadiumLongitude,
              onTap: () => onVenueSelected(venue),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFF6B35)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFFF6B35),
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                placesError!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This feature will help you find restaurants, bars, hotels, and other venues near the game location.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF475569)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🔥', '${stats['popular']}', 'Popular'),
          _buildStatItem('⭐', '${stats['highly_rated']}', '4.0+ Rating'),
          _buildStatItem('🕒', '${stats['open_now']}', 'Open Now'),
          _buildStatItem('🏈', '${stats['sports_bars']}', 'Sports Bars'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String count, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: VenueSortOption.values.map((option) {
          final isSelected = sortOption == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, size: 16, color: isSelected ? Colors.white : ThemeHelper.textSecondaryColor(context)),
                  const SizedBox(width: 4),
                  Text(
                    option.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : ThemeHelper.textSecondaryColor(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onPressed: () => onSortOptionChanged(option),
              backgroundColor: isSelected ? ThemeHelper.favoriteColor : ThemeHelper.backgroundColor(context),
              elevation: isSelected ? 4 : 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularVenuesSection() {
    final popularVenues = VenueRecommendationService.getPopularVenues(nearbyPlaces!, limit: 5);

    if (popularVenues.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Popular Near Stadium',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularVenues.length,
            itemBuilder: (context, index) {
              final venue = popularVenues[index];
              return SizedBox(
                width: 280,
                child: EnhancedVenueCard(
                  venue: venue,
                  stadiumLat: stadiumLatitude,
                  stadiumLng: stadiumLongitude,
                  onTap: () => onVenueSelected(venue),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
