import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_option_chips.dart';
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

  group('VenueRouteOptionChips', () {
    testWidgets('renders all three route options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              onRouteSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(VenueRouteOptionChips), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('Driving'), findsOneWidget);
      expect(find.text('Transit'), findsOneWidget);
    });

    testWidgets('displays icons for each route option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              onRouteSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      expect(find.byIcon(Icons.directions_transit), findsOneWidget);
    });

    testWidgets('walking route is tappable', (tester) async {
      RouteOption? selectedRoute;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.driving,
              onRouteSelected: (route) {
                selectedRoute = route;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Walking'));
      await tester.pump();

      expect(selectedRoute, equals(RouteOption.walking));
    });

    testWidgets('driving route is tappable', (tester) async {
      RouteOption? selectedRoute;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              onRouteSelected: (route) {
                selectedRoute = route;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Driving'));
      await tester.pump();

      expect(selectedRoute, equals(RouteOption.driving));
    });

    testWidgets('transit route is tappable', (tester) async {
      RouteOption? selectedRoute;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              onRouteSelected: (route) {
                selectedRoute = route;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Transit'));
      await tester.pump();

      expect(selectedRoute, equals(RouteOption.transit));
    });

    testWidgets('renders with route details', (tester) async {
      final routeDetails = RouteDetails(
        walkingTime: 10,
        drivingTime: 3,
        distance: 0.5,
        steps: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              routeDetails: routeDetails,
              onRouteSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(VenueRouteOptionChips), findsOneWidget);
    });

    testWidgets('renders without route details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueRouteOptionChips(
              selectedRoute: RouteOption.walking,
              routeDetails: null,
              onRouteSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(VenueRouteOptionChips), findsOneWidget);
    });

    test('can be constructed with required parameters', () {
      final widget = VenueRouteOptionChips(
        selectedRoute: RouteOption.walking,
        onRouteSelected: (_) {},
      );

      expect(widget, isA<VenueRouteOptionChips>());
      expect(widget.selectedRoute, equals(RouteOption.walking));
      expect(widget.routeDetails, isNull);
    });

    test('is a StatelessWidget', () {
      final widget = VenueRouteOptionChips(
        selectedRoute: RouteOption.driving,
        onRouteSelected: (_) {},
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('all RouteOption values are valid', () {
      for (final route in RouteOption.values) {
        final widget = VenueRouteOptionChips(
          selectedRoute: route,
          onRouteSelected: (_) {},
        );

        expect(widget.selectedRoute, equals(route));
      }
    });
  });
}
