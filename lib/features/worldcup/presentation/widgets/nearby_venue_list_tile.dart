import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../data/services/nearby_venues_service.dart';

/// Compact list item for nearby venues.
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
        '${venue.distanceFormatted} \u2022 ${venue.walkingTimeFormatted}',
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
