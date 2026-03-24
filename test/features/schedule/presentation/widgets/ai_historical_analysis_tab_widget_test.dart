import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_historical_analysis_tab_widget.dart';
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

  group('AIHistoricalAnalysisTabWidget', () {
    testWidgets('shows loading indicator when analysisData is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: null,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator when both historical and aiInsights are null',
        (WidgetTester tester) async {
      final analysisData = {'other': 'data'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders AI historical insights section',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('AI Historical Analysis'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsWidgets);
    });

    testWidgets('renders home team season analysis',
        (WidgetTester tester) async {
      final analysisData = {
        'historical': {
          'home': {
            'performance': {
              'record': '8-2',
            },
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Brazil Season Analysis'), findsOneWidget);
      expect(find.text('Record:'), findsWidgets);
      expect(find.text('8-2'), findsOneWidget);
    });

    testWidgets('renders away team season analysis',
        (WidgetTester tester) async {
      final analysisData = {
        'historical': {
          'away': {
            'performance': {
              'record': '7-3',
            },
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Argentina Season Analysis'), findsOneWidget);
      expect(find.text('7-3'), findsOneWidget);
    });

    testWidgets('renders head-to-head history section',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Head-to-Head History'), findsOneWidget);
      expect(find.text('Historic rivalry - closely contested'), findsOneWidget);
      expect(find.text('15 meetings'), findsOneWidget);
    });

    testWidgets('renders data quality info section',
        (WidgetTester tester) async {
      final analysisData = ScheduleTestFactory.createAiAnalysisData();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsWidgets);
      expect(
        find.textContaining('Season data based on'),
        findsOneWidget,
      );
    });

    testWidgets('handles empty historical data gracefully',
        (WidgetTester tester) async {
      final analysisData = {
        'aiInsights': {
          'summary': 'Test summary',
          'analysis': 'Test analysis',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('AI Historical Analysis'), findsOneWidget);
      expect(find.text('Test summary'), findsOneWidget);
      // Should not show team sections if historical data is missing
      expect(find.text('Brazil Season Analysis'), findsNothing);
      expect(find.text('Argentina Season Analysis'), findsNothing);
    });

    testWidgets('handles missing head-to-head narrative',
        (WidgetTester tester) async {
      final analysisData = {
        'historical': {
          'home': {
            'record': '8-2',
          },
          'away': {
            'record': '7-3',
          },
          'headToHead': {
            'totalMeetings': 10,
            // no narrative field
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      // Head-to-head section should not appear without narrative
      expect(find.text('Head-to-Head History'), findsNothing);
    });

    testWidgets('renders with complete AI insights data',
        (WidgetTester tester) async {
      final analysisData = {
        'aiInsights': {
          'summary': 'Comprehensive analysis summary',
          'analysis': 'Detailed analysis text',
        },
        'historical': {
          'home': {
            'performance': {
              'record': '10-5',
              'avgPointsFor': '2.5',
              'avgPointsAgainst': '1.2',
            },
            'narrative': 'Strong home season performance',
          },
          'away': {
            'performance': {
              'record': '8-7',
              'avgPointsFor': '2.0',
              'avgPointsAgainst': '1.8',
            },
            'narrative': 'Consistent away form',
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Comprehensive analysis summary'), findsOneWidget);
      expect(find.text('Detailed analysis text'), findsOneWidget);
      expect(find.text('10-5'), findsOneWidget);
      expect(find.text('8-7'), findsOneWidget);
      expect(find.text('Season Story:'), findsWidgets);
      expect(find.text('Strong home season performance'), findsOneWidget);
      expect(find.text('Consistent away form'), findsOneWidget);
    });

    testWidgets('displays avg points for and against',
        (WidgetTester tester) async {
      final analysisData = {
        'historical': {
          'home': {
            'performance': {
              'record': '10-5',
              'avgPointsFor': '2.5',
              'avgPointsAgainst': '1.2',
            },
          },
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalAnalysisTabWidget(
              analysisData: analysisData,
              homeTeamName: 'Brazil',
              awayTeamName: 'Argentina',
            ),
          ),
        ),
      );

      expect(find.text('Avg Points Scored:'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('Avg Points Allowed:'), findsOneWidget);
      expect(find.text('1.2'), findsOneWidget);
    });
  });
}
