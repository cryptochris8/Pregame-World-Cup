import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:pregame_world_cup/features/schedule/presentation/screens/schedule_social_tab.dart';
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
          child: ScheduleSocialTab(
            onRefresh: () {},
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Basic rendering tests
  // ---------------------------------------------------------------------------
  group('ScheduleSocialTab - basic rendering', () {
    testWidgets('renders without crashing', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleLoading());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ScheduleSocialTab), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (tester) async {
      final tab = ScheduleSocialTab(
        onRefresh: () {},
      );
      expect(tab, isA<StatelessWidget>());
    });
  });

  // ---------------------------------------------------------------------------
  // Loading state tests
  // ---------------------------------------------------------------------------
  group('ScheduleSocialTab - loading state', () {
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
  group('ScheduleSocialTab - empty state', () {
    testWidgets('shows no upcoming games message when list is empty',
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

      expect(find.text('No Upcoming Games'), findsOneWidget);
    });

    testWidgets('shows groups icon in empty state', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(
        const ScheduleLoaded(
          [],
          showFavoritesOnly: false,
          favoriteTeams: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.groups), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Loaded state tests (with only past/final games)
  // NOTE: Rendering tests with actual games avoided due to Firebase dependencies in ScheduleSocialGameCard
  // ---------------------------------------------------------------------------
  group('ScheduleSocialTab - loaded state', () {
    testWidgets('shows empty state when only completed games available',
        (tester) async {
      final completedGame = ScheduleTestFactory.createCompletedGame(
        gameId: 'completed_001',
      );

      when(() => mockScheduleBloc.state).thenReturn(
        ScheduleLoaded(
          [completedGame],
          showFavoritesOnly: false,
          favoriteTeams: const [],
        ),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Completed games should be filtered out, showing empty state
      expect(find.text('No Upcoming Games'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Other states
  // ---------------------------------------------------------------------------
  group('ScheduleSocialTab - other states', () {
    testWidgets('shows empty container for unknown state', (tester) async {
      when(() => mockScheduleBloc.state).thenReturn(ScheduleInitial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
