import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/bloc/nearby_venues_cubit.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/match_detail_page.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/reminder_button.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_filter_cubit.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/match_reminder_service.dart';

import '../../presentation/bloc/mock_repositories.dart';

// Mock cubits
class MockNearbyVenuesCubit extends MockCubit<NearbyVenuesState>
    implements NearbyVenuesCubit {}

class MockVenueFilterCubit extends MockCubit<VenueFilterState>
    implements VenueFilterCubit {}

// Mock services
class MockMatchReminderService extends Mock implements MatchReminderService {}

void main() {
  late MockNearbyVenuesCubit mockNearbyVenuesCubit;
  late MockVenueFilterCubit mockVenueFilterCubit;
  late MockMatchReminderService mockReminderService;

  setUpAll(() async {
    // Set up Firebase mocks so that Firebase-dependent services
    // (WorldCupPaymentService in FanPassFeatureGate) do not throw
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

    mockNearbyVenuesCubit = MockNearbyVenuesCubit();
    mockVenueFilterCubit = MockVenueFilterCubit();
    mockReminderService = MockMatchReminderService();

    // Stub cubit states
    when(() => mockNearbyVenuesCubit.state)
        .thenReturn(const NearbyVenuesState());
    when(() => mockVenueFilterCubit.state)
        .thenReturn(const VenueFilterState());

    // Stub cubit close methods to prevent errors during disposal
    when(() => mockNearbyVenuesCubit.close()).thenAnswer((_) async {});
    when(() => mockVenueFilterCubit.close()).thenAnswer((_) async {});

    // Stub cubit stream for BlocProvider
    when(() => mockNearbyVenuesCubit.stream)
        .thenAnswer((_) => const Stream<NearbyVenuesState>.empty());
    when(() => mockVenueFilterCubit.stream)
        .thenAnswer((_) => const Stream<VenueFilterState>.empty());

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

  /// Helper to pump the MatchDetailPage widget for testing.
  Future<void> pumpMatchDetailPage(
    WidgetTester tester,
    WorldCupMatch match,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(500, 1200)),
          child: MatchDetailPage(match: match),
        ),
      ),
    );
    await tester.pump();
  }

  group('MatchDetailPage', () {
    testWidgets('renders match teams (home and away team names)',
        (tester) async {
      final match = TestDataFactory.createMatch(
        homeTeamName: 'United States',
        awayTeamName: 'Mexico',
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);
    });

    testWidgets('shows scheduled status badge for scheduled match',
        (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
      );

      await pumpMatchDetailPage(tester, match);

      // Scheduled match shows 'vs' in the score display area
      expect(find.text('vs'), findsOneWidget);
    });

    testWidgets('shows live indicator for live match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.inProgress,
        homeScore: 1,
        awayScore: 0,
      );

      await pumpMatchDetailPage(tester, match);

      // The live indicator section contains 'Match in progress' text
      expect(find.textContaining('Match in progress'), findsOneWidget);
    });

    testWidgets('shows score for completed match', (tester) async {
      final match = TestDataFactory.createMatch(
        matchNumber: 50,
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 3,
      );

      await pumpMatchDetailPage(tester, match);

      // Score digits: homeScore=2 and awayScore=3
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Full Time'), findsOneWidget);
    });

    testWidgets('shows match info (date, time, stadium)', (tester) async {
      final match = TestDataFactory.createMatch(
        dateTime: DateTime(2026, 6, 11, 18, 0),
      );

      await pumpMatchDetailPage(tester, match);

      // The info card shows these labels
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Kick-off'), findsOneWidget);
      expect(find.text('Match Number'), findsOneWidget);
      expect(find.text('Stage'), findsOneWidget);
    });

    testWidgets('shows group stage label for group matches', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.groupStage,
        group: 'A',
      );

      await pumpMatchDetailPage(tester, match);

      // The stage display name for groupStage is 'Group Stage'
      expect(find.text('Group Stage'), findsAtLeastNWidgets(1));
      // The group label appears as 'Group A' in both the header and info card
      expect(find.text('Group A'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows knockout stage label for knockout matches',
        (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.roundOf16,
        group: null,
      );

      await pumpMatchDetailPage(tester, match);

      // The stage display name for roundOf16 is 'Round of 16'
      expect(find.text('Round of 16'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders without crashing when venue is not found',
        (tester) async {
      // Create a match with no venue - venueName comes from venue getter
      // so with no venue, the venue card should not appear
      final match = TestDataFactory.createMatch();

      await pumpMatchDetailPage(tester, match);

      // The page should still render the basic match info
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);
      expect(find.byType(MatchDetailPage), findsOneWidget);
    });

    testWidgets('shows reminder button for scheduled match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.scheduled,
      );

      await pumpMatchDetailPage(tester, match);

      // The ReminderButton widget is rendered in the app bar actions
      // for scheduled matches
      expect(find.byType(ReminderButton), findsOneWidget);
    });

    testWidgets('does NOT show reminder button for completed match',
        (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.completed,
        homeScore: 3,
        awayScore: 1,
      );

      await pumpMatchDetailPage(tester, match);

      // The ReminderButton should NOT appear for completed matches
      expect(find.byType(ReminderButton), findsNothing);
    });

    testWidgets('shows watch parties section', (tester) async {
      final match = TestDataFactory.createMatch();

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Watch Parties'), findsOneWidget);
      expect(
        find.text('Find or create a watch party for this match'),
        findsOneWidget,
      );
    });

    testWidgets('shows half time status for half time match', (tester) async {
      final match = TestDataFactory.createMatch(
        status: MatchStatus.halfTime,
        homeScore: 1,
        awayScore: 1,
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Half Time'), findsOneWidget);
    });

    testWidgets('shows match number in info card', (tester) async {
      final match = TestDataFactory.createMatch(
        matchNumber: 42,
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Match Number'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows quarter-final stage label', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.quarterFinal,
        group: null,
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Quarter-Final'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows final stage label', (tester) async {
      final match = TestDataFactory.createMatch(
        stage: MatchStage.final_,
        group: null,
      );

      await pumpMatchDetailPage(tester, match);

      expect(find.text('Final'), findsAtLeastNWidgets(1));
    });
  });
}
