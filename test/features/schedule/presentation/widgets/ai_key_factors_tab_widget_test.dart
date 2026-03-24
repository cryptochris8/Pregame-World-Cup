import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_key_factors_tab_widget.dart';
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

  group('AIKeyFactorsTabWidget', () {
    testWidgets('shows empty state when keyFactors is null',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.text('No key factors available'), findsOneWidget);
      expect(
        find.text('Key factors will appear here when analysis is complete.'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when keyFactors is empty list',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('No key factors available'), findsOneWidget);
    });

    testWidgets('renders key factors list with string factors',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData(
        keyFactors: [
          'Home field advantage',
          'Recent team momentum',
          'Defensive matchups',
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Key Factors to Watch'), findsOneWidget);
      expect(find.text('Home field advantage'), findsOneWidget);
      expect(find.text('Recent team momentum'), findsOneWidget);
      expect(find.text('Defensive matchups'), findsOneWidget);
    });

    testWidgets('renders string factor with Key Factor badge',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': ['Weather conditions'],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Key Factor'), findsOneWidget);
      expect(find.text('Weather conditions'), findsOneWidget);
    });

    testWidgets('renders map format key factors with category',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [
            {
              'category': 'Performance',
              'impact': 'High',
              'factor': 'Home field advantage',
              'details': 'Team has strong home record',
            },
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('High Impact'), findsOneWidget);
      expect(find.text('Home field advantage'), findsOneWidget);
      expect(find.text('Team has strong home record'), findsOneWidget);
    });

    testWidgets('renders map format with different impact levels',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [
            {
              'category': 'Critical',
              'impact': 'Critical',
              'factor': 'Injuries',
              'details': 'Key players missing',
            },
            {
              'category': 'Stats',
              'impact': 'Medium',
              'factor': 'Head to head',
              'details': 'Historical context',
            },
            {
              'category': 'Form',
              'impact': 'Low',
              'factor': 'Recent results',
              'details': 'Last 5 games',
            },
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Critical Impact'), findsOneWidget);
      expect(find.text('Medium Impact'), findsOneWidget);
      expect(find.text('Low Impact'), findsOneWidget);
    });

    testWidgets('handles mixed string and map factors',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [
            'Simple string factor',
            {
              'category': 'Tactical',
              'impact': 'High',
              'factor': 'Formation matchup',
              'details': 'Tactical advantage',
            },
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Simple string factor'), findsOneWidget);
      expect(find.text('Formation matchup'), findsOneWidget);
      expect(find.text('Tactical advantage'), findsOneWidget);
    });

    testWidgets('handles missing prediction key in analysisData',
        (WidgetTester tester) async {
      final analysisData = {
        'other': 'data',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('No key factors available'), findsOneWidget);
    });

    testWidgets('renders multiple string factors',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [
            'Factor one',
            'Factor two',
            'Factor three',
            'Factor four',
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      expect(find.text('Factor one'), findsOneWidget);
      expect(find.text('Factor two'), findsOneWidget);
      expect(find.text('Factor three'), findsOneWidget);
      expect(find.text('Factor four'), findsOneWidget);
    });

    testWidgets('handles map format with missing optional fields',
        (WidgetTester tester) async {
      final analysisData = {
        'prediction': {
          'keyFactors': [
            {
              // Missing category, impact, factor, details
            },
          ],
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIKeyFactorsTabWidget(
              analysisData: analysisData,
            ),
          ),
        ),
      );

      // Should use defaults
      expect(find.text('Factor'), findsOneWidget);
      expect(find.text('Medium Impact'), findsOneWidget);
      expect(find.text('Key factor to watch'), findsOneWidget);
      expect(find.text('Details not available'), findsOneWidget);
    });
  });
}
