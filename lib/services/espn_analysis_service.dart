import 'package:pregame_world_cup/core/entities/game_intelligence.dart';
import 'espn_team_matcher.dart';
import 'espn_venue_recommendations.dart';

/// Handles analysis of ESPN soccer match data to create actionable intelligence.
/// Calculates crowd factors, TV audience estimates, storylines, and confidence scores.
class ESPNAnalysisService {
  final ESPNTeamMatcher _teamMatcher;
  final ESPNVenueRecommendationGenerator _venueRecommendationGenerator;

  ESPNAnalysisService({
    ESPNTeamMatcher? teamMatcher,
    ESPNVenueRecommendationGenerator? venueRecommendationGenerator,
  })  : _teamMatcher = teamMatcher ?? ESPNTeamMatcher(),
        _venueRecommendationGenerator = venueRecommendationGenerator ?? ESPNVenueRecommendationGenerator();

  /// Analyze ESPN soccer match data to create actionable intelligence
  Future<GameIntelligence> analyzeGameData(Map<String, dynamic> espnData) async {
    final header = espnData['header'] ?? {};
    final competitions = espnData['competitions'] ?? [];

    String homeTeam = '';
    String awayTeam = '';
    int? homeRank;
    int? awayRank;

    if (competitions.isNotEmpty) {
      final teams = competitions[0]['competitors'] ?? [];
      for (var team in teams) {
        final teamData = team['team'] ?? {};
        final isHome = team['homeAway'] == 'home';
        final teamName = teamData['displayName'] ?? '';
        // FIFA ranking from ESPN data
        final rank = parseRank(team['curatedRank']?.toString());

        if (isHome) {
          homeTeam = teamName;
          homeRank = rank;
        } else {
          awayTeam = teamName;
          awayRank = rank;
        }
      }
    }

    // Calculate crowd factor based on FIFA rankings and match importance
    final crowdFactor = calculateCrowdFactor(
      homeRank: homeRank,
      awayRank: awayRank,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      gameData: espnData,
    );

    // Detect rivalry/derby matches
    final isRivalry = _teamMatcher.isRivalryGame(homeTeam, awayTeam);

    // Analyze knockout/championship implications
    final hasChampImplications = hasChampionshipImplications(espnData);

    // Extract broadcast information
    final broadcast = extractBroadcastInfo(espnData);

    // Generate venue recommendations for watch parties and sports bars
    final venueRecommendations = _venueRecommendationGenerator.generateVenueRecommendations(
      crowdFactor: crowdFactor,
      isRivalry: isRivalry,
      hasChampImplications: hasChampImplications,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
    );

    return GameIntelligence(
      gameId: header['id']?.toString() ?? '',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamRank: homeRank,
      awayTeamRank: awayRank,
      crowdFactor: crowdFactor,
      isRivalryGame: isRivalry,
      hasChampionshipImplications: hasChampImplications,
      broadcastNetwork: broadcast['network'] ?? 'TBD',
      expectedTvAudience: estimateTvAudience(crowdFactor, isRivalry, broadcast['network']),
      keyStorylines: extractKeyStorylines(espnData, isRivalry, hasChampImplications),
      teamStats: extractTeamStats(espnData),
      lastUpdated: DateTime.now(),
      confidenceScore: calculateConfidenceScore(espnData),
      venueRecommendations: venueRecommendations,
    );
  }

  /// Calculate crowd factor based on FIFA rankings, rivalry status, and match stage
  double calculateCrowdFactor({
    int? homeRank,
    int? awayRank,
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameData,
  }) {
    double factor = 1.0; // Base factor

    // FIFA ranking impact (higher ranked = more interest)
    // Top 10 nations draw massive crowds
    if (homeRank != null && homeRank <= 50) {
      factor += (51 - homeRank) * 0.01; // Up to +0.5 for #1 ranked team
    }
    if (awayRank != null && awayRank <= 50) {
      factor += (51 - awayRank) * 0.01;
    }

    // Both teams in top 10 FIFA rankings
    if ((homeRank != null && homeRank <= 10) && (awayRank != null && awayRank <= 10)) {
      factor += 0.5; // Top 10 matchup bonus
    }

    // International rivalry/derby bonus
    if (_teamMatcher.isRivalryGame(homeTeam, awayTeam)) {
      factor += 0.7; // Major rivalry bonus (World Cup rivalries draw huge interest)
    }

    // Knockout round / championship implications
    if (hasChampionshipImplications(gameData)) {
      factor += 0.6;
    }

    // Weekend matches tend to draw bigger watch party crowds
    final gameTime = DateTime.tryParse(gameData['header']?['timeValid'] ?? '');
    if (gameTime != null && (gameTime.weekday == DateTime.saturday || gameTime.weekday == DateTime.sunday)) {
      factor += 0.2;
    }

    // Cap the maximum crowd factor at 3.0 (300% of normal)
    return factor > 3.0 ? 3.0 : factor;
  }

