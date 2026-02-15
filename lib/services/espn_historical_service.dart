import 'package:dio/dio.dart';

/// World Cup historical matchup intelligence service.
/// Contains famous World Cup matches, international rivalries, tournament records,
/// and historical context for FIFA World Cup 2026 match analysis.
class ESPNHistoricalService {

  // Historical matchup records for major international soccer rivalries
  static const Map<String, Map<String, dynamic>> _historicalMatchups = {
    'Argentina_Brazil': {
      'series_record': 'Argentina leads 40-36-26 (all-time)',
      'last_meeting': {
        'year': 2021,
        'result': 'Argentina 1, Brazil 0 (Copa America Final)',
        'location': 'Maracana, Rio de Janeiro',
        'significance': 'Messi lifts first major international trophy'
      },
      'rivalry_name': 'Superclasico de las Americas',
      'significance': 'The greatest rivalry in international football',
      'key_facts': [
        'Most passionate fan bases in world football',
        'World Cup meetings always draw 1B+ global viewers',
        'Argentina won 2022 World Cup; Brazil has 5 titles',
        'Historic 1990 WC Round of 16: Argentina stunned Brazil'
      ]
    },
    'England_Germany': {
      'series_record': 'Germany leads 15-13-8 (all-time)',
      'last_meeting': {
        'year': 2021,
        'result': 'England 2, Germany 0 (Euro 2020 R16)',
        'location': 'Wembley Stadium, London',
        'significance': 'England exorcised decades of tournament heartbreak vs Germany'
      },
      'rivalry_name': 'Football\'s Greatest Rivalry',
      'significance': 'Decades of World Cup drama between two powerhouses',
      'key_facts': [
        '1966 WC Final: England 4-2 Germany (Geoff Hurst hat-trick)',
        '1990 WC Semi: Germany won on penalties (Gazza\'s tears)',
        '2010 WC R16: Germany 4-1 England (Lampard ghost goal)',
        'Penalty shootout drama is a recurring theme'
      ]
    },
    'Germany_Netherlands': {
      'series_record': 'Germany leads 16-11-9 (all-time)',
      'last_meeting': {
        'year': 2019,
        'result': 'Netherlands 4, Germany 2 (Euro Qualifier)',
        'location': 'Hamburg',
        'significance': 'Dutch resurgence under Koeman'
      },
      'rivalry_name': 'Der Klassiker / De Klassieker',
      'significance': 'One of Europe\'s most intense national team rivalries',
      'key_facts': [
        '1974 WC Final: Germany 2-1 Netherlands (Cruyff denied)',
        '1988 Euro Semi: Netherlands 2-1 Germany (Van Basten magic)',
        'Political and cultural dimensions beyond football',
        'Always produces memorable World Cup encounters'
      ]
    },
    'Argentina_England': {
      'series_record': 'Argentina leads 9-6-4 (all-time)',
      'last_meeting': {
        'year': 2002,
        'result': 'England 1, Argentina 0 (WC Group Stage)',
        'location': 'Sapporo, Japan',
        'significance': 'Beckham redeemed himself with penalty winner'
      },
      'rivalry_name': 'The Hand of God Rivalry',
      'significance': 'Historic World Cup rivalry with political undertones',
      'key_facts': [
        '1986 WC QF: Maradona\'s "Hand of God" and "Goal of the Century"',
        '1998 WC R16: Argentina won on penalties (Beckham red card)',
        'Falklands War added geopolitical dimension to rivalry',
        'Every World Cup meeting becomes an instant classic'
      ]
    },
    'Brazil_Germany': {
      'series_record': 'Brazil leads 12-5-4 (all-time)',
      'last_meeting': {
        'year': 2018,
        'result': 'Brazil 1, Germany 0 (Friendly)',
        'location': 'Berlin',
        'significance': 'Brazil seeking partial redemption after 7-1'
      },
      'rivalry_name': 'The 7-1 Rivals',
      'significance': 'Defined by the most shocking World Cup result ever',
      'key_facts': [
        '2002 WC Final: Brazil 2-0 Germany (Ronaldo brace)',
        '2014 WC Semi: Germany 7-1 Brazil (Mineirazo - greatest WC shock)',
        'Combined 14 World Cup titles between them',
        'Two of the most successful football nations in history'
      ]
    },
    'Brazil_France': {
      'series_record': 'France leads 7-5-3 (all-time)',
      'last_meeting': {
        'year': 2006,
        'result': 'France 1, Brazil 0 (WC Quarter-Final)',
        'location': 'Frankfurt, Germany',
        'significance': 'Henry\'s goal ended Brazil\'s title defense'
      },
      'rivalry_name': 'Le Classique Mondial',
      'significance': 'World Cup giants with dramatic tournament history',
      'key_facts': [
        '1998 WC Final: France 3-0 Brazil (Zidane masterclass)',
        '2006 WC QF: France 1-0 Brazil (end of the Ronaldinho era)',
        '1986 WC QF: France 1-1 Brazil, France won on penalties',
        'Combined 8 World Cup titles'
      ]
    },
    'France_Italy': {
      'series_record': 'France leads 18-12-6 (all-time)',
      'last_meeting': {
        'year': 2018,
        'result': 'France 3, Italy 1 (Friendly)',
        'location': 'Nice, France',
        'significance': 'Italy failed to qualify for 2018 WC'
      },
      'rivalry_name': 'The Mediterranean Derby',
      'significance': 'European neighbors with World Cup Final drama',
      'key_facts': [
        '2006 WC Final: Italy beat France on penalties (Zidane headbutt)',
        '2000 Euro Final: France 2-1 Italy (golden goal drama)',
        'Both nations among the most successful in WC history',
        'Italy has 4 WC titles; France has 2'
      ]
    },
    'France_Germany': {
      'series_record': 'Germany leads 14-10-5 (all-time)',
      'last_meeting': {
        'year': 2021,
        'result': 'France 1, Germany 0 (Euro 2020 Group Stage)',
        'location': 'Munich',
        'significance': 'Hummels own goal decided a tight contest'
      },
      'rivalry_name': 'Le Classique Europeen',
      'significance': 'European powerhouses with deep World Cup history',
      'key_facts': [
        '1982 WC Semi: Germany 3-3 France, Germany won on penalties',
        '1986 WC Semi: France 2-0 Germany',
        '2014 WC QF: Germany 1-0 France (Hummels header)',
        '2016 Euro Semi: France 2-0 Germany (Griezmann brace)'
      ]
    },
    'Mexico_United States': {
      'series_record': 'Mexico leads 36-22-15 (all-time)',
      'last_meeting': {
        'year': 2023,
        'result': 'USA 3, Mexico 0 (CONCACAF Nations League Semi)',
        'location': 'Las Vegas',
        'significance': 'US dominance in recent competitive matches'
      },
      'rivalry_name': 'Dos a Cero / CONCACAF Clasico',
      'significance': 'North America\'s fiercest football rivalry, amplified by 2026 co-hosting',
      'key_facts': [
        '2002 WC R16: USA 2-0 Mexico (the original "Dos a Cero")',
        'Both nations co-hosting World Cup 2026',
        'Rivalry has intensified since 2000s',
        'Matches draw massive TV audiences across North America'
      ]
    },
    'Portugal_Spain': {
      'series_record': 'Spain leads 17-7-10 (all-time)',
      'last_meeting': {
        'year': 2018,
        'result': 'Spain 3, Portugal 3 (WC Group Stage)',
        'location': 'Sochi, Russia',
        'significance': 'Ronaldo hat-trick in an all-time WC classic'
      },
      'rivalry_name': 'The Iberian Derby',
      'significance': 'Neighbors united by geography, divided by football',
      'key_facts': [
        '2018 WC: Cristiano Ronaldo hat-trick in 3-3 draw',
        '2010 WC R16: Spain 1-0 Portugal (David Villa winner)',
        'The only Iberian Peninsula nations to win international trophies',
        'Fans from both nations travel well to tournaments'
      ]
    },
    'Japan_South Korea': {
      'series_record': 'South Korea leads 42-24-16 (all-time)',
      'last_meeting': {
        'year': 2023,
        'result': 'Japan 3, South Korea 0 (East Asian Cup)',
        'location': 'Tokyo',
        'significance': 'Japan asserting recent dominance'
      },
      'rivalry_name': 'The East Asian Derby',
      'significance': 'Asia\'s biggest football rivalry, co-hosted 2002 World Cup',
      'key_facts': [
        'Co-hosted 2002 FIFA World Cup together',
        'Both reached knockout rounds in 2022 WC',
        'Historical and cultural rivalry beyond football',
        'Both emerging as consistent World Cup contenders'
      ]
    },
    'Ghana_Uruguay': {
      'series_record': 'Uruguay leads 3-1-0 (all-time)',
      'last_meeting': {
        'year': 2022,
        'result': 'Ghana 0, Uruguay 2 (WC Group Stage)',
        'location': 'Al Janoub, Qatar',
        'significance': 'Both eliminated despite Uruguay win; Ghana denied revenge'
      },
      'rivalry_name': 'The Suarez Handball Rivalry',
      'significance': 'Born from one of the most infamous moments in World Cup history',
      'key_facts': [
        '2010 WC QF: Uruguay beat Ghana on penalties after Suarez handball',
        'Suarez deliberately blocked a goal-bound header on the line',
        'Gyan missed the resulting penalty; Ghana lost shootout',
        '2022 WC: Both eliminated in group stage in dramatic fashion'
      ]
    },
    'Argentina_Germany': {
      'series_record': 'Germany leads 10-7-6 (all-time)',
      'last_meeting': {
        'year': 2022,
        'result': 'Argentina 2, Germany 0 (Friendly)',
        'location': 'Lusail, Qatar region',
        'significance': 'Messi-era Argentina showing their class'
      },
      'rivalry_name': 'World Cup Final Rivals',
      'significance': 'Met in three World Cup Finals (1986, 1990, 2014)',
      'key_facts': [
        '1986 WC Final: Argentina 3-2 Germany (Maradona\'s tournament)',
        '1990 WC Final: Germany 1-0 Argentina (Brehme penalty)',
        '2014 WC Final: Germany 1-0 Argentina AET (Gotze winner)',
        'Three World Cup Final meetings - more than any other pairing'
      ]
    },
    'Belgium_Netherlands': {
      'series_record': 'Belgium leads 30-26-19 (all-time)',
      'last_meeting': {
        'year': 2023,
        'result': 'Netherlands 1, Belgium 0 (Friendly)',
        'location': 'Amsterdam',
        'significance': 'Low Countries rivalry continues'
      },
      'rivalry_name': 'The Low Countries Derby',
      'significance': 'Neighboring nations with passionate football cultures',
      'key_facts': [
        'Belgium\'s golden generation vs Dutch total football legacy',
        'Netherlands has 3 WC Final appearances; Belgium reached 2018 SF',
        'Both nations produce elite talent for top European leagues',
        'Culturally intertwined yet fiercely competitive'
      ]
    },
    'Croatia_Serbia': {
      'series_record': 'Croatia leads 5-3-4 (all-time)',
      'last_meeting': {
        'year': 2013,
        'result': 'Croatia 2, Serbia 0 (WC Qualifier)',
        'location': 'Zagreb',
        'significance': 'Politically charged Balkan derby'
      },
      'rivalry_name': 'The Balkan Derby',
      'significance': 'Deep political and cultural tensions fuel football rivalry',
      'key_facts': [
        'Croatia reached 2018 WC Final (runners-up)',
        'Croatia finished 3rd at 2022 WC',
        'Former Yugoslav national team split in 1990s',
        'Matches carry significant political weight'
      ]
    },
    'Germany_Italy': {
      'series_record': 'Italy leads 15-8-9 (all-time)',
      'last_meeting': {
        'year': 2022,
        'result': 'Germany 5, Italy 2 (Nations League)',
        'location': 'Monchengladbach',
        'significance': 'Germany broke Italy\'s long unbeaten record in this fixture'
      },
      'rivalry_name': 'The Classic European Rivalry',
      'significance': 'Seven World Cup titles between them',
      'key_facts': [
        '1970 WC Semi: Italy 4-3 Germany AET (Game of the Century)',
        '2006 WC Semi: Italy 2-0 Germany (Grosso & Del Piero in ET)',
        'Combined 8 World Cup titles (Italy 4, Germany 4)',
        'Italy historically had the upper hand in tournaments'
      ]
    },
    'Italy_Spain': {
      'series_record': 'Spain leads 12-8-8 (all-time)',
      'last_meeting': {
        'year': 2021,
        'result': 'Italy 1-1 Spain (Italy won 4-2 pens, Euro 2020 Semi)',
        'location': 'Wembley Stadium, London',
        'significance': 'Italy edged out Spain en route to Euro 2020 title'
      },
      'rivalry_name': 'The Latin Derby',
      'significance': 'Europe\'s southern football powers clash',
      'key_facts': [
        '2010 WC: Spain 1-0 elimination of a stubborn Italian side',
        '2012 Euro Final: Spain 4-0 Italy (total domination)',
        'Both play possession-based football philosophies',
        'Combined 5 World Cup titles'
      ]
    },
    'Argentina_Uruguay': {
      'series_record': 'Argentina leads 91-59-50 (all-time)',
      'last_meeting': {
        'year': 2023,
        'result': 'Argentina 2, Uruguay 0 (WC Qualifier)',
        'location': 'Buenos Aires',
        'significance': 'River Plate rivalry in qualifying'
      },
      'rivalry_name': 'El Clasico del Rio de la Plata',
      'significance': 'The oldest international football rivalry in the world',
      'key_facts': [
        'First played in 1902 - oldest international rivalry',
        'Uruguay won first ever World Cup in 1930 (beat Argentina in Final)',
        '1930 WC Final: Uruguay 4-2 Argentina in Montevideo',
        'Combined 4 World Cup titles'
      ]
    },
    'Brazil_Uruguay': {
      'series_record': 'Brazil leads 38-20-20 (all-time)',
      'last_meeting': {
        'year': 2023,
        'result': 'Uruguay 2, Brazil 0 (WC Qualifier)',
        'location': 'Montevideo',
        'significance': 'Uruguay shocked Brazil in qualifying'
      },
      'rivalry_name': 'The Maracanazo Rivalry',
      'significance': 'Defined by the greatest upset in World Cup history',
      'key_facts': [
        '1950 WC Final: Uruguay 2-1 Brazil (the Maracanazo)',
        'Uruguay stunned 200,000 fans at the Maracana',
        'Brazil\'s greatest football trauma',
        'Both South American giants with storied World Cup pasts'
      ]
    },
  };

