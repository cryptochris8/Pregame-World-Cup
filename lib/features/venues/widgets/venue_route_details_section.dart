import 'package:flutter/material.dart';
import '../../../core/services/venue_recommendation_service.dart';
import 'venue_route_models.dart';

/// Displays the route summary (time, distance, mode) and a scrollable
/// list of turn-by-turn direction steps.
class VenueRouteDetailsSection extends StatelessWidget {
  final RouteDetails routeDetails;
  final RouteOption selectedRoute;

  const VenueRouteDetailsSection({
    super.key,
    required this.routeDetails,
    required this.selectedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary
          _buildRouteSummary(),
          const SizedBox(height: 20),

          // Route steps
          const Text(
            'Directions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1810),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: routeDetails.steps.length,
              itemBuilder: (context, index) {
                final step = routeDetails.steps[index];
                return _RouteStepTile(
                  step: step,
                  index: index,
                  totalSteps: routeDetails.steps.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B4513).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            _getRouteIcon(),
            color: const Color(0xFF8B4513),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEstimatedTime(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                ),
                Text(
                  '${(routeDetails.distance / 1000).toStringAsFixed(1)} km via ${_getRouteDescription()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Fastest',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D6A4F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRouteIcon() {
    switch (selectedRoute) {
      case RouteOption.walking:
        return Icons.directions_walk;
      case RouteOption.driving:
        return Icons.directions_car;
      case RouteOption.transit:
        return Icons.directions_transit;
    }
  }

  String _getEstimatedTime() {
    switch (selectedRoute) {
      case RouteOption.walking:
        return VenueRecommendationService.formatWalkingTime(routeDetails.walkingTime);
      case RouteOption.driving:
        return VenueRecommendationService.formatWalkingTime(routeDetails.drivingTime);
      case RouteOption.transit:
        return '15 min';
    }
  }

  String _getRouteDescription() {
    switch (selectedRoute) {
      case RouteOption.walking:
        return 'sidewalks and paths';
      case RouteOption.driving:
        return 'city streets';
      case RouteOption.transit:
        return 'public transit';
    }
  }
}

/// A single direction step tile with step indicator and instruction text.
class _RouteStepTile extends StatelessWidget {
  final RouteStep step;
  final int index;
  final int totalSteps;

  const _RouteStepTile({
    required this.step,
    required this.index,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFF2D6A4F)
                  : index == totalSteps - 1
                      ? const Color(0xFFD32F2F)
                      : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: index == 0
                  ? const Icon(Icons.my_location, color: Colors.white, size: 16)
                  : index == totalSteps - 1
                      ? const Icon(Icons.location_on, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 12),

          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D1810),
                  ),
                ),
                if (step.distance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.distance!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
