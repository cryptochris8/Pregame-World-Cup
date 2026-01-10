import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/domain/models/player.dart';

/// Comprehensive tests for Player data model and nested classes
void main() {
  group('Player Model - Computed Properties', () {
    test('formattedMarketValue returns €M for millions', () {
      final player = _createPlayer(marketValue: 150000000);
      expect(player.formattedMarketValue, equals('€150M'));
    });

    test('formattedMarketValue returns €K for thousands', () {
      final player = _createPlayer(marketValue: 500000);
      expect(player.formattedMarketValue, equals('€500K'));
    });

    test('formattedMarketValue returns raw value for small amounts', () {
      final player = _createPlayer(marketValue: 500);
      expect(player.formattedMarketValue, equals('€500'));
    });

    test('positionDisplayName returns full name for GK', () {
      final player = _createPlayer(position: 'GK');
      expect(player.positionDisplayName, equals('Goalkeeper'));
    });

    test('positionDisplayName returns full name for CB', () {
      final player = _createPlayer(position: 'CB');
      expect(player.positionDisplayName, equals('Center Back'));
    });

    test('positionDisplayName returns full name for LB', () {
      final player = _createPlayer(position: 'LB');
      expect(player.positionDisplayName, equals('Left Back'));
    });

    test('positionDisplayName returns full name for RB', () {
      final player = _createPlayer(position: 'RB');
      expect(player.positionDisplayName, equals('Right Back'));
    });

    test('positionDisplayName returns full name for LWB', () {
      final player = _createPlayer(position: 'LWB');
      expect(player.positionDisplayName, equals('Left Wing Back'));
    });

    test('positionDisplayName returns full name for RWB', () {
      final player = _createPlayer(position: 'RWB');
      expect(player.positionDisplayName, equals('Right Wing Back'));
    });

    test('positionDisplayName returns full name for CDM', () {
      final player = _createPlayer(position: 'CDM');
      expect(player.positionDisplayName, equals('Defensive Midfielder'));
    });

    test('positionDisplayName returns full name for CM', () {
      final player = _createPlayer(position: 'CM');
      expect(player.positionDisplayName, equals('Central Midfielder'));
    });

    test('positionDisplayName returns full name for CAM', () {
      final player = _createPlayer(position: 'CAM');
      expect(player.positionDisplayName, equals('Attacking Midfielder'));
    });

    test('positionDisplayName returns full name for LM', () {
      final player = _createPlayer(position: 'LM');
      expect(player.positionDisplayName, equals('Left Midfielder'));
    });

    test('positionDisplayName returns full name for RM', () {
      final player = _createPlayer(position: 'RM');
      expect(player.positionDisplayName, equals('Right Midfielder'));
    });

    test('positionDisplayName returns full name for LW', () {
      final player = _createPlayer(position: 'LW');
      expect(player.positionDisplayName, equals('Left Winger'));
    });

    test('positionDisplayName returns full name for RW', () {
      final player = _createPlayer(position: 'RW');
      expect(player.positionDisplayName, equals('Right Winger'));
    });

    test('positionDisplayName returns full name for ST', () {
      final player = _createPlayer(position: 'ST');
      expect(player.positionDisplayName, equals('Striker'));
    });

    test('positionDisplayName returns full name for CF', () {
      final player = _createPlayer(position: 'CF');
      expect(player.positionDisplayName, equals('Center Forward'));
    });

    test('positionDisplayName returns position code for unknown positions', () {
      final player = _createPlayer(position: 'XYZ');
      expect(player.positionDisplayName, equals('XYZ'));
    });

    test('category returns Goalkeeper for GK', () {
      final player = _createPlayer(position: 'GK');
      expect(player.category, equals('Goalkeeper'));
    });

    test('category returns Defender for CB', () {
      final player = _createPlayer(position: 'CB');
      expect(player.category, equals('Defender'));
    });

    test('category returns Defender for LB', () {
      final player = _createPlayer(position: 'LB');
      expect(player.category, equals('Defender'));
    });

    test('category returns Defender for RB', () {
      final player = _createPlayer(position: 'RB');
      expect(player.category, equals('Defender'));
    });

    test('category returns Defender for LWB', () {
      final player = _createPlayer(position: 'LWB');
      expect(player.category, equals('Defender'));
    });

    test('category returns Defender for RWB', () {
      final player = _createPlayer(position: 'RWB');
      expect(player.category, equals('Defender'));
    });

    test('category returns Midfielder for CDM', () {
      final player = _createPlayer(position: 'CDM');
      expect(player.category, equals('Midfielder'));
    });

    test('category returns Midfielder for CM', () {
      final player = _createPlayer(position: 'CM');
      expect(player.category, equals('Midfielder'));
    });

    test('category returns Midfielder for CAM', () {
      final player = _createPlayer(position: 'CAM');
      expect(player.category, equals('Midfielder'));
    });

    test('category returns Midfielder for LM', () {
      final player = _createPlayer(position: 'LM');
      expect(player.category, equals('Midfielder'));
    });

    test('category returns Midfielder for RM', () {
      final player = _createPlayer(position: 'RM');
      expect(player.category, equals('Midfielder'));
    });

    test('category returns Forward for LW', () {
      final player = _createPlayer(position: 'LW');
      expect(player.category, equals('Forward'));
    });

    test('category returns Forward for RW', () {
      final player = _createPlayer(position: 'RW');
      expect(player.category, equals('Forward'));
    });

    test('category returns Forward for ST', () {
      final player = _createPlayer(position: 'ST');
      expect(player.category, equals('Forward'));
    });

    test('category returns Forward for CF', () {
      final player = _createPlayer(position: 'CF');
      expect(player.category, equals('Forward'));
    });

    test('category returns Player for unknown positions', () {
      final player = _createPlayer(position: 'UNKNOWN');
      expect(player.category, equals('Player'));
    });

    test('goalsPerGame calculates correctly', () {
      final player = _createPlayer(caps: 100, goals: 50);
      expect(player.goalsPerGame, equals(0.5));
    });

    test('goalsPerGame returns 0 when caps is 0', () {
      final player = _createPlayer(caps: 0, goals: 0);
      expect(player.goalsPerGame, equals(0.0));
    });

    test('assistsPerGame calculates correctly', () {
      final player = _createPlayer(caps: 100, assists: 25);
      expect(player.assistsPerGame, equals(0.25));
    });

    test('assistsPerGame returns 0 when caps is 0', () {
      final player = _createPlayer(caps: 0, assists: 0);
      expect(player.assistsPerGame, equals(0.0));
    });
  });

  group('Player Model - toFirestore and fromFirestore roundtrip', () {
    test('toFirestore contains all required fields', () {
      final player = _createFullPlayer();
      final map = player.toFirestore();

      expect(map['playerId'], equals('player_001'));
      expect(map['fifaCode'], equals('BRA'));
      expect(map['commonName'], equals('Neymar'));
      expect(map['jerseyNumber'], equals(10));
      expect(map['position'], equals('LW'));
      expect(map['marketValue'], equals(150000000));
      expect(map['caps'], equals(128));
      expect(map['goals'], equals(79));
      expect(map['assists'], equals(58));
    });

    test('toFirestore includes nested stats', () {
      final player = _createFullPlayer();
      final map = player.toFirestore();

      expect(map['stats'], isNotNull);
      expect(map['stats']['club'], isNotNull);
      expect(map['stats']['international'], isNotNull);
    });

    test('toFirestore includes social media', () {
      final player = _createFullPlayer();
      final map = player.toFirestore();

      expect(map['socialMedia'], isNotNull);
      expect(map['socialMedia']['instagram'], equals('@neymarjr'));
    });
  });

  group('ClubStats Model', () {
    test('fromMap parses correctly', () {
      final map = {
        'season': '2024-25',
        'appearances': 30,
        'goals': 20,
        'assists': 15,
        'minutesPlayed': 2500,
      };
      final stats = ClubStats.fromMap(map);

      expect(stats.season, equals('2024-25'));
      expect(stats.appearances, equals(30));
      expect(stats.goals, equals(20));
      expect(stats.assists, equals(15));
      expect(stats.minutesPlayed, equals(2500));
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};
      final stats = ClubStats.fromMap(map);

      expect(stats.season, equals(''));
      expect(stats.appearances, equals(0));
      expect(stats.goals, equals(0));
      expect(stats.assists, equals(0));
      expect(stats.minutesPlayed, equals(0));
    });

    test('toMap returns correct structure', () {
      final stats = ClubStats(
        season: '2024-25',
        appearances: 30,
        goals: 20,
        assists: 15,
        minutesPlayed: 2500,
      );
      final map = stats.toMap();

      expect(map['season'], equals('2024-25'));
      expect(map['appearances'], equals(30));
      expect(map['goals'], equals(20));
      expect(map['assists'], equals(15));
      expect(map['minutesPlayed'], equals(2500));
    });
  });

  group('InternationalStats Model', () {
    test('fromMap parses correctly', () {
      final map = {
        'appearances': 128,
        'goals': 79,
        'assists': 58,
        'minutesPlayed': 10000,
      };
      final stats = InternationalStats.fromMap(map);

      expect(stats.appearances, equals(128));
      expect(stats.goals, equals(79));
      expect(stats.assists, equals(58));
      expect(stats.minutesPlayed, equals(10000));
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};
      final stats = InternationalStats.fromMap(map);

      expect(stats.appearances, equals(0));
      expect(stats.goals, equals(0));
      expect(stats.assists, equals(0));
      expect(stats.minutesPlayed, equals(0));
    });

    test('toMap returns correct structure', () {
      final stats = InternationalStats(
        appearances: 128,
        goals: 79,
        assists: 58,
        minutesPlayed: 10000,
      );
      final map = stats.toMap();

      expect(map['appearances'], equals(128));
      expect(map['goals'], equals(79));
      expect(map['assists'], equals(58));
      expect(map['minutesPlayed'], equals(10000));
    });
  });

  group('PlayerStats Model', () {
    test('fromMap parses nested club and international stats', () {
      final map = {
        'club': {
          'season': '2024-25',
          'appearances': 30,
          'goals': 20,
          'assists': 15,
          'minutesPlayed': 2500,
        },
        'international': {
          'appearances': 128,
          'goals': 79,
          'assists': 58,
          'minutesPlayed': 10000,
        },
      };
      final stats = PlayerStats.fromMap(map);

      expect(stats.club.season, equals('2024-25'));
      expect(stats.club.goals, equals(20));
      expect(stats.international.appearances, equals(128));
      expect(stats.international.goals, equals(79));
    });

    test('fromMap handles empty map', () {
      final map = <String, dynamic>{};
      final stats = PlayerStats.fromMap(map);

      expect(stats.club.season, equals(''));
      expect(stats.international.appearances, equals(0));
    });

    test('toMap returns correct nested structure', () {
      final stats = PlayerStats(
        club: ClubStats(
          season: '2024-25',
          appearances: 30,
          goals: 20,
          assists: 15,
          minutesPlayed: 2500,
        ),
        international: InternationalStats(
          appearances: 128,
          goals: 79,
          assists: 58,
          minutesPlayed: 10000,
        ),
      );
      final map = stats.toMap();

      expect(map['club']['season'], equals('2024-25'));
      expect(map['international']['goals'], equals(79));
    });
  });

  group('SocialMedia Model', () {
    test('fromMap parses correctly', () {
      final map = {
        'instagram': '@neymarjr',
        'twitter': '@neymarjr',
        'followers': 200000000,
      };
      final social = SocialMedia.fromMap(map);

      expect(social.instagram, equals('@neymarjr'));
      expect(social.twitter, equals('@neymarjr'));
      expect(social.followers, equals(200000000));
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};
      final social = SocialMedia.fromMap(map);

      expect(social.instagram, equals(''));
      expect(social.twitter, equals(''));
      expect(social.followers, equals(0));
    });

    test('toMap returns correct structure', () {
      final social = SocialMedia(
        instagram: '@neymarjr',
        twitter: '@neymarjr',
        followers: 200000000,
      );
      final map = social.toMap();

      expect(map['instagram'], equals('@neymarjr'));
      expect(map['twitter'], equals('@neymarjr'));
      expect(map['followers'], equals(200000000));
    });

    test('formattedFollowers returns M for millions', () {
      final social = SocialMedia(
        instagram: '',
        twitter: '',
        followers: 200000000,
      );
      expect(social.formattedFollowers, equals('200.0M'));
    });

    test('formattedFollowers returns K for thousands', () {
      final social = SocialMedia(
        instagram: '',
        twitter: '',
        followers: 500000,
      );
      expect(social.formattedFollowers, equals('500K'));
    });

    test('formattedFollowers returns raw value for small numbers', () {
      final social = SocialMedia(
        instagram: '',
        twitter: '',
        followers: 500,
      );
      expect(social.formattedFollowers, equals('500'));
    });
  });

  group('WorldCupTournamentStats Model', () {
    test('fromMap parses correctly with all fields', () {
      final map = {
        'year': 2022,
        'matches': 7,
        'goals': 3,
        'assists': 2,
        'yellowCards': 1,
        'redCards': 0,
        'minutesPlayed': 630,
        'stage': 'Final',
        'keyMoment': 'Scored in final',
      };
      final stats = WorldCupTournamentStats.fromMap(map);

      expect(stats.year, equals(2022));
      expect(stats.matches, equals(7));
      expect(stats.goals, equals(3));
      expect(stats.assists, equals(2));
      expect(stats.yellowCards, equals(1));
      expect(stats.redCards, equals(0));
      expect(stats.minutesPlayed, equals(630));
      expect(stats.stage, equals('Final'));
      expect(stats.keyMoment, equals('Scored in final'));
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'year': 2018,
        'matches': 5,
        'goals': 2,
        'assists': 1,
        'stage': 'Quarter-final',
      };
      final stats = WorldCupTournamentStats.fromMap(map);

      expect(stats.year, equals(2018));
      expect(stats.yellowCards, isNull);
      expect(stats.redCards, isNull);
      expect(stats.minutesPlayed, isNull);
      expect(stats.keyMoment, isNull);
    });

    test('fromMap handles empty map with defaults', () {
      final map = <String, dynamic>{};
      final stats = WorldCupTournamentStats.fromMap(map);

      expect(stats.year, equals(0));
      expect(stats.matches, equals(0));
      expect(stats.goals, equals(0));
      expect(stats.assists, equals(0));
      expect(stats.stage, equals(''));
    });

    test('toMap returns correct structure', () {
      final stats = WorldCupTournamentStats(
        year: 2022,
        matches: 7,
        goals: 3,
        assists: 2,
        yellowCards: 1,
        redCards: 0,
        minutesPlayed: 630,
        stage: 'Final',
        keyMoment: 'Scored in final',
      );
      final map = stats.toMap();

      expect(map['year'], equals(2022));
      expect(map['matches'], equals(7));
      expect(map['goals'], equals(3));
      expect(map['assists'], equals(2));
      expect(map['yellowCards'], equals(1));
      expect(map['redCards'], equals(0));
      expect(map['minutesPlayed'], equals(630));
      expect(map['stage'], equals('Final'));
      expect(map['keyMoment'], equals('Scored in final'));
    });
  });
}

