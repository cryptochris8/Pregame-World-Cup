import '../../domain/entities/game_schedule.dart';

/// Utility for matching team names against a list of user favorites.
///
/// Handles flexible matching for international team names,
/// common aliases, and nicknames.
class TeamNameMatcher {
  TeamNameMatcher._();

  /// Whether the [game] involves any team from [favoriteTeams].
  static bool isFavoriteTeamGame(GameSchedule game, List<String> favoriteTeams) {
    return isTeamInFavorites(game.homeTeamName, favoriteTeams) ||
           isTeamInFavorites(game.awayTeamName, favoriteTeams);
  }

  /// Whether [teamName] matches any entry in [favorites].
  static bool isTeamInFavorites(String teamName, List<String> favorites) {
    // Direct match first
    if (favorites.contains(teamName)) {
      return true;
    }

    // Flexible matching
    for (String favoriteTeam in favorites) {
      if (teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }

    return false;
  }

  /// Flexible team name matching that handles aliases and nicknames.
  static bool teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();

    // Direct match
    if (apiLower == favLower) return true;

    // Check for key team identifiers
    const teamMappings = {
      'united states': ['united states', 'usa', 'usmnt', 'stars and stripes'],
      'mexico': ['mexico', 'el tri', 'tricolor'],
      'brazil': ['brazil', 'selecao', 'canarinha'],
      'argentina': ['argentina', 'albiceleste'],
      'france': ['france', 'les bleus'],
      'germany': ['germany', 'die mannschaft'],
      'spain': ['spain', 'la roja'],
      'england': ['england', 'three lions'],
      'portugal': ['portugal'],
      'netherlands': ['netherlands', 'holland', 'oranje'],
      'italy': ['italy', 'azzurri'],
      'japan': ['japan', 'samurai blue'],
      'south korea': ['south korea', 'korea republic', 'taegeuk warriors'],
      'morocco': ['morocco', 'atlas lions'],
      'canada': ['canada', 'canmnt'],
      'croatia': ['croatia', 'vatreni'],
    };

    for (String key in teamMappings.keys) {
      final identifiers = teamMappings[key]!;
      bool apiMatches = identifiers.any((id) => apiLower.contains(id));
      bool favMatches = identifiers.any((id) => favLower.contains(id));

      if (apiMatches && favMatches) {
        return true;
      }
    }

    return false;
  }
}
