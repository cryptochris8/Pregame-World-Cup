import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock JSON data and asset bundle setup for chatbot tests.
///
/// Call [setupMockAssetBundle] in `setUpAll` to provide test data to
/// [rootBundle.loadString] so that [ChatbotKnowledgeBase] and
/// [EnhancedMatchDataService] can initialize in tests.

final Map<String, String> _mockAssets = {
  'assets/data/worldcup/matches/group_stage.json': jsonEncode(mockGroupStageMatches),
  'assets/data/worldcup/matches/knockout.json': jsonEncode(mockKnockoutMatches),
  'assets/data/worldcup/history/records.json': jsonEncode(mockRecords),
  'assets/data/worldcup/history/tournaments.json': jsonEncode(mockTournaments),
  'AssetManifest.json': jsonEncode(mockAssetManifest),
  'assets/data/worldcup/player_stats/Lionel_Messi_ARG.json': jsonEncode(mockMessiStats),
  'assets/data/worldcup/teams/usa.json': jsonEncode(mockTeamUSA),
  'assets/data/worldcup/teams/arg.json': jsonEncode(mockTeamARG),
  'assets/data/worldcup/managers/usa.json': jsonEncode(mockManagerUSA),
  'assets/data/worldcup/managers/arg.json': jsonEncode(mockManagerARG),
  'assets/data/worldcup/head_to_head/ARG_BRA.json': jsonEncode(mockH2hArgBra),
  'assets/data/worldcup/match_summaries/ARG_BRA.json': jsonEncode(mockSummaryArgBra),
  'assets/data/worldcup/squad_values.json': jsonEncode(mockSquadValues),
  'assets/data/worldcup/betting_odds.json': jsonEncode(mockBettingOdds),
  'assets/data/worldcup/injury_tracker.json': jsonEncode(mockInjuryTracker),
  'assets/data/worldcup/recent_form/groups_a_d.json': jsonEncode(mockRecentFormAD),
  'assets/data/worldcup/recent_form/groups_e_h.json': jsonEncode({'metadata': {}}),
  'assets/data/worldcup/recent_form/groups_i_l.json': jsonEncode(mockRecentFormIL),
  'assets/data/worldcup/historical_patterns.json': jsonEncode(mockHistoricalPatterns),
  'assets/data/worldcup/confederation_records.json': jsonEncode(mockConfederationRecords),
  'assets/data/worldcup/player_name_index.json': jsonEncode(mockPlayerNameIndex),
  'assets/data/worldcup/player_profiles/usa.json': jsonEncode(mockPlayerProfilesUSA),
  'assets/data/worldcup/player_profiles/arg.json': jsonEncode(mockPlayerProfilesARG),
};

/// Sets up a mock binary messenger handler that serves test JSON files
/// when [rootBundle.loadString] is called.
void setupMockAssetBundle() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (message == null) return null;
    final key = utf8.decode(
      message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
    );
    // URI-decode the key (rootBundle encodes the path)
    final decoded = Uri.decodeFull(key);
    if (_mockAssets.containsKey(decoded)) {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(_mockAssets[decoded]!)),
      );
    }
    return null;
  });
}

/// Tears down the mock handler.
void tearDownMockAssetBundle() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', null);
}

// ─── Mock Data ──────────────────────────────────────────────────

final mockGroupStageMatches = [
  {
    'matchId': 'wc2026_1',
    'matchNumber': 1,
    'stage': 'groupStage',
    'group': 'A',
    'groupMatchDay': 1,
    'homeTeamCode': 'MEX',
    'homeTeamName': 'Mexico',
    'awayTeamCode': 'RSA',
    'awayTeamName': 'South Africa',
    'status': 'scheduled',
    'date': '2026-06-11',
    'time': '15:00',
    'venueName': 'Estadio Azteca',
    'venueCity': 'Mexico City',
  },
  {
    'matchId': 'wc2026_5',
    'matchNumber': 5,
    'stage': 'groupStage',
    'group': 'B',
    'groupMatchDay': 1,
    'homeTeamCode': 'USA',
    'homeTeamName': 'United States',
    'awayTeamCode': 'BRA',
    'awayTeamName': 'Brazil',
    'status': 'scheduled',
    'date': '2026-06-12',
    'time': '20:00',
    'venueName': 'SoFi Stadium',
    'venueCity': 'Los Angeles',
  },
  {
    'matchId': 'wc2026_10',
    'matchNumber': 10,
    'stage': 'groupStage',
    'group': 'B',
    'groupMatchDay': 2,
    'homeTeamCode': 'BRA',
    'homeTeamName': 'Brazil',
    'awayTeamCode': 'ARG',
    'awayTeamName': 'Argentina',
    'status': 'scheduled',
    'date': '2026-06-17',
    'time': '14:00',
    'venueName': 'MetLife Stadium',
    'venueCity': 'East Rutherford',
  },
  {
    'matchId': 'wc2026_15',
    'matchNumber': 15,
    'stage': 'groupStage',
    'group': 'B',
    'groupMatchDay': 3,
    'homeTeamCode': 'ARG',
    'homeTeamName': 'Argentina',
    'awayTeamCode': 'USA',
    'awayTeamName': 'United States',
    'status': 'scheduled',
    'date': '2026-06-22',
    'time': '17:00',
    'venueName': 'AT&T Stadium',
    'venueCity': 'Dallas',
  },
];

