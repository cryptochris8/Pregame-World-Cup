import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/ai_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_game_insights_widget.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';
import '../../schedule_test_factory.dart';

class MockAIService extends Mock implements AIService {}

class FakeGameSchedule extends Fake implements GameSchedule {}

void main() {
  late MockAIService mockAIService;
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

    mockAIService = MockAIService();

    // Register mock in GetIt
    if (!getIt.isRegistered<AIService>()) {
      getIt.registerSingleton<AIService>(mockAIService);
    }
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest(GameSchedule game) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AIGameInsightsWidget(game: game),
      ),
    );
  }

  group('AIGameInsightsWidget', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Test prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Test insights');

      await tester.pumpWidget(createWidgetUnderTest(game));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('AI is analyzing the matchup...'), findsOneWidget);
    });

    testWidgets('shows error state when AI service fails',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenThrow(Exception('API error'));

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Unable to load AI analysis'), findsOneWidget);
    });

    testWidgets('displays AI Historical Insights header',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction text');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights text');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays game matchup in header', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame(
        awayTeamName: 'Spain',
        homeTeamName: 'Portugal',
      );

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(find.text('Spain @ Portugal'), findsOneWidget);
    });

    testWidgets('renders AI prediction section', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Brazil will likely win this match');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Key factors');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(find.text('Brazil will likely win this match'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('renders key insights section', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction text');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer(
              (_) async => 'Watch for defensive matchups and set pieces');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(
        find.text('Watch for defensive matchups and set pieces'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      var callCount = 0;
      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async {
        callCount++;
        return 'Prediction $callCount';
      });

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(callCount, 1);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(callCount, 2);
    });

    testWidgets('handles game with week number', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame(week: 5);

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      // Widget should render without errors
      expect(find.byType(AIGameInsightsWidget), findsOneWidget);
    });

    testWidgets('handles game with dateTimeUTC', (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame(
        dateTimeUTC: DateTime.utc(2026, 6, 20, 19, 0),
      );

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      // Widget should render without errors
      expect(find.byType(AIGameInsightsWidget), findsOneWidget);
    });

    testWidgets('shows both prediction and insights sections',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'AI Prediction content');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Key factors content');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      expect(find.text('AI Prediction content'), findsOneWidget);
      expect(find.text('Key factors content'), findsOneWidget);
    });

    testWidgets('shows loading indicator during initial load',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));

      // During loading, CircularProgressIndicator should be visible
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      // After loading, content should be visible
      expect(find.text('Prediction'), findsOneWidget);
    });

    testWidgets('renders gradient container background',
        (WidgetTester tester) async {
      final game = ScheduleTestFactory.createUpcomingGame();

      when(() => mockAIService.generateGamePrediction(
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            gameStats: any(named: 'gameStats'),
          )).thenAnswer((_) async => 'Prediction');

      when(() => mockAIService.generateCompletion(
            prompt: any(named: 'prompt'),
            systemMessage: any(named: 'systemMessage'),
            maxTokens: any(named: 'maxTokens'),
            temperature: any(named: 'temperature'),
          )).thenAnswer((_) async => 'Insights');

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      // Find container with gradient decoration
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('AI Insights'),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
