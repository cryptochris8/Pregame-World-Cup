import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_filter_cubit.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/match_reminder_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

import '../features/worldcup/presentation/bloc/mock_repositories.dart';

// ---------------------------------------------------------------
// Mock cubits
// ---------------------------------------------------------------
class MockMatchListCubit extends MockCubit<MatchListState>
    implements MatchListCubit {}

class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

class MockPredictionsCubit extends MockCubit<PredictionsState>
    implements PredictionsCubit {}

class MockNearbyVenuesCubit extends MockCubit<NearbyVenuesState>
    implements NearbyVenuesCubit {}

class MockVenueFilterCubit extends MockCubit<VenueFilterState>
    implements VenueFilterCubit {}

// ---------------------------------------------------------------
// Mock services
// ---------------------------------------------------------------
class MockMatchReminderService extends Mock implements MatchReminderService {}

void main() {
  late MockMatchListCubit mockMatchListCubit;
  late MockFavoritesCubit mockFavoritesCubit;
  late MockPredictionsCubit mockPredictionsCubit;
  late MockNearbyVenuesCubit mockNearbyVenuesCubit;
  late MockVenueFilterCubit mockVenueFilterCubit;
  late MockMatchReminderService mockReminderService;

  // -----------------------------------------------------------
  // Firebase setup (same pattern as match_detail_page_test.dart)
  // -----------------------------------------------------------
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    // Ignore overflow errors in widget tests
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('_dependents.isEmpty')) {
        return;
      }
      FlutterError.presentError(details);
    };

    mockMatchListCubit = MockMatchListCubit();
    mockFavoritesCubit = MockFavoritesCubit();
    mockPredictionsCubit = MockPredictionsCubit();
    mockNearbyVenuesCubit = MockNearbyVenuesCubit();
    mockVenueFilterCubit = MockVenueFilterCubit();
    mockReminderService = MockMatchReminderService();

    // Stub cubit states
    when(() => mockMatchListCubit.state)
        .thenReturn(MatchListState.initial());
    when(() => mockFavoritesCubit.state)
        .thenReturn(FavoritesState.initial());
    when(() => mockPredictionsCubit.state)
        .thenReturn(PredictionsState.initial());
    when(() => mockNearbyVenuesCubit.state)
        .thenReturn(const NearbyVenuesState());
    when(() => mockVenueFilterCubit.state)
        .thenReturn(const VenueFilterState());

    // Stub cubit close methods
    when(() => mockMatchListCubit.close()).thenAnswer((_) async {});
    when(() => mockFavoritesCubit.close()).thenAnswer((_) async {});
    when(() => mockPredictionsCubit.close()).thenAnswer((_) async {});
    when(() => mockNearbyVenuesCubit.close()).thenAnswer((_) async {});
    when(() => mockVenueFilterCubit.close()).thenAnswer((_) async {});

    // Stub cubit streams for BlocProvider
    when(() => mockMatchListCubit.stream)
        .thenAnswer((_) => const Stream<MatchListState>.empty());
    when(() => mockFavoritesCubit.stream)
        .thenAnswer((_) => const Stream<FavoritesState>.empty());
    when(() => mockPredictionsCubit.stream)
        .thenAnswer((_) => const Stream<PredictionsState>.empty());
    when(() => mockNearbyVenuesCubit.stream)
        .thenAnswer((_) => const Stream<NearbyVenuesState>.empty());
    when(() => mockVenueFilterCubit.stream)
        .thenAnswer((_) => const Stream<VenueFilterState>.empty());

    // Stub MatchListCubit methods that the MatchListPage calls on init
    when(() => mockMatchListCubit.init()).thenAnswer((_) async {});

    // Stub reminder service methods
    when(() => mockReminderService.hasReminderCached(any())).thenReturn(false);
    when(() => mockReminderService.getReminderTimingCached(any()))
        .thenReturn(null);
    when(() => mockReminderService.hasReminder(any()))
        .thenAnswer((_) async => false);

    // Register mocks in GetIt
    final sl = GetIt.instance;
    sl.registerFactory<NearbyVenuesCubit>(() => mockNearbyVenuesCubit);
    sl.registerFactory<VenueFilterCubit>(() => mockVenueFilterCubit);
    sl.registerSingleton<MatchReminderService>(mockReminderService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  // -----------------------------------------------------------
  // Helper: build MatchListPage wrapped in required providers
  // -----------------------------------------------------------
  Future<void> pumpMatchListPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MatchListCubit>.value(value: mockMatchListCubit),
          BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
          BlocProvider<PredictionsCubit>.value(value: mockPredictionsCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(size: Size(500, 1200)),
            child: MatchListPage(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // -----------------------------------------------------------
  // Helper: build MatchDetailPage for a given match
  // -----------------------------------------------------------
  Future<void> pumpMatchDetailPage(
    WidgetTester tester,
    WorldCupMatch match,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(500, 1200)),
          child: MatchDetailPage(match: match),
        ),
      ),
    );
    await tester.pump();
  }

  // -----------------------------------------------------------
  // Helper: build a navigable app with match list that navigates
  // to match detail
  // -----------------------------------------------------------
  Future<void> pumpNavigableApp(
    WidgetTester tester,
    List<WorldCupMatch> matches,
  ) async {
    // Set up loaded state with matches
    final loadedState = MatchListState(
      matches: matches,
      filteredMatches: matches,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
    when(() => mockMatchListCubit.state).thenReturn(loadedState);
    whenListen(
      mockMatchListCubit,
      Stream<MatchListState>.value(loadedState),
      initialState: loadedState,
    );

    // Set up favorites state (no favorites)
    const favoritesState = FavoritesState(isLoading: false);
    when(() => mockFavoritesCubit.state).thenReturn(favoritesState);
    whenListen(
      mockFavoritesCubit,
      Stream<FavoritesState>.value(favoritesState),
      initialState: favoritesState,
    );

    // Set up predictions state (no predictions)
    const predictionsState = PredictionsState(isLoading: false);
    when(() => mockPredictionsCubit.state).thenReturn(predictionsState);
    whenListen(
      mockPredictionsCubit,
      Stream<PredictionsState>.value(predictionsState),
      initialState: predictionsState,
    );

    // Stub all methods that may be called
    when(() => mockFavoritesCubit.isMatchFavorite(any())).thenReturn(false);
    when(() => mockPredictionsCubit.getPredictionForMatch(any()))
        .thenReturn(null);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MatchListCubit>.value(value: mockMatchListCubit),
          BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
          BlocProvider<PredictionsCubit>.value(value: mockPredictionsCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(size: Size(500, 1200)),
            child: MatchListPage(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // =============================================================
  // Test Group: Match Browsing Flow
  // =============================================================
  group('Match Browsing Flow', () {
    // ---------------------------------------------------------
    // 1. Match list renders matches from cubit state
    // ---------------------------------------------------------
    testWidgets('match list renders matches from cubit state',
        (tester) async {
      final matches = [
        TestDataFactory.createMatch(
          matchId: 'match_1',
          matchNumber: 1,
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
        ),
        TestDataFactory.createMatch(
          matchId: 'match_2',
          matchNumber: 2,
          homeTeamCode: 'BRA',
          homeTeamName: 'Brazil',
          awayTeamCode: 'ARG',
          awayTeamName: 'Argentina',
        ),
      ];

      await pumpNavigableApp(tester, matches);

      // Verify both match cards are rendered via team codes in MatchCard header
      expect(find.text('Match 1'), findsOneWidget);
      expect(find.text('Match 2'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 2. Tapping match card triggers navigation callback
    // ---------------------------------------------------------
    testWidgets('tapping match card triggers match tap action',
        (tester) async {
      final matches = [
        TestDataFactory.createMatch(
          matchId: 'match_1',
          matchNumber: 1,
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
        ),
      ];

      await pumpNavigableApp(tester, matches);

      // Tap the first MatchCard
      await tester.tap(find.byType(MatchCard).first);
      await tester.pump();

      // MatchListPage shows a snackbar on tap (see _onMatchTap)
      expect(find.text('United States vs Mexico'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 3. Match detail shows correct match data
    // ---------------------------------------------------------
    testWidgets('match detail page shows correct match data',
        (tester) async {
      final match = TestDataFactory.createMatch(
        matchId: 'match_1',
        matchNumber: 42,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        stage: MatchStage.groupStage,
        group: 'A',
        dateTime: DateTime(2026, 6, 11, 18, 0),
      );

      await pumpMatchDetailPage(tester, match);

      // Verify team names appear on the detail page
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);

      // Verify stage and group information
      expect(find.text('Group Stage'), findsAtLeastNWidgets(1));
      expect(find.text('Group A'), findsAtLeastNWidgets(1));

      // Verify match number in info card
      expect(find.text('42'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 4. Back navigation returns to match list
    // ---------------------------------------------------------
    testWidgets('back navigation returns to match list', (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
      );

      // Build a two-screen Navigator stack
      final loadedState = MatchListState(
        matches: [match],
        filteredMatches: [match],
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      when(() => mockMatchListCubit.state).thenReturn(loadedState);
      whenListen(
        mockMatchListCubit,
        Stream<MatchListState>.value(loadedState),
        initialState: loadedState,
      );
      const favoritesState = FavoritesState(isLoading: false);
      when(() => mockFavoritesCubit.state).thenReturn(favoritesState);
      whenListen(
        mockFavoritesCubit,
        Stream<FavoritesState>.value(favoritesState),
        initialState: favoritesState,
      );
      const predictionsState = PredictionsState(isLoading: false);
      when(() => mockPredictionsCubit.state).thenReturn(predictionsState);
      whenListen(
        mockPredictionsCubit,
        Stream<PredictionsState>.value(predictionsState),
        initialState: predictionsState,
      );

      // Build an app that starts on match list, with a route to detail
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MatchListCubit>.value(value: mockMatchListCubit),
            BlocProvider<FavoritesCubit>.value(value: mockFavoritesCubit),
            BlocProvider<PredictionsCubit>.value(value: mockPredictionsCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(size: Size(500, 1200)),
              child: Builder(
                builder: (context) => Scaffold(
                  body: const Text('Match List Screen'),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchDetailPage(match: match),
                        ),
                      );
                    },
                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify we start on the match list screen
      expect(find.text('Match List Screen'), findsOneWidget);

      // Navigate to match detail
      await tester.tap(find.byType(FloatingActionButton));
      // Use pump with duration instead of pumpAndSettle (non-terminating animations)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we're on the detail page
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);

      // Navigate back using the Navigator directly
      Navigator.of(tester.element(find.byType(MatchDetailPage))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we're back on the match list screen
      expect(find.text('Match List Screen'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 5. Different match statuses render correctly in list
    // ---------------------------------------------------------
    testWidgets('different match statuses render correctly in list',
        (tester) async {
      final matches = [
        TestDataFactory.createMatch(
          matchId: 'scheduled_match',
          matchNumber: 1,
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
          status: MatchStatus.scheduled,
        ),
        TestDataFactory.createMatch(
          matchId: 'live_match',
          matchNumber: 2,
          homeTeamCode: 'BRA',
          homeTeamName: 'Brazil',
          awayTeamCode: 'ARG',
          awayTeamName: 'Argentina',
          status: MatchStatus.inProgress,
          homeScore: 1,
          awayScore: 0,
        ),
        TestDataFactory.createMatch(
          matchId: 'completed_match',
          matchNumber: 3,
          homeTeamCode: 'GER',
          homeTeamName: 'Germany',
          awayTeamCode: 'FRA',
          awayTeamName: 'France',
          status: MatchStatus.completed,
          homeScore: 2,
          awayScore: 3,
        ),
      ];

      await pumpNavigableApp(tester, matches);

      // All three match cards should be rendered
      expect(find.byType(MatchCard), findsNWidgets(3));

      // Verify scheduled and completed match numbers appear
      // Note: live matches show LiveBadge instead of 'Match N'
      expect(find.text('Match 1'), findsOneWidget);
      expect(find.text('Match 3'), findsOneWidget);

      // Verify the live match has a LiveBadge instead
      expect(find.byType(LiveBadge), findsAtLeastNWidgets(1));
    });

    // ---------------------------------------------------------
    // Additional: loading state shows progress indicator
    // ---------------------------------------------------------
    testWidgets('loading state shows progress indicator', (tester) async {
      when(() => mockMatchListCubit.state)
          .thenReturn(MatchListState.initial());
      whenListen(
        mockMatchListCubit,
        const Stream<MatchListState>.empty(),
        initialState: MatchListState.initial(),
      );
      const favoritesState = FavoritesState(isLoading: false);
      when(() => mockFavoritesCubit.state).thenReturn(favoritesState);
      whenListen(
        mockFavoritesCubit,
        const Stream<FavoritesState>.empty(),
        initialState: favoritesState,
      );
      const predictionsState = PredictionsState(isLoading: false);
      when(() => mockPredictionsCubit.state).thenReturn(predictionsState);
      whenListen(
        mockPredictionsCubit,
        const Stream<PredictionsState>.empty(),
        initialState: predictionsState,
      );

      await pumpMatchListPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ---------------------------------------------------------
    // Additional: error state shows error message and retry button
    // ---------------------------------------------------------
    testWidgets('error state shows error message and retry button',
        (tester) async {
      const errorState = MatchListState(
        isLoading: false,
        errorMessage: 'Failed to load matches: network error',
      );
      when(() => mockMatchListCubit.state).thenReturn(errorState);
      whenListen(
        mockMatchListCubit,
        Stream<MatchListState>.value(errorState),
        initialState: errorState,
      );
      const favoritesState = FavoritesState(isLoading: false);
      when(() => mockFavoritesCubit.state).thenReturn(favoritesState);
      whenListen(
        mockFavoritesCubit,
        const Stream<FavoritesState>.empty(),
        initialState: favoritesState,
      );
      const predictionsState = PredictionsState(isLoading: false);
      when(() => mockPredictionsCubit.state).thenReturn(predictionsState);
      whenListen(
        mockPredictionsCubit,
        const Stream<PredictionsState>.empty(),
        initialState: predictionsState,
      );

      // Stub loadMatches for retry
      when(() => mockMatchListCubit.loadMatches()).thenAnswer((_) async {});

      await pumpMatchListPage(tester);

      expect(find.textContaining('Failed to load matches'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // Additional: match detail page shows different stages
    // ---------------------------------------------------------
    testWidgets('match detail page shows knockout stage correctly',
        (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.quarterFinal,
        group: null,
        homeTeamName: 'Brazil',
        awayTeamName: 'Germany',
        homeTeamCode: 'BRA',
        awayTeamCode: 'GER',
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('Quarter-Final'), findsAtLeastNWidgets(1));
    });
  });
}