final mockKnockoutMatches = [
  {
    'matchId': 'wc2026_100',
    'matchNumber': 100,
    'stage': 'semiFinal',
    'homeTeamCode': 'FRA',
    'homeTeamName': 'France',
    'awayTeamCode': 'ENG',
    'awayTeamName': 'England',
    'status': 'scheduled',
    'date': '2026-07-14',
    'time': '20:00',
    'venueName': 'MetLife Stadium',
    'venueCity': 'East Rutherford',
  },
];

final mockRecords = [
  {
    'category': 'Most Goals (Career)',
    'record': 'Most World Cup goals all-time',
    'holder': 'Miroslav Klose',
    'holderType': 'player',
    'value': 16,
    'details': 'Germany - 2002, 2006, 2010, 2014',
  },
  {
    'category': 'Most Titles',
    'record': 'Most World Cup wins',
    'holder': 'Brazil',
    'holderType': 'team',
    'value': 5,
    'details': '1958, 1962, 1970, 1994, 2002',
  },
  {
    'category': 'Most Appearances',
    'record': 'Most World Cup matches played',
    'holder': 'Lionel Messi',
    'holderType': 'player',
    'value': 26,
    'details': 'Argentina - 2006-2022',
  },
];

final mockTournaments = [
  {
    'year': 2018,
    'hostCountries': ['Russia'],
    'winner': 'France',
    'winnerCode': 'FRA',
    'runnerUp': 'Croatia',
    'runnerUpCode': 'CRO',
    'thirdPlace': 'Belgium',
    'thirdPlaceCode': 'BEL',
    'totalTeams': 32,
    'totalMatches': 64,
    'totalGoals': 169,
    'topScorer': 'Harry Kane',
    'topScorerCountry': 'England',
    'topScorerGoals': 6,
    'finalScore': '4-2',
    'finalVenue': 'Luzhniki Stadium',
    'finalCity': 'Moscow',
    'highlights': ['France wins second title', 'Croatia reaches first final'],
  },
  {
    'year': 2022,
    'hostCountries': ['Qatar'],
    'winner': 'Argentina',
    'winnerCode': 'ARG',
    'runnerUp': 'France',
    'runnerUpCode': 'FRA',
    'thirdPlace': 'Croatia',
    'thirdPlaceCode': 'CRO',
    'totalTeams': 32,
    'totalMatches': 64,
    'totalGoals': 172,
    'topScorer': 'Kylian Mbappe',
    'topScorerCountry': 'France',
    'topScorerGoals': 8,
    'finalScore': '3-3 (4-2 pen)',
    'finalVenue': 'Lusail Stadium',
    'finalCity': 'Lusail',
    'highlights': ['Messi wins World Cup', 'Greatest final ever'],
  },
];

final mockAssetManifest = {
  'assets/data/worldcup/player_stats/Lionel_Messi_ARG.json': [
    'assets/data/worldcup/player_stats/Lionel_Messi_ARG.json',
  ],
};

final mockMessiStats = {
  'playerName': 'Lionel Messi',
  'teamCode': 'ARG',
  'worldCupAppearances': 26,
  'worldCupGoals': 13,
  'worldCupAssists': 8,
  'previousWorldCups': [2006, 2010, 2014, 2018, 2022],
  'tournamentStats': [
    {
      'year': 2022,
      'matches': 7,
      'goals': 7,
      'assists': 3,
      'stage': 'Winner',
      'keyMoment': 'Won World Cup, 2 goals in final',
    },
  ],
  'worldCupAwards': ['World Cup Winner 2022', 'Golden Ball 2022'],
  'worldCupLegacyRating': 10,
  'worldCup2026Prediction': 'If fit, expected to play in his 6th World Cup.',
};

