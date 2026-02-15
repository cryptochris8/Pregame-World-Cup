import 'package:flutter/material.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';

/// Reusable widget to display ESPN game intelligence
/// Can be integrated into venue screens, game details, etc.
class ESPNGameIntelligenceCard extends StatelessWidget {
  final GameIntelligence intelligence;
  final bool showFullDetails;

  const ESPNGameIntelligenceCard({
    super.key,
    required this.intelligence,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B), // Dark blue-gray
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with game and crowd factor
            _buildHeader(),
            
            const SizedBox(height: 12),
            
            // Key indicators
            _buildIndicators(),
            
            const SizedBox(height: 16),
            
            // Revenue projection highlight
            _buildRevenueProjection(),
            
            if (showFullDetails) ...[
              const SizedBox(height: 16),
              _buildRecommendations(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${intelligence.awayTeam} @ ${intelligence.homeTeam}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.tv,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    intelligence.broadcastNetwork,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  if (intelligence.expectedTvAudience > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${intelligence.expectedTvAudience.toStringAsFixed(1)}M viewers',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Crowd factor badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCrowdFactorColor(intelligence.crowdFactor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${intelligence.crowdFactor.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (intelligence.isRivalryGame)
          _buildIndicatorChip(
            '⚡ Rivalry',
            Colors.red,
            Icons.flash_on,
          ),
        if (intelligence.hasChampionshipImplications)
          _buildIndicatorChip(
            '🏆 Championship',
            Colors.purple,
            Icons.emoji_events,
          ),
        if (intelligence.homeTeamRank != null)
          _buildIndicatorChip(
            'Home #${intelligence.homeTeamRank}',
            Colors.blue,
            Icons.star,
          ),
        if (intelligence.awayTeamRank != null)
          _buildIndicatorChip(
            'Away #${intelligence.awayTeamRank}',
            Colors.blue,
            Icons.star_outline,
          ),
        _buildIndicatorChip(
          'Confidence ${(intelligence.confidenceScore * 100).toInt()}%',
          Colors.green,
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildIndicatorChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueProjection() {
    final recommendations = intelligence.venueRecommendations;
    final trafficIncrease = recommendations.expectedTrafficIncrease;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha:0.1),
            Colors.green.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Projection',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${recommendations.revenueProjection.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trafficIncrease > 0)
                  Text(
                    '+${trafficIncrease.toStringAsFixed(0)}% vs normal game',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = intelligence.venueRecommendations;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Venue Recommendations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Staffing recommendation
        _buildRecommendationRow(
          Icons.people,
          'Staffing',
          recommendations.staffingRecommendation,
          Colors.blue,
        ),
        
        const SizedBox(height: 8),
        
        // Marketing opportunity
        _buildRecommendationRow(
          Icons.campaign,
          'Marketing',
          recommendations.marketingOpportunity,
          Colors.purple,
        ),
        
        const SizedBox(height: 8),
        
        // Inventory advice (if not empty)
        if (recommendations.inventoryAdvice.isNotEmpty)
          _buildRecommendationRow(
            Icons.inventory,
            'Inventory',
            recommendations.inventoryAdvice,
            Colors.orange,
          ),
        
        // Suggested specials
        if (recommendations.suggestedSpecials.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSpecialsSection(recommendations.suggestedSpecials),
        ],
      ],
    );
  }

  Widget _buildRecommendationRow(
    IconData icon, 
    String title, 
    String content, 
    Color color
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialsSection(List<String> specials) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'Suggested Specials',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...specials.take(3).map((special) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.amber, size: 6),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    special,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getCrowdFactorColor(double factor) {
    if (factor >= 2.5) return Colors.red.shade600;
    if (factor >= 2.0) return Colors.orange.shade600;
    if (factor >= 1.5) return Colors.yellow.shade600;
    return Colors.green.shade600;
  }
}

/// Compact version for lists
class ESPNGameIntelligenceCompactCard extends StatelessWidget {
  final GameIntelligence intelligence;
  final VoidCallback? onTap;

  const ESPNGameIntelligenceCompactCard({
    super.key,
    required this.intelligence,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Game info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${intelligence.awayTeam} @ ${intelligence.homeTeam}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (intelligence.isRivalryGame)
                          const Icon(
                            Icons.flash_on,
                            color: Colors.red,
                            size: 12,
                          ),
                        if (intelligence.hasChampionshipImplications) ...[
                          if (intelligence.isRivalryGame) const SizedBox(width: 4),
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.purple,
                            size: 12,
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '\$${intelligence.venueRecommendations.revenueProjection.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Crowd factor badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCrowdFactorColor(intelligence.crowdFactor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${intelligence.crowdFactor.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCrowdFactorColor(double factor) {
    if (factor >= 2.5) return Colors.red.shade600;
    if (factor >= 2.0) return Colors.orange.shade600;
    if (factor >= 1.5) return Colors.yellow.shade600;
    return Colors.green.shade600;
  }
} 