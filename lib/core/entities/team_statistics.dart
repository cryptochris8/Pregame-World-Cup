/// Team statistics entity for comprehensive World Cup team performance analysis
/// Used in Enhanced AI Analysis for team comparisons
class TeamStatistics {
  final String teamId;
  final String teamName;
  final AttackStats attack;
  final DefenseStats defense;
  final SetPieceStats setPieces;
  final String record;
  final int fifaRanking;

  const TeamStatistics({
    required this.teamId,
    required this.teamName,
    required this.attack,
    required this.defense,
    required this.setPieces,
    required this.record,
    required this.fifaRanking,
  });

  /// Create TeamStatistics from API response
  factory TeamStatistics.fromApi(Map<String, dynamic> json) {
    return TeamStatistics(
      teamId: json['teamId']?.toString() ?? '',
      teamName: json['teamName'] ?? 'Unknown Team',
      attack: AttackStats.fromJson(json['attack'] ?? json['offense'] ?? {}),
      defense: DefenseStats.fromJson(json['defense'] ?? {}),
      setPieces: SetPieceStats.fromJson(json['setPieces'] ?? json['special'] ?? {}),
      record: json['record'] ?? '0-0-0',
      fifaRanking: (json['fifaRanking'] ?? json['ranking'] ?? 0) as int,
    );
  }

  /// Get overall team efficiency rating (custom metric)
  /// Weighted: attack 40%, defense 40%, set pieces 20% (soccer is more balanced)
  double get overallEfficiency {
    final attackRating = attack.efficiency;
    final defenseRating = defense.efficiency;
    final setPieceRating = setPieces.efficiency;

    return (attackRating * 0.4) + (defenseRating * 0.4) + (setPieceRating * 0.2);
  }

  /// Get win percentage from record (W-D-L format for soccer)
  double get winPercentage {
    final parts = record.split('-');
    if (parts.length >= 2) {
      final wins = int.tryParse(parts[0]) ?? 0;
      final draws = parts.length >= 3 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final losses = int.tryParse(parts.length >= 3 ? parts[2] : parts[1]) ?? 0;
      final totalGames = wins + draws + losses;
      return totalGames > 0 ? wins / totalGames : 0.0;
    }
    return 0.0;
  }

  /// Get points per game (3 for win, 1 for draw)
  double get pointsPerGame {
    final parts = record.split('-');
    if (parts.length >= 3) {
      final wins = int.tryParse(parts[0]) ?? 0;
      final draws = int.tryParse(parts[1]) ?? 0;
      final losses = int.tryParse(parts[2]) ?? 0;
      final totalGames = wins + draws + losses;
      final totalPoints = (wins * 3) + draws;
      return totalGames > 0 ? totalPoints / totalGames : 0.0;
    }
    return 0.0;
  }

  /// Check if team is in the FIFA top 20
  bool get isTopRanked => fifaRanking > 0 && fifaRanking <= 20;

  /// Get formatted ranking display
  String get rankingDisplay => fifaRanking > 0 ? 'FIFA #$fifaRanking' : 'Unranked';
}

/// Attack statistics for team performance in soccer
class AttackStats {
  final double goalsScored;
  final double shotsPerGame;
  final double possession;
  final double passAccuracy;
  final double chancesCreated;

  const AttackStats({
    required this.goalsScored,
    required this.shotsPerGame,
    required this.possession,
    required this.passAccuracy,
    required this.chancesCreated,
  });

