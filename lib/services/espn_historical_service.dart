import 'package:dio/dio.dart';

/// LEGACY: Enhanced ESPN service with historical matchup intelligence.
/// Contains SEC college football rivalry data from the original Pregame app.
/// Not used for World Cup 2026 - retained for reference only.
/// World Cup historical data is handled by SportsData.io and AI services.
class ESPNHistoricalService {
  
  // LEGACY: Historical matchup records for major SEC rivalries (college football)
  static const Map<String, Map<String, dynamic>> _historicalMatchups = {
    'Alabama_Auburn': {
      'series_record': 'Alabama leads 50-37-1',
      'last_meeting': {
        'year': 2023,
        'result': 'Alabama 27, Auburn 24',
        'location': 'Auburn',
        'significance': 'Iron Bowl classic, decided by field goal'
      },
      'rivalry_name': 'Iron Bowl',
      'significance': 'One of college football\'s greatest rivalries',
      'key_facts': [
        'Played annually since 1948',
        'Winner often goes to SEC Championship',
        'Average attendance: 87,000+',
        'Most watched SEC regular season game'
      ]
    },
    'Alabama_LSU': {
      'series_record': 'Alabama leads 56-26-5',
      'last_meeting': {
        'year': 2023,
        'result': 'Alabama 42, LSU 28',
        'location': 'Tuscaloosa',
        'significance': 'Alabama clinched SEC West'
      },
      'rivalry_name': 'Saban Bowl',
      'significance': 'Heated rivalry intensified under Nick Saban',
      'key_facts': [
        'Often decides SEC West champion',
        'Night games draw huge TV audiences',
        'Both programs compete for same recruits',
        'Recent meetings have major playoff implications'
      ]
    },
    'Alabama_Tennessee': {
      'series_record': 'Alabama leads 59-39-7',
      'last_meeting': {
        'year': 2023,
        'result': 'Alabama 34, Tennessee 20',
        'location': 'Knoxville',
        'significance': 'Third Saturday in October'
      },
      'rivalry_name': 'Third Saturday in October',
      'significance': 'Historic cross-division rivalry',
      'key_facts': [
        'Oldest SEC rivalry for Alabama',
        'Played on third Saturday in October traditionally',
        'Tennessee looking to end 16-game losing streak',
        'Massive TV ratings every year'
      ]
    },
    'Georgia_Florida': {
      'series_record': 'Georgia leads 54-44-2',
      'last_meeting': {
        'year': 2023,
        'result': 'Georgia 24, Florida 20',
        'location': 'Jacksonville',
        'significance': 'World\'s Largest Outdoor Cocktail Party'
      },
      'rivalry_name': 'World\'s Largest Outdoor Cocktail Party',
      'significance': 'Neutral site game in Jacksonville',
      'key_facts': [
        'Played in Jacksonville since 1933',
        'Split stadium - half Bulldogs, half Gators',
        'Winner often goes to SEC Championship',
        'Huge party atmosphere downtown'
      ]
    },
    'Auburn_Georgia': {
      'series_record': 'Georgia leads 63-56-8',
      'last_meeting': {
        'year': 2023,
        'result': 'Georgia 27, Auburn 20',
        'location': 'Athens',
        'significance': 'Deep South\'s Oldest Rivalry'
      },
      'rivalry_name': 'Deep South\'s Oldest Rivalry',
      'significance': 'Oldest rivalry in the Deep South',
      'key_facts': [
        'First played in 1892',
        'Oldest rivalry in the Deep South',
        'Both fan bases travel extremely well',
        'Often season-defining game for both'
      ]
    },
    'Ole_Miss_Mississippi_State': {
      'series_record': 'Ole Miss leads 64-46-6',
      'last_meeting': {
        'year': 2023,
        'result': 'Ole Miss 31, Mississippi State 24',
        'location': 'Oxford',
        'significance': 'Egg Bowl rivalry'
      },
      'rivalry_name': 'Egg Bowl',
      'significance': 'Battle for the Golden Egg',
      'key_facts': [
        'Winner gets the Golden Egg trophy',
        'In-state bragging rights',
        'Often played on Thanksgiving weekend',
        'Can affect bowl game positioning'
      ]
    }
  };

