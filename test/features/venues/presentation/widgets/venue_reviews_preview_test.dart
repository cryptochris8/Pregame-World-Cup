import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_reviews_preview.dart';

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
        body: SizedBox(
          width: 414,
          height: 896,
          child: child,
        ),
      ),
    );
  }

  // ===========================================================================
  // VenueReviewsPreview tests
  // ===========================================================================

  group('VenueReviewsPreview', () {
    testWidgets('renders Reviews & Ratings header', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('Reviews & Ratings'), findsOneWidget);
    });

    testWidgets('renders venue rating display', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.7);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('4.7'), findsOneWidget);
    });

    testWidgets('shows review count', (tester) async {
      final venue = VenueTestFactory.createPlace(userRatingsTotal: 523);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('523 reviews'), findsOneWidget);
    });

    testWidgets('shows default review count when userRatingsTotal is null',
        (tester) async {
      final venue = VenueTestFactory.createPlace(userRatingsTotal: null);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      // Defaults to 127 reviews when null
      expect(find.text('127 reviews'), findsOneWidget);
    });

    testWidgets('renders sample reviewer names', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('Sarah M.'), findsOneWidget);
      expect(find.text('Mike R.'), findsOneWidget);
      expect(find.text('Jessica L.'), findsOneWidget);
    });

    testWidgets('renders reviewer initials', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('SM'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('JL'), findsOneWidget);
    });

    testWidgets('renders review text content', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(
        find.textContaining('Amazing atmosphere'),
        findsOneWidget,
      );
    });

    testWidgets('renders review date', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('2 weeks ago'), findsOneWidget);
      expect(find.text('1 month ago'), findsOneWidget);
      expect(find.text('3 weeks ago'), findsOneWidget);
    });

    testWidgets('renders review highlights/tags', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('Great Food'), findsOneWidget);
      expect(find.text('Game Day Spot'), findsOneWidget);
      expect(find.text('Friendly Staff'), findsOneWidget);
    });

    testWidgets('renders helpful counts', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      expect(find.text('Helpful (12)'), findsOneWidget);
      expect(find.text('Helpful (8)'), findsOneWidget);
      expect(find.text('Helpful (15)'), findsOneWidget);
    });

    testWidgets('renders thumbs up icons', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      // Three reviews, each with a thumb_up icon
      expect(find.byIcon(Icons.thumb_up_outlined), findsNWidgets(3));
    });

    testWidgets('renders View All Reviews button', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      // Need to scroll to see the button
      await tester.scrollUntilVisible(
        find.text('View All Reviews'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('View All Reviews'), findsOneWidget);
    });

    testWidgets('renders star icons for rating breakdown', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsPreview(venue: venue)),
      );

      // Multiple star icons for rating breakdown and individual reviews
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });

  // ===========================================================================
  // VenueReviewsSummary tests
  // ===========================================================================

  group('VenueReviewsSummary', () {
    testWidgets('renders rating and stars when rating is provided',
        (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: 4.5,
        userRatingsTotal: 200,
      );

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsSummary(venue: venue)),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(200)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('returns SizedBox.shrink when rating is null',
        (tester) async {
      final venue = VenueTestFactory.createPlace(rating: null);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsSummary(venue: venue)),
      );

      // Should render an empty widget (SizedBox.shrink)
      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('hides review count when showReviewCount is false',
        (tester) async {
      final venue = VenueTestFactory.createPlace(
        rating: 4.5,
        userRatingsTotal: 200,
      );

      await tester.pumpWidget(
        buildTestWidget(
          VenueReviewsSummary(venue: venue, showReviewCount: false),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(200)'), findsNothing);
    });

    testWidgets('shows half star for fractional rating', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 3.5);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsSummary(venue: venue)),
      );

      expect(find.byIcon(Icons.star_half), findsOneWidget);
    });

    testWidgets('shows empty stars for unearned rating', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 2.0);

      await tester.pumpWidget(
        buildTestWidget(VenueReviewsSummary(venue: venue)),
      );

      expect(find.byIcon(Icons.star_border), findsWidgets);
    });
  });
}