  // World Cup 2026 team storylines and narratives
  static const Map<String, List<String>> _currentSeasonStorylines = {
    'Argentina': [
      'Defending World Cup champions led by Messi\'s legacy',
      'Can they become first back-to-back champions since Brazil 1962?',
      'Scaloni has built the most complete Argentina squad in decades',
      'Messi\'s potential farewell World Cup appearance'
    ],
    'France': [
      '2022 runners-up seeking redemption after penalty shootout loss',
      'Mbappe leads a generational French attack',
      'Back-to-back Final appearances possible (2018 winners)',
      'Strongest squad depth in the tournament'
    ],
    'Brazil': [
      'Seeking 6th World Cup title - most by any nation',
      'New generation after 2022 QF disappointment',
      'Hungry to avenge 2014 home humiliation',
      'Technical brilliance meets tactical evolution'
    ],
    'Germany': [
      'Looking to bounce back after 2022 group stage exit',
      'Euro 2024 host nation momentum',
      '4-time champions with a point to prove',
      'Young squad blending experience with fresh talent'
    ],
    'England': [
      'Perennial contenders seeking first World Cup since 1966',
      'Golden generation: can they finally deliver?',
      '2018 semi-finalists, 2022 quarter-finalists',
      'Premier League talent pool is world-class'
    ],
    'Spain': [
      '2010 champions with a new era of talent',
      'Pedri, Gavi, Yamal - the youngest midfield in the tournament',
      'Tiki-taka evolution under new management',
      'La Roja\'s pressing game suits tournament football'
    ],
    'United States': [
      'Co-hosting the World Cup on home soil',
      'Best USMNT squad in history with European-based stars',
      'Pulisic, McKennie, Reyna, Musah - MLS and European blend',
      'Home crowd advantage across 11 US host cities'
    ],
    'Mexico': [
      'Co-hosts with massive home support',
      'Looking to break the "quinto partido" curse (Round of 16 exit)',
      'Liga MX passion meets World Cup stage',
      'Historic opportunity on home turf'
    ],
    'Canada': [
      'Co-hosts making only their 3rd World Cup appearance',
      'Alphonso Davies and Jonathan David lead a talented squad',
      'First World Cup since 1986',
      'Growing football culture boosted by hosting duties'
    ],
    'Netherlands': [
      'Total Football heritage seeking another WC Final',
      '3 World Cup Finals but never champions',
      'Tactical versatility under Dutch coaching philosophy',
      'Strong Eredivisie and international talent pipeline'
    ],
    'Portugal': [
      'Cristiano Ronaldo\'s possible last World Cup',
      'Beyond Ronaldo: deep squad with Bernardo Silva, Bruno Fernandes',
      '2022 QF exit to Morocco still stings',
      'Seeking first World Cup title in history'
    ],
    'Japan': [
      'Asia\'s top contender with European-based stars',
      'Shocked Germany and Spain in 2022 group stage',
      'Tactical discipline meets technical excellence',
      'Can they reach a first-ever Quarter-Final and beyond?'
    ],
    'Italy': [
      '4-time champions returning after missing 2018 WC',
      'Euro 2020 winners with tactical pedigree',
      'Defensive heritage blended with modern attacking play',
      'Serie A talent factory continues to produce stars'
    ],
    'Belgium': [
      'Golden generation\'s last chance at a major trophy',
      'De Bruyne, Lukaku headline a talented squad',
      '2018 WC 3rd place; 2022 group stage exit was a shock',
      'Can they deliver in their final window?'
    ],
    'Croatia': [
      '2018 WC runners-up, 2022 WC 3rd place',
      'Modric\'s legacy and the next generation',
      'Consistently punching above their weight',
      'Small nation with a giant tournament pedigree'
    ],
    'Uruguay': [
      '2-time World Cup champions with pride and history',
      'Won the first ever World Cup in 1930',
      'Garra Charrua fighting spirit defines their play',
      'South American dark horse in every tournament'
    ],
  };

