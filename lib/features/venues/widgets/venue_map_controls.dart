import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom control bar for the venue map screen.
///
/// Provides toggle buttons for distance rings, list view, and my-location.
class VenueMapBottomControls extends StatelessWidget {
  final bool showDistanceRings;
  final VoidCallback onToggleRings;
  final VoidCallback onListView;
  final VoidCallback onMyLocation;

  const VenueMapBottomControls({
    super.key,
    required this.showDistanceRings,
    required this.onToggleRings,
    required this.onListView,
    required this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.layers,
            label: 'Rings',
            isActive: showDistanceRings,
            onPressed: onToggleRings,
          ),
          _buildControlButton(
            icon: Icons.list,
            label: 'List View',
            onPressed: onListView,
          ),
          _buildControlButton(
            icon: Icons.my_location,
            label: 'My Location',
            onPressed: onMyLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEA580C) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF2D1810),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF2D1810),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating action buttons for the venue map (zoom-to-fit, focus-on-stadium).
class VenueMapFloatingButtons extends StatelessWidget {
  final VoidCallback onZoomToFit;
  final VoidCallback onFocusStadium;

  const VenueMapFloatingButtons({
    super.key,
    required this.onZoomToFit,
    required this.onFocusStadium,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 200,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "venue_map_zoom_fab",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1810),
            onPressed: onZoomToFit,
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "venue_map_stadium_fab",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D1810),
            onPressed: onFocusStadium,
            child: const Icon(Icons.stadium),
          ),
        ],
      ),
    );
  }
}
