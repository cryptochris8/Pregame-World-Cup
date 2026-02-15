import '../../../features/schedule/domain/entities/game_schedule.dart';
import '../../services/cache_service.dart';
import '../../services/logging_service.dart';
import 'ai_historical_knowledge_service.dart';
import 'team_season_constants.dart';
import 'team_season_stats_generator.dart';
import 'team_season_narrative_service.dart';

/// AI Team Season Summary Service
///
/// Generates comprehensive, impressive team season summaries using historical data
/// from 2024 season. Delegates player stats to [TeamSeasonStatsGenerator],
/// narrative text to [TeamSeasonNarrativeService], and shared data to
/// [TeamSeasonConstants].
class AITeamSeasonSummaryService {
  static AITeamSeasonSummaryService? _instance;
  static AITeamSeasonSummaryService get instance => _instance ??= AITeamSeasonSummaryService._();

  AITeamSeasonSummaryService._();

  final AIHistoricalKnowledgeService _historicalService = AIHistoricalKnowledgeService.instance;
  final CacheService _cacheService = CacheService.instance;

  // ==========================================================================
  // Public API
  // ==========================================================================

  /// Generate a comprehensive season summary for a team
  Future<Map<String, dynamic>> generateTeamSeasonSummary(String teamName, {int season = 2024}) async {
    try {
      final cacheKey = 'team_season_summary_${teamName}_$season';

      // Gather all historical data for the team
      final seasonStats = await _historicalService.getSeasonStatistics(season);
      final teamTrends = await _historicalService.getTeamTrends(teamName);
      final games = await _historicalService.getHistoricalGames(season);

      // Create better team name matching logic
      final teamGames = _findTeamGames(games, teamName);

      // Generate comprehensive summary
      final summary = await _buildComprehensiveSeasonSummary(
        teamName,
        season,
        teamGames,
        seasonStats,
        teamTrends,
      );

      // Cache the result for 24 hours
      await _cacheService.set(cacheKey, summary, duration: const Duration(hours: 24));

      return summary;

    } catch (e) {
      LoggingService.error('Team season summary generation failed: $e', tag: 'TeamSummary');
      return _generateFallbackSummary(teamName, season);
    }
  }

  // ==========================================================================
  // Summary orchestration
  // ==========================================================================

  /// Build comprehensive season summary with all details
  Future<Map<String, dynamic>> _buildComprehensiveSeasonSummary(
    String teamName,
    int season,
    List<GameSchedule> teamGames,
    Map<String, dynamic>? seasonStats,
    Map<String, dynamic>? teamTrends,
  ) async {

    // Calculate season record
    final seasonRecord = _calculateSeasonRecord(teamName, teamGames);

    // Generate key insights (delegated to narrative service)
    final keyInsights = TeamSeasonNarrativeService.generateKeyInsights(teamName, seasonRecord, teamGames);

    // Analyze best wins and tough losses
    final gameAnalysis = _analyzeSeasonGames(teamName, teamGames);

    // Generate star players analysis (delegated to stats generator)
    final playersAnalysis = TeamSeasonStatsGenerator.generateStarPlayersAnalysis(teamName, seasonRecord);

    // Determine postseason results
    final postseasonAnalysis = _analyzePostseason(teamName, teamGames, seasonRecord);

    // Conference analysis (delegated to narrative service)
    final conference = TeamSeasonConstants.getTeamConference(teamName);
    final rivalryAnalysis = TeamSeasonStatsGenerator.generateRivalryAnalysis(teamName, seasonRecord);
    final conferenceAnalysis = TeamSeasonNarrativeService.analyzeConferencePerformance(
      teamName, conference, seasonRecord, rivalryAnalysis,
    );

    // Season narrative (delegated to narrative service)
    final seasonNarrative = TeamSeasonNarrativeService.generateSeasonNarrative(teamName, season, seasonRecord, gameAnalysis);

    // Overall assessment (delegated to narrative service + stats generator)
    final baseAssessment = TeamSeasonNarrativeService.generateOverallAssessment(teamName, seasonRecord, postseasonAnalysis);
    final overallAssessment = {
      ...baseAssessment,
      'keyAchievements': TeamSeasonStatsGenerator.generateKeyAchievements(seasonRecord, postseasonAnalysis),
      'areasForImprovement': TeamSeasonStatsGenerator.generateImprovementAreas(seasonRecord),
      'outlookFor2025': TeamSeasonStatsGenerator.generate2025Outlook(teamName, seasonRecord),
    };

    return {
      'teamName': teamName,
      'season': season,
      'lastUpdated': DateTime.now().toIso8601String(),

      // Core stats
      'seasonRecord': seasonRecord,
      'conferenceAnalysis': conferenceAnalysis,
      'postseasonAnalysis': postseasonAnalysis,

      // Detailed insights
      'keyInsights': keyInsights,
      'gameAnalysis': gameAnalysis,
      'playersAnalysis': playersAnalysis,
      'seasonNarrative': seasonNarrative,
      'overallAssessment': overallAssessment,

      // Display data
      'summaryTitle': '$teamName - $season Season in Review',
      'quickSummary': TeamSeasonStatsGenerator.generateQuickSummary(seasonRecord, postseasonAnalysis),
      'highlightStats': TeamSeasonStatsGenerator.generateHighlightStats(seasonRecord, gameAnalysis),
    };
  }

