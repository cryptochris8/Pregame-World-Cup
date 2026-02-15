import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../../../venue_portal/venue_portal.dart';
import 'nearby_venue_card.dart';
import 'nearby_venues_filter_chips.dart';
import 'nearby_venues_state_widgets.dart';

// Re-export extracted widgets so existing imports continue to work
export 'nearby_venue_list_tile.dart';

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
    final filterCubit = context.read<VenueFilterCubit?>();

    return BlocConsumer<NearbyVenuesCubit, NearbyVenuesState>(
      listener: (context, venuesState) {
        if (filterCubit != null && venuesState.venues.isNotEmpty) {
          final venueIds = venuesState.venues.map((v) => v.place.placeId).toList();
          filterCubit.loadEnhancementsForVenues(venueIds);
        }
      },
      builder: (context, venuesState) {
        if (venuesState.isLoading) {
          return const NearbyVenuesLoadingWidget();
        }

        if (venuesState.errorMessage != null) {
          return NearbyVenuesErrorWidget(message: venuesState.errorMessage!);
        }

        if (venuesState.venues.isEmpty) {
          return const NearbyVenuesEmptyWidget();
        }

        if (filterCubit == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) _buildHeader(context, venuesState),
              const SizedBox(height: 12),
              NearbyVenuesTypeFilter(state: venuesState),
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
                NearbyVenuesTypeFilter(state: venuesState),
                const SizedBox(height: 8),
                NearbyVenuesEnhancementFilters(
                  state: filterState,
                  matchId: matchId,
                ),
                const SizedBox(height: 16),
                _buildVenuesList(context, venuesState, filterState),
              ],
            );
          },
        );
      },
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
          color: Colors.white.withValues(alpha: 0.1),
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

  Widget _buildVenuesList(
    BuildContext context,
    NearbyVenuesState venuesState,
    VenueFilterState? filterState,
  ) {
    var venues = venuesState.filteredVenues;

    if (filterState != null && filterState.hasActiveFilters) {
      venues = venues.where((venue) {
        final venueId = venue.place.placeId;
        return filterState.venuePassesFilters(venueId);
      }).toList();
    }

    final displayVenues = maxItems != null ? venues.take(maxItems!).toList() : venues;

    if (displayVenues.isEmpty && filterState?.hasActiveFilters == true) {
      return const NearbyVenuesNoFilterResultsWidget();
    }

    return Column(
      children: displayVenues.map((venue) {
        final enhancement = filterState?.getEnhancement(venue.place.placeId);
        return NearbyVenueCard(
          venue: venue,
          enhancement: enhancement,
          matchId: matchId,
        );
      }).toList(),
    );
  }
}
