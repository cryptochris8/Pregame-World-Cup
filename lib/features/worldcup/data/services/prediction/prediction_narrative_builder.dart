import 'dart:math' as math;
import '../../../domain/entities/entities.dart';
import '../enhanced_match_data_service.dart';

/// Generates narrative text and insights for match predictions.
///
/// Produces key factors lists, detailed analysis paragraphs, quick insights,
/// and contextual narratives based on team stats, betting odds, historical
/// patterns, and other prediction metadata.
class PredictionNarrativeBuilder {
  final EnhancedMatchDataService _data;

  PredictionNarrativeBuilder(this._data);

  /// Generates a list of key factors (up to 5) that influence the prediction.
  ///
  /// Each factor is described as a human-readable string. Factors are sorted
  /// by their impact/weight, with the most significant ones listed first.
  List<String> generateKeyFactors({
    required String homeName,
    required String awayName,
    required NationalTeam? homeTeam,
    required NationalTeam? awayTeam,
    required String homeCode,
    required String awayCode,
    required double bettingScore,
    required double eloScore,
    required double formScore,
    required double squadScore,
    required double h2hScore,
    required double hostScore,
    required double injuryScore,
  }) {
    final factors = <_FactorEntry>[];

    // Elo Rating (with fallback description for world ranking)
    if (eloScore.abs() > 0.01) {
      final homeElo = _data.getEloRating(homeCode);
      final awayElo = _data.getEloRating(awayCode);
      if (homeElo != null && awayElo != null) {
        final fav = eloScore > 0 ? homeName : awayName;
        final favRating = eloScore > 0 ? homeElo['eloRating'] : awayElo['eloRating'];
        final undRating = eloScore > 0 ? awayElo['eloRating'] : homeElo['eloRating'];
        factors.add(_FactorEntry(
          eloScore.abs(),
          '$fav rated $favRating vs $undRating in Elo ratings',
        ));
      } else if (homeTeam?.worldRanking != null && awayTeam?.worldRanking != null) {
        final fav = eloScore > 0 ? homeName : awayName;
        final favRank = eloScore > 0 ? homeTeam!.worldRanking : awayTeam!.worldRanking;
        final undRank = eloScore > 0 ? awayTeam!.worldRanking : homeTeam!.worldRanking;
        factors.add(_FactorEntry(
          eloScore.abs(),
          '$fav ranked #$favRank vs #$undRank in world rankings',
        ));
      }
    }

    // Form
    if (formScore.abs() > 0.1) {
      final better = formScore > 0 ? homeName : awayName;
      final betterCode = formScore > 0 ? homeCode : awayCode;
      final summary = _data.getRecentFormSummary(betterCode) ?? 'strong recent form';
      factors.add(_FactorEntry(
        formScore.abs(),
        '$better in $summary',
      ));
    }

    // Betting odds
    if (bettingScore.abs() > 0.1) {
      final fav = bettingScore > 0 ? homeName : awayName;
      factors.add(_FactorEntry(
        bettingScore.abs(),
        'Betting markets favor $fav',
      ));
    }

    // Squad value
    if (squadScore.abs() > 0.15) {
      final richer = squadScore > 0 ? homeName : awayName;
      final richerCode = squadScore > 0 ? homeCode : awayCode;
      final sv = _data.getSquadValue(richerCode);
      final valStr = sv?['totalValueFormatted'] ?? 'higher value';
      factors.add(_FactorEntry(
        squadScore.abs(),
        '$richer boast a $valStr squad',
      ));
    }

    // Host advantage
    if (hostScore.abs() > 0) {
      final host = hostScore > 0 ? homeName : awayName;
      factors.add(_FactorEntry(
        0.3,
        '$host have home crowd support as tournament hosts',
      ));
    }

    // Injuries
    if (injuryScore.abs() > 0.1) {
      final hurt = injuryScore < 0 ? homeCode : awayCode;
      final hurtName = injuryScore < 0 ? homeName : awayName;
      final injuries = _data.getInjuryConcerns(hurt);
      if (injuries.isNotEmpty) {
        final names = injuries.take(2).map((i) => i['playerName']).join(', ');
        factors.add(_FactorEntry(
          injuryScore.abs(),
          '$hurtName missing key players: $names',
        ));
      }
    }

    // WC experience
    if (homeTeam != null && awayTeam != null) {
      final homeTitles = homeTeam.worldCupTitles;
      final awayTitles = awayTeam.worldCupTitles;
      if (homeTitles > 0 || awayTitles > 0) {
        final more = homeTitles >= awayTitles ? homeName : awayName;
        final count = math.max(homeTitles, awayTitles);
        factors.add(_FactorEntry(
          0.2,
          '$more bring $count World Cup title${count == 1 ? '' : 's'} of pedigree',
        ));
      }
    }

    // Sort by impact and take top 5
    factors.sort((a, b) => b.weight.compareTo(a.weight));
    return factors.take(5).map((f) => f.text).toList();
  }

