import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_map_info_card.dart';

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

  // ===========================================================================
  // VenueMapInfoCard tests
  // ===========================================================================

  group('VenueMapInfoCard', () {
    testWidgets('renders venue name', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Stadium Bar');

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.text('Stadium Bar'), findsOneWidget);
    });

    testWidgets('renders rating and review count', (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: 4.3,
        userRatingsTotal: 185,
      );

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.text('4.3'), findsOneWidget);
      expect(find.text('(185)'), findsOneWidget);
    });

    testWidgets('renders price level', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: 2);

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      // Price level displays dollar signs
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('renders venue address', (tester) async {
      final venue = VenueTestFactory.createPlace(
        vicinity: '789 Elm St, New York, NY',
      );

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.text('789 Elm St, New York, NY'), findsOneWidget);
    });

    testWidgets('renders three action buttons', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button triggers onClose callback', (tester) async {
      var closePressed = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () => closePressed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closePressed, isTrue);
    });

    testWidgets('details button triggers onDetailsPressed callback',
        (tester) async {
      var detailsPressed = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () => detailsPressed = true,
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      await tester.tap(find.text('Details'));
      expect(detailsPressed, isTrue);
    });

    testWidgets('directions button triggers onDirectionsPressed callback',
        (tester) async {
      var directionsPressed = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () => directionsPressed = true,
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      await tester.tap(find.text('Directions'));
      expect(directionsPressed, isTrue);
    });

    testWidgets('call button triggers onCallPressed callback',
        (tester) async {
      var callPressed = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () => callPressed = true,
            onClose: () {},
          ),
        ),
      );

      await tester.tap(find.text('Call'));
      expect(callPressed, isTrue);
    });

    testWidgets('renders category badge', (tester) async {
      final venue = VenueTestFactory.createPlace(
        types: ['bar'],
        name: 'Sports Pub',
      );

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      // Sports bar category display name
      expect(find.text('Sports Bar'), findsOneWidget);
    });

    testWidgets('renders correctly with minimal data', (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      expect(find.text('Unnamed Venue'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('hides address when vicinity is null', (tester) async {
      final venue = VenueTestFactory.createPlace(vicinity: null);

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoCard(
            venue: venue,
            onDetailsPressed: () {},
            onDirectionsPressed: () {},
            onCallPressed: () {},
            onClose: () {},
          ),
        ),
      );

      // No location_on icon for address row when vicinity is null
      expect(find.text('123 Main St, Dallas, TX'), findsNothing);
    });
  });

  // ===========================================================================
  // VenueMapInfoChip tests
  // ===========================================================================

  group('VenueMapInfoChip', () {
    testWidgets('renders venue name', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Chip Pub');

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(venue: venue),
        ),
      );

      expect(find.text('Chip Pub'), findsOneWidget);
    });

    testWidgets('renders rating when available', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.2);

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(venue: venue),
        ),
      );

      expect(find.text('4.2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('does not show rating when null', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: null);

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(venue: venue),
        ),
      );

      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('shows close button when onClose is provided', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(
            venue: venue,
            onClose: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show close button when onClose is null',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(venue: venue),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      var tapped = false;
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueMapInfoChip(
            venue: venue,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(VenueMapInfoChip));
      expect(tapped, isTrue);
    });
  });
}
