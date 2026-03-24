import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../bloc/mock_repositories.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        FlutterError.presentError(details);
      }
    };
  });

  group('MatchWatchPartiesCard', () {
    testWidgets('can be constructed with match', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = MatchWatchPartiesCard(match: match);

      expect(widget, isNotNull);
      expect(widget.match, equals(match));
    });

    testWidgets('is a StatelessWidget', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = MatchWatchPartiesCard(match: match);

      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('stores match data correctly', (tester) async {
      final match = TestDataFactory.createMatch(
        matchId: 'test_match',
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      );

      final widget = MatchWatchPartiesCard(match: match);

      expect(widget.match.matchId, 'test_match');
      expect(widget.match.homeTeamName, 'Brazil');
      expect(widget.match.awayTeamName, 'Argentina');
    });

    testWidgets('widget type verification', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = MatchWatchPartiesCard(match: match);

      expect(widget, isA<Widget>());
      expect(widget, isA<StatelessWidget>());
      expect(widget.runtimeType.toString(), 'MatchWatchPartiesCard');
    });

    testWidgets('handles different match data', (tester) async {
      final match = TestDataFactory.createMatch(
        matchId: 'match_123',
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
        dateTime: DateTime(2026, 6, 15, 18, 0),
      );

      final widget = MatchWatchPartiesCard(match: match);

      expect(widget.match.matchId, 'match_123');
      expect(widget.match.homeTeamName, 'United States');
      expect(widget.match.awayTeamName, 'Mexico');
      expect(widget.match.dateTime, DateTime(2026, 6, 15, 18, 0));
    });

    testWidgets('can be constructed with key', (tester) async {
      final match = TestDataFactory.createMatch();
      final key = const Key('watch_parties_card');

      final widget = MatchWatchPartiesCard(
        key: key,
        match: match,
      );

      expect(widget.key, equals(key));
      expect(widget.match, equals(match));
    });
  });
}
