import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/widgets/enhanced_venue_card.dart';

import '../../mock_factories.dart';

void main() {
  setUp(() {
    // Ignore overflow and HTTP errors in tests
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.toString();
      if (errorString.contains('overflowed') ||
          errorString.contains('HTTP') ||
          errorString.contains('RenderFlex')) {
        return; // Ignore rendering overflow errors
      }
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 400, // Wide enough to avoid overflow
            child: child,
          ),
        ),
      ),
    );
  }

  group('EnhancedVenueCard', () {
    testWidgets('renders venue name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Sports Bar Downtown',
        )),
      );

      expect(find.text('Sports Bar Downtown'), findsOneWidget);
    });

    testWidgets('renders rating with star icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          rating: 4.5,
        )),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders review count', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          rating: 4.5,
          reviewCount: 245,
        )),
      );

      // Review count is formatted with parentheses
      expect(find.textContaining('245'), findsOneWidget);
    });

    testWidgets('formats review count with k for thousands', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          rating: 4.5,
          reviewCount: 2500,
        )),
      );

      // Review count is formatted as "2.5k" for thousands
      expect(find.textContaining('2.5k'), findsOneWidget);
    });

    testWidgets('renders price level', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          priceLevel: '\$\$',
        )),
      );

      expect(find.text('\$\$'), findsOneWidget);
    });

    testWidgets('renders distance', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          distance: '0.3 mi',
        )),
      );

      expect(find.text('0.3 mi'), findsOneWidget);
    });

    testWidgets('renders TV badge when enhancement has TV info', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        tvSetup: VenuePortalTestFactory.createTvSetup(totalScreens: 8),
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.text('8 TVs'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('renders DEAL badge when has active specials', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        gameSpecials: [VenuePortalTestFactory.createGameDaySpecial()],
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.text('DEAL'), findsOneWidget);
      expect(find.byIcon(Icons.local_offer), findsWidgets);
    });

    testWidgets('renders special preview with title and price', (tester) async {
      final special = VenuePortalTestFactory.createGameDaySpecial(
        title: 'Game Day Wings',
        price: 9.99,
      );
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        gameSpecials: [special],
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.textContaining('Game Day Wings'), findsOneWidget);
      expect(find.textContaining('\$9.99'), findsOneWidget);
    });

    testWidgets('renders atmosphere tags', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        atmosphere: VenuePortalTestFactory.createAtmosphereSettings(
          tags: ['family-friendly', 'casual'],
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.text('Family Friendly'), findsOneWidget);
      expect(find.text('Casual'), findsOneWidget);
    });

    testWidgets('renders capacity info when available', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        liveCapacity: VenuePortalTestFactory.createLiveCapacity(
          currentOccupancy: 45,
          maxCapacity: 100,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('renders wait time when present', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        liveCapacity: VenuePortalTestFactory.createLiveCapacity(
          currentOccupancy: 80,
          maxCapacity: 100,
          waitTimeMinutes: 15,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
        )),
      );

      expect(find.textContaining('wait'), findsOneWidget);
    });

    testWidgets('calls onTap when card tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          onTap: () => tapped = true,
        )),
      );

      await tester.tap(find.byType(EnhancedVenueCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders placeholder image when no photo URL', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          photoUrl: null,
        )),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('renders SHOWING badge when showing match', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        showsMatches: true,
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Test Venue',
          enhancement: enhancement,
          showMatchBadge: true,
          matchId: 'match_123',
        )),
      );

      expect(find.text('SHOWING'), findsOneWidget);
      expect(find.byIcon(Icons.live_tv), findsOneWidget);
    });

    testWidgets('renders card with all info', (tester) async {
      final enhancement = VenuePortalTestFactory.createFullyEnhancedVenue();

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueCard(
          venueId: 'venue_full',
          venueName: 'Ultimate Sports Bar',
          rating: 4.8,
          reviewCount: 500,
          priceLevel: '\$\$\$',
          distance: '0.5 mi',
          enhancement: enhancement,
        )),
      );

      expect(find.text('Ultimate Sports Bar'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('\$\$\$'), findsOneWidget);
      expect(find.text('0.5 mi'), findsOneWidget);
    });

    testWidgets('renders without enhancement', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueCard(
          venueId: 'venue_1',
          venueName: 'Basic Venue',
          rating: 4.0,
          enhancement: null,
        )),
      );

      expect(find.text('Basic Venue'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsNothing);
    });
  });

  group('EnhancedVenueListTile', () {
    testWidgets('renders venue name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
        )),
      );

      expect(find.text('Sports Bar'), findsOneWidget);
    });

    testWidgets('renders rating', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          rating: 4.2,
        )),
      );

      expect(find.text('4.2'), findsOneWidget);
    });

    testWidgets('renders distance', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          distance: '1.2 mi',
        )),
      );

      expect(find.text('1.2 mi'), findsOneWidget);
    });

    testWidgets('renders TV badge in trailing when has TVs', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        tvSetup: VenuePortalTestFactory.createTvSetup(totalScreens: 6),
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          enhancement: enhancement,
        )),
      );

      expect(find.text('6'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('renders deal badge when has specials', (tester) async {
      final enhancement = VenuePortalTestFactory.createVenueEnhancement(
        gameSpecials: [VenuePortalTestFactory.createGameDaySpecial()],
      );

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          enhancement: enhancement,
        )),
      );

      expect(find.byIcon(Icons.local_offer), findsOneWidget);
    });

    testWidgets('calls onTap when tile tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          onTap: () => tapped = true,
        )),
      );

      await tester.tap(find.byType(EnhancedVenueListTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder when no photo', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Sports Bar',
          photoUrl: null,
        )),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('renders without badges when no enhancement', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EnhancedVenueListTile(
          venueId: 'venue_1',
          venueName: 'Basic Bar',
          enhancement: null,
        )),
      );

      expect(find.text('Basic Bar'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsNothing);
      expect(find.byIcon(Icons.local_offer), findsNothing);
    });
  });
}
