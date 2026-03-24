import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_prediction_tab_widget.dart';
import '../../schedule_test_factory.dart';

void main() {
  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('RenderFlex overflowed')) {
        FlutterError.presentError(details);
      }
    };
  });

  group('AIPredictionTabWidget', () {
    testWidgets('shows no prediction data message when prediction is null',
        (WidgetTester tester) async {
      final analysisData = {
        'other': 'data',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('No prediction data'), findsOneWidget);
    });

    testWidgets('renders prediction card with scores',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData(
        homeScore: '2',
        awayScore: '1',
        winner: 'Brazil',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Enhanced AI Analysis'), findsOneWidget);
      expect(find.text('Score Prediction'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('displays confidence value',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData(
        confidence: '0.72',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Confidence: 0.72'), findsOneWidget);
    });

    testWidgets('shows winner badge on predicted winner',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData(
        homeScore: '3',
        awayScore: '1',
        winner: 'Brazil',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('WINNER'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('renders confidence analysis section',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.85,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Confidence Analysis'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows high confidence description',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.85,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(
        find.text('High confidence prediction based on strong data indicators'),
        findsOneWidget,
      );
    });

    testWidgets('shows moderate confidence description',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.65,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(
        find.text('Moderate confidence with some uncertainty factors'),
        findsOneWidget,
      );
    });

    testWidgets('shows low confidence description',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.45,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(
        find.text('Low confidence due to limited data or high uncertainty'),
        findsOneWidget,
      );
    });

    testWidgets('displays risk factors when available',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.65,
          'riskFactors': [
            'Weather conditions uncertain',
            'Key player injury status',
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Risk Factors:'), findsOneWidget);
      expect(find.textContaining('Weather conditions uncertain'), findsOneWidget);
      expect(find.textContaining('Key player injury status'), findsOneWidget);
    });

    testWidgets('handles predictedScore format in nested object',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'predictedScore': {
            'home': '3',
            'away': '2',
          },
          'confidence': '0.75',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Score Prediction'), findsOneWidget);
      // Scores should be displayed
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('calculates winner from scores when winner not provided',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '3',
          'awayScore': '1',
          'confidence': '0.75',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      // Brazil (home) should have winner badge since score is 3-1
      expect(find.text('WINNER'), findsOneWidget);
    });

    testWidgets('displays analysis text from prediction',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData(
        analysis: 'Brazil has a strong home record.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Brazil has a strong home record.'), findsOneWidget);
    });

    testWidgets('handles string confidence value',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': '0.85',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.85);
    });

    testWidgets('handles empty risk factors list',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'homeScore': '2',
          'awayScore': '1',
          'confidence': 0.75,
          'riskFactors': [],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIPredictionTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      // Should not show risk factors section when empty
      expect(find.text('Risk Factors:'), findsNothing);
    });
  });
}
