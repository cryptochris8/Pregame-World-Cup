import 'dart:math';

/// Generates realistic player statistics and related helper data for team
/// season summaries. Extracted from AITeamSeasonSummaryService to keep that
/// class focused on orchestrating the summary pipeline.
class TeamSeasonStatsGenerator {
  // ---------------------------------------------------------------------------
  // Star player analysis
  // ---------------------------------------------------------------------------

  /// Generate star players analysis (realistic based on team performance)
  static Map<String, dynamic> generateStarPlayersAnalysis(
      String teamName, Map<String, dynamic> seasonRecord) {
    final players = <Map<String, dynamic>>[];
    final overall = seasonRecord['overall'];

    // Generate goalkeeper
    final gkStats = _generateGoalkeeperStats(overall['wins'], overall['losses']);
    players.add({
      'name': _generateRealisticPlayerName('GK'),
      'position': 'Goalkeeper',
      'age': _getRandomAge(),
      'stats': {
        'appearances': gkStats['appearances'],
        'saves': gkStats['saves'],
        'cleanSheets': gkStats['cleanSheets'],
        'goalsConceded': gkStats['goalsConceded'],
        'savePercentage': gkStats['savePercentage'],
      },
      'highlights': [
        'Commanded the box with authority throughout the campaign',
        'Key performer in crucial group stage and knockout matches',
      ],
    });

    // Generate defender
    final defStats = _generateDefenderStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('DF'),
      'position': 'Defender',
      'age': _getRandomAge(),
      'stats': {
        'appearances': defStats['appearances'],
        'tackles': defStats['tackles'],
        'interceptions': defStats['interceptions'],
        'clearances': defStats['clearances'],
        'aerialDuelsWon': defStats['aerialDuelsWon'],
      },
      'highlights': [
        'Anchored the backline with composure and leadership',
        'Vital in organizing the defensive shape under pressure',
      ],
    });

    // Generate midfielder
    final midStats = _generateMidfielderStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('MF'),
      'position': 'Midfielder',
      'age': _getRandomAge(),
      'stats': {
        'appearances': midStats['appearances'],
        'passesCompleted': midStats['passesCompleted'],
        'keyPasses': midStats['keyPasses'],
        'assists': midStats['assists'],
        'distanceCoveredKm': midStats['distanceCoveredKm'],
      },
      'highlights': [
        'Controlled the tempo with intelligent distribution',
        'Engine of the team covering vast ground every match',
      ],
    });

    // Generate forward/striker
    final fwStats = _generateForwardStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('FW'),
      'position': 'Forward',
      'age': _getRandomAge(),
      'stats': {
        'appearances': fwStats['appearances'],
        'goals': fwStats['goals'],
        'shotsOnTarget': fwStats['shotsOnTarget'],
        'conversionRate': fwStats['conversionRate'],
        'assists': fwStats['assists'],
      },
      'highlights': [
        'Clinical finisher who led the team\'s attacking output',
        'Rose to the occasion in high-pressure knockout matches',
      ],
    });

    return {
      'starPlayers': players,
      'teamCaptains': players.take(2).toList(),
      'allConferenceCandidates':
          players.where((p) => overall['wins'] > overall['losses']).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Postseason / tournament / rivalry helpers
  // ---------------------------------------------------------------------------

  /// Analyze tournament performance stage
  static String getBowlName(int wins, int losses) {
    if (wins >= 11) return 'World Cup Final / Semi-Final';
    if (wins >= 9) return 'World Cup Quarter-Final';
    if (wins >= 7) return 'World Cup Round of 16';
    return 'World Cup Group Stage';
  }

  /// Get overall tournament outcome label
  static String getSeasonOutcome(int wins, int losses, String bowlResult) {
    if (wins >= 12) return 'Tournament Champions';
    if (wins >= 10) return 'Deep Tournament Run';
    if (wins >= 8) return 'Successful Campaign';
    if (wins >= 6) return 'Knockout Stage Qualification';
    return 'Group Stage Campaign';
  }

  /// Generate rivalry analysis placeholder
  static Map<String, dynamic> generateRivalryAnalysis(
      String teamName, Map<String, dynamic> seasonRecord) {
    return {
      'rivalryGames': 2,
      'rivalryRecord': '1-1',
      'biggestRivalryWin': 'Decisive victory over traditional rival',
    };
  }

  // ---------------------------------------------------------------------------
  // Assessment helpers
  // ---------------------------------------------------------------------------

  /// Generate key achievements for the overall assessment
  static List<String> generateKeyAchievements(
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> postseasonAnalysis) {
    final achievements = <String>[];
    final overall = seasonRecord['overall'];

    if (overall['wins'] >= 8) {
      achievements
          .add('Posted ${overall['wins']} wins - among the best tournament campaigns in recent history');
    }

    if (postseasonAnalysis['bowlEligibility']?.toString().contains('Eligible') == true) {
      achievements
          .add('Advanced past the group stage with strong performances');
    }

    final bigWins = seasonRecord['bigWins'] as List;
    if (bigWins.isNotEmpty) {
      achievements
          .add('Secured signature victories that elevated the national team\'s profile');
    }

    return achievements;
  }

  /// Generate areas for improvement
  static List<String> generateImprovementAreas(
      Map<String, dynamic> seasonRecord) {
    final areas = <String>[];
    final overall = seasonRecord['overall'];
    final scoring = seasonRecord['scoring'];

    if (overall['losses'] > overall['wins']) {
      areas.add('Consistency in key moments and closing out matches');
    }

    if (scoring['averageAllowed'] > scoring['averageScored']) {
      areas.add('Defensive organization and limiting opposition chances');
    }

    areas.add('Player development depth to compete at the highest international level');

    return areas;
  }

  /// Generate 2026 outlook
  static String generate2025Outlook(
      String teamName, Map<String, dynamic> seasonRecord) {
    final overall = seasonRecord['overall'];

    if (overall['wins'] > overall['losses']) {
      return 'Strong foundation established for the 2026 World Cup with returning talent and tactical momentum carrying forward.';
    } else {
      return 'Valuable experience gained in international competition provides building blocks for improved form heading into the 2026 World Cup.';
    }
  }

  // ---------------------------------------------------------------------------
  // Display data helpers
  // ---------------------------------------------------------------------------

  /// Generate quick summary string
  static String generateQuickSummary(
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> postseasonAnalysis) {
    final overall = seasonRecord['overall'];
    final wins = overall['wins'];
    final losses = overall['losses'];
    final bowlStatus = postseasonAnalysis['bowlEligibility'];

    return '$wins-$losses overall record \u2022 $bowlStatus \u2022 ${postseasonAnalysis['seasonOutcome']}';
  }

  /// Generate highlight stats list
  static List<String> generateHighlightStats(
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> gameAnalysis) {
    final scoring = seasonRecord['scoring'];
    final bigWins = gameAnalysis['bigWins'] as List;
    final closeGames = gameAnalysis['closeGames'] as List;

    return [
      '${scoring['averageScored']} Goals Scored Avg',
      '${scoring['averageAllowed']} Goals Conceded Avg',
      '${bigWins.length} Signature Wins',
      '${closeGames.length} Matches Decided by 1 Goal or Less',
    ];
  }

  // ---------------------------------------------------------------------------
  // Private stat generators
  // ---------------------------------------------------------------------------

  static String _generateRealisticPlayerName(String position) {
    final firstNames = [
      'Lucas', 'Mateo', 'Karim', 'Luka', 'Kylian',
      'Mohamed', 'Kenji', 'Enzo', 'Rafael', 'Jamal',
      'Sadio', 'Alphonso', 'Giovanni', 'Hugo', 'Youssef',
    ];
    final lastNames = [
      'Silva', 'Martinez', 'Fernandez', 'Mueller', 'Nakamura',
      'Park', 'Williams', 'Diallo', 'Hernandez', 'Van Dijk',
      'Rossi', 'Andersen', 'Al-Dosari', 'Okafor', 'Campbell',
    ];
    final random = Random();
    return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
  }

  static int _getRandomAge() {
    // International players typically range 22-35
    return 22 + Random().nextInt(14);
  }

  static Map<String, dynamic> _generateGoalkeeperStats(int wins, int losses) {
    final totalGames = wins + losses;
    final random = Random();
    final cleanSheets = wins > losses ? (wins * 0.4).round() + random.nextInt(3) : random.nextInt(3) + 1;
    final goalsConceded = losses + random.nextInt(totalGames > 0 ? totalGames : 1);
    final saves = goalsConceded * 2 + random.nextInt(20) + 15;
    final savePercentage = saves > 0 ? (saves / (saves + goalsConceded) * 100) : 70.0;
    return {
      'appearances': totalGames > 0 ? totalGames : 7,
      'saves': saves,
      'cleanSheets': cleanSheets,
      'goalsConceded': goalsConceded,
      'savePercentage': double.parse(savePercentage.toStringAsFixed(1)),
    };
  }

  static Map<String, dynamic> _generateDefenderStats(int wins) {
    final random = Random();
    final appearances = wins > 3 ? wins + random.nextInt(4) : 5 + random.nextInt(3);
    return {
      'appearances': appearances,
      'tackles': 25 + random.nextInt(30), // 25-55 per tournament
      'interceptions': 15 + random.nextInt(20), // 15-35
      'clearances': 30 + random.nextInt(35), // 30-65
      'aerialDuelsWon': 20 + random.nextInt(25), // 20-45
    };
  }

  static Map<String, dynamic> _generateMidfielderStats(int wins) {
    final random = Random();
    final appearances = wins > 3 ? wins + random.nextInt(4) : 5 + random.nextInt(3);
    return {
      'appearances': appearances,
      'passesCompleted': 250 + random.nextInt(300), // 250-550 per tournament
      'keyPasses': 8 + random.nextInt(15), // 8-23
      'assists': 1 + random.nextInt(6), // 1-7
      'distanceCoveredKm': 70.0 + random.nextDouble() * 30, // 70-100 km over tournament
    };
  }

  static Map<String, dynamic> _generateForwardStats(int wins) {
    final random = Random();
    final appearances = wins > 3 ? wins + random.nextInt(4) : 5 + random.nextInt(3);
    final goals = (wins > 6 ? 4 : 1) + random.nextInt(5); // 1-9 goals in a tournament
    final shotsOnTarget = goals * 2 + random.nextInt(8) + 3;
    final totalShots = shotsOnTarget + random.nextInt(12) + 5;
    final conversionRate = totalShots > 0 ? (goals / totalShots * 100) : 15.0;
    return {
      'appearances': appearances,
      'goals': goals,
      'shotsOnTarget': shotsOnTarget,
      'conversionRate': double.parse(conversionRate.toStringAsFixed(1)),
      'assists': random.nextInt(4) + 1, // 1-5
    };
  }
}
