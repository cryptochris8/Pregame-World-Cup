import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_venue.dart';

void main() {
  group('HostCountry', () {
    test('has expected values', () {
      expect(HostCountry.values, hasLength(3));
      expect(HostCountry.values, contains(HostCountry.usa));
      expect(HostCountry.values, contains(HostCountry.mexico));
      expect(HostCountry.values, contains(HostCountry.canada));
    });
  });

  group('HostCountryExtension', () {
    test('displayName returns correct values', () {
      expect(HostCountry.usa.displayName, equals('United States'));
      expect(HostCountry.mexico.displayName, equals('Mexico'));
      expect(HostCountry.canada.displayName, equals('Canada'));
    });

    test('code returns correct values', () {
      expect(HostCountry.usa.code, equals('USA'));
      expect(HostCountry.mexico.code, equals('MEX'));
      expect(HostCountry.canada.code, equals('CAN'));
    });

    test('flagEmoji returns correct values', () {
      expect(HostCountry.usa.flagEmoji, equals('\u{1F1FA}\u{1F1F8}'));
      expect(HostCountry.mexico.flagEmoji, equals('\u{1F1F2}\u{1F1FD}'));
      expect(HostCountry.canada.flagEmoji, equals('\u{1F1E8}\u{1F1E6}'));
    });
  });

  group('WorldCupVenue', () {
    WorldCupVenue createTestVenue({
      String venueId = 'venue_1',
      String name = 'Test Stadium',
      String? worldCupName,
      String city = 'Test City',
      String? state,
      HostCountry country = HostCountry.usa,
      int capacity = 70000,
      int? worldCupCapacity,
      int? yearOpened,
      double? latitude,
      double? longitude,
      String? address,
      String? timeZone,
      int? utcOffset,
      String? imageUrl,
      String? thumbnailUrl,
      List<String> homeTeams = const [],
      List<String> sports = const [],
      String? surfaceType,
      bool hasRoof = false,
      bool retractableRoof = false,
      List<String> keyMatches = const [],
      int? matchCount,
      String? fanFestivalLocation,
      List<String> publicTransit = const [],
      String? parkingInfo,
      String? websiteUrl,
      String? description,
      DateTime? updatedAt,
    }) {
      return WorldCupVenue(
        venueId: venueId,
        name: name,
        worldCupName: worldCupName,
        city: city,
        state: state,
        country: country,
        capacity: capacity,
        worldCupCapacity: worldCupCapacity,
        yearOpened: yearOpened,
        latitude: latitude,
        longitude: longitude,
        address: address,
        timeZone: timeZone,
        utcOffset: utcOffset,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        homeTeams: homeTeams,
        sports: sports,
        surfaceType: surfaceType,
        hasRoof: hasRoof,
        retractableRoof: retractableRoof,
        keyMatches: keyMatches,
        matchCount: matchCount,
        fanFestivalLocation: fanFestivalLocation,
        publicTransit: publicTransit,
        parkingInfo: parkingInfo,
        websiteUrl: websiteUrl,
        description: description,
        updatedAt: updatedAt,
      );
    }

    group('Constructor', () {
      test('creates venue with required fields', () {
        final venue = createTestVenue();

        expect(venue.venueId, equals('venue_1'));
        expect(venue.name, equals('Test Stadium'));
        expect(venue.city, equals('Test City'));
        expect(venue.country, equals(HostCountry.usa));
        expect(venue.capacity, equals(70000));
      });

      test('creates venue with all fields', () {
        final venue = createTestVenue(
          worldCupName: 'FIFA Test Stadium',
          state: 'California',
          worldCupCapacity: 75000,
          yearOpened: 2020,
          latitude: 34.0522,
          longitude: -118.2437,
          address: '123 Main St',
          timeZone: 'America/Los_Angeles',
          utcOffset: -8,
          imageUrl: 'https://example.com/image.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          homeTeams: ['LA Rams', 'LA Chargers'],
          sports: ['Football', 'Soccer'],
          surfaceType: 'Natural grass',
          hasRoof: true,
          retractableRoof: true,
          keyMatches: ['Final', 'Semi-Final'],
          matchCount: 8,
          fanFestivalLocation: 'Downtown Plaza',
          publicTransit: ['Metro', 'Bus'],
          parkingInfo: 'On-site parking available',
          websiteUrl: 'https://stadium.com',
          description: 'A beautiful stadium',
        );

        expect(venue.worldCupName, equals('FIFA Test Stadium'));
        expect(venue.state, equals('California'));
        expect(venue.worldCupCapacity, equals(75000));
        expect(venue.yearOpened, equals(2020));
        expect(venue.latitude, equals(34.0522));
        expect(venue.longitude, equals(-118.2437));
        expect(venue.homeTeams, hasLength(2));
        expect(venue.sports, hasLength(2));
        expect(venue.hasRoof, isTrue);
        expect(venue.retractableRoof, isTrue);
        expect(venue.keyMatches, hasLength(2));
      });
    });

    group('Computed getters', () {
      test('displayName returns worldCupName when available', () {
        final venue = createTestVenue(
          name: 'MetLife Stadium',
          worldCupName: 'New York New Jersey Stadium',
        );
        expect(venue.displayName, equals('New York New Jersey Stadium'));
      });

      test('displayName returns name when worldCupName is null', () {
        final venue = createTestVenue(name: 'Hard Rock Stadium');
        expect(venue.displayName, equals('Hard Rock Stadium'));
      });

      test('fullLocation includes state when available', () {
        final venue = createTestVenue(
          city: 'Arlington',
          state: 'Texas',
          country: HostCountry.usa,
        );
        expect(venue.fullLocation, equals('Arlington, Texas, United States'));
      });

      test('fullLocation excludes state when null', () {
        final venue = createTestVenue(
          city: 'Mexico City',
          state: null,
          country: HostCountry.mexico,
        );
        expect(venue.fullLocation, equals('Mexico City, Mexico'));
      });

      test('effectiveCapacity returns worldCupCapacity when available', () {
        final venue = createTestVenue(
          capacity: 80000,
          worldCupCapacity: 92000,
        );
        expect(venue.effectiveCapacity, equals(92000));
      });

      test('effectiveCapacity returns capacity when worldCupCapacity is null', () {
        final venue = createTestVenue(capacity: 80000);
        expect(venue.effectiveCapacity, equals(80000));
      });

      test('hasKeyMatch returns true when keyMatches is not empty', () {
        final venue = createTestVenue(keyMatches: ['Final']);
        expect(venue.hasKeyMatch, isTrue);
      });

      test('hasKeyMatch returns false when keyMatches is empty', () {
        final venue = createTestVenue(keyMatches: []);
        expect(venue.hasKeyMatch, isFalse);
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final venue = createTestVenue(
          name: 'Test Stadium',
          worldCupName: 'FIFA Test',
          state: 'TX',
          homeTeams: ['Team A'],
          keyMatches: ['Final'],
        );
        final map = venue.toMap();

        expect(map['venueId'], equals('venue_1'));
        expect(map['name'], equals('Test Stadium'));
        expect(map['worldCupName'], equals('FIFA Test'));
        expect(map['city'], equals('Test City'));
        expect(map['state'], equals('TX'));
        expect(map['country'], equals('usa'));
        expect(map['capacity'], equals(70000));
        expect(map['homeTeams'], equals(['Team A']));
        expect(map['keyMatches'], equals(['Final']));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'venueId': 'v_test',
          'name': 'Azteca',
          'city': 'Mexico City',
          'country': 'mexico',
          'capacity': 87000,
          'worldCupCapacity': 90000,
          'yearOpened': 1966,
          'hasRoof': false,
          'keyMatches': ['Opening Match'],
          'homeTeams': ['Club America', 'Cruz Azul'],
          'sports': ['Soccer'],
        };

        final venue = WorldCupVenue.fromMap(map);

        expect(venue.venueId, equals('v_test'));
        expect(venue.name, equals('Azteca'));
        expect(venue.country, equals(HostCountry.mexico));
        expect(venue.capacity, equals(87000));
        expect(venue.worldCupCapacity, equals(90000));
        expect(venue.yearOpened, equals(1966));
        expect(venue.homeTeams, hasLength(2));
        expect(venue.keyMatches, hasLength(1));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestVenue(
          name: 'SoFi Stadium',
          worldCupName: 'Los Angeles Stadium',
          state: 'California',
          worldCupCapacity: 75000,
          latitude: 33.9534,
          longitude: -118.3390,
          hasRoof: true,
          retractableRoof: true,
          homeTeams: ['Rams', 'Chargers'],
          keyMatches: ['Quarter-Final'],
        );
        final map = original.toMap();
        final restored = WorldCupVenue.fromMap(map);

        expect(restored.venueId, equals(original.venueId));
        expect(restored.name, equals(original.name));
        expect(restored.worldCupName, equals(original.worldCupName));
        expect(restored.country, equals(original.country));
        expect(restored.hasRoof, equals(original.hasRoof));
        expect(restored.homeTeams, equals(original.homeTeams));
        expect(restored.keyMatches, equals(original.keyMatches));
      });

      test('fromMap handles missing optional fields', () {
        final map = <String, dynamic>{
          'venueId': 'v_min',
          'name': 'Minimal Stadium',
          'city': 'City',
          'country': 'usa',
          'capacity': 50000,
        };

        final venue = WorldCupVenue.fromMap(map);

        expect(venue.venueId, equals('v_min'));
        expect(venue.worldCupName, isNull);
        expect(venue.state, isNull);
        expect(venue.worldCupCapacity, isNull);
        expect(venue.homeTeams, isEmpty);
        expect(venue.keyMatches, isEmpty);
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes correctly', () {
        final venue = createTestVenue(
          name: 'Test Stadium',
          state: 'TX',
          homeTeams: ['Team A'],
        );
        final data = venue.toFirestore();

        expect(data['name'], equals('Test Stadium'));
        expect(data['state'], equals('TX'));
        expect(data['country'], equals('usa'));
        expect(data['homeTeams'], equals(['Team A']));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'name': 'BC Place',
          'city': 'Vancouver',
          'state': 'British Columbia',
          'country': 'canada',
          'capacity': 54500,
          'hasRoof': true,
          'retractableRoof': true,
          'homeTeams': ['Whitecaps', 'BC Lions'],
          'sports': ['Soccer', 'CFL'],
        };

        final venue = WorldCupVenue.fromFirestore(data, 'bc_place');

        expect(venue.venueId, equals('bc_place'));
        expect(venue.name, equals('BC Place'));
        expect(venue.country, equals(HostCountry.canada));
        expect(venue.hasRoof, isTrue);
        expect(venue.retractableRoof, isTrue);
        expect(venue.homeTeams, hasLength(2));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestVenue(name: 'Original');
        final updated = original.copyWith(
          name: 'Updated',
          capacity: 80000,
          hasRoof: true,
        );

        expect(updated.name, equals('Updated'));
        expect(updated.capacity, equals(80000));
        expect(updated.hasRoof, isTrue);
        expect(updated.venueId, equals(original.venueId));
        expect(updated.city, equals(original.city));
      });

      test('preserves unchanged fields', () {
        final original = createTestVenue(
          name: 'Stadium',
          state: 'TX',
          homeTeams: ['Team A', 'Team B'],
          keyMatches: ['Final'],
        );
        final updated = original.copyWith(capacity: 90000);

        expect(updated.name, equals('Stadium'));
        expect(updated.state, equals('TX'));
        expect(updated.homeTeams, equals(['Team A', 'Team B']));
        expect(updated.keyMatches, equals(['Final']));
      });
    });

    group('Host country parsing', () {
      test('parses USA variations', () {
        final usaMap = {'country': 'usa', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};
        final unitedStatesMap = {'country': 'united states', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};
        final americaMap = {'country': 'america', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};

        expect(WorldCupVenue.fromMap(usaMap).country, equals(HostCountry.usa));
        expect(WorldCupVenue.fromMap(unitedStatesMap).country, equals(HostCountry.usa));
        expect(WorldCupVenue.fromMap(americaMap).country, equals(HostCountry.usa));
      });

      test('parses Mexico variations', () {
        final mexMap = {'country': 'mex', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};
        final mexicoMap = {'country': 'mexico', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};

        expect(WorldCupVenue.fromMap(mexMap).country, equals(HostCountry.mexico));
        expect(WorldCupVenue.fromMap(mexicoMap).country, equals(HostCountry.mexico));
      });

      test('parses Canada variations', () {
        final canMap = {'country': 'can', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};
        final canadaMap = {'country': 'canada', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};

        expect(WorldCupVenue.fromMap(canMap).country, equals(HostCountry.canada));
        expect(WorldCupVenue.fromMap(canadaMap).country, equals(HostCountry.canada));
      });

      test('defaults to USA for unknown country', () {
        final unknownMap = {'country': 'unknownXYZ', 'name': '', 'city': '', 'venueId': '', 'capacity': 0};
        final nullMap = {'name': '', 'city': '', 'venueId': '', 'capacity': 0};

        expect(WorldCupVenue.fromMap(unknownMap).country, equals(HostCountry.usa));
        expect(WorldCupVenue.fromMap(nullMap).country, equals(HostCountry.usa));
      });
    });

    group('Equatable', () {
      test('two venues with same props are equal', () {
        final venue1 = createTestVenue();
        final venue2 = createTestVenue();

        expect(venue1, equals(venue2));
      });

      test('two venues with different venueId are not equal', () {
        final venue1 = createTestVenue(venueId: 'v1');
        final venue2 = createTestVenue(venueId: 'v2');

        expect(venue1, isNot(equals(venue2)));
      });

      test('props contains expected fields', () {
        final venue = createTestVenue();
        expect(venue.props, hasLength(4));
        expect(venue.props, contains(venue.venueId));
        expect(venue.props, contains(venue.name));
        expect(venue.props, contains(venue.city));
        expect(venue.props, contains(venue.country));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final venue = createTestVenue(
          name: 'MetLife Stadium',
          city: 'East Rutherford',
        );
        expect(venue.toString(), equals('MetLife Stadium (East Rutherford)'));
      });
    });
  });

  group('WorldCupVenues', () {
    test('all contains expected number of venues', () {
      // 11 USA + 3 Mexico + 2 Canada = 16 venues
      expect(WorldCupVenues.all, hasLength(16));
    });

    test('getById returns correct venue', () {
      final metlife = WorldCupVenues.getById('metlife');
      expect(metlife, isNotNull);
      expect(metlife!.name, equals('MetLife Stadium'));
      expect(metlife.country, equals(HostCountry.usa));
    });

    test('getById returns null for unknown ID', () {
      final unknown = WorldCupVenues.getById('nonexistent');
      expect(unknown, isNull);
    });

    test('getByCountry returns correct venues', () {
      final usaVenues = WorldCupVenues.getByCountry(HostCountry.usa);
      final mexicoVenues = WorldCupVenues.getByCountry(HostCountry.mexico);
      final canadaVenues = WorldCupVenues.getByCountry(HostCountry.canada);

      expect(usaVenues, hasLength(11));
      expect(mexicoVenues, hasLength(3));
      expect(canadaVenues, hasLength(2));

      for (final v in usaVenues) {
        expect(v.country, equals(HostCountry.usa));
      }
      for (final v in mexicoVenues) {
        expect(v.country, equals(HostCountry.mexico));
      }
      for (final v in canadaVenues) {
        expect(v.country, equals(HostCountry.canada));
      }
    });

    test('getKeyMatchVenues returns venues with key matches', () {
      final keyVenues = WorldCupVenues.getKeyMatchVenues();
      expect(keyVenues.isNotEmpty, isTrue);
      for (final v in keyVenues) {
        expect(v.hasKeyMatch, isTrue);
      }
    });

    test('predefined venues have required fields', () {
      for (final venue in WorldCupVenues.all) {
        expect(venue.venueId.isNotEmpty, isTrue);
        expect(venue.name.isNotEmpty, isTrue);
        expect(venue.city.isNotEmpty, isTrue);
        expect(venue.capacity, greaterThan(0));
      }
    });

    test('MetLife is the Final venue', () {
      final metlife = WorldCupVenues.getById('metlife');
      expect(metlife!.keyMatches, contains('Final'));
    });

    test('Azteca has the Opening Match', () {
      final azteca = WorldCupVenues.getById('azteca');
      expect(azteca!.keyMatches, contains('Opening Match'));
    });
  });
}
