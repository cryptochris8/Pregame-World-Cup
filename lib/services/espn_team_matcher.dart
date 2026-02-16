/// Handles international team name matching, normalization, and rivalry detection
/// for FIFA World Cup soccer matches.
class ESPNTeamMatcher {
  /// Major World Cup rivalries and historic derby matches
  static const List<Set<String>> _rivalries = [
    {'brazil', 'argentina'},
    {'germany', 'netherlands'},
    {'germany', 'england'},
    {'germany', 'italy'},
    {'england', 'argentina'},
    {'brazil', 'germany'},
    {'brazil', 'france'},
    {'france', 'italy'},
    {'france', 'germany'},
    {'spain', 'portugal'},
    {'spain', 'italy'},
    {'mexico', 'united states'},
    {'mexico', 'usa'},
    {'united states', 'england'},
    {'usa', 'england'},
    {'south korea', 'japan'},
    {'uruguay', 'argentina'},
    {'colombia', 'argentina'},
    {'brazil', 'uruguay'},
    {'chile', 'argentina'},
    {'ghana', 'uruguay'},
    {'croatia', 'serbia'},
    {'netherlands', 'belgium'},
    {'england', 'scotland'},
    {'cameroon', 'nigeria'},
    {'egypt', 'algeria'},
    {'iran', 'iraq'},
    {'australia', 'japan'},
    {'costa rica', 'mexico'},
    {'canada', 'united states'},
    {'canada', 'usa'},
  ];

  /// Common international team name abbreviations and variations
  static const Map<String, String> _abbreviations = {
    'united states': 'usa',
    'united states of america': 'usa',
    'korea republic': 'south korea',
    'republic of korea': 'south korea',
    'ir iran': 'iran',
    'islamic republic of iran': 'iran',
    'cote divoire': 'ivory coast',
    'congo dr': 'dr congo',
    'democratic republic of the congo': 'dr congo',
    'czech republic': 'czechia',
    'kingdom of saudi arabia': 'saudi arabia',
    'peoples republic of china': 'china',
    'china pr': 'china',
    'chinese taipei': 'taiwan',
    'bosnia and herzegovina': 'bosnia',
    'trinidad and tobago': 'trinidad',
    'antigua and barbuda': 'antigua',
    'saint kitts and nevis': 'st kitts',
    'new zealand': 'all whites',
    'costa rica': 'los ticos',
    'el salvador': 'la selecta',
  };

  /// Check if this is a major international soccer rivalry
  bool isRivalryGame(String homeTeam, String awayTeam) {
    final home = normalizeTeamName(homeTeam);
    final away = normalizeTeamName(awayTeam);

    for (final rivalry in _rivalries) {
      final team1 = rivalry.first;
      final team2 = rivalry.last;
      if ((home.contains(team1) && away.contains(team2)) ||
          (home.contains(team2) && away.contains(team1))) {
        return true;
      }
    }

    return false;
  }

  /// Check if team names match (handles common international variations).
  /// Supports international team name variations (e.g., "USA" vs "United States").
  bool teamsMatch(String team1, String team2) {
    if (team1.isEmpty || team2.isEmpty) return false;

    final normalized1 = normalizeTeamName(team1);
    final normalized2 = normalizeTeamName(team2);

    // Exact match
    if (normalized1 == normalized2) return true;

    // Check if one contains the other
    if (normalized1.contains(normalized2) || normalized2.contains(normalized1)) return true;

    // Check common international team name variations
    for (final entry in _abbreviations.entries) {
      if ((normalized1.contains(entry.key) && normalized2.contains(entry.value)) ||
          (normalized1.contains(entry.value) && normalized2.contains(entry.key))) {
        return true;
      }
    }

    return false;
  }

  /// Normalize team name for matching
  String normalizeTeamName(String teamName) {
    return teamName.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ')     // Normalize whitespace
        .trim();
  }
}
