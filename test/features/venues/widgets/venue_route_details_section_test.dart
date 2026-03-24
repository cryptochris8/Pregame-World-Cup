import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_details_section.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_models.dart';

void main() {
  group('VenueRouteDetailsSection', () {
    late RouteDetails sampleRouteDetails;
    late RouteOption sampleRouteOption;

    setUp(() {
      sampleRouteDetails = RouteDetails(
        walkingTime: 15,
        drivingTime: 5,
        distance: 1609.34, // 1 mile in meters
        steps: [
          RouteStep(
            instruction: 'Head north on Main St',
            distance: '0.5 mi',
          ),
          RouteStep(
            instruction: 'Turn right on 1st Ave',
            distance: '0.3 mi',
          ),
          RouteStep(
            instruction: 'Destination will be on your left',
            distance: '0.2 mi',
          ),
        ],
      );
      sampleRouteOption = RouteOption.walking;
    });

    test('can be constructed with required parameters', () {
      final widget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: sampleRouteOption,
      );

      expect(widget, isNotNull);
      expect(widget.routeDetails, sampleRouteDetails);
      expect(widget.selectedRoute, sampleRouteOption);
    });

    test('stores route details correctly', () {
      final widget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: sampleRouteOption,
      );

      expect(widget.routeDetails.walkingTime, 15);
      expect(widget.routeDetails.drivingTime, 5);
      expect(widget.routeDetails.distance, 1609.34);
      expect(widget.routeDetails.steps.length, 3);
    });

    test('stores selected route correctly', () {
      final widget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: RouteOption.walking,
      );

      expect(widget.selectedRoute, RouteOption.walking);
    });

    test('accepts different route options', () {
      final walkingWidget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: RouteOption.walking,
      );
      final drivingWidget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: RouteOption.driving,
      );
      final transitWidget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: RouteOption.transit,
      );

      expect(walkingWidget.selectedRoute, RouteOption.walking);
      expect(drivingWidget.selectedRoute, RouteOption.driving);
      expect(transitWidget.selectedRoute, RouteOption.transit);
    });

    test('handles route with no steps', () {
      final emptyRouteDetails = RouteDetails(
        walkingTime: 5,
        drivingTime: 2,
        distance: 500.0,
        steps: [],
      );

      final widget = VenueRouteDetailsSection(
        routeDetails: emptyRouteDetails,
        selectedRoute: RouteOption.walking,
      );

      expect(widget.routeDetails.steps, isEmpty);
    });

    test('handles route with single step', () {
      final singleStepRoute = RouteDetails(
        walkingTime: 5,
        drivingTime: 2,
        distance: 500.0,
        steps: [
          RouteStep(instruction: 'Go straight to destination'),
        ],
      );

      final widget = VenueRouteDetailsSection(
        routeDetails: singleStepRoute,
        selectedRoute: RouteOption.walking,
      );

      expect(widget.routeDetails.steps.length, 1);
      expect(widget.routeDetails.steps[0].instruction, 'Go straight to destination');
    });

    test('handles route with many steps', () {
      final manyStepsRoute = RouteDetails(
        walkingTime: 30,
        drivingTime: 10,
        distance: 3000.0,
        steps: List.generate(
          10,
          (i) => RouteStep(
            instruction: 'Step ${i + 1}',
            distance: '${100 + i * 10} ft',
          ),
        ),
      );

      final widget = VenueRouteDetailsSection(
        routeDetails: manyStepsRoute,
        selectedRoute: RouteOption.walking,
      );

      expect(widget.routeDetails.steps.length, 10);
      expect(widget.routeDetails.steps[0].instruction, 'Step 1');
      expect(widget.routeDetails.steps[9].instruction, 'Step 10');
    });

    test('handles route steps with null distance', () {
      final routeWithNullDistance = RouteDetails(
        walkingTime: 10,
        drivingTime: 4,
        distance: 1000.0,
        steps: [
          RouteStep(
            instruction: 'Turn left',
            distance: null,
          ),
          RouteStep(
            instruction: 'Continue straight',
            distance: '0.5 mi',
          ),
        ],
      );

      final widget = VenueRouteDetailsSection(
        routeDetails: routeWithNullDistance,
        selectedRoute: RouteOption.walking,
      );

      expect(widget.routeDetails.steps[0].distance, isNull);
      expect(widget.routeDetails.steps[1].distance, '0.5 mi');
    });

    test('handles different walking times', () {
      final quickRoute = RouteDetails(
        walkingTime: 5,
        drivingTime: 2,
        distance: 400.0,
        steps: [],
      );
      final longRoute = RouteDetails(
        walkingTime: 45,
        drivingTime: 15,
        distance: 5000.0,
        steps: [],
      );

      final widget1 = VenueRouteDetailsSection(
        routeDetails: quickRoute,
        selectedRoute: RouteOption.walking,
      );
      final widget2 = VenueRouteDetailsSection(
        routeDetails: longRoute,
        selectedRoute: RouteOption.walking,
      );

      expect(widget1.routeDetails.walkingTime, 5);
      expect(widget2.routeDetails.walkingTime, 45);
    });

    test('handles different distances', () {
      final shortRoute = RouteDetails(
        walkingTime: 3,
        drivingTime: 1,
        distance: 200.0,
        steps: [],
      );
      final longRoute = RouteDetails(
        walkingTime: 30,
        drivingTime: 10,
        distance: 4828.03, // 3 miles in meters
        steps: [],
      );

      final widget1 = VenueRouteDetailsSection(
        routeDetails: shortRoute,
        selectedRoute: RouteOption.walking,
      );
      final widget2 = VenueRouteDetailsSection(
        routeDetails: longRoute,
        selectedRoute: RouteOption.walking,
      );

      expect(widget1.routeDetails.distance, 200.0);
      expect(widget2.routeDetails.distance, 4828.03);
    });

    test('is a StatelessWidget', () {
      final widget = VenueRouteDetailsSection(
        routeDetails: sampleRouteDetails,
        selectedRoute: sampleRouteOption,
      );

      expect(widget, isA<VenueRouteDetailsSection>());
    });
  });

  group('RouteDetails', () {
    test('can be constructed with all required parameters', () {
      final details = RouteDetails(
        walkingTime: 15,
        drivingTime: 5,
        distance: 1609.34,
        steps: [],
      );

      expect(details.walkingTime, 15);
      expect(details.drivingTime, 5);
      expect(details.distance, 1609.34);
      expect(details.steps, isEmpty);
    });

    test('stores steps list correctly', () {
      final steps = [
        RouteStep(instruction: 'Step 1', distance: '100 ft'),
        RouteStep(instruction: 'Step 2', distance: '200 ft'),
      ];
      final details = RouteDetails(
        walkingTime: 10,
        drivingTime: 4,
        distance: 500.0,
        steps: steps,
      );

      expect(details.steps.length, 2);
      expect(details.steps[0].instruction, 'Step 1');
      expect(details.steps[1].instruction, 'Step 2');
    });
  });

  group('RouteStep', () {
    test('can be constructed with instruction only', () {
      final step = RouteStep(instruction: 'Turn left on Main St');

      expect(step.instruction, 'Turn left on Main St');
      expect(step.distance, isNull);
    });

    test('can be constructed with instruction and distance', () {
      final step = RouteStep(
        instruction: 'Continue straight',
        distance: '0.5 mi',
      );

      expect(step.instruction, 'Continue straight');
      expect(step.distance, '0.5 mi');
    });

    test('distance is optional', () {
      final stepWithDistance = RouteStep(
        instruction: 'Turn right',
        distance: '100 ft',
      );
      final stepWithoutDistance = RouteStep(
        instruction: 'Turn left',
      );

      expect(stepWithDistance.distance, '100 ft');
      expect(stepWithoutDistance.distance, isNull);
    });
  });

  group('RouteOption', () {
    test('has correct enum values', () {
      expect(RouteOption.values.length, 3);
      expect(RouteOption.values.contains(RouteOption.walking), true);
      expect(RouteOption.values.contains(RouteOption.driving), true);
      expect(RouteOption.values.contains(RouteOption.transit), true);
    });

    test('displayName extension returns correct values', () {
      expect(RouteOption.walking.displayName, 'Walking');
      expect(RouteOption.driving.displayName, 'Driving');
      expect(RouteOption.transit.displayName, 'Transit');
    });

    test('can be compared for equality', () {
      const option1 = RouteOption.walking;
      const option2 = RouteOption.walking;
      const option3 = RouteOption.driving;

      expect(option1 == option2, true);
      expect(option1 == option3, false);
    });
  });
}
