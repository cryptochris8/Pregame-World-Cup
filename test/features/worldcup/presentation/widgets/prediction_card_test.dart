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

  group('PredictionCard', () {
    testWidgets('renders with pending prediction data', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(prediction: prediction),
          ),
        ),
      );

      // Check team names
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);

      // Check predicted score
      expect(find.text('2 - 1'), findsOneWidget);
    });

    testWidgets('shows predicted scores', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 3,
        predictedAwayScore: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(prediction: prediction),
          ),
        ),
      );

      expect(find.text('3 - 0'), findsOneWidget);
    });

    testWidgets('shows team names', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(prediction: prediction),
          ),
        ),
      );

      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final prediction = TestDataFactory.createPrediction();
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(wasTapped, isTrue);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      // Create pending prediction (actualOutcome = null by default)
      final prediction = TestDataFactory.createPrediction(
        actualOutcome: null, // Explicitly set to null for pending state
      );
      bool wasEdited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              onEdit: () => wasEdited = true,
            ),
          ),
        ),
      );

      // Verify prediction is pending
      expect(prediction.isPending, isTrue);

      // Find and tap the edit button (only shown for pending predictions)
      final editButton = find.text('Edit');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      expect(wasEdited, isTrue);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      // Create pending prediction (actualOutcome = null by default)
      final prediction = TestDataFactory.createPrediction(
        actualOutcome: null, // Explicitly set to null for pending state
      );
      bool wasDeleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              onDelete: () => wasDeleted = true,
            ),
          ),
        ),
      );

      // Verify prediction is pending
      expect(prediction.isPending, isTrue);

      // Find and tap the delete button (only shown for pending predictions)
      final deleteButton = find.text('Delete');
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      expect(wasDeleted, isTrue);
    });

    testWidgets('shows date when showDate is true', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        matchDate: DateTime(2026, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showDate: true,
            ),
          ),
        ),
      );

      // Date should be formatted as 'Jun 15'
      expect(find.text('Jun 15'), findsOneWidget);
    });

    testWidgets('hides date when showDate is false', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        matchDate: DateTime(2026, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showDate: false,
            ),
          ),
        ),
      );

      // Date should not be shown
      expect(find.text('Jun 15'), findsNothing);
    });

    testWidgets('shows exact score correct badge', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        exactScoreCorrect: true,
        resultCorrect: true,
        pointsEarned: 5,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: true,
            ),
          ),
        ),
      );

      // Should show exact score badge
      expect(find.text('Exact Score!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows correct result badge', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        exactScoreCorrect: false,
        resultCorrect: true,
        pointsEarned: 3,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: true,
            ),
          ),
        ),
      );

      // Should show correct result badge
      expect(find.text('Correct Result'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows incorrect badge', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        exactScoreCorrect: false,
        resultCorrect: false,
        pointsEarned: 0,
        actualOutcome: PredictionOutcome.incorrect,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: true,
            ),
          ),
        ),
      );

      // Should show incorrect badge
      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows points earned for correct prediction', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        exactScoreCorrect: true,
        pointsEarned: 5,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: true,
            ),
          ),
        ),
      );

      // Should show points earned
      expect(find.text('5 points'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('shows 1 point with singular text', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        resultCorrect: true,
        pointsEarned: 1,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: true,
            ),
          ),
        ),
      );

      expect(find.text('1 point'), findsOneWidget);
    });

    testWidgets('does not show edit/delete for evaluated predictions',
        (tester) async {
      final prediction = TestDataFactory.createPrediction(
        resultCorrect: true,
        pointsEarned: 3,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Edit and delete buttons should not be shown for evaluated predictions
      expect(find.widgetWithText(TextButton, 'Edit'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Delete'), findsNothing);
    });

    testWidgets('hides result when showResult is false', (tester) async {
      final prediction = TestDataFactory.createPrediction(
        exactScoreCorrect: true,
        pointsEarned: 5,
        actualOutcome: PredictionOutcome.correct,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(
              prediction: prediction,
              showResult: false,
            ),
          ),
        ),
      );

      // Result badge and points should not be shown
      expect(find.text('Exact Score!'), findsNothing);
      expect(find.text('5 points'), findsNothing);
    });

    testWidgets('uses fallback team names when team names are null',
        (tester) async {
      final prediction = TestDataFactory.createPrediction(
        homeTeamName: null,
        homeTeamCode: 'USA',
        awayTeamName: null,
        awayTeamCode: 'MEX',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(prediction: prediction),
          ),
        ),
      );

      // Should fall back to team codes
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('MEX'), findsOneWidget);
    });

    testWidgets('uses "Home" and "Away" when both name and code are null',
        (tester) async {
      final prediction = TestDataFactory.createPrediction(
        homeTeamName: null,
        homeTeamCode: null,
        awayTeamName: null,
        awayTeamCode: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionCard(prediction: prediction),
          ),
        ),
      );

      // Should fall back to generic names
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Away'), findsOneWidget);
    });
  });

  group('PredictionStatsCard', () {
    testWidgets('renders prediction statistics', (tester) async {
      final stats = PredictionStats(
        totalPredictions: 10,
        pendingPredictions: 3,
        correctResults: 5,
        exactScores: 2,
        totalPoints: 21,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.text('Your Predictions'), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // total
      expect(find.text('5'), findsOneWidget); // correct
      expect(find.text('2'), findsOneWidget); // exact
      expect(find.text('21'), findsOneWidget); // points
    });

    testWidgets('shows accuracy percentage', (tester) async {
      final stats = PredictionStats(
        totalPredictions: 10,
        pendingPredictions: 2,
        correctResults: 6,
        exactScores: 2,
        totalPoints: 24,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionStatsCard(stats: stats),
          ),
        ),
      );

      // 6 correct out of 8 evaluated = 75%
      expect(find.textContaining('75.0% accuracy'), findsOneWidget);
    });

    testWidgets('shows progress indicator for accuracy', (tester) async {
      final stats = PredictionStats(
        totalPredictions: 5,
        pendingPredictions: 0,
        correctResults: 3,
        exactScores: 1,
        totalPoints: 13,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show accuracy when all predictions are pending',
        (tester) async {
      final stats = PredictionStats(
        totalPredictions: 5,
        pendingPredictions: 5,
        correctResults: 0,
        exactScores: 0,
        totalPoints: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionStatsCard(stats: stats),
          ),
        ),
      );

      // Should not show progress bar or accuracy when all pending
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.textContaining('accuracy'), findsNothing);
    });

    testWidgets('shows analytics icon', (tester) async {
      final stats = PredictionStats(
        totalPredictions: 1,
        pendingPredictions: 0,
        correctResults: 1,
        exactScores: 0,
        totalPoints: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictionStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });
}
