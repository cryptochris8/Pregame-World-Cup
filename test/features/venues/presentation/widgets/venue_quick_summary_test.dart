import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_quick_summary.dart';

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

  group('VenueQuickSummary', () {
    testWidgets('renders venue name', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Quick Pub');

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.text('Quick Pub'), findsOneWidget);
    });

    testWidgets('renders rating and star icon when rating is provided',
        (tester) async {
      final venue = VenueTestFactory.createPlace(rating: 4.3);

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.text('4.3'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('does not render rating when null', (tester) async {
      final venue = VenueTestFactory.createPlace(rating: null);

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.text('4.3'), findsNothing);
      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('renders category display name', (tester) async {
      final venue = VenueTestFactory.createRestaurant();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.text('Restaurant'), findsOneWidget);
    });

    testWidgets('renders action buttons (phone, directions, info)',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.directions), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders category icon in avatar', (tester) async {
      final venue = VenueTestFactory.createCafe();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      // Cafe icon
      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    });

    testWidgets('renders with minimal venue data without crashing',
        (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickSummary(venue: venue)),
      );

      expect(find.text('Unnamed Venue'), findsOneWidget);
      expect(find.byType(VenueQuickSummary), findsOneWidget);
    });
  });
}
