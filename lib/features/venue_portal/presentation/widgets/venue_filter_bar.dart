import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/venue_filter_cubit.dart';

/// Filter bar for venue searches, allowing users to filter by
/// match broadcasting, TVs, specials, and atmosphere tags.
class VenueFilterBar extends StatelessWidget {
  final String? matchId;
  final String? matchLabel;

  const VenueFilterBar({
    super.key,
    this.matchId,
    this.matchLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueFilterCubit, VenueFilterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Shows match filter (if matchId provided)
              if (matchId != null)
                _buildFilterChip(
                  context,
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
              _buildFilterChip(
                context,
                label: 'Has TVs',
                icon: Icons.tv,
                isSelected: state.criteria.hasTvs == true,
                onTap: () {
                  context.read<VenueFilterCubit>().toggleHasTvsFilter();
                },
              ),

              // Has Specials filter
              _buildFilterChip(
                context,
                label: 'Specials',
                icon: Icons.local_offer,
                isSelected: state.criteria.hasSpecials == true,
                onTap: () {
                  context.read<VenueFilterCubit>().toggleHasSpecialsFilter();
                },
              ),

              // Clear filters button
              if (state.hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: () {
                      context.read<VenueFilterCubit>().clearAllFilters();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? colorScheme.onPrimaryContainer : null,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// Expandable filter sheet for more detailed filtering options
class VenueFilterSheet extends StatelessWidget {
  final String? matchId;

  const VenueFilterSheet({super.key, this.matchId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<VenueFilterCubit, VenueFilterState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Venues',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              context.read<VenueFilterCubit>().clearAllFilters();
                            },
                            child: const Text('Clear All'),
                          ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Filter options
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Broadcasting
                        if (matchId != null) ...[
                          _buildSectionHeader(context, 'Broadcasting'),
                          SwitchListTile(
                            value: state.criteria.showsMatchId == matchId,
                            onChanged: (value) {
                              final cubit = context.read<VenueFilterCubit>();
                              cubit.setShowsMatchFilter(value ? matchId : null);
                            },
                            title: const Text('Shows This Match'),
                            subtitle: const Text(
                                'Only show venues broadcasting this match'),
                            secondary: const Icon(Icons.live_tv),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Setup
                        _buildSectionHeader(context, 'Setup'),
                        SwitchListTile(
                          value: state.criteria.hasTvs == true,
                          onChanged: (value) {
                            context
                                .read<VenueFilterCubit>()
                                .setHasTvsFilter(value ? true : null);
                          },
                          title: const Text('Has TVs'),
                          subtitle:
                              const Text('Venues with TV/screen information'),
                          secondary: const Icon(Icons.tv),
                        ),

                        const SizedBox(height: 16),

                        // Specials
                        _buildSectionHeader(context, 'Offers'),
                        SwitchListTile(
                          value: state.criteria.hasSpecials == true,
                          onChanged: (value) {
                            context
                                .read<VenueFilterCubit>()
                                .setHasSpecialsFilter(value ? true : null);
                          },
                          title: const Text('Has Specials'),
                          subtitle: const Text('Venues with active deals'),
                          secondary: const Icon(Icons.local_offer),
                        ),

                        const SizedBox(height: 16),

                        // Capacity
                        _buildSectionHeader(context, 'Availability'),
                        SwitchListTile(
                          value: state.criteria.hasCapacityInfo == true,
                          onChanged: (value) {
                            context
                                .read<VenueFilterCubit>()
                                .setHasCapacityFilter(value ? true : null);
                          },
                          title: const Text('Live Capacity Info'),
                          subtitle:
                              const Text('Shows real-time occupancy data'),
                          secondary: const Icon(Icons.groups),
                        ),

                        const SizedBox(height: 16),

                        // Atmosphere tags
                        _buildSectionHeader(context, 'Atmosphere'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'family-friendly',
                            '21+',
                            'rowdy',
                            'chill',
                            'upscale',
                            'casual',
                            'outdoor-seating',
                          ].map((tag) {
                            final isSelected =
                                state.criteria.atmosphereTags.contains(tag);
                            return FilterChip(
                              label: Text(_formatTag(tag)),
                              selected: isSelected,
                              onSelected: (selected) {
                                final cubit = context.read<VenueFilterCubit>();
                                if (selected) {
                                  cubit.addAtmosphereTag(tag);
                                } else {
                                  cubit.removeAtmosphereTag(tag);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Apply button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          state.hasActiveFilters
                              ? 'Apply ${state.activeFilterCount} Filter${state.activeFilterCount == 1 ? '' : 's'}'
                              : 'Done',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _formatTag(String tag) {
    return tag
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Shows the filter sheet in a modal bottom sheet
void showVenueFilterSheet(BuildContext context, {String? matchId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => VenueFilterSheet(matchId: matchId),
  );
}