/// Helper function to create a minimal Player with specified properties
Player _createPlayer({
  int marketValue = 0,
  String position = 'ST',
  int caps = 0,
  int goals = 0,
  int assists = 0,
}) {
  return Player(
    playerId: 'test_001',
    fifaCode: 'TST',
    firstName: 'Test',
    lastName: 'Player',
    fullName: 'Test Player',
    commonName: 'Test',
    jerseyNumber: 10,
    position: position,
    dateOfBirth: DateTime(1990, 1, 1),
    age: 34,
    height: 180,
    weight: 75,
    preferredFoot: 'Right',
    club: 'Test FC',
    clubLeague: 'Test League',
    photoUrl: '',
    marketValue: marketValue,
    caps: caps,
    goals: goals,
    assists: assists,
    worldCupAppearances: 0,
    worldCupGoals: 0,
    previousWorldCups: [],
    stats: PlayerStats(
      club: ClubStats(
        season: '2024-25',
        appearances: 0,
        goals: 0,
        assists: 0,
        minutesPlayed: 0,
      ),
      international: InternationalStats(
        appearances: 0,
        goals: 0,
        assists: 0,
        minutesPlayed: 0,
      ),
    ),
    honors: [],
    strengths: [],
    weaknesses: [],
    playStyle: '',
    keyMoment: '',
    comparisonToLegend: '',
    worldCup2026Prediction: '',
    socialMedia: SocialMedia(
      instagram: '',
      twitter: '',
      followers: 0,
    ),
    trivia: [],
  );
}

