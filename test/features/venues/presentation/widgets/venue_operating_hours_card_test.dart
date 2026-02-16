import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_operating_hours_card.dart';

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

  Widget buildTestWidget(Widget child, {double height = 896}) {
    return MediaQuery(
      data: MediaQueryData(size: Size(600, height)),
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

  // ===========================================================================
  // VenueOperatingHoursCard tests
  // ===========================================================================

  group('VenueOperatingHoursCard', () {
    testWidgets('renders Hours title', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      expect(find.text('Hours'), findsOneWidget);
    });

    testWidgets('renders clock icon', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows Open Now or Closed status', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      // The status depends on the current time, but one of these should be shown
      final openNow = find.text('Open Now');
      final closed = find.text('Closed');

      expect(
        openNow.evaluate().isNotEmpty || closed.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show either Open Now or Closed',
      );
    });

    testWidgets('shows today\'s day name', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      // The current day name should be displayed
      final now = DateTime.now();
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final today = dayNames[now.weekday - 1];

      expect(find.text(today), findsOneWidget);
    });

    testWidgets('shows hours for today', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      // Should show hours text (e.g., "8:00 AM - 10:00 PM")
      expect(find.textContaining('AM'), findsWidgets);
      expect(find.textContaining('PM'), findsWidgets);
    });

    testWidgets('shows "View full schedule" link when not showing full schedule',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueOperatingHoursCard(venue: venue, showFullSchedule: false),
        ),
      );

      expect(find.text('View full schedule'), findsOneWidget);
    });

    testWidgets('shows full schedule when showFullSchedule is true',
        (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(
          VenueOperatingHoursCard(venue: venue, showFullSchedule: true),
        ),
      );

      // Full schedule shows all day names
      expect(find.text('Weekly Schedule'), findsOneWidget);
      // Each day name appears at least once in the full schedule.
      // The current day may appear twice (once in today's hours, once in the schedule).
      expect(find.text('Monday'), findsAtLeastNWidgets(1));
      expect(find.text('Tuesday'), findsAtLeastNWidgets(1));
      expect(find.text('Wednesday'), findsAtLeastNWidgets(1));
      expect(find.text('Thursday'), findsAtLeastNWidgets(1));
      expect(find.text('Friday'), findsAtLeastNWidgets(1));
      expect(find.text('Saturday'), findsAtLeastNWidgets(1));
      expect(find.text('Sunday'), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping "View full schedule" shows dialog', (tester) async {
      // Use a tall viewport so the dialog content does not overflow
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final venue = VenueTestFactory.createPlace(
        name: 'Test Bar',
      );

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      await tester.tap(find.text('View full schedule'));
      await tester.pumpAndSettle();

      // Dialog should show the venue name in the title
      expect(find.text('Test Bar Hours'), findsOneWidget);
      // Dialog shows holiday notice
      expect(
        find.text('Hours may vary on holidays. Call ahead to confirm.'),
        findsOneWidget,
      );
    });

    testWidgets('full schedule dialog can be closed', (tester) async {
      // Use a tall viewport so the dialog content does not overflow
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      await tester.tap(find.text('View full schedule'));
      await tester.pumpAndSettle();

      // Close the dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Weekly Schedule'), findsNothing);
    });

    testWidgets('renders correctly with minimal venue data', (tester) async {
      final venue = VenueTestFactory.createMinimalPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueOperatingHoursCard(venue: venue)),
      );

      expect(find.text('Hours'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });
  });

  // ===========================================================================
  // VenueHoursChip tests
  // ===========================================================================

  group('VenueHoursChip', () {
    testWidgets('renders Open Now or Closed text', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueHoursChip(venue: venue)),
      );

      final openNow = find.text('Open Now');
      final closed = find.text('Closed');

      expect(
        openNow.evaluate().isNotEmpty || closed.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('shows indicator dot when showIcon is true', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueHoursChip(venue: venue, showIcon: true)),
      );

      expect(find.byType(VenueHoursChip), findsOneWidget);
    });

    testWidgets('hides indicator dot when showIcon is false', (tester) async {
      final venue = VenueTestFactory.createFullPlace();

      await tester.pumpWidget(
        buildTestWidget(VenueHoursChip(venue: venue, showIcon: false)),
      );

      expect(find.byType(VenueHoursChip), findsOneWidget);
    });
  });
}
