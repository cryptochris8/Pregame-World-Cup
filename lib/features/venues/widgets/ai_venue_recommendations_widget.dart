import 'package:flutter/material.dart';
import '../../../core/ai/entities/ai_recommendation.dart';
import '../../../core/services/unified_venue_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../injection_container.dart';

class AIVenueRecommendationsWidget extends StatefulWidget {
  final Place currentVenue;
  final List<Place> nearbyVenues;

  const AIVenueRecommendationsWidget({
    super.key,
    required this.currentVenue,
    required this.nearbyVenues,
  });

  @override
  State<AIVenueRecommendationsWidget> createState() => _AIVenueRecommendationsWidgetState();
}

class _AIVenueRecommendationsWidgetState extends State<AIVenueRecommendationsWidget> {
  List<AIRecommendation> _recommendations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final unifiedVenueService = sl<UnifiedVenueService>();
      
      // Get enhanced venue recommendations from unified service
      final venueRecommendations = await unifiedVenueService.getRecommendations(
        venues: widget.nearbyVenues.isNotEmpty ? widget.nearbyVenues : [widget.currentVenue],
        context: "watch_party",
        limit: 3,
        includeAIAnalysis: true,
        includePersonalization: false,
      );

      // Convert to AI recommendations format
      final recommendations = venueRecommendations.map((venueRec) {
        return AIRecommendation(
          id: 'ai_${venueRec.venue.placeId}_${DateTime.now().millisecondsSinceEpoch}',
          title: "${venueRec.category.emoji} ${venueRec.venue.name}",
          description: venueRec.reasoning,
          confidence: venueRec.confidence,
          metadata: {
            'venueId': venueRec.venue.placeId,
            'venueName': venueRec.venue.name,
            'venueRating': venueRec.venue.rating,
            'unifiedScore': venueRec.unifiedScore,
          },
          reasons: venueRec.tags,
          timestamp: DateTime.now(),
          category: 'ai_venue_recommendation',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withValues(alpha: 0.1),
            const Color(0xFFA29BFE).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI badge and refresh button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'AI Powered',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Smart Recommendations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isLoading ? null : _loadRecommendations,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Color(0xFF6C5CE7)),
                tooltip: 'Refresh AI Recommendations',
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                ),
              ),
            )
          else if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unable to load AI recommendations',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No recommendations available at this time',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _recommendations.map((recommendation) => 
                _buildRecommendationCard(recommendation)
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with confidence
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1810),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(recommendation.confidence).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getConfidenceColor(recommendation.confidence).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${(recommendation.confidence * 100).round()}%',
                  style: TextStyle(
                    color: _getConfidenceColor(recommendation.confidence),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            recommendation.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),

          if (recommendation.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: recommendation.reasons.take(3).map((reason) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reason,
                    style: const TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF00D2FF);
    if (confidence >= 0.6) return const Color(0xFF6C5CE7);
    return const Color(0xFFFD79A8);
  }
} 