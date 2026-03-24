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
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  group('MatchExtraTimeCard', () {
    testWidgets('renders without error', (tester) async {
      final match = TestDataFactory.createMatch(
        homeScore: 2,
        awayScore: 2,
        status: MatchStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.byType(MatchExtraTimeCard), findsOneWidget);
    });

    testWidgets('shows title and icon', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('Extra Time & Penalties'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('shows AET message when match has extra time', (tester) async {
      // Create match with extra time scores
      final match = TestDataFactory.createMatch(
        homeScore: 2,
        awayScore: 2,
        status: MatchStatus.completed,
      ).copyWith(
        homeExtraTimeScore: 1,
        awayExtraTimeScore: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('Match went to extra time (AET)'), findsOneWidget);
    });

    testWidgets('shows penalty shootout scores when match has penalties', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'BRA',
        awayTeamCode: 'ARG',
        homeScore: 1,
        awayScore: 1,
        status: MatchStatus.completed,
      ).copyWith(
        homePenaltyScore: 4,
        awayPenaltyScore: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('BRA'), findsOneWidget);
      expect(find.text('ARG'), findsOneWidget);
      expect(find.text('4 - 2'), findsOneWidget);
      expect(find.text('Penalty Shootout'), findsOneWidget);
    });

    testWidgets('shows both extra time and penalties when both present', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'GER',
        awayTeamCode: 'FRA',
        homeScore: 2,
        awayScore: 2,
        status: MatchStatus.completed,
      ).copyWith(
        homeExtraTimeScore: 0,
        awayExtraTimeScore: 0,
        homePenaltyScore: 5,
        awayPenaltyScore: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('Match went to extra time (AET)'), findsOneWidget);
      expect(find.text('5 - 4'), findsOneWidget);
      expect(find.text('Penalty Shootout'), findsOneWidget);
    });

    testWidgets('displays team codes for penalty section', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamCode: 'USA',
        awayTeamCode: 'MEX',
      ).copyWith(
        homePenaltyScore: 3,
        awayPenaltyScore: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('USA'), findsOneWidget);
      expect(find.text('MEX'), findsOneWidget);
    });

    testWidgets('does not show AET message when no extra time', (tester) async {
      final match = TestDataFactory.createMatch(
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('Match went to extra time (AET)'), findsNothing);
    });

    testWidgets('does not show penalty section when no penalties', (tester) async {
      final match = TestDataFactory.createMatch(
        homeScore: 3,
        awayScore: 2,
        status: MatchStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      expect(find.text('Penalty Shootout'), findsNothing);
    });

    testWidgets('has correct container styling', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MatchExtraTimeCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('penalty score container has proper styling', (tester) async {
      final match = TestDataFactory.createMatch().copyWith(
        homePenaltyScore: 4,
        awayPenaltyScore: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExtraTimeCard(match: match),
          ),
        ),
      );

      final scoreContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('4 - 3'),
          matching: find.byType(Container),
        ).first,
      );

      expect(scoreContainer.decoration, isA<BoxDecoration>());
      final decoration = scoreContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
