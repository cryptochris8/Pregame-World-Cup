/// Team statistics entity for comprehensive team performance analysis
/// Used in Enhanced AI Analysis for team comparisons
class TeamStatistics {
  final String teamId;
  final String teamName;
  final OffensiveStats offense;
  final DefensiveStats defense;
  final SpecialTeamsStats special;
  final String record;
  final int ranking;
  
  const TeamStatistics({
    required this.teamId,
    required this.teamName,
    required this.offense,
    required this.defense,
    required this.special,
    required this.record,
    required this.ranking,
  });
  
  /// Create TeamStatistics from NCAA API response
  factory TeamStatistics.fromNCAAApi(Map<String, dynamic> json) {
    return TeamStatistics(
      teamId: json['teamId']?.toString() ?? '',
      teamName: json['teamName'] ?? 'Unknown Team',
      offense: OffensiveStats.fromJson(json['offense'] ?? {}),
      defense: DefensiveStats.fromJson(json['defense'] ?? {}),
      special: SpecialTeamsStats.fromJson(json['special'] ?? {}),
      record: json['record'] ?? '0-0',
      ranking: (json['ranking'] ?? 0) as int,
    );
  }
  
  /// Get overall team efficiency rating (custom metric)
  double get overallEfficiency {
    final offenseRating = offense.efficiency;
    final defenseRating = defense.efficiency;
    final specialRating = special.efficiency;
    
    return (offenseRating * 0.5) + (defenseRating * 0.4) + (specialRating * 0.1);
  }
  
  /// Get win percentage from record
  double get winPercentage {
    final parts = record.split('-');
    if (parts.length >= 2) {
      final wins = int.tryParse(parts[0]) ?? 0;
      final losses = int.tryParse(parts[1]) ?? 0;
      final totalGames = wins + losses;
      return totalGames > 0 ? wins / totalGames : 0.0;
    }
    return 0.0;
  }
  
  /// Check if team is ranked
  bool get isRanked => ranking > 0 && ranking <= 25;
  
  /// Get formatted ranking display
  String get rankingDisplay => isRanked ? '#$ranking' : 'Unranked';
}

/// Offensive statistics for team performance
class OffensiveStats {
  final double totalYards;
  final double passingYards;
  final double rushingYards;
  final double pointsPerGame;
  final double thirdDownConversion;
  final double redZoneEfficiency;
  final double yardsPerPlay;
  final double turnoversPerGame;
  
  const OffensiveStats({
    required this.totalYards,
    required this.passingYards,
    required this.rushingYards,
    required this.pointsPerGame,
    required this.thirdDownConversion,
    required this.redZoneEfficiency,
    required this.yardsPerPlay,
    required this.turnoversPerGame,
  });
  
  factory OffensiveStats.fromJson(Map<String, dynamic> json) {
    return OffensiveStats(
      totalYards: (json['totalYards'] ?? 0.0) as double,
      passingYards: (json['passingYards'] ?? 0.0) as double,
      rushingYards: (json['rushingYards'] ?? 0.0) as double,
      pointsPerGame: (json['pointsPerGame'] ?? 0.0) as double,
      thirdDownConversion: (json['thirdDownConversion'] ?? 0.0) as double,
      redZoneEfficiency: (json['redZoneEfficiency'] ?? 0.0) as double,
      yardsPerPlay: (json['yardsPerPlay'] ?? 0.0) as double,
      turnoversPerGame: (json['turnoversPerGame'] ?? 0.0) as double,
    );
  }
  
  /// Get offensive balance (0.5 = perfectly balanced, closer to 0 = run heavy, closer to 1 = pass heavy)
  double get offensiveBalance {
    final totalOffense = passingYards + rushingYards;
    return totalOffense > 0 ? passingYards / totalOffense : 0.5;
  }
  
  /// Get overall offensive efficiency rating (0-100)
  double get efficiency {
    // Custom formula considering multiple factors
    final pointsRating = (pointsPerGame / 50.0) * 100; // Max 50 PPG = 100%
    final yardsRating = (totalYards / 500.0) * 100; // Max 500 YPG = 100%
    final thirdDownRating = thirdDownConversion * 100;
    final redZoneRating = redZoneEfficiency * 100;
    final turnoverPenalty = turnoversPerGame * 10; // Penalty for turnovers
    
    final baseRating = (pointsRating * 0.4) + (yardsRating * 0.3) + 
                      (thirdDownRating * 0.2) + (redZoneRating * 0.1);
    
    return (baseRating - turnoverPenalty).clamp(0.0, 100.0);
  }
  
  /// Get offensive style description
  String get offensiveStyle {
    final balance = offensiveBalance;
    if (balance > 0.65) return 'Pass Heavy';
    if (balance < 0.35) return 'Run Heavy';
    return 'Balanced';
  }
}

