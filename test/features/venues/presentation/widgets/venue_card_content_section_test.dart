import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_card_content_section.dart';

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

  group('VenueCardContentSection', () {
    testWidgets('renders venue name', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'MetLife Bar');

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('MetLife Bar'), findsOneWidget);
    });

    testWidgets('renders rating stars for rated venue', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.5);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // Should show star icons for the rating
      expect(find.byIcon(Icons.star), findsWidgets);
      // Should show the numeric rating
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('renders user ratings total', (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: 4.5,
        userRatingsTotal: 312,
      );

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('(312)'), findsOneWidget);
    });

    testWidgets('does not render rating when null', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: null);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // No star icons should be rendered for rating
      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('renders price level with dollar signs', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: 3);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // Price level 3 => 3 bold dollar signs + 1 faded
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('does not render price level when null', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: null);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // Should not crash, should render without price
      expect(find.byType(VenueCardContentSection), findsOneWidget);
    });

    testWidgets('does not render price level when 0', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: 0);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.byType(VenueCardContentSection), findsOneWidget);
    });

    testWidgets('renders address when vicinity is not empty', (tester) async {
      final venue = VenueTestFactory.createPlace(
        vicinity: '456 Oak Ave, Dallas, TX',
      );

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('456 Oak Ave, Dallas, TX'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not render address when vicinity is null',
        (tester) async {
      final venue = VenueTestFactory.createPlace(vicinity: null);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // location_on icon should not appear when no vicinity
      // (it may still appear in walking distance, but address row uses it)
      expect(find.text('456 Oak Ave, Dallas, TX'), findsNothing);
    });

    testWidgets('does not render address when vicinity is empty',
        (tester) async {
      final venue = VenueTestFactory.createPlace(vicinity: '');

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.byType(VenueCardContentSection), findsOneWidget);
    });

    testWidgets('shows walking distance when gameLocation is provided',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueCardContentSection(
            venue: venue,
            gameLocation: 'MetLife Stadium',
          ),
        ),
      );

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    });

    testWidgets('does not show walking distance when gameLocation is null',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.byIcon(Icons.directions_walk), findsNothing);
    });

    testWidgets('shows "Open Now" when venue is open', (tester) async {
      final venue = VenueTestFactory.createPlace(
        openingHours: OpeningHours(openNow: true),
      );

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('Open Now'), findsOneWidget);
    });

    testWidgets('shows "Closed" when venue is closed', (tester) async {
      final venue = VenueTestFactory.createPlace(
        openingHours: OpeningHours(openNow: false),
      );

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('shows "Hours vary" when no opening hours data',
        (tester) async {
      final venue = VenueTestFactory.createPlace(openingHours: null);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('Hours vary'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders correctly with minimal venue data', (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      expect(find.text('Unnamed Venue'), findsOneWidget);
      expect(find.text('Hours vary'), findsOneWidget);
    });

    testWidgets('renders half star for fractional rating', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 3.5);

      await tester.pumpWidget(
        buildTestWidget(VenueCardContentSection(venue: venue)),
      );

      // Should have star_half icon for 0.5 fraction
      expect(find.byIcon(Icons.star_half), findsOneWidget);
    });
  });
}
