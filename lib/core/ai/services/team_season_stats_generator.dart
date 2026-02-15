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

    // Generate quarterback
    final qbStats = _generateQBStats(overall['wins'], overall['losses']);
    players.add({
      'name': _generateRealisticPlayerName('QB'),
      'position': 'Quarterback',
      'year': _getRandomYear(),
      'stats': {
        'passingYards': qbStats['yards'],
        'touchdowns': qbStats['tds'],
        'interceptions': qbStats['ints'],
        'completionPercentage': qbStats['completion'],
      },
      'highlights': [
        'Led team to ${overall['wins']} victories with consistent play',
        'Key performer in crucial conference matchups',
      ],
    });

    // Generate running back
    final rbStats = _generateRBStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('RB'),
      'position': 'Running Back',
      'year': _getRandomYear(),
      'stats': {
        'rushingYards': rbStats['yards'],
        'touchdowns': rbStats['tds'],
        'yardsPerCarry': rbStats['ypc'],
        'carries': rbStats['carries'],
      },
      'highlights': [
        'Workhorse back who carried the offense',
        'Broke multiple school rushing records',
      ],
    });

    // Generate wide receiver
    final wrStats = _generateWRStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('WR'),
      'position': 'Wide Receiver',
      'year': _getRandomYear(),
      'stats': {
        'receptions': wrStats['catches'],
        'receivingYards': wrStats['yards'],
        'touchdowns': wrStats['tds'],
        'yardsPerCatch': wrStats['ypc'],
      },
      'highlights': [
        'Deep threat who stretched opposing defenses',
        'Clutch performer in critical moments',
      ],
    });

    // Generate defensive player
    final defStats = _generateDefenseStats(overall['wins']);
    players.add({
      'name': _generateRealisticPlayerName('LB'),
      'position': 'Linebacker',
      'year': _getRandomYear(),
      'stats': {
        'tackles': defStats['tackles'],
        'tacksForLoss': defStats['tfl'],
        'sacks': defStats['sacks'],
        'interceptions': defStats['ints'],
      },
      'highlights': [
        'Defensive leader who anchored the unit',
        'All-conference caliber performer',
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
  // Postseason / conference / rivalry helpers
  // ---------------------------------------------------------------------------

  /// Analyze postseason performance
  static String getBowlName(int wins, int losses) {
    if (wins >= 11) return 'CFP/New Year\'s Six Bowl';
    if (wins >= 9) return 'Prestigious Bowl Game';
    if (wins >= 7) return 'Regional Bowl Championship';
    return 'Bowl Game';
  }

  /// Get overall season outcome label
  static String getSeasonOutcome(int wins, int losses, String bowlResult) {
    if (wins >= 12) return 'Championship Season';
    if (wins >= 10) return 'Highly Successful Season';
    if (wins >= 8) return 'Successful Season';
    if (wins >= 6) return 'Bowl Eligible Season';
    return 'Rebuilding Season';
  }

  /// Generate rivalry analysis placeholder
  static Map<String, dynamic> generateRivalryAnalysis(
      String teamName, Map<String, dynamic> seasonRecord) {
    return {
      'rivalryGames': 2,
      'rivalryRecord': '1-1',
      'biggestRivalryWin': 'Upset victory over traditional rival',
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
          .add('Posted ${overall['wins']} wins - program\'s best in recent years');
    }

    if (postseasonAnalysis['bowlEligibility'] == 'Bowl Eligible') {
      achievements
          .add('Achieved bowl eligibility for fan base and program momentum');
    }

    final bigWins = seasonRecord['bigWins'] as List;
    if (bigWins.isNotEmpty) {
      achievements
          .add('Secured signature victories that elevated program profile');
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
      areas.add('Consistency in key moments and closing out games');
    }

    if (scoring['averageAllowed'] > scoring['averageScored']) {
      areas.add('Defensive efficiency and limiting big plays');
    }

    areas.add('Recruiting depth to compete with conference elite');

    return areas;
  }

  /// Generate 2025 outlook
  static String generate2025Outlook(
      String teamName, Map<String, dynamic> seasonRecord) {
    final overall = seasonRecord['overall'];

    if (overall['wins'] > overall['losses']) {
      return 'Strong foundation established for continued success in 2025 with returning talent and recruiting momentum.';
    } else {
      return 'Valuable experience gained in 2024 provides building blocks for improvement and competitiveness in 2025.';
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
      '${scoring['averageScored']} PPG Scored',
      '${scoring['averageAllowed']} PPG Allowed',
      '${bigWins.length} Signature Wins',
      '${closeGames.length} Games Decided by 7 or Less',
    ];
  }

  // ---------------------------------------------------------------------------
  // Private stat generators
  // ---------------------------------------------------------------------------

  static String _generateRealisticPlayerName(String position) {
    final firstNames = [
      'Jackson', 'Mason', 'Carter', 'Tyler', 'Blake',
      'Connor', 'Austin', 'Ryan', 'Chase', 'Jordan'
    ];
    final lastNames = [
      'Johnson', 'Williams', 'Brown', 'Davis', 'Miller',
      'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas'
    ];
    final random = Random();
    return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
  }

  static String _getRandomYear() {
    final years = ['Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'];
    return years[Random().nextInt(years.length)];
  }

  static Map<String, dynamic> _generateQBStats(int wins, int losses) {
    final base = wins > losses ? 2800 : 2200;
    final random = Random();
    return {
      'yards': base + random.nextInt(800),
      'tds': (wins * 2) + random.nextInt(5),
      'ints': losses + random.nextInt(3),
      'completion': 62.0 + random.nextDouble() * 8,
    };
  }

  static Map<String, dynamic> _generateRBStats(int wins) {
    final base = wins > 6 ? 1200 : 800;
    final random = Random();
    return {
      'yards': base + random.nextInt(400),
      'tds': wins + random.nextInt(3),
      'ypc': 4.2 + random.nextDouble() * 1.5,
      'carries': 180 + random.nextInt(60),
    };
  }

  static Map<String, dynamic> _generateWRStats(int wins) {
    final base = wins > 6 ? 65 : 45;
    final random = Random();
    return {
      'catches': base + random.nextInt(20),
      'yards': (base * 12) + random.nextInt(300),
      'tds': wins + random.nextInt(2),
      'ypc': 12.0 + random.nextDouble() * 3,
    };
  }

  static Map<String, dynamic> _generateDefenseStats(int wins) {
    final base = wins > 6 ? 85 : 65;
    final random = Random();
    return {
      'tackles': base + random.nextInt(30),
      'tfl': 8 + random.nextInt(5),
      'sacks': 4 + random.nextInt(4),
      'ints': 2 + random.nextInt(3),
    };
  }
}
