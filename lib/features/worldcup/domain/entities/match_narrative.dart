import 'package:equatable/equatable.dart';

/// A beautifully written, expert-level pregame article for a World Cup match.
///
/// Generated offline by the AI Sports Journalism Engine and bundled as local
/// JSON in assets/data/worldcup/match_narratives/{TEAM1}_{TEAM2}.json.
/// Never generated at runtime — all content is pre-researched and pre-written.
class MatchNarrative extends Equatable {
  final String matchKey;
  final String team1Code;
  final String team2Code;
  final String team1Name;
  final String team2Name;
  final DateTime? generatedAt;
  final int dataVersion;

  /// Compelling, evocative headline (max ~80 chars)
  final String headline;

  /// One-sentence summary (max ~150 chars)
  final String subheadline;

  /// 2-3 paragraphs of rich pregame context — the heart of the article
  final String openingNarrative;

  /// Tactical analysis section
  final TacticalBreakdown tacticalBreakdown;

  /// Data-driven insights woven into narrative form
  final DataInsights dataInsights;

  /// 3-4 compelling player spotlights
  final List<PlayerSpotlight> playerSpotlights;

  /// The prediction with narrative reasoning
  final NarrativeVerdict verdict;

  /// One powerful closing sentence
  final String closingLine;

  const MatchNarrative({
    required this.matchKey,
    required this.team1Code,
    required this.team2Code,
    required this.team1Name,
    required this.team2Name,
    this.generatedAt,
    this.dataVersion = 1,
    required this.headline,
    required this.subheadline,
    required this.openingNarrative,
    required this.tacticalBreakdown,
    required this.dataInsights,
    required this.playerSpotlights,
    required this.verdict,
    required this.closingLine,
  });

  @override
  List<Object?> get props => [matchKey];

