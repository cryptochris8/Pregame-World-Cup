import 'package:equatable/equatable.dart';

/// AI-generated prediction outcome
enum AIPredictedOutcome {
  homeWin,
  draw,
  awayWin,
}

/// Extension for AIPredictedOutcome
extension AIPredictedOutcomeExtension on AIPredictedOutcome {
  String get displayName {
    switch (this) {
      case AIPredictedOutcome.homeWin:
        return 'Home Win';
      case AIPredictedOutcome.draw:
        return 'Draw';
      case AIPredictedOutcome.awayWin:
        return 'Away Win';
    }
  }
}

/// AI-generated match prediction for World Cup matches
///
/// Contains predicted scores, win probability, confidence level,
/// key factors, and detailed analysis from AI providers (Claude/OpenAI).
class AIMatchPrediction extends Equatable {
  /// Match ID this prediction is for
  final String matchId;

  /// Predicted outcome (home win, draw, away win)
  final AIPredictedOutcome predictedOutcome;

  /// Predicted home team score
  final int predictedHomeScore;

  /// Predicted away team score
  final int predictedAwayScore;

  /// Confidence level (0-100)
  final int confidence;

  /// Win probability for home team (0-100)
  final int homeWinProbability;

  /// Draw probability (0-100)
  final int drawProbability;

  /// Win probability for away team (0-100)
  final int awayWinProbability;

  /// Key factors influencing the prediction (3-5 items)
  final List<String> keyFactors;

  /// Detailed analysis text
  final String analysis;

  /// Short one-liner insight for cards
  final String quickInsight;

  /// AI provider used ('Claude' or 'OpenAI')
  final String provider;

  /// When the prediction was generated
  final DateTime generatedAt;

  /// Time-to-live in minutes (for cache invalidation)
  final int ttlMinutes;

  /// Whether this match has upset potential
  final bool isUpsetAlert;

  /// Upset alert description (if applicable)
  final String? upsetAlertText;

  /// Squad value comparison narrative
  final String? squadValueNarrative;

  /// Manager tactical matchup description
  final String? managerMatchup;

  /// Relevant historical patterns for this matchup
  final List<String> historicalPatterns;

  /// Confidence debate text (why AI is uncertain, shown when confidence < 60)
  final String? confidenceDebate;

  /// Recent form summary for home team
  final String? homeRecentForm;

  /// Recent form summary for away team
  final String? awayRecentForm;

  /// Betting odds implied probability for favorite
  final String? bettingOddsSummary;

  const AIMatchPrediction({
    required this.matchId,
    required this.predictedOutcome,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    required this.confidence,
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
    required this.keyFactors,
    required this.analysis,
    required this.quickInsight,
    required this.provider,
    required this.generatedAt,
    this.ttlMinutes = 1440, // 24 hours for persistent caching
    this.isUpsetAlert = false,
    this.upsetAlertText,
    this.squadValueNarrative,
    this.managerMatchup,
    this.historicalPatterns = const [],
    this.confidenceDebate,
    this.homeRecentForm,
    this.awayRecentForm,
    this.bettingOddsSummary,
  });

  @override
  List<Object?> get props => [
        matchId,
        predictedOutcome,
        predictedHomeScore,
        predictedAwayScore,
        confidence,
        generatedAt,
      ];

  /// Check if prediction is still valid (within TTL)
  bool get isValid {
    final now = DateTime.now();
    final expiresAt = generatedAt.add(Duration(minutes: ttlMinutes));
    return now.isBefore(expiresAt);
  }

  /// Get predicted score as display string (e.g., "2-1")
  String get scoreDisplay => '$predictedHomeScore-$predictedAwayScore';

  /// Get confidence as description
  String get confidenceDescription {
    if (confidence >= 80) return 'Very High';
    if (confidence >= 65) return 'High';
    if (confidence >= 50) return 'Moderate';
    if (confidence >= 35) return 'Low';
    return 'Very Low';
  }

