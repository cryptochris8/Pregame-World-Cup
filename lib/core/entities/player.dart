/// Player entity for NCAA college football players
/// Contains profile information and statistics
class Player {
  final String id;
  final String name;
  final String position;
  final String playerClass;
  final String height;
  final String weight;
  final String number;
  final String hometown;
  final PlayerStatistics? statistics;
  final String? teamKey;
  
  const Player({
    required this.id,
    required this.name,
    required this.position,
    required this.playerClass,
    required this.height,
    required this.weight,
    required this.number,
    required this.hometown,
    this.statistics,
    this.teamKey,
  });
  
  /// Create Player from NCAA API response
  factory Player.fromNCAAApi(Map<String, dynamic> json) {
    return Player(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Player',
      position: json['position'] ?? 'N/A',
      playerClass: json['class'] ?? 'N/A',
      height: json['height'] ?? 'N/A',
      weight: json['weight'] ?? 'N/A',
      number: json['number'] ?? 'N/A',
      hometown: json['hometown'] ?? 'N/A',
      statistics: json['stats'] != null 
        ? PlayerStatistics.fromJson(json['stats'])
        : null,
      teamKey: json['teamKey'] as String?,
    );
  }
  
  /// Get display name with position
  String get displayNameWithPosition => '$name ($position)';
  
  /// Get formatted height and weight
  String get physicalStats => '${height}, ${weight} lbs';
  
  /// Check if player has statistics available
  bool get hasStatistics => statistics != null;
  
  /// Get primary statistic based on position
  String get primaryStat {
    if (statistics == null) return 'No stats available';
    
    final pos = position.toLowerCase();
    if (pos.contains('qb')) {
      return '${statistics!.passing.yards} pass yds, ${statistics!.passing.touchdowns} TDs';
    } else if (pos.contains('rb')) {
      return '${statistics!.rushing.yards} rush yds, ${statistics!.rushing.touchdowns} TDs';
    } else if (pos.contains('wr') || pos.contains('te')) {
      return '${statistics!.receiving.yards} rec yds, ${statistics!.receiving.touchdowns} TDs';
    } else {
      return '${statistics!.defense.tackles} tackles, ${statistics!.defense.sacks} sacks';
    }
  }
  
  /// Convert player to JSON for API usage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'playerClass': playerClass,
      'height': height,
      'weight': weight,
      'number': number,
      'hometown': hometown,
      'teamKey': teamKey,
      'statistics': statistics != null ? {
        'passing': {
          'yards': statistics!.passing.yards,
          'touchdowns': statistics!.passing.touchdowns,
          'attempts': statistics!.passing.attempts,
          'completions': statistics!.passing.completions,
        },
        'rushing': {
          'yards': statistics!.rushing.yards,
          'touchdowns': statistics!.rushing.touchdowns,
          'attempts': statistics!.rushing.attempts,
        },
        'receiving': {
          'yards': statistics!.receiving.yards,
          'touchdowns': statistics!.receiving.touchdowns,
          'receptions': statistics!.receiving.receptions,
        },
        'defense': {
          'tackles': statistics!.defense.tackles,
          'sacks': statistics!.defense.sacks,
        },
      } : null,
    };
  }
}

/// Player statistics broken down by category
class PlayerStatistics {
  final PassingStats passing;
  final RushingStats rushing;
  final ReceivingStats receiving;
  final DefenseStats defense;
  
  const PlayerStatistics({
    required this.passing,
    required this.rushing,
    required this.receiving,
    required this.defense,
  });
  
  /// Create PlayerStatistics from API response
  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      passing: PassingStats.fromJson(json['passing'] ?? {}),
      rushing: RushingStats.fromJson(json['rushing'] ?? {}),
      receiving: ReceivingStats.fromJson(json['receiving'] ?? {}),
      defense: DefenseStats.fromJson(json['defense'] ?? {}),
    );
  }
}

