import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/data/services/chatbot_knowledge_base.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../helpers/mock_knowledge_data.dart';

void main() {
  late ChatbotKnowledgeBase kb;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAssetBundle();

    kb = ChatbotKnowledgeBase(enhancedData: EnhancedMatchDataService.instance);
    await kb.initialize();
  });

  tearDownAll(() {
    tearDownMockAssetBundle();
  });

  group('Initialization', () {
    test('isInitialized is true after init', () {
      expect(kb.isInitialized, isTrue);
    });

    test('team aliases are populated', () {
      expect(kb.teamAliases, isNotEmpty);
    });
  });

  group('Team alias resolution', () {
    test('resolves FIFA code', () {
      expect(kb.resolveTeamCode('USA'), 'USA');
      expect(kb.resolveTeamCode('usa'), 'USA');
      expect(kb.resolveTeamCode('ARG'), 'ARG');
    });

    test('resolves country name', () {
      expect(kb.resolveTeamCode('United States'), 'USA');
      expect(kb.resolveTeamCode('Argentina'), 'ARG');
      expect(kb.resolveTeamCode('Brazil'), 'BRA');
      expect(kb.resolveTeamCode('Mexico'), 'MEX');
    });

    test('resolves nicknames', () {
      expect(kb.resolveTeamCode('usmnt'), 'USA');
      expect(kb.resolveTeamCode('la albiceleste'), 'ARG');
      expect(kb.resolveTeamCode('selecao'), 'BRA');
      expect(kb.resolveTeamCode('el tri'), 'MEX');
    });

    test('returns null for unknown teams', () {
      expect(kb.resolveTeamCode('Narnia'), isNull);
      expect(kb.resolveTeamCode('asdf'), isNull);
    });
  });

  group('Match queries', () {
    test('getMatchesForTeam returns matches', () {
      final matches = kb.getMatchesForTeam('USA');
      expect(matches, isNotEmpty);
      // USA plays in 2 group stage matches in our mock data
      expect(matches.length, 2);
    });

    test('getMatchesForTeam returns empty for unknown team', () {
      final matches = kb.getMatchesForTeam('XYZ');
      expect(matches, isEmpty);
    });

    test('getNextMatch returns first scheduled match', () {
      final next = kb.getNextMatch('USA');
      expect(next, isNotNull);
      expect(next!['date'], '2026-06-12');
    });

    test('getGroupMatches returns matches in group', () {
      final matches = kb.getGroupMatches('B');
      expect(matches, isNotEmpty);
      // 3 group B matches in mock data
      expect(matches.length, 3);
    });

    test('getGroupMatches returns empty for invalid group', () {
      expect(kb.getGroupMatches('Z'), isEmpty);
    });
  });

  group('Team/Group data', () {
    test('getTeamName returns name from match data', () {
      expect(kb.getTeamName('USA'), 'United States');
      expect(kb.getTeamName('ARG'), 'Argentina');
      expect(kb.getTeamName('MEX'), 'Mexico');
    });

    test('getTeamGroup returns correct group', () {
      expect(kb.getTeamGroup('USA'), 'B');
      expect(kb.getTeamGroup('MEX'), 'A');
    });

    test('getTeamsInGroup returns teams in a group', () {
      final teams = kb.getTeamsInGroup('B');
      expect(teams, contains('USA'));
      expect(teams, contains('BRA'));
      expect(teams, contains('ARG'));
    });
  });

  group('Venue queries', () {
    test('getAllVenues returns unique venues', () {
      final venues = kb.getAllVenues();
      expect(venues, isNotEmpty);
      expect(venues, contains('SoFi Stadium'));
      expect(venues, contains('Estadio Azteca'));
      expect(venues, contains('MetLife Stadium'));
    });

    test('getVenueMatches returns matches at venue', () {
      final matches = kb.getVenueMatches('MetLife Stadium');
      expect(matches, isNotEmpty);
    });

    test('getVenueMatches supports partial match', () {
      final matches = kb.getVenueMatches('metlife');
      expect(matches, isNotEmpty);
    });
  });

  group('Lazy-loaded data', () {
    test('getTeamData loads team squad', () async {
      final team = await kb.getTeamData('usa');
      expect(team, isNotNull);
      expect(team!['fifaCode'], 'USA');
      expect(team['players'], isA<List>());
      expect((team['players'] as List).length, 2);
    });

    test('getTeamData caches results', () async {
      final first = await kb.getTeamData('arg');
      final second = await kb.getTeamData('arg');
      expect(identical(first, second), isTrue);
    });

    test('getManager loads manager data', () async {
      final mgr = await kb.getManager('usa');
      expect(mgr, isNotNull);
      expect(mgr!['commonName'], 'Mauricio Pochettino');
      expect(mgr['preferredFormation'], '4-3-3');
    });

    test('getHeadToHead loads h2h data', () async {
      final h2h = await kb.getHeadToHead('ARG', 'BRA');
      expect(h2h, isNotNull);
      expect(h2h!['totalMatches'], 111);
      expect(h2h['team1Wins'], 40);
    });

    test('getHeadToHead tries both orderings', () async {
      // Try reversed order — should still find ARG_BRA file
      final h2h = await kb.getHeadToHead('BRA', 'ARG');
      expect(h2h, isNotNull);
      expect(h2h!['totalMatches'], 111);
    });

    test('getHeadToHead returns null for unknown pair', () async {
      final h2h = await kb.getHeadToHead('USA', 'NZL');
      expect(h2h, isNull);
    });

    test('getMatchSummary loads preview data', () async {
      final summary = await kb.getMatchSummary('ARG', 'BRA');
      expect(summary, isNotNull);
      expect(summary!['historicalAnalysis'], contains('greatest'));
    });

    test('getPlayerStats loads player data', () async {
      final stats = await kb.getPlayerStats('messi');
      expect(stats, isNotNull);
      expect(stats!['playerName'], 'Lionel Messi');
      expect(stats['worldCupGoals'], 13);
    });
  });

  group('History data', () {
    test('getRecords returns records list', () {
      final records = kb.getRecords();
      expect(records, isNotEmpty);
      expect(records.length, 3);
    });

    test('getTournamentByYear returns correct tournament', () {
      final t = kb.getTournamentByYear(2022);
      expect(t, isNotNull);
      expect(t!['winner'], 'Argentina');
    });

    test('getTournamentByYear returns null for invalid year', () {
      expect(kb.getTournamentByYear(2023), isNull);
    });

    test('getAllTournaments returns all tournaments', () {
      expect(kb.getAllTournaments().length, 2);
    });
  });

  group('Delegates to EnhancedMatchDataService', () {
    test('getSquadValue returns data', () {
      final sv = kb.getSquadValue('USA');
      expect(sv, isNotNull);
      expect(sv!['totalValueFormatted'], '\$500M');
    });

    test('getBettingOdds returns data', () {
      final odds = kb.getBettingOdds('ARG');
      expect(odds, isNotNull);
      expect(odds!['odds_american'], '+700');
    });

    test('getInjuryConcerns returns non-fit players', () {
      final injuries = kb.getInjuryConcerns('USA');
      expect(injuries, isNotEmpty);
      expect(injuries.first['playerName'], 'Christian Pulisic');
    });

    test('getInjuryConcerns returns empty for clean team', () {
      final injuries = kb.getInjuryConcerns('MEX');
      expect(injuries, isEmpty);
    });

    test('getRecentFormSummary returns form string', () {
      final form = kb.getRecentFormSummary('USA');
      expect(form, isNotNull);
      expect(form, contains('W'));
    });
  });

  group('getTopFavorites', () {
    test('returns favorites sorted by probability', () {
      final favorites = kb.getTopFavorites(limit: 3);
      expect(favorites, isNotEmpty);
      // France has highest implied probability (18.2%)
      expect(favorites.first['team'], 'France');
    });

    test('respects limit', () {
      final favorites = kb.getTopFavorites(limit: 2);
      expect(favorites.length, lessThanOrEqualTo(2));
    });
  });
}