  factory MatchNarrative.fromJson(Map<String, dynamic> json) {
    return MatchNarrative(
      matchKey: json['matchKey'] as String,
      team1Code: json['team1Code'] as String,
      team2Code: json['team2Code'] as String,
      team1Name: json['team1Name'] as String,
      team2Name: json['team2Name'] as String,
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
      dataVersion: json['dataVersion'] as int? ?? 1,
      headline: json['headline'] as String,
      subheadline: json['subheadline'] as String,
      openingNarrative: json['openingNarrative'] as String,
      tacticalBreakdown: TacticalBreakdown.fromJson(
          json['tacticalBreakdown'] as Map<String, dynamic>),
      dataInsights:
          DataInsights.fromJson(json['dataInsights'] as Map<String, dynamic>),
      playerSpotlights: (json['playerSpotlights'] as List<dynamic>?)
              ?.map(
                  (p) => PlayerSpotlight.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      verdict: NarrativeVerdict.fromJson(
          json['theVerdict'] as Map<String, dynamic>),
      closingLine: json['closingLine'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchKey': matchKey,
      'team1Code': team1Code,
      'team2Code': team2Code,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'generatedAt': generatedAt?.toIso8601String(),
      'dataVersion': dataVersion,
      'headline': headline,
      'subheadline': subheadline,
      'openingNarrative': openingNarrative,
      'tacticalBreakdown': tacticalBreakdown.toJson(),
      'dataInsights': dataInsights.toJson(),
      'playerSpotlights': playerSpotlights.map((p) => p.toJson()).toList(),
      'theVerdict': verdict.toJson(),
      'closingLine': closingLine,
    };
  }
}

class TacticalBreakdown {
  final String title;
  final String narrative;
  final String team1Formation;
  final String team2Formation;
  final String keyMatchup;

  const TacticalBreakdown({
    required this.title,
    required this.narrative,
    required this.team1Formation,
    required this.team2Formation,
    required this.keyMatchup,
  });

  factory TacticalBreakdown.fromJson(Map<String, dynamic> json) {
    return TacticalBreakdown(
      title: json['title'] as String? ?? 'Tactical Breakdown',
      narrative: json['narrative'] as String,
      team1Formation: json['team1Formation'] as String? ?? '',
      team2Formation: json['team2Formation'] as String? ?? '',
      keyMatchup: json['keyMatchup'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'narrative': narrative,
        'team1Formation': team1Formation,
        'team2Formation': team2Formation,
        'keyMatchup': keyMatchup,
      };
}

class DataInsights {
  final String title;
  final String? eloAnalysis;
  final String? formAnalysis;
  final String? squadValueComparison;
  final String? injuryImpact;
  final String? bettingPerspective;
  final String? historicalPattern;

  const DataInsights({
    this.title = 'By The Numbers',
    this.eloAnalysis,
    this.formAnalysis,
    this.squadValueComparison,
    this.injuryImpact,
    this.bettingPerspective,
    this.historicalPattern,
  });

  /// All non-null insight entries for iteration in UI
  List<MapEntry<String, String>> get entries {
    final result = <MapEntry<String, String>>[];
    if (eloAnalysis != null) {
      result.add(MapEntry('Strength Rating', eloAnalysis!));
    }
    if (formAnalysis != null) {
      result.add(MapEntry('Current Form', formAnalysis!));
    }
    if (squadValueComparison != null) {
      result.add(MapEntry('Squad Investment', squadValueComparison!));
    }
    if (injuryImpact != null) {
      result.add(MapEntry('Availability', injuryImpact!));
    }
    if (bettingPerspective != null) {
      result.add(MapEntry('Market View', bettingPerspective!));
    }
    if (historicalPattern != null) {
      result.add(MapEntry('History', historicalPattern!));
    }
    return result;
  }

  factory DataInsights.fromJson(Map<String, dynamic> json) {
    return DataInsights(
      title: json['title'] as String? ?? 'By The Numbers',
      eloAnalysis: json['eloAnalysis'] as String?,
      formAnalysis: json['formAnalysis'] as String?,
      squadValueComparison: json['squadValueComparison'] as String?,
      injuryImpact: json['injuryImpact'] as String?,
      bettingPerspective: json['bettingPerspective'] as String?,
      historicalPattern: json['historicalPattern'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'eloAnalysis': eloAnalysis,
        'formAnalysis': formAnalysis,
        'squadValueComparison': squadValueComparison,
        'injuryImpact': injuryImpact,
        'bettingPerspective': bettingPerspective,
        'historicalPattern': historicalPattern,
      };
}

class PlayerSpotlight {
  final String name;
  final String teamCode;
  final String narrative;
  final String? statline;

  const PlayerSpotlight({
    required this.name,
    required this.teamCode,
    required this.narrative,
    this.statline,
  });

  factory PlayerSpotlight.fromJson(Map<String, dynamic> json) {
    return PlayerSpotlight(
      name: json['name'] as String,
      teamCode: json['teamCode'] as String,
      narrative: json['narrative'] as String,
      statline: json['statline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'teamCode': teamCode,
        'narrative': narrative,
        'statline': statline,
      };
}

class NarrativeVerdict {
  final String title;
  final String prediction;
  final int confidence;
  final String narrative;
  final List<AlternativeScenario> alternativeScenarios;

  const NarrativeVerdict({
    this.title = 'The Verdict',
    required this.prediction,
    required this.confidence,
    required this.narrative,
    this.alternativeScenarios = const [],
  });

  factory NarrativeVerdict.fromJson(Map<String, dynamic> json) {
    return NarrativeVerdict(
      title: json['title'] as String? ?? 'The Verdict',
      prediction: json['prediction'] as String,
      confidence: json['confidence'] as int,
      narrative: json['narrative'] as String,
      alternativeScenarios: (json['alternativeScenarios'] as List<dynamic>?)
              ?.map((s) =>
                  AlternativeScenario.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'prediction': prediction,
        'confidence': confidence,
        'narrative': narrative,
        'alternativeScenarios':
            alternativeScenarios.map((s) => s.toJson()).toList(),
      };
}

class AlternativeScenario {
  final String scenario;
  final int probability;
  final String reasoning;

  const AlternativeScenario({
    required this.scenario,
    required this.probability,
    required this.reasoning,
  });

  factory AlternativeScenario.fromJson(Map<String, dynamic> json) {
    return AlternativeScenario(
      scenario: json['scenario'] as String,
      probability: json['probability'] as int,
      reasoning: json['reasoning'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'scenario': scenario,
        'probability': probability,
        'reasoning': reasoning,
      };
}