/// Helper function to create a full Player with all fields populated
Player _createFullPlayer() {
  return Player(
    playerId: 'player_001',
    fifaCode: 'BRA',
    firstName: 'Neymar',
    lastName: 'da Silva Santos Júnior',
    fullName: 'Neymar da Silva Santos Júnior',
    commonName: 'Neymar',
    jerseyNumber: 10,
    position: 'LW',
    dateOfBirth: DateTime(1992, 2, 5),
    age: 32,
    height: 175,
    weight: 68,
    preferredFoot: 'Right',
    club: 'Al-Hilal',
    clubLeague: 'Saudi Pro League',
    photoUrl: 'https://example.com/neymar.jpg',
    marketValue: 150000000,
    caps: 128,
    goals: 79,
    assists: 58,
    worldCupAppearances: 3,
    worldCupGoals: 8,
    worldCupAssists: 3,
    previousWorldCups: [2014, 2018, 2022],
    worldCupTournamentStats: [
      WorldCupTournamentStats(
        year: 2022,
        matches: 5,
        goals: 2,
        assists: 1,
        stage: 'Quarter-final',
      ),
    ],
    worldCupAwards: ['Bronze Boot 2014'],
    memorableMoments: ['Penalty in 2014 shootout'],
    worldCupLegacyRating: 8,
    stats: PlayerStats(
      club: ClubStats(
        season: '2024-25',
        appearances: 25,
        goals: 15,
        assists: 12,
        minutesPlayed: 2000,
      ),
      international: InternationalStats(
        appearances: 128,
        goals: 79,
        assists: 58,
        minutesPlayed: 10000,
      ),
    ),
    honors: ['Copa America 2019', 'Olympic Gold 2016'],
    strengths: ['Dribbling', 'Speed', 'Creativity'],
    weaknesses: ['Discipline', 'Diving'],
    playStyle: 'Creative and skillful winger',
    keyMoment: 'Leading Brazil to Olympic gold',
    comparisonToLegend: 'Modern day Ronaldinho',
    worldCup2026Prediction: 'Key player for Brazil',
    socialMedia: SocialMedia(
      instagram: '@neymarjr',
      twitter: '@neymarjr',
      followers: 200000000,
    ),
    trivia: ['Youngest Brazilian to score in a World Cup'],
  );
}