/// Defensive statistics for team performance
class DefensiveStats {
  final double totalYardsAllowed;
  final double passingYardsAllowed;
  final double rushingYardsAllowed;
  final double pointsAllowedPerGame;
  final double sacks;
  final double interceptions;
  final double forcedFumbles;
  final double thirdDownDefense;
  final double redZoneDefense;
  
  const DefensiveStats({
    required this.totalYardsAllowed,
    required this.passingYardsAllowed,
    required this.rushingYardsAllowed,
    required this.pointsAllowedPerGame,
    required this.sacks,
    required this.interceptions,
    required this.forcedFumbles,
    required this.thirdDownDefense,
    required this.redZoneDefense,
  });
  
  factory DefensiveStats.fromJson(Map<String, dynamic> json) {
    return DefensiveStats(
      totalYardsAllowed: (json['totalYardsAllowed'] ?? 0.0) as double,
      passingYardsAllowed: (json['passingYardsAllowed'] ?? 0.0) as double,
      rushingYardsAllowed: (json['rushingYardsAllowed'] ?? 0.0) as double,
      pointsAllowedPerGame: (json['pointsAllowedPerGame'] ?? 0.0) as double,
      sacks: (json['sacks'] ?? 0.0) as double,
      interceptions: (json['interceptions'] ?? 0.0) as double,
      forcedFumbles: (json['forcedFumbles'] ?? 0.0) as double,
      thirdDownDefense: (json['thirdDownDefense'] ?? 0.0) as double,
      redZoneDefense: (json['redZoneDefense'] ?? 0.0) as double,
    );
  }
  
  /// Get total turnovers forced per game
  double get turnoversForced => interceptions + forcedFumbles;
  
  /// Get overall defensive efficiency rating (0-100, higher is better)
  double get efficiency {
    // Custom formula - lower allowed stats = higher rating
    final pointsRating = ((50.0 - pointsAllowedPerGame) / 50.0) * 100; // Less points allowed = better
    final yardsRating = ((500.0 - totalYardsAllowed) / 500.0) * 100; // Less yards allowed = better
    final thirdDownRating = (1.0 - thirdDownDefense) * 100; // Lower conversion rate = better
    final redZoneRating = (1.0 - redZoneDefense) * 100; // Lower conversion rate = better
    final turnoverBonus = turnoversForced * 5; // Bonus for creating turnovers
    
    final baseRating = (pointsRating * 0.4) + (yardsRating * 0.3) + 
                      (thirdDownRating * 0.2) + (redZoneRating * 0.1);
    
    return (baseRating + turnoverBonus).clamp(0.0, 100.0);
  }
  
  /// Get defensive strength description
  String get defensiveStrength {
    if (passingYardsAllowed < rushingYardsAllowed * 1.5) {
      return 'Strong Pass Defense';
    } else if (rushingYardsAllowed < passingYardsAllowed * 0.75) {
      return 'Strong Run Defense';
    } else {
      return 'Balanced Defense';
    }
  }
}

/// Special teams statistics
class SpecialTeamsStats {
  final double fieldGoalPercentage;
  final double puntAverage;
  final double kickoffReturnAverage;
  final double puntReturnAverage;
  final double blockedKicks;
  
  const SpecialTeamsStats({
    required this.fieldGoalPercentage,
    required this.puntAverage,
    required this.kickoffReturnAverage,
    required this.puntReturnAverage,
    required this.blockedKicks,
  });
  
  factory SpecialTeamsStats.fromJson(Map<String, dynamic> json) {
    return SpecialTeamsStats(
      fieldGoalPercentage: (json['fieldGoalPercentage'] ?? 0.0) as double,
      puntAverage: (json['puntAverage'] ?? 0.0) as double,
      kickoffReturnAverage: (json['kickoffReturnAverage'] ?? 0.0) as double,
      puntReturnAverage: (json['puntReturnAverage'] ?? 0.0) as double,
      blockedKicks: (json['blockedKicks'] ?? 0.0) as double,
    );
  }
  
  /// Get overall special teams efficiency (0-100)
  double get efficiency {
    final fgRating = fieldGoalPercentage * 100;
    final puntRating = (puntAverage / 50.0) * 100; // 50 yard average = 100%
    final returnRating = ((kickoffReturnAverage + puntReturnAverage) / 40.0) * 100; // 20 yard average each = 100%
    final blockBonus = blockedKicks * 10; // Bonus for blocked kicks
    
    final baseRating = (fgRating * 0.5) + (puntRating * 0.3) + (returnRating * 0.2);
    
    return (baseRating + blockBonus).clamp(0.0, 100.0);
  }
  
  /// Get special teams strength description
  String get specialTeamsStrength {
    if (fieldGoalPercentage > 0.85) {
      return 'Elite Kicking Game';
    } else if (kickoffReturnAverage > 25 || puntReturnAverage > 12) {
      return 'Dangerous Return Game';
    } else if (puntAverage > 45) {
      return 'Strong Punting Game';
    } else {
      return 'Solid Special Teams';
    }
  }
} 