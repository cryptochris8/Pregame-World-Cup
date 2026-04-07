import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

void main() {
  group('TeamDetailPage', () {
    final testTeam = NationalTeam(
      teamCode: 'USA',
      countryName: 'United States',
      shortName: 'USA',
      flagUrl: '',
      confederation: Confederation.concacaf,
      group: 'A',
      worldCupTitles: 0,
      isHostNation: true,
    );

    test('is a StatelessWidget', () {
      expect(TeamDetailPage(team: testTeam), isA<StatelessWidget>());
    });

    test('stores team parameter', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team, equals(testTeam));
    });

    test('team has correct team code', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.teamCode, 'USA');
    });

    test('team has correct country name', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.countryName, 'United States');
    });

    test('accepts a key parameter', () {
      const key = Key('test');
      final widget = TeamDetailPage(key: key, team: testTeam);
      expect(widget.key, equals(key));
    });

    test('team has correct confederation', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.confederation, Confederation.concacaf);
    });

    test('works with different team data', () {
      final brTeam = NationalTeam(
        teamCode: 'BRA',
        countryName: 'Brazil',
        shortName: 'BRA',
        flagUrl: '',
        confederation: Confederation.conmebol,
        group: 'B',
        worldCupTitles: 5,
        isHostNation: false,
      );
      final widget = TeamDetailPage(team: brTeam);
      expect(widget.team.teamCode, 'BRA');
      expect(widget.team.worldCupTitles, 5);
    });

    test('team stores correct group', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.group, 'A');
    });

    test('team stores correct host nation status', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.isHostNation, isTrue);
    });

    test('team stores correct short name', () {
      final widget = TeamDetailPage(team: testTeam);
      expect(widget.team.shortName, 'USA');
    });
  });
}
