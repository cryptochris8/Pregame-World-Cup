/// Utility class for matching team names between API responses and user favorites
/// Handles both full team names and short API keys
class TeamMatchingHelper {
  
  /// SEC Team API Key Mappings - maps API short keys to searchable identifiers
  static const Map<String, List<String>> _secTeamKeyMappings = {
    'ala': ['alabama', 'crimson tide'],
    'aubrn': ['auburn', 'tigers'],
    'ark': ['arkansas', 'razorbacks'],
    'fl': ['florida', 'gators'],
    'ga': ['georgia', 'bulldogs'],
    'uk': ['kentucky', 'wildcats'],
    'lsu': ['lsu', 'tigers'],
    'mspst': ['mississippi state', 'bulldogs', 'miss state'],
    'missr': ['missouri', 'tigers'],
    'miss': ['ole miss', 'rebels', 'mississippi'],
    'sc': ['south carolina', 'gamecocks'],
    'tenn': ['tennessee', 'volunteers', 'vols'],
    'txam': ['texas a&m', 'aggies', 'tamu'],
    'vand': ['vanderbilt', 'commodores'],
  };

  /// Full team name mappings for additional flexibility
  /// Each team requires BOTH school name AND mascot to match to prevent false positives
  static const Map<String, List<String>> _teamNameMappings = {
    'alabama': ['alabama crimson tide', 'alabama', 'crimson tide'],
    'arkansas': ['arkansas razorbacks', 'arkansas', 'razorbacks'],
    'auburn': ['auburn tigers', 'auburn', 'tigers'],
    'florida': ['florida gators', 'florida', 'gators'],
    'georgia': ['georgia bulldogs', 'georgia', 'bulldogs'],
    'kentucky': ['kentucky wildcats', 'kentucky', 'wildcats'],
    'lsu': ['lsu tigers', 'lsu', 'tigers'],
    'mississippi state': ['mississippi state bulldogs', 'mississippi state', 'bulldogs', 'miss state'],
    'missouri': ['missouri tigers', 'missouri', 'tigers'],
    'oklahoma': ['oklahoma sooners', 'oklahoma', 'sooners'],
    'ole miss': ['ole miss rebels', 'ole miss', 'rebels', 'mississippi'],
    'south carolina': ['south carolina gamecocks', 'south carolina', 'gamecocks'],
    'tennessee': ['tennessee volunteers', 'tennessee', 'volunteers', 'vols'],
    'texas a&m': ['texas a&m aggies', 'texas a&m', 'aggies', 'tamu'],
    'texas': ['texas longhorns', 'texas', 'longhorns'],
    'vanderbilt': ['vanderbilt commodores', 'vanderbilt', 'commodores'],
  };

  /// Matches an API team name (could be short key or full name) against a favorite team name
  /// Returns true if they represent the same team
  static bool teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();
    
    // Direct match
    if (apiLower == favLower) return true;
    
    // Check if API team name is a short key that matches a favorite
    for (String key in _secTeamKeyMappings.keys) {
      if (apiLower == key) {
        final identifiers = _secTeamKeyMappings[key]!;
        bool favMatches = identifiers.any((id) => favLower.contains(id));
        if (favMatches) {
          return true;
        }
      }
    }
    
    // Check for key team identifiers (full team names)
    // Both names must match identifiers for the SAME team to avoid false matches
    for (String key in _teamNameMappings.keys) {
      final identifiers = _teamNameMappings[key]!;
      
      // For a match, we need either:
      // 1. Full team name match (first identifier is always the full name)
      // 2. School name match (second identifier) + some other confirmation
      
      final fullName = identifiers[0]; // e.g., "alabama crimson tide"
      final schoolName = identifiers[1]; // e.g., "alabama"
      
      // Check for full team name match first (most reliable)
      if (apiLower.contains(fullName) && favLower.contains(fullName)) {
        return true;
      }
      
      // Check if both contain the school name (primary identifier)
      if (apiLower.contains(schoolName) && favLower.contains(schoolName)) {
        // Additional validation to ensure it's really the same school
        // This prevents "Georgia" from matching "Georgia Southern" etc.
        bool apiIsExactSchoolMatch = _isExactSchoolMatch(apiLower, schoolName, identifiers);
        bool favIsExactSchoolMatch = _isExactSchoolMatch(favLower, schoolName, identifiers);
        
        if (apiIsExactSchoolMatch && favIsExactSchoolMatch) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// Check if a team name is in the favorites list using flexible matching
  static bool isTeamInFavorites(String teamName, List<String> favoriteTeams) {
    // Direct match first
    if (favoriteTeams.contains(teamName)) {
      return true;
    }
    
    // Flexible matching - check if any favorite team name contains the team name or vice versa
    for (String favoriteTeam in favoriteTeams) {
      if (teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }
    
    return false;
  }

  /// Helper method to validate that a school name match is exact and not a partial match
  static bool _isExactSchoolMatch(String teamName, String schoolName, List<String> identifiers) {
    // For very specific schools like "Georgia", ensure it's not "Georgia Southern", "Georgia Tech", etc.
    if (schoolName == 'georgia') {
      return !teamName.contains('georgia tech') && 
             !teamName.contains('georgia southern') && 
             !teamName.contains('georgia state');
    }
    
    // For "Texas", ensure it's not "Texas Tech", "Texas State", etc.
    if (schoolName == 'texas') {
      return !teamName.contains('texas tech') && 
             !teamName.contains('texas state') && 
             !teamName.contains('texas san antonio') &&
             !teamName.contains('texas el paso');
    }
    
    // For "Mississippi", ensure proper differentiation
    if (schoolName == 'mississippi state') {
      return teamName.contains('mississippi state') || teamName.contains('miss state');
    }
    
    // For other schools, check if mascot is also present (more confident match)
    if (identifiers.length > 2) {
      final mascot = identifiers[2]; // Third element is usually mascot
      return teamName.contains(mascot);
    }
    
    return true; // Default to allowing the match
  }

  /// Get the full team name from an API short key
  static String? getFullTeamName(String apiKey) {
    final keyLower = apiKey.toLowerCase();
    
    for (String key in _secTeamKeyMappings.keys) {
      if (keyLower == key) {
        final identifiers = _secTeamKeyMappings[key]!;
        // Return the first identifier which should be the school name
        return identifiers.first;
      }
    }
    
    return null; // Not a recognized SEC team key
  }
} 