import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_theme.dart';
import '../../data/services/nearby_venues_service.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../../../venue_portal/venue_portal.dart';
import '../../../venues/screens/venue_detail_screen.dart';

/// Widget to display nearby venues around a stadium
class NearbyVenuesWidget extends StatelessWidget {
  final bool showHeader;
  final int? maxItems;
  final String? matchId;

  const NearbyVenuesWidget({
    super.key,
    this.showHeader = true,
    this.maxItems,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get VenueFilterCubit if available
    final filterCubit = context.read<VenueFilterCubit?>();

    return BlocConsumer<NearbyVenuesCubit, NearbyVenuesState>(
      listener: (context, venuesState) {
        // Load enhancements when venues change
        if (filterCubit != null && venuesState.venues.isNotEmpty) {
          final venueIds = venuesState.venues.map((v) => v.place.placeId).toList();
          filterCubit.loadEnhancementsForVenues(venueIds);
        }
      },
      builder: (context, venuesState) {
        if (venuesState.isLoading) {
          return _buildLoading();
        }

        if (venuesState.errorMessage != null) {
          return _buildError(context, venuesState.errorMessage!);
        }

        if (venuesState.venues.isEmpty) {
          return _buildEmpty();
        }

        if (filterCubit == null) {
          // No filter cubit, render without enhancement filters
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) _buildHeader(context, venuesState),
              const SizedBox(height: 12),
              _buildTypeFilter(context, venuesState),
              const SizedBox(height: 16),
              _buildVenuesList(context, venuesState, null),
            ],
          );
        }

        return BlocBuilder<VenueFilterCubit, VenueFilterState>(
          builder: (context, filterState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) _buildHeader(context, venuesState),
                const SizedBox(height: 12),
                _buildTypeFilter(context, venuesState),
                const SizedBox(height: 8),
                _buildEnhancementFilters(context, filterState),
                const SizedBox(height: 16),
                _buildVenuesList(context, venuesState, filterState),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancementFilters(BuildContext context, VenueFilterState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Shows Match filter (if matchId provided)
          if (matchId != null)
            _buildEnhancementChip(
              context: context,
              label: 'Shows Match',
              icon: Icons.live_tv,
              isSelected: state.criteria.showsMatchId == matchId,
              onTap: () {
                final cubit = context.read<VenueFilterCubit>();
                if (state.criteria.showsMatchId == matchId) {
                  cubit.setShowsMatchFilter(null);
                } else {
                  cubit.setShowsMatchFilter(matchId);
                }
              },
            ),
          // Has TVs filter
          _buildEnhancementChip(
            context: context,
            label: 'Has TVs',
            icon: Icons.tv,
            isSelected: state.criteria.hasTvs == true,
            onTap: () => context.read<VenueFilterCubit>().toggleHasTvsFilter(),
          ),
          // Has Specials filter
          _buildEnhancementChip(
            context: context,
            label: 'Specials',
            icon: Icons.local_offer,
            isSelected: state.criteria.hasSpecials == true,
            onTap: () => context.read<VenueFilterCubit>().toggleHasSpecialsFilter(),
          ),
          // Clear filters button
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => context.read<VenueFilterCubit>().clearAllFilters(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear, color: Colors.red, size: 14),
                      SizedBox(width: 4),
                      Text('Clear', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancementChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.secondaryEmerald
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildVenuesList(
    BuildContext context,
    NearbyVenuesState venuesState,
    VenueFilterState? filterState,
  ) {
    var venues = venuesState.filteredVenues;

    // Apply enhancement filters if available
    if (filterState != null && filterState.hasActiveFilters) {
      venues = venues.where((venue) {
        final venueId = venue.place.placeId;
        return filterState.venuePassesFilters(venueId);
      }).toList();
    }

    final displayVenues = maxItems != null ? venues.take(maxItems!).toList() : venues;

    if (displayVenues.isEmpty && filterState?.hasActiveFilters == true) {
      return _buildNoFilterResults();
    }

    return Column(
      children: displayVenues.map((venue) {
        final enhancement = filterState?.getEnhancement(venue.place.placeId);
        return _NearbyVenueCard(
          venue: venue,
          enhancement: enhancement,
          matchId: matchId,
        );
      }).toList(),
    );
  }

  Widget _buildNoFilterResults() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.filter_alt_off, color: Colors.white38, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No venues match your filters',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try removing some filters to see more results',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              return ElevatedButton.icon(
                onPressed: () => context.read<VenueFilterCubit>().clearAllFilters(),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Card displaying a single nearby venue with photo and reviews
class _NearbyVenueCard extends StatefulWidget {
  final NearbyVenueResult venue;
  final VenueEnhancement? enhancement;
  final String? matchId;

  const _NearbyVenueCard({
    required this.venue,
    this.enhancement,
    this.matchId,
  });

  @override
  State<_NearbyVenueCard> createState() => _NearbyVenueCardState();
}

class _NearbyVenueCardState extends State<_NearbyVenueCard> {
  String? _photoUrl;

  NearbyVenueResult get venue => widget.venue;
  VenueEnhancement? get enhancement => widget.enhancement;

  @override
  void initState() {
    super.initState();
    _buildPhotoUrl();
  }

  void _buildPhotoUrl() {
    // Use photoReference from the place if available
    // Route through our Cloud Function proxy to avoid CORS issues in browser
    final photoRef = venue.place.photoReference;
    // Debug output removed
    if (photoRef != null && photoRef.isNotEmpty) {
      // Use Cloud Function proxy to avoid CORS blocking from browser
      _photoUrl = 'https://us-central1-pregame-b089e.cloudfunctions.net/placePhotoProxy'
          '?photoReference=$photoRef&maxWidth=200';
      // Debug output removed
    } else {
      // Debug output removed
    }
  }

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
          onTap: () => _openVenueDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Photo or type icon
                _buildPhotoSection(),
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
                      // Type row
                      Text(
                        venue.primaryType,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Rating and price row
                      Row(
                        children: [
                          if (venue.place.rating != null) ...[
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
                            // Review count
                            if (venue.place.userRatingsTotal != null &&
                                venue.place.userRatingsTotal! > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${_formatReviewCount(venue.place.userRatingsTotal!)})',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
                      // Enhancement badges
                      if (enhancement != null) ...[
                        const SizedBox(height: 6),
                        _buildEnhancementBadges(),
                      ],
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

  Widget _buildPhotoSection() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _photoUrl != null
            ? Image.network(
                _photoUrl!,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryPurple.withOpacity(0.5),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildFallbackIcon(),
              )
            : _buildFallbackIcon(),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Text(
        venue.typeIcon,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  /// Navigate to the venue detail screen
  void _openVenueDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venue: venue.place,
        ),
      ),
    );
  }

  /// Open venue in Google Maps (kept as fallback/alternative)
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

  Widget _buildEnhancementBadges() {
    final badges = <Widget>[];

    // Shows this match badge
    if (widget.matchId != null && enhancement!.isBroadcastingMatch(widget.matchId!)) {
      badges.add(_buildBadge(
        icon: Icons.live_tv,
        label: 'SHOWING',
        color: Colors.red,
      ));
    }

    // Has TVs badge
    if (enhancement!.hasTvInfo) {
      badges.add(_buildBadge(
        icon: Icons.tv,
        label: '${enhancement!.tvSetup!.totalScreens} TVs',
        color: AppTheme.primaryPurple,
      ));
    }

    // Has specials badge
    if (enhancement!.hasActiveSpecials) {
      badges.add(_buildBadge(
        icon: Icons.local_offer,
        label: 'DEALS',
        color: AppTheme.secondaryEmerald,
      ));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: badges,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