final mockTeamUSA = {
  'teamCode': 'USA',
  'countryName': 'United States',
  'players': [
    {
      'firstName': 'Christian',
      'lastName': 'Pulisic',
      'jerseyNumber': 10,
      'position': 'FW',
      'dateOfBirth': '1998-09-18',
      'height': 173,
      'weight': 70,
      'preferredFoot': 'Right',
      'club': 'AC Milan',
      'clubLeague': 'Serie A',
      'marketValue': 55000000,
      'caps': 70,
      'goals': 30,
    },
    {
      'firstName': 'Weston',
      'lastName': 'McKennie',
      'jerseyNumber': 8,
      'position': 'MF',
      'dateOfBirth': '1998-08-28',
      'height': 185,
      'weight': 77,
      'preferredFoot': 'Right',
      'club': 'Juventus',
      'clubLeague': 'Serie A',
      'marketValue': 30000000,
      'caps': 55,
      'goals': 11,
    },
  ],
};

final mockTeamARG = {
  'teamCode': 'ARG',
  'countryName': 'Argentina',
  'players': [
    {
      'firstName': 'Lionel',
      'lastName': 'Messi',
      'jerseyNumber': 10,
      'position': 'FW',
      'dateOfBirth': '1987-06-24',
      'height': 170,
      'weight': 72,
      'preferredFoot': 'Left',
      'club': 'Inter Miami',
      'clubLeague': 'MLS',
      'marketValue': 25000000,
      'caps': 185,
      'goals': 109,
    },
    {
      'firstName': 'Julian',
      'lastName': 'Alvarez',
      'jerseyNumber': 9,
      'position': 'FW',
      'dateOfBirth': '2000-01-31',
      'height': 170,
      'weight': 71,
      'preferredFoot': 'Right',
      'club': 'Atletico Madrid',
      'clubLeague': 'La Liga',
      'marketValue': 90000000,
      'caps': 35,
      'goals': 9,
    },
  ],
};

final mockManagerUSA = {
  'id': 'manager_usa',
  'firstName': 'Mauricio',
  'lastName': 'Pochettino',
  'commonName': 'Mauricio Pochettino',
  'nationality': 'Argentine',
  'currentTeam': 'United States',
  'currentTeamCode': 'USA',
  'preferredFormation': '4-3-3',
  'coachingStyle': 'High Press',
  'yearsExperience': 15,
  'trophies': ['Ligue 1 2022'],
  'careerWins': 200,
  'careerDraws': 80,
  'careerLosses': 100,
  'careerWinPercentage': 53,
  'bio': 'Argentine manager who took over the USMNT in 2024.',
};

final mockManagerARG = {
  'id': 'manager_arg',
  'firstName': 'Lionel',
  'lastName': 'Scaloni',
  'commonName': 'Lionel Scaloni',
  'nationality': 'Argentine',
  'currentTeam': 'Argentina',
  'currentTeamCode': 'ARG',
  'preferredFormation': '4-3-3',
  'coachingStyle': 'Possession',
  'yearsExperience': 7,
  'trophies': ['World Cup 2022', 'Copa America 2021'],
  'careerWins': 55,
  'careerDraws': 12,
  'careerLosses': 6,
  'careerWinPercentage': 75,
  'bio': 'Led Argentina to World Cup glory in 2022.',
};

final mockH2hArgBra = {
  'id': 'ARG_BRA',
  'team1Code': 'ARG',
  'team2Code': 'BRA',
  'totalMatches': 111,
  'team1Wins': 40,
  'team2Wins': 46,
  'draws': 25,
  'worldCupMatches': 4,
  'lastMatch': '2024-11-19',
  'notableMatches': [
    {
      'year': 1990,
      'tournament': 'World Cup',
      'stage': 'Round of 16',
      'team1Score': 1,
      'team2Score': 0,
      'winnerCode': 'ARG',
      'description': 'Caniggia stunner eliminates Brazil',
    },
  ],
};

