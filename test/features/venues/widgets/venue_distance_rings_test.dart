import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_distance_rings.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('DistanceRing', () {
    test('can be constructed with all required parameters', () {
      final ring = DistanceRing(
        radiusMiles: 0.5,
        label: 'Close',
        description: '5-10 min walk',
        color: Colors.green,
        estimatedWalkTime: 7,
      );

      expect(ring.radiusMiles, 0.5);
      expect(ring.label, 'Close');
      expect(ring.description, '5-10 min walk');
      expect(ring.color, Colors.green);
      expect(ring.estimatedWalkTime, 7);
    });

    test('stores values correctly', () {
      final ring = DistanceRing(
        radiusMiles: 1.5,
        label: 'Far',
        description: '20+ min walk',
        color: const Color(0xFFD32F2F),
        estimatedWalkTime: 25,
      );

      expect(ring.radiusMiles, 1.5);
      expect(ring.label, 'Far');
      expect(ring.description, '20+ min walk');
      expect(ring.color, const Color(0xFFD32F2F));
      expect(ring.estimatedWalkTime, 25);
    });

    test('supports different radius values', () {
      final ring1 = DistanceRing(
        radiusMiles: 0.25,
        label: 'Very Close',
        description: '2-5 min',
        color: Colors.green,
        estimatedWalkTime: 3,
      );
      final ring2 = DistanceRing(
        radiusMiles: 2.0,
        label: 'Very Far',
        description: '30+ min',
        color: Colors.red,
        estimatedWalkTime: 35,
      );

      expect(ring1.radiusMiles, 0.25);
      expect(ring2.radiusMiles, 2.0);
    });

    test('supports different colors', () {
      final greenRing = DistanceRing(
        radiusMiles: 0.5,
        label: 'Close',
        description: 'Short walk',
        color: const Color(0xFF2D6A4F),
        estimatedWalkTime: 5,
      );
      final yellowRing = DistanceRing(
        radiusMiles: 1.0,
        label: 'Medium',
        description: 'Medium walk',
        color: const Color(0xFFFFB300),
        estimatedWalkTime: 15,
      );

      expect(greenRing.color, const Color(0xFF2D6A4F));
      expect(yellowRing.color, const Color(0xFFFFB300));
    });
  });

  group('GameDayDistanceRings', () {
    testWidgets('getDefaultRings returns 4 distance rings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              expect(rings.length, 4);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getDefaultRings has correct radius values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              expect(rings[0].radiusMiles, 0.25);
              expect(rings[1].radiusMiles, 0.5);
              expect(rings[2].radiusMiles, 1.0);
              expect(rings[3].radiusMiles, 1.5);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getDefaultRings has correct estimated walk times', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              expect(rings[0].estimatedWalkTime, 3);
              expect(rings[1].estimatedWalkTime, 10);
              expect(rings[2].estimatedWalkTime, 18);
              expect(rings[3].estimatedWalkTime, 25);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getDefaultRings has correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              expect(rings[0].color, const Color(0xFF2D6A4F)); // Green
              expect(rings[1].color, const Color(0xFFFFB300)); // Yellow
              expect(rings[2].color, const Color(0xFFFF8F00)); // Orange
              expect(rings[3].color, const Color(0xFFD32F2F)); // Red
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getQuickAccessRings returns 3 distance rings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getQuickAccessRings(l10n);

              expect(rings.length, 3);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getQuickAccessRings has correct radius values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getQuickAccessRings(l10n);

              expect(rings[0].radiusMiles, 0.2);
              expect(rings[1].radiusMiles, 0.5);
              expect(rings[2].radiusMiles, 1.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getQuickAccessRings has correct estimated walk times', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getQuickAccessRings(l10n);

              expect(rings[0].estimatedWalkTime, 2);
              expect(rings[1].estimatedWalkTime, 7);
              expect(rings[2].estimatedWalkTime, 15);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getQuickAccessRings has correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getQuickAccessRings(l10n);

              expect(rings[0].color, const Color(0xFF1B5E20)); // Dark green
              expect(rings[1].color, const Color(0xFF388E3C)); // Medium green
              expect(rings[2].color, const Color(0xFFF57C00)); // Orange
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('default rings are ordered by increasing radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              for (int i = 1; i < rings.length; i++) {
                expect(rings[i].radiusMiles, greaterThan(rings[i - 1].radiusMiles));
              }
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('quick access rings are ordered by increasing radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getQuickAccessRings(l10n);

              for (int i = 1; i < rings.length; i++) {
                expect(rings[i].radiusMiles, greaterThan(rings[i - 1].radiusMiles));
              }
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('default rings walk times increase with distance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final rings = GameDayDistanceRings.getDefaultRings(l10n);

              for (int i = 1; i < rings.length; i++) {
                expect(rings[i].estimatedWalkTime, greaterThan(rings[i - 1].estimatedWalkTime));
              }
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('quick access rings have smaller radii than default rings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final defaultRings = GameDayDistanceRings.getDefaultRings(l10n);
              final quickRings = GameDayDistanceRings.getQuickAccessRings(l10n);

              expect(quickRings[0].radiusMiles, lessThan(defaultRings[0].radiusMiles));
              expect(quickRings.last.radiusMiles, lessThanOrEqualTo(defaultRings[2].radiusMiles));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('VenueDistanceGroup', () {
    test('can be constructed with all required parameters', () {
      final group = VenueDistanceGroup(
        title: 'Very Close',
        description: '2-5 min walk',
        color: Colors.green,
        venueCount: 12,
        minDistance: 0.0,
        maxDistance: 0.25,
      );

      expect(group.title, 'Very Close');
      expect(group.description, '2-5 min walk');
      expect(group.color, Colors.green);
      expect(group.venueCount, 12);
      expect(group.minDistance, 0.0);
      expect(group.maxDistance, 0.25);
    });

    test('stores values correctly', () {
      final group = VenueDistanceGroup(
        title: 'Moderate',
        description: '15-20 min walk',
        color: const Color(0xFFFF8F00),
        venueCount: 8,
        minDistance: 0.5,
        maxDistance: 1.0,
      );

      expect(group.title, 'Moderate');
      expect(group.description, '15-20 min walk');
      expect(group.color, const Color(0xFFFF8F00));
      expect(group.venueCount, 8);
      expect(group.minDistance, 0.5);
      expect(group.maxDistance, 1.0);
    });

    test('supports different venue counts', () {
      final smallGroup = VenueDistanceGroup(
        title: 'Small',
        description: 'Few venues',
        color: Colors.blue,
        venueCount: 3,
        minDistance: 0.0,
        maxDistance: 0.5,
      );
      final largeGroup = VenueDistanceGroup(
        title: 'Large',
        description: 'Many venues',
        color: Colors.blue,
        venueCount: 50,
        minDistance: 0.0,
        maxDistance: 0.5,
      );

      expect(smallGroup.venueCount, 3);
      expect(largeGroup.venueCount, 50);
    });

    test('can have zero venues', () {
      final group = VenueDistanceGroup(
        title: 'Empty',
        description: 'No venues',
        color: Colors.grey,
        venueCount: 0,
        minDistance: 0.0,
        maxDistance: 0.5,
      );

      expect(group.venueCount, 0);
    });

    test('supports overlapping distance ranges', () {
      final group1 = VenueDistanceGroup(
        title: 'Group 1',
        description: 'First group',
        color: Colors.red,
        venueCount: 5,
        minDistance: 0.0,
        maxDistance: 0.5,
      );
      final group2 = VenueDistanceGroup(
        title: 'Group 2',
        description: 'Second group',
        color: Colors.blue,
        venueCount: 3,
        minDistance: 0.25,
        maxDistance: 0.75,
      );

      expect(group1.maxDistance, greaterThan(group2.minDistance));
    });
  });

  group('VenueDistanceOrganizer', () {
    test('can be constructed with required parameters', () {
      final groups = [
        VenueDistanceGroup(
          title: 'Close',
          description: 'Nearby venues',
          color: Colors.green,
          venueCount: 10,
          minDistance: 0.0,
          maxDistance: 0.5,
        ),
      ];

      final widget = VenueDistanceOrganizer(groups: groups);

      expect(widget, isNotNull);
      expect(widget.groups, groups);
      expect(widget.onGroupTap, isNull);
    });

    test('can be constructed with optional onGroupTap callback', () {
      final groups = [
        VenueDistanceGroup(
          title: 'Close',
          description: 'Nearby venues',
          color: Colors.green,
          venueCount: 10,
          minDistance: 0.0,
          maxDistance: 0.5,
        ),
      ];
      bool tapped = false;
      void onTap(VenueDistanceGroup group) {
        tapped = true;
      }

      final widget = VenueDistanceOrganizer(
        groups: groups,
        onGroupTap: onTap,
      );

      expect(widget.onGroupTap, isNotNull);
      widget.onGroupTap?.call(groups[0]);
      expect(tapped, true);
    });

    test('accepts empty groups list', () {
      final widget = VenueDistanceOrganizer(groups: const []);

      expect(widget.groups, isEmpty);
    });

    test('accepts multiple groups', () {
      final groups = [
        VenueDistanceGroup(
          title: 'Very Close',
          description: '2-5 min',
          color: Colors.green,
          venueCount: 8,
          minDistance: 0.0,
          maxDistance: 0.25,
        ),
        VenueDistanceGroup(
          title: 'Close',
          description: '5-10 min',
          color: Colors.yellow,
          venueCount: 12,
          minDistance: 0.25,
          maxDistance: 0.5,
        ),
        VenueDistanceGroup(
          title: 'Far',
          description: '20+ min',
          color: Colors.red,
          venueCount: 5,
          minDistance: 1.0,
          maxDistance: 1.5,
        ),
      ];

      final widget = VenueDistanceOrganizer(groups: groups);

      expect(widget.groups.length, 3);
      expect(widget.groups[0].title, 'Very Close');
      expect(widget.groups[1].title, 'Close');
      expect(widget.groups[2].title, 'Far');
    });
  });

  group('VenueDistanceRings', () {
    test('can be constructed with required parameters', () {
      final rings = [
        DistanceRing(
          radiusMiles: 0.5,
          label: 'Close',
          description: '5-10 min',
          color: Colors.green,
          estimatedWalkTime: 7,
        ),
      ];

      final widget = VenueDistanceRings(
        centerLocation: const LatLng(40.7128, -74.0060),
        rings: rings,
      );

      expect(widget, isNotNull);
      expect(widget.centerLocation.latitude, 40.7128);
      expect(widget.centerLocation.longitude, -74.0060);
      expect(widget.rings, rings);
      expect(widget.isVisible, false);
      expect(widget.onToggle, isNull);
    });

    test('accepts optional isVisible parameter', () {
      final rings = [
        DistanceRing(
          radiusMiles: 0.5,
          label: 'Close',
          description: '5-10 min',
          color: Colors.green,
          estimatedWalkTime: 7,
        ),
      ];

      final widget = VenueDistanceRings(
        centerLocation: const LatLng(40.7128, -74.0060),
        rings: rings,
        isVisible: true,
      );

      expect(widget.isVisible, true);
    });

    test('accepts optional onToggle callback', () {
      final rings = [
        DistanceRing(
          radiusMiles: 0.5,
          label: 'Close',
          description: '5-10 min',
          color: Colors.green,
          estimatedWalkTime: 7,
        ),
      ];
      bool toggled = false;
      void onToggle() {
        toggled = true;
      }

      final widget = VenueDistanceRings(
        centerLocation: const LatLng(40.7128, -74.0060),
        rings: rings,
        onToggle: onToggle,
      );

      expect(widget.onToggle, isNotNull);
      widget.onToggle?.call();
      expect(toggled, true);
    });

    test('accepts multiple rings', () {
      final rings = [
        DistanceRing(
          radiusMiles: 0.25,
          label: 'Very Close',
          description: '2-5 min',
          color: Colors.green,
          estimatedWalkTime: 3,
        ),
        DistanceRing(
          radiusMiles: 0.5,
          label: 'Close',
          description: '5-10 min',
          color: Colors.yellow,
          estimatedWalkTime: 7,
        ),
        DistanceRing(
          radiusMiles: 1.0,
          label: 'Far',
          description: '15-20 min',
          color: Colors.orange,
          estimatedWalkTime: 18,
        ),
      ];

      final widget = VenueDistanceRings(
        centerLocation: const LatLng(40.7128, -74.0060),
        rings: rings,
      );

      expect(widget.rings.length, 3);
      expect(widget.rings[0].radiusMiles, 0.25);
      expect(widget.rings[1].radiusMiles, 0.5);
      expect(widget.rings[2].radiusMiles, 1.0);
    });

    test('can have different center locations', () {
      final rings = [
        DistanceRing(
          radiusMiles: 0.5,
          label: 'Close',
          description: '5-10 min',
          color: Colors.green,
          estimatedWalkTime: 7,
        ),
      ];

      final widget1 = VenueDistanceRings(
        centerLocation: const LatLng(40.7128, -74.0060), // New York
        rings: rings,
      );
      final widget2 = VenueDistanceRings(
        centerLocation: const LatLng(34.0522, -118.2437), // Los Angeles
        rings: rings,
      );

      expect(widget1.centerLocation.latitude, 40.7128);
      expect(widget2.centerLocation.latitude, 34.0522);
    });
  });
}
