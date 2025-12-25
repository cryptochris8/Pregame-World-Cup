import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// GroupTeamStanding represents a team's standing within a group
class GroupTeamStanding extends Equatable {
  /// Team FIFA code
  final String teamCode;

  /// Team name
  final String teamName;

  /// Team flag URL
  final String? flagUrl;

  /// Position in group (1-4)
  final int position;

  /// Matches played
  final int played;

  /// Matches won
  final int won;

  /// Matches drawn
  final int drawn;

  /// Matches lost
  final int lost;

  /// Goals scored (for)
  final int goalsFor;

  /// Goals conceded (against)
  final int goalsAgainst;

  /// Goal difference
  int get goalDifference => goalsFor - goalsAgainst;

  /// Points (3 for win, 1 for draw)
  final int points;

  /// Recent form (last 3 matches: W, D, L)
  final List<String> form;

  /// Whether team has qualified from group
  final bool? hasQualified;

  /// Qualification status: 'winner', 'runner-up', 'third', 'eliminated', null (pending)
  final String? qualificationStatus;

  const GroupTeamStanding({
    required this.teamCode,
    required this.teamName,
    this.flagUrl,
    required this.position,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
    this.form = const [],
    this.hasQualified,
    this.qualificationStatus,
  });

  @override
  List<Object?> get props => [
    teamCode,
    position,
    played,
    won,
    drawn,
    lost,
    goalsFor,
    goalsAgainst,
    points,
  ];