final mockSummaryArgBra = {
  'team1Code': 'ARG',
  'team2Code': 'BRA',
  'team1Name': 'Argentina',
  'team2Name': 'Brazil',
  'historicalAnalysis': 'The greatest rivalry in football.',
  'keyStorylines': ['Argentina as defending champions', 'Brazil seeking redemption'],
  'playersToWatch': [
    {
      'name': 'Lionel Messi',
      'teamCode': 'ARG',
      'position': 'Forward',
      'reason': 'GOAT in his final tournament',
    },
  ],
  'tacticalPreview': 'Both teams favor attacking football.',
  'prediction': {
    'predictedOutcome': 'DRAW',
    'predictedScore': '2-2',
    'confidence': 45,
    'reasoning': 'Too close to call.',
  },
};

final mockSquadValues = {
  'lastUpdated': '2026-02-21',
  'teams': [
    {
      'rank': 1,
      'teamCode': 'ENG',
      'teamName': 'England',
      'playerCount': 26,
      'totalValue': 1866250000,
      'totalValueFormatted': '\$1.86B',
      'averagePlayerValue': 71778846,
      'mostValuablePlayer': {'name': 'Jude Bellingham', 'value': '\$225.0M'},
      'leastValuablePlayer': {'name': 'Kyle Walker', 'value': '\$10.0M'},
    },
    {
      'rank': 5,
      'teamCode': 'USA',
      'teamName': 'United States',
      'playerCount': 26,
      'totalValue': 500000000,
      'totalValueFormatted': '\$500M',
      'averagePlayerValue': 19230769,
      'mostValuablePlayer': {'name': 'Christian Pulisic', 'value': '\$55M'},
      'leastValuablePlayer': {'name': 'Some Player', 'value': '\$2M'},
    },
    {
      'rank': 10,
      'teamCode': 'ARG',
      'teamName': 'Argentina',
      'playerCount': 26,
      'totalValue': 700000000,
      'totalValueFormatted': '\$700M',
      'averagePlayerValue': 26923077,
      'mostValuablePlayer': {'name': 'Julian Alvarez', 'value': '\$90M'},
      'leastValuablePlayer': {'name': 'Some Player', 'value': '\$3M'},
    },
  ],
};

final mockBettingOdds = {
  'metadata': {'lastUpdated': '2026-02-21'},
  'outright_winner_odds': {
    'teams': [
      {
        'team': 'France',
        'code': 'FRA',
        'odds_american': '+450',
        'odds_decimal': 5.50,
        'implied_probability_pct': 18.2,
        'tier': 'favorite',
      },
      {
        'team': 'England',
        'code': 'ENG',
        'odds_american': '+500',
        'odds_decimal': 6.00,
        'implied_probability_pct': 16.7,
        'tier': 'favorite',
      },
      {
        'team': 'Argentina',
        'code': 'ARG',
        'odds_american': '+700',
        'odds_decimal': 8.00,
        'implied_probability_pct': 12.5,
        'tier': 'contender',
      },
      {
        'team': 'United States',
        'code': 'USA',
        'odds_american': '+2500',
        'odds_decimal': 26.00,
        'implied_probability_pct': 3.8,
        'tier': 'dark_horse',
      },
    ],
  },
};

final mockInjuryTracker = {
  'metadata': {'lastUpdated': '2026-02-21'},
  'players': [
    {
      'playerName': 'Kylian Mbappe',
      'teamCode': 'FRA',
      'country': 'France',
      'club': 'Real Madrid',
      'position': 'Forward',
      'injuryType': 'Recurring left knee discomfort',
      'expectedReturn': 'Currently playing through management',
      'availabilityStatus': 'minor_concern',
    },
    {
      'playerName': 'Christian Pulisic',
      'teamCode': 'USA',
      'country': 'United States',
      'club': 'AC Milan',
      'position': 'Forward',
      'injuryType': 'Hamstring strain',
      'expectedReturn': 'March 2026',
      'availabilityStatus': 'doubt',
    },
  ],
};

final mockRecentFormAD = {
  'metadata': {'generated': '2026-02-21'},
  'group_B': {
    'USA': {
      'team_name': 'United States',
      'team_code': 'USA',
      'recent_matches': [
        {'date': '2026-01-15', 'opponent': 'Canada', 'score': '2-1', 'result': 'W', 'venue': 'home'},
        {'date': '2026-01-10', 'opponent': 'Mexico', 'score': '1-1', 'result': 'D', 'venue': 'away'},
        {'date': '2025-12-20', 'opponent': 'Panama', 'score': '3-0', 'result': 'W', 'venue': 'home'},
      ],
    },
    'BRA': {
      'team_name': 'Brazil',
      'team_code': 'BRA',
      'recent_matches': [
        {'date': '2026-01-15', 'opponent': 'Chile', 'score': '2-0', 'result': 'W', 'venue': 'home'},
      ],
    },
  },
};

