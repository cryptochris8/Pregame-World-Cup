import 'dart:convert';

/// Helpers for building fallback venue recommendations when the OpenAI API is
/// unavailable. Extracted from AIService to keep that class focused on
/// API interaction and orchestration.
class AIVenueFallbackHelpers {

  // ---------------------------------------------------------------------------
  // Summarization helpers used by the AI prompt path
  // ---------------------------------------------------------------------------

  /// Helper method to summarize behavior data for AI analysis
  static String summarizeBehaviorData(Map<String, dynamic> behaviorData) {
    final gameInteractions =
        behaviorData['gameInteractions'] as List? ?? [];
    final teamPreferences =
        behaviorData['teamPreferences'] as List? ?? [];

    final summary = StringBuffer();

    if (gameInteractions.isNotEmpty) {
      final viewCount =
          gameInteractions.where((i) => i['interactionType'] == 'view').length;
      final favoriteCount = gameInteractions
          .where((i) => i['interactionType'] == 'favorite')
          .length;
      summary
          .writeln('Game interactions: $viewCount views, $favoriteCount favorites');
    }

    if (teamPreferences.isNotEmpty) {
      final addedTeams = teamPreferences
          .where((p) => p['action'] == 'add')
          .map((p) => p['teamName'])
          .toSet();
      summary.writeln('Favorite teams: ${addedTeams.join(', ')}');
    }

    return summary.toString();
  }

  /// Helper method to summarize user insights for recommendations
  static String summarizeUserInsights(Map<String, dynamic> userInsights) {
    final teamScores = userInsights['teamAffinityScores'] as Map? ?? {};
    final engagementScore = userInsights['engagementScore'] ?? 0.0;

    return 'Top teams: ${teamScores.keys.take(3).join(', ')}, Engagement: $engagementScore';
  }

  /// Helper method to summarize upcoming games for AI processing
  static String summarizeUpcomingGames(List<Map<String, dynamic>> games,
      {int limit = 5}) {
    return games.take(limit).map((game) {
      return '${game['AwayTeam']} @ ${game['HomeTeam']} (${game['DateTime'] ?? 'TBD'})';
    }).join('\n');
  }

  /// Summarize user behavior data for venue recommendations
  static String summarizeBehaviorForVenues(
      Map<String, dynamic> behaviorData) {
    final summary = StringBuffer();

    // Venue type preferences
    final venueTypePrefs =
        behaviorData['venue_type_preferences'] as Map<String, dynamic>?;
    if (venueTypePrefs != null) {
      final topTypes = venueTypePrefs.entries
          .where((e) => e.value > 0.6)
          .map((e) => e.key)
          .take(3)
          .join(', ');
      if (topTypes.isNotEmpty) {
        summary.writeln('Preferred venue types: $topTypes');
      }
    }

    // Distance preferences
    final distancePrefs =
        behaviorData['distance_preferences'] as Map<String, dynamic>?;
    if (distancePrefs != null) {
      final maxDistance = distancePrefs['preferred_max_distance'] ?? 5.0;
      summary.writeln('Preferred distance: within ${maxDistance}km');
    }

    // Price preferences
    final pricePrefs =
        behaviorData['price_preferences'] as Map<String, dynamic>?;
    if (pricePrefs != null) {
      final priceLevel = pricePrefs['preferred_price_level'] ?? 2;
      summary.writeln('Price preference: level $priceLevel');
    }

    return summary.toString();
  }

  // ---------------------------------------------------------------------------
  // Fallback venue recommendation builder
  // ---------------------------------------------------------------------------

