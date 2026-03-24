import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/enhanced_ai_game_analysis_service.dart';
import 'package:pregame_world_cup/core/ai/services/ai_historical_knowledge_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_historical_insights_widget.dart';
import '../../schedule_test_factory.dart';

class MockEnhancedAIGameAnalysisService extends Mock
    implements EnhancedAIGameAnalysisService {}

class MockAIHistoricalKnowledgeService extends Mock
    implements AIHistoricalKnowledgeService {}

class FakeGameSchedule extends Fake implements GameSchedule {}

void main() {
  late MockEnhancedAIGameAnalysisService mockAnalysisService;
  late MockAIHistoricalKnowledgeService mockKnowledgeService;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(FakeGameSchedule());
  });

  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('RenderFlex overflowed')) {
        FlutterError.presentError(details);
      }
    };

    mockAnalysisService = MockEnhancedAIGameAnalysisService();
    mockKnowledgeService = MockAIHistoricalKnowledgeService();

    // Register mocks in GetIt
    if (!getIt.isRegistered<EnhancedAIGameAnalysisService>()) {
      getIt.registerSingleton<EnhancedAIGameAnalysisService>(mockAnalysisService);
    }
    if (!getIt.isRegistered<AIHistoricalKnowledgeService>()) {
      getIt.registerSingleton<AIHistoricalKnowledgeService>(mockKnowledgeService);
    }
  });

  tearDown(() {
    getIt.reset();
  });

  group('AIHistoricalInsightsWidget', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => false);
      when(() => mockAnalysisService.generateQuickSummary(any()))
          .thenAnswer((_) async => 'Quick summary');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(game: game),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing historical data...'), findsOneWidget);
    });

    testWidgets('shows error state when analysis fails',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenThrow(Exception('Failed to load'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Analysis temporarily unavailable'), findsOneWidget);
    });

    testWidgets('shows quick summary when knowledge base not ready',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => false);
      when(() => mockAnalysisService.generateQuickSummary(any()))
          .thenAnswer((_) async => 'Exciting matchup expected');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Exciting matchup expected'), findsOneWidget);
    });

    testWidgets('displays AI Historical Insights header',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => false);
      when(() => mockAnalysisService.generateQuickSummary(any()))
          .thenAnswer((_) async => 'Summary');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI Historical Insights'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('shows full analysis when showFullAnalysis is true',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'prediction': {
          'predictedWinner': 'Brazil',
          'confidence': 0.75,
          'predictedScore': {
            'home': 2,
            'away': 1,
          },
        },
        'keyFactors': ['Home advantage', 'Recent form'],
        'aiInsights': {
          'summary': 'Comprehensive analysis',
          'keyInsights': ['Insight 1', 'Insight 2'],
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI Prediction'), findsOneWidget);
      expect(find.text('Key Factors'), findsOneWidget);
      expect(find.text('AI Analysis'), findsOneWidget);
    });

    testWidgets('renders prediction widget with confidence',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'prediction': {
          'predictedWinner': 'Brazil',
          'confidence': 0.85,
          'predictedScore': {
            'home': 3,
            'away': 1,
          },
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Predicted Winner: Brazil'), findsOneWidget);
      expect(find.text('Confidence: 85%'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders key factors list', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'keyFactors': [
          'Home field advantage',
          'Recent team form',
          'Head-to-head record',
        ],
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home field advantage'), findsOneWidget);
      expect(find.text('Recent team form'), findsOneWidget);
      expect(find.text('Head-to-head record'), findsOneWidget);
    });

    testWidgets('renders AI insights with summary and analysis',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'aiInsights': {
          'summary': 'This is a crucial matchup',
          'keyInsights': [
            'Strong defensive record',
            'Offensive struggles',
          ],
          'historicalNotes': 'These teams have met 10 times before',
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('This is a crucial matchup'), findsOneWidget);
      expect(find.text('Key Insights:'), findsOneWidget);
      expect(find.text('Strong defensive record'), findsOneWidget);
      expect(find.text('Historical Context:'), findsOneWidget);
      expect(find.text('These teams have met 10 times before'), findsOneWidget);
    });

    testWidgets('handles null aiInsights gracefully',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'prediction': {
          'predictedWinner': 'Brazil',
          'confidence': 0.70,
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render prediction section
      expect(find.text('AI Prediction'), findsOneWidget);
      // But not AI Analysis section
      expect(find.text('AI Analysis'), findsNothing);
    });

    testWidgets('shows expand button for quick summary',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => false);
      when(() => mockAnalysisService.generateQuickSummary(any()))
          .thenAnswer((_) async => 'Quick match summary');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(game: game),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('View detailed analysis'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('handles empty predicted score', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'prediction': {
          'predictedWinner': 'Brazil',
          'confidence': 0.75,
          'predictedScore': <String, dynamic>{},
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Predicted Winner: Brazil'), findsOneWidget);
      // Predicted Score should not appear when empty
      expect(find.textContaining('Predicted Score:'), findsNothing);
    });

    testWidgets('displays predicted score when available',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();
      final analysisData = {
        'prediction': {
          'predictedWinner': 'Brazil',
          'confidence': 0.80,
          'predictedScore': <String, dynamic>{
            'home': 2,
            'away': 1,
          },
        },
      };

      when(() => mockKnowledgeService.isKnowledgeBaseReady())
          .thenAnswer((_) async => true);
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => analysisData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIHistoricalInsightsWidget(
              game: game,
              showFullAnalysis: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Predicted Score:'), findsOneWidget);
    });
  });
}