  /// Generates a detailed analysis paragraph for the prediction.
  ///
  /// Incorporates historical context from match summaries if available,
  /// describes the predicted outcome and confidence level, and provides
  /// contextual commentary based on the match stage.
  String generateAnalysis({
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    required int confidence,
    required double composite,
    required WorldCupMatch match,
    Map<String, dynamic>? matchSummary,
  }) {
    final winner = homeScore > awayScore
        ? homeName
        : awayScore > homeScore
            ? awayName
            : null;
    final stage = match.stage.displayName;

    final buffer = StringBuffer();

    // Prepend historical context from match summary if available
    final historicalAnalysis =
        matchSummary?['historicalAnalysis'] as String?;
    if (historicalAnalysis != null && historicalAnalysis.isNotEmpty) {
      // Use just the first sentence or two for conciseness
      final sentences = historicalAnalysis.split(RegExp(r'(?<=\.)\s+'));
      final snippet = sentences.take(2).join(' ');
      buffer.write('$snippet ');
    }

    if (winner != null) {
      final margin = (homeScore - awayScore).abs();
      final marginDesc = margin >= 2 ? 'comfortably' : 'narrowly';
      buffer.write('Our analysis points to $winner winning $marginDesc $homeScore-$awayScore '
          'in this $stage clash. '
          '${confidence >= 65 ? 'Multiple factors align strongly in their favor.' : 'However, this could be a tight affair with margins thin between the two sides.'}');
    } else {
      buffer.write('This $stage match looks evenly balanced, with a $homeScore-$awayScore draw '
          'the most likely outcome. '
          'Neither side holds a decisive advantage across the key factors.');
    }

    return buffer.toString();
  }

  /// Generates a quick one-line insight for the prediction.
  ///
  /// Format: "Winner Score-Score (Confidence%) — Storyline"
  /// Includes a key storyline from the match summary if available.
  String generateQuickInsight({
    required String homeName,
    required String awayName,
    required int homeScore,
    required int awayScore,
    required int confidence,
    Map<String, dynamic>? matchSummary,
  }) {
    String scorePart;
    if (homeScore > awayScore) {
      scorePart = '$homeName $homeScore-$awayScore ($confidence%)';
    } else if (awayScore > homeScore) {
      scorePart = '$awayName $awayScore-$homeScore ($confidence%)';
    } else {
      scorePart = 'Draw $homeScore-$awayScore ($confidence%)';
    }

    // Append a key storyline from the match summary if available
    final storylines = matchSummary?['keyStorylines'] as List<dynamic>?;
    if (storylines != null && storylines.isNotEmpty) {
      final storyline = storylines.first as String;
      return '$scorePart — $storyline';
    }

    return scorePart;
  }

  /// Builds a narrative about squad value comparison.
  ///
  /// Returns a pre-computed narrative from the data service, or null if unavailable.
  String? buildSquadValueNarrative(String homeCode, String awayCode) {
    final comparison = _data.getSquadValueComparison(homeCode, awayCode);
    return comparison?['narrative'] as String?;
  }

