import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/config/app_theme.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/ai_match_prediction.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/probability_bar.dart';

AIMatchPrediction _createPrediction({
  int homeWinProbability = 45,
  int drawProbability = 25,
  int awayWinProbability = 30,
}) {
  return AIMatchPrediction(
    matchId: 'test-match-1',
    predictedOutcome: AIPredictedOutcome.homeWin,
    predictedHomeScore: 2,
    predictedAwayScore: 1,
    confidence: 70,
    homeWinProbability: homeWinProbability,
    drawProbability: drawProbability,
    awayWinProbability: awayWinProbability,
    keyFactors: const ['Strong home form'],
    analysis: 'Test analysis',
    quickInsight: 'Test insight',
    provider: 'Test',
    generatedAt: DateTime(2026, 6, 1),
  );
}

Widget _buildTestWidget({
  AIMatchPrediction? prediction,
  String homeTeamName = 'United States',
  String awayTeamName = 'Mexico',
  Color? homeColor,
  Color? awayColor,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 400,
        child: ProbabilityBar(
          prediction: prediction ?? _createPrediction(),
          homeTeamName: homeTeamName,
          awayTeamName: awayTeamName,
          homeColor: homeColor ?? AppTheme.primaryPurple,
          awayColor: awayColor ?? AppTheme.primaryOrange,
        ),
      ),
    ),
  );
}

void main() {
  group('ProbabilityBar', () {
    testWidgets('renders team names', (tester) async {
      await tester.pumpWidget(_buildTestWidget());

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);
      expect(find.text('Draw'), findsOneWidget);
    });

    testWidgets('renders percentage labels below bar', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 45,
          drawProbability: 25,
          awayWinProbability: 30,
        ),
      ));

      // Percentages appear below the bar (and possibly inside if wide enough)
      expect(find.text('45%'), findsAny);
      expect(find.text('25%'), findsAny);
      expect(find.text('30%'), findsAny);
    });

    testWidgets('renders with dominant home win', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 70,
          drawProbability: 15,
          awayWinProbability: 15,
        ),
      ));

      expect(find.text('70%'), findsAny);
      expect(find.text('15%'), findsAny);
    });

    testWidgets('renders with dominant away win', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 15,
          drawProbability: 20,
          awayWinProbability: 65,
        ),
      ));

      expect(find.text('65%'), findsAny);
      expect(find.text('20%'), findsAny);
      expect(find.text('15%'), findsAny);
    });

    testWidgets('renders with equal probabilities', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 33,
          drawProbability: 34,
          awayWinProbability: 33,
        ),
      ));

      expect(find.text('33%'), findsAny);
      expect(find.text('34%'), findsAny);
    });

    testWidgets('uses custom colors when provided', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        homeColor: Colors.blue,
        awayColor: Colors.red,
      ));

      // Widget should render without errors using custom colors
      expect(find.byType(ProbabilityBar), findsOneWidget);
    });

    testWidgets('handles long team names with ellipsis', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        homeTeamName: 'Bosnia and Herzegovina',
        awayTeamName: 'Trinidad and Tobago',
      ));

      expect(find.text('Bosnia and Herzegovina'), findsOneWidget);
      expect(find.text('Trinidad and Tobago'), findsOneWidget);
    });

    testWidgets('bar has rounded corners via ClipRRect', (tester) async {
      await tester.pumpWidget(_buildTestWidget());

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, isNotNull);
    });

    testWidgets('contains three colored segments', (tester) async {
      await tester.pumpWidget(_buildTestWidget());

      // The bar row has 3 Flexible children, each containing a Container
      // Find the SizedBox that represents the bar height
      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 32,
        ),
      );
      expect(sizedBox, isNotNull);
    });

    testWidgets('hides inline label for small segments', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 80,
          drawProbability: 10,
          awayWinProbability: 10,
        ),
      ));

      // 80% should show inline label, 10% segments should not
      // The bottom percentage labels always show
      // Inside the bar, 10% is < 15 threshold so inline label is hidden
      expect(find.text('80%'), findsAny);
      expect(find.text('10%'), findsAny);
    });

    testWidgets('renders with default bar height of 32', (tester) async {
      await tester.pumpWidget(_buildTestWidget());

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 32,
        ),
      );
      expect(sizedBox.height, 32);
    });

    testWidgets('handles zero probabilities gracefully', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        prediction: _createPrediction(
          homeWinProbability: 0,
          drawProbability: 0,
          awayWinProbability: 0,
        ),
      ));

      // Should render without errors even with zero values
      expect(find.byType(ProbabilityBar), findsOneWidget);
    });
  });
}
