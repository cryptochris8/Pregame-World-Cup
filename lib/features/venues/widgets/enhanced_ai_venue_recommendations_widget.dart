import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/ai/entities/ai_recommendation.dart';
import '../../../core/services/unified_venue_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../features/social/domain/entities/user_profile.dart';
import '../../../features/social/domain/services/social_service.dart';
import '../../../features/schedule/domain/entities/game_schedule.dart';
import '../../../injection_container.dart';

/// Enhanced AI venue recommendations that uses real user preferences
/// and game context for smarter recommendations
class EnhancedAIVenueRecommendationsWidget extends StatefulWidget {
  final List<Place> nearbyVenues;
  final GameSchedule? currentGame;
  final String? customContext;

  const EnhancedAIVenueRecommendationsWidget({
    super.key,
    required this.nearbyVenues,
    this.currentGame,
    this.customContext,
  });

  @override
  State<EnhancedAIVenueRecommendationsWidget> createState() => 
      _EnhancedAIVenueRecommendationsWidgetState();
}

class _EnhancedAIVenueRecommendationsWidgetState 
    extends State<EnhancedAIVenueRecommendationsWidget> {
  List<AIRecommendation> _recommendations = [];
  bool _isLoading = true;
  String? _error;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndRecommendations();
  }

  Future<void> _loadUserProfileAndRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load user profile first
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final socialService = sl<SocialService>();
        _userProfile = await socialService.getUserProfile(user.uid);
      }

      await _loadRecommendations();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final unifiedVenueService = sl<UnifiedVenueService>();
      
      // Build smart user preferences from profile
      final userPreferences = _buildUserPreferences();
      
      // Build intelligent game context
      final gameContext = _buildGameContext();
      
      // Get enhanced venue recommendations from unified service
      final venueRecommendations = await unifiedVenueService.getRecommendations(
        venues: widget.nearbyVenues,
        game: widget.currentGame,
        context: gameContext,
        limit: 4,
        includeAIAnalysis: true,
        includePersonalization: true,
      );

      // Convert to AI recommendations format
      final recommendations = venueRecommendations.map((venueRec) {
        return AIRecommendation(
          id: 'unified_${venueRec.venue.placeId}_${DateTime.now().millisecondsSinceEpoch}',
          title: _generateRecommendationTitle(venueRec),
          description: venueRec.reasoning,
          confidence: venueRec.confidence,
          metadata: {
            'venueId': venueRec.venue.placeId,
            'venueName': venueRec.venue.name,
            'venueRating': venueRec.venue.rating,
            'venueTypes': venueRec.venue.types,
            'unifiedScore': venueRec.unifiedScore,
            'category': venueRec.category.displayName,
          },
          reasons: venueRec.tags,
          timestamp: DateTime.now(),
          category: 'unified_venue_recommendation',
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

  /// Build personalized user preferences string from profile
  String _buildUserPreferences() {
    if (_userProfile == null) {
      return "Sports fan looking for game day atmosphere, good food, and energetic crowd";
    }

    final preferences = _userProfile!.preferences;
    final favoriteTeams = _userProfile!.favoriteTeams;
    
    final parts = <String>[];
    
    // Add favorite teams context
    if (favoriteTeams.isNotEmpty) {
      parts.add("Fan of ${favoriteTeams.join(', ')}");
    }
    
    // Add venue type preferences
    if (preferences.preferredVenueTypes.isNotEmpty) {
      final types = preferences.preferredVenueTypes.map((type) {
        switch (type) {
          case 'sports_bar': return 'sports bars';
          case 'restaurant': return 'restaurants';
          case 'bar': return 'bars';
          case 'brewery': return 'breweries';
          default: return type;
        }
      }).join(', ');
      parts.add("Prefers $types");
    }
    
    // Add price preference
    parts.add("Budget preference: ${preferences.preferredPriceRange}");
    
    // Add travel distance
    parts.add("Within ${preferences.maxTravelDistance}km travel distance");
    
    // Add dietary restrictions if any
    if (preferences.dietaryRestrictions.isNotEmpty) {
      parts.add("Dietary needs: ${preferences.dietaryRestrictions.join(', ')}");
    }
    
    // Add general preferences
    parts.add("Looking for energetic game day atmosphere with good food and drinks");
    
    return parts.join('. ');
  }

  /// Build intelligent game context
  String _buildGameContext() {
    if (widget.customContext != null) {
      return widget.customContext!;
    }
    
    if (widget.currentGame == null) {
      return "general";
    }
    
    final game = widget.currentGame!;
    
    // Determine context based on game timing
    if (game.dateTimeUTC != null) {
      final gameTime = game.dateTimeUTC!.toLocal();
      final now = DateTime.now();
      final hoursUntil = gameTime.difference(now).inHours;
      
      if (hoursUntil > 2) {
        return "pre_game";
      } else if (hoursUntil > -3) {
        return "watch_party";
      } else {
        return "post_game";
      }
    }
    
    return "watch_party";
  }

  /// Generate recommendation title from venue recommendation
  String _generateRecommendationTitle(EnhancedVenueRecommendation venueRec) {
    final venue = venueRec.venue;
    final category = venueRec.category;
    
    if (venueRec.unifiedScore > 0.8) {
      return "🌟 Perfect Match: ${venue.name}";
    } else if (venueRec.unifiedScore > 0.7) {
      return "⭐ Great Choice: ${venue.name}";
    } else if (category.displayName.isNotEmpty) {
      return "${category.emoji} ${venue.name}";
    } else {
      return "📍 ${venue.name}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED), // Vibrant purple
            Color(0xFF3B82F6), // Electric blue
            Color(0xFFEA580C), // Warm orange
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C3AED),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // AI Badge
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
        
        // Title
        const Expanded(
          child: Text(
            'Smart Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        // Personalization indicator
        if (_userProfile != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 12, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Personalized',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        
        // Refresh button
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isLoading ? null : _loadUserProfileAndRecommendations,
          icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white, size: 20),
          tooltip: 'Refresh Recommendations',
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
              SizedBox(height: 12),
              Text(
                'AI is analyzing your preferences...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unable to load AI recommendations',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return Container(
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
      );
    }

    return Column(
      children: [
        // Context indicator
        if (_userProfile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 16, color: Color(0xFF6C5CE7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on your preferences: ${_userProfile!.preferences.preferredVenueTypes.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Recommendations list
        ...(_recommendations.map((recommendation) => 
          _buildRecommendationCard(recommendation)
        ).toList()),
      ],
    );
  }

  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
              _buildConfidenceBadge(recommendation.confidence),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          
          // Reasons
          if (recommendation.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: recommendation.reasons.map((reason) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C5CE7),
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

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).round();
    final color = confidence >= 0.8 
        ? Colors.green
        : confidence >= 0.6 
            ? Colors.orange
            : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$percentage% match',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 