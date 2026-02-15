import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// Enhanced venue card that displays venue enhancement information
/// with badges for TVs, specials, capacity, and atmosphere tags.
class EnhancedVenueCard extends StatelessWidget {
  final String venueId;
  final String venueName;
  final String? venueType;
  final String? photoUrl;
  final double? rating;
  final int? reviewCount;
  final String? priceLevel;
  final String? distance;
  final String? walkingTime;
  final VenueEnhancement? enhancement;
  final VoidCallback? onTap;
  final bool showMatchBadge;
  final String? matchId;

  const EnhancedVenueCard({
    super.key,
    required this.venueId,
    required this.venueName,
    this.venueType,
    this.photoUrl,
    this.rating,
    this.reviewCount,
    this.priceLevel,
    this.distance,
    this.walkingTime,
    this.enhancement,
    this.onTap,
    this.showMatchBadge = false,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with badges overlay
            Stack(
              children: [
                // Photo
                Container(
                  height: 140,
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest,
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),

                // Badge overlays
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (_showsThisMatch)
                        _buildBadge(
                          context,
                          icon: Icons.live_tv,
                          label: 'SHOWING',
                          color: Colors.red,
                        ),
                      if (enhancement?.hasTvInfo ?? false) ...[
                        if (_showsThisMatch) const SizedBox(width: 6),
                        _buildBadge(
                          context,
                          icon: Icons.tv,
                          label: '${enhancement!.tvCount} TVs',
                          color: colorScheme.primary,
                        ),
                      ],
                      if (enhancement?.hasActiveSpecials ?? false) ...[
                        const Spacer(),
                        _buildBadge(
                          context,
                          icon: Icons.local_offer,
                          label: 'DEAL',
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),

                // Capacity indicator (bottom right)
                if (enhancement?.hasCapacityInfo ?? false)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildCapacityBadge(context),
                  ),
              ],
            ),

            // Venue info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    venueName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating, price, distance
                  Row(
                    children: [
                      if (rating != null) ...[
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (reviewCount != null) ...[
                          Text(
                            ' (${_formatReviewCount(reviewCount!)})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                      if (priceLevel != null) ...[
                        const Text(' · '),
                        Text(
                          priceLevel!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (distance != null) ...[
                        const Text(' · '),
                        Text(
                          distance!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Atmosphere tags
                  if (enhancement?.hasAtmosphereInfo ?? false) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (enhancement!.atmosphere!.tags.take(3).toList())
                          .map((tag) => _buildAtmosphereChip(context, tag))
                          .toList(),
                    ),
                  ],

                  // Active special preview
                  if (enhancement?.hasActiveSpecials ?? false) ...[
                    const SizedBox(height: 8),
                    _buildSpecialPreview(context),
                  ],

                  // Capacity status
                  if (enhancement?.hasCapacityInfo ?? false) ...[
                    const SizedBox(height: 8),
                    _buildCapacityRow(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showsThisMatch {
    if (!showMatchBadge || matchId == null) return false;
    return enhancement?.isBroadcastingMatch(matchId!) ?? false;
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityBadge(BuildContext context) {
    final capacity = enhancement!.liveCapacity!;
    final percent = capacity.occupancyPercent;

    Color color;
    if (percent >= 95) {
      color = Colors.red;
    } else if (percent >= 80) {
      color = Colors.orange;
    } else if (percent >= 50) {
      color = Colors.yellow.shade700;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            capacity.occupancyText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphereChip(BuildContext context, String tag) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedTag = tag
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        formattedTag,
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSpecialPreview(BuildContext context) {
    final special = enhancement!.activeSpecials.first;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, size: 14, color: Colors.orange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${special.title} - ${special.displayPrice}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityRow(BuildContext context) {
    final capacity = enhancement!.liveCapacity!;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.groups, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          capacity.statusText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (capacity.waitTimeMinutes != null && capacity.waitTimeMinutes! > 0) ...[
          const Text(' · '),
          Text(
            capacity.waitTimeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// Compact version for list views
class EnhancedVenueListTile extends StatelessWidget {
  final String venueId;
  final String venueName;
  final String? venueType;
  final String? photoUrl;
  final double? rating;
  final String? distance;
  final VenueEnhancement? enhancement;
  final VoidCallback? onTap;
  final String? matchId;

  const EnhancedVenueListTile({
    super.key,
    required this.venueId,
    required this.venueName,
    this.venueType,
    this.photoUrl,
    this.rating,
    this.distance,
    this.enhancement,
    this.onTap,
    this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 56,
            height: 56,
            color: colorScheme.surfaceContainerHighest,
            child: photoUrl != null
                ? Image.network(photoUrl!, fit: BoxFit.cover)
                : const Icon(Icons.restaurant),
          ),
        ),
        title: Text(
          venueName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (rating != null) ...[
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(rating!.toStringAsFixed(1)),
            ],
            if (distance != null) ...[
              if (rating != null) const Text(' · '),
              Text(distance!),
            ],
          ],
        ),
        trailing: _buildBadges(context),
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    final badges = <Widget>[];

    if (enhancement?.hasTvInfo ?? false) {
      badges.add(_buildSmallBadge(Icons.tv, '${enhancement!.tvCount}'));
    }

    if (enhancement?.hasActiveSpecials ?? false) {
      badges.add(_buildSmallBadge(Icons.local_offer, '', Colors.orange));
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(mainAxisSize: MainAxisSize.min, children: badges);
  }

  Widget _buildSmallBadge(IconData icon, String label, [Color? color]) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.blue),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