  /// Generate enhanced fallback venue recommendations when AI fails
  static String generateFallbackVenueRecommendations(
      List<dynamic> venues, Map<String, dynamic> context) {
    final venueContext = context['context'] ?? 'general';
    final gameInfo = context['game_info'] as Map<String, dynamic>?;
    final userBehavior = context['user_behavior'] as Map<String, dynamic>?;
    final recommendations = <Map<String, dynamic>>[];

    // Enhanced scoring algorithm
    for (final venue in venues.take(15)) {
      final v = venue as dynamic;
      double score = 0.4; // Base score
      final reasons = <String>[];
      final tags = <String>[];

      // Rating contribution (weighted heavily)
      if (v.rating != null && v.rating > 0) {
        final ratingScore = ((v.rating - 2.5) / 2.5).clamp(0.0, 1.0);
        score += ratingScore * 0.3;
        if (v.rating >= 4.5) {
          reasons.add('Highly rated (${v.rating}⭐)');
          tags.add('Top Rated');
        } else if (v.rating >= 4.0) {
          reasons.add('Well reviewed (${v.rating}⭐)');
          tags.add('Popular');
        }
      }

      // Context-based type scoring
      final types = v.types as List<String>? ?? [];
      if (venueContext == 'pre_game') {
        if (types.any(
            (t) => ['restaurant', 'meal_takeaway', 'food'].contains(t))) {
          score += 0.25;
          reasons.add('Great for pre-game dining');
          tags.add('Pre-Game');
        }
        if (types.contains('sports_bar')) {
          score += 0.2;
          reasons.add('Perfect sports atmosphere');
          tags.add('Sports Bar');
        }
      } else if (venueContext == 'post_game') {
        if (types
            .any((t) => ['bar', 'night_club', 'entertainment'].contains(t))) {
          score += 0.25;
          reasons.add('Ideal for post-game celebration');
          tags.add('Post-Game');
        }
        if (types.contains('restaurant') && types.contains('bar')) {
          score += 0.15;
          reasons.add('Food and drinks available');
          tags.add('Full Service');
        }
      } else {
        // General context
        if (types.contains('sports_bar')) {
          score += 0.2;
          reasons.add('Sports-focused venue');
          tags.add('Sports');
        }
        if (types.contains('restaurant')) {
          score += 0.15;
          reasons.add('Dining available');
          tags.add('Dining');
        }
      }

      // Distance-based scoring
      if (v.distance != null) {
        if (v.distance <= 1.0) {
          score += 0.2;
          reasons.add('Very close (${v.distance.toStringAsFixed(1)}km)');
          tags.add('Nearby');
        } else if (v.distance <= 3.0) {
          score += 0.1;
          reasons.add(
              'Convenient location (${v.distance.toStringAsFixed(1)}km)');
        } else if (v.distance > 10.0) {
          score -= 0.1; // Penalty for very far venues
        }
      }

      // Game-specific bonuses
      if (gameInfo != null) {
        final homeTeam = gameInfo['home_team'] as String?;

        // If venue name contains team references
        if (homeTeam != null && v.name != null) {
          final venueName = (v.name as String).toLowerCase();
          final teamKeywords = _getTeamKeywords(homeTeam);
          if (teamKeywords
              .any((keyword) => venueName.contains(keyword.toLowerCase()))) {
            score += 0.15;
            reasons.add('Team-themed venue');
            tags.add('Team Spirit');
          }
        }
      }

      // User behavior bonuses
      if (userBehavior != null) {
        final venueTypePrefs =
            userBehavior['venue_type_preferences'] as Map<String, dynamic>?;
        if (venueTypePrefs != null) {
          for (final type in types) {
            final preference = venueTypePrefs[type] as double?;
            if (preference != null && preference > 0.7) {
              score += 0.1;
              reasons.add('Matches your preferences');
              tags.add('Personalized');
              break;
            }
          }
        }
      }

      // Price level consideration
      if (v.priceLevel != null) {
        final priceLevel = v.priceLevel as int;
        if (priceLevel <= 2) {
          reasons.add('Budget-friendly');
          tags.add('Affordable');
        } else if (priceLevel >= 4) {
          reasons.add('Premium experience');
          tags.add('Upscale');
        }
      }

      // Generate contextual reasoning
      String contextualReasoning =
          _generateContextualReasoning(v, venueContext, gameInfo, reasons);

      recommendations.add({
        'name': v.name ?? 'Unknown Venue',
        'score': score.clamp(0.0, 1.0),
        'reasoning': contextualReasoning,
        'tags': tags.isEmpty ? ['Recommended'] : tags,
        'context_match': venueContext,
        'distance': v.distance,
        'rating': v.rating,
        'types': types,
        'reasons': reasons,
      });
    }

    // Sort by score and take top recommendations
    recommendations.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return json.encode({
      'recommendations': recommendations.take(8).toList(),
      'context': venueContext,
      'analysis': _generateVenueAnalysis(recommendations, venueContext),
    });
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Generate contextual reasoning for venue recommendations
  static String _generateContextualReasoning(
      dynamic venue,
      String context,
      Map<String, dynamic>? gameInfo,
      List<String> reasons) {
    final venueName = venue.name ?? 'This venue';
    final rating = venue.rating;
    final distance = venue.distance;

    final buffer = StringBuffer();

    if (context == 'pre_game') {
      buffer.write(
          '$venueName is an excellent choice for pre-game activities. ');
    } else if (context == 'post_game') {
      buffer
          .write('$venueName offers a great post-game experience. ');
    } else {
      buffer.write('$venueName is a solid choice for your visit. ');
    }

    if (rating != null && rating >= 4.0) {
      buffer.write(
          'With a $rating⭐ rating, it\'s clearly popular with visitors. ');
    }

    if (distance != null && distance <= 2.0) {
      buffer.write(
          'Its convenient location (${distance.toStringAsFixed(1)}km away) makes it easily accessible. ');
    }

    if (reasons.isNotEmpty) {
      buffer.write(
          'Key highlights: ${reasons.take(2).join(' and ').toLowerCase()}.');
    }

    return buffer.toString();
  }

  /// Generate venue analysis summary
  static String _generateVenueAnalysis(
      List<Map<String, dynamic>> recommendations, String context) {
    if (recommendations.isEmpty) {
      return 'No suitable venues found in the area.';
    }

    final topScore = recommendations.first['score'] as double;
    final avgRating = recommendations
            .where((r) => r['rating'] != null)
            .map((r) => r['rating'] as double)
            .fold(0.0, (sum, rating) => sum + rating) /
        recommendations.length;

    final contextText = context == 'pre_game'
        ? 'pre-game dining and preparation'
        : context == 'post_game'
            ? 'post-game celebration and relaxation'
            : 'your visit';

    return 'Found ${recommendations.length} venues optimized for $contextText. Top recommendation scores ${(topScore * 100).toInt()}% with average rating of ${avgRating.toStringAsFixed(1)}⭐.';
  }

  /// Get team-related keywords for venue matching
  static List<String> _getTeamKeywords(String teamName) {
    final keywords = <String>[];

    if (teamName.contains('Alabama')) {
      keywords.addAll(['tide', 'crimson', 'bama', 'roll']);
    } else if (teamName.contains('Auburn')) {
      keywords.addAll(['tiger', 'auburn', 'war', 'eagle']);
    } else if (teamName.contains('Georgia')) {
      keywords.addAll(['bulldog', 'dawg', 'georgia', 'uga']);
    } else if (teamName.contains('Florida')) {
      keywords.addAll(['gator', 'florida', 'swamp']);
    } else if (teamName.contains('LSU')) {
      keywords.addAll(['tiger', 'lsu', 'bayou', 'purple']);
    } else if (teamName.contains('Tennessee')) {
      keywords.addAll(['volunteer', 'vol', 'orange', 'rocky']);
    }

    // Add general team-related terms
    keywords.addAll(['sports', 'game', 'fan', 'tailgate']);

    return keywords;
  }
}
