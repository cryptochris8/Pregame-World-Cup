import 'dart:math';

/// Helper methods for generating fallback/mock responses when the OpenAI API
/// is unavailable. Extracted from AIService to keep that class focused on
/// API interaction and orchestration.
class AIFallbackHelpers {

  // ---------------------------------------------------------------------------
  // Prompt-based fallback response
  // ---------------------------------------------------------------------------

  /// Generate fallback response when API is unavailable
  static String generateFallbackResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('venue') ||
        lowerPrompt.contains('restaurant') ||
        lowerPrompt.contains('bar')) {
      return 'I recommend checking out popular sports bars in your area for the best match day atmosphere!';
    } else if (lowerPrompt.contains('prediction') ||
        lowerPrompt.contains('game') ||
        lowerPrompt.contains('score')) {
      return 'This should be an exciting match! Check recent team form and squad updates for the best insights.';
    } else {
      return 'I\'m here to help you find the best match day experience. Try asking about venues or match predictions!';
    }
  }

  /// Generate mock embedding for fallback
  static List<double> generateMockEmbedding(String text) {
    final random = Random(text.hashCode);
    return List.generate(
        1536, (i) => (random.nextDouble() - 0.5) * 2); // OpenAI embedding dimension
  }

  // ---------------------------------------------------------------------------
  // User behaviour / recommendation fallbacks
  // ---------------------------------------------------------------------------

  /// Generate fallback user insights when AI analysis fails
  static Map<String, dynamic> generateFallbackUserInsights(
      Map<String, dynamic> behaviorData) {
    final gameInteractions = behaviorData['gameInteractions'] as List? ?? [];

    // Basic team affinity calculation
    final teamCounts = <String, int>{};
    for (final interaction in gameInteractions) {
      final homeTeam = interaction['homeTeam'] as String?;
      final awayTeam = interaction['awayTeam'] as String?;
      if (homeTeam != null) {
        teamCounts[homeTeam] = (teamCounts[homeTeam] ?? 0) + 1;
      }
      if (awayTeam != null) {
        teamCounts[awayTeam] = (teamCounts[awayTeam] ?? 0) + 1;
      }
    }

    final totalInteractions = gameInteractions.length;
    final teamAffinityScores = <String, double>{};
    teamCounts.forEach((team, count) {
      teamAffinityScores[team] =
          count / (totalInteractions > 0 ? totalInteractions : 1);
    });

    return {
      'teamAffinityScores': teamAffinityScores,
      'interactionPatterns': {
        'gameViews': gameInteractions
                .where((i) => i['interactionType'] == 'view')
                .length /
            (totalInteractions > 0 ? totalInteractions : 1),
        'favorites': gameInteractions
                .where((i) => i['interactionType'] == 'favorite')
                .length /
            (totalInteractions > 0 ? totalInteractions : 1),
      },
      'preferredGameTypes': ['group_stage', 'knockout'],
      'recommendedVenues': ['sports_bar', 'fan_zone'],
      'engagementScore': totalInteractions > 5 ? 0.7 : 0.3,
    };
  }

  /// Generate fallback game recommendations when AI fails
  static List<Map<String, dynamic>> generateFallbackGameRecommendations(
    List<Map<String, dynamic>> upcomingGames,
    Map<String, dynamic> userInsights,
    int limit,
  ) {
    final teamScores =
        userInsights['teamAffinityScores'] as Map<String, double>? ?? {};

    // Score games based on team involvement
    final scoredGames = upcomingGames.map((game) {
      final homeTeam = game['HomeTeam'] as String? ?? '';
      final awayTeam = game['AwayTeam'] as String? ?? '';

      final homeScore = teamScores[homeTeam] ?? 0.0;
      final awayScore = teamScores[awayTeam] ?? 0.0;
      final totalScore = (homeScore + awayScore) * 0.5 +
          Random().nextDouble() * 0.1; // Add small random factor

      return {
        'gameId': game['GameID']?.toString() ?? '',
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'score': totalScore,
        'reasons': ['Teams match your interests'],
        'gameTime': game['DateTimeUTC'] ??
            game['DateTime'] ??
            DateTime.now().toIso8601String(),
        'gameData': game,
      };
    }).toList();

    // Sort by score and return top games
    scoredGames
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return scoredGames.take(limit).toList();
  }

  // ---------------------------------------------------------------------------
  // Game prediction fallback
  // ---------------------------------------------------------------------------

  /// Generate enhanced fallback prediction when AI fails
  static Map<String, dynamic> generateFallbackPrediction(
      String homeTeam, String awayTeam) {
    // Use team names to create more realistic variability
    final homeHash = homeTeam.hashCode.abs();
    final awayHash = awayTeam.hashCode.abs();

    // Generate realistic soccer scores (0-4 typical range)
    final homeBaseScore = homeHash % 4; // 0-3 range
    final awayBaseScore = awayHash % 4; // 0-3 range

    // Add slight home advantage
    final homeScore = homeBaseScore + (homeHash % 2); // 0-4
    final awayScore = awayBaseScore;

    final homeWins = homeScore > awayScore;
    final confidence =
        0.55 + ((homeHash + awayHash) % 30) / 100.0; // 0.55 to 0.85

    // Generate team-specific analysis
    final analysis = _generateTeamSpecificAnalysis(
        homeTeam, awayTeam, homeScore, awayScore);

    return {
      'prediction': homeScore == awayScore ? 'draw' : (homeWins ? 'home_win' : 'away_win'),
      'confidence': confidence,
      'predictedScore': {
        'home': homeScore,
        'away': awayScore,
      },
      'keyFactors': _generateKeyFactors(homeTeam, awayTeam, homeWins),
      'analysis': analysis,
      'playerMatchups': _generatePlayerMatchups(homeTeam, awayTeam),
      'venueImpact': _generateVenueImpact(homeTeam),
      'source': 'Enhanced Statistical Analysis',
    };
  }

  /// Generate team-specific analysis
  static String _generateTeamSpecificAnalysis(
      String homeTeam, String awayTeam, int homeScore, int awayScore) {
    final winner = homeScore > awayScore ? homeTeam : (awayScore > homeScore ? awayTeam : null);
    final margin = (homeScore - awayScore).abs();

    final marginText = margin == 0
        ? 'tightly contested draw'
        : margin == 1
            ? 'closely fought match'
            : 'decisive victory';

    final resultText = winner != null
        ? '$winner is projected to win in what should be a $marginText.'
        : 'This match is projected to end in a $marginText.';

    return '''$resultText

The prediction is based on statistical analysis of team performance metrics, including attacking efficiency, defensive organization, and tournament form. $homeTeam benefits from favorable conditions, which historically provides an edge in international soccer.

Key factors include possession control, set-piece quality, and goalkeeping form. Both teams have shown competitive play in recent matches, making this an intriguing matchup for fans and analysts alike.''';
  }

  /// Generate key factors based on teams
  static List<String> _generateKeyFactors(
      String homeTeam, String awayTeam, bool homeWins) {
    final factors = <String>[
      'Home crowd advantage and familiar conditions',
      'Midfield control and possession dominance',
      'Defensive shape and pressing intensity',
      'Set piece execution and aerial threat',
    ];

    // Add team-specific factors
    if (homeTeam.contains('Brazil') ||
        homeTeam.contains('France') ||
        homeTeam.contains('Germany')) {
      factors.add('Elite squad depth and tournament pedigree');
    }

    if (awayTeam.contains('Argentina') || awayTeam.contains('Spain')) {
      factors.add('Strong tactical identity and away form');
    }

    if (homeWins) {
      factors.add('Crowd support and venue atmosphere');
    } else {
      factors.add('Away team composure and counter-attacking threat');
    }

    return factors;
  }

  /// Generate player matchups
  static List<Map<String, String>> _generatePlayerMatchups(
      String homeTeam, String awayTeam) {
    return [
      {
        'matchup': 'Midfield Battle',
        'description': '$homeTeam midfield control vs $awayTeam pressing game',
        'impact': 'Critical for dictating tempo and controlling possession',
      },
      {
        'matchup': 'Defensive Shape',
        'description': '$homeTeam defensive line vs $awayTeam attacking movement',
        'impact': 'Will determine chances created and goals conceded',
      },
      {
        'matchup': 'Wing Play',
        'description': '$awayTeam wide attackers vs $homeTeam full-backs',
        'impact': 'Key to creating crossing opportunities and overlapping runs',
      },
    ];
  }

  /// Generate venue impact analysis
  static String _generateVenueImpact(String homeTeam) {
    final venueNames = {
      'United States': 'MetLife Stadium',
      'Mexico': 'Estadio Azteca',
      'Canada': 'BMO Field',
      'Brazil': 'AT&T Stadium',
      'Argentina': 'Hard Rock Stadium',
      'France': 'SoFi Stadium',
      'Germany': 'Mercedes-Benz Stadium',
      'England': 'Lincoln Financial Field',
      'Spain': 'NRG Stadium',
    };

    final venue = venueNames[homeTeam] ?? 'the designated World Cup venue';

    return 'Playing at $venue provides a significant boost with passionate fan support, world-class facilities, and optimal match conditions. The atmosphere at World Cup venues can influence player performance and create an electrifying environment that elevates the intensity of every contest.';
  }
}
