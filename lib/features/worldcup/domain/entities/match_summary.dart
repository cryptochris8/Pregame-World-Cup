import 'package:equatable/equatable.dart';

/// AI-generated match summary for a World Cup 2026 matchup
class MatchSummary extends Equatable {
  /// Unique ID (team1Code_team2Code, alphabetically sorted)
  final String id;

  /// First team FIFA code
  final String team1Code;

  /// Second team FIFA code
  final String team2Code;

  /// First team name
  final String team1Name;

  /// Second team name
  final String team2Name;

  /// Historical analysis paragraph (based on H2H data)
  final String historicalAnalysis;

  /// Key storylines and narratives for this matchup
  final List<String> keyStorylines;

  /// Players to watch from each team
  final List<PlayerToWatch> playersToWatch;

  /// Tactical analysis
  final String tacticalPreview;

  /// AI prediction with confidence
  final MatchPredictionSummary prediction;

  /// Notable past encounters summary
  final String? pastEncountersSummary;

  /// Fun facts about this matchup
  final List<String> funFacts;

  /// Whether this is a first-ever meeting
  final bool isFirstMeeting;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const MatchSummary({
    required this.id,
    required this.team1Code,
    required this.team2Code,
    required this.team1Name,
    required this.team2Name,
    required this.historicalAnalysis,
    required this.keyStorylines,
    required this.playersToWatch,
    required this.tacticalPreview,
    required this.prediction,
    this.pastEncountersSummary,
    required this.funFacts,
    this.isFirstMeeting = false,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, team1Code, team2Code];

  factory MatchSummary.fromFirestore(Map<String, dynamic> data, String docId) {
    return MatchSummary(
      id: docId,
      team1Code: data['team1Code'] as String,
      team2Code: data['team2Code'] as String,
      team1Name: data['team1Name'] as String,
      team2Name: data['team2Name'] as String,
      historicalAnalysis: data['historicalAnalysis'] as String,
      keyStorylines: List<String>.from(data['keyStorylines'] ?? []),
      playersToWatch: (data['playersToWatch'] as List<dynamic>?)
              ?.map((p) => PlayerToWatch.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      tacticalPreview: data['tacticalPreview'] as String,
      prediction: MatchPredictionSummary.fromMap(
          data['prediction'] as Map<String, dynamic>),
      pastEncountersSummary: data['pastEncountersSummary'] as String?,
      funFacts: List<String>.from(data['funFacts'] ?? []),
      isFirstMeeting: data['isFirstMeeting'] as bool? ?? false,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'team1Code': team1Code,
      'team2Code': team2Code,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'historicalAnalysis': historicalAnalysis,
      'keyStorylines': keyStorylines,
      'playersToWatch': playersToWatch.map((p) => p.toMap()).toList(),
      'tacticalPreview': tacticalPreview,
      'prediction': prediction.toMap(),
      'pastEncountersSummary': pastEncountersSummary,
      'funFacts': funFacts,
      'isFirstMeeting': isFirstMeeting,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Player to watch in a matchup
class PlayerToWatch {
  final String name;
  final String teamCode;
  final String position;
  final String reason;

  const PlayerToWatch({
    required this.name,
    required this.teamCode,
    required this.position,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teamCode': teamCode,
      'position': position,
      'reason': reason,
    };
  }

  factory PlayerToWatch.fromMap(Map<String, dynamic> map) {
    return PlayerToWatch(
      name: map['name'] as String,
      teamCode: map['teamCode'] as String,
      position: map['position'] as String,
      reason: map['reason'] as String,
    );
  }
}

/// AI prediction summary for a match
class MatchPredictionSummary {
  /// Predicted winner code (or 'DRAW')
  final String predictedOutcome;

  /// Predicted score
  final String predictedScore;

  /// Confidence level (0-100)
  final int confidence;

  /// Reasoning for the prediction
  final String reasoning;

  /// Alternative scenario
  final String? alternativeScenario;

  const MatchPredictionSummary({
    required this.predictedOutcome,
    required this.predictedScore,
    required this.confidence,
    required this.reasoning,
    this.alternativeScenario,
  });

  Map<String, dynamic> toMap() {
    return {
      'predictedOutcome': predictedOutcome,
      'predictedScore': predictedScore,
      'confidence': confidence,
      'reasoning': reasoning,
      'alternativeScenario': alternativeScenario,
    };
  }

  factory MatchPredictionSummary.fromMap(Map<String, dynamic> map) {
    return MatchPredictionSummary(
      predictedOutcome: map['predictedOutcome'] as String,
      predictedScore: map['predictedScore'] as String,
      confidence: map['confidence'] as int,
      reasoning: map['reasoning'] as String,
      alternativeScenario: map['alternativeScenario'] as String?,
    );
  }

  /// Get confidence level text
  String get confidenceText {
    if (confidence >= 80) return 'High Confidence';
    if (confidence >= 60) return 'Moderate Confidence';
    if (confidence >= 40) return 'Low Confidence';
    return 'Uncertain';
  }
}
