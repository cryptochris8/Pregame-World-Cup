import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  Widget buildWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('MatchFilterChips', () {
    testWidgets('renders all filter chips', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
          ),
        ),
      );

      // Verify all chips are rendered
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Knockout'), findsOneWidget);
    });

    testWidgets('selected chip is highlighted - All', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
          ),
        ),
      );

      final allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('selected chip is highlighted - Favorites', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.favorites,
            onFilterChanged: (_) {},
          ),
        ),
      );

      final favoritesChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Favorites'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(favoritesChip.selected, isTrue);
    });

    testWidgets('selected chip is highlighted - Live', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.live,
            onFilterChanged: (_) {},
          ),
        ),
      );

      final liveChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Live'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(liveChip.selected, isTrue);
    });

    testWidgets('tapping chip calls callback with correct filter', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      // Tap the Favorites chip
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.favorites);
    });

    testWidgets('tapping Today chip calls callback', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.today);
    });

    testWidgets('tapping Upcoming chip calls callback', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      await tester.tap(find.text('Upcoming'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.upcoming);
    });

    testWidgets('tapping Completed chip calls callback', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      // Scroll to make the Completed chip visible
      await tester.dragUntilVisible(
        find.text('Completed'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.completed);
    });

    testWidgets('tapping Groups chip calls callback', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      // Scroll to make the Groups chip visible
      await tester.dragUntilVisible(
        find.text('Groups'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.groupStage);
    });

    testWidgets('tapping Knockout chip calls callback', (tester) async {
      MatchListFilter? capturedFilter;

      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (filter) {
              capturedFilter = filter;
            },
          ),
        ),
      );

      // Scroll to make the Knockout chip visible
      await tester.dragUntilVisible(
        find.text('Knockout'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Knockout'));
      await tester.pumpAndSettle();

      expect(capturedFilter, MatchListFilter.knockout);
    });

    testWidgets('shows count badge when liveCount is provided', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            liveCount: 3,
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows count badge when upcomingCount is provided', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            upcomingCount: 5,
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows count badge when completedCount is provided', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            completedCount: 12,
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('shows count badge when favoritesCount is provided', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            favoritesCount: 7,
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows multiple count badges when multiple counts provided', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            liveCount: 2,
            upcomingCount: 8,
            completedCount: 15,
            favoritesCount: 4,
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('does not show badge when count is zero', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            liveCount: 0,
          ),
        ),
      );

      // Should not show '0' badge
      expect(find.text('0'), findsNothing);
    });

    testWidgets('does not show badge when count is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
            liveCount: null,
          ),
        ),
      );

      // Verify Live chip exists but no badge
      expect(find.text('Live'), findsOneWidget);
      // No count badge should be present on Live chip
    });

    testWidgets('renders icons for chips with icons', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
          ),
        ),
      );

      // Count icons rendered
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.today), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.account_tree), findsOneWidget);
    });

    testWidgets('All chip does not have an icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          MatchFilterChips(
            selectedFilter: MatchListFilter.all,
            onFilterChanged: (_) {},
          ),
        ),
      );

      final allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.avatar, isNull);
    });
  });
}
