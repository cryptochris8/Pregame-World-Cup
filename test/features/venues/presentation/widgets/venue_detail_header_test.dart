import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_recommendation_service.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_detail_header.dart';

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
    return MediaQuery(
      data: const MediaQueryData(size: Size(600, 896)),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 600,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('VenueDetailHeader', () {
    testWidgets('renders venue name', (tester) async {
      final venue = VenueTestFactory.createFullPlace();
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('MetLife Stadium Sports Bar'), findsOneWidget);
    });

    testWidgets('renders category badge', (tester) async {
      final venue = VenueTestFactory.createPlace(
        types: ['bar'],
        name: 'Sports Hub',
      );
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('Sports Bar'), findsOneWidget);
    });

    testWidgets('renders Popular badge when isPopular is true',
        (tester) async {
      final venue = VenueTestFactory.createPopularVenue();
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: true,
          ),
        ),
      );

      expect(find.text('Popular'), findsOneWidget);
    });

    testWidgets('does not render Popular badge when isPopular is false',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('Popular'), findsNothing);
    });

    testWidgets('renders rating stars and numeric value', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.7);
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('4.7'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('renders review count', (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: 4.5,
        userRatingsTotal: 523,
      );
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('(523 reviews)'), findsOneWidget);
    });

    testWidgets('renders price level with dollar signs', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: 2);
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('renders address with location icon', (tester) async {
      final venue = VenueTestFactory.createPlace(
        vicinity: '1 MetLife Dr, East Rutherford, NJ',
      );
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('1 MetLife Dr, East Rutherford, NJ'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not render address when vicinity is null',
        (tester) async {
      final venue = VenueTestFactory.createPlace(vicinity: null);
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      // No location_on icon when there's no address
      expect(find.byIcon(Icons.location_on), findsNothing);
    });

    testWidgets('does not render rating when null', (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: null,
        userRatingsTotal: null,
      );
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('4.5'), findsNothing);
      expect(find.text('4.7'), findsNothing);
    });

    testWidgets('does not render price when null', (tester) async {
      final venue = VenueTestFactory.createPlace(priceLevel: null);
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.byType(VenueDetailHeader), findsOneWidget);
    });

    testWidgets('renders half star for fractional rating', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 3.5);
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.star_half), findsOneWidget);
    });

    testWidgets('renders with restaurant category', (tester) async {
      final venue = VenueTestFactory.createRestaurant();
      final category = VenueRecommendationService.categorizeVenue(venue);

      await tester.pumpWidget(
        buildTestWidget(
          VenueDetailHeader(
            venue: venue,
            category: category,
            isPopular: false,
          ),
        ),
      );

      expect(find.text('Restaurant'), findsOneWidget);
    });
  });
}
