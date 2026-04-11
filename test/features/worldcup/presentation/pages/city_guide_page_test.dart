import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/fan_zone_guide.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/city_guide_page.dart';

void main() {
  late FanZoneGuide sampleGuide;

  setUp(() {
    sampleGuide = FanZoneGuide.fromJson({
      'cityId': 'new_york_nj',
      'cityName': 'New York / New Jersey',
      'country': 'USA',
      'stateOrProvince': 'New Jersey',
      'venueStadium': {'name': 'MetLife Stadium', 'capacity': 82500},
      'fanZones': [
        {
          'name': 'Times Square Fan Zone',
          'location': 'Times Square, Manhattan',
          'description': 'The heart of the action.',
          'features': ['Live screenings', 'Food trucks'],
        },
      ],
      'transit': {
        'airports': ['JFK', 'EWR', 'LGA'],
        'publicTransit': 'NJ Transit and PATH trains serve MetLife.',
        'tips': ['Take NJ Transit from Penn Station.'],
      },
      'timezone': 'ET',
      'utcOffset': -4,
      'currency': 'USD',
      'language': 'English',
      'visaRequirements': {
        'forUS': 'No visa needed.',
        'forCanada': 'ESTA required.',
        'forMexico': 'ESTA required.',
        'forEU': 'ESTA required.',
        'general': 'Most visitors need ESTA or visa.',
      },
      'weather': {
        'juneAvgHigh': 82,
        'juneAvgLow': 63,
        'julyAvgHigh': 87,
        'julyAvgLow': 68,
        'rainySeasonNote': 'Afternoon thunderstorms possible.',
      },
      'localTips': ['Walk across the Brooklyn Bridge.', 'Try a classic NYC slice.'],
      'emergencyNumber': '911',
    });
  });

  Widget buildWidget() {
    return MaterialApp(
      home: CityGuidePage(guide: sampleGuide),
    );
  }

  group('CityGuidePage', () {
    testWidgets('renders city name in header', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('New York / New Jersey'), findsWidgets);
    });

    testWidgets('renders stadium name and capacity', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('MetLife Stadium'), findsOneWidget);
      expect(find.textContaining('82.5k'), findsOneWidget);
    });

    testWidgets('renders fan zone name and description', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.scrollUntilVisible(
        find.text('Times Square Fan Zone'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Times Square Fan Zone'), findsOneWidget);
      expect(find.text('The heart of the action.'), findsOneWidget);
    });

    testWidgets('renders transit airports', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.scrollUntilVisible(
        find.textContaining('JFK'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('JFK'), findsOneWidget);
    });

    testWidgets('renders weather data', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.scrollUntilVisible(
        find.text('June'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('June'), findsOneWidget);
      expect(find.text('July'), findsOneWidget);
    });

    testWidgets('renders local tips', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.scrollUntilVisible(
        find.textContaining('Brooklyn Bridge'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Brooklyn Bridge'), findsOneWidget);
    });

    testWidgets('renders emergency number', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.scrollUntilVisible(
        find.textContaining('911'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('911'), findsOneWidget);
    });

    testWidgets('renders country flag for USA', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.textContaining('🇺🇸'), findsAtLeast(1));
    });

    testWidgets('renders info chips for timezone, currency, language', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('ET'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });
  });
}
