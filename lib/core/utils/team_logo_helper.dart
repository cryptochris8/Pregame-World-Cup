import 'package:flutter/material.dart';

/// Helper class for managing SEC team logos
class TeamLogoHelper {
  // Map of team names (case-insensitive) to their logo asset paths
  // All 16 SEC Teams (2025 season)
  static const Map<String, String> _teamLogoMap = {
    // 1. Alabama Crimson Tide
    'alabama': 'assets/logos/alabama_crimson_tide.png',
    'alabama crimson tide': 'assets/logos/alabama_crimson_tide.png',
    'crimson tide': 'assets/logos/alabama_crimson_tide.png',
    'bama': 'assets/logos/alabama_crimson_tide.png',
    'ala': 'assets/logos/alabama_crimson_tide.png',
    
    // 2. Arkansas Razorbacks  
    'arkansas': 'assets/logos/arkansas_razorbacks.png',
    'arkansas razorbacks': 'assets/logos/arkansas_razorbacks.png',
    'razorbacks': 'assets/logos/arkansas_razorbacks.png',
    'ark': 'assets/logos/arkansas_razorbacks.png',
    'arks': 'assets/logos/arkansas_razorbacks.png',
    
    // 3. Auburn Tigers
    'auburn': 'assets/logos/auburn_tigers.png',
    'auburn tigers': 'assets/logos/auburn_tigers.png',
    'aubrn': 'assets/logos/auburn_tigers.png',
    'aub': 'assets/logos/auburn_tigers.png',
    
    // 4. Florida Gators
    'florida': 'assets/logos/florida_gators.png',
    'florida gators': 'assets/logos/florida_gators.png',
    'gators': 'assets/logos/florida_gators.png',
    'uf': 'assets/logos/florida_gators.png',
    'fla': 'assets/logos/florida_gators.png',
    'flor': 'assets/logos/florida_gators.png',
    
    // 5. Georgia Bulldogs
    'georgia': 'assets/logos/georgia_bulldogs.png',
    'georgia bulldogs': 'assets/logos/georgia_bulldogs.png',
    'bulldogs': 'assets/logos/georgia_bulldogs.png',
    'uga': 'assets/logos/georgia_bulldogs.png',
    'ga': 'assets/logos/georgia_bulldogs.png',
    'geo': 'assets/logos/georgia_bulldogs.png',
    'geor': 'assets/logos/georgia_bulldogs.png',
    
    // 6. Kentucky Wildcats
    'kentucky': 'assets/logos/kentucky_wildcats.png',
    'kentucky wildcats': 'assets/logos/kentucky_wildcats.png',
    'wildcats': 'assets/logos/kentucky_wildcats.png',
    'uk': 'assets/logos/kentucky_wildcats.png',
    'ky': 'assets/logos/kentucky_wildcats.png',
    'kent': 'assets/logos/kentucky_wildcats.png',
    
    // 7. LSU Tigers
    'lsu': 'assets/logos/lsu_tigers.png',
    'lsu tigers': 'assets/logos/lsu_tigers.png',
    'louisiana state': 'assets/logos/lsu_tigers.png',
    'louisiana state university': 'assets/logos/lsu_tigers.png',
    'tigers': 'assets/logos/lsu_tigers.png',
    
    // 8. Mississippi State Bulldogs
    'mississippi state': 'assets/logos/mississipi_state.png',
    'miss state': 'assets/logos/mississipi_state.png',
    'mississippi st': 'assets/logos/mississipi_state.png',
    'msu': 'assets/logos/mississipi_state.png',
    'state bulldogs': 'assets/logos/mississipi_state.png',
    'mspst': 'assets/logos/mississipi_state.png',
    'msst': 'assets/logos/mississipi_state.png',
    'misST': 'assets/logos/mississipi_state.png',
    'mississippi state bulldogs': 'assets/logos/mississipi_state.png',
    
    // 9. Missouri Tigers
    'missouri': 'assets/logos/missouri_tigers.png',
    'missouri tigers': 'assets/logos/missouri_tigers.png',
    'mizzou': 'assets/logos/missouri_tigers.png',
    'missr': 'assets/logos/missouri_tigers.png',
    'miz': 'assets/logos/missouri_tigers.png',
    'mizz': 'assets/logos/missouri_tigers.png',
    'mo': 'assets/logos/missouri_tigers.png',
    
    // 10. Ole Miss Rebels
    'ole miss': 'assets/logos/ole_miss_rebels.png',
    'ole miss rebels': 'assets/logos/ole_miss_rebels.png',
    'mississippi rebels': 'assets/logos/ole_miss_rebels.png',
    'rebels': 'assets/logos/ole_miss_rebels.png',
    'miss': 'assets/logos/ole_miss_rebels.png',
    'olms': 'assets/logos/ole_miss_rebels.png',
    'mississippi': 'assets/logos/ole_miss_rebels.png',
    
    // 11. Oklahoma Sooners (New 2025)
    'oklahoma': 'assets/logos/oklahoma-sooners.png',
    'oklahoma sooners': 'assets/logos/oklahoma-sooners.png',
    'sooners': 'assets/logos/oklahoma-sooners.png',
    'ou': 'assets/logos/oklahoma-sooners.png',
    'okla': 'assets/logos/oklahoma-sooners.png',
    'oklhm': 'assets/logos/oklahoma-sooners.png',
    
    // 12. South Carolina Gamecocks
    'south carolina': 'assets/logos/south_carolina_gamecocks.png',
    'south carolina gamecocks': 'assets/logos/south_carolina_gamecocks.png',
    'gamecocks': 'assets/logos/south_carolina_gamecocks.png',
    'usc': 'assets/logos/south_carolina_gamecocks.png',
    'sc': 'assets/logos/south_carolina_gamecocks.png',
    'scar': 'assets/logos/south_carolina_gamecocks.png',
    'scst': 'assets/logos/south_carolina_gamecocks.png',
    
    // 13. Tennessee Volunteers
    'tennessee': 'assets/logos/tennessee_vols.png',
    'tennessee volunteers': 'assets/logos/tennessee_vols.png',
    'tennessee vols': 'assets/logos/tennessee_vols.png',
    'vols': 'assets/logos/tennessee_vols.png',
    'volunteers': 'assets/logos/tennessee_vols.png',
    'tenn': 'assets/logos/tennessee_vols.png',
    'tn': 'assets/logos/tennessee_vols.png',
    'ten': 'assets/logos/tennessee_vols.png',
    
    // 14. Texas Longhorns (New 2025)
    'texas': 'assets/logos/texas_longhonerns.png',
    'texas longhorns': 'assets/logos/texas_longhonerns.png',
    'longhorns': 'assets/logos/texas_longhonerns.png',
    'ut': 'assets/logos/texas_longhonerns.png',
    'tex': 'assets/logos/texas_longhonerns.png',
    'txs': 'assets/logos/texas_longhonerns.png',
    'horns': 'assets/logos/texas_longhonerns.png',
    
    // 15. Texas A&M Aggies
    'texas a&m': 'assets/logos/texas_a&m_aggies.png',
    'texas a&m aggies': 'assets/logos/texas_a&m_aggies.png',
    'tamu': 'assets/logos/texas_a&m_aggies.png',
    'aggies': 'assets/logos/texas_a&m_aggies.png',
    'texas am': 'assets/logos/texas_a&m_aggies.png',
    'txam': 'assets/logos/texas_a&m_aggies.png',
    'tam': 'assets/logos/texas_a&m_aggies.png',
    'a&m': 'assets/logos/texas_a&m_aggies.png',
    
    // 16. Vanderbilt Commodores
    'vanderbilt': 'assets/logos/vanderbilt_commodores.png',
    'vanderbilt commodores': 'assets/logos/vanderbilt_commodores.png',
    'commodores': 'assets/logos/vanderbilt_commodores.png',
    'vandy': 'assets/logos/vanderbilt_commodores.png',
    'vand': 'assets/logos/vanderbilt_commodores.png',
    'vandb': 'assets/logos/vanderbilt_commodores.png',
    'dores': 'assets/logos/vanderbilt_commodores.png',
  };