  // Current season storylines that add context
  static const Map<String, List<String>> _currentSeasonStorylines = {
    'Alabama': [
      'New era under Kalen DeBoer',
      'Can they maintain dynasty without Saban?',
      'Quarterback competition heating up',
      'Loaded roster still championship caliber'
    ],
    'Georgia': [
      'Back-to-back national championship pursuit',
      'Kirby Smart has built a powerhouse',
      'Elite recruiting class coming in',
      'Quarterback depth is impressive'
    ],
    'LSU': [
      'Brian Kelly\'s third year building culture',
      'Improved recruiting in Louisiana',
      'Death Valley still intimidating',
      'Looking to reclaim SEC West'
    ],
    'Auburn': [
      'Hugh Freeze bringing new energy',
      'Jordan Hare Stadium mystique',
      'Building toward Iron Bowl upset',
      'Young team with upside'
    ],
    'Tennessee': [
      'Josh Heupel\'s high-octane offense',
      'Neyland Stadium rocking again',
      'Can they beat Alabama finally?',
      'SEC Championship contender'
    ],
    'Florida': [
      'Billy Napier building foundation',
      'The Swamp advantage',
      'Recruiting battles with Georgia',
      'Return to SEC East contention'
    ]
  };

  ESPNHistoricalService({Dio? dio});

  /// Get enhanced historical context for a matchup
  Future<Map<String, dynamic>?> getMatchupHistory(String homeTeam, String awayTeam) async {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];
    
    if (historicalData == null) {
      // No specific historical data, but we can still provide context
      return _generateGenericMatchupContext(homeTeam, awayTeam);
    }

    // Enhance with current season context
    final homeStorylines = _currentSeasonStorylines[homeTeam] ?? [];
    final awayStorylines = _currentSeasonStorylines[awayTeam] ?? [];