  /// Factory to create from AI response map
  factory AIMatchPrediction.fromMap(Map<String, dynamic> map, String matchId) {
    final predictedHome = map['predictedHomeScore'] as int? ?? 1;
    final predictedAway = map['predictedAwayScore'] as int? ?? 1;

    AIPredictedOutcome outcome;
    if (predictedHome > predictedAway) {
      outcome = AIPredictedOutcome.homeWin;
    } else if (predictedAway > predictedHome) {
      outcome = AIPredictedOutcome.awayWin;
    } else {
      outcome = AIPredictedOutcome.draw;
    }

    return AIMatchPrediction(
      matchId: matchId,
      predictedOutcome: outcome,
      predictedHomeScore: predictedHome,
      predictedAwayScore: predictedAway,
      confidence: map['confidence'] as int? ?? 50,
      homeWinProbability: map['homeWinProbability'] as int? ?? 33,
      drawProbability: map['drawProbability'] as int? ?? 34,
      awayWinProbability: map['awayWinProbability'] as int? ?? 33,
      keyFactors: (map['keyFactors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      analysis: map['analysis'] as String? ?? '',
      quickInsight: map['quickInsight'] as String? ?? '',
      provider: map['provider'] as String? ?? 'AI',
      generatedAt: map['generatedAt'] != null
          ? DateTime.parse(map['generatedAt'] as String)
          : DateTime.now(),
      ttlMinutes: map['ttlMinutes'] as int? ?? 1440, // 24 hours default
      isUpsetAlert: map['isUpsetAlert'] as bool? ?? false,
      upsetAlertText: map['upsetAlertText'] as String?,
      squadValueNarrative: map['squadValueNarrative'] as String?,
      managerMatchup: map['managerMatchup'] as String?,
      historicalPatterns: (map['historicalPatterns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      confidenceDebate: map['confidenceDebate'] as String?,
      homeRecentForm: map['homeRecentForm'] as String?,
      awayRecentForm: map['awayRecentForm'] as String?,
      bettingOddsSummary: map['bettingOddsSummary'] as String?,
    );
  }

  /// Convert to map for storage/caching
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'predictedOutcome': predictedOutcome.name,
      'predictedHomeScore': predictedHomeScore,
      'predictedAwayScore': predictedAwayScore,
      'confidence': confidence,
      'homeWinProbability': homeWinProbability,
      'drawProbability': drawProbability,
      'awayWinProbability': awayWinProbability,
      'keyFactors': keyFactors,
      'analysis': analysis,
      'quickInsight': quickInsight,
      'provider': provider,
      'generatedAt': generatedAt.toIso8601String(),
      'ttlMinutes': ttlMinutes,
      'isUpsetAlert': isUpsetAlert,
      'upsetAlertText': upsetAlertText,
      'squadValueNarrative': squadValueNarrative,
      'managerMatchup': managerMatchup,
      'historicalPatterns': historicalPatterns,
      'confidenceDebate': confidenceDebate,
      'homeRecentForm': homeRecentForm,
      'awayRecentForm': awayRecentForm,
      'bettingOddsSummary': bettingOddsSummary,
    };
  }

  /// Create a copy with updated fields
  AIMatchPrediction copyWith({
    String? matchId,
    AIPredictedOutcome? predictedOutcome,
    int? predictedHomeScore,
    int? predictedAwayScore,
    int? confidence,
    int? homeWinProbability,
    int? drawProbability,
    int? awayWinProbability,
    List<String>? keyFactors,
    String? analysis,
    String? quickInsight,
    String? provider,
    DateTime? generatedAt,
    int? ttlMinutes,
    bool? isUpsetAlert,
    String? upsetAlertText,
    String? squadValueNarrative,
    String? managerMatchup,
    List<String>? historicalPatterns,
    String? confidenceDebate,
    String? homeRecentForm,
    String? awayRecentForm,
    String? bettingOddsSummary,
  }) {
    return AIMatchPrediction(
      matchId: matchId ?? this.matchId,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      predictedHomeScore: predictedHomeScore ?? this.predictedHomeScore,
      predictedAwayScore: predictedAwayScore ?? this.predictedAwayScore,
      confidence: confidence ?? this.confidence,
      homeWinProbability: homeWinProbability ?? this.homeWinProbability,
      drawProbability: drawProbability ?? this.drawProbability,
      awayWinProbability: awayWinProbability ?? this.awayWinProbability,
      keyFactors: keyFactors ?? this.keyFactors,
      analysis: analysis ?? this.analysis,
      quickInsight: quickInsight ?? this.quickInsight,
      provider: provider ?? this.provider,
      generatedAt: generatedAt ?? this.generatedAt,
      ttlMinutes: ttlMinutes ?? this.ttlMinutes,
      isUpsetAlert: isUpsetAlert ?? this.isUpsetAlert,
      upsetAlertText: upsetAlertText ?? this.upsetAlertText,
      squadValueNarrative: squadValueNarrative ?? this.squadValueNarrative,
      managerMatchup: managerMatchup ?? this.managerMatchup,
      historicalPatterns: historicalPatterns ?? this.historicalPatterns,
      confidenceDebate: confidenceDebate ?? this.confidenceDebate,
      homeRecentForm: homeRecentForm ?? this.homeRecentForm,
      awayRecentForm: awayRecentForm ?? this.awayRecentForm,
      bettingOddsSummary: bettingOddsSummary ?? this.bettingOddsSummary,
    );
  }

  /// Create a fallback prediction based on FIFA rankings
  factory AIMatchPrediction.fallback({
    required String matchId,
    required String homeTeamName,
    required String awayTeamName,
    int? homeRanking,
    int? awayRanking,
  }) {
    // Simple ranking-based prediction
    final homeRank = homeRanking ?? 50;
    final awayRank = awayRanking ?? 50;

    int homeProb, drawProb, awayProb;
    int homeScore, awayScore;

    if (homeRank < awayRank) {
      // Home team ranked higher (lower number = better)
      final diff = awayRank - homeRank;
      homeProb = (45 + (diff * 0.5)).clamp(30, 70).toInt();
      awayProb = (30 - (diff * 0.3)).clamp(15, 40).toInt();
      drawProb = 100 - homeProb - awayProb;
      homeScore = diff > 20 ? 2 : 1;
      awayScore = diff > 30 ? 0 : 1;
    } else if (awayRank < homeRank) {
      // Away team ranked higher
      final diff = homeRank - awayRank;
      awayProb = (40 + (diff * 0.4)).clamp(30, 60).toInt();
      homeProb = (35 - (diff * 0.3)).clamp(20, 40).toInt();
      drawProb = 100 - homeProb - awayProb;
      awayScore = diff > 20 ? 2 : 1;
      homeScore = diff > 30 ? 0 : 1;
    } else {
      // Equal rankings
      homeProb = 38;
      drawProb = 28;
      awayProb = 34;
      homeScore = 1;
      awayScore = 1;
    }

    AIPredictedOutcome outcome;
    if (homeScore > awayScore) {
      outcome = AIPredictedOutcome.homeWin;
    } else if (awayScore > homeScore) {
      outcome = AIPredictedOutcome.awayWin;
    } else {
      outcome = AIPredictedOutcome.draw;
    }

    return AIMatchPrediction(
      matchId: matchId,
      predictedOutcome: outcome,
      predictedHomeScore: homeScore,
      predictedAwayScore: awayScore,
      confidence: 40,
      homeWinProbability: homeProb,
      drawProbability: drawProb,
      awayWinProbability: awayProb,
      keyFactors: const [
        'FIFA World Rankings comparison',
        'Historical World Cup performance',
        'Tournament stage dynamics',
      ],
      analysis: 'Based on FIFA rankings and historical data.',
      quickInsight: 'Ranking-based prediction',
      provider: 'Fallback',
      generatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'AIMatchPrediction($matchId: $scoreDisplay, confidence: $confidence%)';
}
