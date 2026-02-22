import 'package:cloud_firestore/cloud_firestore.dart';

/// Player model representing a World Cup 2026 player
/// Corresponds to the player data in Firestore
class Player {
  final String playerId;
  final String fifaCode;
  final String firstName;
  final String lastName;
  final String fullName;
  final String commonName;
  final int jerseyNumber;
  final String position;
  final DateTime dateOfBirth;
  final int age;
  final int height; // in cm
  final int weight; // in kg
  final String preferredFoot;
  final String club;
  final String clubLeague;
  final String photoUrl;
  final int marketValue; // in USD
  final int caps;
  final int goals;
  final int assists;
  final int worldCupAppearances;
  final int worldCupGoals;
  final int worldCupAssists;
  final List<int> previousWorldCups;
  final List<WorldCupTournamentStats> worldCupTournamentStats;
  final List<String> worldCupAwards;
  final List<String> memorableMoments;
  final int worldCupLegacyRating;
  final PlayerStats stats;
  final List<String> honors;
  final List<String> strengths;
  final List<String> weaknesses;
  final String playStyle;
  final String keyMoment;
  final String comparisonToLegend;
  final String worldCup2026Prediction;
  final SocialMedia socialMedia;
  final List<String> trivia;

  Player({
    required this.playerId,
    required this.fifaCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.commonName,
    required this.jerseyNumber,
    required this.position,
    required this.dateOfBirth,
    required this.age,
    required this.height,
    required this.weight,
    required this.preferredFoot,
    required this.club,
    required this.clubLeague,
    required this.photoUrl,
    required this.marketValue,
    required this.caps,
    required this.goals,
    required this.assists,
    required this.worldCupAppearances,
    required this.worldCupGoals,
    this.worldCupAssists = 0,
    required this.previousWorldCups,
    this.worldCupTournamentStats = const [],
    this.worldCupAwards = const [],
    this.memorableMoments = const [],
    this.worldCupLegacyRating = 0,
    required this.stats,
    required this.honors,
    required this.strengths,
    required this.weaknesses,
    required this.playStyle,
    required this.keyMoment,
    required this.comparisonToLegend,
    required this.worldCup2026Prediction,
    required this.socialMedia,
    required this.trivia,
  });

  /// Create Player from Firestore document
  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Player(
      playerId: data['playerId'] ?? '',
      fifaCode: data['fifaCode'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      fullName: data['fullName'] ?? '',
      commonName: data['commonName'] ?? '',
      jerseyNumber: data['jerseyNumber'] ?? 0,
      position: data['position'] ?? '',
      dateOfBirth: DateTime.parse(data['dateOfBirth'] ?? '2000-01-01'),
      age: data['age'] ?? 0,
      height: data['height'] ?? 0,
      weight: data['weight'] ?? 0,
      preferredFoot: data['preferredFoot'] ?? 'Right',
      club: data['club'] ?? '',
      clubLeague: data['clubLeague'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      marketValue: data['marketValue'] ?? 0,
      caps: data['caps'] ?? 0,
      goals: data['goals'] ?? 0,
      assists: data['assists'] ?? 0,
      worldCupAppearances: data['worldCupAppearances'] ?? 0,
      worldCupGoals: data['worldCupGoals'] ?? 0,
      worldCupAssists: data['worldCupAssists'] ?? 0,
      previousWorldCups: List<int>.from(data['previousWorldCups'] ?? []),
      worldCupTournamentStats: (data['worldCupTournamentStats'] as List<dynamic>?)
          ?.map((s) => WorldCupTournamentStats.fromMap(s as Map<String, dynamic>))
          .toList() ?? const [],
      worldCupAwards: List<String>.from(data['worldCupAwards'] ?? []),
      memorableMoments: List<String>.from(data['memorableMoments'] ?? []),
      worldCupLegacyRating: data['worldCupLegacyRating'] ?? 0,
      stats: PlayerStats.fromMap(data['stats'] ?? {}),
      honors: List<String>.from(data['honors'] ?? []),
      strengths: List<String>.from(data['strengths'] ?? []),
      weaknesses: List<String>.from(data['weaknesses'] ?? []),
      playStyle: data['playStyle'] ?? '',
      keyMoment: data['keyMoment'] ?? '',
      comparisonToLegend: data['comparisonToLegend'] ?? '',
      worldCup2026Prediction: data['worldCup2026Prediction'] ?? '',
      socialMedia: SocialMedia.fromMap(data['socialMedia'] ?? {}),
      trivia: List<String>.from(data['trivia'] ?? []),
    );
  }

  /// Convert Player to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'fifaCode': fifaCode,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'commonName': commonName,
      'jerseyNumber': jerseyNumber,
      'position': position,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'height': height,
      'weight': weight,
      'preferredFoot': preferredFoot,
      'club': club,
      'clubLeague': clubLeague,
      'photoUrl': photoUrl,
      'marketValue': marketValue,
      'caps': caps,
      'goals': goals,
      'assists': assists,
      'worldCupAppearances': worldCupAppearances,
      'worldCupGoals': worldCupGoals,
      'worldCupAssists': worldCupAssists,
      'previousWorldCups': previousWorldCups,
      'worldCupTournamentStats': worldCupTournamentStats.map((s) => s.toMap()).toList(),
      'worldCupAwards': worldCupAwards,
      'memorableMoments': memorableMoments,
      'worldCupLegacyRating': worldCupLegacyRating,
      'stats': stats.toMap(),
      'honors': honors,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'playStyle': playStyle,
      'keyMoment': keyMoment,
      'comparisonToLegend': comparisonToLegend,
      'worldCup2026Prediction': worldCup2026Prediction,
      'socialMedia': socialMedia.toMap(),
      'trivia': trivia,
    };
  }

  /// Get formatted market value (e.g., "\$80M")
  String get formattedMarketValue {
    if (marketValue >= 1000000) {
      return '\$${(marketValue / 1000000).toStringAsFixed(0)}M';
    } else if (marketValue >= 1000) {
      return '\$${(marketValue / 1000).toStringAsFixed(0)}K';
    }
    return '\$$marketValue';
  }

  /// Get position display name
  String get positionDisplayName {
    const positionMap = {
      'GK': 'Goalkeeper',
      'CB': 'Center Back',
      'LB': 'Left Back',
      'RB': 'Right Back',
      'LWB': 'Left Wing Back',
      'RWB': 'Right Wing Back',
      'CDM': 'Defensive Midfielder',
      'CM': 'Central Midfielder',
      'CAM': 'Attacking Midfielder',
      'LM': 'Left Midfielder',
      'RM': 'Right Midfielder',
      'LW': 'Left Winger',
      'RW': 'Right Winger',
      'ST': 'Striker',
      'CF': 'Center Forward',
    };
    return positionMap[position] ?? position;
  }

  /// Get player category (Defender, Midfielder, Forward, Goalkeeper)
  String get category {
    if (position == 'GK') return 'Goalkeeper';
    if (['CB', 'LB', 'RB', 'LWB', 'RWB'].contains(position)) return 'Defender';
    if (['CDM', 'CM', 'CAM', 'LM', 'RM'].contains(position)) return 'Midfielder';
    if (['LW', 'RW', 'ST', 'CF'].contains(position)) return 'Forward';
    return 'Player';
  }

  /// Calculate goals per game ratio
  double get goalsPerGame {
    if (caps == 0) return 0.0;
    return goals / caps;
  }

  /// Calculate assists per game ratio
  double get assistsPerGame {
    if (caps == 0) return 0.0;
    return assists / caps;
  }
}

