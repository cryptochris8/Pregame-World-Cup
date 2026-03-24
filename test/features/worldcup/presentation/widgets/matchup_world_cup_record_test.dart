import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/matchup_world_cup_record.dart';

void main() {
  setUp(() {
    // Suppress overflow errors during testing
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
          );

      if (isOverflowError) {
        throw exception;
      }
    };
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  group('MatchupWorldCupRecord', () {
    testWidgets('renders trophy icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders "World Cup Meetings" title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('World Cup Meetings'), findsOneWidget);
    });

    testWidgets('renders team1 wins count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders team2 wins count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders team1Name', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('Argentina'), findsOneWidget);
    });

    testWidgets('renders team2Name', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('renders worldCupMatches count with "matches" text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('5 matches'), findsOneWidget);
    });

    testWidgets('shows draw text when worldCupDraws is 1 (singular)', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 2,
            worldCupMatches: 5,
            worldCupDraws: 1,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('1 draw'), findsOneWidget);
    });

    testWidgets('shows draws text when worldCupDraws > 1 (plural)', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 2,
            team2Wins: 1,
            worldCupMatches: 5,
            worldCupDraws: 2,
            team1Name: 'Argentina',
            team2Name: 'France',
          ),
        ),
      );

      expect(find.text('2 draws'), findsOneWidget);
    });

    testWidgets('does not show draws when worldCupDraws is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 3,
            team2Wins: 2,
            worldCupMatches: 5,
            worldCupDraws: 0,
            team1Name: 'Brazil',
            team2Name: 'Germany',
          ),
        ),
      );

      expect(find.textContaining('draw'), findsNothing);
    });

    testWidgets('renders with different team names', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 5,
            team2Wins: 3,
            worldCupMatches: 10,
            worldCupDraws: 2,
            team1Name: 'Brazil',
            team2Name: 'Germany',
          ),
        ),
      );

      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders with zero wins for both teams', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupWorldCupRecord(
            team1Wins: 0,
            team2Wins: 0,
            worldCupMatches: 3,
            worldCupDraws: 3,
            team1Name: 'Italy',
            team2Name: 'Spain',
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(2)); // Both teams have 0 wins
      expect(find.text('3 matches'), findsOneWidget);
      expect(find.text('3 draws'), findsOneWidget);
    });
  });
}
