/// Service to map team display names to SportsData.io API keys
/// Maps FIFA World Cup 2026 national team names to their API identifiers
class TeamMappingService {
  static final Map<String, String> _teamMapping = {
    // Group A
    'United States': 'USA',
    'USA': 'USA',
    'USMNT': 'USA',

    // Group stage teams - CONCACAF
    'Mexico': 'MEX',
    'Canada': 'CAN',
    'Costa Rica': 'CRC',
    'Jamaica': 'JAM',
    'Honduras': 'HON',
    'Panama': 'PAN',
    'El Salvador': 'SLV',
    'Trinidad and Tobago': 'TRI',

    // CONMEBOL
    'Brazil': 'BRA',
    'Argentina': 'ARG',
    'Uruguay': 'URU',
    'Colombia': 'COL',
    'Ecuador': 'ECU',
    'Chile': 'CHI',
    'Paraguay': 'PAR',
    'Peru': 'PER',
    'Venezuela': 'VEN',
    'Bolivia': 'BOL',

    // UEFA
    'France': 'FRA',
    'Germany': 'GER',
    'Spain': 'ESP',
    'England': 'ENG',
    'Portugal': 'POR',
    'Netherlands': 'NED',
    'Belgium': 'BEL',
    'Italy': 'ITA',
    'Croatia': 'CRO',
    'Switzerland': 'SUI',
    'Denmark': 'DEN',
    'Austria': 'AUT',
    'Serbia': 'SRB',
    'Scotland': 'SCO',
    'Wales': 'WAL',
    'Poland': 'POL',
    'Ukraine': 'UKR',
    'Sweden': 'SWE',
    'Czech Republic': 'CZE',
    'Turkey': 'TUR',
    'Hungary': 'HUN',
    'Slovakia': 'SVK',
    'Romania': 'ROU',
    'Norway': 'NOR',
    'Finland': 'FIN',
    'Iceland': 'ISL',
    'Greece': 'GRE',
    'Ireland': 'IRL',

    // AFC
    'Japan': 'JPN',
    'South Korea': 'KOR',
    'Korea Republic': 'KOR',
    'Australia': 'AUS',
    'Iran': 'IRN',
    'Saudi Arabia': 'KSA',
    'Qatar': 'QAT',
    'Iraq': 'IRQ',
    'Uzbekistan': 'UZB',
    'China': 'CHN',
    'China PR': 'CHN',
    'United Arab Emirates': 'UAE',

    // CAF
    'Morocco': 'MAR',
    'Senegal': 'SEN',
    'Nigeria': 'NGA',
    'Cameroon': 'CMR',
    'Ghana': 'GHA',
    'Egypt': 'EGY',
    'Tunisia': 'TUN',
    'Algeria': 'ALG',
    'Ivory Coast': 'CIV',
    'Cote d\'Ivoire': 'CIV',
    'Mali': 'MLI',
    'South Africa': 'RSA',
    'DR Congo': 'COD',

    // OFC
    'New Zealand': 'NZL',

    // Common nickname/alias mappings
    'La Albiceleste': 'ARG',
    'Die Mannschaft': 'GER',
    'Les Bleus': 'FRA',
    'Selecao': 'BRA',
    'La Roja': 'ESP',
    'Three Lions': 'ENG',
    'Azzurri': 'ITA',
    'Oranje': 'NED',
    'El Tri': 'MEX',
    'Samurai Blue': 'JPN',
    'Socceroos': 'AUS',
    'Atlas Lions': 'MAR',
    'Super Eagles': 'NGA',
    'Indomitable Lions': 'CMR',
    'Black Stars': 'GHA',
    'Lions of Teranga': 'SEN',
    'Vatreni': 'CRO',
    'La Celeste': 'URU',
    'Los Cafeteros': 'COL',
    'Taegeuk Warriors': 'KOR',
    'Team Melli': 'IRN',
    'Green Falcons': 'KSA',
  };

  /// Convert team display name to SportsData.io API key
  static String getTeamKey(String displayName) {
    // Try exact match first
    if (_teamMapping.containsKey(displayName)) {
      return _teamMapping[displayName]!;
    }

    // Try case-insensitive match
    final lowerName = displayName.toLowerCase();
    for (final entry in _teamMapping.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }

    // Try partial matches
    final cleanName = displayName.trim();

    for (final entry in _teamMapping.entries) {
      if (entry.key.toLowerCase().contains(cleanName.toLowerCase()) && cleanName.length > 3) {
        return entry.value;
      }
    }

    // If no match found, return the original name as uppercase code
    return displayName.toUpperCase().replaceAll(' ', '');
  }

  /// Get all available team mappings
  static Map<String, String> getAllMappings() => Map.from(_teamMapping);

  /// Check if a team is supported
  static bool isTeamSupported(String displayName) {
    return _teamMapping.containsKey(displayName) ||
           _teamMapping.keys.any((key) => key.toLowerCase() == displayName.toLowerCase());
  }

  /// Get display name from team key
  static String? getDisplayName(String teamKey) {
    for (final entry in _teamMapping.entries) {
      if (entry.value == teamKey) {
        return entry.key;
      }
    }
    return null;
  }
}