  /// Analyze if match has knockout/championship implications
  bool hasChampionshipImplications(Map<String, dynamic> gameData) {
    final notes = gameData['notes']?.toString().toLowerCase() ?? '';
    final situation = gameData['situation']?.toString().toLowerCase() ?? '';
    final header = gameData['header']?.toString().toLowerCase() ?? '';

    return notes.contains('final') ||
           notes.contains('semifinal') ||
           notes.contains('semi-final') ||
           notes.contains('quarter-final') ||
           notes.contains('quarterfinal') ||
           notes.contains('knockout') ||
           notes.contains('round of 16') ||
           notes.contains('round of 32') ||
           situation.contains('elimination') ||
           situation.contains('knockout') ||
           header.contains('final') ||
           header.contains('knockout');
  }

  /// Extract broadcast information
  Map<String, String> extractBroadcastInfo(Map<String, dynamic> gameData) {
    final competitions = gameData['competitions'] ?? [];
    if (competitions.isNotEmpty) {
      final broadcasts = competitions[0]['broadcasts'] ?? [];
      if (broadcasts.isNotEmpty) {
        return {
          'network': broadcasts[0]['names']?[0] ?? 'TBD',
          'type': broadcasts[0]['type']?['shortName'] ?? 'TV',
        };
      }
    }
    return {'network': 'TBD', 'type': 'TV'};
  }

  /// Estimate TV audience for a World Cup match based on various factors
  double estimateTvAudience(double crowdFactor, bool isRivalry, String? network) {
    // World Cup matches draw massive global audiences
    double baseAudience = 10.0; // Million US viewers baseline for World Cup

    // Network influence for US broadcast
    switch (network?.toUpperCase()) {
      case 'FOX':
        baseAudience = 15.0; // FOX has primary English rights for WC 2026
        break;
      case 'FS1':
        baseAudience = 10.0;
        break;
      case 'TELEMUNDO':
      case 'UNIVERSO':
        baseAudience = 12.0; // Spanish-language draws huge audiences
        break;
      case 'PEACOCK':
        baseAudience = 8.0;
        break;
      default:
        baseAudience = 10.0;
    }

    // Apply crowd factor and rivalry bonus
    double estimatedAudience = baseAudience * crowdFactor;
    if (isRivalry) {
      estimatedAudience *= 1.4; // Rivalries draw even more viewers
    }

    return estimatedAudience;
  }

  /// Extract key storylines for marketing and engagement
  List<String> extractKeyStorylines(Map<String, dynamic> gameData, bool isRivalry, bool hasChampImplications) {
    List<String> storylines = [];

    if (isRivalry) {
      storylines.add('Historic International Rivalry');
    }

    if (hasChampImplications) {
      storylines.add('Knockout Stage Match - Win or Go Home');
    }

    // Add storylines based on match data
    final situation = gameData['situation']?.toString() ?? '';
    if (situation.contains('unbeaten') || situation.contains('undefeated')) {
      storylines.add('Unbeaten Run on the Line');
    }

    final notes = gameData['notes']?.toString().toLowerCase() ?? '';
    if (notes.contains('group')) {
      storylines.add('Group Stage - Fight for Qualification');
    }
    if (notes.contains('final')) {
      storylines.add('World Cup Final - The Biggest Match in Football');
    }

    return storylines;
  }

  /// Extract relevant team statistics from ESPN soccer data
  Map<String, dynamic> extractTeamStats(Map<String, dynamic> gameData) {
    Map<String, dynamic> stats = {};

    final competitions = gameData['competitions'] ?? [];
    if (competitions.isNotEmpty) {
      final teams = competitions[0]['competitors'] ?? [];
      for (var team in teams) {
        final teamData = team['team'] ?? {};
        final record = team['records']?[0] ?? {};
        final teamName = teamData['displayName'] ?? '';

        // Soccer records: W-D-L format (wins-draws-losses)
        stats[teamName] = {
          'wins': record['wins'] ?? 0,
          'draws': record['ties'] ?? record['draws'] ?? 0,
          'losses': record['losses'] ?? 0,
          'rank': parseRank(team['curatedRank']?.toString()),
          'record_summary': record['displayValue'] ?? 'N/A',
        };
      }
    }

    return stats;
  }

  /// Helper method to parse ranking from various ESPN formats
  int? parseRank(String? rankString) {
    if (rankString == null || rankString.isEmpty) return null;
    final rankMatch = RegExp(r'\d+').firstMatch(rankString);
    return rankMatch != null ? int.tryParse(rankMatch.group(0)!) : null;
  }

  /// Calculate confidence score based on data completeness
  double calculateConfidenceScore(Map<String, dynamic> gameData) {
    double score = 0.0;

    // Check data completeness
    if (gameData['header'] != null) score += 0.2;
    if (gameData['competitions'] != null && gameData['competitions'].isNotEmpty) score += 0.3;
    if (gameData['competitions']?[0]?['competitors'] != null) score += 0.3;
    if (gameData['situation'] != null) score += 0.1;
    if (gameData['notes'] != null) score += 0.1;

    return score;
  }
}