  factory AttackStats.fromJson(Map<String, dynamic> json) {
    return AttackStats(
      goalsScored: _toDouble(json['goalsScored']),
      shotsPerGame: _toDouble(json['shotsPerGame']),
      possession: _toDouble(json['possession']),
      passAccuracy: _toDouble(json['passAccuracy']),
      chancesCreated: _toDouble(json['chancesCreated']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Get attacking style description based on possession and shots
  String get attackingStyle {
    if (possession > 60.0) return 'Possession-Based';
    if (shotsPerGame > 15.0 && possession < 45.0) return 'Counter-Attacking';
    if (possession < 40.0) return 'Defensive / Counter';
    return 'Balanced';
  }

  /// Get shot conversion rate (goals per shots)
  double get conversionRate {
    return shotsPerGame > 0 ? (goalsScored / shotsPerGame) * 100 : 0.0;
  }

  /// Get overall attacking efficiency rating (0-100)
  double get efficiency {
    // Soccer-appropriate formula
    final goalsRating = (goalsScored / 3.0) * 100; // 3 goals/game = 100%
    final possessionRating = possession; // Already 0-100 scale
    final accuracyRating = passAccuracy; // Already 0-100 scale
    final shotsRating = (shotsPerGame / 20.0) * 100; // 20 shots/game = 100%
    final chancesRating = (chancesCreated / 15.0) * 100; // 15 chances/game = 100%

    final baseRating = (goalsRating * 0.35) + (possessionRating * 0.20) +
                      (accuracyRating * 0.20) + (shotsRating * 0.10) +
                      (chancesRating * 0.15);

    return baseRating.clamp(0.0, 100.0);
  }
}

/// Defense statistics for team performance in soccer
class DefenseStats {
  final double goalsConceded;
  final double cleanSheets;
  final double tacklesPerGame;
  final double interceptions;
  final double savesPerGame;

  const DefenseStats({
    required this.goalsConceded,
    required this.cleanSheets,
    required this.tacklesPerGame,
    required this.interceptions,
    required this.savesPerGame,
  });

  factory DefenseStats.fromJson(Map<String, dynamic> json) {
    return DefenseStats(
      goalsConceded: AttackStats._toDouble(json['goalsConceded']),
      cleanSheets: AttackStats._toDouble(json['cleanSheets']),
      tacklesPerGame: AttackStats._toDouble(json['tacklesPerGame']),
      interceptions: AttackStats._toDouble(json['interceptions']),
      savesPerGame: AttackStats._toDouble(json['savesPerGame']),
    );
  }

  /// Get total defensive actions per game
  double get defensiveActionsPerGame => tacklesPerGame + interceptions;

  /// Get overall defensive efficiency rating (0-100, higher is better)
  double get efficiency {
    // Soccer-appropriate formula - lower goals conceded = higher rating
    final goalsConcededRating = ((3.0 - goalsConceded) / 3.0) * 100; // 0 conceded = 100%
    final cleanSheetRating = (cleanSheets / 10.0) * 100; // 10 clean sheets = 100%
    final tacklesRating = (tacklesPerGame / 25.0) * 100; // 25 tackles/game = 100%
    final interceptionsRating = (interceptions / 15.0) * 100; // 15 per game = 100%
    final savesRating = (savesPerGame / 5.0) * 100; // 5 saves/game = 100%

    final baseRating = (goalsConcededRating * 0.35) + (cleanSheetRating * 0.25) +
                      (tacklesRating * 0.15) + (interceptionsRating * 0.10) +
                      (savesRating * 0.15);

    return baseRating.clamp(0.0, 100.0);
  }

  /// Get defensive strength description
  String get defensiveStrength {
    if (goalsConceded < 0.5 && cleanSheets > 5) {
      return 'Elite Defense';
    } else if (goalsConceded < 1.0) {
      return 'Strong Defense';
    } else if (tacklesPerGame > 20 && interceptions > 10) {
      return 'Aggressive Defense';
    } else {
      return 'Balanced Defense';
    }
  }
}

/// Set piece statistics for soccer teams
class SetPieceStats {
  final double cornerKicks;
  final double freeKicks;
  final double penalties;
  final double penaltyConversionRate;

  const SetPieceStats({
    required this.cornerKicks,
    required this.freeKicks,
    required this.penalties,
    required this.penaltyConversionRate,
  });

  factory SetPieceStats.fromJson(Map<String, dynamic> json) {
    return SetPieceStats(
      cornerKicks: AttackStats._toDouble(json['cornerKicks']),
      freeKicks: AttackStats._toDouble(json['freeKicks']),
      penalties: AttackStats._toDouble(json['penalties']),
      penaltyConversionRate: AttackStats._toDouble(json['penaltyConversionRate']),
    );
  }

  /// Get overall set piece efficiency (0-100)
  double get efficiency {
    final cornerRating = (cornerKicks / 8.0) * 100; // 8 corners/game = 100%
    final freeKickRating = (freeKicks / 15.0) * 100; // 15 free kicks/game = 100%
    final penaltyRating = penaltyConversionRate; // Already 0-100 scale

    final baseRating = (cornerRating * 0.40) + (freeKickRating * 0.30) +
                      (penaltyRating * 0.30);

    return baseRating.clamp(0.0, 100.0);
  }

  /// Get set piece strength description
  String get setPieceStrength {
    if (penaltyConversionRate > 85.0) {
      return 'Clinical from the Spot';
    } else if (cornerKicks > 7.0) {
      return 'Dangerous from Corners';
    } else if (freeKicks > 12.0) {
      return 'Active Set Piece Team';
    } else {
      return 'Standard Set Pieces';
    }
  }
}
