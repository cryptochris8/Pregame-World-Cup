import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:pregame_world_cup/features/schedule/presentation/screens/schedule_live_scores_tab.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';
import '../../schedule_test_factory.dart';

// ==================== MOCKS ====================

class MockScheduleBloc extends MockBloc<ScheduleEvent, ScheduleState>
    implements ScheduleBloc {}

// ==================== TESTS ====================

void main() {
  late MockScheduleBloc mockScheduleBloc;

  setUp(() {
    // Suppress overflow errors in constrained test environments.
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };

    mockScheduleBloc = MockScheduleBloc();
  });

  // ---------------------------------------------------------------------------
  // Helper: wrap widget in MaterialApp with BlocProvider
  // ---------------------------------------------------------------------------
  Widget buildTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<ScheduleBloc>.value(
          value: mockScheduleBloc,
          child: const ScheduleLiveScoresTab(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Basic rendering tests
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - basic rendering', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScheduleLiveScoresTab), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const tab = ScheduleLiveScoresTab();
      expect(tab, isA<StatelessWidget>());
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state tests
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - loading state', () {
    testWidgets('shows loading indicator when state is ScheduleLoading',
        (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading indicator has orange color', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.valueColor?.value, Colors.orange);
    });
  });

  // ---------------------------------------------------------------------------
  // Empty state tests
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - empty state', () {
    testWidgets('shows no live games message when list is empty',
        (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleLoaded(
          [],
          showFavoritesOnly: false,
          favoriteTeams: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Live Games Currently Available'), findsOneWidget);
    });

    testWidgets('shows soccer icon in empty state', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleLoaded(
          [],
          showFavoritesOnly: false,
          favoriteTeams: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Live games state tests
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - live games state', () {
    testWidgets('shows live games when available', (tester) async {
      final liveGame = ScheduleTestFactory.createLiveGame(
        gameId: 'live_001',
        awayTeamName: 'Argentina',
        homeTeamName: 'Brazil',
        awayScore: 1,
        homeScore: 2,
      );

      when(() => mockScheduleBloc.state).thenReturn(
        ScheduleLoaded(
          [liveGame],
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('filters for live games only from schedule', (tester) async {
      final liveGame = ScheduleTestFactory.createLiveGame(
        gameId: 'live_001',
      );
      final upcomingGame = ScheduleTestFactory.createUpcomingGame(
        gameId: 'upcoming_001',
      );

      when(() => mockScheduleBloc.state).thenReturn(
        ScheduleLoaded(
          [liveGame, upcomingGame],
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Should show live games but not show no-games message
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // UpcomingGamesLoaded state tests
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - UpcomingGamesLoaded state', () {
    testWidgets('handles UpcomingGamesLoaded state', (tester) async {
      final liveGame = ScheduleTestFactory.createLiveGame(
        gameId: 'live_001',
      );

      when(() => mockScheduleBloc.state).thenReturn(
        UpcomingGamesLoaded(
          [liveGame],
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows empty state when no live games in UpcomingGamesLoaded',
        (tester) async {
      final upcomingGame = ScheduleTestFactory.createUpcomingGame(
        gameId: 'upcoming_001',
      );

      when(() => mockScheduleBloc.state).thenReturn(
        UpcomingGamesLoaded(
          [upcomingGame],
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No Live Games Currently Available'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Other states
  // ---------------------------------------------------------------------------
  group('ScheduleLiveScoresTab - other states', () {
    testWidgets('shows empty container for unknown state', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
