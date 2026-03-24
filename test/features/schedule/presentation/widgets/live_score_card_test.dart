import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/live_score_card.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import '../../schedule_test_factory.dart';

void main() {
  setUp(() {
    // Suppress overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
          );
      if (isOverflowError) {
        FlutterError.presentError(details);
      }
    };
  });

  group('LiveScoreCard', () {
    testWidgets('shows "LIVE" text', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createLiveGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('shows team names', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createLiveGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(game.awayTeamName), findsOneWidget);
      expect(find.text(game.homeTeamName), findsOneWidget);
    });

    testWidgets('shows "Away" and "Home" labels', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createLiveGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Away'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('shows scores', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createLiveGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display score values
      if (game.awayScore != null) {
        expect(find.text(game.awayScore.toString()), findsOneWidget);
      }
      if (game.homeScore != null) {
        expect(find.text(game.homeScore.toString()), findsOneWidget);
      }
    });

    testWidgets('shows period text when period is not null', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createLiveGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      if (game.period != null) {
        expect(find.textContaining(game.period!), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('shows time remaining when timeRemaining is not null', (WidgetTester tester) async {
      final game = GameSchedule(
        gameId: 'test-live-1',
        awayTeamName: 'Team A',
        homeTeamName: 'Team B',
        dateTimeUTC: DateTime.now(),
        isLive: true,
        status: 'InProgress',
        awayScore: 1,
        homeScore: 2,
        period: '2nd Half',
        timeRemaining: '15:30',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('15:30'), findsOneWidget);
    });

    testWidgets('shows stadium name when available', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createGameWithStadium();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(game.stadium!.name!), findsOneWidget);
    });

    testWidgets('shows social activity when present', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createGameWithSocialData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show prediction and comment counts
      if (game.userPredictions != null) {
        expect(find.textContaining(game.userPredictions.toString()), findsAtLeastNWidgets(1));
      }
      if (game.userComments != null) {
        expect(find.textContaining(game.userComments.toString()), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('shows "Updated" text when lastScoreUpdate exists', (WidgetTester tester) async {
      final game = GameSchedule(
        gameId: 'test-live-3',
        awayTeamName: 'Team A',
        homeTeamName: 'Team B',
        dateTimeUTC: DateTime.now(),
        isLive: true,
        status: 'InProgress',
        awayScore: 2,
        homeScore: 1,
        lastScoreUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveScoreCard(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The text will be "Updated 5m ago" or similar, so we use textContaining
      expect(find.textContaining('Updated'), findsOneWidget);
    });
  });
}
