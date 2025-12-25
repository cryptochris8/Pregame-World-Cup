import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'world_cup_match.dart';

/// BracketSlot represents a single position in the knockout bracket
class BracketSlot extends Equatable {
  /// Unique slot ID (e.g., "R32-1", "R16-4", "QF-2", "SF-1", "F")
  final String slotId;

  /// Stage of this slot
  final MatchStage stage;

  /// Match number within the stage
  final int matchNumberInStage;

  /// Team FIFA code (null if TBD)
  final String? teamCode;

  /// Team name or placeholder (e.g., "Winner Group A")
  final String teamNameOrPlaceholder;

  /// Team flag URL
  final String? flagUrl;

  /// Source of this team (e.g., "1A" for winner of Group A, "R32-1" for winner of R32 match 1)
  final String? source;

  /// Match ID for the match that decides this slot
  final String? matchId;

  /// Whether this slot is confirmed (team determined)
  final bool isConfirmed;

  /// Whether this team won and advances
  final bool? hasAdvanced;

  /// Score in this match
  final int? score;

  /// Penalty score (if applicable)
  final int? penaltyScore;

  // Convenience getters
  /// Placeholder alias for teamNameOrPlaceholder
  String get placeholder => teamNameOrPlaceholder;

  /// Team name (alias for teamNameOrPlaceholder when confirmed)
  String get teamName => teamNameOrPlaceholder;

  const BracketSlot({
    required this.slotId,
    required this.stage,
    required this.matchNumberInStage,
    this.teamCode,
    required this.teamNameOrPlaceholder,
    this.flagUrl,
    this.source,
    this.matchId,
    this.isConfirmed = false,
    this.hasAdvanced,
    this.score,
    this.penaltyScore,
  });

  @override
  List<Object?> get props => [slotId, teamCode, isConfirmed, hasAdvanced];

  /// Factory to create from Map
  factory BracketSlot.fromMap(Map<String, dynamic> map) {
    return BracketSlot(
      slotId: map['slotId'] as String? ?? '',
      stage: _parseMatchStage(map['stage'] as String?),
      matchNumberInStage: map['matchNumberInStage'] as int? ?? 0,
      teamCode: map['teamCode'] as String?,
      teamNameOrPlaceholder: map['teamNameOrPlaceholder'] as String? ?? 'TBD',
      flagUrl: map['flagUrl'] as String?,
      source: map['source'] as String?,
      matchId: map['matchId'] as String?,
      isConfirmed: map['isConfirmed'] as bool? ?? false,
      hasAdvanced: map['hasAdvanced'] as bool?,
      score: map['score'] as int?,
      penaltyScore: map['penaltyScore'] as int?,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'slotId': slotId,
      'stage': stage.name,
      'matchNumberInStage': matchNumberInStage,
      'teamCode': teamCode,
      'teamNameOrPlaceholder': teamNameOrPlaceholder,
      'flagUrl': flagUrl,
      'source': source,
      'matchId': matchId,
      'isConfirmed': isConfirmed,
      'hasAdvanced': hasAdvanced,
      'score': score,
      'penaltyScore': penaltyScore,
    };
  }

  /// Create a copy with updated fields
  BracketSlot copyWith({
    String? slotId,
    MatchStage? stage,
    int? matchNumberInStage,
    String? teamCode,
    String? teamNameOrPlaceholder,
    String? flagUrl,
    String? source,
    String? matchId,
    bool? isConfirmed,
    bool? hasAdvanced,
    int? score,
    int? penaltyScore,
  }) {
    return BracketSlot(
      slotId: slotId ?? this.slotId,
      stage: stage ?? this.stage,
      matchNumberInStage: matchNumberInStage ?? this.matchNumberInStage,
      teamCode: teamCode ?? this.teamCode,
      teamNameOrPlaceholder: teamNameOrPlaceholder ?? this.teamNameOrPlaceholder,
      flagUrl: flagUrl ?? this.flagUrl,
      source: source ?? this.source,
      matchId: matchId ?? this.matchId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      hasAdvanced: hasAdvanced ?? this.hasAdvanced,
      score: score ?? this.score,
      penaltyScore: penaltyScore ?? this.penaltyScore,
    );
  }

  static MatchStage _parseMatchStage(String? value) {
    if (value == null) return MatchStage.roundOf32;
    switch (value.toLowerCase()) {
      case 'roundof32':
        return MatchStage.roundOf32;
      case 'roundof16':
        return MatchStage.roundOf16;
      case 'quarterfinal':
        return MatchStage.quarterFinal;
      case 'semifinal':
        return MatchStage.semiFinal;
      case 'thirdplace':
        return MatchStage.thirdPlace;
      case 'final_':
        return MatchStage.final_;
      default:
        return MatchStage.roundOf32;
    }
  }
}

