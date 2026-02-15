import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../../../venue_portal/venue_portal.dart';

/// Type filter chips for nearby venues (All, Bars, Restaurants, Cafes).
class NearbyVenuesTypeFilter extends StatelessWidget {
  final NearbyVenuesState state;

  const NearbyVenuesTypeFilter({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
            label: '\u{1F37A} Bars',
            count: state.barCount,
            isSelected: state.selectedType == 'bar',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('bar'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '\u{1F37D}\uFE0F Restaurants',
            count: state.restaurantCount,
            isSelected: state.selectedType == 'restaurant',
            onTap: () => context.read<NearbyVenuesCubit>().setTypeFilter('restaurant'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: '\u2615 Cafes',
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
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPurple
                : Colors.white.withValues(alpha: 0.2),
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
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
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
}

/// Enhancement filter chips (Shows Match, Has TVs, Specials).
class NearbyVenuesEnhancementFilters extends StatelessWidget {
  final VenueFilterState state;
  final String? matchId;

  const NearbyVenuesEnhancementFilters({
    super.key,
    required this.state,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
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
          _buildEnhancementChip(
            context: context,
            label: 'Has TVs',
            icon: Icons.tv,
            isSelected: state.criteria.hasTvs == true,
            onTap: () => context.read<VenueFilterCubit>().toggleHasTvsFilter(),
          ),
          _buildEnhancementChip(
            context: context,
            label: 'Specials',
            icon: Icons.local_offer,
            isSelected: state.criteria.hasSpecials == true,
            onTap: () => context.read<VenueFilterCubit>().toggleHasSpecialsFilter(),
          ),
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => context.read<VenueFilterCubit>().clearAllFilters(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withValues(alpha: 0.2),
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
}