    return {
      'historical_data': historicalData,
      'current_context': {
        'home_storylines': homeStorylines,
        'away_storylines': awayStorylines,
      },
      'matchup_intelligence': _generateMatchupIntelligence(historicalData, homeTeam, awayTeam),
    };
  }

  /// Generate venue-specific insights based on historical data
  Map<String, dynamic> generateVenueHistoricalInsights(String homeTeam, String awayTeam) {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];
    
    if (historicalData == null) {
      return _generateGenericVenueInsights(homeTeam, awayTeam);
    }

    final rivalryName = historicalData['rivalry_name'] ?? 'Rivalry Game';
    final seriesRecord = historicalData['series_record'] ?? 'Series tied';
    final lastMeeting = historicalData['last_meeting'] ?? {};

    return {
      'crowd_appeal': _calculateHistoricalCrowdAppeal(historicalData),
      'marketing_hooks': [
        'Historic $rivalryName returns!',
        'Series record: $seriesRecord',
        'Last meeting: ${lastMeeting['result'] ?? 'Great game expected'}',
        'Rivalry atmosphere guaranteed'
      ],
      'venue_preparation': _generateHistoricalVenuePrep(historicalData),
      'social_media_content': [
        'Did you know: $seriesRecord',
        'Last time these teams met: ${lastMeeting['result'] ?? 'Epic showdown'}',
        'Get ready for $rivalryName atmosphere!',
        '#${rivalryName.replaceAll(' ', '')} #Legacy'
      ]
    };
  }

  /// Create AI-enhanced game summary with historical context
  String generateGameSummaryWithHistory(String homeTeam, String awayTeam, int? homeRank, int? awayRank) {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];
    
    String summary = '';
    
    // Add ranking context
    if (homeRank != null && homeRank <= 25) {
      summary += '#$homeRank ';
    }
    summary += homeTeam;
    
    summary += ' hosts ';
    
    if (awayRank != null && awayRank <= 25) {
      summary += '#$awayRank ';
    }
    summary += awayTeam;

    // Add historical context
    if (historicalData != null) {
      final rivalryName = historicalData['rivalry_name'];
      final seriesRecord = historicalData['series_record'];
      
      summary += ' in the $rivalryName. ';
      summary += 'Series record: $seriesRecord. ';
      
      // Add last meeting context
      final lastMeeting = historicalData['last_meeting'];
      if (lastMeeting != null) {
        summary += 'Last meeting (${lastMeeting['year']}): ${lastMeeting['result']}. ';
        if (lastMeeting['significance'] != null) {
          summary += lastMeeting['significance'];
        }
      }
    } else {
      summary += ' in a conference showdown.';
    }

    return summary;
  }

  /// Private helper methods
  String _getMatchupKey(String team1, String team2) {
    final teams = [team1, team2]..sort();
    return teams.join('_');
  }

  Map<String, dynamic> _generateGenericMatchupContext(String homeTeam, String awayTeam) {
    return {
      'historical_data': {
        'series_record': 'Series history not available',
        'rivalry_name': 'Conference Matchup',
        'significance': 'Important match'
      },
      'current_context': {
        'home_storylines': _currentSeasonStorylines[homeTeam] ?? ['Looking to defend home field'],
        'away_storylines': _currentSeasonStorylines[awayTeam] ?? ['Road test in hostile environment'],
      },
      'matchup_intelligence': {
        'crowd_factor_boost': 0.2,
        'tv_appeal': 'Moderate',
        'betting_interest': 'Conference game significance'
      }
    };
  }

  Map<String, dynamic> _generateMatchupIntelligence(Map<String, dynamic> historicalData, String homeTeam, String awayTeam) {
    double crowdBoost = 0.3; // Base rivalry boost
    String tvAppeal = 'High';
    
    // Analyze historical significance for crowd boost
    final significance = historicalData['significance']?.toString().toLowerCase() ?? '';
    if (significance.contains('greatest') || significance.contains('iron bowl')) {
      crowdBoost = 0.6;
      tvAppeal = 'Extremely High';
    } else if (significance.contains('historic') || significance.contains('oldest')) {
      crowdBoost = 0.5;
      tvAppeal = 'Very High';
    }

    return {
      'crowd_factor_boost': crowdBoost,
      'tv_appeal': tvAppeal,
      'betting_interest': 'Rivalry games typically see heavy action',
      'social_media_buzz': 'High engagement expected from both fan bases',
      'economic_impact': 'Significant visitor traffic for local businesses'
    };
  }

  double _calculateHistoricalCrowdAppeal(Map<String, dynamic> historicalData) {
    final keyFacts = historicalData['key_facts'] as List<String>? ?? [];
    
    double appeal = 1.5; // Base rivalry appeal
    
    for (String fact in keyFacts) {
      if (fact.contains('Most watched') || fact.contains('huge TV')) {
        appeal += 0.3;
      }
      if (fact.contains('attendance') || fact.contains('87,000')) {
        appeal += 0.2;
      }
      if (fact.contains('party') || fact.contains('atmosphere')) {
        appeal += 0.2;
      }
    }
    
    return appeal > 3.0 ? 3.0 : appeal; // Cap at 3.0x
  }

  Map<String, dynamic> _generateHistoricalVenuePrep(Map<String, dynamic> historicalData) {
    final keyFacts = historicalData['key_facts'] as List<String>? ?? [];
    final rivalryName = historicalData['rivalry_name'] ?? 'Rivalry Game';
    
    List<String> prepTips = [
      'Expect sellout crowd - book reservations early',
      'Stock team-specific merchandise',
      'Plan for extended hours',
    ];
    
    // Add specific tips based on historical data
    for (String fact in keyFacts) {
      if (fact.contains('attendance') || fact.contains('87,000')) {
        prepTips.add('Massive crowd expected - triple staff recommended');
      }
      if (fact.contains('party') || fact.contains('cocktail')) {
        prepTips.add('Heavy alcohol sales expected - stock premium options');
      }
      if (fact.contains('night games')) {
        prepTips.add('Prime time exposure - perfect for livestreaming');
      }
    }

    return {
      'staffing_multiplier': 2.5,
      'inventory_focus': ['Team colors merchandise', 'Premium alcohol', 'Rivalry-themed specials'],
      'preparation_tips': prepTips,
      'marketing_emphasis': 'Historic $rivalryName viewing experience'
    };
  }

  Map<String, dynamic> _generateGenericVenueInsights(String homeTeam, String awayTeam) {
    return {
      'crowd_appeal': 1.3,
      'marketing_hooks': [
        'Exciting matchup!',
        '$homeTeam vs $awayTeam',
        'Match day atmosphere',
        'Conference championship implications'
      ],
      'venue_preparation': {
        'staffing_multiplier': 1.5,
        'inventory_focus': ['Standard game day items', 'Team merchandise'],
        'preparation_tips': ['Prepare for increased crowd', 'Monitor game importance'],
        'marketing_emphasis': 'Quality match viewing'
      }
    };
  }
} 