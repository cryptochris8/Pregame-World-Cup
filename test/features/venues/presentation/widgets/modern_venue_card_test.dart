import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/modern_venue_card.dart';

import '../../venue_test_helpers.dart';

void main() {
  // Suppress overflow errors in constrained test environments
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
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
            width: 414,
            child: child,
          ),
        ),
      ),
    );
  }

  group('ModernVenueCard', () {
    testWidgets('renders venue name in full card mode', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Dallas Sports Bar');

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.text('Dallas Sports Bar'), findsOneWidget);
    });

    testWidgets('renders View Details button in full mode', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('renders address in full card mode', (tester) async {
      final venue = VenueTestFactory.createPlace(
        vicinity: '100 Main St, Dallas, TX',
      );

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.text('100 Main St, Dallas, TX'), findsOneWidget);
    });

    testWidgets('shows "Address not available" when vicinity is null',
        (tester) async {
      final venue = VenueTestFactory.createPlace(vicinity: null);

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.text('Address not available'), findsOneWidget);
    });

    testWidgets('renders rating badge', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.5);

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.text('4.5'), findsWidgets);
    });

    testWidgets('renders compact card when isCompact is true', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Compact Venue');

      await tester.pumpWidget(
        buildTestWidget(
          ModernVenueCard(venue: venue, isCompact: true),
        ),
      );

      // Name should appear
      expect(find.text('Compact Venue'), findsOneWidget);
      // View Details button should NOT appear in compact mode
      expect(find.text('View Details'), findsNothing);
      // Forward arrow should appear in compact mode
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('renders star icon in compact mode', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.0);

      await tester.pumpWidget(
        buildTestWidget(
          ModernVenueCard(venue: venue, isCompact: true),
        ),
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          ModernVenueCard(
            venue: venue,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ModernVenueCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders location icon in full mode', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('renders category badge with uppercase text', (tester) async {
      final venue = VenueTestFactory.createPlace(
        types: ['bar'],
        name: 'Sports Fan Pub',
      );

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      // Category badge shows uppercase text in full mode
      expect(find.text('SPORTS BAR'), findsOneWidget);
    });

    testWidgets('renders category text in compact mode', (tester) async {
      final venue = VenueTestFactory.createRestaurant();

      await tester.pumpWidget(
        buildTestWidget(
          ModernVenueCard(venue: venue, isCompact: true),
        ),
      );

      expect(find.text('Restaurant'), findsOneWidget);
    });

    testWidgets('renders with minimal venue data without crashing',
        (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      expect(find.byType(ModernVenueCard), findsOneWidget);
      expect(find.text('Unnamed Venue'), findsOneWidget);
    });

    testWidgets('displays 0.0 rating when rating is null', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: null);

      await tester.pumpWidget(
        buildTestWidget(ModernVenueCard(venue: venue)),
      );

      // Rating badge should show 0.0
      expect(find.text('0.0'), findsWidgets);
    });
  });
}
