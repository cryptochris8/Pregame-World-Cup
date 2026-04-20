import 'dart:math' as math;
import '../../../domain/entities/entities.dart';
import '../enhanced_match_data_service.dart';
import 'prediction_form_evaluator.dart';

/// Scores individual prediction factors comparing home vs away teams.
///
/// Each factor scoring method returns a value from -1.0 to +1.0,
/// where positive values favor the home team and negative values favor away.
/// A score of 0.0 indicates neutral/balanced for that factor.
class PredictionFactorScorer {
  final EnhancedMatchDataService _data;

  static const Set<String> _hostNations = {'USA', 'MEX', 'CAN'};

  PredictionFactorScorer(this._data);

  // ========== FACTOR SCORING (-1.0 to +1.0, positive = home-favored) ==========

  /// Factor 1: Betting odds implied probability comparison
  double scoreBettingOdds(String homeCode, String awayCode) {
    final homeOdds = _data.getBettingOdds(homeCode);
    final awayOdds = _data.getBettingOdds(awayCode);
    if (homeOdds == null || awayOdds == null) return 0.0;

    final homeProb = ((homeOdds['implied_probability_pct'] as num?) ?? 0).toDouble();
    final awayProb = ((awayOdds['implied_probability_pct'] as num?) ?? 0).toDouble();

    if (homeProb + awayProb == 0) return 0.0;

    // Normalize difference to [-1, 1]
    final diff = (homeProb - awayProb) / (homeProb + awayProb);
    return diff.clamp(-1.0, 1.0);
  }

  /// Factor 2: Elo rating comparison using tanh curve.
  ///
  /// Uses the World Football Elo Rating system, which is strictly superior
  /// to world rankings because it accounts for margin of victory, match
  /// importance, and home advantage. Falls back to world rankings if Elo
  /// data is unavailable.
  double scoreEloRating(
    String homeCode,
    String awayCode,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    final homeElo = _data.getEloRating(homeCode);
    final awayElo = _data.getEloRating(awayCode);

    if (homeElo != null && awayElo != null) {
      final homeRating =
          ((homeElo['eloRating'] as num?) ?? 1500).toDouble();
      final awayRating =
          ((awayElo['eloRating'] as num?) ?? 1500).toDouble();

      // Elo difference of ~200 points ≈ 75% expected win rate.
      // Scale so 200-point gap maps to ~0.76 via tanh(200/200).
      return tanh((homeRating - awayRating) / 200.0);
    }

    // Fallback: use world rankings if Elo data is not available
    final homeRank = homeTeam?.worldRanking ?? 50;
    final awayRank = awayTeam?.worldRanking ?? 50;

    // Lower rank = better. Positive diff means home is better.
    final diff = awayRank - homeRank;

    // tanh scaling: 20 ranks difference → ~0.96
    return tanh(diff / 20.0);
  }

