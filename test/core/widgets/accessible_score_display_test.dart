import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/widgets/accessible_score_display.dart';

void main() {
  Widget buildWidget({
    String homeTeam = 'Argentina',
    String awayTeam = 'Brazil',
    int homeScore = 2,
    int awayScore = 1,
    TextStyle? scoreStyle,
    TextStyle? separatorStyle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AccessibleScoreDisplay(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          homeScore: homeScore,
          awayScore: awayScore,
          scoreStyle: scoreStyle,
          separatorStyle: separatorStyle,
        ),
      ),
    );
  }

  group('AccessibleScoreDisplay', () {
    testWidgets('displays score text visually', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('has correct Semantics label combining team names and scores',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        homeTeam: 'Argentina',
        awayTeam: 'Brazil',
        homeScore: 2,
        awayScore: 1,
      ));

      final semantics = tester.getSemantics(find.byType(AccessibleScoreDisplay));
      expect(semantics.label, 'Argentina 2, Brazil 1');
    });

    testWidgets('handles zero-zero score', (tester) async {
      await tester.pumpWidget(buildWidget(
        homeTeam: 'France',
        awayTeam: 'Germany',
        homeScore: 0,
        awayScore: 0,
      ));

      expect(find.text('0'), findsNWidgets(2));

      final semantics = tester.getSemantics(find.byType(AccessibleScoreDisplay));
      expect(semantics.label, 'France 0, Germany 0');
    });

    testWidgets('applies custom score style', (tester) async {
      const customStyle = TextStyle(fontSize: 32, color: Colors.red);
      await tester.pumpWidget(buildWidget(scoreStyle: customStyle));

      final scoreWidget = tester.widget<Text>(find.text('2'));
      expect(scoreWidget.style?.fontSize, 32);
      expect(scoreWidget.style?.color, Colors.red);
    });

    testWidgets('applies custom separator style', (tester) async {
      const customStyle = TextStyle(fontSize: 16, color: Colors.blue);
      await tester.pumpWidget(buildWidget(separatorStyle: customStyle));

      final separatorWidget = tester.widget<Text>(find.text('-'));
      expect(separatorWidget.style?.fontSize, 16);
      expect(separatorWidget.style?.color, Colors.blue);
    });

    testWidgets('score digits are excluded from individual semantics',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      final excludeSemantics = find.descendant(
        of: find.byType(AccessibleScoreDisplay),
        matching: find.byType(ExcludeSemantics),
      );
      expect(excludeSemantics, findsOneWidget);
    });
  });
}
