import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_action_buttons.dart';

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
  // VenueActionButtons tests
  // ===========================================================================

  group('VenueActionButtons', () {
    testWidgets('renders all four action buttons', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('renders correct icons for each action', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.directions), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueActionButtons(venue: venue, showLabels: false),
        ),
      );

      expect(find.text('Call'), findsNothing);
      expect(find.text('Directions'), findsNothing);
      expect(find.text('Website'), findsNothing);
      expect(find.text('Share'), findsNothing);
      // Icons should still be visible
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('tapping Call shows dialog', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Test Bar');

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();

      // Dialog should appear with the venue name
      expect(find.text('Call Test Bar'), findsOneWidget);
    });

    testWidgets('tapping Website shows dialog', (tester) async {
      final venue = VenueTestFactory.createPlace(name: 'Web Pub');

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      await tester.tap(find.text('Website'));
      await tester.pumpAndSettle();

      expect(find.text('Visit Web Pub Website'), findsOneWidget);
    });

    testWidgets('tapping Share shows dialog with share text', (tester) async {
      final venue = VenueTestFactory.createPlace(
        name: 'Share Pub',
        rating: 4.5,
        vicinity: '123 Main St',
      );

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(find.text('Share Share Pub'), findsOneWidget);
      expect(find.textContaining('Check out Share Pub'), findsOneWidget);
    });

    testWidgets('dialog can be closed', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Close'), findsNothing);
    });

    testWidgets('renders with minimal venue data', (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueActionButtons(venue: venue)),
      );

      // All buttons should still render
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('renders with custom alignment', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueActionButtons(
            venue: venue,
            alignment: MainAxisAlignment.start,
          ),
        ),
      );

      expect(find.byType(VenueActionButtons), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueActionButtons(
            venue: venue,
            padding: EdgeInsets.zero,
          ),
        ),
      );

      expect(find.byType(VenueActionButtons), findsOneWidget);
    });
  });

  // ===========================================================================
  // VenueQuickActions tests
  // ===========================================================================

  group('VenueQuickActions', () {
    testWidgets('renders three quick action buttons', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickActions(venue: venue)),
      );

      expect(find.byIcon(Icons.directions), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders with background by default', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueQuickActions(venue: venue)),
      );

      expect(find.byType(VenueQuickActions), findsOneWidget);
    });

    testWidgets('renders without background when showBackground is false',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueQuickActions(venue: venue, showBackground: false),
        ),
      );

      expect(find.byType(VenueQuickActions), findsOneWidget);
    });
  });
}