  /// Factory to create from Map
  factory GroupTeamStanding.fromMap(Map<String, dynamic> map) {
    return GroupTeamStanding(
      teamCode: map['teamCode'] as String? ?? '',
      teamName: map['teamName'] as String? ?? '',
      flagUrl: map['flagUrl'] as String?,
      position: map['position'] as int? ?? 0,
      played: map['played'] as int? ?? 0,
      won: map['won'] as int? ?? 0,
      drawn: map['drawn'] as int? ?? 0,
      lost: map['lost'] as int? ?? 0,
      goalsFor: map['goalsFor'] as int? ?? 0,
      goalsAgainst: map['goalsAgainst'] as int? ?? 0,
      points: map['points'] as int? ?? 0,
      form: (map['form'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      hasQualified: map['hasQualified'] as bool?,
      qualificationStatus: map['qualificationStatus'] as String?,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'teamCode': teamCode,
      'teamName': teamName,
      'flagUrl': flagUrl,
      'position': position,
      'played': played,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'points': points,
      'form': form,
      'hasQualified': hasQualified,
      'qualificationStatus': qualificationStatus,
    };
  }

  /// Create a copy with updated fields
  GroupTeamStanding copyWith({
    String? teamCode,
    String? teamName,
    String? flagUrl,
    int? position,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? goalsFor,
    int? goalsAgainst,
    int? points,
    List<String>? form,
    bool? hasQualified,
    String? qualificationStatus,
  }) {
    return GroupTeamStanding(
      teamCode: teamCode ?? this.teamCode,
      teamName: teamName ?? this.teamName,
      flagUrl: flagUrl ?? this.flagUrl,
      position: position ?? this.position,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      points: points ?? this.points,
      form: form ?? this.form,
      hasQualified: hasQualified ?? this.hasQualified,
      qualificationStatus: qualificationStatus ?? this.qualificationStatus,
    );
  }

  @override
  String toString() =>
      '$position. $teamName - P:$played W:$won D:$drawn L:$lost GD:$goalDifference Pts:$points';
}

/// WorldCupGroup represents a group in the World Cup 2026
/// There are 12 groups (A-L) with 4 teams each
class WorldCupGroup extends Equatable {
  /// Group letter (A-L)
  final String groupLetter;

  /// List of team standings in order
  final List<GroupTeamStanding> standings;

  /// List of match IDs in this group
  final List<String> matchIds;

  /// Current match day (1, 2, or 3)
  final int currentMatchDay;

  /// Whether group stage is complete
  final bool isComplete;

  /// Group winner team code (after completion)
  final String? winnerTeamCode;

  /// Group runner-up team code (after completion)
  final String? runnerUpTeamCode;

  /// Best third-place team from this group (if qualified)
  final String? thirdPlaceTeamCode;

  /// Whether the third-place team qualified
  final bool? thirdPlaceQualified;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const WorldCupGroup({
    required this.groupLetter,
    this.standings = const [],
    this.matchIds = const [],
    this.currentMatchDay = 0,
    this.isComplete = false,
    this.winnerTeamCode,
    this.runnerUpTeamCode,
    this.thirdPlaceTeamCode,
    this.thirdPlaceQualified,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [groupLetter, standings, isComplete];

  /// Get team at specific position (1-4)
  GroupTeamStanding? getTeamAtPosition(int position) {
    try {
      return standings.firstWhere((s) => s.position == position);
    } catch (_) {
      return null;
    }
  }

  /// Get sorted standings (by position)
  List<GroupTeamStanding> get sortedStandings {
    final sorted = List<GroupTeamStanding>.from(standings);
    sorted.sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  }

  /// Get teams that qualify (top 2 + potentially 3rd)
  List<GroupTeamStanding> get qualifyingTeams {
    return standings.where((s) => s.hasQualified == true).toList();
  }

  /// Factory to create from Firestore document
  factory WorldCupGroup.fromFirestore(Map<String, dynamic> data, String docId) {
    return WorldCupGroup(
      groupLetter: docId,
      standings: (data['standings'] as List<dynamic>?)
          ?.map((e) => GroupTeamStanding.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      matchIds: (data['matchIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      currentMatchDay: data['currentMatchDay'] as int? ?? 0,
      isComplete: data['isComplete'] as bool? ?? false,
      winnerTeamCode: data['winnerTeamCode'] as String?,
      runnerUpTeamCode: data['runnerUpTeamCode'] as String?,
      thirdPlaceTeamCode: data['thirdPlaceTeamCode'] as String?,
      thirdPlaceQualified: data['thirdPlaceQualified'] as bool?,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'standings': standings.map((s) => s.toMap()).toList(),
      'matchIds': matchIds,
      'currentMatchDay': currentMatchDay,
      'isComplete': isComplete,
      'winnerTeamCode': winnerTeamCode,
      'runnerUpTeamCode': runnerUpTeamCode,
      'thirdPlaceTeamCode': thirdPlaceTeamCode,
      'thirdPlaceQualified': thirdPlaceQualified,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'groupLetter': groupLetter,
      'standings': standings.map((s) => s.toMap()).toList(),
      'matchIds': matchIds,
      'currentMatchDay': currentMatchDay,
      'isComplete': isComplete,
      'winnerTeamCode': winnerTeamCode,
      'runnerUpTeamCode': runnerUpTeamCode,
      'thirdPlaceTeamCode': thirdPlaceTeamCode,
      'thirdPlaceQualified': thirdPlaceQualified,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory to create from cached Map
  factory WorldCupGroup.fromMap(Map<String, dynamic> map) {
    return WorldCupGroup(
      groupLetter: map['groupLetter'] as String? ?? '',
      standings: (map['standings'] as List<dynamic>?)
          ?.map((e) => GroupTeamStanding.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      matchIds: (map['matchIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      currentMatchDay: map['currentMatchDay'] as int? ?? 0,
      isComplete: map['isComplete'] as bool? ?? false,
      winnerTeamCode: map['winnerTeamCode'] as String?,
      runnerUpTeamCode: map['runnerUpTeamCode'] as String?,
      thirdPlaceTeamCode: map['thirdPlaceTeamCode'] as String?,
      thirdPlaceQualified: map['thirdPlaceQualified'] as bool?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  WorldCupGroup copyWith({
    String? groupLetter,
    List<GroupTeamStanding>? standings,
    List<String>? matchIds,
    int? currentMatchDay,
    bool? isComplete,
    String? winnerTeamCode,
    String? runnerUpTeamCode,
    String? thirdPlaceTeamCode,
    bool? thirdPlaceQualified,
    DateTime? updatedAt,
  }) {
    return WorldCupGroup(
      groupLetter: groupLetter ?? this.groupLetter,
      standings: standings ?? this.standings,
      matchIds: matchIds ?? this.matchIds,
      currentMatchDay: currentMatchDay ?? this.currentMatchDay,
      isComplete: isComplete ?? this.isComplete,
      winnerTeamCode: winnerTeamCode ?? this.winnerTeamCode,
      runnerUpTeamCode: runnerUpTeamCode ?? this.runnerUpTeamCode,
      thirdPlaceTeamCode: thirdPlaceTeamCode ?? this.thirdPlaceTeamCode,
      thirdPlaceQualified: thirdPlaceQualified ?? this.thirdPlaceQualified,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate tiebreakers between teams with equal points
  /// FIFA tiebreaker rules:
  /// 1. Goal difference
  /// 2. Goals scored
  /// 3. Points in head-to-head matches
  /// 4. Goal difference in head-to-head matches
  /// 5. Goals scored in head-to-head matches
  /// 6. Fair play points
  /// 7. Drawing of lots by FIFA
  static List<GroupTeamStanding> applyTiebreakers(
      List<GroupTeamStanding> standings) {
    // Group teams by points
    final byPoints = <int, List<GroupTeamStanding>>{};
    for (final team in standings) {
      byPoints.putIfAbsent(team.points, () => []).add(team);
    }

    // Sort each group by tiebreaker rules
    final result = <GroupTeamStanding>[];
    final sortedPoints = byPoints.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final pts in sortedPoints) {
      final teamsWithSamePoints = byPoints[pts]!;
      if (teamsWithSamePoints.length == 1) {
        result.add(teamsWithSamePoints.first);
      } else {
        // Apply tiebreakers
        teamsWithSamePoints.sort((a, b) {
          // 1. Goal difference
          final gdDiff = b.goalDifference.compareTo(a.goalDifference);
          if (gdDiff != 0) return gdDiff;

          // 2. Goals scored
          final gfDiff = b.goalsFor.compareTo(a.goalsFor);
          if (gfDiff != 0) return gfDiff;

          // For head-to-head, would need match data - simplified here
          return 0;
        });
        result.addAll(teamsWithSamePoints);
      }
    }

    // Assign positions
    return result.asMap().entries.map((entry) {
      return entry.value.copyWith(position: entry.key + 1);
    }).toList();
  }

  @override
  String toString() => 'Group $groupLetter';
}

/// Helper class for group-related utilities
class GroupUtils {
  /// All group letters for World Cup 2026 (12 groups)
  static const List<String> allGroupLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
  ];

  /// Number of teams per group
  static const int teamsPerGroup = 4;

  /// Number of matches per group (each team plays 3 matches)
  static const int matchesPerGroup = 6;

  /// Total number of groups
  static const int totalGroups = 12;

  /// Total group stage matches (12 groups * 6 matches)
  static const int totalGroupMatches = 72;

  /// Check if a group letter is valid
  static bool isValidGroupLetter(String letter) {
    return allGroupLetters.contains(letter.toUpperCase());
  }

  /// Get group index from letter (A=0, B=1, etc.)
  static int getGroupIndex(String letter) {
    return allGroupLetters.indexOf(letter.toUpperCase());
  }

  /// Get group letter from index (0=A, 1=B, etc.)
  static String getGroupLetter(int index) {
    if (index < 0 || index >= allGroupLetters.length) {
      throw ArgumentError('Invalid group index: $index');
    }
    return allGroupLetters[index];
  }
}
