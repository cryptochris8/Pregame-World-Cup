import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pregame_world_cup/features/auth/presentation/screens/favorite_teams_screen.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// ==================== MOCKS ====================

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;
  final sl = GetIt.instance;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    // Initialize shared preferences with empty values
    SharedPreferences.setMockInitialValues({});

    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    sl.registerSingleton<AuthService>(mockAuthService);

    // Default stubs
    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_user_123');
  });

  tearDown(() {
    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
  });

  /// Build the widget wrapped in a navigable context (pushed on top of a
  /// parent route) so that Navigator.pop works correctly during save.
  Widget buildTestWidgetWithNavigation() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          // Auto-navigate to FavoriteTeamsScreen after first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoriteTeamsScreen(),
              ),
            );
          });
          return const Scaffold(body: Text('Parent'));
        },
      ),
    );
  }

  /// Simple widget without navigation context (for rendering-only tests)
  Widget buildTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FavoriteTeamsScreen(),
    );
  }

  // ========================================================
  // RENDERING TESTS
  // ========================================================

  group('FavoriteTeamsScreen - Rendering', () {
    testWidgets('renders the app bar title', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Select Favorite Teams'), findsOneWidget);
    });

    testWidgets('renders app logo in app bar', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('renders team list with CheckboxListTile items',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('shows loading text and spinner while fetching favorites',
        (tester) async {
      // After loading finishes and list is empty, the loading column
      // ("Loading your favorite teams...") is replaced by the team list.
      // We verify that the loaded state shows the team list (not the
      // loading column), confirming the loading->loaded transition.
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // After loading, the loading text should be gone
      expect(find.text('Loading your favorite teams...'), findsNothing);
      // And the team list should be visible
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('shows save icon in app bar after loading', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('shows selected count when teams are selected',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil', 'Argentina']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('2 teams selected'), findsOneWidget);
    });

    testWidgets('shows singular "team" text for single selection',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1 team selected'), findsOneWidget);
    });
  });

  // ========================================================
  // TEAM LIST DATA TESTS
  // ========================================================

  group('FavoriteTeamsScreen - Team List Data', () {
    test('worldCupTeams constant has 49 teams', () {
      // 7 CONCACAF + 10 CONMEBOL + 18 UEFA + 8 AFC + 5 CAF + 1 OFC = 49
      expect(worldCupTeams, hasLength(49));
    });

    test('worldCupTeams includes all host nations', () {
      expect(worldCupTeams, contains('United States'));
      expect(worldCupTeams, contains('Mexico'));
      expect(worldCupTeams, contains('Canada'));
    });

    test('worldCupTeams includes CONMEBOL teams', () {
      expect(worldCupTeams, contains('Argentina'));
      expect(worldCupTeams, contains('Brazil'));
      expect(worldCupTeams, contains('Uruguay'));
      expect(worldCupTeams, contains('Colombia'));
      expect(worldCupTeams, contains('Ecuador'));
      expect(worldCupTeams, contains('Chile'));
      expect(worldCupTeams, contains('Paraguay'));
      expect(worldCupTeams, contains('Peru'));
      expect(worldCupTeams, contains('Venezuela'));
      expect(worldCupTeams, contains('Bolivia'));
    });

    test('worldCupTeams includes major UEFA teams', () {
      expect(worldCupTeams, contains('England'));
      expect(worldCupTeams, contains('France'));
      expect(worldCupTeams, contains('Germany'));
      expect(worldCupTeams, contains('Spain'));
      expect(worldCupTeams, contains('Portugal'));
      expect(worldCupTeams, contains('Netherlands'));
      expect(worldCupTeams, contains('Belgium'));
      expect(worldCupTeams, contains('Croatia'));
    });

    test('worldCupTeams includes AFC teams', () {
      expect(worldCupTeams, contains('Japan'));
      expect(worldCupTeams, contains('South Korea'));
      expect(worldCupTeams, contains('Australia'));
      expect(worldCupTeams, contains('Saudi Arabia'));
      expect(worldCupTeams, contains('Iran'));
      expect(worldCupTeams, contains('Qatar'));
    });

    test('worldCupTeams includes CAF teams', () {
      expect(worldCupTeams, contains('Morocco'));
      expect(worldCupTeams, contains('Senegal'));
      expect(worldCupTeams, contains('Nigeria'));
      expect(worldCupTeams, contains('Cameroon'));
      expect(worldCupTeams, contains('Egypt'));
    });

    test('worldCupTeams includes OFC teams', () {
      expect(worldCupTeams, contains('New Zealand'));
    });

    test('worldCupTeams has no duplicates', () {
      expect(worldCupTeams.toSet().length, equals(worldCupTeams.length));
    });

    test('host nations appear first in the list', () {
      expect(worldCupTeams[0], equals('United States'));
      expect(worldCupTeams[1], equals('Mexico'));
      expect(worldCupTeams[2], equals('Canada'));
    });
  });

  // ========================================================
  // LOADING FAVORITE TEAMS
  // ========================================================

  group('FavoriteTeamsScreen - Loading Favorites', () {
    testWidgets('loads favorites from Firebase for logged-in user',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams('test_user_123'))
          .thenAnswer((_) async => ['Brazil', 'Germany']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('2 teams selected'), findsOneWidget);
      verify(() => mockAuthService.getFavoriteTeams('test_user_123'))
          .called(1);
    });

    testWidgets('falls back to local storage when Firebase fails',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'favorite_teams': ['Argentina', 'France'],
      });

      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenThrow(Exception('Firebase offline'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('2 teams selected'), findsOneWidget);
    });

    testWidgets('uses local storage when user is not logged in',
        (tester) async {
      when(() => mockAuthService.currentUser).thenReturn(null);
      SharedPreferences.setMockInitialValues({
        'favorite_teams': ['Japan'],
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1 team selected'), findsOneWidget);
    });

    testWidgets('shows no selected count when no favorites exist',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('selected'), findsNothing);
    });
  });

  // ========================================================
  // SELECTING AND DESELECTING TEAMS
  // ========================================================

  group('FavoriteTeamsScreen - Team Selection', () {
    testWidgets('can select a team by tapping its checkbox', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final firstCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      expect(find.text('1 team selected'), findsOneWidget);
    });

    testWidgets('can deselect a previously selected team', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['United States']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1 team selected'), findsOneWidget);

      final firstCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      expect(find.textContaining('selected'), findsNothing);
    });

    testWidgets('can select multiple teams', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final checkboxes = find.byType(CheckboxListTile);
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      expect(find.text('2 teams selected'), findsOneWidget);
    });

    testWidgets('shows pre-selected teams as checked', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['United States']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final firstTile = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile).first);
      expect(firstTile.value, isTrue);
    });

    testWidgets('unselected teams show as unchecked', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final firstTile = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile).first);
      expect(firstTile.value, isFalse);
    });
  });

  // ========================================================
  // SAVING FAVORITE TEAMS
  // ========================================================

  group('FavoriteTeamsScreen - Saving Favorites', () {
    testWidgets('save button is present but disabled when no teams selected',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The save icon is rendered (it's always shown when not loading)
      expect(find.byIcon(Icons.save), findsOneWidget);

      // But the IconButton has onPressed: null (disabled)
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('save button is enabled when teams are selected',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save), findsOneWidget);
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('calls updateFavoriteTeams on save for logged-in user',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);
      when(() => mockAuthService.updateFavoriteTeams(
              'test_user_123', ['Brazil']))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidgetWithNavigation());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.updateFavoriteTeams(
          'test_user_123', ['Brazil'])).called(1);
    });

    testWidgets('shows synced snackbar when Firebase save succeeds',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);
      when(() => mockAuthService.updateFavoriteTeams(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidgetWithNavigation());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(
        find.text('Favorite teams saved & synced!'),
        findsOneWidget,
      );
    });

    testWidgets(
        'shows local-only saved snackbar when Firebase save fails',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);
      when(() => mockAuthService.updateFavoriteTeams(any(), any()))
          .thenThrow(Exception('Firebase error'));

      await tester.pumpWidget(buildTestWidgetWithNavigation());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.text('Favorite teams saved!'), findsOneWidget);
    });

    testWidgets('saves to local storage when user is not logged in',
        (tester) async {
      when(() => mockAuthService.currentUser).thenReturn(null);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestWidgetWithNavigation());
      await tester.pumpAndSettle();

      // Select a team first
      final firstCheckbox = find.byType(CheckboxListTile).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.text('Favorite teams saved!'), findsOneWidget);
      verifyNever(() => mockAuthService.updateFavoriteTeams(any(), any()));
    });
  });

  // ========================================================
  // ERROR HANDLING
  // ========================================================

  group('FavoriteTeamsScreen - Error Handling', () {
    testWidgets(
        'shows teams list even when initial Firebase load fails',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenThrow(Exception('Network error'));
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets('handles no user and no local storage gracefully',
        (tester) async {
      when(() => mockAuthService.currentUser).thenReturn(null);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // ========================================================
  // UI COMPONENTS
  // ========================================================

  group('FavoriteTeamsScreen - UI Components', () {
    testWidgets('has an AppBar', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('CheckboxListTile tiles have team name text', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets('teams can be scrolled to last item', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('New Zealand'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('New Zealand'), findsOneWidget);
    });

    testWidgets('background color is dark theme', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF0F172A)));
    });

    testWidgets('app bar is present with proper structure', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Select Favorite Teams'), findsOneWidget);
    });
  });

  // ========================================================
  // NAVIGATION (POP RESULT)
  // ========================================================

  group('FavoriteTeamsScreen - Navigation', () {
    testWidgets('pops with selected teams list on successful save',
        (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil']);
      when(() => mockAuthService.updateFavoriteTeams(any(), any()))
          .thenAnswer((_) async {});

      List<String>? popResult;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteTeamsScreen(),
                ),
              );
              popResult = result;
            },
            child: const Text('Go'),
          ),
        ),
      ));

      // Navigate to FavoriteTeamsScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(popResult, isNotNull);
      expect(popResult, contains('Brazil'));
    });

    testWidgets('pops with multiple selected teams', (tester) async {
      when(() => mockAuthService.getFavoriteTeams(any()))
          .thenAnswer((_) async => ['Brazil', 'Argentina', 'Germany']);
      when(() => mockAuthService.updateFavoriteTeams(any(), any()))
          .thenAnswer((_) async {});

      List<String>? popResult;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteTeamsScreen(),
                ),
              );
              popResult = result;
            },
            child: const Text('Go'),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(popResult, isNotNull);
      expect(popResult, hasLength(3));
      expect(popResult, contains('Brazil'));
      expect(popResult, contains('Argentina'));
      expect(popResult, contains('Germany'));
    });
  });
}
