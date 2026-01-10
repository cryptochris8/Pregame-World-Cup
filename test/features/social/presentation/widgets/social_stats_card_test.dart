import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/social_stats_card.dart';

import '../../mock_factories.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: child,
          ),
        ),
      ),
    );
  }

  group('SocialStatsCard', () {
    testWidgets('renders Social Stats title', (tester) async {
      final stats = SocialTestFactory.createSocialStats();

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('Social Stats'), findsOneWidget);
    });

    testWidgets('renders friends count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(friendsCount: 42);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('renders games attended count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(gamesAttended: 12);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);
    });

    testWidgets('renders venues visited count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(venuesVisited: 25);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('25'), findsOneWidget);
      expect(find.text('Venues'), findsOneWidget);
    });

    testWidgets('renders reviews count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(reviewsCount: 8);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('8'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('renders photos count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(photosShared: 30);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('30'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
    });

    testWidgets('renders likes count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(likesReceived: 150);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('150'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('renders check-ins count', (tester) async {
      final stats = SocialTestFactory.createSocialStats(checkInsCount: 15);

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('Check-ins'), findsOneWidget);
    });

    testWidgets('calls onFriendsPressed when friends stat tapped', (tester) async {
      final stats = SocialTestFactory.createSocialStats();
      bool friendsTapped = false;

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(
          stats: stats,
          onFriendsPressed: () => friendsTapped = true,
        )),
      );

      // Find and tap the friends stat area
      final friendsFinder = find.ancestor(
        of: find.text('Friends'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(friendsFinder.first);

      expect(friendsTapped, isTrue);
    });

    testWidgets('calls onGamesPressed when games stat tapped', (tester) async {
      final stats = SocialTestFactory.createSocialStats();
      bool gamesTapped = false;

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(
          stats: stats,
          onGamesPressed: () => gamesTapped = true,
        )),
      );

      final gamesFinder = find.ancestor(
        of: find.text('Games'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gamesFinder.first);

      expect(gamesTapped, isTrue);
    });

    testWidgets('calls onVenuesPressed when venues stat tapped', (tester) async {
      final stats = SocialTestFactory.createSocialStats();
      bool venuesTapped = false;

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(
          stats: stats,
          onVenuesPressed: () => venuesTapped = true,
        )),
      );

      final venuesFinder = find.ancestor(
        of: find.text('Venues'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(venuesFinder.first);

      expect(venuesTapped, isTrue);
    });

    testWidgets('renders analytics icon', (tester) async {
      final stats = SocialTestFactory.createSocialStats();

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('renders people icon for friends', (tester) async {
      final stats = SocialTestFactory.createSocialStats();

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('renders zero counts correctly', (tester) async {
      final stats = SocialTestFactory.createSocialStats(
        friendsCount: 0,
        gamesAttended: 0,
        venuesVisited: 0,
      );

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      // Should find multiple '0' values
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('renders large numbers correctly', (tester) async {
      final stats = SocialTestFactory.createSocialStats(
        friendsCount: 1000,
        likesReceived: 9999,
      );

      await tester.pumpWidget(
        buildTestWidget(SocialStatsCard(stats: stats)),
      );

      expect(find.text('1000'), findsOneWidget);
      expect(find.text('9999'), findsOneWidget);
    });
  });
}
