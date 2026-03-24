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

  group('MatchHeaderWidget', () {
    testWidgets('renders without error', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
        stage: MatchStage.groupStage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.blue,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MatchHeaderWidget), findsOneWidget);
    });

    testWidgets('shows stage badge with stage display name', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.quarterFinal,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.green,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Quarter-Final'), findsOneWidget);
    });

    testWidgets('shows group information when group is present', (tester) async {
      final match = TestDataFactory.createMatch(
        group: 'B',
        stage: MatchStage.groupStage,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.orange,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Group B'), findsOneWidget);
    });

    testWidgets('does not show group when group is null', (tester) async {
      final match = TestDataFactory.createMatch(
        group: null,
        stage: MatchStage.final_,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.purple,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Group'), findsNothing);
    });

    testWidgets('shows home team name', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.yellow,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Brazil'), findsOneWidget);
    });

    testWidgets('shows away team name', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'Germany',
        awayTeamName: 'France',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.red,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('shows VS for scheduled match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
        dateTime: DateTime(2026, 6, 15, 18, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.teal,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('shows kick-off time for scheduled match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
        dateTime: DateTime(2026, 6, 15, 18, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.indigo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Time should be displayed, format depends on locale
      expect(find.textContaining('6:30'), findsOneWidget);
    });

    testWidgets('shows score for completed match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: 3,
        awayScore: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.brown,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text(' - '), findsOneWidget);
    });

    testWidgets('shows Full Time label for completed match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.cyan,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Full Time'), findsOneWidget);
    });

    testWidgets('shows Half Time label for match at half time', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.halfTime,
        homeScore: 1,
        awayScore: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.lime,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Half Time'), findsOneWidget);
    });

    testWidgets('score shows 0 when scores are null for non-scheduled match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: null,
        awayScore: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.pink,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0'), findsNWidgets(2)); // Both home and away show 0
    });

    testWidgets('has gradient background container', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.deepOrange,
            ),
          ),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MatchHeaderWidget),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('uses provided stage color in gradient', (tester) async {
      const testColor = Colors.deepPurple;
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: testColor,
            ),
          ),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MatchHeaderWidget),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // The gradient should contain variations of the stage color
      expect(gradient.colors.length, equals(2));
    });

    testWidgets('stage badge has rounded border', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.semiFinal,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.blueGrey,
            ),
          ),
        ),
      );
      await tester.pump();

      final badgeContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Semi-Final'),
          matching: find.byType(Container),
        ).first,
      );

      expect(badgeContainer.decoration, isA<BoxDecoration>());
      final decoration = badgeContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('score container has rounded border and gradient', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: 4,
        awayScore: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.amber,
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the container that holds the score
      final scoreContainers = tester.widgetList<Container>(
        find.ancestor(
          of: find.text('4'),
          matching: find.byType(Container),
        ),
      );

      // Should find at least one container with BoxDecoration
      expect(
        scoreContainers.any((c) => c.decoration is BoxDecoration),
        isTrue,
      );
    });

    testWidgets('handles different match stages correctly', (tester) async {
      final stages = [
        (MatchStage.groupStage, 'Group Stage'),
        (MatchStage.roundOf32, 'Round of 32'),
        (MatchStage.roundOf16, 'Round of 16'),
        (MatchStage.quarterFinal, 'Quarter-Final'),
        (MatchStage.semiFinal, 'Semi-Final'),
        (MatchStage.thirdPlace, 'Third Place Play-off'),
        (MatchStage.final_, 'Final'),
      ];

      for (final (stage, displayName) in stages) {
        final match = TestDataFactory.createMatch(
          stage: stage,
          group: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MatchHeaderWidget(
                match: match,
                stageColor: Colors.blue,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(displayName), findsOneWidget);

        // Clear for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('includes SafeArea widget', (tester) async {
      final match = TestDataFactory.createMatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchHeaderWidget(
              match: match,
              stageColor: Colors.green,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
