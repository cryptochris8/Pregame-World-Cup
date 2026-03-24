import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_compact_content_widget.dart';
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

  group('AICompactContentWidget', () {
    testWidgets('renders AI Prediction text when prediction data exists',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('AI Prediction:'), findsOneWidget);
    });

    testWidgets('shows winning team name with wins suffix',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // The winner from createAiAnalysisData should be present
      final winnerName =
          analysisData['prediction']?['winner'] as String? ?? '';
      if (winnerName.isNotEmpty) {
        expect(find.textContaining('wins'), findsWidgets);
      }
    });

    testWidgets('shows predicted score', (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      final prediction = analysisData['prediction'] as Map<String, dynamic>?;
      if (prediction != null) {
        final homeScore = prediction['homeScore'];
        final awayScore = prediction['awayScore'];
        if (homeScore != null && awayScore != null) {
          expect(find.textContaining('$homeScore'), findsWidgets);
          expect(find.textContaining('$awayScore'), findsWidgets);
        }
      }
    });

    testWidgets('shows confidence percentage', (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('confidence'), findsWidgets);
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('shows Key Factors section when key factors exist',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      final prediction = analysisData['prediction'] as Map<String, dynamic>?;
      final keyFactors = prediction?['keyFactors'] as List<dynamic>?;
      if (keyFactors != null && keyFactors.isNotEmpty) {
        expect(find.text('Key Factors'), findsOneWidget);
      }
    });

    testWidgets('shows max 2 key factors in preview',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'winner': 'Brazil',
          'homeScore': '2',
          'awayScore': '1',
          'confidence': '0.75',
          'keyFactors': [
            'Factor 1',
            'Factor 2',
            'Factor 3',
            'Factor 4',
          ],
        },
      };
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Should show first two factors
      expect(find.textContaining('Factor 1'), findsOneWidget);
      expect(find.textContaining('Factor 2'), findsOneWidget);
    });

    testWidgets('shows +N more factors when more than 2 factors',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'winner': 'Brazil',
          'homeScore': '2',
          'awayScore': '1',
          'confidence': '0.75',
          'keyFactors': [
            'Factor 1',
            'Factor 2',
            'Factor 3',
            'Factor 4',
          ],
        },
      };
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Should show "+2 more factors..." since we have 4 total and show 2
      expect(find.textContaining('+2 more factors'), findsOneWidget);
    });

    testWidgets('shows View Detailed Analysis button',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('View Detailed Analysis'), findsOneWidget);
    });

    testWidgets('tapping View Detailed Analysis calls the callback',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Detailed Analysis'));
      await tester.pump();

      expect(callbackCalled, isTrue);
    });

    testWidgets('handles missing prediction data gracefully',
        (WidgetTester tester) async {
      final analysisData = <String, dynamic>{};
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AICompactContentWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
              onViewDetailedAnalysis: () => callbackCalled = true,
            ),
          ),
        ),
      );

      // Widget should still render without crashing
      expect(find.byType(AICompactContentWidget), findsOneWidget);
      // Button should still be present
      expect(find.text('View Detailed Analysis'), findsOneWidget);
    });
  });
}
