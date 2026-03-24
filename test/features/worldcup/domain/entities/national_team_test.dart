import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/national_team.dart';

void main() {
  group('Confederation', () {
    test('has expected values', () {
      expect(Confederation.values, hasLength(6));
      expect(Confederation.values, contains(Confederation.uefa));
      expect(Confederation.values, contains(Confederation.conmebol));
      expect(Confederation.values, contains(Confederation.concacaf));
      expect(Confederation.values, contains(Confederation.afc));
      expect(Confederation.values, contains(Confederation.caf));
      expect(Confederation.values, contains(Confederation.ofc));
    });
  });

  group('ConfederationExtension', () {
    test('displayName returns correct values', () {
      expect(Confederation.uefa.displayName, equals('UEFA'));
      expect(Confederation.conmebol.displayName, equals('CONMEBOL'));
      expect(Confederation.concacaf.displayName, equals('CONCACAF'));
      expect(Confederation.afc.displayName, equals('AFC'));
      expect(Confederation.caf.displayName, equals('CAF'));
      expect(Confederation.ofc.displayName, equals('OFC'));
    });

    test('fullName returns correct values', () {
      expect(Confederation.uefa.fullName,
          equals('Union of European Football Associations'));
      expect(Confederation.conmebol.fullName,
          equals('South American Football Confederation'));
      expect(Confederation.concacaf.fullName,
          equals('Confederation of North, Central America and Caribbean Association Football'));
      expect(Confederation.afc.fullName,
          equals('Asian Football Confederation'));
      expect(Confederation.caf.fullName,
          equals('Confederation of African Football'));
      expect(Confederation.ofc.fullName,
          equals('Oceania Football Confederation'));
    });
  });

  group('NationalTeam', () {
    NationalTeam createTestTeam({
      String teamCode = 'USA',
      String countryName = 'United States',
      String shortName = 'USA',
      String flagUrl = 'https://example.com/flags/usa.png',
      String? federationLogoUrl,
      Confederation confederation = Confederation.concacaf,
      int? worldRanking = 11,
      String? coachName,
      String? primaryColor,
      String? secondaryColor,
      String? group,
      int worldCupTitles = 0,
      String? bestFinish,
      int worldCupAppearances = 11,
      bool isHostNation = true,
      String? nickname,
      String? homeStadium,
      String? captainName,
      List<String> starPlayers = const [],
      String? qualificationMethod,
      bool isQualified = true,
      DateTime? updatedAt,
    }) {
      return NationalTeam(
        teamCode: teamCode,
        countryName: countryName,
        shortName: shortName,
        flagUrl: flagUrl,
        federationLogoUrl: federationLogoUrl,
        confederation: confederation,
        worldRanking: worldRanking,
        coachName: coachName,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        group: group,
        worldCupTitles: worldCupTitles,
        bestFinish: bestFinish,
        worldCupAppearances: worldCupAppearances,
        isHostNation: isHostNation,
        nickname: nickname,
        homeStadium: homeStadium,
        captainName: captainName,
        starPlayers: starPlayers,
        qualificationMethod: qualificationMethod,
        isQualified: isQualified,
        updatedAt: updatedAt,
      );
    }

    group('Constructor', () {
      test('creates team with required fields', () {
        final team = createTestTeam();

        expect(team.teamCode, equals('USA'));
        expect(team.countryName, equals('United States'));
        expect(team.shortName, equals('USA'));
        expect(team.flagUrl, equals('https://example.com/flags/usa.png'));
        expect(team.confederation, equals(Confederation.concacaf));
        expect(team.worldRanking, equals(11));
        expect(team.isHostNation, isTrue);
        expect(team.isQualified, isTrue);
      });

      test('creates team with optional fields', () {
        final now = DateTime(2024, 10, 15);
        final team = createTestTeam(
          federationLogoUrl: 'https://example.com/logo.png',
          group: 'A',
          bestFinish: 'Semi-finals',
          nickname: 'USMNT',
          coachName: 'Gregg Berhalter',
          primaryColor: '#1F3C6E',
          secondaryColor: '#FFFFFF',
          starPlayers: ['Christian Pulisic', 'Weston McKennie'],
          homeStadium: 'BMO Stadium',
          captainName: 'Christian Pulisic',
          qualificationMethod: 'Host',
          updatedAt: now,
        );

        expect(team.federationLogoUrl, equals('https://example.com/logo.png'));
        expect(team.group, equals('A'));
        expect(team.bestFinish, equals('Semi-finals'));
        expect(team.nickname, equals('USMNT'));
        expect(team.coachName, equals('Gregg Berhalter'));
        expect(team.primaryColor, equals('#1F3C6E'));
        expect(team.secondaryColor, equals('#FFFFFF'));
        expect(team.starPlayers, equals(['Christian Pulisic', 'Weston McKennie']));
        expect(team.homeStadium, equals('BMO Stadium'));
        expect(team.captainName, equals('Christian Pulisic'));
        expect(team.qualificationMethod, equals('Host'));
        expect(team.updatedAt, equals(now));
      });

      test('creates teams with different confederations', () {
        final uefaTeam = createTestTeam(
          teamCode: 'FRA',
          countryName: 'France',
          shortName: 'France',
          confederation: Confederation.uefa,
        );
        final conmebolTeam = createTestTeam(
          teamCode: 'ARG',
          countryName: 'Argentina',
          shortName: 'Argentina',
          confederation: Confederation.conmebol,
        );
        final afcTeam = createTestTeam(
          teamCode: 'JPN',
          countryName: 'Japan',
          shortName: 'Japan',
          confederation: Confederation.afc,
        );
        final cafTeam = createTestTeam(
          teamCode: 'MAR',
          countryName: 'Morocco',
          shortName: 'Morocco',
          confederation: Confederation.caf,
        );
        final ofcTeam = createTestTeam(
          teamCode: 'NZL',
          countryName: 'New Zealand',
          shortName: 'New Zealand',
          confederation: Confederation.ofc,
        );

        expect(uefaTeam.confederation, equals(Confederation.uefa));
        expect(conmebolTeam.confederation, equals(Confederation.conmebol));
        expect(afcTeam.confederation, equals(Confederation.afc));
        expect(cafTeam.confederation, equals(Confederation.caf));
        expect(ofcTeam.confederation, equals(Confederation.ofc));
      });

      test('creates team with default values', () {
        const team = NationalTeam(
          teamCode: 'TST',
          countryName: 'Test Country',
          shortName: 'Test',
          flagUrl: 'https://example.com/flag.png',
          confederation: Confederation.uefa,
        );

        expect(team.worldCupTitles, equals(0));
        expect(team.worldCupAppearances, equals(0));
        expect(team.isHostNation, isFalse);
        expect(team.starPlayers, isEmpty);
        expect(team.isQualified, isFalse);
      });
    });

    group('flagEmoji', () {
      test('returns correct emoji for standard country codes', () {
        final brazil = createTestTeam(teamCode: 'BRA', countryName: 'Brazil', shortName: 'Brazil');
        final argentina = createTestTeam(teamCode: 'ARG', countryName: 'Argentina', shortName: 'Argentina');

        // Brazil: BRA -> BR (standard, uses first 2 letters)
        expect(brazil.flagEmoji, equals('🇧🇷'));
        // Argentina: ARG -> AR (standard, uses first 2 letters)
        expect(argentina.flagEmoji, equals('🇦🇷'));
      });

      test('handles special FIFA code mappings', () {
        final usa = createTestTeam(teamCode: 'USA', countryName: 'United States', shortName: 'USA');
        final germany = createTestTeam(teamCode: 'GER', countryName: 'Germany', shortName: 'Germany');
        final netherlands = createTestTeam(teamCode: 'NED', countryName: 'Netherlands', shortName: 'Netherlands');
        final switzerland = createTestTeam(teamCode: 'SUI', countryName: 'Switzerland', shortName: 'Switzerland');
        final portugal = createTestTeam(teamCode: 'POR', countryName: 'Portugal', shortName: 'Portugal');

        expect(usa.flagEmoji, equals('🇺🇸'));
        expect(germany.flagEmoji, equals('🇩🇪'));
        expect(netherlands.flagEmoji, equals('🇳🇱'));
        expect(switzerland.flagEmoji, equals('🇨🇭'));
        expect(portugal.flagEmoji, equals('🇵🇹'));
      });

      test('returns flag for host nations', () {
        final usa = createTestTeam(teamCode: 'USA', countryName: 'United States', shortName: 'USA');
        final canada = createTestTeam(teamCode: 'CAN', countryName: 'Canada', shortName: 'Canada');

        expect(usa.flagEmoji, equals('🇺🇸'));
        expect(canada.flagEmoji, equals('🇨🇦'));
        // Note: MEX is not in special mappings, so it uses first 2 letters which maps to ME (Montenegro)
      });

      test('handles Asian countries', () {
        final japan = createTestTeam(teamCode: 'JPN', countryName: 'Japan', shortName: 'Japan');
        final korea = createTestTeam(teamCode: 'KOR', countryName: 'South Korea', shortName: 'Korea');
        final iran = createTestTeam(teamCode: 'IRN', countryName: 'Iran', shortName: 'Iran');
        final saudiArabia = createTestTeam(teamCode: 'KSA', countryName: 'Saudi Arabia', shortName: 'Saudi Arabia');

        expect(japan.flagEmoji, equals('🇯🇵'));
        expect(korea.flagEmoji, equals('🇰🇷'));
        expect(iran.flagEmoji, equals('🇮🇷'));
        expect(saudiArabia.flagEmoji, equals('🇸🇦'));
      });

      test('handles South American countries', () {
        final uruguay = createTestTeam(teamCode: 'URU', countryName: 'Uruguay', shortName: 'Uruguay');
        final colombia = createTestTeam(teamCode: 'COL', countryName: 'Colombia', shortName: 'Colombia');
        final chile = createTestTeam(teamCode: 'CHI', countryName: 'Chile', shortName: 'Chile');

        expect(uruguay.flagEmoji, equals('🇺🇾'));
        expect(colombia.flagEmoji, equals('🇨🇴'));
        expect(chile.flagEmoji, equals('🇨🇱'));
      });

      test('handles African countries', () {
        final morocco = createTestTeam(teamCode: 'MAR', countryName: 'Morocco', shortName: 'Morocco');
        final nigeria = createTestTeam(teamCode: 'NGA', countryName: 'Nigeria', shortName: 'Nigeria');
        final senegal = createTestTeam(teamCode: 'SEN', countryName: 'Senegal', shortName: 'Senegal');
        final cameroon = createTestTeam(teamCode: 'CMR', countryName: 'Cameroon', shortName: 'Cameroon');

        expect(morocco.flagEmoji, equals('🇲🇦'));
        expect(nigeria.flagEmoji, equals('🇳🇬'));
        expect(senegal.flagEmoji, equals('🇸🇳'));
        expect(cameroon.flagEmoji, equals('🇨🇲'));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestTeam();
        final updated = original.copyWith(
          worldRanking: 5,
          isQualified: true,
          group: 'B',
        );

        expect(updated.worldRanking, equals(5));
        expect(updated.isQualified, isTrue);
        expect(updated.group, equals('B'));
        expect(updated.teamCode, equals(original.teamCode));
      });

      test('preserves unchanged fields', () {
        final original = createTestTeam(
          nickname: 'USMNT',
          coachName: 'Coach Name',
          starPlayers: ['Player 1', 'Player 2'],
        );
        final updated = original.copyWith(worldRanking: 10);

        expect(updated.nickname, equals('USMNT'));
        expect(updated.coachName, equals('Coach Name'));
        expect(updated.starPlayers, equals(['Player 1', 'Player 2']));
      });

      test('updates all fields when provided', () {
        final original = createTestTeam();
        final newTime = DateTime.now();
        final updated = original.copyWith(
          teamCode: 'NEW',
          countryName: 'New Country',
          shortName: 'New',
          flagUrl: 'https://new.com/flag.png',
          federationLogoUrl: 'https://new.com/logo.png',
          confederation: Confederation.uefa,
          worldRanking: 1,
          coachName: 'New Coach',
          primaryColor: '#FF0000',
          secondaryColor: '#0000FF',
          group: 'A',
          worldCupTitles: 5,
          bestFinish: 'Winner',
          worldCupAppearances: 20,
          isHostNation: false,
          nickname: 'The New',
          homeStadium: 'New Stadium',
          captainName: 'New Captain',
          starPlayers: ['Star 1'],
          qualificationMethod: 'Qualifier',
          isQualified: true,
          updatedAt: newTime,
        );

        expect(updated.teamCode, equals('NEW'));
        expect(updated.countryName, equals('New Country'));
        expect(updated.worldCupTitles, equals(5));
        expect(updated.bestFinish, equals('Winner'));
        expect(updated.updatedAt, equals(newTime));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final team = createTestTeam(
          group: 'A',
          nickname: 'USMNT',
          starPlayers: ['Pulisic', 'McKennie'],
        );
        final map = team.toMap();

        expect(map['teamCode'], equals('USA'));
        expect(map['countryName'], equals('United States'));
        expect(map['shortName'], equals('USA'));
        expect(map['confederation'], equals('concacaf'));
        expect(map['worldRanking'], equals(11));
        expect(map['group'], equals('A'));
        expect(map['worldCupAppearances'], equals(11));
        expect(map['worldCupTitles'], equals(0));
        expect(map['isHostNation'], isTrue);
        expect(map['isQualified'], isTrue);
        expect(map['nickname'], equals('USMNT'));
        expect(map['starPlayers'], equals(['Pulisic', 'McKennie']));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'teamCode': 'FRA',
          'countryName': 'France',
          'shortName': 'France',
          'flagUrl': 'https://example.com/france.png',
          'confederation': 'uefa',
          'worldRanking': 2,
          'group': 'D',
          'worldCupAppearances': 16,
          'worldCupTitles': 2,
          'bestFinish': 'Winner',
          'isHostNation': false,
          'isQualified': true,
          'nickname': 'Les Bleus',
          'coachName': 'Didier Deschamps',
          'starPlayers': ['Mbappe', 'Griezmann'],
        };

        final team = NationalTeam.fromMap(map);

        expect(team.teamCode, equals('FRA'));
        expect(team.countryName, equals('France'));
        expect(team.confederation, equals(Confederation.uefa));
        expect(team.worldRanking, equals(2));
        expect(team.worldCupTitles, equals(2));
        expect(team.nickname, equals('Les Bleus'));
        expect(team.starPlayers, equals(['Mbappe', 'Griezmann']));
      });

      test('fromMap handles missing optional fields', () {
        final map = {
          'teamCode': 'TST',
          'countryName': 'Test Country',
          'shortName': 'Test',
          'flagUrl': '',
          'confederation': 'uefa',
        };

        final team = NationalTeam.fromMap(map);

        expect(team.group, isNull);
        expect(team.bestFinish, isNull);
        expect(team.nickname, isNull);
        expect(team.coachName, isNull);
        expect(team.starPlayers, isEmpty);
        expect(team.worldRanking, isNull);
        expect(team.isHostNation, isFalse);
        expect(team.isQualified, isFalse);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestTeam(
          group: 'A',
          bestFinish: 'Semi-finals',
          nickname: 'USMNT',
          starPlayers: ['Pulisic', 'McKennie', 'Reyna'],
        );
        final map = original.toMap();
        final restored = NationalTeam.fromMap(map);

        expect(restored.teamCode, equals(original.teamCode));
        expect(restored.countryName, equals(original.countryName));
        expect(restored.confederation, equals(original.confederation));
        expect(restored.group, equals(original.group));
        expect(restored.bestFinish, equals(original.bestFinish));
        expect(restored.nickname, equals(original.nickname));
        expect(restored.starPlayers, equals(original.starPlayers));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes correctly', () {
        final team = createTestTeam(
          group: 'A',
          starPlayers: ['Pulisic'],
        );
        final data = team.toFirestore();

        expect(data['teamCode'], equals('USA'));
        expect(data['countryName'], equals('United States'));
        expect(data['confederation'], equals('concacaf'));
        expect(data['isHostNation'], isTrue);
        expect(data['starPlayers'], equals(['Pulisic']));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'teamCode': 'ARG',
          'countryName': 'Argentina',
          'shortName': 'Argentina',
          'flagUrl': 'https://example.com/argentina.png',
          'confederation': 'conmebol',
          'worldRanking': 1,
          'group': 'C',
          'worldCupAppearances': 18,
          'worldCupTitles': 3,
          'bestFinish': 'Winner',
          'isHostNation': false,
          'isQualified': true,
          'nickname': 'La Albiceleste',
          'coachName': 'Lionel Scaloni',
          'starPlayers': ['Messi', 'Di Maria'],
        };

        final team = NationalTeam.fromFirestore(data, 'ARG');

        expect(team.teamCode, equals('ARG'));
        expect(team.countryName, equals('Argentina'));
        expect(team.confederation, equals(Confederation.conmebol));
        expect(team.worldCupTitles, equals(3));
        expect(team.nickname, equals('La Albiceleste'));
      });

      test('fromFirestore uses docId as fallback teamCode', () {
        final data = {
          'countryName': 'Test',
          'shortName': 'Test',
          'flagUrl': '',
          'confederation': 'uefa',
        };

        final team = NationalTeam.fromFirestore(data, 'TST');
        expect(team.teamCode, equals('TST'));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'teamCode': 'NEW',
          'countryName': 'New Team',
          'shortName': 'New',
          'flagUrl': '',
          'confederation': 'ofc',
        };

        final team = NationalTeam.fromFirestore(data, 'NEW');

        expect(team.group, isNull);
        expect(team.starPlayers, isEmpty);
        expect(team.coachName, isNull);
        expect(team.isHostNation, isFalse);
        expect(team.isQualified, isFalse);
      });
    });

    group('API serialization', () {
      test('fromApi deserializes correctly with Key field', () {
        final apiData = {
          'Key': 'BRA',
          'FullName': 'Brazil',
          'ShortName': 'Brazil',
          'WikipediaLogoUrl': 'https://wikipedia.org/brazil.png',
          'AreaName': 'South America',
          'GlobalTeamRanking': 5,
        };

        final team = NationalTeam.fromApi(apiData);

        expect(team.teamCode, equals('BRA'));
        expect(team.countryName, equals('Brazil'));
        expect(team.shortName, equals('Brazil'));
        expect(team.flagUrl, equals('https://wikipedia.org/brazil.png'));
        expect(team.confederation, equals(Confederation.conmebol));
        expect(team.worldRanking, equals(5));
        expect(team.isQualified, isTrue);
      });

      test('fromApi handles Name fallback', () {
        final apiData = {
          'TeamId': 123,
          'Name': 'Germany',
          'AreaName': 'Europe',
        };

        final team = NationalTeam.fromApi(apiData);

        expect(team.teamCode, equals('123'));
        expect(team.countryName, equals('Germany'));
        expect(team.shortName, equals('Germany'));
        expect(team.confederation, equals(Confederation.uefa));
      });

      test('fromApi handles FlagUrl fallback', () {
        final apiData = {
          'Key': 'ARG',
          'FullName': 'Argentina',
          'FlagUrl': 'https://flags.com/arg.png',
          'AreaName': 'South America',
        };

        final team = NationalTeam.fromApi(apiData);
        expect(team.flagUrl, equals('https://flags.com/arg.png'));
      });

      test('fromApi handles coach data', () {
        final apiData = {
          'Key': 'ESP',
          'FullName': 'Spain',
          'AreaName': 'Europe',
          'Coach': {'Name': 'Luis de la Fuente'},
        };

        final team = NationalTeam.fromApi(apiData);
        expect(team.coachName, equals('Luis de la Fuente'));
      });

      test('fromApi parses different area names', () {
        expect(NationalTeam.fromApi(const {'Key': 'A', 'Name': 'A', 'AreaName': 'Europe'})
            .confederation, equals(Confederation.uefa));
        expect(NationalTeam.fromApi(const {'Key': 'B', 'Name': 'B', 'AreaName': 'South America'})
            .confederation, equals(Confederation.conmebol));
        expect(NationalTeam.fromApi(const {'Key': 'C', 'Name': 'C', 'AreaName': 'North America'})
            .confederation, equals(Confederation.concacaf));
        expect(NationalTeam.fromApi(const {'Key': 'D', 'Name': 'D', 'AreaName': 'Asia'})
            .confederation, equals(Confederation.afc));
        expect(NationalTeam.fromApi(const {'Key': 'E', 'Name': 'E', 'AreaName': 'Africa'})
            .confederation, equals(Confederation.caf));
        expect(NationalTeam.fromApi(const {'Key': 'F', 'Name': 'F', 'AreaName': 'Oceania'})
            .confederation, equals(Confederation.ofc));
      });
    });

    group('Confederation parsing', () {
      test('parses confederation strings with contains logic', () {
        final testCases = {
          'uefa': Confederation.uefa,
          'CONMEBOL': Confederation.conmebol,
          'concacaf': Confederation.concacaf,
          'AFC': Confederation.afc,
          'caf': Confederation.caf,
          'OFC': Confederation.ofc,
          'Europe': Confederation.uefa,
          'south america': Confederation.conmebol,
          'Central America': Confederation.concacaf,
          'asia': Confederation.afc,
          'AFRICA': Confederation.caf,
          'oceania': Confederation.ofc,
        };

        for (final entry in testCases.entries) {
          final map = {
            'teamCode': 'TST',
            'countryName': 'Test',
            'shortName': 'Test',
            'flagUrl': '',
            'confederation': entry.key,
          };
          final team = NationalTeam.fromMap(map);
          expect(team.confederation, equals(entry.value),
              reason: '${entry.key} should parse to ${entry.value}');
        }
      });

      test('defaults to uefa for unknown confederation', () {
        final map = {
          'teamCode': 'TST',
          'countryName': 'Test',
          'shortName': 'Test',
          'flagUrl': '',
          'confederation': 'unknownConfederation',
        };
        final team = NationalTeam.fromMap(map);
        expect(team.confederation, equals(Confederation.uefa));
      });

      test('defaults to uefa for null confederation', () {
        final map = {
          'teamCode': 'TST',
          'countryName': 'Test',
          'shortName': 'Test',
          'flagUrl': '',
          'confederation': null,
        };
        final team = NationalTeam.fromMap(map);
        expect(team.confederation, equals(Confederation.uefa));
      });
    });

    group('Equatable', () {
      test('two teams with same props are equal', () {
        final team1 = createTestTeam();
        final team2 = createTestTeam();

        expect(team1, equals(team2));
      });

      test('two teams with different teamCode are not equal', () {
        final team1 = createTestTeam(teamCode: 'USA');
        final team2 = createTestTeam(teamCode: 'MEX');

        expect(team1, isNot(equals(team2)));
      });

      test('two teams with different ranking are not equal', () {
        final team1 = createTestTeam(worldRanking: 1);
        final team2 = createTestTeam(worldRanking: 2);

        expect(team1, isNot(equals(team2)));
      });

      test('props contains expected fields', () {
        final team = createTestTeam();
        expect(team.props, hasLength(8));
        expect(team.props, contains(team.teamCode));
        expect(team.props, contains(team.countryName));
        expect(team.props, contains(team.shortName));
        expect(team.props, contains(team.confederation));
        expect(team.props, contains(team.worldRanking));
        expect(team.props, contains(team.group));
        expect(team.props, contains(team.isQualified));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final team = createTestTeam(
          teamCode: 'ARG',
          shortName: 'Argentina',
        );
        expect(team.toString(), equals('Argentina (ARG)'));
      });
    });
  });
}
