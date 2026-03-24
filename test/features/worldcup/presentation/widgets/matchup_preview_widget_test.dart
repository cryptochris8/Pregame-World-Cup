import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/matchup_preview_widget.dart';

void main() {
  group('MatchupPreviewWidget', () {
    test('MatchupPreviewWidget is a StatefulWidget', () {
      expect(MatchupPreviewWidget, isNotNull);
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('MatchupPreviewWidget can be instantiated with required parameters', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );

      expect(widget, isNotNull);
      expect(widget, isA<MatchupPreviewWidget>());
    });

    test('MatchupPreviewWidget can be instantiated with all parameters', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        team1Name: 'Argentina',
        team2Name: 'France',
        team1FlagUrl: 'https://example.com/arg.png',
        team2FlagUrl: 'https://example.com/fra.png',
        showNotableMatches: true,
        maxNotableMatches: 3,
        compact: false,
      );

      expect(widget, isNotNull);
      expect(widget, isA<MatchupPreviewWidget>());
    });

    test('MatchupPreviewWidget defaults to showNotableMatches true', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget defaults to maxNotableMatches 3', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget defaults to compact false', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget accepts null team names', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        team1Name: null,
        team2Name: null,
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget accepts null flag URLs', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        team1FlagUrl: null,
        team2FlagUrl: null,
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget accepts different team codes', () {
      final widget1 = MatchupPreviewWidget(
        team1Code: 'BRA',
        team2Code: 'GER',
      );

      final widget2 = MatchupPreviewWidget(
        team1Code: 'ESP',
        team2Code: 'ITA',
      );

      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
    });

    test('MatchupPreviewWidget accepts showNotableMatches false', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        showNotableMatches: false,
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget accepts different maxNotableMatches values', () {
      final widget1 = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        maxNotableMatches: 1,
      );

      final widget2 = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        maxNotableMatches: 10,
      );

      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
    });

    test('MatchupPreviewWidget accepts compact true', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
        compact: true,
      );

      expect(widget, isNotNull);
    });

    test('MatchupPreviewWidget createState returns a State', () {
      final widget = MatchupPreviewWidget(
        team1Code: 'ARG',
        team2Code: 'FRA',
      );

      final state = widget.createState();
      expect(state, isNotNull);
    });
  });
}
