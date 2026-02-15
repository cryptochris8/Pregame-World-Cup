import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../../../venue_portal/venue_portal.dart';

/// Loading indicator for the nearby venues list.
class NearbyVenuesLoadingWidget extends StatelessWidget {
  const NearbyVenuesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
}

/// Error state for the nearby venues list.
class NearbyVenuesErrorWidget extends StatelessWidget {
  final String message;

  const NearbyVenuesErrorWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Empty state for when no nearby venues are found.
class NearbyVenuesEmptyWidget extends StatelessWidget {
  const NearbyVenuesEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
}

/// Shown when active filters produce no results.
class NearbyVenuesNoFilterResultsWidget extends StatelessWidget {
  const NearbyVenuesNoFilterResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
