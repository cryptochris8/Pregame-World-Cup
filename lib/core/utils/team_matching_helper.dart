/// Utility class for matching team names between API responses and user favorites.
///
/// For World Cup 2026 the favorite team names are full country names
/// (e.g., "United States", "Brazil"). This helper handles common aliases,
/// short FIFA codes, and case-insensitive matching so that schedule data
/// from various sources can be reliably compared against the user's list.
class TeamMatchingHelper {

  /// Maps lowercase aliases/codes to the canonical country name used in favorites.
  static const Map<String, String> _aliasToCanonical = {
    // CONCACAF
    'usa': 'United States',
    'united states': 'United States',
    'us': 'United States',
    'usmnt': 'United States',
    'mexico': 'Mexico',
    'mex': 'Mexico',
    'el tri': 'Mexico',
    'canada': 'Canada',
    'can': 'Canada',
    'costa rica': 'Costa Rica',
    'crc': 'Costa Rica',
    'honduras': 'Honduras',
    'hon': 'Honduras',
    'jamaica': 'Jamaica',
    'jam': 'Jamaica',
    'panama': 'Panama',
    'pan': 'Panama',

    // CONMEBOL
    'argentina': 'Argentina',
    'arg': 'Argentina',
    'la albiceleste': 'Argentina',
    'bolivia': 'Bolivia',
    'bol': 'Bolivia',
    'brazil': 'Brazil',
    'bra': 'Brazil',
    'brasil': 'Brazil',
    'chile': 'Chile',
    'chi': 'Chile',
    'colombia': 'Colombia',
    'col': 'Colombia',
    'ecuador': 'Ecuador',
    'ecu': 'Ecuador',
    'paraguay': 'Paraguay',
    'par': 'Paraguay',
    'peru': 'Peru',
    'per': 'Peru',
    'uruguay': 'Uruguay',
    'uru': 'Uruguay',
    'venezuela': 'Venezuela',
    'ven': 'Venezuela',

    // UEFA
    'albania': 'Albania',
    'alb': 'Albania',
    'austria': 'Austria',
    'aut': 'Austria',
    'belgium': 'Belgium',
    'bel': 'Belgium',
    'croatia': 'Croatia',
    'cro': 'Croatia',
    'denmark': 'Denmark',
    'den': 'Denmark',
    'england': 'England',
    'eng': 'England',
    'france': 'France',
    'fra': 'France',
    'germany': 'Germany',
    'ger': 'Germany',
    'netherlands': 'Netherlands',
    'ned': 'Netherlands',
    'holland': 'Netherlands',
    'poland': 'Poland',
    'pol': 'Poland',
    'portugal': 'Portugal',
    'por': 'Portugal',
    'scotland': 'Scotland',
    'sco': 'Scotland',
    'serbia': 'Serbia',
    'srb': 'Serbia',
    'spain': 'Spain',
    'esp': 'Spain',
    'switzerland': 'Switzerland',
    'sui': 'Switzerland',
    'turkey': 'Turkey',
    'tur': 'Turkey',
    'turkiye': 'Turkey',
    'ukraine': 'Ukraine',
    'ukr': 'Ukraine',
    'wales': 'Wales',
    'wal': 'Wales',

    // AFC
    'australia': 'Australia',
    'aus': 'Australia',
    'iran': 'Iran',
    'irn': 'Iran',
    'ir iran': 'Iran',
    'iraq': 'Iraq',
    'irq': 'Iraq',
    'japan': 'Japan',
    'jpn': 'Japan',
    'saudi arabia': 'Saudi Arabia',
    'ksa': 'Saudi Arabia',
    'south korea': 'South Korea',
    'kor': 'South Korea',
    'korea republic': 'South Korea',
    'korea': 'South Korea',
    'qatar': 'Qatar',
    'qat': 'Qatar',
    'uzbekistan': 'Uzbekistan',
    'uzb': 'Uzbekistan',

    // CAF
    'cameroon': 'Cameroon',
    'cmr': 'Cameroon',
    'egypt': 'Egypt',
    'egy': 'Egypt',
    'morocco': 'Morocco',
    'mar': 'Morocco',
    'nigeria': 'Nigeria',
    'nga': 'Nigeria',
    'senegal': 'Senegal',
    'sen': 'Senegal',

    // OFC
    'new zealand': 'New Zealand',
    'nzl': 'New Zealand',
  };

  /// Returns true if [apiTeamName] and [favoriteTeamName] refer to the same team.
  static bool teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase().trim();
    final favLower = favoriteTeamName.toLowerCase().trim();

    // Direct match
    if (apiLower == favLower) return true;

    // Resolve both sides to canonical names and compare
    final apiCanonical = _aliasToCanonical[apiLower];
    final favCanonical = _aliasToCanonical[favLower];

    if (apiCanonical != null && favCanonical != null) {
      return apiCanonical == favCanonical;
    }

    // One side resolved, compare with the other's raw value
    if (apiCanonical != null) {
      return apiCanonical.toLowerCase() == favLower;
    }
    if (favCanonical != null) {
      return favCanonical.toLowerCase() == apiLower;
    }

    // Substring containment as last resort (e.g., "Korea Republic" contains "Korea")
    if (apiLower.contains(favLower) || favLower.contains(apiLower)) {
      return true;
    }

    return false;
  }

  /// Check if [teamName] is in the [favoriteTeams] list using flexible matching.
  static bool isTeamInFavorites(String teamName, List<String> favoriteTeams) {
    // Fast exact match first
    if (favoriteTeams.contains(teamName)) return true;

    for (final favoriteTeam in favoriteTeams) {
      if (teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }

    return false;
  }

  /// Get the canonical team name from an API key or alias.
  /// Returns null if not recognized.
  static String? getFullTeamName(String apiKey) {
    return _aliasToCanonical[apiKey.toLowerCase().trim()];
  }
}
