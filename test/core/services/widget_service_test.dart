import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/widget_service.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import '../../features/worldcup/presentation/bloc/mock_repositories.dart';

void main() {
  group('WidgetConfiguration', () {
    test('has correct default values', () {
      const config = WidgetConfiguration();
      expect(config.showLiveScores, true);
      expect(config.showUpcomingMatches, true);
      expect(config.upcomingMatchCount, 3);
      expect(config.favoriteTeamCode, null);
      expect(config.compactMode, false);
    });

    test('toMap converts to map correctly', () {
      const config = WidgetConfiguration(
        showLiveScores: false,
        showUpcomingMatches: true,
        upcomingMatchCount: 5,
        favoriteTeamCode: 'USA',
        compactMode: true,
      );

      final map = config.toMap();
      expect(map['showLiveScores'], false);
      expect(map['showUpcomingMatches'], true);
      expect(map['upcomingMatchCount'], 5);
      expect(map['favoriteTeamCode'], 'USA');
      expect(map['compactMode'], true);
    });

    test('fromMap creates configuration from map', () {
      final map = {
        'showLiveScores': false,
        'showUpcomingMatches': true,
        'upcomingMatchCount': 5,
        'favoriteTeamCode': 'BRA',
        'compactMode': true,
      };

      final config = WidgetConfiguration.fromMap(map);
      expect(config.showLiveScores, false);
      expect(config.showUpcomingMatches, true);
      expect(config.upcomingMatchCount, 5);
      expect(config.favoriteTeamCode, 'BRA');
      expect(config.compactMode, true);
    });

    test('fromMap uses defaults for missing fields', () {
      final map = <String, dynamic>{};
      final config = WidgetConfiguration.fromMap(map);
      expect(config.showLiveScores, true);
      expect(config.showUpcomingMatches, true);
      expect(config.upcomingMatchCount, 3);
      expect(config.favoriteTeamCode, null);
      expect(config.compactMode, false);
    });

    test('fromMap uses defaults for null values', () {
      final map = {
        'showLiveScores': null,
        'showUpcomingMatches': null,
        'upcomingMatchCount': null,
        'favoriteTeamCode': null,
        'compactMode': null,
      };

      final config = WidgetConfiguration.fromMap(map);
      expect(config.showLiveScores, true);
      expect(config.showUpcomingMatches, true);
      expect(config.upcomingMatchCount, 3);
      expect(config.favoriteTeamCode, null);
      expect(config.compactMode, false);
    });

    test('toMap and fromMap round-trip correctly', () {
      const original = WidgetConfiguration(
        showLiveScores: false,
        showUpcomingMatches: true,
        upcomingMatchCount: 7,
        favoriteTeamCode: 'ARG',
        compactMode: true,
      );

      final map = original.toMap();
      final restored = WidgetConfiguration.fromMap(map);

      expect(restored.showLiveScores, original.showLiveScores);
      expect(restored.showUpcomingMatches, original.showUpcomingMatches);
      expect(restored.upcomingMatchCount, original.upcomingMatchCount);
      expect(restored.favoriteTeamCode, original.favoriteTeamCode);
      expect(restored.compactMode, original.compactMode);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = WidgetConfiguration(
        showLiveScores: true,
        upcomingMatchCount: 3,
      );

      final updated = original.copyWith(
        showLiveScores: false,
        favoriteTeamCode: 'MEX',
      );

      expect(updated.showLiveScores, false);
      expect(updated.upcomingMatchCount, 3); // unchanged
      expect(updated.favoriteTeamCode, 'MEX');
    });

    test('copyWith with no parameters returns equivalent instance', () {
      const original = WidgetConfiguration(
        showLiveScores: false,
        upcomingMatchCount: 5,
        favoriteTeamCode: 'GER',
      );

      final copy = original.copyWith();

      expect(copy.showLiveScores, original.showLiveScores);
      expect(copy.upcomingMatchCount, original.upcomingMatchCount);
      expect(copy.favoriteTeamCode, original.favoriteTeamCode);
    });
  });

  group('WidgetMatchData', () {
    test('toMap converts to map correctly', () {
      final matchTime = DateTime(2026, 6, 15, 18, 0);
      final matchData = WidgetMatchData(
        matchId: 'match_1',
        homeTeam: 'United States',
        awayTeam: 'Mexico',
        homeTeamCode: 'USA',
        awayTeamCode: 'MEX',
        homeFlag: '🇺🇸',
        awayFlag: '🇲🇽',
        homeScore: 2,
        awayScore: 1,
        matchTime: matchTime,
        status: 'completed',
        venue: 'MetLife Stadium',
        stage: 'Group Stage',
      );

      final map = matchData.toMap();
      expect(map['matchId'], 'match_1');
      expect(map['homeTeam'], 'United States');
      expect(map['awayTeam'], 'Mexico');
      expect(map['homeTeamCode'], 'USA');
      expect(map['awayTeamCode'], 'MEX');
      expect(map['homeFlag'], '🇺🇸');
      expect(map['awayFlag'], '🇲🇽');
      expect(map['homeScore'], 2);
      expect(map['awayScore'], 1);
      expect(map['matchTime'], matchTime.toIso8601String());
      expect(map['status'], 'completed');
      expect(map['venue'], 'MetLife Stadium');
      expect(map['stage'], 'Group Stage');
    });

    test('fromMap creates match data from map', () {
      final matchTime = DateTime(2026, 6, 15, 18, 0);
      final map = {
        'matchId': 'match_2',
        'homeTeam': 'Brazil',
        'awayTeam': 'Argentina',
        'homeTeamCode': 'BRA',
        'awayTeamCode': 'ARG',
        'homeFlag': '🇧🇷',
        'awayFlag': '🇦🇷',
        'homeScore': 3,
        'awayScore': 2,
        'matchTime': matchTime.toIso8601String(),
        'status': 'live',
        'venue': 'Estadio Azteca',
        'stage': 'Final',
      };

      final matchData = WidgetMatchData.fromMap(map);
      expect(matchData.matchId, 'match_2');
      expect(matchData.homeTeam, 'Brazil');
      expect(matchData.awayTeam, 'Argentina');
      expect(matchData.homeTeamCode, 'BRA');
      expect(matchData.awayTeamCode, 'ARG');
      expect(matchData.homeFlag, '🇧🇷');
      expect(matchData.awayFlag, '🇦🇷');
      expect(matchData.homeScore, 3);
      expect(matchData.awayScore, 2);
      expect(matchData.matchTime, matchTime);
      expect(matchData.status, 'live');
      expect(matchData.venue, 'Estadio Azteca');
      expect(matchData.stage, 'Final');
    });

    test('toMap and fromMap round-trip correctly', () {
      final matchTime = DateTime(2026, 7, 1, 15, 0);
      final original = WidgetMatchData(
        matchId: 'match_3',
        homeTeam: 'Germany',
        awayTeam: 'France',
        homeTeamCode: 'GER',
        awayTeamCode: 'FRA',
        homeFlag: '🇩🇪',
        awayFlag: '🇫🇷',
        homeScore: 1,
        awayScore: 0,
        matchTime: matchTime,
        status: 'halftime',
        venue: 'Rose Bowl',
        stage: 'Semi-Final',
      );

      final map = original.toMap();
      final restored = WidgetMatchData.fromMap(map);

      expect(restored.matchId, original.matchId);
      expect(restored.homeTeam, original.homeTeam);
      expect(restored.awayTeam, original.awayTeam);
      expect(restored.homeTeamCode, original.homeTeamCode);
      expect(restored.awayTeamCode, original.awayTeamCode);
      expect(restored.homeFlag, original.homeFlag);
      expect(restored.awayFlag, original.awayFlag);
      expect(restored.homeScore, original.homeScore);
      expect(restored.awayScore, original.awayScore);
      expect(restored.matchTime, original.matchTime);
      expect(restored.status, original.status);
      expect(restored.venue, original.venue);
      expect(restored.stage, original.stage);
    });

    test('fromMap handles null scores correctly', () {
      final map = {
        'matchId': 'match_4',
        'homeTeam': 'Spain',
        'awayTeam': 'Portugal',
        'homeTeamCode': 'ESP',
        'awayTeamCode': 'POR',
        'homeFlag': '🇪🇸',
        'awayFlag': '🇵🇹',
        'homeScore': null,
        'awayScore': null,
        'matchTime': DateTime(2026, 6, 20).toIso8601String(),
        'status': 'upcoming',
        'venue': 'SoFi Stadium',
        'stage': 'Group Stage',
      };

      final matchData = WidgetMatchData.fromMap(map);
      expect(matchData.homeScore, null);
      expect(matchData.awayScore, null);
    });
  });

  group('WidgetMatchData.fromWorldCupMatch', () {
    test('converts scheduled match to upcoming status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_1',
        status: MatchStatus.scheduled,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        dateTime: DateTime(2026, 6, 15, 18, 0),
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'upcoming');
      expect(widgetData.matchId, 'wc_1');
      expect(widgetData.homeTeam, 'United States');
      expect(widgetData.awayTeam, 'Mexico');
      expect(widgetData.homeTeamCode, 'USA');
      expect(widgetData.awayTeamCode, 'MEX');
    });

    test('converts inProgress match to live status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_2',
        status: MatchStatus.inProgress,
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'ARG',
        awayTeamName: 'Argentina',
        homeScore: 1,
        awayScore: 1,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'live');
      expect(widgetData.homeScore, 1);
      expect(widgetData.awayScore, 1);
    });

    test('converts halfTime match to halftime status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_3',
        status: MatchStatus.halfTime,
        homeTeamCode: 'GER',
        homeTeamName: 'Germany',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
        homeScore: 0,
        awayScore: 1,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'halftime');
    });

    test('converts completed match to completed status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_4',
        status: MatchStatus.completed,
        homeTeamCode: 'ESP',
        homeTeamName: 'Spain',
        awayTeamCode: 'ITA',
        awayTeamName: 'Italy',
        homeScore: 2,
        awayScore: 0,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'completed');
    });

    test('converts extraTime match to live status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_5',
        status: MatchStatus.extraTime,
        homeTeamCode: 'ENG',
        homeTeamName: 'England',
        awayTeamCode: 'NED',
        awayTeamName: 'Netherlands',
        homeScore: 2,
        awayScore: 2,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'live');
    });

    test('converts penalties match to live status', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_6',
        status: MatchStatus.penalties,
        homeTeamCode: 'POR',
        homeTeamName: 'Portugal',
        awayTeamCode: 'BEL',
        awayTeamName: 'Belgium',
        homeScore: 1,
        awayScore: 1,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.status, 'live');
    });

    test('includes flag emojis for known team codes', () {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.homeFlag, '🇺🇸');
      expect(widgetData.awayFlag, '🇲🇽');
    });

    test('uses empty string for unknown team code flags', () {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'XXX',
        homeTeamName: 'Unknown Team',
        awayTeamCode: 'YYY',
        awayTeamName: 'Another Unknown',
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.homeFlag, '');
      expect(widgetData.awayFlag, '');
    });

    test('handles null team codes with TBD placeholder', () {
      final match = TestDataFactory.createMatch(
        homeTeamCode: null,
        homeTeamName: 'TBD',
        awayTeamCode: null,
        awayTeamName: 'TBD',
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.homeTeamCode, 'TBD');
      expect(widgetData.awayTeamCode, 'TBD');
      expect(widgetData.homeFlag, '');
      expect(widgetData.awayFlag, '');
    });

    test('includes venue name from WorldCupMatch', () {
      final venue = TestDataFactory.createVenue(
        name: 'MetLife Stadium',
        city: 'East Rutherford',
      );
      final match = TestDataFactory.createMatch(
        matchId: 'wc_7',
      );
      final matchWithVenue = match.copyWith(venue: venue);

      final widgetData = WidgetMatchData.fromWorldCupMatch(matchWithVenue);
      expect(widgetData.venue, 'MetLife Stadium');
    });

    test('uses TBD for missing venue', () {
      final match = TestDataFactory.createMatch(
        matchId: 'wc_8',
      );
      final matchNoVenue = match.copyWith(venue: null, venueId: null);

      final widgetData = WidgetMatchData.fromWorldCupMatch(matchNoVenue);
      expect(widgetData.venue, 'TBD');
    });

    test('includes stage display name', () {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.groupStage,
      );

      final widgetData = WidgetMatchData.fromWorldCupMatch(match);
      expect(widgetData.stage, match.stage.displayName);
    });

    test('uses dateTimeUtc or falls back to DateTime.now', () {
      final specificDate = DateTime.utc(2026, 6, 15, 18, 0);
      final match = TestDataFactory.createMatch(
        dateTime: specificDate,
      );
      final matchWithUtc = match.copyWith(dateTimeUtc: specificDate);

      final widgetData = WidgetMatchData.fromWorldCupMatch(matchWithUtc);
      expect(widgetData.matchTime, specificDate);
    });

    test('falls back to DateTime.now when dateTimeUtc is null', () {
      final match = TestDataFactory.createMatch(
        dateTime: null,
      );
      final matchNoDate = match.copyWith(dateTimeUtc: null);

      final now = DateTime.now();
      final widgetData = WidgetMatchData.fromWorldCupMatch(matchNoDate);

      // Should be within 1 second of now
      expect(widgetData.matchTime.difference(now).inSeconds.abs(), lessThan(2));
    });
  });
}
