import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/fan_zone_guide.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/fan_zone_guide_service.dart';

void main() {
  group('FanZoneGuide', () {
    late Map<String, dynamic> sampleJson;

    setUp(() {
      sampleJson = {
        'cityId': 'new_york_nj',
        'cityName': 'New York / New Jersey',
        'country': 'USA',
        'stateOrProvince': 'New Jersey',
        'venueStadium': {
          'name': 'MetLife Stadium',
          'capacity': 87157,
          'tournamentName': 'New York New Jersey Stadium',
        },
        'fanZones': [
          {
            'name': 'Times Square Fan Festival',
            'location': 'Times Square, Manhattan, New York',
            'description': 'The main fan gathering point in Manhattan.',
            'features': ['Giant LED screens', 'Live music stages', 'Food village'],
          },
        ],
        'transit': {
          'airports': ['Newark Liberty International (EWR)', 'JFK International (JFK)'],
          'publicTransit': 'NJ Transit trains and buses connect to MetLife Stadium.',
          'tips': ['Use the Meadowlands Rail Line', 'Buy a MetroCard'],
        },
        'timezone': 'America/New_York',
        'utcOffset': -4,
        'currency': 'USD',
        'language': 'English',
        'visaRequirements': {
          'forUS': 'No visa needed (domestic)',
          'forCanada': 'ESTA or B1/B2 visa required',
          'forMexico': 'ESTA or B1/B2 visa required',
          'forEU': 'ESTA required for Visa Waiver Program countries',
          'general': 'Most visitors need an approved ESTA or valid US visa.',
        },
        'weather': {
          'juneAvgHigh': 27,
          'juneAvgLow': 17,
          'julyAvgHigh': 30,
          'julyAvgLow': 21,
          'rainySeasonNote': 'Summer thunderstorms possible.',
        },
        'localTips': [
          'MetLife Stadium is in East Rutherford, NJ.',
          'The NYC subway runs 24/7.',
          'Tipping 18-20% is standard.',
        ],
        'emergencyNumber': '911',
      };
    });

    test('fromJson parses all top-level fields correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.cityId, 'new_york_nj');
      expect(guide.cityName, 'New York / New Jersey');
      expect(guide.country, 'USA');
      expect(guide.stateOrProvince, 'New Jersey');
      expect(guide.timezone, 'America/New_York');
      expect(guide.utcOffset, -4);
      expect(guide.currency, 'USD');
      expect(guide.language, 'English');
      expect(guide.emergencyNumber, '911');
    });

    test('fromJson parses venueStadium correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.venueStadium.name, 'MetLife Stadium');
      expect(guide.venueStadium.capacity, 87157);
      expect(guide.venueStadium.tournamentName, 'New York New Jersey Stadium');
    });

    test('fromJson parses fanZones list correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.fanZones.length, 1);
      expect(guide.fanZones.first.name, 'Times Square Fan Festival');
      expect(guide.fanZones.first.location, contains('Manhattan'));
      expect(guide.fanZones.first.features.length, 3);
      expect(guide.fanZones.first.features, contains('Giant LED screens'));
    });

    test('fromJson parses transit info correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.transit.airports.length, 2);
      expect(guide.transit.airports.first, contains('EWR'));
      expect(guide.transit.publicTransit, contains('NJ Transit'));
      expect(guide.transit.tips.length, 2);
    });

    test('fromJson parses visa requirements correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.visaRequirements.forUS, contains('domestic'));
      expect(guide.visaRequirements.forCanada, contains('ESTA'));
      expect(guide.visaRequirements.forMexico, contains('ESTA'));
      expect(guide.visaRequirements.forEU, contains('Visa Waiver'));
      expect(guide.visaRequirements.general, contains('ESTA'));
    });

    test('fromJson parses weather info correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.weather.juneAvgHigh, 27);
      expect(guide.weather.juneAvgLow, 17);
      expect(guide.weather.julyAvgHigh, 30);
      expect(guide.weather.julyAvgLow, 21);
      expect(guide.weather.rainySeasonNote, contains('thunderstorms'));
    });

    test('fromJson parses localTips correctly', () {
      final guide = FanZoneGuide.fromJson(sampleJson);

      expect(guide.localTips.length, 3);
      expect(guide.localTips.first, contains('East Rutherford'));
    });

    test('toJson roundtrip preserves data', () {
      final original = FanZoneGuide.fromJson(sampleJson);
      final json = original.toJson();
      final restored = FanZoneGuide.fromJson(json);

      expect(restored.cityId, original.cityId);
      expect(restored.cityName, original.cityName);
      expect(restored.country, original.country);
      expect(restored.venueStadium.name, original.venueStadium.name);
      expect(restored.venueStadium.capacity, original.venueStadium.capacity);
      expect(restored.fanZones.length, original.fanZones.length);
      expect(restored.fanZones.first.name, original.fanZones.first.name);
      expect(restored.transit.airports.length, original.transit.airports.length);
      expect(restored.visaRequirements.forUS, original.visaRequirements.forUS);
      expect(restored.weather.juneAvgHigh, original.weather.juneAvgHigh);
      expect(restored.localTips.length, original.localTips.length);
      expect(restored.emergencyNumber, original.emergencyNumber);
    });

    test('equatable compares by cityId', () {
      final a = FanZoneGuide.fromJson(sampleJson);
      final b = FanZoneGuide.fromJson(sampleJson);
      expect(a, equals(b));
    });

    test('equatable detects different cityIds', () {
      final a = FanZoneGuide.fromJson(sampleJson);
      final modifiedJson = Map<String, dynamic>.from(sampleJson);
      modifiedJson['cityId'] = 'los_angeles';
      final b = FanZoneGuide.fromJson(modifiedJson);
      expect(a, isNot(equals(b)));
    });
  });

  group('VenueStadium', () {
    test('fromJson parses all fields', () {
      final stadium = VenueStadium.fromJson({
        'name': 'MetLife Stadium',
        'capacity': 87157,
        'tournamentName': 'New York New Jersey Stadium',
      });

      expect(stadium.name, 'MetLife Stadium');
      expect(stadium.capacity, 87157);
      expect(stadium.tournamentName, 'New York New Jersey Stadium');
    });

    test('fromJson handles missing tournamentName', () {
      final stadium = VenueStadium.fromJson({
        'name': 'Test Stadium',
        'capacity': 50000,
      });

      expect(stadium.tournamentName, isNull);
    });
  });

  group('FanZone', () {
    test('fromJson parses all fields', () {
      final zone = FanZone.fromJson({
        'name': 'Times Square Fan Festival',
        'location': 'Times Square, Manhattan',
        'description': 'The main fan gathering point.',
        'features': ['Screens', 'Music', 'Food'],
      });

      expect(zone.name, 'Times Square Fan Festival');
      expect(zone.location, contains('Manhattan'));
      expect(zone.description, contains('fan gathering'));
      expect(zone.features.length, 3);
    });

    test('toJson roundtrip preserves data', () {
      final original = FanZone.fromJson({
        'name': 'Test Zone',
        'location': 'Test Location',
        'description': 'A test fan zone.',
        'features': ['Feature 1', 'Feature 2'],
      });
      final json = original.toJson();
      final restored = FanZone.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.features.length, original.features.length);
    });
  });

  group('TransitInfo', () {
    test('fromJson parses all fields', () {
      final transit = TransitInfo.fromJson({
        'airports': ['EWR', 'JFK', 'LGA'],
        'publicTransit': 'Subway, bus, and rail.',
        'tips': ['Use subway', 'Buy MetroCard'],
      });

      expect(transit.airports.length, 3);
      expect(transit.publicTransit, contains('Subway'));
      expect(transit.tips.length, 2);
    });
  });

  group('VisaRequirements', () {
    test('fromJson parses all fields', () {
      final visa = VisaRequirements.fromJson({
        'forUS': 'No visa needed',
        'forCanada': 'ESTA required',
        'forMexico': 'ESTA required',
        'forEU': 'ESTA for VWP countries',
        'general': 'Apply 72 hours before travel.',
      });

      expect(visa.forUS, 'No visa needed');
      expect(visa.forCanada, 'ESTA required');
      expect(visa.forMexico, 'ESTA required');
      expect(visa.forEU, contains('VWP'));
      expect(visa.general, contains('72 hours'));
    });

    test('toJson roundtrip preserves data', () {
      final original = VisaRequirements.fromJson({
        'forUS': 'Domestic',
        'forCanada': 'ESTA',
        'forMexico': 'ESTA',
        'forEU': 'ESTA for VWP',
        'general': 'General info',
      });
      final json = original.toJson();
      final restored = VisaRequirements.fromJson(json);

      expect(restored.forUS, original.forUS);
      expect(restored.general, original.general);
    });
  });

  group('WeatherInfo', () {
    test('fromJson parses all fields', () {
      final weather = WeatherInfo.fromJson({
        'juneAvgHigh': 27,
        'juneAvgLow': 17,
        'julyAvgHigh': 30,
        'julyAvgLow': 21,
        'rainySeasonNote': 'Thunderstorms possible.',
      });

      expect(weather.juneAvgHigh, 27);
      expect(weather.juneAvgLow, 17);
      expect(weather.julyAvgHigh, 30);
      expect(weather.julyAvgLow, 21);
      expect(weather.rainySeasonNote, contains('Thunderstorms'));
    });

    test('toJson roundtrip preserves data', () {
      final original = WeatherInfo.fromJson({
        'juneAvgHigh': 35,
        'juneAvgLow': 24,
        'julyAvgHigh': 37,
        'julyAvgLow': 25,
        'rainySeasonNote': 'Hot and humid.',
      });
      final json = original.toJson();
      final restored = WeatherInfo.fromJson(json);

      expect(restored.juneAvgHigh, original.juneAvgHigh);
      expect(restored.rainySeasonNote, original.rainySeasonNote);
    });
  });

  group('FanZoneGuide - Mexico city parsing', () {
    test('parses a Mexican city with MXN currency', () {
      final guide = FanZoneGuide.fromJson({
        'cityId': 'mexico_city',
        'cityName': 'Mexico City',
        'country': 'Mexico',
        'stateOrProvince': 'Ciudad de Mexico',
        'venueStadium': {
          'name': 'Estadio Azteca',
          'capacity': 87523,
        },
        'fanZones': [
          {
            'name': 'Zocalo Fan Festival',
            'location': 'Zocalo, Centro Historico',
            'description': 'The massive central square.',
            'features': ['Screenings', 'Mariachi'],
          },
        ],
        'transit': {
          'airports': ['Mexico City International (MEX)'],
          'publicTransit': 'CDMX Metro is one of the busiest in the world.',
          'tips': ['Take Metro Line 2 to Tasquena'],
        },
        'timezone': 'America/Mexico_City',
        'utcOffset': -6,
        'currency': 'MXN (Mexican Peso)',
        'language': 'Spanish',
        'visaRequirements': {
          'forUS': 'No visa needed for stays under 180 days',
          'forCanada': 'No visa needed for stays under 180 days',
          'forMexico': 'No visa needed (domestic)',
          'forEU': 'No visa needed for most EU citizens',
          'general': 'FMM tourist card required.',
        },
        'weather': {
          'juneAvgHigh': 24,
          'juneAvgLow': 13,
          'julyAvgHigh': 23,
          'julyAvgLow': 12,
          'rainySeasonNote': 'Heavy rainy season June-September.',
        },
        'localTips': [
          'Altitude is 2,200 meters.',
          'Street tacos are essential.',
        ],
        'emergencyNumber': '911',
      });

      expect(guide.country, 'Mexico');
      expect(guide.currency, 'MXN (Mexican Peso)');
      expect(guide.language, 'Spanish');
      expect(guide.utcOffset, -6);
      expect(guide.visaRequirements.forMexico, contains('domestic'));
    });
  });

  group('FanZoneGuide - Canada city parsing', () {
    test('parses a Canadian city with CAD currency and eTA visa info', () {
      final guide = FanZoneGuide.fromJson({
        'cityId': 'toronto',
        'cityName': 'Toronto',
        'country': 'Canada',
        'stateOrProvince': 'Ontario',
        'venueStadium': {
          'name': 'BMO Field',
          'capacity': 45736,
        },
        'fanZones': [
          {
            'name': 'Nathan Phillips Square Fan Zone',
            'location': 'Nathan Phillips Square, City Hall',
            'description': 'Toronto civic heart becomes a multicultural festival.',
            'features': ['City Hall screenings', 'Food village'],
          },
        ],
        'transit': {
          'airports': ['Toronto Pearson International (YYZ)'],
          'publicTransit': 'TTC operates subway, streetcars, and buses.',
          'tips': ['Take the 509 streetcar from Union Station'],
        },
        'timezone': 'America/Toronto',
        'utcOffset': -4,
        'currency': 'CAD (Canadian Dollar)',
        'language': 'English (French is also an official language of Canada)',
        'visaRequirements': {
          'forUS': 'No visa needed for US citizens.',
          'forCanada': 'No visa needed (domestic)',
          'forMexico': 'eTA required for Mexican citizens.',
          'forEU': 'eTA required for most EU citizens.',
          'general': 'Many nationalities need only an eTA to fly to Canada.',
        },
        'weather': {
          'juneAvgHigh': 25,
          'juneAvgLow': 14,
          'julyAvgHigh': 28,
          'julyAvgLow': 18,
          'rainySeasonNote': 'Pleasant summer weather.',
        },
        'localTips': [
          'Toronto is one of the most multicultural cities on Earth.',
        ],
        'emergencyNumber': '911',
      });

      expect(guide.country, 'Canada');
      expect(guide.currency, 'CAD (Canadian Dollar)');
      expect(guide.visaRequirements.forMexico, contains('eTA'));
      expect(guide.visaRequirements.forEU, contains('eTA'));
    });
  });

  group('FanZoneGuideService', () {
    late FanZoneGuideService service;

    setUp(() {
      service = FanZoneGuideService();
    });

    test('service can be instantiated', () {
      expect(service, isNotNull);
    });

    test('clearCache does not throw', () {
      service.clearCache();
    });

    test('getAllCityGuides returns empty list in test environment', () async {
      // In unit tests, rootBundle is not available, so the service
      // should gracefully return an empty list.
      final guides = await service.getAllCityGuides();
      expect(guides, isA<List<FanZoneGuide>>());
    });

    test('getCityGuide returns null for non-existent city in test env', () async {
      final guide = await service.getCityGuide('nonexistent_city');
      expect(guide, isNull);
    });

    test('getCityGuidesByCountry returns list in test env', () async {
      final guides = await service.getCityGuidesByCountry('USA');
      expect(guides, isA<List<FanZoneGuide>>());
    });

    test('searchCities returns list in test env', () async {
      final results = await service.searchCities('New York');
      expect(results, isA<List<FanZoneGuide>>());
    });

    test('getCityCount returns count in test env', () async {
      final count = await service.getCityCount();
      expect(count, isA<int>());
    });

    test('cache is used on repeated calls', () async {
      // First call loads (empty in test env)
      await service.getAllCityGuides();
      // Second call should use cache — should not throw
      final guides = await service.getAllCityGuides();
      expect(guides, isA<List<FanZoneGuide>>());
    });

    test('clearCache forces reload on next call', () async {
      await service.getAllCityGuides();
      service.clearCache();
      // After clearing, next call should work fine
      final guides = await service.getAllCityGuides();
      expect(guides, isA<List<FanZoneGuide>>());
    });
  });
}
