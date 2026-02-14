/// Player entity for World Cup soccer player data
/// Contains profile information and statistics
class Player {
  final String id;
  final String name;
  final String position;
  final String nationality;
  final String height;
  final String weight;
  final String number;
  final String club;
  final PlayerStatistics? statistics;
  final String? teamKey;

  const Player({
    required this.id,
    required this.name,
    required this.position,
    required this.nationality,
    required this.height,
    required this.weight,
    required this.number,
    required this.club,
    this.statistics,
    this.teamKey,
  });

  /// Create Player from API response
  factory Player.fromApi(Map<String, dynamic> json) {
    return Player(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Player',
      position: json['position'] ?? 'N/A',
      nationality: json['nationality'] ?? json['class'] ?? 'N/A',
      height: json['height'] ?? 'N/A',
      weight: json['weight'] ?? 'N/A',
      number: json['number'] ?? 'N/A',
      club: json['club'] ?? json['hometown'] ?? 'N/A',
      statistics: json['stats'] != null
        ? PlayerStatistics.fromJson(json['stats'])
        : null,
      teamKey: json['teamKey'] as String?,
    );
  }

  /// Get display name with position
  String get displayNameWithPosition => '$name ($position)';

  /// Get formatted height and weight
  String get physicalStats => '$height, $weight kg';

  /// Check if player has statistics available
  bool get hasStatistics => statistics != null;

  /// Get primary statistic based on position
  String get primaryStat {
    if (statistics == null) return 'No stats available';

    final pos = position.toUpperCase();
    if (pos.contains('GK')) {
      return '${statistics!.goalkeeper.saves} saves, ${statistics!.goalkeeper.cleanSheets} clean sheets';
    } else if (pos.contains('CB') || pos.contains('LB') || pos.contains('RB') || pos.contains('CDM')) {
      return '${statistics!.defensive.tackles} tackles, ${statistics!.defensive.interceptions} interceptions';
    } else if (pos.contains('CAM') || pos.contains('CM')) {
      return '${statistics!.creative.keyPasses} key passes, ${statistics!.creative.chancesCreated} chances created';
    } else {
      // ST, CF, LW, RW - attacking players
      return '${statistics!.attacking.goals} goals, ${statistics!.attacking.assists} assists';
    }
  }

  /// Convert player to JSON for API usage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'nationality': nationality,
      'height': height,
      'weight': weight,
      'number': number,
      'club': club,
      'teamKey': teamKey,
      'statistics': statistics != null ? {
        'goalkeeper': {
          'saves': statistics!.goalkeeper.saves,
          'cleanSheets': statistics!.goalkeeper.cleanSheets,
          'goalsConceded': statistics!.goalkeeper.goalsConceded,
          'savePercentage': statistics!.goalkeeper.savePercentage,
        },
        'attacking': {
          'goals': statistics!.attacking.goals,
          'assists': statistics!.attacking.assists,
          'shots': statistics!.attacking.shots,
          'shotsOnTarget': statistics!.attacking.shotsOnTarget,
          'minutesPlayed': statistics!.attacking.minutesPlayed,
        },
        'creative': {
          'keyPasses': statistics!.creative.keyPasses,
          'crosses': statistics!.creative.crosses,
          'throughBalls': statistics!.creative.throughBalls,
          'chancesCreated': statistics!.creative.chancesCreated,
        },
        'defensive': {
          'tackles': statistics!.defensive.tackles,
          'interceptions': statistics!.defensive.interceptions,
          'clearances': statistics!.defensive.clearances,
          'blocks': statistics!.defensive.blocks,
          'aerialDuelsWon': statistics!.defensive.aerialDuelsWon,
        },
      } : null,
    };
  }
}

/// Player statistics broken down by category
class PlayerStatistics {
  final GoalkeeperStats goalkeeper;
  final AttackingStats attacking;
  final CreativeStats creative;
  final DefensiveStats defensive;

  const PlayerStatistics({
    required this.goalkeeper,
    required this.attacking,
    required this.creative,
    required this.defensive,
  });

  /// Create PlayerStatistics from API response
  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      goalkeeper: GoalkeeperStats.fromJson(json['goalkeeper'] ?? {}),
      attacking: AttackingStats.fromJson(json['attacking'] ?? {}),
      creative: CreativeStats.fromJson(json['creative'] ?? {}),
      defensive: DefensiveStats.fromJson(json['defensive'] ?? {}),
    );
  }
}

