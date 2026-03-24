import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/matchup_goals_comparison.dart';

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

  group('MatchupGoalsComparison', () {
    testWidgets('renders "Goals" label', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 50,
            team2Goals: 30,
          ),
        ),
      );

      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('renders team1Goals value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 50,
            team2Goals: 30,
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('renders team2Goals value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 50,
            team2Goals: 30,
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('renders bar chart containers', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 50,
            team2Goals: 30,
          ),
        ),
      );

      // Bar chart should be present with Container widgets
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('returns empty when both goals are 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 0,
            team2Goals: 0,
          ),
        ),
      );

      // Should return SizedBox.shrink() - nothing visible
      expect(find.text('Goals'), findsNothing);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('renders with team1 having more goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 100,
            team2Goals: 50,
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('renders with team2 having more goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 25,
            team2Goals: 75,
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('renders with equal goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 40,
            team2Goals: 40,
          ),
        ),
      );

      expect(find.text('40'), findsNWidgets(2)); // Both teams have same value
      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('renders with team1 having all goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 80,
            team2Goals: 0,
          ),
        ),
      );

      expect(find.text('80'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('renders with team2 having all goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const MatchupGoalsComparison(
            team1Goals: 0,
            team2Goals: 60,
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
    });
  });
}
