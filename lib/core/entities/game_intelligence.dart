import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'game_intelligence.g.dart';

@HiveType(typeId: 21)
class GameIntelligence extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String gameId;

  @HiveField(1)
  final String homeTeam;

  @HiveField(2)
  final String awayTeam;

  @HiveField(3)
  final int? homeTeamRank;

  @HiveField(4)
  final int? awayTeamRank;

  @HiveField(5)
  final double crowdFactor;

  @HiveField(6)
  final bool isRivalryGame;

  @HiveField(7)
  final bool hasChampionshipImplications;

  @HiveField(8)
  final String broadcastNetwork;

  @HiveField(9)
  final double expectedTvAudience;

  @HiveField(10)
  final List<String> keyStorylines;

  @HiveField(11)
  final Map<String, dynamic> teamStats;

  @HiveField(12)
  final DateTime lastUpdated;

  @HiveField(13)
  final double confidenceScore;

  @HiveField(14)
  final VenueRecommendations venueRecommendations;

  GameIntelligence({
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamRank,
    this.awayTeamRank,
    required this.crowdFactor,
    required this.isRivalryGame,
    required this.hasChampionshipImplications,
    required this.broadcastNetwork,
    required this.expectedTvAudience,
    required this.keyStorylines,
    required this.teamStats,
    required this.lastUpdated,
    required this.confidenceScore,
    required this.venueRecommendations,
  });

  @override
  List<Object?> get props => [
        gameId,
        homeTeam,
        awayTeam,
        homeTeamRank,
        awayTeamRank,
        crowdFactor,
        isRivalryGame,
        hasChampionshipImplications,
        broadcastNetwork,
        expectedTvAudience,
        keyStorylines,
        teamStats,
        lastUpdated,
        confidenceScore,
        venueRecommendations,
      ];

  GameIntelligence copyWith({
    String? gameId,
    String? homeTeam,
    String? awayTeam,
    int? homeTeamRank,
    int? awayTeamRank,
    double? crowdFactor,
    bool? isRivalryGame,
    bool? hasChampionshipImplications,
    String? broadcastNetwork,
    double? expectedTvAudience,
    List<String>? keyStorylines,
    Map<String, dynamic>? teamStats,
    DateTime? lastUpdated,
    double? confidenceScore,
    VenueRecommendations? venueRecommendations,
  }) {
    return GameIntelligence(
      gameId: gameId ?? this.gameId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamRank: homeTeamRank ?? this.homeTeamRank,
      awayTeamRank: awayTeamRank ?? this.awayTeamRank,
      crowdFactor: crowdFactor ?? this.crowdFactor,
      isRivalryGame: isRivalryGame ?? this.isRivalryGame,
      hasChampionshipImplications: hasChampionshipImplications ?? this.hasChampionshipImplications,
      broadcastNetwork: broadcastNetwork ?? this.broadcastNetwork,
      expectedTvAudience: expectedTvAudience ?? this.expectedTvAudience,
      keyStorylines: keyStorylines ?? this.keyStorylines,
      teamStats: teamStats ?? this.teamStats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      venueRecommendations: venueRecommendations ?? this.venueRecommendations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeTeamRank': homeTeamRank,
      'awayTeamRank': awayTeamRank,
      'crowdFactor': crowdFactor,
      'isRivalryGame': isRivalryGame,
      'hasChampionshipImplications': hasChampionshipImplications,
      'broadcastNetwork': broadcastNetwork,
      'expectedTvAudience': expectedTvAudience,
      'keyStorylines': keyStorylines,
      'teamStats': teamStats,
      'lastUpdated': lastUpdated.toIso8601String(),
      'confidenceScore': confidenceScore,
      'venueRecommendations': venueRecommendations.toJson(),
    };
  }

  factory GameIntelligence.fromJson(Map<String, dynamic> json) {
    return GameIntelligence(
      gameId: json['gameId'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeTeamRank: json['homeTeamRank'] as int?,
      awayTeamRank: json['awayTeamRank'] as int?,
      crowdFactor: (json['crowdFactor'] as num).toDouble(),
      isRivalryGame: json['isRivalryGame'] as bool,
      hasChampionshipImplications: json['hasChampionshipImplications'] as bool,
      broadcastNetwork: json['broadcastNetwork'] as String,
      expectedTvAudience: (json['expectedTvAudience'] as num).toDouble(),
      keyStorylines: List<String>.from(json['keyStorylines'] as List),
      teamStats: Map<String, dynamic>.from(json['teamStats'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      venueRecommendations: VenueRecommendations.fromJson(json['venueRecommendations'] as Map<String, dynamic>),
    );
  }
}

@HiveType(typeId: 22)
class VenueRecommendations extends HiveObject with EquatableMixin {
  @HiveField(0)
  final double expectedTrafficIncrease;

  @HiveField(1)
  final String staffingRecommendation;

  @HiveField(2)
  final List<String> suggestedSpecials;

  @HiveField(3)
  final String inventoryAdvice;

  @HiveField(4)
  final String marketingOpportunity;

  @HiveField(5)
  final double revenueProjection;

  VenueRecommendations({
    required this.expectedTrafficIncrease,
    required this.staffingRecommendation,
    required this.suggestedSpecials,
    required this.inventoryAdvice,
    required this.marketingOpportunity,
    required this.revenueProjection,
  });

  @override
  List<Object?> get props => [
        expectedTrafficIncrease,
        staffingRecommendation,
        suggestedSpecials,
        inventoryAdvice,
        marketingOpportunity,
        revenueProjection,
      ];

  Map<String, dynamic> toJson() {
    return {
      'expectedTrafficIncrease': expectedTrafficIncrease,
      'staffingRecommendation': staffingRecommendation,
      'suggestedSpecials': suggestedSpecials,
      'inventoryAdvice': inventoryAdvice,
      'marketingOpportunity': marketingOpportunity,
      'revenueProjection': revenueProjection,
    };
  }

  factory VenueRecommendations.fromJson(Map<String, dynamic> json) {
    return VenueRecommendations(
      expectedTrafficIncrease: (json['expectedTrafficIncrease'] as num).toDouble(),
      staffingRecommendation: json['staffingRecommendation'] as String,
      suggestedSpecials: List<String>.from(json['suggestedSpecials'] as List),
      inventoryAdvice: json['inventoryAdvice'] as String,
      marketingOpportunity: json['marketingOpportunity'] as String,
      revenueProjection: (json['revenueProjection'] as num).toDouble(),
    );
  }
} 