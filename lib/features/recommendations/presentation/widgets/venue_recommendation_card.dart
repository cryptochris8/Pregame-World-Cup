import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/smart_venue_recommendation_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../domain/entities/place.dart';

/// A card displaying a single smart venue recommendation with rank, score,
/// tags, reasoning, and action buttons.
class VenueRecommendationCard extends StatelessWidget {
  final SmartVenueRecommendation recommendation;
  final int index;
  final Function(Place)? onVenueSelected;
  final Function(Place)? onVenueFavorited;

  const VenueRecommendationCard({
    super.key,
    required this.recommendation,
    required this.index,
    this.onVenueSelected,
    this.onVenueFavorited,
  });

  @override
  Widget build(BuildContext context) {
    final venue = recommendation.venue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: const Color(0xFF334155),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleVenueSelection(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(venue),
              const SizedBox(height: 12),
              if (recommendation.tags.isNotEmpty) _buildTags(),
              const SizedBox(height: 8),
              _buildReasoning(),
              const SizedBox(height: 12),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(Place venue) {
    return Row(
      children: [
        // Rank badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getRankGradient(index),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Venue info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venue.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (venue.rating != null) ...[
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text(
                      venue.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (venue.rating != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text(
                      venue.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Smart score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getScoreColor(recommendation.smartScore),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(recommendation.smartScore * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: recommendation.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF475569),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF64748B)),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasoning() {
    return Text(
      recommendation.reasoning,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 13,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleVenueSelection(context),
            icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF6B35)),
            label: const Text(
              'View Details',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B35)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _handleVenueFavorite(context),
          icon: Icon(
            Icons.favorite_border,
            color: Colors.red.shade400,
            size: 20,
          ),
          tooltip: 'Add to favorites',
        ),
      ],
    );
  }

  List<Color> _getRankGradient(int index) {
    if (index == 0) {
      return [Colors.amber.shade600, Colors.orange.shade600];
    } else if (index == 1) {
      return [Colors.grey.shade500, Colors.grey.shade600];
    } else if (index == 2) {
      return [Colors.brown.shade400, Colors.brown.shade600];
    } else {
      return [Colors.blue.shade400, Colors.blue.shade600];
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) {
      return Colors.green.shade600;
    } else if (score >= 0.6) {
      return Colors.orange.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  void _handleVenueSelection(BuildContext context) {
    LoggingService.info(
      'Venue selected: ${recommendation.venue.name} (score: ${recommendation.smartScore})',
      tag: 'SmartVenueDiscovery',
    );
    onVenueSelected?.call(recommendation.venue);
    HapticFeedback.lightImpact();
  }

  void _handleVenueFavorite(BuildContext context) {
    LoggingService.info(
      'Venue favorited: ${recommendation.venue.name}',
      tag: 'SmartVenueDiscovery',
    );
    onVenueFavorited?.call(recommendation.venue);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recommendation.venue.name} to favorites!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}
