import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/head_to_head.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/matchup_notable_matches.dart';

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

  final testMatch = HistoricalMatch(
    year: 2022,
    tournament: 'World Cup',
    stage: 'Final',
    team1Score: 3,
    team2Score: 3,
    winnerCode: 'ARG',
    location: 'Lusail',
    description: 'Epic final',
  );

  group('MatchupNotableMatches', () {
    testWidgets('renders "Notable Matches" header', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Notable Matches'), findsOneWidget);
    });

    testWidgets('renders tournament name', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('World Cup'), findsOneWidget);
    });

    testWidgets('renders stage badge when stage is not null', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Final'), findsOneWidget);
    });

    testWidgets('renders team names', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Argentina'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('renders scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('3 - 3'), findsOneWidget); // Combined score display
    });

    testWidgets('renders year', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('2022'), findsOneWidget);
    });

    testWidgets('renders location', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Lusail'), findsOneWidget);
    });

    testWidgets('renders description', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Epic final'), findsOneWidget);
    });

    testWidgets('shows "Show X more" button when matches exceed maxNotableMatches and not showing all', (WidgetTester tester) async {
      final matches = List.generate(
        5,
        (i) => HistoricalMatch(
          year: 2020 + i,
          tournament: 'Tournament $i',
          stage: 'Stage $i',
          team1Score: i,
          team2Score: i + 1,
          winnerCode: 'ARG',
          location: 'Location $i',
          description: 'Description $i',
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: matches,
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Show 2 more'), findsOneWidget);
    });

    testWidgets('does not show "Show X more" when showAllMatches is true', (WidgetTester tester) async {
      final matches = List.generate(
        5,
        (i) => HistoricalMatch(
          year: 2020 + i,
          tournament: 'Tournament $i',
          stage: 'Stage $i',
          team1Score: i,
          team2Score: i + 1,
          winnerCode: 'ARG',
          location: 'Location $i',
          description: 'Description $i',
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: matches,
            maxNotableMatches: 3,
            showAllMatches: true,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.textContaining('Show'), findsNothing);
    });

    testWidgets('does not show "Show X more" when matches <= maxNotableMatches', (WidgetTester tester) async {
      final matches = List.generate(
        2,
        (i) => HistoricalMatch(
          year: 2020 + i,
          tournament: 'Tournament $i',
          stage: 'Stage $i',
          team1Score: i,
          team2Score: i + 1,
          winnerCode: 'ARG',
          location: 'Location $i',
          description: 'Description $i',
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: matches,
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.textContaining('Show'), findsNothing);
    });

    testWidgets('calls onShowMore when button tapped', (WidgetTester tester) async {
      final matches = List.generate(
        5,
        (i) => HistoricalMatch(
          year: 2020 + i,
          tournament: 'Tournament $i',
          stage: 'Stage $i',
          team1Score: i,
          team2Score: i + 1,
          winnerCode: 'ARG',
          location: 'Location $i',
          description: 'Description $i',
        ),
      );

      bool showMoreCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: matches,
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {
              showMoreCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Show 2 more'));
      await tester.pump();

      expect(showMoreCalled, true);
    });

    testWidgets('shows team1Name when provided, falls back to team1Code', (WidgetTester tester) async {
      // Test with team1Name provided
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('Argentina'), findsOneWidget);

      // Test with team1Name as null (should fall back to team1Code)
      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: [testMatch],
            maxNotableMatches: 3,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: null,
            team2Name: null,
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('ARG'), findsOneWidget);
      expect(find.text('FRA'), findsOneWidget);
    });

    testWidgets('renders multiple match cards', (WidgetTester tester) async {
      final matches = [
        HistoricalMatch(
          year: 2022,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 3,
          team2Score: 3,
          winnerCode: 'ARG',
          location: 'Lusail',
          description: 'Epic final',
        ),
        HistoricalMatch(
          year: 2018,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 4,
          team2Score: 3,
          winnerCode: 'FRA',
          location: 'Kazan',
          description: 'Thriller',
        ),
        HistoricalMatch(
          year: 2014,
          tournament: 'Friendly',
          stage: null,
          team1Score: 0,
          team2Score: 0,
          winnerCode: null,
          location: 'Paris',
          description: 'Goalless draw',
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          MatchupNotableMatches(
            matches: matches,
            maxNotableMatches: 5,
            showAllMatches: false,
            team1Code: 'ARG',
            team2Code: 'FRA',
            team1Name: 'Argentina',
            team2Name: 'France',
            h2hTeam1Code: 'ARG',
            onShowMore: () {},
          ),
        ),
      );

      expect(find.text('2022'), findsOneWidget);
      expect(find.text('2018'), findsOneWidget);
      expect(find.text('2014'), findsOneWidget);
      expect(find.text('World Cup'), findsNWidgets(2));
      expect(find.text('Friendly'), findsOneWidget);
    });
  });
}