final mockRecentFormIL = {
  'metadata': {'generated': '2026-02-21'},
  'group_J': {
    'ARG': {
      'team_name': 'Argentina',
      'team_code': 'ARG',
      'recent_matches': [
        {'date': '2026-01-15', 'opponent': 'Uruguay', 'score': '1-0', 'result': 'W', 'venue': 'home'},
        {'date': '2026-01-10', 'opponent': 'Chile', 'score': '2-1', 'result': 'W', 'venue': 'away'},
      ],
    },
  },
};

final mockHistoricalPatterns = {
  'metadata': {'lastUpdated': '2026-02-21'},
  'patterns': [
    {
      'id': 'host_nation_performance',
      'category': 'Host Nation Performance',
      'title': 'Host Nations Historically Outperform Expectations',
      'description': 'Six host nations have won on home soil.',
      'keyFacts': ['6 out of 22 World Cup winners were host nations'],
      'relevanceTo2026': 'USA, Mexico, and Canada are co-hosts.',
    },
    {
      'id': 'defending_champion_curse',
      'category': 'Defending Champion Curse',
      'title': 'Champions Struggle to Retain the Trophy',
      'description': 'Since 2002, defending champions fail.',
      'keyFacts': ['No champion has reached the final since 2006'],
    },
  ],
};

final mockConfederationRecords = {
  'lastUpdated': '2026-02-21',
  'confederationOverview': {
    'UEFA': {'fullName': 'UEFA', 'region': 'Europe', 'worldCupTitles': 12},
    'CONMEBOL': {'fullName': 'CONMEBOL', 'region': 'South America', 'worldCupTitles': 10},
  },
  'headToHead': [],
};

final mockPlayerNameIndex = {
  'Christian Pulisic': 'USA',
  'Weston McKennie': 'USA',
  'Lionel Messi': 'ARG',
  'Julian Alvarez': 'ARG',
  'Kylian Mbappe': 'FRA',
  'Pulisic': 'USA',
  'McKennie': 'USA',
  'Messi': 'ARG',
  'Alvarez': 'ARG',
  'Mbappe': 'FRA',
};

final mockPlayerProfilesUSA = {
  'players': {
    'Christian Pulisic': {
      'bio': 'Born in Hershey, Pennsylvania, Pulisic became the youngest US international to score in a World Cup qualifier at 17.',
      'playingStyle': 'Dynamic winger who cuts inside with pace and trickery',
      'keyStrengths': ['Dribbling', 'Off-the-ball runs', 'Big-game mentality'],
      'worldCup2026Role': 'The face of the US team and primary creative force on home soil',
      'notableFact': 'Known as Captain America by US fans',
    },
    'Weston McKennie': {
      'bio': 'A box-to-box midfielder who grew up in Texas before moving to Germany as a teenager to join Schalke 04.',
      'playingStyle': 'Energetic, physical midfielder who covers every blade of grass',
      'keyStrengths': ['Aerial ability', 'Work rate', 'Versatility'],
      'worldCup2026Role': 'Engine of the midfield, expected to start every match',
      'notableFact': 'First American to score in the Champions League knockout rounds for Juventus',
    },
  },
};

final mockPlayerProfilesARG = {
  'players': {
    'Lionel Messi': {
      'bio': 'Widely regarded as the greatest footballer of all time, Messi led Argentina to World Cup glory in 2022.',
      'playingStyle': 'Playmaker with supernatural vision, close control, and finishing ability',
      'keyStrengths': ['Dribbling', 'Vision', 'Free kicks'],
      'worldCup2026Role': 'If fit, a farewell tour for the GOAT in his 6th World Cup',
      'notableFact': 'Won 8 Ballon d\'Or awards, the most by any player in history',
    },
    'Julian Alvarez': {
      'bio': 'A versatile forward from Calchin, Argentina who won the World Cup at just 22 years old.',
      'playingStyle': 'Intelligent forward who presses relentlessly and finds space in the box',
      'keyStrengths': ['Movement', 'Pressing', 'Clinical finishing'],
      'worldCup2026Role': 'Expected to lead the line as Argentina defends their title',
      'notableFact': 'Scored 4 goals at the 2022 World Cup as a 22-year-old',
    },
  },
};
