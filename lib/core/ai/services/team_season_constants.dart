/// Shared constants for team season analysis services.
/// FIFA confederation mappings, elite national team lists, and team name variation data.
class TeamSeasonConstants {
  TeamSeasonConstants._();

  /// FIFA confederation mappings for analysis and classification
  static const Map<String, List<String>> conferences = {
    'UEFA': [
      'France', 'Germany', 'Spain', 'England', 'Portugal', 'Netherlands',
      'Belgium', 'Italy', 'Croatia', 'Switzerland', 'Denmark', 'Austria',
      'Serbia', 'Scotland', 'Wales', 'Poland', 'Ukraine', 'Sweden',
      'Czech Republic', 'Turkey', 'Hungary', 'Slovakia', 'Romania',
      'Norway', 'Finland', 'Iceland', 'Greece', 'Ireland',
    ],
    'CONMEBOL': [
      'Brazil', 'Argentina', 'Uruguay', 'Colombia', 'Ecuador',
      'Chile', 'Paraguay', 'Peru', 'Venezuela', 'Bolivia',
    ],
    'CONCACAF': [
      'United States', 'Mexico', 'Canada', 'Costa Rica', 'Jamaica',
      'Honduras', 'Panama', 'El Salvador', 'Trinidad and Tobago', 'Guatemala',
    ],
    'AFC': [
      'Japan', 'South Korea', 'Australia', 'Iran', 'Saudi Arabia',
      'Qatar', 'Iraq', 'Uzbekistan', 'China', 'Bahrain',
      'United Arab Emirates', 'Oman', 'Jordan', 'Vietnam', 'Thailand',
    ],
    'CAF': [
      'Morocco', 'Senegal', 'Nigeria', 'Cameroon', 'Ghana',
      'Egypt', 'Tunisia', 'Algeria', 'Ivory Coast', 'Mali',
      'South Africa', 'DR Congo', 'Burkina Faso', 'Guinea',
    ],
    'OFC': [
      'New Zealand', 'Solomon Islands', 'Tahiti', 'Fiji',
      'Papua New Guinea', 'New Caledonia', 'Vanuatu', 'Samoa',
    ],
  };

  /// Elite national teams used for significance scoring
  static const List<String> elitePrograms = [
    'Brazil', 'Germany', 'France', 'Argentina', 'Spain',
    'England', 'Italy', 'Netherlands', 'Portugal', 'Uruguay',
    'Belgium', 'Croatia', 'Morocco', 'Japan', 'United States',
    'Mexico', 'Colombia', 'Senegal',
  ];

  /// Common team name variations for fuzzy matching
  static const Map<String, List<String>> commonVariations = {
    'Argentina': ['La Albiceleste', 'ARG', 'Albicelestes'],
    'Germany': ['Die Mannschaft', 'GER', 'Deutschland'],
    'France': ['Les Bleus', 'FRA', 'L\'Equipe de France'],
    'Brazil': ['Seleção', 'Selecao', 'BRA', 'A Canarinha', 'Canarinho'],
    'Spain': ['La Roja', 'ESP', 'La Furia Roja'],
    'England': ['Three Lions', 'ENG', 'The Three Lions'],
    'Italy': ['Gli Azzurri', 'Azzurri', 'ITA'],
    'Netherlands': ['Oranje', 'Holland', 'NED', 'The Flying Dutchmen'],
    'Portugal': ['A Seleção', 'POR', 'Selecção das Quinas'],
    'Uruguay': ['La Celeste', 'URU', 'Los Charrúas'],
    'Belgium': ['Red Devils', 'BEL', 'Rode Duivels', 'Les Diables Rouges'],
    'Croatia': ['Vatreni', 'CRO', 'The Blazers'],
    'Morocco': ['Atlas Lions', 'MAR', 'Les Lions de l\'Atlas'],
    'Japan': ['Samurai Blue', 'JPN', 'Blue Samurai'],
    'South Korea': ['Taegeuk Warriors', 'KOR', 'Korea Republic'],
    'United States': ['USMNT', 'USA', 'Stars and Stripes', 'US', 'Yanks'],
    'Mexico': ['El Tri', 'MEX', 'El Tricolor'],
    'Colombia': ['Los Cafeteros', 'COL', 'Tricolor'],
    'Senegal': ['Lions of Teranga', 'SEN', 'Les Lions'],
    'Nigeria': ['Super Eagles', 'NGA'],
    'Cameroon': ['Indomitable Lions', 'CMR', 'Les Lions Indomptables'],
    'Ghana': ['Black Stars', 'GHA'],
    'Australia': ['Socceroos', 'AUS'],
    'Canada': ['Les Rouges', 'CAN', 'CanMNT'],
    'Costa Rica': ['Los Ticos', 'CRC'],
    'Ecuador': ['La Tri', 'ECU', 'La Tricolor'],
    'Switzerland': ['Nati', 'SUI', 'La Nati'],
    'Denmark': ['Danish Dynamite', 'DEN'],
    'Serbia': ['Orlovi', 'SRB', 'The Eagles'],
    'Saudi Arabia': ['The Green Falcons', 'KSA', 'Al-Suqour Al-Khodhr'],
    'Iran': ['Team Melli', 'IRN'],
    'Tunisia': ['Eagles of Carthage', 'TUN', 'Les Aigles de Carthage'],
    'Qatar': ['The Maroons', 'QAT', 'Al-Annabi'],
  };

  /// Look up a team's confederation
  static String getTeamConference(String teamName) {
    for (final entry in conferences.entries) {
      if (entry.value.contains(teamName)) {
        return entry.key;
      }
    }
    return 'Independent';
  }

  /// Check if a team is considered an elite national team
  static bool isEliteProgram(String teamName) {
    return elitePrograms.contains(teamName);
  }
}
