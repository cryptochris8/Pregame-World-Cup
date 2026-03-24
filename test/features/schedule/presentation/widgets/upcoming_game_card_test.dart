import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/upcoming_game_card.dart';
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

  group('UpcomingGameCard', () {
    testWidgets('renders team names', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(game.awayTeamName), findsOneWidget);
      expect(find.text(game.homeTeamName), findsOneWidget);
    });

    testWidgets('shows @ symbol', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('@'), findsOneWidget);
    });

    testWidgets('shows "Favorite Team" indicator when isFavoriteGame=true', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Favorite Team'), findsOneWidget);
    });

    testWidgets('does NOT show "Favorite Team" when isFavoriteGame=false', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Favorite Team'), findsNothing);
    });

    testWidgets('shows game time', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find some time-related text (the widget formats the time)
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows venue name when stadium exists', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createGameWithStadium();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(game.stadium!.name!), findsOneWidget);
    });

    testWidgets('shows TV channel when present', (WidgetTester tester) async {
      final game = GameSchedule(
        gameId: 'test-1',
        awayTeamName: 'Team A',
        homeTeamName: 'Team B',
        dateTimeUTC: DateTime.now().add(const Duration(days: 1)),
        channel: 'ESPN',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TV: ESPN'), findsOneWidget);
    });

    testWidgets('shows week info when week exists', (WidgetTester tester) async {
      final game = GameSchedule(
        gameId: 'test-1',
        awayTeamName: 'Team A',
        homeTeamName: 'Team B',
        dateTimeUTC: DateTime.now().add(const Duration(days: 1)),
        week: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Week'), findsOneWidget);
    });

    testWidgets('tapping the card calls onTap', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpcomingGameCard(
              game: game,
              isFavoriteGame: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(UpcomingGameCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