  /// Factor 3: Recent form weighted by opponent quality and competition type.
  ///
  /// Uses tanh scaling on the difference so that a ~1.5 point gap maps to
  /// approximately +/-0.8, providing smooth saturation.
  double scoreRecentForm(String homeCode, String awayCode) {
    final homeForm = _data.getRecentForm(homeCode);
    final awayForm = _data.getRecentForm(awayCode);

    // Extract matches list from form data
    final homeMatches = homeForm != null
        ? ((homeForm['recent_matches'] ?? homeForm['matches']) as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
        : null;
    final awayMatches = awayForm != null
        ? ((awayForm['recent_matches'] ?? awayForm['matches']) as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
        : null;

    final homePoints = PredictionFormEvaluator.formPoints(homeMatches);
    final awayPoints = PredictionFormEvaluator.formPoints(awayMatches);

    if (homePoints == null && awayPoints == null) return 0.0;
    final hp = homePoints ?? 0.75; // neutral default (midpoint of typical range)
    final ap = awayPoints ?? 0.75;

    // Use tanh scaling: a difference of ~1.5 points maps to ~0.8
    return tanh((hp - ap) / 1.5);
  }

  /// Factor 4: Squad market value ratio
  double scoreSquadValue(String homeCode, String awayCode) {
    final home = _data.getSquadValue(homeCode);
    final away = _data.getSquadValue(awayCode);
    if (home == null || away == null) return 0.0;

    final homeVal = ((home['totalValue'] as num?) ?? 0).toDouble();
    final awayVal = ((away['totalValue'] as num?) ?? 0).toDouble();

    if (homeVal + awayVal == 0) return 0.0;

    // Log ratio so extreme differences don't dominate
    final ratio = homeVal / (awayVal > 0 ? awayVal : 1.0);
    return tanh(math.log(ratio) / math.log(3));
  }

  /// Factor 5: Head-to-head historical record from actual H2H JSON data.
  ///
  /// Loads the H2H file for the team pairing and computes a score based on:
  ///   - Overall win percentage (40% of H2H score)
  ///   - World Cup-specific record (40% of H2H score)
  ///   - Goal difference ratio (20% of H2H score)
  ///
  /// Returns neutral 0.0 if no H2H file exists for the pairing.
  Future<double> scoreHeadToHead(String homeCode, String awayCode) async {
    final h2h = await _data.getHeadToHead(homeCode, awayCode);
    if (h2h == null) return 0.0;

    final team1Code = (h2h['team1Code'] as String?) ?? '';
    final totalMatches = ((h2h['totalMatches'] as num?) ?? 0).toInt();
    if (totalMatches == 0) return 0.0;

    // Determine which team in the H2H file corresponds to home/away
    final bool homeIsTeam1 = team1Code.toUpperCase() == homeCode.toUpperCase();

    final team1Wins = ((h2h['team1Wins'] as num?) ?? 0).toDouble();
    final team2Wins = ((h2h['team2Wins'] as num?) ?? 0).toDouble();
    final team1Goals = ((h2h['team1Goals'] as num?) ?? 0).toDouble();
    final team2Goals = ((h2h['team2Goals'] as num?) ?? 0).toDouble();
    final wcMatches = ((h2h['worldCupMatches'] as num?) ?? 0).toInt();
    final team1WcWins = ((h2h['team1WorldCupWins'] as num?) ?? 0).toDouble();
    final team2WcWins = ((h2h['team2WorldCupWins'] as num?) ?? 0).toDouble();

    // Map to home/away perspective
    final homeWins = homeIsTeam1 ? team1Wins : team2Wins;
    final awayWins = homeIsTeam1 ? team2Wins : team1Wins;
    final homeGoals = homeIsTeam1 ? team1Goals : team2Goals;
    final awayGoals = homeIsTeam1 ? team2Goals : team1Goals;
    final homeWcWins = homeIsTeam1 ? team1WcWins : team2WcWins;
    final awayWcWins = homeIsTeam1 ? team2WcWins : team1WcWins;

    // --- 1. Overall win percentage (40% of H2H score) ---
    // Normalize: homeWinPct - awayWinPct, range [-1, 1]
    final homeWinPct = homeWins / totalMatches;
    final awayWinPct = awayWins / totalMatches;
    final overallScore = (homeWinPct - awayWinPct).clamp(-1.0, 1.0);

    // --- 2. World Cup-specific record (40% of H2H score) ---
    double wcScore = 0.0;
    if (wcMatches > 0) {
      final homeWcPct = homeWcWins / wcMatches;
      final awayWcPct = awayWcWins / wcMatches;
      wcScore = (homeWcPct - awayWcPct).clamp(-1.0, 1.0);
    }

    // --- 3. Goal difference ratio (20% of H2H score) ---
    double goalScore = 0.0;
    final totalGoals = homeGoals + awayGoals;
    if (totalGoals > 0) {
      goalScore = ((homeGoals - awayGoals) / totalGoals).clamp(-1.0, 1.0);
    }

    // Weighted blend
    final composite = overallScore * 0.4 + wcScore * 0.4 + goalScore * 0.2;
    return composite.clamp(-1.0, 1.0);
  }

  /// Factor 6: Manager WC experience and career win rate
  Future<double> scoreManager(String homeCode, String awayCode) async {
    final homeManager = await _data.getManagerProfile(homeCode);
    final awayManager = await _data.getManagerProfile(awayCode);
    if (homeManager == null || awayManager == null) return 0.0;

    final homeWinRate = ((homeManager['careerWinPercentage'] as num?) ?? 50).toDouble();
    final awayWinRate = ((awayManager['careerWinPercentage'] as num?) ?? 50).toDouble();

    // Check WC experience
    final homeWcExp = (homeManager['worldCupExperience'] as Map<String, dynamic>?);
    final awayWcExp = (awayManager['worldCupExperience'] as Map<String, dynamic>?);
    final homeWcGames = ((homeWcExp?['matchesAsCoach'] as num?) ?? 0).toDouble();
    final awayWcGames = ((awayWcExp?['matchesAsCoach'] as num?) ?? 0).toDouble();

    // Blend win rate difference + WC experience
    final winRateDiff = (homeWinRate - awayWinRate) / 100.0;
    final expDiff = (homeWcGames - awayWcGames) / 20.0; // 20 games = large diff

    return (winRateDiff * 0.6 + tanh(expDiff) * 0.4).clamp(-1.0, 1.0);
  }

  /// Factor 7: Host nation advantage
  double scoreHostAdvantage(String homeCode, String awayCode) {
    final homeIsHost = _hostNations.contains(homeCode);
    final awayIsHost = _hostNations.contains(awayCode);

    if (homeIsHost && !awayIsHost) return 0.3;
    if (awayIsHost && !homeIsHost) return -0.3;
    return 0.0;
  }

  /// Factor 8: World Cup experience (appearances + titles)
  double scoreWorldCupExperience(NationalTeam? homeTeam, NationalTeam? awayTeam) {
    if (homeTeam == null || awayTeam == null) return 0.0;

    // Score = appearances * 1 + titles * 5 + bestFinish bonus
    final homeExp = homeTeam.worldCupAppearances +
        homeTeam.worldCupTitles * 5 +
        PredictionFormEvaluator.bestFinishBonus(homeTeam.bestFinish);
    final awayExp = awayTeam.worldCupAppearances +
        awayTeam.worldCupTitles * 5 +
        PredictionFormEvaluator.bestFinishBonus(awayTeam.bestFinish);

    if (homeExp + awayExp == 0) return 0.0;
    return tanh((homeExp - awayExp).toDouble() / 15.0);
  }

  /// Factor 9: Injury impact on key players
  double scoreInjuryImpact(String homeCode, String awayCode) {
    final homeInjuries = _data.getInjuryConcerns(homeCode);
    final awayInjuries = _data.getInjuryConcerns(awayCode);

    // Weight injuries by severity
    final homeImpact = PredictionFormEvaluator.injurySeverityTotal(homeInjuries);
    final awayImpact = PredictionFormEvaluator.injurySeverityTotal(awayInjuries);

    // More injuries = worse for that team, so flip sign for home
    if (homeImpact + awayImpact == 0) return 0.0;
    return tanh((awayImpact - homeImpact) / 3.0);
  }

  /// Factor 10: Confederation historical record at tournaments
  ///
  /// Looks up the head-to-head record between the two teams' confederations
  /// from `confederation_records.json` and scores based on historical win
  /// percentages. Returns 0.0 for intra-confederation matches or missing data.
  double scoreConfederationRecord(
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    if (homeTeam == null || awayTeam == null) return 0.0;

    final homeConf = homeTeam.confederation.displayName;
    final awayConf = awayTeam.confederation.displayName;

    // Same confederation → no inter-confederation advantage
    if (homeConf == awayConf) return 0.0;

    final record = _data.getConfederationMatchup(homeConf, awayConf);
    if (record == null) return 0.0;

    final conf1 = record['confederation1'] as String? ?? '';
    final conf1WinPct = ((record['confederation1WinPct'] as num?) ?? 0).toDouble();
    final conf2WinPct = ((record['confederation2WinPct'] as num?) ?? 0).toDouble();

    // Map to home/away perspective
    final homeWinPct = (conf1 == homeConf) ? conf1WinPct : conf2WinPct;
    final awayWinPct = (conf1 == homeConf) ? conf2WinPct : conf1WinPct;

    if (homeWinPct + awayWinPct == 0) return 0.0;

    // Normalize difference to [-1, 1]
    final diff = (homeWinPct - awayWinPct) / (homeWinPct + awayWinPct);
    return diff.clamp(-1.0, 1.0);
  }

  // ========== ATTACK/DEFENSE STRENGTH DECOMPOSITION ==========

  /// Compute attack, defense, and midfield strength scores for a team
  /// based on positional market values from the squad roster.
  ///
  /// Positions are classified as:
  ///   - Attack: ST, LW, RW, CF, SS (strikers and wingers)
  ///   - Midfield: CAM, CM, CDM, LM, RM (all midfield roles)
  ///   - Defense: CB, LB, RB, LWB, RWB, GK (defenders and goalkeepers)
  ///
  /// Returns a map with keys 'attack', 'defense', 'midfield' containing
  /// the total market value for each unit, or null if data unavailable.
  Future<Map<String, double>?> computeTeamStrength(String teamCode) async {
    final teamData = await _data.getTeamSquadPlayers(teamCode);
    if (teamData == null) return null;

    final players = teamData['players'] as List<dynamic>?;
    if (players == null || players.isEmpty) return null;

    double attackValue = 0;
    double defenseValue = 0;
    double midfieldValue = 0;

    for (final p in players) {
      final player = p as Map<String, dynamic>;
      final position = (player['position'] as String?) ?? '';
      final value = ((player['marketValue'] as num?) ?? 0).toDouble();

      if (isAttackPosition(position)) {
        attackValue += value;
      } else if (isDefensePosition(position)) {
        defenseValue += value;
      } else {
        // Midfield and any unrecognized positions
        midfieldValue += value;
      }
    }

    return {
      'attack': attackValue,
      'defense': defenseValue,
      'midfield': midfieldValue,
    };
  }

  /// Whether a position code is an attacking role
  bool isAttackPosition(String position) {
    const attackPositions = {'ST', 'LW', 'RW', 'CF', 'SS'};
    return attackPositions.contains(position.toUpperCase());
  }

  /// Whether a position code is a defensive role (including GK)
  bool isDefensePosition(String position) {
    const defensePositions = {'CB', 'LB', 'RB', 'LWB', 'RWB', 'GK'};
    return defensePositions.contains(position.toUpperCase());
  }

  // ========== HELPERS ==========

  /// Hyperbolic tangent for smooth [-1, 1] mapping
  static double tanh(double x) {
    final e2x = math.exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }
}