  // ==========================================================================
  // Season record calculation
  // ==========================================================================

  /// Calculate comprehensive season record
  Map<String, dynamic> _calculateSeasonRecord(String teamName, List<GameSchedule> teamGames) {
    final completedGames = teamGames.where((game) =>
      game.homeScore != null && game.awayScore != null
    ).toList();

    int wins = 0, losses = 0;
    int pointsFor = 0, pointsAgainst = 0;
    int conferenceWins = 0, conferenceLosses = 0;
    int homeWins = 0, homeLosses = 0;
    int awayWins = 0, awayLosses = 0;
    List<Map<String, dynamic>> bigWins = [];
    List<Map<String, dynamic>> toughLosses = [];

    for (final game in completedGames) {
      final isHome = game.homeTeamName == teamName;
      final teamScore = isHome ? game.homeScore! : game.awayScore!;
      final opponentScore = isHome ? game.awayScore! : game.homeScore!;
      final opponentName = isHome ? game.awayTeamName : game.homeTeamName;
      final isWin = teamScore > opponentScore;

      pointsFor += teamScore;
      pointsAgainst += opponentScore;

      if (isWin) {
        wins++;
        if (isHome) { homeWins++; } else { awayWins++; }

        if (_isSignificantWin(opponentName, teamScore - opponentScore)) {
          bigWins.add({
            'opponent': opponentName,
            'score': '$teamScore-$opponentScore',
            'location': isHome ? 'Home' : 'Away',
            'margin': teamScore - opponentScore,
            'significance': _getWinSignificance(opponentName, teamScore - opponentScore),
          });
        }
      } else {
        losses++;
        if (isHome) { homeLosses++; } else { awayLosses++; }

        if (_isToughLoss(opponentName, opponentScore - teamScore)) {
          toughLosses.add({
            'opponent': opponentName,
            'score': '$teamScore-$opponentScore',
            'location': isHome ? 'Home' : 'Away',
            'margin': opponentScore - teamScore,
            'context': _getLossContext(opponentName, opponentScore - teamScore),
          });
        }
      }
    }

    return {
      'overall': {'wins': wins, 'losses': losses},
      'home': {'wins': homeWins, 'losses': homeLosses},
      'away': {'wins': awayWins, 'losses': awayLosses},
      'conference': {'wins': conferenceWins, 'losses': conferenceLosses},
      'scoring': {
        'pointsFor': pointsFor,
        'pointsAgainst': pointsAgainst,
        'averageScored': completedGames.isNotEmpty ? (pointsFor / completedGames.length).round() : 0,
        'averageAllowed': completedGames.isNotEmpty ? (pointsAgainst / completedGames.length).round() : 0,
      },
      'bigWins': bigWins,
      'toughLosses': toughLosses,
      'totalGames': completedGames.length,
    };
  }

  // ==========================================================================
  // Game analysis
  // ==========================================================================

