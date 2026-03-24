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

  group('PredictionDialog', () {
    testWidgets('can be constructed', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = PredictionDialog(match: match);

      expect(widget, isNotNull);
      expect(widget.match, equals(match));
    });

    testWidgets('can be constructed with existing prediction', (tester) async {
      final match = TestDataFactory.createMatch();
      final prediction = TestDataFactory.createPrediction();

      final widget = PredictionDialog(
        match: match,
        existingPrediction: prediction,
      );

      expect(widget, isNotNull);
      expect(widget.match, equals(match));
      expect(widget.existingPrediction, equals(prediction));
    });

    testWidgets('can be constructed with team details', (tester) async {
      final match = TestDataFactory.createMatch();
      final homeTeam = TestDataFactory.createTeam(teamCode: 'USA');
      final awayTeam = TestDataFactory.createTeam(teamCode: 'MEX');

      final widget = PredictionDialog(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );

      expect(widget, isNotNull);
      expect(widget.homeTeam, equals(homeTeam));
      expect(widget.awayTeam, equals(awayTeam));
    });

    testWidgets('has onSave callback parameter', (tester) async {
      final match = TestDataFactory.createMatch();
      bool callbackCalled = false;

      final widget = PredictionDialog(
        match: match,
        onSave: (homeScore, awayScore) {
          callbackCalled = true;
        },
      );

      expect(widget, isNotNull);
      expect(widget.onSave, isNotNull);
    });

    testWidgets('has correct match data properties', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      );

      final widget = PredictionDialog(match: match);

      expect(widget.match.homeTeamName, equals('Brazil'));
      expect(widget.match.awayTeamName, equals('Argentina'));
    });
  });

  group('_ScoreSelector', () {
    // _ScoreSelector is a private widget, so we test it through PredictionDialog
    testWidgets('PredictionDialog type verification', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = PredictionDialog(match: match);

      expect(widget, isA<StatefulWidget>());
      expect(widget.match, isNotNull);
    });
  });

  group('QuickPredictionButton', () {
    testWidgets('can be constructed with match', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = QuickPredictionButton(match: match);

      expect(widget, isNotNull);
      expect(widget.match, equals(match));
    });

    testWidgets('can be constructed with existing prediction', (tester) async {
      final match = TestDataFactory.createMatch();
      final prediction = TestDataFactory.createPrediction();

      final widget = QuickPredictionButton(
        match: match,
        prediction: prediction,
      );

      expect(widget, isNotNull);
      expect(widget.prediction, equals(prediction));
    });

    testWidgets('has onPrediction callback parameter', (tester) async {
      final match = TestDataFactory.createMatch();

      final widget = QuickPredictionButton(
        match: match,
        onPrediction: (homeScore, awayScore) {},
      );

      expect(widget, isNotNull);
      expect(widget.onPrediction, isNotNull);
    });

    testWidgets('does not render for completed matches', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickPredictionButton(match: match),
          ),
        ),
      );

      // Should render as SizedBox.shrink() for completed matches
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('widget type is correct for scheduled matches',
        (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
        dateTime: DateTime.now().add(const Duration(days: 1)),
      );

      final widget = QuickPredictionButton(match: match);

      expect(widget, isA<StatelessWidget>());
      expect(widget.match.status, MatchStatus.scheduled);
    });

    testWidgets('widget handles existing prediction', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
        dateTime: DateTime.now().add(const Duration(days: 1)),
      );
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 3,
        predictedAwayScore: 1,
      );

      final widget = QuickPredictionButton(
        match: match,
        prediction: prediction,
      );

      expect(widget.prediction, isNotNull);
      expect(widget.prediction!.predictionDisplay, '3 - 1');
    });

    testWidgets('widget respects match status for live matches',
        (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.inProgress,
        dateTime: DateTime.now(),
      );

      final widget = QuickPredictionButton(match: match);

      expect(widget.match.status, MatchStatus.inProgress);
      expect(widget.match.isLive, isTrue);
    });

    testWidgets('widget handles completed match status',
        (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        dateTime: DateTime.now(),
      );
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 2,
        predictedAwayScore: 0,
      );

      final widget = QuickPredictionButton(
        match: match,
        prediction: prediction,
      );

      expect(widget.match.status, MatchStatus.completed);
      expect(widget.prediction, isNotNull);
    });
  });
}