/// Goalkeeper statistics
class GoalkeeperStats {
  final int saves;
  final int cleanSheets;
  final int goalsConceded;
  final double savePercentage;

  const GoalkeeperStats({
    required this.saves,
    required this.cleanSheets,
    required this.goalsConceded,
    required this.savePercentage,
  });

  factory GoalkeeperStats.fromJson(Map<String, dynamic> json) {
    return GoalkeeperStats(
      saves: _parseToInt(json['saves']),
      cleanSheets: _parseToInt(json['cleanSheets']),
      goalsConceded: _parseToInt(json['goalsConceded']),
      savePercentage: _parseToDouble(json['savePercentage']),
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

  /// Get saves per goals conceded ratio
  double get savesToConcededRatio =>
    goalsConceded > 0 ? saves / goalsConceded : saves.toDouble();
}

/// Attacking statistics for forwards and attacking players
class AttackingStats {
  final int goals;
  final int assists;
  final int shots;
  final int shotsOnTarget;
  final int minutesPlayed;

  const AttackingStats({
    required this.goals,
    required this.assists,
    required this.shots,
    required this.shotsOnTarget,
    required this.minutesPlayed,
  });

  factory AttackingStats.fromJson(Map<String, dynamic> json) {
    return AttackingStats(
      goals: GoalkeeperStats._parseToInt(json['goals']),
      assists: GoalkeeperStats._parseToInt(json['assists']),
      shots: GoalkeeperStats._parseToInt(json['shots']),
      shotsOnTarget: GoalkeeperStats._parseToInt(json['shotsOnTarget']),
      minutesPlayed: GoalkeeperStats._parseToInt(json['minutesPlayed']),
    );
  }

  /// Get shot accuracy percentage
  double get shotAccuracy =>
    shots > 0 ? (shotsOnTarget / shots) * 100 : 0.0;

  /// Get goal contributions (goals + assists)
  int get goalContributions => goals + assists;

  /// Get minutes per goal
  double get minutesPerGoal =>
    goals > 0 ? minutesPlayed / goals : 0.0;
}

/// Creative statistics for midfielders and playmakers
class CreativeStats {
  final int keyPasses;
  final int crosses;
  final int throughBalls;
  final int chancesCreated;

  const CreativeStats({
    required this.keyPasses,
    required this.crosses,
    required this.throughBalls,
    required this.chancesCreated,
  });

  factory CreativeStats.fromJson(Map<String, dynamic> json) {
    return CreativeStats(
      keyPasses: GoalkeeperStats._parseToInt(json['keyPasses']),
      crosses: GoalkeeperStats._parseToInt(json['crosses']),
      throughBalls: GoalkeeperStats._parseToInt(json['throughBalls']),
      chancesCreated: GoalkeeperStats._parseToInt(json['chancesCreated']),
    );
  }

  /// Get total creative output
  int get totalCreativeOutput => keyPasses + crosses + throughBalls;
}

/// Defensive statistics for defenders and defensive midfielders
class DefensiveStats {
  final int tackles;
  final int interceptions;
  final int clearances;
  final int blocks;
  final int aerialDuelsWon;

  const DefensiveStats({
    required this.tackles,
    required this.interceptions,
    required this.clearances,
    required this.blocks,
    required this.aerialDuelsWon,
  });

  factory DefensiveStats.fromJson(Map<String, dynamic> json) {
    return DefensiveStats(
      tackles: GoalkeeperStats._parseToInt(json['tackles']),
      interceptions: GoalkeeperStats._parseToInt(json['interceptions']),
      clearances: GoalkeeperStats._parseToInt(json['clearances']),
      blocks: GoalkeeperStats._parseToInt(json['blocks']),
      aerialDuelsWon: GoalkeeperStats._parseToInt(json['aerialDuelsWon']),
    );
  }

  /// Get total defensive actions
  int get totalDefensiveActions =>
    tackles + interceptions + clearances + blocks + aerialDuelsWon;

  /// Get defensive impact score (weighted metric)
  int get defensiveImpact =>
    tackles + (interceptions * 2) + clearances + (blocks * 2) + aerialDuelsWon;
}
