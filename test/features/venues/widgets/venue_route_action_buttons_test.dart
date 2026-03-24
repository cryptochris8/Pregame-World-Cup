import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_action_buttons.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
          );
      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  group('VenueRouteActionButtons', () {
    testWidgets('renders with walking route option', (tester) async {
      var startNavigationCalled = false;
      var shareCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteActionButtons(
              selectedRoute: RouteOption.walking,
              onStartNavigation: () {
                startNavigationCalled = true;
              },
              onShare: () {
                shareCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(VenueRouteActionButtons), findsOneWidget);
      expect(find.text('Start Walking'), findsOneWidget);
      expect(find.byIcon(Icons.navigation), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(startNavigationCalled, isFalse);
      expect(shareCalled, isFalse);
    });

    testWidgets('renders with driving route option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteActionButtons(
              selectedRoute: RouteOption.driving,
              onStartNavigation: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.text('Start Driving'), findsOneWidget);
    });

    testWidgets('renders with transit route option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteActionButtons(
              selectedRoute: RouteOption.transit,
              onStartNavigation: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.text('Start Transit'), findsOneWidget);
    });

    testWidgets('start navigation button is tappable', (tester) async {
      var startNavigationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteActionButtons(
              selectedRoute: RouteOption.walking,
              onStartNavigation: () {
                startNavigationCalled = true;
              },
              onShare: () {},
            ),
          ),
        ),
      );

      expect(startNavigationCalled, isFalse);

      await tester.tap(find.text('Start Walking'));
      await tester.pump();

      expect(startNavigationCalled, isTrue);
    });

    testWidgets('share button is tappable', (tester) async {
      var shareCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteActionButtons(
              selectedRoute: RouteOption.walking,
              onStartNavigation: () {},
              onShare: () {
                shareCalled = true;
              },
            ),
          ),
        ),
      );

      expect(shareCalled, isFalse);

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      expect(shareCalled, isTrue);
    });

    test('can be constructed with required parameters', () {
      final widget = VenueRouteActionButtons(
        selectedRoute: RouteOption.walking,
        onStartNavigation: () {},
        onShare: () {},
      );

      expect(widget, isA<VenueRouteActionButtons>());
      expect(widget.selectedRoute, equals(RouteOption.walking));
    });

    test('is a StatelessWidget', () {
      final widget = VenueRouteActionButtons(
        selectedRoute: RouteOption.driving,
        onStartNavigation: () {},
        onShare: () {},
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('all RouteOption values are valid', () {
      for (final route in RouteOption.values) {
        final widget = VenueRouteActionButtons(
          selectedRoute: route,
          onStartNavigation: () {},
          onShare: () {},
        );

        expect(widget.selectedRoute, equals(route));
      }
    });
  });
}