/// Player statistics (club and international)
class PlayerStats {
  final ClubStats club;
  final InternationalStats international;

  PlayerStats({
    required this.club,
    required this.international,
  });

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      club: ClubStats.fromMap(map['club'] ?? {}),
      international: InternationalStats.fromMap(map['international'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'club': club.toMap(),
      'international': international.toMap(),
    };
  }
}

/// Club statistics for current season
class ClubStats {
  final String season;
  final int appearances;
  final int goals;
  final int assists;
  final int minutesPlayed;

  ClubStats({
    required this.season,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.minutesPlayed,
  });

  factory ClubStats.fromMap(Map<String, dynamic> map) {
    return ClubStats(
      season: map['season'] ?? '',
      appearances: map['appearances'] ?? 0,
      goals: map['goals'] ?? 0,
      assists: map['assists'] ?? 0,
      minutesPlayed: map['minutesPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'season': season,
      'appearances': appearances,
      'goals': goals,
      'assists': assists,
      'minutesPlayed': minutesPlayed,
    };
  }
}

/// International statistics
class InternationalStats {
  final int appearances;
  final int goals;
  final int assists;
  final int minutesPlayed;

  InternationalStats({
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.minutesPlayed,
  });

  factory InternationalStats.fromMap(Map<String, dynamic> map) {
    return InternationalStats(
      appearances: map['appearances'] ?? 0,
      goals: map['goals'] ?? 0,
      assists: map['assists'] ?? 0,
      minutesPlayed: map['minutesPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appearances': appearances,
      'goals': goals,
      'assists': assists,
      'minutesPlayed': minutesPlayed,
    };
  }
}

/// Social media information
class SocialMedia {
  final String instagram;
  final String twitter;
  final int followers;

  SocialMedia({
    required this.instagram,
    required this.twitter,
    required this.followers,
  });

  factory SocialMedia.fromMap(Map<String, dynamic> map) {
    return SocialMedia(
      instagram: map['instagram'] ?? '',
      twitter: map['twitter'] ?? '',
      followers: map['followers'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'followers': followers,
    };
  }

  /// Get formatted follower count (e.g., "28M")
  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(0)}K';
    }
    return followers.toString();
  }
}

/// World Cup tournament statistics for a specific year
class WorldCupTournamentStats {
  final int year;
  final int matches;
  final int goals;
  final int assists;
  final int? yellowCards;
  final int? redCards;
  final int? minutesPlayed;
  final String stage;
  final String? keyMoment;

  WorldCupTournamentStats({
    required this.year,
    required this.matches,
    required this.goals,
    required this.assists,
    this.yellowCards,
    this.redCards,
    this.minutesPlayed,
    required this.stage,
    this.keyMoment,
  });

  factory WorldCupTournamentStats.fromMap(Map<String, dynamic> map) {
    return WorldCupTournamentStats(
      year: map['year'] ?? 0,
      matches: map['matches'] ?? 0,
      goals: map['goals'] ?? 0,
      assists: map['assists'] ?? 0,
      yellowCards: map['yellowCards'],
      redCards: map['redCards'],
      minutesPlayed: map['minutesPlayed'],
      stage: map['stage'] ?? '',
      keyMoment: map['keyMoment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'matches': matches,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'minutesPlayed': minutesPlayed,
      'stage': stage,
      'keyMoment': keyMoment,
    };
  }
}