/// Passing statistics for quarterbacks
class PassingStats {
  final int attempts;
  final int completions;
  final int yards;
  final int touchdowns;
  final int interceptions;
  final double rating;
  
  const PassingStats({
    required this.attempts,
    required this.completions,
    required this.yards,
    required this.touchdowns,
    required this.interceptions,
    required this.rating,
  });
  
  factory PassingStats.fromJson(Map<String, dynamic> json) {
    return PassingStats(
      attempts: _parseToInt(json['attempts']),
      completions: _parseToInt(json['completions']),
      yards: _parseToInt(json['yards']),
      touchdowns: _parseToInt(json['touchdowns']),
      interceptions: _parseToInt(json['interceptions']),
      rating: _parseToDouble(json['rating']),
    );
  }
  
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.round();
    return 0;
  }
  
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  /// Get completion percentage
  double get completionPercentage => 
    attempts > 0 ? (completions / attempts) * 100 : 0.0;
  
  /// Get yards per attempt
  double get yardsPerAttempt => 
    attempts > 0 ? yards / attempts : 0.0;
  
  /// Get touchdown to interception ratio
  double get tdIntRatio => 
    interceptions > 0 ? touchdowns / interceptions : touchdowns.toDouble();
}

/// Rushing statistics for running backs and other players
class RushingStats {
  final int attempts;
  final int yards;
  final int touchdowns;
  final double average;
  final int longRush;
  
  const RushingStats({
    required this.attempts,
    required this.yards,
    required this.touchdowns,
    required this.average,
    required this.longRush,
  });
  
  factory RushingStats.fromJson(Map<String, dynamic> json) {
    return RushingStats(
      attempts: PassingStats._parseToInt(json['attempts']),
      yards: PassingStats._parseToInt(json['yards']),
      touchdowns: PassingStats._parseToInt(json['touchdowns']),
      average: PassingStats._parseToDouble(json['average']),
      longRush: PassingStats._parseToInt(json['longRush']),
    );
  }
  
  /// Get yards per carry
  double get yardsPerCarry => 
    attempts > 0 ? yards / attempts : 0.0;
}

/// Receiving statistics for receivers and tight ends
class ReceivingStats {
  final int receptions;
  final int yards;
  final int touchdowns;
  final double average;
  final int longReception;
  
  const ReceivingStats({
    required this.receptions,
    required this.yards,
    required this.touchdowns,
    required this.average,
    required this.longReception,
  });
  
  factory ReceivingStats.fromJson(Map<String, dynamic> json) {
    return ReceivingStats(
      receptions: PassingStats._parseToInt(json['receptions']),
      yards: PassingStats._parseToInt(json['yards']),
      touchdowns: PassingStats._parseToInt(json['touchdowns']),
      average: PassingStats._parseToDouble(json['average']),
      longReception: PassingStats._parseToInt(json['longReception']),
    );
  }
  
  /// Get yards per reception
  double get yardsPerReception => 
    receptions > 0 ? yards / receptions : 0.0;
}

/// Defensive statistics for defensive players
class DefenseStats {
  final int tackles;
  final int sacks;
  final int interceptions;
  final int passBreakups;
  final int forcedFumbles;
  
  const DefenseStats({
    required this.tackles,
    required this.sacks,
    required this.interceptions,
    required this.passBreakups,
    required this.forcedFumbles,
  });
  
  factory DefenseStats.fromJson(Map<String, dynamic> json) {
    return DefenseStats(
      tackles: PassingStats._parseToInt(json['tackles']),
      sacks: PassingStats._parseToInt(json['sacks']),
      interceptions: PassingStats._parseToInt(json['interceptions']),
      passBreakups: PassingStats._parseToInt(json['passBreakups']),
      forcedFumbles: PassingStats._parseToInt(json['forcedFumbles']),
    );
  }
  
  /// Get total defensive impact (custom metric)
  int get defensiveImpact => 
    tackles + (sacks * 2) + (interceptions * 3) + passBreakups + (forcedFumbles * 2);
} 