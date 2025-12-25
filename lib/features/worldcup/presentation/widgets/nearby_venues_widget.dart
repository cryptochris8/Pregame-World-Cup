import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_theme.dart';
import '../../data/services/nearby_venues_service.dart';
import '../bloc/nearby_venues_cubit.dart';

/// Widget to display nearby venues around a stadium
class NearbyVenuesWidget extends StatelessWidget {
  final bool showHeader;
  final int? maxItems;

  const NearbyVenuesWidget({
    super.key,
    this.showHeader = true,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyVenuesCubit, NearbyVenuesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildLoading();
        }

        if (state.errorMessage != null) {
          return _buildError(context, state.errorMessage!);
        }

        if (state.venues.isEmpty) {
          return _buildEmpty();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildHeader(context, state),
            const SizedBox(height: 12),
            _buildTypeFilter(context, state),
            const SizedBox(height: 16),
            _buildVenuesList(context, state),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppTheme.primaryPurple),
            SizedBox(height: 16),
            Text(
              'Finding nearby venues...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<NearbyVenuesCubit>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: Colors.white38, size: 48),
          SizedBox(height: 12),
          Text(
            'No venues found nearby',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            'Try increasing the search radius',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NearbyVenuesState state) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppTheme.secondaryEmerald, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Venues',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.stadium != null)
                Text(
                  'Near ${state.stadium!.displayName}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
            ],
          ),
        ),
        _buildRadiusSelector(context, state),
      ],
    );
  }

  Widget _buildRadiusSelector(BuildContext context, NearbyVenuesState state) {
    return PopupMenuButton<double>(
      initialValue: state.radiusMeters,
      onSelected: (radius) {
        context.read<NearbyVenuesCubit>().setRadius(radius);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 500, child: Text('500m')),
        const PopupMenuItem(value: 1000, child: Text('1 km')),
        const PopupMenuItem(value: 2000, child: Text('2 km')),
        const PopupMenuItem(value: 5000, child: Text('5 km')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.radiusMeters < 1000
                  ? '${state.radiusMeters.toInt()}m'
                  : '${(state.radiusMeters / 1000).toStringAsFixed(0)}km',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, NearbyVenuesState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'All',
            count: state.venues.length,
            isSelected: state.selectedType == 'all',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '🍺 Bars',
            count: state.barCount,
            isSelected: state.selectedType == 'bar',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('bar'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '🍽️ Restaurants',
            count: state.restaurantCount,
            isSelected: state.selectedType == 'restaurant',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('restaurant'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '☕ Cafes',
            count: state.cafeCount,
            isSelected: state.selectedType == 'cafe',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('cafe'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPurple
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesList(BuildContext context, NearbyVenuesState state) {
    final venues = state.filteredVenues;
    final displayVenues = maxItems != null ? venues.take(maxItems!).toList() : venues;

    return Column(
      children: displayVenues.map((venue) => _NearbyVenueCard(venue: venue)).toList(),
    );
  }
}

/// Card displaying a single nearby venue
class _NearbyVenueCard extends StatelessWidget {
  final NearbyVenueResult venue;

  const _NearbyVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openInMaps(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      venue.typeIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Venue info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.place.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            venue.primaryType,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (venue.place.rating != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: AppTheme.accentGold, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              venue.place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (venue.place.priceLevel != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$' * venue.place.priceLevel!,
                              style: const TextStyle(
                                color: AppTheme.secondaryEmerald,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryEmerald.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        venue.distanceFormatted,
                        style: const TextStyle(
                          color: AppTheme.secondaryEmerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.white38, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          venue.walkingTimeFormatted,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    final lat = venue.place.latitude;
    final lng = venue.place.longitude;

    // Open in Google Maps with place ID
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=${venue.place.placeId}');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}

/// Compact list item for nearby venues
class NearbyVenueListTile extends StatelessWidget {
  final NearbyVenueResult venue;
  final VoidCallback? onTap;

  const NearbyVenueListTile({
    super.key,
    required this.venue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(venue.typeIcon, style: const TextStyle(fontSize: 24)),
      title: Text(
        venue.place.name,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${venue.distanceFormatted} • ${venue.walkingTimeFormatted}',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: venue.place.rating != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppTheme.accentGold, size: 16),
                const SizedBox(width: 2),
                Text(
                  venue.place.rating!.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            )
          : null,
      onTap: onTap,
    );
  }
}
