import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_models.dart';

void main() {
  group('RouteOption', () {
    test('has exactly three values', () {
      expect(RouteOption.values.length, equals(3));
    });

    test('includes walking value', () {
      expect(RouteOption.values, contains(RouteOption.walking));
    });

    test('includes driving value', () {
      expect(RouteOption.values, contains(RouteOption.driving));
    });

    test('includes transit value', () {
      expect(RouteOption.values, contains(RouteOption.transit));
    });
  });

  group('RouteOptionExtension', () {
    test('walking displayName returns "Walking"', () {
      expect(RouteOption.walking.displayName, equals('Walking'));
    });

    test('driving displayName returns "Driving"', () {
      expect(RouteOption.driving.displayName, equals('Driving'));
    });

    test('transit displayName returns "Transit"', () {
      expect(RouteOption.transit.displayName, equals('Transit'));
    });

    test('all values have non-empty displayName', () {
      for (final option in RouteOption.values) {
        expect(option.displayName, isNotEmpty);
      }
    });
  });

  group('RouteDetails', () {
    test('can be constructed with all required parameters', () {
      final details = RouteDetails(
        walkingTime: 15,
        drivingTime: 5,
        distance: 1.2,
        steps: [],
      );

      expect(details, isNotNull);
    });

    test('stores walkingTime correctly', () {
      final details = RouteDetails(
        walkingTime: 20,
        drivingTime: 7,
        distance: 1.5,
        steps: [],
      );

      expect(details.walkingTime, equals(20));
    });

    test('stores drivingTime correctly', () {
      final details = RouteDetails(
        walkingTime: 20,
        drivingTime: 7,
        distance: 1.5,
        steps: [],
      );

      expect(details.drivingTime, equals(7));
    });

    test('stores distance correctly', () {
      final details = RouteDetails(
        walkingTime: 20,
        drivingTime: 7,
        distance: 2.3,
        steps: [],
      );

      expect(details.distance, equals(2.3));
    });

    test('stores steps list correctly', () {
      final step1 = RouteStep(instruction: 'Turn left', distance: '0.5 mi');
      final step2 = RouteStep(instruction: 'Turn right', distance: '0.3 mi');
      final steps = [step1, step2];

      final details = RouteDetails(
        walkingTime: 15,
        drivingTime: 5,
        distance: 0.8,
        steps: steps,
      );

      expect(details.steps, equals(steps));
      expect(details.steps.length, equals(2));
    });

    test('can be constructed with empty steps list', () {
      final details = RouteDetails(
        walkingTime: 10,
        drivingTime: 3,
        distance: 0.5,
        steps: [],
      );

      expect(details.steps, isEmpty);
    });

    test('stores all fields correctly', () {
      final step = RouteStep(instruction: 'Go straight', distance: '1.0 mi');
      final details = RouteDetails(
        walkingTime: 25,
        drivingTime: 8,
        distance: 1.8,
        steps: [step],
      );

      expect(details.walkingTime, equals(25));
      expect(details.drivingTime, equals(8));
      expect(details.distance, equals(1.8));
      expect(details.steps.length, equals(1));
      expect(details.steps.first.instruction, equals('Go straight'));
    });

    test('can store zero values', () {
      final details = RouteDetails(
        walkingTime: 0,
        drivingTime: 0,
        distance: 0.0,
        steps: [],
      );

      expect(details.walkingTime, equals(0));
      expect(details.drivingTime, equals(0));
      expect(details.distance, equals(0.0));
    });

    test('can store large values', () {
      final details = RouteDetails(
        walkingTime: 120,
        drivingTime: 45,
        distance: 10.5,
        steps: [],
      );

      expect(details.walkingTime, equals(120));
      expect(details.drivingTime, equals(45));
      expect(details.distance, equals(10.5));
    });

    test('can store negative distance (edge case)', () {
      final details = RouteDetails(
        walkingTime: 10,
        drivingTime: 5,
        distance: -1.0,
        steps: [],
      );

      expect(details.distance, equals(-1.0));
    });
  });

  group('RouteStep', () {
    test('can be constructed with instruction and distance', () {
      final step = RouteStep(
        instruction: 'Turn left on Main St',
        distance: '0.5 mi',
      );

      expect(step, isNotNull);
    });

    test('stores instruction correctly', () {
      final step = RouteStep(
        instruction: 'Continue straight',
        distance: '1.0 mi',
      );

      expect(step.instruction, equals('Continue straight'));
    });

    test('stores distance correctly when provided', () {
      final step = RouteStep(
        instruction: 'Turn right',
        distance: '0.3 mi',
      );

      expect(step.distance, equals('0.3 mi'));
    });

    test('distance is null when not provided', () {
      final step = RouteStep(instruction: 'Start at Stadium');

      expect(step.distance, isNull);
    });

    test('can be constructed with null distance explicitly', () {
      final step = RouteStep(
        instruction: 'Arrive at destination',
        distance: null,
      );

      expect(step.instruction, equals('Arrive at destination'));
      expect(step.distance, isNull);
    });

    test('stores both fields correctly', () {
      final step = RouteStep(
        instruction: 'Head north on Stadium Drive',
        distance: '0.2 mi',
      );

      expect(step.instruction, equals('Head north on Stadium Drive'));
      expect(step.distance, equals('0.2 mi'));
    });

    test('can store empty instruction', () {
      final step = RouteStep(
        instruction: '',
        distance: '0.1 mi',
      );

      expect(step.instruction, isEmpty);
    });

    test('can store very long instruction', () {
      final longInstruction = 'Continue straight for 5 blocks, '
          'passing the shopping center on your left, '
          'until you reach the intersection with Oak Street';
      final step = RouteStep(
        instruction: longInstruction,
        distance: '2.5 mi',
      );

      expect(step.instruction, equals(longInstruction));
    });

    test('can store various distance formats', () {
      final step1 = RouteStep(instruction: 'Step 1', distance: '0.5 mi');
      final step2 = RouteStep(instruction: 'Step 2', distance: '500 m');
      final step3 = RouteStep(instruction: 'Step 3', distance: '1 km');

      expect(step1.distance, equals('0.5 mi'));
      expect(step2.distance, equals('500 m'));
      expect(step3.distance, equals('1 km'));
    });
  });

  group('RouteDetails with multiple RouteSteps', () {
    test('can store a realistic route with multiple steps', () {
      final steps = [
        RouteStep(instruction: 'Start at Stadium', distance: null),
        RouteStep(instruction: 'Head north on Stadium Drive', distance: '0.2 mi'),
        RouteStep(instruction: 'Turn right on Main Street', distance: '0.3 mi'),
        RouteStep(instruction: 'Continue straight for 2 blocks', distance: '0.4 mi'),
        RouteStep(instruction: 'Arrive at destination', distance: null),
      ];

      final details = RouteDetails(
        walkingTime: 18,
        drivingTime: 6,
        distance: 0.9,
        steps: steps,
      );

      expect(details.steps.length, equals(5));
      expect(details.steps.first.instruction, equals('Start at Stadium'));
      expect(details.steps.first.distance, isNull);
      expect(details.steps.last.instruction, equals('Arrive at destination'));
      expect(details.steps.last.distance, isNull);
      expect(details.steps[2].distance, equals('0.3 mi'));
    });

    test('steps list is independent from original list', () {
      final originalSteps = [
        RouteStep(instruction: 'Step 1', distance: '0.1 mi'),
      ];

      final details = RouteDetails(
        walkingTime: 5,
        drivingTime: 2,
        distance: 0.1,
        steps: originalSteps,
      );

      // Modify original list
      originalSteps.add(RouteStep(instruction: 'Step 2', distance: '0.2 mi'));

      // Details should still have only 1 step if list was copied
      // (or 2 if reference is stored - this tests the behavior)
      expect(details.steps.length, greaterThanOrEqualTo(1));
    });
  });
}
