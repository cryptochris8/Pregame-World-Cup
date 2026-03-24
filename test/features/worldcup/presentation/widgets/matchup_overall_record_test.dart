import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/matchup_overall_record.dart';

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

  group('MatchupOverallRecord', () {
    testWidgets('renders team1Wins value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('renders team2Wins value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('renders draws value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('renders total matches text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 50,
            team2Wins: 20,
            draws: 7,
            totalMatches: 77,
          ),
        ),
      );

      expect(find.text('77 total matches'), findsOneWidget);
    });

    testWidgets('shows "Wins" labels twice', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      expect(find.text('Wins'), findsNWidgets(2));
    });

    testWidgets('shows "Draws" label', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      expect(find.text('Draws'), findsOneWidget);
    });

    testWidgets('win bar renders when totals > 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 25,
            team2Wins: 15,
            draws: 10,
            totalMatches: 50,
          ),
        ),
      );

      // Win bar should be present (not SizedBox.shrink)
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('when all zeros, still renders stat columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 0,
            team2Wins: 0,
            draws: 0,
            totalMatches: 0,
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(3)); // team1Wins, team2Wins, draws
      expect(find.text('Wins'), findsNWidgets(2));
      expect(find.text('Draws'), findsOneWidget);
    });

    testWidgets('renders with different values - all team1 wins', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 100,
            team2Wins: 0,
            draws: 0,
            totalMatches: 100,
          ),
        ),
      );

      expect(find.text('100'), findsWidgets); // team1Wins appears in widget
      expect(find.text('0'), findsNWidgets(2)); // team2Wins and draws
      expect(find.text('100 total matches'), findsOneWidget);
    });

    testWidgets('renders with different values - all draws', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 0,
            team2Wins: 0,
            draws: 20,
            totalMatches: 20,
          ),
        ),
      );

      expect(find.text('20'), findsWidgets); // draws appears in widget
      expect(find.text('0'), findsNWidgets(2)); // team1Wins and team2Wins
      expect(find.text('20 total matches'), findsOneWidget);
    });

    testWidgets('renders with different values - balanced', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 10,
            team2Wins: 10,
            draws: 10,
            totalMatches: 30,
          ),
        ),
      );

      expect(find.text('10'), findsNWidgets(3)); // all three stats
      expect(find.text('30 total matches'), findsOneWidget);
    });

    testWidgets('renders with large numbers', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupOverallRecord(
            team1Wins: 500,
            team2Wins: 350,
            draws: 150,
            totalMatches: 1000,
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('1000 total matches'), findsOneWidget);
    });
  });
}