/// BracketMatch represents a single match in the knockout bracket
class BracketMatch extends Equatable {
  /// Match ID
  final String matchId;

  /// Match number in tournament
  final int matchNumber;

  /// Stage of this match
  final MatchStage stage;

  /// Match number within stage (1-16 for R32, 1-8 for R16, etc.)
  final int matchNumberInStage;

  /// Home team slot
  final BracketSlot homeSlot;

  /// Away team slot
  final BracketSlot awaySlot;

  /// Winner advances to this slot ID
  final String? advancesToSlotId;

  /// Match status
  final MatchStatus status;

  /// Venue ID
  final String? venueId;

  /// Match date/time
  final DateTime? dateTime;

  /// Winner team code
  final String? winnerCode;

  const BracketMatch({
    required this.matchId,
    required this.matchNumber,
    required this.stage,
    required this.matchNumberInStage,
    required this.homeSlot,
    required this.awaySlot,
    this.advancesToSlotId,
    this.status = MatchStatus.scheduled,
    this.venueId,
    this.dateTime,
    this.winnerCode,
  });

  @override
  List<Object?> get props => [matchId, stage, homeSlot, awaySlot, status];

  /// Whether both teams are determined
  bool get teamsConfirmed => homeSlot.isConfirmed && awaySlot.isConfirmed;

  /// Whether match is complete
  bool get isComplete => status == MatchStatus.completed;

  /// Alias for isComplete (for widget compatibility)
  bool get isCompleted => isComplete;

  /// Whether match is currently live
  bool get isLive =>
      status == MatchStatus.inProgress ||
      status == MatchStatus.halfTime ||
      status == MatchStatus.extraTime ||
      status == MatchStatus.penalties;

  // Convenience aliases for widgets
  /// Team 1 slot (alias for homeSlot)
  BracketSlot get team1 => homeSlot;

  /// Team 2 slot (alias for awaySlot)
  BracketSlot get team2 => awaySlot;

  /// Team 1 penalty score (from homeSlot)
  int? get team1PenaltyScore => homeSlot.penaltyScore;

  /// Team 2 penalty score (from awaySlot)
  int? get team2PenaltyScore => awaySlot.penaltyScore;

  /// Factory to create from Map
  factory BracketMatch.fromMap(Map<String, dynamic> map) {
    return BracketMatch(
      matchId: map['matchId'] as String? ?? '',
      matchNumber: map['matchNumber'] as int? ?? 0,
      stage: _parseMatchStage(map['stage'] as String?),
      matchNumberInStage: map['matchNumberInStage'] as int? ?? 0,
      homeSlot: BracketSlot.fromMap(map['homeSlot'] as Map<String, dynamic>? ?? {}),
      awaySlot: BracketSlot.fromMap(map['awaySlot'] as Map<String, dynamic>? ?? {}),
      advancesToSlotId: map['advancesToSlotId'] as String?,
      status: _parseMatchStatus(map['status'] as String?),
      venueId: map['venueId'] as String?,
      dateTime: map['dateTime'] != null
          ? DateTime.tryParse(map['dateTime'] as String)
          : null,
      winnerCode: map['winnerCode'] as String?,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'matchNumber': matchNumber,
      'stage': stage.name,
      'matchNumberInStage': matchNumberInStage,
      'homeSlot': homeSlot.toMap(),
      'awaySlot': awaySlot.toMap(),
      'advancesToSlotId': advancesToSlotId,
      'status': status.name,
      'venueId': venueId,
      'dateTime': dateTime?.toIso8601String(),
      'winnerCode': winnerCode,
    };
  }

  static MatchStage _parseMatchStage(String? value) {
    if (value == null) return MatchStage.roundOf32;
    switch (value.toLowerCase()) {
      case 'roundof32':
        return MatchStage.roundOf32;
      case 'roundof16':
        return MatchStage.roundOf16;
      case 'quarterfinal':
        return MatchStage.quarterFinal;
      case 'semifinal':
        return MatchStage.semiFinal;
      case 'thirdplace':
        return MatchStage.thirdPlace;
      case 'final_':
        return MatchStage.final_;
      default:
        return MatchStage.roundOf32;
    }
  }

  static MatchStatus _parseMatchStatus(String? value) {
    if (value == null) return MatchStatus.scheduled;
    switch (value.toLowerCase()) {
      case 'inprogress':
        return MatchStatus.inProgress;
      case 'halftime':
        return MatchStatus.halfTime;
      case 'extratime':
        return MatchStatus.extraTime;
      case 'penalties':
        return MatchStatus.penalties;
      case 'completed':
        return MatchStatus.completed;
      default:
        return MatchStatus.scheduled;
    }
  }
}