  /// Analyze season games for memorable moments
  Map<String, dynamic> _analyzeSeasonGames(String teamName, List<GameSchedule> teamGames) {
    final bigWins = <Map<String, dynamic>>[];
    final upsets = <Map<String, dynamic>>[];
    final closeGames = <Map<String, dynamic>>[];
    final blowouts = <Map<String, dynamic>>[];

    for (final game in teamGames) {
      if (game.homeScore == null || game.awayScore == null) continue;

      final isHome = game.homeTeamName == teamName;
      final teamScore = isHome ? game.homeScore! : game.awayScore!;
      final opponentScore = isHome ? game.awayScore! : game.homeScore!;
      final opponentName = isHome ? game.awayTeamName : game.homeTeamName;
      final margin = (teamScore - opponentScore).abs();
      final isWin = teamScore > opponentScore;

      final gameData = {
        'opponent': opponentName,
        'score': '$teamScore-$opponentScore',
        'location': isHome ? 'Home' : 'Away',
        'margin': margin,
        'result': isWin ? 'W' : 'L',
        'week': game.week ?? 0,
      };

      // Categorize games
      if (margin <= 7) {
        closeGames.add({...gameData, 'type': 'Close Game'});
      } else if (margin >= 21) {
        if (isWin) {
          blowouts.add({...gameData, 'type': 'Dominant Win'});
        }
      }

      // Check for upsets or big wins
      if (TeamSeasonConstants.isEliteProgram(opponentName)) {
        if (isWin) {
          bigWins.add({...gameData, 'type': 'Signature Win'});
        } else {
          upsets.add({...gameData, 'type': 'Quality Opponent'});
        }
      }
    }

    return {
      'bigWins': bigWins,
      'upsets': upsets,
      'closeGames': closeGames,
      'blowouts': blowouts,
      'gameTypeCount': {
        'closeGames': closeGames.length,
        'blowouts': blowouts.length,
        'bigWins': bigWins.length,
      },
    };
  }

  // ==========================================================================
  // Postseason analysis
  // ==========================================================================

  /// Analyze postseason performance
  Map<String, dynamic> _analyzePostseason(String teamName, List<GameSchedule> teamGames, Map<String, dynamic> seasonRecord) {
    final overall = seasonRecord['overall'];
    final wins = overall['wins'];
    final losses = overall['losses'];

    final bowlGames = teamGames.where((game) =>
      (game.week ?? 0) >= 15 &&
      (game.homeScore != null && game.awayScore != null)
    ).toList();

    String bowlEligibility = 'Not Bowl Eligible';
    String bowlResult = '';
    Map<String, dynamic>? bowlGame;

    if (wins >= 6) {
      bowlEligibility = 'Bowl Eligible';

      if (bowlGames.isNotEmpty) {
        final bowl = bowlGames.first;
        final isHome = bowl.homeTeamName == teamName;
        final teamScore = isHome ? bowl.homeScore! : bowl.awayScore!;
        final opponentScore = isHome ? bowl.awayScore! : bowl.homeScore!;
        final opponentName = isHome ? bowl.awayTeamName : bowl.homeTeamName;
        final isWin = teamScore > opponentScore;

        bowlGame = {
          'opponent': opponentName,
          'score': '$teamScore-$opponentScore',
          'result': isWin ? 'W' : 'L',
          'bowlName': TeamSeasonStatsGenerator.getBowlName(wins, losses),
        };

        bowlResult = isWin ? 'Won Bowl Game' : 'Lost Bowl Game';
      } else {
        bowlResult = 'Selected for Bowl Game';
      }
    }

    // Playoff considerations
    String playoffStatus = 'Did Not Make Playoff';
    if (wins >= 11 && losses <= 2) {
      playoffStatus = 'Playoff Contender';
    } else if (wins >= 9) {
      playoffStatus = 'Ranked Team';
    }

    return {
      'bowlEligibility': bowlEligibility,
      'bowlResult': bowlResult,
      'bowlGame': bowlGame,
      'playoffStatus': playoffStatus,
      'seasonOutcome': TeamSeasonStatsGenerator.getSeasonOutcome(wins, losses, bowlResult),
    };
  }

  // ==========================================================================
  // Team name matching
  // ==========================================================================

