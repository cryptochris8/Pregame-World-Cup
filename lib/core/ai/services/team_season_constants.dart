/// Shared constants for team season analysis services.
/// Conference mappings, elite program lists, and team name variation data.
class TeamSeasonConstants {
  TeamSeasonConstants._();

  /// Conference mappings for analysis and classification
  static const Map<String, List<String>> conferences = {
    'SEC': ['Alabama Crimson Tide', 'Auburn Tigers', 'Georgia Bulldogs', 'LSU Tigers', 'Tennessee Volunteers', 'Florida Gators', 'Kentucky Wildcats', 'Mississippi State Bulldogs', 'Ole Miss Rebels', 'Arkansas Razorbacks', 'South Carolina Gamecocks', 'Vanderbilt Commodores', 'Missouri Tigers', 'Texas A&M Aggies'],
    'Big Ten': ['Ohio State Buckeyes', 'Michigan Wolverines', 'Penn State Nittany Lions', 'Wisconsin Badgers', 'Iowa Hawkeyes', 'Minnesota Golden Gophers', 'Illinois Fighting Illini', 'Northwestern Wildcats', 'Indiana Hoosiers', 'Michigan State Spartans', 'Purdue Boilermakers', 'Nebraska Cornhuskers', 'Maryland Terrapins', 'Rutgers Scarlet Knights'],
    'Big 12': ['Oklahoma Sooners', 'Texas Longhorns', 'Kansas State Wildcats', 'Oklahoma State Cowboys', 'Baylor Bears', 'TCU Horned Frogs', 'West Virginia Mountaineers', 'Iowa State Cyclones', 'Kansas Jayhawks', 'Texas Tech Red Raiders'],
    'ACC': ['Clemson Tigers', 'Florida State Seminoles', 'Miami Hurricanes', 'North Carolina Tar Heels', 'NC State Wolfpack', 'Virginia Tech Hokies', 'Virginia Cavaliers', 'Duke Blue Devils', 'Wake Forest Demon Deacons', 'Georgia Tech Yellow Jackets', 'Boston College Eagles', 'Syracuse Orange', 'Pittsburgh Panthers', 'Louisville Cardinals'],
    'Pac-12': ['USC Trojans', 'UCLA Bruins', 'Oregon Ducks', 'Washington Huskies', 'Stanford Cardinal', 'California Golden Bears', 'Oregon State Beavers', 'Washington State Cougars', 'Arizona State Sun Devils', 'Arizona Wildcats', 'Utah Utes', 'Colorado Buffaloes'],
  };

  /// Elite programs used for significance scoring
  static const List<String> elitePrograms = [
    'Alabama Crimson Tide', 'Georgia Bulldogs', 'Ohio State Buckeyes', 'Michigan Wolverines',
    'Clemson Tigers', 'Oklahoma Sooners', 'Texas Longhorns', 'USC Trojans', 'Oregon Ducks',
    'Penn State Nittany Lions', 'Florida State Seminoles', 'LSU Tigers', 'Auburn Tigers',
  ];

  /// Common team name variations for fuzzy matching
  static const Map<String, List<String>> commonVariations = {
    'Iowa State Cyclones': ['Iowa State', 'Iowa St.', 'Iowa St', 'ISU'],
    'Kansas State Wildcats': ['Kansas State', 'Kansas St.', 'Kansas St', 'K-State', 'KSU'],
    'Fresno State Bulldogs': ['Fresno State', 'Fresno St.', 'Fresno St'],
    'Kansas Jayhawks': ['Kansas', 'KU'],
    'Alabama Crimson Tide': ['Alabama', 'Bama'],
    'Auburn Tigers': ['Auburn'],
    'Georgia Bulldogs': ['Georgia', 'UGA'],
    'Florida State Seminoles': ['Florida State', 'FSU', 'Florida St'],
    'Arkansas Razorbacks': ['Arkansas'],
    'Colorado Buffaloes': ['Colorado', 'CU'],
  };

  /// Look up a team's conference
  static String getTeamConference(String teamName) {
    for (final entry in conferences.entries) {
      if (entry.value.contains(teamName)) {
        return entry.key;
      }
    }
    return 'Independent';
  }

  /// Check if a team is considered an elite program
  static bool isEliteProgram(String teamName) {
    return elitePrograms.contains(teamName);
  }
}
