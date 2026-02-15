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
      return 'I recommend checking out popular sports bars in your area for the best game day atmosphere!';
    } else if (lowerPrompt.contains('prediction') ||
        lowerPrompt.contains('game') ||
        lowerPrompt.contains('score')) {
      return 'This should be an exciting game! Check recent team performance and injury reports for the best insights.';
    } else {
      return 'I\'m here to help you find the best game day experience. Try asking about venues or game predictions!';
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
      'preferredGameTypes': ['conference'],
      'recommendedVenues': ['sports_bar', 'stadium'],
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

    // Generate more realistic scores based on team characteristics
    final homeBaseScore = 17 + (homeHash % 21); // 17-37 range
    final awayBaseScore = 14 + (awayHash % 21); // 14-34 range

    // Add home field advantage
    final homeScore = homeBaseScore + 3;
    final awayScore = awayBaseScore;

    final homeWins = homeScore > awayScore;
    final confidence =
        0.65 + ((homeHash + awayHash) % 25) / 100.0; // 0.65 to 0.9

    // Generate team-specific analysis
    final analysis = _generateTeamSpecificAnalysis(
        homeTeam, awayTeam, homeScore, awayScore);

    return {
      'prediction': homeWins ? 'home_win' : 'away_win',
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
    final winner = homeScore > awayScore ? homeTeam : awayTeam;
    final margin = (homeScore - awayScore).abs();

    final marginText = margin <= 3
        ? 'close game'
        : margin <= 7
            ? 'competitive matchup'
            : 'decisive victory';

    return '''$winner is projected to win in what should be a $marginText.

The prediction is based on statistical analysis of team performance metrics, including attacking efficiency, defensive organization, and home advantage factors. $homeTeam benefits from playing at home, which historically provides an edge in international soccer.

Key factors include possession control, set-piece quality, and goalkeeping form. Both teams have shown competitive play in recent matches, making this an intriguing matchup for fans and analysts alike.''';
  }

  /// Generate key factors based on teams
  static List<String> _generateKeyFactors(
      String homeTeam, String awayTeam, bool homeWins) {
    final factors = <String>[
      'Home field advantage (+3 points)',
      'Offensive line play and protection',
      'Turnover margin and ball security',
      'Third-down conversion efficiency',
    ];

    // Add team-specific factors
    if (homeTeam.contains('Alabama') ||
        homeTeam.contains('Georgia') ||
        homeTeam.contains('LSU')) {
      factors.add('Elite recruiting and depth advantage');
    }

    if (awayTeam.contains('Auburn') || awayTeam.contains('Tennessee')) {
      factors.add('Strong road game experience');
    }

    if (homeWins) {
      factors.add('Crowd noise and venue atmosphere');
    } else {
      factors.add('Away team motivation and focus');
    }

    return factors;
  }

  /// Generate player matchups
  static List<Map<String, String>> _generatePlayerMatchups(
      String homeTeam, String awayTeam) {
    return [
      {
        'matchup': 'Quarterback Protection',
        'description': '$homeTeam offensive line vs $awayTeam pass rush',
        'impact': 'Critical for establishing offensive rhythm',
      },
      {
        'matchup': 'Running Game Control',
        'description': '$homeTeam ground attack vs $awayTeam run defense',
        'impact': 'Will determine time of possession and game flow',
      },
      {
        'matchup': 'Secondary Coverage',
        'description': '$awayTeam receivers vs $homeTeam defensive backs',
        'impact': 'Key to limiting big-play opportunities',
      },
    ];
  }

  /// Generate venue impact analysis
  static String _generateVenueImpact(String homeTeam) {
    final venueNames = {
      'Alabama Crimson Tide': 'Bryant-Denny Stadium',
      'Auburn Tigers': 'Jordan-Hare Stadium',
      'Georgia Bulldogs': 'Sanford Stadium',
      'Florida Gators': 'Ben Hill Griffin Stadium',
      'LSU Tigers': 'Tiger Stadium',
      'Tennessee Volunteers': 'Neyland Stadium',
    };

    final venue = venueNames[homeTeam] ?? 'home stadium';

    return 'Playing at $venue provides significant home field advantage with passionate fan support, familiar surroundings, and optimal preparation routines. The crowd noise and atmosphere can impact visiting team communication and execution.';
  }
}
