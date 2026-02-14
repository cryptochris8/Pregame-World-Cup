/// Service to map team display names to SportsData.io API keys
class TeamMappingService {
  static final Map<String, String> _teamMapping = {
    // Legacy team mappings - to be replaced with World Cup 2026 teams
    'Alabama': 'ALA',
    'Alabama Crimson Tide': 'ALA',
    'Auburn': 'AUBRN',  // Updated from AUB to AUBRN
    'Auburn Tigers': 'AUBRN',
    'Georgia': 'GA',   // Updated from UGA to GA
    'Georgia Bulldogs': 'GA',
    'LSU': 'LSU',
    'LSU Tigers': 'LSU',
    'Mississippi': 'MISS',
    'Ole Miss': 'MISS',
    'Mississippi Rebels': 'MISS',
    'Mississippi State': 'MSPST',  // Updated from MSST to MSPST
    'Mississippi State Bulldogs': 'MSPST',
    'Florida': 'FL',   // Updated from FLA to FL
    'Florida Gators': 'FL',
    'Tennessee': 'TENN',
    'Tennessee Volunteers': 'TENN',
    'Kentucky': 'UK',
    'Kentucky Wildcats': 'UK',
    'South Carolina': 'SC',
    'South Carolina Gamecocks': 'SC',
    'Arkansas': 'ARK',
    'Arkansas Razorbacks': 'ARK',
    'Missouri': 'MISSR',  // Updated from MIZZ to MISSR
    'Missouri Tigers': 'MISSR',
    'Texas A&M': 'TXAM',  // Updated from TAM to TXAM
    'Texas A&M Aggies': 'TXAM',
    'Vanderbilt': 'VAND',  // Updated from VAN to VAND
    'Vanderbilt Commodores': 'VAND',
    
    // Big 12 Teams - Updated with correct SportsData.io keys
    'Texas': 'TEX',
    'Texas Longhorns': 'TEX',
    'Oklahoma': 'OU',     // Updated from OKLA to OU
    'Oklahoma Sooners': 'OU',
    'Oklahoma State': 'OKST',
    'Oklahoma State Cowboys': 'OKST',
    'Texas Tech': 'TTU',
    'Texas Tech Red Raiders': 'TTU',
    'Baylor': 'BAY',
    'Baylor Bears': 'BAY',
    'TCU': 'TCU',
    'TCU Horned Frogs': 'TCU',
    'Kansas': 'KU',
    'Kansas Jayhawks': 'KU',
    'Kansas State': 'KANST',  // Updated from KSU to KANST
    'Kansas State Wildcats': 'KANST',
    'Iowa State': 'IOWAST',  // Updated from ISU to IOWAST
    'Iowa State Cyclones': 'IOWAST',
    'West Virginia': 'WVU',
    'West Virginia Mountaineers': 'WVU',
    
    // Big Ten Teams
    'Ohio State': 'OSU',
    'Ohio State Buckeyes': 'OSU',
    'Michigan': 'MICH',
    'Michigan Wolverines': 'MICH',
    'Michigan State': 'MSU',
    'Michigan State Spartans': 'MSU',
    'Penn State': 'PSU',
    'Penn State Nittany Lions': 'PSU',
    'Wisconsin': 'WIS',
    'Wisconsin Badgers': 'WIS',
    'Iowa': 'IOWA',
    'Iowa Hawkeyes': 'IOWA',
    'Minnesota': 'MINN',
    'Minnesota Golden Gophers': 'MINN',
    'Illinois': 'ILL',
    'Illinois Fighting Illini': 'ILL',
    'Indiana': 'IND',
    'Indiana Hoosiers': 'IND',
    'Purdue': 'PUR',
    'Purdue Boilermakers': 'PUR',
    'Northwestern': 'NW',
    'Northwestern Wildcats': 'NW',
    'Nebraska': 'NEB',
    'Nebraska Cornhuskers': 'NEB',
    'Maryland': 'MD',
    'Maryland Terrapins': 'MD',
    'Rutgers': 'RU',
    'Rutgers Scarlet Knights': 'RU',
    
    // ACC Teams
    'Clemson': 'CLEM',
    'Clemson Tigers': 'CLEM',
    'Florida State': 'FSU',
    'Florida State Seminoles': 'FSU',
    'Miami': 'MIA',
    'Miami Hurricanes': 'MIA',
    'North Carolina': 'UNC',
    'North Carolina Tar Heels': 'UNC',
    'NC State': 'NCST',
    'NC State Wolfpack': 'NCST',
    'Duke': 'DUKE',
    'Duke Blue Devils': 'DUKE',
    'Wake Forest': 'WF',
    'Wake Forest Demon Deacons': 'WF',
    'Virginia': 'UVA',
    'Virginia Cavaliers': 'UVA',
    'Virginia Tech': 'VT',
    'Virginia Tech Hokies': 'VT',
    'Georgia Tech': 'GT',
    'Georgia Tech Yellow Jackets': 'GT',
    'Louisville': 'LOU',
    'Louisville Cardinals': 'LOU',
    'Pittsburgh': 'PITT',
    'Pittsburgh Panthers': 'PITT',
    'Syracuse': 'SYR',
    'Syracuse Orange': 'SYR',
    'Boston College': 'BC',
    'Boston College Eagles': 'BC',
    
    // Pac-12 Teams  
    'USC': 'USC',
    'USC Trojans': 'USC',
    'UCLA': 'UCLA',
    'UCLA Bruins': 'UCLA',
    'Oregon': 'ORE',
    'Oregon Ducks': 'ORE',
    'Oregon State': 'ORST',
    'Oregon State Beavers': 'ORST',
    'Washington': 'WASH',
    'Washington Huskies': 'WASH',
    'Washington State': 'WSU',
    'Washington State Cougars': 'WSU',
    'Stanford': 'STAN',
    'Stanford Cardinal': 'STAN',
    'California': 'CAL',
    'California Golden Bears': 'CAL',
    'Arizona': 'ARIZ',
    'Arizona Wildcats': 'ARIZ',
    'Arizona State': 'ASU',
    'Arizona State Sun Devils': 'ASU',
    'Colorado': 'COLO',
    'Colorado Buffaloes': 'COLO',
    'Utah': 'UTAH',
    'Utah Utes': 'UTAH',
    
    // Group of 5 and Independent Teams
    'Toledo': 'TOLEDO',
    'Toledo Rockets': 'TOLEDO',
    'UNLV': 'UNLV',
    'UNLV Rebels': 'UNLV',
    'Idaho State': 'IDSU',
    'Idaho State Bengals': 'IDSU',
    'Fresno State': 'FRES',
    'Fresno State Bulldogs': 'FRES',
    'Marshall': 'MARSH',
    'Marshall Thundering Herd': 'MARSH',
    'Florida State': 'FLST',
    'Florida State Seminoles': 'FLST',
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
    
    // Try partial matches (remove common suffixes)
    final cleanName = displayName
        .replaceAll(RegExp(r'\s+(Tigers?|Bulldogs?|Eagles?|Cardinals?|Panthers?|Bears?|Wildcats?|Spartans?|Buckeyes?|Wolverines?|Nittany\s+Lions?|Badgers?|Hawkeyes?|Fighting\s+Illini|Hoosiers?|Boilermakers?|Cornhuskers?|Terrapins?|Scarlet\s+Knights?|Seminoles?|Hurricanes?|Tar\s+Heels?|Wolfpack|Blue\s+Devils?|Demon\s+Deacons?|Cavaliers?|Hokies?|Yellow\s+Jackets?|Trojans?|Bruins?|Ducks?|Beavers?|Huskies?|Cougars?|Cardinal|Golden\s+Bears?|Sun\s+Devils?|Buffaloes?|Utes?|Crimson\s+Tide|Razorbacks?|Aggies?|Commodores?|Longhorns?|Sooners?|Cowboys?|Red\s+Raiders?|Horned\s+Frogs?|Jayhawks?|Cyclones?|Mountaineers?|Golden\s+Gophers?|Gamecocks?|Volunteers?|Rebels?)$', caseSensitive: false), '')
        .trim();
    
    for (final entry in _teamMapping.entries) {
      if (entry.key.toLowerCase().contains(cleanName.toLowerCase()) && cleanName.length > 3) {
        return entry.value;
      }
    }
    
    // If no match found, return the original name
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