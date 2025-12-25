import 'package:flutter/material.dart';
import '../../../../core/entities/game_intelligence.dart';
import '../../../../services/espn_service.dart';
import '../../../../config/theme_helper.dart';

/// Widget that displays ESPN-powered game intelligence including crowd factors,
/// revenue projections, and venue recommendations
class ESPNGameInsightsWidget extends StatefulWidget {
  final String gameId;
  final String homeTeam;
  final String awayTeam;
  final bool isCompact; // For display in list vs detailed view

  const ESPNGameInsightsWidget({
    super.key,
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    this.isCompact = true,
  });

  @override
  State<ESPNGameInsightsWidget> createState() => _ESPNGameInsightsWidgetState();
}

class _ESPNGameInsightsWidgetState extends State<ESPNGameInsightsWidget> {
  GameIntelligence? _intelligence;
  bool _isLoading = false;
  String? _error;
  final ESPNService _espnService = ESPNService();

  @override
  void initState() {
    super.initState();
    _loadGameIntelligence();
  }

  Future<void> _loadGameIntelligence() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try with the provided gameId
      var intelligence = await _espnService.getGameIntelligence(widget.gameId);
      
      // If that fails and we have team names, try to find the ESPN game ID
      if (intelligence == null && widget.homeTeam != null && widget.awayTeam != null) {
        final espnGameId = await _espnService.findESPNGameId(
          homeTeam: widget.homeTeam!,
          awayTeam: widget.awayTeam!,
        );
        
        if (espnGameId != null) {
          intelligence = await _espnService.getGameIntelligence(espnGameId);
        }
      }
      
      if (mounted) {
        setState(() {
          _intelligence = intelligence;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load game insights';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_intelligence == null) {
      return const SizedBox.shrink();
    }

    return widget.isCompact ? _buildCompactView() : _buildDetailedView();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading ESPN insights...',
            style: TextStyle(
              color: Colors.blue[100],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[300], size: 16),
          const SizedBox(width: 8),
          Text(
            _error!,
            style: TextStyle(
              color: Colors.red[100],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView() {
    final intelligence = _intelligence!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.8), // ESPN blue
            Colors.orange[800]!.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange[900]!.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ESPN branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ESPN',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Game Intelligence',
                  style: TextStyle(
                    color: Colors.orange[100],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (intelligence.isRivalryGame) ...[
                Icon(
                  Icons.whatshot,
                  color: Colors.orange[300],
                  size: 16,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                '${(intelligence.crowdFactor * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: _getCrowdFactorColor(intelligence.crowdFactor),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Key metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricChip(
                'Crowd',
                '${intelligence.crowdFactor.toStringAsFixed(1)}x',
                _getCrowdFactorColor(intelligence.crowdFactor),
              ),
              _buildMetricChip(
                'Revenue',
                '+${intelligence.venueRecommendations.expectedTrafficIncrease.toStringAsFixed(0)}%',
                Colors.green[300]!,
              ),
              if (intelligence.isRivalryGame)
                _buildMetricChip(
                  'Rivalry',
                  '🔥',
                  Colors.orange[300]!,
                ),
              if (intelligence.hasChampionshipImplications)
                _buildMetricChip(
                  'Championship',
                  '🏆',
                  Colors.yellow[300]!,
                ),
            ],
          ),
          
          // Key storylines (first one only in compact view)
          if (intelligence.keyStorylines.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              intelligence.keyStorylines.first,
              style: TextStyle(
                color: Colors.orange[200],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    final intelligence = _intelligence!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.9), // ESPN blue
            Colors.orange[800]!.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange[900]!.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ESPN GAME INTELLIGENCE',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.analytics,
                color: Colors.orange[200],
                size: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main metrics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildDetailedMetricCard(
                'Crowd Factor',
                '${intelligence.crowdFactor.toStringAsFixed(1)}x normal',
                Icons.people,
                _getCrowdFactorColor(intelligence.crowdFactor),
              ),
              _buildDetailedMetricCard(
                'Revenue Boost',
                '+${intelligence.venueRecommendations.expectedTrafficIncrease.toStringAsFixed(0)}%',
                Icons.trending_up,
                Colors.green[300]!,
              ),
              _buildDetailedMetricCard(
                'TV Audience',
                '${intelligence.expectedTvAudience.toStringAsFixed(1)}M',
                Icons.tv,
                Colors.blue[300]!,
              ),
              _buildDetailedMetricCard(
                'Network',
                intelligence.broadcastNetwork,
                Icons.broadcast_on_home,
                Colors.purple[300]!,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Storylines
          if (intelligence.keyStorylines.isNotEmpty) ...[
            Text(
              'Key Storylines',
              style: TextStyle(
                color: Colors.orange[200],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...intelligence.keyStorylines.map((storyline) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: Colors.orange[300],
                    size: 8,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      storyline,
                      style: TextStyle(
                        color: Colors.orange[100],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          
          // Venue recommendations summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Venue Recommendations',
                  style: TextStyle(
                    color: Colors.orange[200],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  intelligence.venueRecommendations.staffingRecommendation,
                  style: TextStyle(
                    color: Colors.orange[100],
                    fontSize: 11,
                  ),
                ),
                if (intelligence.venueRecommendations.suggestedSpecials.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Suggested: ${intelligence.venueRecommendations.suggestedSpecials.first}',
                    style: TextStyle(
                      color: Colors.green[200],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
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

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCrowdFactorColor(double factor) {
    if (factor >= 2.5) return Colors.red[300]!;      // High crowd (red-hot)
    if (factor >= 2.0) return Colors.orange[300]!;   // High crowd (orange)
    if (factor >= 1.5) return Colors.yellow[300]!;   // Medium crowd (yellow)
    return Colors.green[300]!;                       // Normal crowd (green)
  }
} 