  ESPNHistoricalService({Dio? dio});

  /// Get enhanced historical context for an international matchup
  Future<Map<String, dynamic>?> getMatchupHistory(String homeTeam, String awayTeam) async {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];

    if (historicalData == null) {
      // No specific historical data, but we can still provide context
      return _generateGenericMatchupContext(homeTeam, awayTeam);
    }

    // Enhance with current World Cup cycle context
    final homeStorylines = _currentSeasonStorylines[_extractCountryName(homeTeam)] ?? [];
    final awayStorylines = _currentSeasonStorylines[_extractCountryName(awayTeam)] ?? [];

    return {
      'historical_data': historicalData,
      'current_context': {
        'home_storylines': homeStorylines,
        'away_storylines': awayStorylines,
      },
      'matchup_intelligence': _generateMatchupIntelligence(historicalData, homeTeam, awayTeam),
    };
  }

  /// Generate venue-specific insights based on World Cup historical data
  Map<String, dynamic> generateVenueHistoricalInsights(String homeTeam, String awayTeam) {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];

    if (historicalData == null) {
      return _generateGenericVenueInsights(homeTeam, awayTeam);
    }

    final rivalryName = historicalData['rivalry_name'] ?? 'World Cup Match';
    final seriesRecord = historicalData['series_record'] ?? 'Series tied';
    final lastMeeting = historicalData['last_meeting'] ?? {};

    return {
      'crowd_appeal': _calculateHistoricalCrowdAppeal(historicalData),
      'marketing_hooks': [
        'Historic $rivalryName returns to the World Cup stage!',
        'All-time record: $seriesRecord',
        'Last meeting: ${lastMeeting['result'] ?? 'Great match expected'}',
        'World Cup rivalry atmosphere guaranteed'
      ],
      'venue_preparation': _generateHistoricalVenuePrep(historicalData),
      'social_media_content': [
        'Did you know: $seriesRecord',
        'Last time these nations met: ${lastMeeting['result'] ?? 'Epic showdown'}',
        'Get ready for $rivalryName atmosphere at our watch party!',
        '#WorldCup2026 #${rivalryName.replaceAll(' ', '')} #FIFA'
      ]
    };
  }

  /// Create AI-enhanced match summary with World Cup historical context
  String generateGameSummaryWithHistory(String homeTeam, String awayTeam, int? homeRank, int? awayRank) {
    final matchupKey = _getMatchupKey(homeTeam, awayTeam);
    final historicalData = _historicalMatchups[matchupKey];

    String summary = '';

    // Add FIFA ranking context
    if (homeRank != null && homeRank <= 50) {
      summary += '(FIFA #$homeRank) ';
    }
    summary += homeTeam;

    summary += ' vs ';

    if (awayRank != null && awayRank <= 50) {
      summary += '(FIFA #$awayRank) ';
    }
    summary += awayTeam;

    // Add historical context
    if (historicalData != null) {
      final rivalryName = historicalData['rivalry_name'];
      final seriesRecord = historicalData['series_record'];

      summary += ' in the $rivalryName. ';
      summary += 'All-time record: $seriesRecord. ';

      // Add last meeting context
      final lastMeeting = historicalData['last_meeting'];
      if (lastMeeting != null) {
        summary += 'Last meeting (${lastMeeting['year']}): ${lastMeeting['result']}. ';
        if (lastMeeting['significance'] != null) {
          summary += lastMeeting['significance'];
        }
      }
    } else {
      summary += ' in a FIFA World Cup 2026 clash.';
    }

    return summary;
  }

  /// Get World Cup records and milestones for trivia and engagement
  static Map<String, dynamic> getWorldCupRecords() {
    return {
      'most_titles': {'team': 'Brazil', 'count': 5, 'years': '1958, 1962, 1970, 1994, 2002'},
      'most_finals': {'team': 'Germany', 'count': 8},
      'most_goals_tournament': {'player': 'Just Fontaine', 'goals': 13, 'year': 1958, 'country': 'France'},
      'most_goals_career': {'player': 'Miroslav Klose', 'goals': 16, 'country': 'Germany'},
      'youngest_scorer': {'player': 'Pele', 'age': '17 years, 239 days', 'year': 1958},
      'fastest_goal': {'player': 'Hakan Sukur', 'time': '11 seconds', 'year': 2002, 'country': 'Turkey'},
      'most_appearances': {'player': 'Lothar Matthaus', 'matches': 25, 'country': 'Germany'},
      'highest_scoring_final': {'match': 'England 4-2 Germany (aet)', 'year': 1966},
      'biggest_win': {'match': 'Hungary 10-1 El Salvador', 'year': 1982},
      'most_attended': {'tournament': 'USA 1994', 'attendance': '3,587,538'},
      '2026_format': {
        'teams': 48,
        'matches': 104,
        'host_countries': ['USA', 'Mexico', 'Canada'],
        'final_venue': 'MetLife Stadium, New Jersey',
        'dates': 'June 11 - July 19, 2026',
      }
    };
  }

  /// Get famous World Cup matches for content and trivia
  static List<Map<String, dynamic>> getFamousWorldCupMatches() {
    return [
      {
        'match': 'Brazil 5-2 Sweden',
        'year': 1958,
        'stage': 'Final',
        'significance': 'Pele announces himself to the world at 17',
      },
      {
        'match': 'England 4-2 West Germany (aet)',
        'year': 1966,
        'stage': 'Final',
        'significance': 'England\'s only World Cup, Geoff Hurst hat-trick',
      },
      {
        'match': 'Italy 4-3 West Germany',
        'year': 1970,
        'stage': 'Semi-Final',
        'significance': 'Game of the Century - 5 goals in extra time',
      },
      {
        'match': 'West Germany 2-1 Netherlands',
        'year': 1974,
        'stage': 'Final',
        'significance': 'Cruyff\'s Total Football denied by resilient Germans',
      },
      {
        'match': 'Argentina 2-1 England',
        'year': 1986,
        'stage': 'Quarter-Final',
        'significance': 'Maradona\'s Hand of God and Goal of the Century',
      },
      {
        'match': 'France 3-0 Brazil',
        'year': 1998,
        'stage': 'Final',
        'significance': 'Zidane\'s two headers; mystery of Ronaldo\'s illness',
      },
      {
        'match': 'Germany 7-1 Brazil',
        'year': 2014,
        'stage': 'Semi-Final',
        'significance': 'The Mineirazo - most shocking World Cup result in history',
      },
      {
        'match': 'Argentina 3-3 France (4-2 pens)',
        'year': 2022,
        'stage': 'Final',
        'significance': 'Greatest WC Final ever? Messi vs Mbappe, Messi crowns career',
      },
    ];
  }

  /// Private helper methods

  /// Get the matchup key by sorting team names alphabetically
  String _getMatchupKey(String team1, String team2) {
    final country1 = _extractCountryName(team1);
    final country2 = _extractCountryName(team2);
    final teams = [country1, country2]..sort();
    return teams.join('_');
  }

  /// Extract the country name from various team name formats
  String _extractCountryName(String teamName) {
    final nameMap = {
      'usa': 'United States',
      'us': 'United States',
      'usmnt': 'United States',
      'korea republic': 'South Korea',
      'ir iran': 'Iran',
      'cote divoire': 'Ivory Coast',
    };

    final normalized = teamName.toLowerCase().trim();
    for (final entry in nameMap.entries) {
      if (normalized == entry.key || normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    // Remove common suffixes
    return teamName
        .replaceAll(RegExp(r'\s*national\s*(football\s*)?(soccer\s*)?team\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*nt\s*$', caseSensitive: false), '')
        .trim();
  }

  Map<String, dynamic> _generateGenericMatchupContext(String homeTeam, String awayTeam) {
    final homeCountry = _extractCountryName(homeTeam);
    final awayCountry = _extractCountryName(awayTeam);

    return {
      'historical_data': {
        'series_record': 'Head-to-head history not available',
        'rivalry_name': 'World Cup 2026 Match',
        'significance': 'Every World Cup match matters'
      },
      'current_context': {
        'home_storylines': _currentSeasonStorylines[homeCountry] ?? ['Fighting for World Cup glory'],
        'away_storylines': _currentSeasonStorylines[awayCountry] ?? ['Representing their nation on the world stage'],
      },
      'matchup_intelligence': {
        'crowd_factor_boost': 0.2,
        'tv_appeal': 'Moderate',
        'global_interest': 'World Cup atmosphere guarantees interest'
      }
    };
  }

  Map<String, dynamic> _generateMatchupIntelligence(Map<String, dynamic> historicalData, String homeTeam, String awayTeam) {
    double crowdBoost = 0.4; // Base World Cup rivalry boost
    String tvAppeal = 'High';

    // Analyze historical significance for crowd boost
    final significance = historicalData['significance']?.toString().toLowerCase() ?? '';
    if (significance.contains('greatest') || significance.contains('fiercest')) {
      crowdBoost = 0.7;
      tvAppeal = 'Extremely High - Global Event';
    } else if (significance.contains('historic') || significance.contains('intense') || significance.contains('world cup final')) {
      crowdBoost = 0.6;
      tvAppeal = 'Very High - Must-Watch';
    } else if (significance.contains('drama') || significance.contains('infamous') || significance.contains('shocking')) {
      crowdBoost = 0.5;
      tvAppeal = 'High - Storyline-Driven';
    }

    return {
      'crowd_factor_boost': crowdBoost,
      'tv_appeal': tvAppeal,
      'global_interest': 'World Cup rivalries attract billions of viewers worldwide',
      'social_media_buzz': 'Expect massive engagement from fans of both nations',
      'economic_impact': 'Significant tourism and local spending for host city'
    };
  }

  double _calculateHistoricalCrowdAppeal(Map<String, dynamic> historicalData) {
    final keyFacts = historicalData['key_facts'] as List<String>? ?? [];

    double appeal = 1.8; // Base World Cup rivalry appeal (higher than generic)

    for (String fact in keyFacts) {
      if (fact.toLowerCase().contains('billion') || fact.toLowerCase().contains('viewers')) {
        appeal += 0.4;
      }
      if (fact.toLowerCase().contains('final') || fact.toLowerCase().contains('classic')) {
        appeal += 0.3;
      }
      if (fact.toLowerCase().contains('world cup') || fact.toLowerCase().contains('wc')) {
        appeal += 0.2;
      }
      if (fact.toLowerCase().contains('dramatic') || fact.toLowerCase().contains('shock')) {
        appeal += 0.2;
      }
    }

    return appeal > 3.0 ? 3.0 : appeal; // Cap at 3.0x
  }

  Map<String, dynamic> _generateHistoricalVenuePrep(Map<String, dynamic> historicalData) {
    final keyFacts = historicalData['key_facts'] as List<String>? ?? [];
    final rivalryName = historicalData['rivalry_name'] ?? 'World Cup Match';

    List<String> prepTips = [
      'Expect packed house - promote early reservations',
      'Set up large screens with premium audio for the match',
      'Stock country flags and scarves for both teams',
      'Plan for extended hours - fans will arrive early and stay late',
    ];

    for (String fact in keyFacts) {
      if (fact.toLowerCase().contains('billion') || fact.toLowerCase().contains('viewers')) {
        prepTips.add('Global audience means diverse crowd - consider multilingual staff');
      }
      if (fact.toLowerCase().contains('penalty') || fact.toLowerCase().contains('penalties')) {
        prepTips.add('Historic penalty drama expected - prepare for high emotions');
      }
      if (fact.toLowerCase().contains('passionate') || fact.toLowerCase().contains('intense')) {
        prepTips.add('Passionate fan bases - have security plan and designated areas');
      }
    }

    return {
      'staffing_multiplier': 2.5,
      'inventory_focus': [
        'Country flag decorations for both nations',
        'International beer and cocktails',
        'Match-themed food specials',
        'World Cup merchandise',
      ],
      'preparation_tips': prepTips,
      'marketing_emphasis': 'Historic $rivalryName at World Cup 2026 - unmissable atmosphere'
    };
  }

  Map<String, dynamic> _generateGenericVenueInsights(String homeTeam, String awayTeam) {
    return {
      'crowd_appeal': 1.5, // World Cup baseline is higher than regular matches
      'marketing_hooks': [
        'World Cup 2026 Match Day!',
        '$homeTeam vs $awayTeam - live on the big screen',
        'Join the global celebration of football',
        'World Cup watch party atmosphere'
      ],
      'venue_preparation': {
        'staffing_multiplier': 1.5,
        'inventory_focus': ['World Cup decorations', 'International food & drinks'],
        'preparation_tips': [
          'Prepare for increased World Cup interest crowd',
          'Set up multiple viewing screens',
          'Promote on social media with #WorldCup2026',
        ],
        'marketing_emphasis': 'FIFA World Cup 2026 live viewing experience'
      }
    };
  }
}
