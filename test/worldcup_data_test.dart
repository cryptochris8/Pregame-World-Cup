import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/data/datasources/world_cup_firestore_datasource.dart';

/// Integration tests for World Cup data models and Firestore
///
/// Run with: flutter test test/worldcup_data_test.dart
void main() {
  group('World Cup Firestore Data Source Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late WorldCupFirestoreDataSource dataSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      dataSource = WorldCupFirestoreDataSource(firestore: fakeFirestore);
    });

    test('Can initialize datasource with fake Firestore', () {
      // Verify datasource initializes correctly
      expect(dataSource, isNotNull);
      expect(fakeFirestore, isNotNull);
    });

    test('Can read national teams from Firestore', () async {
      // Arrange: Add sample team to fake Firestore
      await fakeFirestore.collection('worldcup_teams').doc('USA').set({
        'fifaCode': 'USA',
        'countryName': 'United States',
        'shortName': 'USA',
        'flagUrl': 'assets/worldcup/flags/usa.png',
        'confederation': 'concacaf',
        'fifaRanking': 13,
        'group': 'A',
        'worldCupTitles': 0,
        'worldCupAppearances': 11,
        'bestFinish': 'Third Place (1930)',
        'isHostNation': true,
        'nickname': 'USMNT',
        'coachName': 'Gregg Berhalter',
        'captainName': 'Christian Pulisic',
        'starPlayers': ['Christian Pulisic', 'Weston McKennie'],
        'qualificationMethod': 'Host Nation',
        'isQualified': true,
        'primaryColor': '#002868',
        'secondaryColor': '#BF0A30',
      });

      // Act: Fetch teams
      final teams = await dataSource.getAllTeams();

      // Assert
      expect(teams, isNotEmpty);
      expect(teams.length, equals(1));
      expect(teams.first.fifaCode, equals('USA'));
      expect(teams.first.countryName, equals('United States'));
      expect(teams.first.confederation, equals(Confederation.concacaf));
      expect(teams.first.isHostNation, isTrue);
    });

    test('Can read World Cup matches from Firestore', () async {
      // Arrange: Add sample match
      await fakeFirestore.collection('worldcup_matches').doc('wc2026_001').set({
        'matchId': 'wc2026_001',
        'matchNumber': 1,
        'stage': 'groupStage',
        'group': 'A',
        'homeTeamCode': 'MEX',
        'homeTeamName': 'Mexico',
        'awayTeamCode': 'TBD',
        'awayTeamName': 'TBD',
        'venueId': 'azteca',
        'dateTime': Timestamp.fromDate(DateTime(2026, 6, 11, 14, 0)),
        'dateTimeUtc': Timestamp.fromDate(DateTime(2026, 6, 11, 20, 0)),
        'status': 'scheduled',
        'broadcastChannels': ['FOX', 'Telemundo'],
      });

      // Act
      final matches = await dataSource.getAllMatches();

      // Assert
      expect(matches, isNotEmpty);
      expect(matches.length, equals(1));
      expect(matches.first.matchNumber, equals(1));
      expect(matches.first.stage, equals(MatchStage.groupStage));
      expect(matches.first.homeTeamCode, equals('MEX'));
      expect(matches.first.status, equals(MatchStatus.scheduled));
    });

    test('Can read venues from Firestore', () async {
      // Arrange: Add sample venue
      await fakeFirestore.collection('worldcup_venues').doc('metlife').set({
        'venueId': 'metlife',
        'name': 'MetLife Stadium',
        'city': 'East Rutherford',
        'state': 'New Jersey',
        'country': 'USA',
        'capacity': 82500,
        'latitude': 40.8128,
        'longitude': -74.0742,
        'timeZone': 'America/New_York',
        'address': '1 MetLife Stadium Dr',
        'significance': 'FINAL VENUE',
        'matchesHosted': 8,
      });

      // Act
      final venues = await dataSource.getAllVenues();

      // Assert
      expect(venues, isNotEmpty);
      expect(venues.first.name, equals('MetLife Stadium'));
      expect(venues.first.capacity, equals(82500));
      expect(venues.first.country, equals(HostCountry.usa));
    });

    test('Can filter matches by stage', () async {
      // Arrange: Add matches at different stages
      await fakeFirestore.collection('worldcup_matches').doc('wc_group_1').set({
        'matchNumber': 1,
        'stage': 'groupStage',
        'status': 'scheduled',
      });

      await fakeFirestore.collection('worldcup_matches').doc('wc_final').set({
        'matchNumber': 104,
        'stage': 'final_',
        'status': 'scheduled',
      });

      // Act
      final groupMatches = await dataSource.getMatchesByStage(MatchStage.groupStage);
      final finalMatches = await dataSource.getMatchesByStage(MatchStage.final_);

      // Assert
      expect(groupMatches.length, equals(1));
      expect(finalMatches.length, equals(1));
      expect(finalMatches.first.stage, equals(MatchStage.final_));
    });

    test('Can get teams by confederation', () async {
      // Arrange: Add teams from different confederations
      await fakeFirestore.collection('worldcup_teams').doc('USA').set({
        'fifaCode': 'USA',
        'countryName': 'United States',
        'confederation': 'concacaf',
      });

      await fakeFirestore.collection('worldcup_teams').doc('BRA').set({
        'fifaCode': 'BRA',
        'countryName': 'Brazil',
        'confederation': 'conmebol',
      });

      await fakeFirestore.collection('worldcup_teams').doc('GER').set({
        'fifaCode': 'GER',
        'countryName': 'Germany',
        'confederation': 'uefa',
      });

      // Act
      final allTeams = await dataSource.getAllTeams();
      final concacafTeams = allTeams.where((t) => t.confederation == Confederation.concacaf).toList();
      final uefaTeams = allTeams.where((t) => t.confederation == Confederation.uefa).toList();

      // Assert
      expect(concacafTeams.length, equals(1));
      expect(uefaTeams.length, equals(1));
      expect(concacafTeams.first.fifaCode, equals('USA'));
      expect(uefaTeams.first.fifaCode, equals('GER'));
    });

    test('Can get teams by group', () async {
      // Arrange: Add teams in Group A
      await fakeFirestore.collection('worldcup_teams').doc('USA').set({
        'fifaCode': 'USA',
        'countryName': 'United States',
        'group': 'A',
      });

      await fakeFirestore.collection('worldcup_teams').doc('BRA').set({
        'fifaCode': 'BRA',
        'countryName': 'Brazil',
        'group': 'A',
      });

      await fakeFirestore.collection('worldcup_teams').doc('ARG').set({
        'fifaCode': 'ARG',
        'countryName': 'Argentina',
        'group': 'B',
      });

      // Act
      final groupATeams = await dataSource.getTeamsByGroup('A');

      // Assert
      expect(groupATeams.length, equals(2));
      expect(groupATeams.any((t) => t.fifaCode == 'USA'), isTrue);
      expect(groupATeams.any((t) => t.fifaCode == 'BRA'), isTrue);
      expect(groupATeams.any((t) => t.fifaCode == 'ARG'), isFalse);
    });

    test('WorldCupMatch entity parses all fields correctly', () {
      // Arrange
      final matchData = {
        'matchId': 'test_match',
        'matchNumber': 1,
        'stage': 'groupStage',
        'group': 'A',
        'homeTeamCode': 'USA',
        'homeTeamName': 'United States',
        'awayTeamCode': 'MEX',
        'awayTeamName': 'Mexico',
        'dateTime': Timestamp.fromDate(DateTime(2026, 6, 11)),
        'status': 'scheduled',
      };

      // Act
      final match = WorldCupMatch.fromFirestore(matchData, 'test_match');

      // Assert
      expect(match.matchId, equals('test_match'));
      expect(match.matchNumber, equals(1));
      expect(match.stage, equals(MatchStage.groupStage));
      expect(match.homeTeamCode, equals('USA'));
      expect(match.awayTeamCode, equals('MEX'));
      expect(match.status, equals(MatchStatus.scheduled));
    });

    test('NationalTeam entity parses all fields correctly', () {
      // Arrange
      final teamData = {
        'fifaCode': 'USA',
        'countryName': 'United States',
        'shortName': 'USA',
        'confederation': 'concacaf',
        'fifaRanking': 13,
        'worldCupTitles': 0,
        'isHostNation': true,
        'starPlayers': ['Pulisic', 'McKennie'],
      };

      // Act
      final team = NationalTeam.fromFirestore(teamData, 'USA');

      // Assert
      expect(team.fifaCode, equals('USA'));
      expect(team.countryName, equals('United States'));
      expect(team.confederation, equals(Confederation.concacaf));
      expect(team.isHostNation, isTrue);
      expect(team.starPlayers.length, equals(2));
    });
  });

  group('Data Model Validation', () {
    test('MatchStage enum has all expected values', () {
      expect(MatchStage.values.length, equals(7));
      expect(MatchStage.values, contains(MatchStage.groupStage));
      expect(MatchStage.values, contains(MatchStage.roundOf32));
      expect(MatchStage.values, contains(MatchStage.roundOf16));
      expect(MatchStage.values, contains(MatchStage.quarterFinal));
      expect(MatchStage.values, contains(MatchStage.semiFinal));
      expect(MatchStage.values, contains(MatchStage.thirdPlace));
      expect(MatchStage.values, contains(MatchStage.final_));
    });

    test('Confederation enum has all 6 confederations', () {
      expect(Confederation.values.length, equals(6));
      expect(Confederation.values, contains(Confederation.uefa));
      expect(Confederation.values, contains(Confederation.conmebol));
      expect(Confederation.values, contains(Confederation.concacaf));
      expect(Confederation.values, contains(Confederation.afc));
      expect(Confederation.values, contains(Confederation.caf));
      expect(Confederation.values, contains(Confederation.ofc));
    });

    test('MatchStatus enum includes all status types', () {
      expect(MatchStatus.values, contains(MatchStatus.scheduled));
      expect(MatchStatus.values, contains(MatchStatus.inProgress));
      expect(MatchStatus.values, contains(MatchStatus.halfTime));
      expect(MatchStatus.values, contains(MatchStatus.extraTime));
      expect(MatchStatus.values, contains(MatchStatus.penalties));
      expect(MatchStatus.values, contains(MatchStatus.completed));
    });

    test('MatchStage display names are correct', () {
      expect(MatchStage.groupStage.displayName, equals('Group Stage'));
      expect(MatchStage.roundOf16.displayName, equals('Round of 16'));
      expect(MatchStage.quarterFinal.displayName, equals('Quarter-Final'));
      expect(MatchStage.semiFinal.displayName, equals('Semi-Final'));
      expect(MatchStage.final_.displayName, equals('Final'));
    });
  });
}
