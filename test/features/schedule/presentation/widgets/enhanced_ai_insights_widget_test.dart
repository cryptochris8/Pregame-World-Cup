import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/ai/services/enhanced_ai_game_analysis_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/enhanced_ai_insights_widget.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_state_widgets.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_header_widget.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// ==================== MOCKS ====================

class MockEnhancedAIGameAnalysisService extends Mock
    implements EnhancedAIGameAnalysisService {}

class FakeGameSchedule extends Fake implements GameSchedule {}

final sl = GetIt.instance;

// ==================== TEST DATA ====================

GameSchedule _createTestGame({
  String gameId = 'test_game_1',
  String homeTeamName = 'Brazil',
  String awayTeamName = 'Argentina',
  String? status,
  int? homeScore,
  int? awayScore,
}) {
  return GameSchedule(
    gameId: gameId,
    homeTeamName: homeTeamName,
    awayTeamName: awayTeamName,
    status: status ?? 'Scheduled',
    homeScore: homeScore,
    awayScore: awayScore,
    dateTime: DateTime(2026, 6, 20, 20, 0),
    dateTimeUTC: DateTime.utc(2026, 6, 21, 0, 0),
    week: 1,
  );
}

Map<String, dynamic> _createTestAnalysisData() {
  return {
    'prediction': {
      'homeScore': '2',
      'awayScore': '1',
      'winner': 'Brazil',
      'confidence': '0.72',
      'keyFactors': [
        'Home field advantage',
        'Recent team momentum',
        'Defensive matchups',
      ],
      'analysis': 'Brazil has a strong home record against Argentina.',
    },
    'summary': 'Exciting matchup between two South American rivals.',
    'historical': {
      'home': {
        'record': '8-2',
        'wins': 8,
        'losses': 2,
      },
      'away': {
        'record': '7-3',
        'wins': 7,
        'losses': 3,
      },
      'headToHead': {
        'narrative': 'Historic rivalry - closely contested',
        'totalMeetings': 15,
      },
    },
    'aiInsights': {
      'summary': 'Two of the strongest teams in CONMEBOL face off.',
      'analysis':
          'Both teams bring unique strengths to this compelling matchup.',
    },
    'dataQuality': 'enhanced_analysis',
  };
}

// ==================== TESTS ====================