  /// Get the logo asset path for a team name
  /// Returns null if team is not found
  static String? getTeamLogoPath(String? teamName) {
    if (teamName == null || teamName.isEmpty) return null;
    
    final cleanName = teamName.toLowerCase().trim();
    
    // Only do exact matches to avoid incorrect mappings
    if (_teamLogoMap.containsKey(cleanName)) {
      return _teamLogoMap[cleanName];
    }
    
    return null;
  }

  /// Get a widget displaying the team logo
  /// Falls back to a football icon if logo is not found (non-SEC teams)
  static Widget getTeamLogoWidget({
    required String? teamName,
    double size = 24,
    Color? fallbackColor,
  }) {
    final logoPath = getTeamLogoPath(teamName);
    
    if (logoPath != null) {
      return Image.asset(
        logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sports_football,
            size: size,
            color: fallbackColor ?? Colors.orange,
          );
        },
      );
    }
    
    // No SEC logo found - show football icon for non-SEC teams
    return Icon(
      Icons.sports_football,
      size: size,
      color: fallbackColor ?? Colors.orange,
    );
  }

  /// Get the pregame app logo widget
  static Widget getPregameLogo({double height = 32}) {
    return Image.asset(
      'assets/logos/pregame_logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.sports_football,
          size: height,
          color: Colors.orange,
        );
      },
    );
  }

  /// Check if a team has a logo available (SEC teams only)
  static bool hasTeamLogo(String? teamName) {
    return getTeamLogoPath(teamName) != null;
  }

  /// Get all available SEC team names that have logos
  static List<String> getAvailableTeams() {
    return _teamLogoMap.keys.toList();
  }
} 