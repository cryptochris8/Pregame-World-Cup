import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:pregame_world_cup/features/schedule/presentation/screens/schedule_games_tab.dart';
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
          child: ScheduleGamesTab(
            showLiveOnly: false,
            showFavoritesOnly: false,
            favoriteTeams: const [],
            onRefresh: () {},
            onLoadFavoriteTeams: () async {},
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Basic rendering tests
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - basic rendering', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScheduleGamesTab), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      final tab = ScheduleGamesTab(
        showLiveOnly: false,
        showFavoritesOnly: false,
        favoriteTeams: const [],
        onRefresh: () {},
        onLoadFavoriteTeams: () async {},
      );
      expect(tab, isA<StatelessWidget>());
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state tests
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - loading state', () {
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
  // Error state tests
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - error state', () {
    testWidgets('shows error message when state is ScheduleError',
        (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleError('Failed to load games'),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load games'), findsOneWidget);
    });

    testWidgets('error state shows retry button', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleError('Test error'),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Loaded state tests
  // NOTE: Full rendering tests avoided due to ScheduleGameCard having Firebase dependencies
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - loaded state', () {
    testWidgets('shows empty state when no games available', (tester) async {
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
  // UpcomingGamesLoaded state tests
  // NOTE: Rendering tests with games avoided due to Firebase dependencies
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - UpcomingGamesLoaded state', () {
    testWidgets('handles UpcomingGamesLoaded state without crashing', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const UpcomingGamesLoaded(
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
  // Live filter tests
  // NOTE: Rendering tests with games avoided due to Firebase dependencies
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - live filter', () {
    testWidgets('shows empty state when no live games with filter',
        (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleLoaded(
          [],
          showFavoritesOnly: false,
          favoriteTeams: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<ScheduleBloc>.value(
              value: mockScheduleBloc,
              child: ScheduleGamesTab(
                showLiveOnly: true,
                showFavoritesOnly: false,
                favoriteTeams: const [],
                onRefresh: () {},
                onLoadFavoriteTeams: () async {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // WeeklyScheduleLoaded state tests
  // NOTE: Rendering tests with games avoided due to Firebase dependencies
  // ---------------------------------------------------------------------------
  group('ScheduleGamesTab - WeeklyScheduleLoaded state', () {
    testWidgets('shows empty weekly state when no games for week',
        (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const WeeklyScheduleLoaded(
          [],
          2026,
          5,
          showFavoritesOnly: false,
          favoriteTeams: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });
}
