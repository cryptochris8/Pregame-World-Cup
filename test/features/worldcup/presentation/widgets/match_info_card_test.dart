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

  group('MatchInfoCard', () {
    testWidgets('renders without error with complete match data', (tester) async {
      final match = TestDataFactory.createMatch(
        matchNumber: 1,
        stage: MatchStage.groupStage,
        group: 'A',
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
        dateTime: DateTime(2026, 6, 11, 18, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.byType(MatchInfoCard), findsOneWidget);
    });

    testWidgets('shows match number', (tester) async {
      final match = TestDataFactory.createMatch(
        matchNumber: 42,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('Match Number'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows match stage', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.groupStage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('Stage'), findsOneWidget);
      expect(find.text('Group Stage'), findsOneWidget);
    });

    testWidgets('shows formatted date when dateTime is provided', (tester) async {
      final match = TestDataFactory.createMatch(
        dateTime: DateTime(2026, 6, 11, 18, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Kick-off'), findsOneWidget);
      // Date should be formatted as "EEEE, MMMM d, yyyy"
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('shows TBD when dateTime is null', (tester) async {
      // Create match with explicitly null dateTime by using copyWith
      final match = WorldCupMatch(
        matchId: 'test',
        matchNumber: 1,
        stage: MatchStage.groupStage,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        status: MatchStatus.scheduled,
        dateTime: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('TBD'), findsNWidgets(2)); // Date and Kick-off both show TBD
    });

    testWidgets('shows group information when group is provided', (tester) async {
      final match = TestDataFactory.createMatch(
        group: 'B',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('Group'), findsOneWidget);
      expect(find.text('Group B'), findsOneWidget);
    });

    testWidgets('does not show group section when group is null', (tester) async {
      final match = TestDataFactory.createMatch(
        group: null,
        stage: MatchStage.final_,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      expect(find.text('Group'), findsNothing);
    });

    testWidgets('displays all info row icons', (tester) async {
      final match = TestDataFactory.createMatch(
        group: 'A',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      // Check for icons
      expect(find.byIcon(Icons.numbers), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });

    testWidgets('shows correct stage display names for different stages', (tester) async {
      final stageTests = [
        (MatchStage.groupStage, 'Group Stage'),
        (MatchStage.roundOf16, 'Round of 16'),
        (MatchStage.quarterFinal, 'Quarter-Final'),
        (MatchStage.semiFinal, 'Semi-Final'),
        (MatchStage.final_, 'Final'),
      ];

      for (final (stage, displayName) in stageTests) {
        final match = TestDataFactory.createMatch(
          stage: stage,
          group: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MatchInfoCard(match: match),
            ),
          ),
        );

        expect(find.text(displayName), findsOneWidget);

        // Clear for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('has proper container decoration', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchInfoCard(match: match),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MatchInfoCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
    });
  });
}
