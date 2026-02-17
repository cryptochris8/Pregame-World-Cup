import 'package:flutter/material.dart';
import 'venue_route_models.dart';

/// Action buttons at the bottom of the venue route panel.
///
/// Provides a primary "Start Navigation" button and a secondary "Share" button.
class VenueRouteActionButtons extends StatelessWidget {
  final RouteOption selectedRoute;
  final VoidCallback onStartNavigation;
  final VoidCallback onShare;

  const VenueRouteActionButtons({
    super.key,
    required this.selectedRoute,
    required this.onStartNavigation,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Start navigation button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onStartNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.navigation, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start ${selectedRoute.displayName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Share route button
          OutlinedButton(
            onPressed: onShare,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B4513),
              side: const BorderSide(color: Color(0xFF8B4513)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.share, size: 20),
          ),
        ],
      ),
    );
  }
}