/// WorldCupBracket represents the complete knockout stage bracket
class WorldCupBracket extends Equatable {
  /// Round of 32 matches (16 matches)
  final List<BracketMatch> roundOf32;

  /// Round of 16 matches (8 matches)
  final List<BracketMatch> roundOf16;

  /// Quarter-final matches (4 matches)
  final List<BracketMatch> quarterFinals;

  /// Semi-final matches (2 matches)
  final List<BracketMatch> semiFinals;

  /// Third place match
  final BracketMatch? thirdPlace;

  /// Final match
  final BracketMatch? finalMatch;

  /// Tournament champion team code
  final String? championCode;

  /// Tournament champion team name
  final String? championName;

  /// Runner-up team code
  final String? runnerUpCode;

  /// Third place team code
  final String? thirdPlaceCode;

  /// Fourth place team code
  final String? fourthPlaceCode;

  /// Whether bracket is complete
  final bool isComplete;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const WorldCupBracket({
    this.roundOf32 = const [],
    this.roundOf16 = const [],
    this.quarterFinals = const [],
    this.semiFinals = const [],
    this.thirdPlace,
    this.finalMatch,
    this.championCode,
    this.championName,
    this.runnerUpCode,
    this.thirdPlaceCode,
    this.fourthPlaceCode,
    this.isComplete = false,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    roundOf32,
    roundOf16,
    quarterFinals,
    semiFinals,
    thirdPlace,
    finalMatch,
    isComplete,
  ];

  /// Get all knockout matches in order
  List<BracketMatch> get allMatches {
    return [
      ...roundOf32,
      ...roundOf16,
      ...quarterFinals,
      ...semiFinals,
      if (thirdPlace != null) thirdPlace!,
      if (finalMatch != null) finalMatch!,
    ];
  }

  /// Get matches by stage
  List<BracketMatch> getMatchesByStage(MatchStage stage) {
    switch (stage) {
      case MatchStage.roundOf32:
        return roundOf32;
      case MatchStage.roundOf16:
        return roundOf16;
      case MatchStage.quarterFinal:
        return quarterFinals;
      case MatchStage.semiFinal:
        return semiFinals;
      case MatchStage.thirdPlace:
        return thirdPlace != null ? [thirdPlace!] : [];
      case MatchStage.final_:
        return finalMatch != null ? [finalMatch!] : [];
      default:
        return [];
    }
  }

  /// Get match by ID
  BracketMatch? getMatchById(String matchId) {
    try {
      return allMatches.firstWhere((m) => m.matchId == matchId);
    } catch (_) {
      return null;
    }
  }

  /// Get next upcoming match
  BracketMatch? get nextMatch {
    final scheduled = allMatches
        .where((m) => m.status == MatchStatus.scheduled && m.dateTime != null)
        .toList();
    if (scheduled.isEmpty) return null;
    scheduled.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return scheduled.first;
  }

  /// Get live matches
  List<BracketMatch> get liveMatches {
    return allMatches.where((m) =>
      m.status == MatchStatus.inProgress ||
      m.status == MatchStatus.halfTime ||
      m.status == MatchStatus.extraTime ||
      m.status == MatchStatus.penalties
    ).toList();
  }

  /// Factory to create from Firestore document
  factory WorldCupBracket.fromFirestore(Map<String, dynamic> data) {
    return WorldCupBracket(
      roundOf32: (data['roundOf32'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      roundOf16: (data['roundOf16'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      quarterFinals: (data['quarterFinals'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      semiFinals: (data['semiFinals'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      thirdPlace: data['thirdPlace'] != null
          ? BracketMatch.fromMap(data['thirdPlace'] as Map<String, dynamic>)
          : null,
      finalMatch: data['finalMatch'] != null
          ? BracketMatch.fromMap(data['finalMatch'] as Map<String, dynamic>)
          : null,
      championCode: data['championCode'] as String?,
      championName: data['championName'] as String?,
      runnerUpCode: data['runnerUpCode'] as String?,
      thirdPlaceCode: data['thirdPlaceCode'] as String?,
      fourthPlaceCode: data['fourthPlaceCode'] as String?,
      isComplete: data['isComplete'] as bool? ?? false,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'roundOf32': roundOf32.map((m) => m.toMap()).toList(),
      'roundOf16': roundOf16.map((m) => m.toMap()).toList(),
      'quarterFinals': quarterFinals.map((m) => m.toMap()).toList(),
      'semiFinals': semiFinals.map((m) => m.toMap()).toList(),
      'thirdPlace': thirdPlace?.toMap(),
      'finalMatch': finalMatch?.toMap(),
      'championCode': championCode,
      'championName': championName,
      'runnerUpCode': runnerUpCode,
      'thirdPlaceCode': thirdPlaceCode,
      'fourthPlaceCode': fourthPlaceCode,
      'isComplete': isComplete,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'roundOf32': roundOf32.map((m) => m.toMap()).toList(),
      'roundOf16': roundOf16.map((m) => m.toMap()).toList(),
      'quarterFinals': quarterFinals.map((m) => m.toMap()).toList(),
      'semiFinals': semiFinals.map((m) => m.toMap()).toList(),
      'thirdPlace': thirdPlace?.toMap(),
      'finalMatch': finalMatch?.toMap(),
      'championCode': championCode,
      'championName': championName,
      'runnerUpCode': runnerUpCode,
      'thirdPlaceCode': thirdPlaceCode,
      'fourthPlaceCode': fourthPlaceCode,
      'isComplete': isComplete,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory to create from cached Map
  factory WorldCupBracket.fromMap(Map<String, dynamic> map) {
    return WorldCupBracket(
      roundOf32: (map['roundOf32'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      roundOf16: (map['roundOf16'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      quarterFinals: (map['quarterFinals'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      semiFinals: (map['semiFinals'] as List<dynamic>?)
          ?.map((e) => BracketMatch.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      thirdPlace: map['thirdPlace'] != null
          ? BracketMatch.fromMap(map['thirdPlace'] as Map<String, dynamic>)
          : null,
      finalMatch: map['finalMatch'] != null
          ? BracketMatch.fromMap(map['finalMatch'] as Map<String, dynamic>)
          : null,
      championCode: map['championCode'] as String?,
      championName: map['championName'] as String?,
      runnerUpCode: map['runnerUpCode'] as String?,
      thirdPlaceCode: map['thirdPlaceCode'] as String?,
      fourthPlaceCode: map['fourthPlaceCode'] as String?,
      isComplete: map['isComplete'] as bool? ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  WorldCupBracket copyWith({
    List<BracketMatch>? roundOf32,
    List<BracketMatch>? roundOf16,
    List<BracketMatch>? quarterFinals,
    List<BracketMatch>? semiFinals,
    BracketMatch? thirdPlace,
    BracketMatch? finalMatch,
    String? championCode,
    String? championName,
    String? runnerUpCode,
    String? thirdPlaceCode,
    String? fourthPlaceCode,
    bool? isComplete,
    DateTime? updatedAt,
  }) {
    return WorldCupBracket(
      roundOf32: roundOf32 ?? this.roundOf32,
      roundOf16: roundOf16 ?? this.roundOf16,
      quarterFinals: quarterFinals ?? this.quarterFinals,
      semiFinals: semiFinals ?? this.semiFinals,
      thirdPlace: thirdPlace ?? this.thirdPlace,
      finalMatch: finalMatch ?? this.finalMatch,
      championCode: championCode ?? this.championCode,
      championName: championName ?? this.championName,
      runnerUpCode: runnerUpCode ?? this.runnerUpCode,
      thirdPlaceCode: thirdPlaceCode ?? this.thirdPlaceCode,
      fourthPlaceCode: fourthPlaceCode ?? this.fourthPlaceCode,
      isComplete: isComplete ?? this.isComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'WorldCupBracket(R32: ${roundOf32.length}, R16: ${roundOf16.length}, QF: ${quarterFinals.length}, SF: ${semiFinals.length})';
}

/// Constants for World Cup 2026 knockout structure
class BracketConstants {
  /// Number of Round of 32 matches
  static const int roundOf32Matches = 16;

  /// Number of Round of 16 matches
  static const int roundOf16Matches = 8;

  /// Number of Quarter-final matches
  static const int quarterFinalMatches = 4;

  /// Number of Semi-final matches
  static const int semiFinalMatches = 2;

  /// Total knockout matches (16 + 8 + 4 + 2 + 1 + 1 = 32)
  static const int totalKnockoutMatches = 32;

  /// Match number ranges by stage
  static const Map<MatchStage, List<int>> matchNumberRanges = {
    MatchStage.roundOf32: [73, 88],  // Matches 73-88
    MatchStage.roundOf16: [89, 96],  // Matches 89-96
    MatchStage.quarterFinal: [97, 100],  // Matches 97-100
    MatchStage.semiFinal: [101, 102],  // Matches 101-102
    MatchStage.thirdPlace: [103, 103],  // Match 103
    MatchStage.final_: [104, 104],  // Match 104
  };
}