  /// Builds a narrative about the manager matchup.
  ///
  /// Format: "Manager1 (formation, style) vs Manager2 (formation, style)"
  Future<String?> buildManagerMatchupNarrative(String homeCode, String awayCode) async {
    final homeManager = await _data.getManagerProfile(homeCode);
    final awayManager = await _data.getManagerProfile(awayCode);
    if (homeManager == null || awayManager == null) return null;

    final hName = '${homeManager['firstName']} ${homeManager['lastName']}';
    final aName = '${awayManager['firstName']} ${awayManager['lastName']}';
    final hForm = homeManager['preferredFormation'] ?? 'unknown';
    final aForm = awayManager['preferredFormation'] ?? 'unknown';
    final hStyle = homeManager['coachingStyle'] ?? 'pragmatic';
    final aStyle = awayManager['coachingStyle'] ?? 'pragmatic';

    return '$hName ($hForm, $hStyle) vs $aName ($aForm, $aStyle)';
  }

  /// Builds a list of historical patterns relevant to the match.
  ///
  /// Patterns are retrieved from the data service based on confederation
  /// matchups and host nation status.
  List<String> buildHistoricalPatterns(NationalTeam? homeTeam, NationalTeam? awayTeam) {
    final patterns = _data.getRelevantPatterns(
      homeConfederation: homeTeam?.confederation.displayName,
      awayConfederation: awayTeam?.confederation.displayName,
      isHostNation: homeTeam?.isHostNation ?? false,
    );
    return patterns.map((p) => (p['title'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// Checks if the match qualifies as a potential upset.
  ///
  /// Returns true if the data service flags this as an upset scenario.
  bool checkUpsetAlert(String homeCode, String awayCode) {
    final upset = _data.getUpsetPotential(homeCode, awayCode);
    return upset?['isUpsetAlert'] == true;
  }

  /// Builds the upset alert text.
  ///
  /// Format: "Upset Alert: Underdog have [chance] chance of springing a surprise here."
  String buildUpsetAlertText(
    String homeName,
    String awayName,
    String homeCode,
    String awayCode,
  ) {
    final upset = _data.getUpsetPotential(homeCode, awayCode);
    if (upset == null) return '';

    final underdog = upset['underdog'] == homeCode ? homeName : awayName;
    final chance = upset['underdogChance'] ?? 'a real';
    return 'Upset Alert: $underdog have $chance chance of springing a surprise here.';
  }

  /// Builds a "confidence debate" narrative when confidence is low.
  ///
  /// Returns null if confidence >= 60. Otherwise, provides context about
  /// the uncertainty and close matchup.
  String? buildConfidenceDebate(
    String homeName,
    String awayName,
    int confidence,
    double composite,
  ) {
    if (confidence >= 60) return null;

    if (confidence < 40) {
      return 'This match is extremely difficult to call. $homeName and $awayName '
          'are closely matched across nearly every metric — rankings, form, '
          'squad value, and betting odds all point to a coin-flip contest.';
    }
    return 'While one side has a slight edge, key factors like form and injuries '
        'could easily swing this result. Do not be surprised by any outcome '
        'in this $homeName vs $awayName clash.';
  }

  /// Builds a summary of betting odds for both teams.
  ///
  /// Format: "Team1 (tier, X% to win tournament) vs Team2 (tier, Y% to win tournament)"
  String? buildBettingOddsSummary(
    String homeCode,
    String awayCode,
    String homeName,
    String awayName,
  ) {
    final homeOdds = _data.getBettingOdds(homeCode);
    final awayOdds = _data.getBettingOdds(awayCode);
    if (homeOdds == null || awayOdds == null) return null;

    final homeTier = homeOdds['tier'] as String? ?? 'unknown';
    final awayTier = awayOdds['tier'] as String? ?? 'unknown';
    final homeProb = homeOdds['implied_probability_pct'] ?? 0;
    final awayProb = awayOdds['implied_probability_pct'] ?? 0;

    return '$homeName ($homeTier, $homeProb% to win tournament) vs '
        '$awayName ($awayTier, $awayProb% to win tournament)';
  }
}

/// Internal helper for sorting factors by weight
class _FactorEntry {
  final double weight;
  final String text;
  _FactorEntry(this.weight, this.text);
}
