import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pregame_world_cup/core/services/route_service.dart';

void main() {
  group('RouteService', () {
    group('calculateWalkingTime', () {
      test('returns "< 1 min" for very short distances', () {
        expect(RouteService.calculateWalkingTime(0.01), '< 1 min');
      });

      test('returns "< 1 min" for zero distance', () {
        expect(RouteService.calculateWalkingTime(0.0), '< 1 min');
      });

      test('returns minutes for distances under 1 hour walk', () {
        // 1 km at 5 km/h = 12 min
        expect(RouteService.calculateWalkingTime(1.0), '12 min');
      });

      test('returns minutes for 2.5 km walk', () {
        // 2.5 km at 5 km/h = 30 min
        expect(RouteService.calculateWalkingTime(2.5), '30 min');
      });

      test('returns hours and minutes for longer distances', () {
        // 6 km at 5 km/h = 1.2 hours = 1h 12m
        expect(RouteService.calculateWalkingTime(6.0), '1h 12m');
      });

      test('returns hours only when minutes are zero', () {
        // 5 km at 5 km/h = 1.0 hours = 1h
        expect(RouteService.calculateWalkingTime(5.0), '1h');
      });

      test('returns hours and minutes for 10 km walk', () {
        // 10 km at 5 km/h = 2.0 hours = 2h
        expect(RouteService.calculateWalkingTime(10.0), '2h');
      });

      test('handles fractional distances correctly', () {
        // 0.5 km at 5 km/h = 0.1 hours = 6 min
        expect(RouteService.calculateWalkingTime(0.5), '6 min');
      });
    });

    group('getWalkingDifficulty', () {
      test('returns easy for short distance and short duration', () {
        expect(
          RouteService.getWalkingDifficulty(0.3, 4),
          WalkingDifficulty.easy,
        );
      });

      test('returns easy at boundary values (0.5 km, 6 min)', () {
        expect(
          RouteService.getWalkingDifficulty(0.5, 6),
          WalkingDifficulty.easy,
        );
      });

      test('returns moderate for medium distance', () {
        expect(
          RouteService.getWalkingDifficulty(0.8, 10),
          WalkingDifficulty.moderate,
        );
      });

      test('returns moderate at boundary values (1.0 km, 12 min)', () {
        expect(
          RouteService.getWalkingDifficulty(1.0, 12),
          WalkingDifficulty.moderate,
        );
      });

      test('returns challenging for longer distance', () {
        expect(
          RouteService.getWalkingDifficulty(1.5, 18),
          WalkingDifficulty.challenging,
        );
      });

      test('returns challenging at boundary values (2.0 km, 25 min)', () {
        expect(
          RouteService.getWalkingDifficulty(2.0, 25),
          WalkingDifficulty.challenging,
        );
      });

      test('returns difficult for very long distance', () {
        expect(
          RouteService.getWalkingDifficulty(3.0, 36),
          WalkingDifficulty.difficult,
        );
      });

      test('returns difficult for distance slightly over 2 km', () {
        expect(
          RouteService.getWalkingDifficulty(2.1, 26),
          WalkingDifficulty.difficult,
        );
      });

      test('difficulty determined by distance when duration fits lower tier',
          () {
        // Distance is easy range but check with duration of 3 min
        expect(
          RouteService.getWalkingDifficulty(0.4, 3),
          WalkingDifficulty.easy,
        );
      });

      test('returns difficult when only distance exceeds thresholds', () {
        // Distance > 2 km but duration is within challenging range
        expect(
          RouteService.getWalkingDifficulty(2.5, 20),
          WalkingDifficulty.difficult,
        );
      });

      test('returns difficult when only duration exceeds thresholds', () {
        // Distance within challenging range but duration > 25
        expect(
          RouteService.getWalkingDifficulty(1.5, 30),
          WalkingDifficulty.difficult,
        );
      });
    });
  });

  group('WalkingDifficulty', () {
    test('has 4 values', () {
      expect(WalkingDifficulty.values.length, 4);
    });

    test('easy has correct properties', () {
      expect(WalkingDifficulty.easy.label, 'Easy');
      expect(WalkingDifficulty.easy.description, 'Quick walk');
      expect(WalkingDifficulty.easy.color, const Color(0xFF2D6A4F));
    });

    test('moderate has correct properties', () {
      expect(WalkingDifficulty.moderate.label, 'Moderate');
      expect(WalkingDifficulty.moderate.description, 'Pleasant walk');
      expect(WalkingDifficulty.moderate.color, const Color(0xFFFFB300));
    });

    test('challenging has correct properties', () {
      expect(WalkingDifficulty.challenging.label, 'Challenging');
      expect(WalkingDifficulty.challenging.description, 'Longer walk');
      expect(WalkingDifficulty.challenging.color, const Color(0xFFFF8F00));
    });

    test('difficult has correct properties', () {
      expect(WalkingDifficulty.difficult.label, 'Difficult');
      expect(WalkingDifficulty.difficult.description, 'Long walk');
      expect(WalkingDifficulty.difficult.color, const Color(0xFFD32F2F));
    });

    test('all labels are unique', () {
      final labels = WalkingDifficulty.values.map((d) => d.label).toSet();
      expect(labels.length, WalkingDifficulty.values.length);
    });

    test('all descriptions are unique', () {
      final descriptions =
          WalkingDifficulty.values.map((d) => d.description).toSet();
      expect(descriptions.length, WalkingDifficulty.values.length);
    });

    test('all colors are unique', () {
      final colors = WalkingDifficulty.values.map((d) => d.color).toSet();
      expect(colors.length, WalkingDifficulty.values.length);
    });
  });

  group('RouteData', () {
    late RouteData routeData;

    setUp(() {
      routeData = RouteData(
        coordinates: [
          const LatLng(40.0, -74.0),
          const LatLng(40.1, -74.1),
        ],
        distance: '1.5 km',
        duration: '18 min',
        distanceValue: 1500,
        durationValue: 1080,
        steps: [
          RouteStep(
            instruction: 'Walk north',
            distance: '0.5 km',
            duration: '6 min',
            startLocation: const LatLng(40.0, -74.0),
            endLocation: const LatLng(40.05, -74.05),
          ),
          RouteStep(
            instruction: 'Turn right',
            distance: '1.0 km',
            duration: '12 min',
            startLocation: const LatLng(40.05, -74.05),
            endLocation: const LatLng(40.1, -74.1),
          ),
        ],
      );
    });

    test('distanceKm converts meters to km', () {
      expect(routeData.distanceKm, 1.5);
    });

    test('distanceKm handles zero', () {
      final zeroRoute = RouteData(
        coordinates: [],
        distance: '0 km',
        duration: '0 min',
        distanceValue: 0,
        durationValue: 0,
        steps: [],
      );
      expect(zeroRoute.distanceKm, 0.0);
    });

    test('durationMinutes converts seconds to minutes', () {
      // 1080 seconds = 18 minutes
      expect(routeData.durationMinutes, 18);
    });

    test('durationMinutes handles zero', () {
      final zeroRoute = RouteData(
        coordinates: [],
        distance: '0 km',
        duration: '0 min',
        distanceValue: 0,
        durationValue: 0,
        steps: [],
      );
      expect(zeroRoute.durationMinutes, 0);
    });

    test('difficulty returns correct WalkingDifficulty', () {
      // 1.5 km, 18 min -> challenging
      expect(routeData.difficulty, WalkingDifficulty.challenging);
    });

    test('difficulty returns easy for short route', () {
      final shortRoute = RouteData(
        coordinates: [],
        distance: '0.3 km',
        duration: '4 min',
        distanceValue: 300,
        durationValue: 240,
        steps: [],
      );
      expect(shortRoute.difficulty, WalkingDifficulty.easy);
    });

    test('toPolyline creates polyline with default parameters', () {
      final polyline = routeData.toPolyline();
      expect(polyline.polylineId.value, 'route');
      expect(polyline.points, routeData.coordinates);
      expect(polyline.width, 4);
      expect(polyline.color, const Color(0xFF8B4513));
    });

    test('toPolyline creates polyline with custom parameters', () {
      final polyline = routeData.toPolyline(
        polylineId: 'custom_route',
        color: const Color(0xFF0000FF),
        width: 8,
      );
      expect(polyline.polylineId.value, 'custom_route');
      expect(polyline.width, 8);
      expect(polyline.color, const Color(0xFF0000FF));
    });

    test('coordinates list is accessible', () {
      expect(routeData.coordinates.length, 2);
      expect(routeData.coordinates.first.latitude, 40.0);
      expect(routeData.coordinates.first.longitude, -74.0);
    });

    test('steps list is accessible', () {
      expect(routeData.steps.length, 2);
      expect(routeData.steps.first.instruction, 'Walk north');
    });

    test('distance and duration strings are accessible', () {
      expect(routeData.distance, '1.5 km');
      expect(routeData.duration, '18 min');
    });
  });

  group('RouteStep', () {
    test('creates instance with required fields', () {
      final step = RouteStep(
        instruction: 'Walk north on Main St',
        distance: '500 m',
        duration: '6 min',
        startLocation: const LatLng(40.0, -74.0),
        endLocation: const LatLng(40.05, -74.0),
      );

      expect(step.instruction, 'Walk north on Main St');
      expect(step.distance, '500 m');
      expect(step.duration, '6 min');
      expect(step.startLocation.latitude, 40.0);
      expect(step.endLocation.latitude, 40.05);
    });
  });

  group('WalkingPreferences', () {
    test('default values are correct', () {
      final prefs = WalkingPreferences();
      expect(prefs.maxDistanceKm, 2.0);
      expect(prefs.maxDurationMinutes, 25);
      expect(prefs.avoidHills, isFalse);
      expect(prefs.preferSidewalks, isTrue);
    });

    test('custom values are set correctly', () {
      final prefs = WalkingPreferences(
        maxDistanceKm: 5.0,
        maxDurationMinutes: 60,
        avoidHills: true,
        preferSidewalks: false,
      );
      expect(prefs.maxDistanceKm, 5.0);
      expect(prefs.maxDurationMinutes, 60);
      expect(prefs.avoidHills, isTrue);
      expect(prefs.preferSidewalks, isFalse);
    });

    group('meetsPreferences', () {
      test('returns true when route is within preferences', () {
        final prefs = WalkingPreferences();
        final route = RouteData(
          coordinates: [],
          distance: '1.0 km',
          duration: '12 min',
          distanceValue: 1000,
          durationValue: 720,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isTrue);
      });

      test('returns true at exact boundary', () {
        final prefs = WalkingPreferences();
        final route = RouteData(
          coordinates: [],
          distance: '2.0 km',
          duration: '25 min',
          distanceValue: 2000,
          durationValue: 1500,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isTrue);
      });

      test('returns false when distance exceeds preference', () {
        final prefs = WalkingPreferences();
        final route = RouteData(
          coordinates: [],
          distance: '3.0 km',
          duration: '20 min',
          distanceValue: 3000,
          durationValue: 1200,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isFalse);
      });

      test('returns false when duration exceeds preference', () {
        final prefs = WalkingPreferences();
        final route = RouteData(
          coordinates: [],
          distance: '1.5 km',
          duration: '30 min',
          distanceValue: 1500,
          durationValue: 1800,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isFalse);
      });

      test('returns false when both exceed preference', () {
        final prefs = WalkingPreferences();
        final route = RouteData(
          coordinates: [],
          distance: '5.0 km',
          duration: '60 min',
          distanceValue: 5000,
          durationValue: 3600,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isFalse);
      });

      test('custom preferences are respected', () {
        final prefs = WalkingPreferences(
          maxDistanceKm: 10.0,
          maxDurationMinutes: 120,
        );
        final route = RouteData(
          coordinates: [],
          distance: '8.0 km',
          duration: '96 min',
          distanceValue: 8000,
          durationValue: 5760,
          steps: [],
        );
        expect(prefs.meetsPreferences(route), isTrue);
      });
    });
  });

  group('RouteCalculationOptions', () {
    test('default values are correct', () {
      final options = RouteCalculationOptions();
      expect(options.mode, 'walking');
      expect(options.alternatives, isFalse);
      expect(options.optimizeWaypoints, isFalse);
      expect(options.language, isNull);
      expect(options.region, isNull);
    });

    test('custom values are set correctly', () {
      final options = RouteCalculationOptions(
        mode: 'driving',
        alternatives: true,
        optimizeWaypoints: true,
        language: 'en',
        region: 'us',
      );
      expect(options.mode, 'driving');
      expect(options.alternatives, isTrue);
      expect(options.optimizeWaypoints, isTrue);
      expect(options.language, 'en');
      expect(options.region, 'us');
    });

    test('mode can be transit', () {
      final options = RouteCalculationOptions(mode: 'transit');
      expect(options.mode, 'transit');
    });
  });
}