  /// Find team games with intelligent name matching
  List<GameSchedule> _findTeamGames(List<GameSchedule> games, String teamName) {
    // Try exact match first
    var matches = games.where((game) =>
      game.homeTeamName == teamName || game.awayTeamName == teamName
    ).toList();

    if (matches.isNotEmpty) return matches;

    // Try common team name variations
    final variations = _getTeamNameVariations(teamName);
    for (final variation in variations) {
      matches = games.where((game) =>
        game.homeTeamName == variation || game.awayTeamName == variation
      ).toList();
      if (matches.isNotEmpty) return matches;
    }

    // Try partial matching with stricter criteria
    final teamKeywords = teamName.toLowerCase().split(' ');
    final meaningfulKeywords = teamKeywords.where((word) =>
      !['state', 'university', 'college', 'of', 'the', 'and'].contains(word)
    ).toList();

    if (meaningfulKeywords.isNotEmpty) {
      matches = games.where((game) {
        final homeWords = game.homeTeamName.toLowerCase().split(' ');
        final awayWords = game.awayTeamName.toLowerCase().split(' ');

        final homeMatches = meaningfulKeywords.where((keyword) =>
          homeWords.any((word) => word == keyword || (keyword.length > 4 && word.contains(keyword)))
        ).length;

        final awayMatches = meaningfulKeywords.where((keyword) =>
          awayWords.any((word) => word == keyword || (keyword.length > 4 && word.contains(keyword)))
        ).length;

        return homeMatches >= 2 || awayMatches >= 2 ||
               (homeMatches >= 1 && meaningfulKeywords.length == 1) ||
               (awayMatches >= 1 && meaningfulKeywords.length == 1);
      }).toList();
    }

    return matches;
  }

  /// Get common team name variations
  List<String> _getTeamNameVariations(String teamName) {
    final variations = <String>[];

    if (TeamSeasonConstants.commonVariations.containsKey(teamName)) {
      variations.addAll(TeamSeasonConstants.commonVariations[teamName]!);
    }

    if (teamName.contains(' ')) {
      final parts = teamName.split(' ');
      if (parts.length >= 2) {
        variations.add(parts.first);
        variations.add('${parts.first} ${parts.last}');
        if (parts.length > 2) {
          variations.add(parts.sublist(0, parts.length - 1).join(' '));
        }
      }
    }

    return variations;
  }

  // ==========================================================================
  // Private helpers
  // ==========================================================================

  bool _isSignificantWin(String opponent, int margin) {
    return TeamSeasonConstants.isEliteProgram(opponent) || margin >= 14;
  }

  bool _isToughLoss(String opponent, int margin) {
    return margin <= 7 || TeamSeasonConstants.isEliteProgram(opponent);
  }

  String _getWinSignificance(String opponent, int margin) {
    if (TeamSeasonConstants.isEliteProgram(opponent)) {
      return 'Upset victory over ranked opponent';
    } else if (margin >= 21) {
      return 'Dominant performance';
    }
    return 'Quality win';
  }

  String _getLossContext(String opponent, int margin) {
    if (margin <= 3) {
      return 'Heartbreaking last-second loss';
    } else if (margin <= 7) {
      return 'Close battle that could have gone either way';
    } else if (TeamSeasonConstants.isEliteProgram(opponent)) {
      return 'Tough matchup against elite competition';
    }
    return 'Learning experience';
  }

  /// Generate fallback summary when data is unavailable
  Map<String, dynamic> _generateFallbackSummary(String teamName, int season) {
    return {
      'teamName': teamName,
      'season': season,
      'quickSummary': '$season season data not available in current sample - comprehensive analysis coming soon',
      'seasonRecord': {
        'overall': {'wins': 0, 'losses': 0},
        'conference': {'wins': 0, 'losses': 0},
        'home': {'wins': 0, 'losses': 0},
        'away': {'wins': 0, 'losses': 0},
        'scoring': {'averageScored': 0, 'averageAllowed': 0}
      },
      'keyInsights': [
        'Team not included in current $season data sample',
        'Historical analysis being expanded to include more teams',
        'Check back soon for complete season breakdown'
      ],
      'overallAssessment': {
        'seasonGrade': 'Data Pending',
        'assessment': 'Season analysis will be available when data expansion is complete',
        'keyAchievements': ['Data processing in progress'],
        'improvementAreas': ['Comprehensive analysis coming soon'],
        'outlook2025': 'Complete historical analysis will provide detailed outlook'
      },
      'playersAnalysis': {
        'starPlayers': [],
        'breakoutPerformers': []
      },
      'postseasonAnalysis': {
        'bowlEligibility': 'Data Pending',
        'bowlGame': 'Analysis pending',
        'seasonOutcome': 'Comprehensive review coming soon'
      }
    };
  }
}
