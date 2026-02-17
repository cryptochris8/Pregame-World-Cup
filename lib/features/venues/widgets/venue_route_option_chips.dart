import 'package:flutter/material.dart';
import '../../../core/services/venue_recommendation_service.dart';
import 'venue_route_models.dart';

/// A row of selectable route option chips (Walking, Driving, Transit).
///
/// Each chip shows the transport mode icon, label, and estimated time.
class VenueRouteOptionChips extends StatelessWidget {
  final RouteOption selectedRoute;
  final RouteDetails? routeDetails;
  final ValueChanged<RouteOption> onRouteSelected;

  const VenueRouteOptionChips({
    super.key,
    required this.selectedRoute,
    this.routeDetails,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip(
            RouteOption.walking,
            Icons.directions_walk,
            'Walking',
            routeDetails?.walkingTime,
          ),
          const SizedBox(width: 12),
          _buildChip(
            RouteOption.driving,
            Icons.directions_car,
            'Driving',
            routeDetails?.drivingTime,
          ),
          const SizedBox(width: 12),
          _buildChip(
            RouteOption.transit,
            Icons.directions_transit,
            'Transit',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    RouteOption option,
    IconData icon,
    String label,
    int? estimatedTime,
  ) {
    final isSelected = selectedRoute == option;

    return Expanded(
      child: GestureDetector(
        onTap: () => onRouteSelected(option),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF8B4513)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B4513)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              if (estimatedTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  VenueRecommendationService.formatWalkingTime(estimatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
