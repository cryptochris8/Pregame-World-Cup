import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../data/services/nearby_venues_service.dart';
import '../../../venue_portal/venue_portal.dart';
import '../../../venues/screens/venue_detail_screen.dart';

/// Card displaying a single nearby venue with photo and reviews.
class NearbyVenueCard extends StatefulWidget {
  final NearbyVenueResult venue;
  final VenueEnhancement? enhancement;
  final String? matchId;

  const NearbyVenueCard({
    super.key,
    required this.venue,
    this.enhancement,
    this.matchId,
  });

  @override
  State<NearbyVenueCard> createState() => _NearbyVenueCardState();
}

class _NearbyVenueCardState extends State<NearbyVenueCard> {
  String? _photoUrl;

  NearbyVenueResult get venue => widget.venue;
  VenueEnhancement? get enhancement => widget.enhancement;

  @override
  void initState() {
    super.initState();
    _buildPhotoUrl();
  }

  void _buildPhotoUrl() {
    final photoRef = venue.place.photoReference;
    if (photoRef != null && photoRef.isNotEmpty) {
      _photoUrl = 'https://us-central1-pregame-b089e.cloudfunctions.net/placePhotoProxy'
          '?photoReference=$photoRef&maxWidth=200';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                _buildPhotoSection(),
                const SizedBox(width: 12),
                Expanded(child: _buildVenueInfo()),
                _buildDistanceColumn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVenueInfo() {
    return Column(
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
        Text(
          venue.primaryType,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        _buildRatingAndPrice(),
        if (enhancement != null) ...[
          const SizedBox(height: 6),
          _buildEnhancementBadges(),
        ],
      ],
    );
  }

  Widget _buildRatingAndPrice() {
    return Row(
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
    );
  }

  Widget _buildDistanceColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.secondaryEmerald.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
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
                        color: AppTheme.primaryPurple.withValues(alpha: 0.5),
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

  void _openVenueDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(
          venue: venue.place,
        ),
      ),
    );
  }

  Widget _buildEnhancementBadges() {
    final badges = <Widget>[];

    if (widget.matchId != null && enhancement!.isBroadcastingMatch(widget.matchId!)) {
      badges.add(_buildBadge(
        icon: Icons.live_tv,
        label: 'SHOWING',
        color: Colors.red,
      ));
    }

    if (enhancement!.hasTvInfo) {
      badges.add(_buildBadge(
        icon: Icons.tv,
        label: '${enhancement!.tvSetup!.totalScreens} TVs',
        color: AppTheme.primaryPurple,
      ));
    }

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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
