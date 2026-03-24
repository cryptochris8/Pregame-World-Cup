import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/nearby_venues_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_venue.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/nearby_venue_list_tile.dart';

void main() {
  late WorldCupVenue testVenue;
  late Place testPlace;
  late NearbyVenueResult testResult;

  setUp(() {
    // Suppress overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };

    testVenue = WorldCupVenue(
      venueId: 'v1',
      name: 'MetLife Stadium',
      city: 'East Rutherford',
      country: HostCountry.usa,
      capacity: 82500,
    );

    testPlace = Place(
      placeId: 'p1',
      name: 'Sports Bar',
      rating: 4.5,
      types: ['bar'],
      latitude: 40.8,
      longitude: -74.1,
    );

    testResult = NearbyVenueResult(
      place: testPlace,
      distanceMeters: 500.0,
      stadium: testVenue,
    );
  });

  Widget buildTestWidget(NearbyVenueResult result, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: NearbyVenueListTile(
          venue: result,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('renders venue name', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    expect(find.text('Sports Bar'), findsOneWidget);
  });

  testWidgets('renders type icon emoji for bar', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    expect(find.text('🍺'), findsOneWidget);
  });

  testWidgets('renders distance formatted', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    // Distance should be formatted as "0.3 mi" (500 meters)
    expect(find.textContaining('0.3 mi'), findsOneWidget);
  });

  testWidgets('renders walking time formatted', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    // Walking time should be formatted as "6 min walk" or similar
    expect(find.textContaining('min walk'), findsOneWidget);
  });

  testWidgets('renders star rating when rating is not null',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('does not show rating when rating is null',
      (WidgetTester tester) async {
    final placeWithoutRating = Place(
      placeId: 'p2',
      name: 'No Rating Bar',
      rating: null,
      types: ['bar'],
      latitude: 40.8,
      longitude: -74.1,
    );

    final resultWithoutRating = NearbyVenueResult(
      place: placeWithoutRating,
      distanceMeters: 500.0,
      stadium: testVenue,
    );

    await tester.pumpWidget(buildTestWidget(resultWithoutRating));

    expect(find.byIcon(Icons.star), findsNothing);
  });

  testWidgets('calls onTap when tapped', (WidgetTester tester) async {
    bool wasTapped = false;
    void handleTap() {
      wasTapped = true;
    }

    await tester.pumpWidget(buildTestWidget(testResult, onTap: handleTap));

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(wasTapped, isTrue);
  });

  testWidgets('renders as ListTile', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(testResult));

    expect(find.byType(ListTile), findsOneWidget);
  });
}