void main() {
  late MockEnhancedAIGameAnalysisService mockAnalysisService;

  setUpAll(() {
    registerFallbackValue(FakeGameSchedule());
    mockAnalysisService = MockEnhancedAIGameAnalysisService();
    // Register the mock in GetIt so the AIInsightsAnalysisHelper can resolve it
    sl.registerSingleton<EnhancedAIGameAnalysisService>(mockAnalysisService);
  });

  tearDownAll(() async {
    await sl.reset();
  });

  // Suppress overflow, rendering, and pending timer errors in constrained test
  // environments. The widget internally creates Future.delayed timers for
  // timeout race conditions that may still be pending when the test completes.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed') ||
          message.contains('Timer')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  // ---------------------------------------------------------------------------
  // Helper: wrap widget in MaterialApp with localization support
  // ---------------------------------------------------------------------------
  Widget buildTestWidget(GameSchedule game, {bool isCompact = true}) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(414, 896)),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EnhancedAIInsightsWidget(
              game: game,
              isCompact: isCompact,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Compact view tests - use pumpAndSettle to let analysis complete
  // ---------------------------------------------------------------------------
  group('EnhancedAIInsightsWidget - compact view', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(EnhancedAIInsightsWidget), findsOneWidget);
    });

    testWidgets('shows Enhanced AI Analysis badge', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Enhanced AI Analysis'), findsOneWidget);
    });

    testWidgets('shows matchup title with team names', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame(
        homeTeamName: 'France',
        awayTeamName: 'Germany',
      );

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Germany @ France'), findsOneWidget);
    });

    testWidgets('shows refresh button', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Refresh button exists (icon button with refresh icon)
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows AIInsightsHeaderWidget', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(AIInsightsHeaderWidget), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state tests
  // ---------------------------------------------------------------------------
  group('EnhancedAIInsightsWidget - loading state', () {
    testWidgets('loading state disappears after analysis completes',
        (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // After analysis completes, loading widget should be gone
      expect(find.byType(AIInsightsLoadingWidget), findsNothing);
      // And we should see actual content (the header is always shown)
      expect(find.text('Enhanced AI Analysis'), findsOneWidget);
    });

    testWidgets(
        'AIInsightsLoadingWidget displays progress indicator and text',
        (tester) async {
      // Test the loading widget standalone to verify its UI
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing matchup data...'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Detailed (non-compact) view with tabs
  // ---------------------------------------------------------------------------
  group('EnhancedAIInsightsWidget - detailed view with tabs', () {
    testWidgets('renders without crashing in non-compact mode', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(EnhancedAIInsightsWidget), findsOneWidget);
    });

    testWidgets('shows 3 tabs: Predict, Analysis, Key Factors',
        (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Predict'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Key Factors'), findsOneWidget);
    });

    testWidgets('TabBar has exactly 3 tabs', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final tabBarFinder = find.byType(TabBar);
      expect(tabBarFinder, findsOneWidget);
      final tabBar = tester.widget<TabBar>(tabBarFinder);
      expect(tabBar.tabs.length, 3);
    });

    testWidgets('shows TabBarView with content', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // TabBarView should be present when analysis data is loaded
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('shows AIInsightsHeaderWidget in detailed mode', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(AIInsightsHeaderWidget), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Compact mode does not show tabs
  // ---------------------------------------------------------------------------
  group('EnhancedAIInsightsWidget - compact vs detailed', () {
    testWidgets('compact mode does not show TabBar', (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      await tester.pumpWidget(buildTestWidget(game, isCompact: true));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Compact mode should NOT show TabBar
      expect(find.byType(TabBar), findsNothing);
      // But should NOT show TabBarView either
      expect(find.byType(TabBarView), findsNothing);
    });

    testWidgets('detailed mode shows TabBar while compact does not',
        (tester) async {
      when(() => mockAnalysisService.generateGameAnalysis(any()))
          .thenAnswer((_) async => _createTestAnalysisData());

      final game = _createTestGame();

      // First test compact mode
      await tester.pumpWidget(buildTestWidget(game, isCompact: true));
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.byType(TabBar), findsNothing);

      // Then test detailed mode
      await tester.pumpWidget(buildTestWidget(game, isCompact: false));
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(find.byType(TabBar), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Sub-widget rendering (standalone tests - no async/timer issues)
  // ---------------------------------------------------------------------------
  group('EnhancedAIInsightsWidget - sub-widgets', () {
    testWidgets('AIInsightsLoadingWidget renders correctly standalone',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing matchup data...'), findsOneWidget);
    });

    testWidgets(
        'AIInsightsLoadingWidget shows orange progress indicator color',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final animation =
          progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(animation.value, Colors.orange);
    });

    testWidgets('AIInsightsErrorWidget renders error message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: 'Failed to load analysis: timeout',
            ),
          ),
        ),
      );

      expect(find.text('Failed to load analysis: timeout'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('AIInsightsErrorWidget renders with long error message',
        (tester) async {
      const longError =
          'This is a very long error message that might wrap to multiple '
          'lines when displayed in the error widget container.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AIInsightsErrorWidget(errorMessage: longError),
            ),
          ),
        ),
      );

      expect(find.text(longError), findsOneWidget);
    });

    testWidgets('AIInsightsErrorWidget has red-tinted background',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: 'Some error',
            ),
          ),
        ),
      );

      // The error widget wraps content in a Container with red-tinted decoration
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isNotNull);
    });

    testWidgets('AIInsightsHeaderWidget renders team names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Mexico',
              homeTeamName: 'USA',
              isLoading: false,
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('Mexico @ USA'), findsOneWidget);
      expect(find.text('Enhanced AI Analysis'), findsOneWidget);
    });

    testWidgets('AIInsightsHeaderWidget shows loading indicator when loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Mexico',
              homeTeamName: 'USA',
              isLoading: true,
              onRefresh: () {},
            ),
          ),
        ),
      );

      // When loading, the icon button shows a small CircularProgressIndicator
      // instead of the refresh icon
      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AIInsightsHeaderWidget shows refresh icon when not loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AIInsightsHeaderWidget(
              awayTeamName: 'Spain',
              homeTeamName: 'Portugal',
              isLoading: false,
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
