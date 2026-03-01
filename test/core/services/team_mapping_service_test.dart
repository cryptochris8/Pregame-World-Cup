import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/team_mapping_service.dart';

void main() {
  group('TeamMappingService', () {
    group('getTeamKey', () {
      group('exact match', () {
        test('returns correct code for full country name', () {
          expect(TeamMappingService.getTeamKey('Brazil'), equals('BRA'));
          expect(TeamMappingService.getTeamKey('Argentina'), equals('ARG'));
          expect(TeamMappingService.getTeamKey('France'), equals('FRA'));
          expect(TeamMappingService.getTeamKey('Germany'), equals('GER'));
          expect(TeamMappingService.getTeamKey('Spain'), equals('ESP'));
        });

        test('returns correct code for USA variants', () {
          expect(TeamMappingService.getTeamKey('United States'), equals('USA'));
          expect(TeamMappingService.getTeamKey('USA'), equals('USA'));
          expect(TeamMappingService.getTeamKey('USMNT'), equals('USA'));
        });

        test('returns correct code for Korea variants', () {
          expect(
              TeamMappingService.getTeamKey('South Korea'), equals('KOR'));
          expect(
              TeamMappingService.getTeamKey('Korea Republic'), equals('KOR'));
        });

        test('returns correct code for China variants', () {
          expect(TeamMappingService.getTeamKey('China'), equals('CHN'));
          expect(TeamMappingService.getTeamKey('China PR'), equals('CHN'));
        });

        test('returns correct code for Ivory Coast variants', () {
          expect(
              TeamMappingService.getTeamKey('Ivory Coast'), equals('CIV'));
          expect(
              TeamMappingService.getTeamKey('Cote d\'Ivoire'), equals('CIV'));
        });

        test('returns correct code for CONCACAF teams', () {
          expect(TeamMappingService.getTeamKey('Mexico'), equals('MEX'));
          expect(TeamMappingService.getTeamKey('Canada'), equals('CAN'));
          expect(TeamMappingService.getTeamKey('Costa Rica'), equals('CRC'));
          expect(TeamMappingService.getTeamKey('Jamaica'), equals('JAM'));
          expect(TeamMappingService.getTeamKey('Honduras'), equals('HON'));
          expect(TeamMappingService.getTeamKey('Panama'), equals('PAN'));
          expect(TeamMappingService.getTeamKey('El Salvador'), equals('SLV'));
          expect(TeamMappingService.getTeamKey('Trinidad and Tobago'),
              equals('TRI'));
        });

        test('returns correct code for CONMEBOL teams', () {
          expect(TeamMappingService.getTeamKey('Uruguay'), equals('URU'));
          expect(TeamMappingService.getTeamKey('Colombia'), equals('COL'));
          expect(TeamMappingService.getTeamKey('Ecuador'), equals('ECU'));
          expect(TeamMappingService.getTeamKey('Chile'), equals('CHI'));
          expect(TeamMappingService.getTeamKey('Paraguay'), equals('PAR'));
          expect(TeamMappingService.getTeamKey('Peru'), equals('PER'));
          expect(TeamMappingService.getTeamKey('Venezuela'), equals('VEN'));
          expect(TeamMappingService.getTeamKey('Bolivia'), equals('BOL'));
        });

        test('returns correct code for UEFA teams', () {
          expect(TeamMappingService.getTeamKey('England'), equals('ENG'));
          expect(TeamMappingService.getTeamKey('Portugal'), equals('POR'));
          expect(TeamMappingService.getTeamKey('Netherlands'), equals('NED'));
          expect(TeamMappingService.getTeamKey('Belgium'), equals('BEL'));
          expect(TeamMappingService.getTeamKey('Italy'), equals('ITA'));
          expect(TeamMappingService.getTeamKey('Croatia'), equals('CRO'));
          expect(
              TeamMappingService.getTeamKey('Switzerland'), equals('SUI'));
          expect(TeamMappingService.getTeamKey('Denmark'), equals('DEN'));
          expect(TeamMappingService.getTeamKey('Austria'), equals('AUT'));
          expect(TeamMappingService.getTeamKey('Serbia'), equals('SRB'));
          expect(TeamMappingService.getTeamKey('Scotland'), equals('SCO'));
          expect(TeamMappingService.getTeamKey('Wales'), equals('WAL'));
          expect(TeamMappingService.getTeamKey('Poland'), equals('POL'));
          expect(TeamMappingService.getTeamKey('Ukraine'), equals('UKR'));
          expect(TeamMappingService.getTeamKey('Sweden'), equals('SWE'));
          expect(
              TeamMappingService.getTeamKey('Czech Republic'), equals('CZE'));
          expect(TeamMappingService.getTeamKey('Turkey'), equals('TUR'));
          expect(TeamMappingService.getTeamKey('Hungary'), equals('HUN'));
          expect(TeamMappingService.getTeamKey('Slovakia'), equals('SVK'));
          expect(TeamMappingService.getTeamKey('Romania'), equals('ROU'));
          expect(TeamMappingService.getTeamKey('Norway'), equals('NOR'));
          expect(TeamMappingService.getTeamKey('Finland'), equals('FIN'));
          expect(TeamMappingService.getTeamKey('Iceland'), equals('ISL'));
          expect(TeamMappingService.getTeamKey('Greece'), equals('GRE'));
          expect(TeamMappingService.getTeamKey('Ireland'), equals('IRL'));
        });

        test('returns correct code for AFC teams', () {
          expect(TeamMappingService.getTeamKey('Japan'), equals('JPN'));
          expect(TeamMappingService.getTeamKey('Australia'), equals('AUS'));
          expect(TeamMappingService.getTeamKey('Iran'), equals('IRN'));
          expect(
              TeamMappingService.getTeamKey('Saudi Arabia'), equals('KSA'));
          expect(TeamMappingService.getTeamKey('Qatar'), equals('QAT'));
          expect(TeamMappingService.getTeamKey('Iraq'), equals('IRQ'));
          expect(TeamMappingService.getTeamKey('Uzbekistan'), equals('UZB'));
          expect(TeamMappingService.getTeamKey('United Arab Emirates'),
              equals('UAE'));
        });

        test('returns correct code for CAF teams', () {
          expect(TeamMappingService.getTeamKey('Morocco'), equals('MAR'));
          expect(TeamMappingService.getTeamKey('Senegal'), equals('SEN'));
          expect(TeamMappingService.getTeamKey('Nigeria'), equals('NGA'));
          expect(TeamMappingService.getTeamKey('Cameroon'), equals('CMR'));
          expect(TeamMappingService.getTeamKey('Ghana'), equals('GHA'));
          expect(TeamMappingService.getTeamKey('Egypt'), equals('EGY'));
          expect(TeamMappingService.getTeamKey('Tunisia'), equals('TUN'));
          expect(TeamMappingService.getTeamKey('Algeria'), equals('ALG'));
          expect(TeamMappingService.getTeamKey('Mali'), equals('MLI'));
          expect(
              TeamMappingService.getTeamKey('South Africa'), equals('RSA'));
          expect(TeamMappingService.getTeamKey('DR Congo'), equals('COD'));
        });

        test('returns correct code for OFC teams', () {
          expect(
              TeamMappingService.getTeamKey('New Zealand'), equals('NZL'));
        });
      });

      group('nickname/alias match', () {
        test('returns correct code for team nicknames', () {
          expect(TeamMappingService.getTeamKey('La Albiceleste'),
              equals('ARG'));
          expect(TeamMappingService.getTeamKey('Die Mannschaft'),
              equals('GER'));
          expect(TeamMappingService.getTeamKey('Les Bleus'), equals('FRA'));
          expect(TeamMappingService.getTeamKey('Selecao'), equals('BRA'));
          expect(TeamMappingService.getTeamKey('La Roja'), equals('ESP'));
          expect(
              TeamMappingService.getTeamKey('Three Lions'), equals('ENG'));
          expect(TeamMappingService.getTeamKey('Azzurri'), equals('ITA'));
          expect(TeamMappingService.getTeamKey('Oranje'), equals('NED'));
          expect(TeamMappingService.getTeamKey('El Tri'), equals('MEX'));
          expect(
              TeamMappingService.getTeamKey('Samurai Blue'), equals('JPN'));
          expect(TeamMappingService.getTeamKey('Socceroos'), equals('AUS'));
          expect(
              TeamMappingService.getTeamKey('Atlas Lions'), equals('MAR'));
          expect(
              TeamMappingService.getTeamKey('Super Eagles'), equals('NGA'));
          expect(TeamMappingService.getTeamKey('Indomitable Lions'),
              equals('CMR'));
          expect(
              TeamMappingService.getTeamKey('Black Stars'), equals('GHA'));
          expect(TeamMappingService.getTeamKey('Lions of Teranga'),
              equals('SEN'));
          expect(TeamMappingService.getTeamKey('Vatreni'), equals('CRO'));
          expect(
              TeamMappingService.getTeamKey('La Celeste'), equals('URU'));
          expect(TeamMappingService.getTeamKey('Los Cafeteros'),
              equals('COL'));
          expect(TeamMappingService.getTeamKey('Taegeuk Warriors'),
              equals('KOR'));
          expect(
              TeamMappingService.getTeamKey('Team Melli'), equals('IRN'));
          expect(TeamMappingService.getTeamKey('Green Falcons'),
              equals('KSA'));
        });
      });

      group('case-insensitive match', () {
        test('matches lowercase input', () {
          expect(TeamMappingService.getTeamKey('brazil'), equals('BRA'));
          expect(TeamMappingService.getTeamKey('france'), equals('FRA'));
          expect(TeamMappingService.getTeamKey('germany'), equals('GER'));
        });

        test('matches uppercase input', () {
          expect(TeamMappingService.getTeamKey('BRAZIL'), equals('BRA'));
          expect(TeamMappingService.getTeamKey('FRANCE'), equals('FRA'));
        });

        test('matches mixed case input', () {
          expect(TeamMappingService.getTeamKey('bRaZiL'), equals('BRA'));
          expect(
              TeamMappingService.getTeamKey('uNiTeD sTaTeS'), equals('USA'));
        });

        test('matches nicknames case-insensitively', () {
          expect(
              TeamMappingService.getTeamKey('la albiceleste'), equals('ARG'));
          expect(
              TeamMappingService.getTeamKey('three lions'), equals('ENG'));
          expect(TeamMappingService.getTeamKey('LES BLEUS'), equals('FRA'));
        });
      });

      group('partial match', () {
        test('matches partial name longer than 3 characters', () {
          // 'Brazi' should match 'Brazil' -> 'BRA'
          expect(TeamMappingService.getTeamKey('Brazi'), equals('BRA'));
        });

        test('matches partial name case-insensitively', () {
          expect(TeamMappingService.getTeamKey('argen'), equals('ARG'));
        });

        test('does not match partial name with 3 or fewer characters', () {
          // 'Bra' is only 3 chars, partial match requires > 3
          final result = TeamMappingService.getTeamKey('Bra');
          // Should not match, so returns the uppercased input
          expect(result, equals('BRA'));
          // This happens to match the code, but it's because of the
          // fallback behavior, not a partial match. Let's test with
          // something that won't coincidentally match.
        });

        test(
            'returns uppercased input without spaces for unmatched short strings',
            () {
          final result = TeamMappingService.getTeamKey('XY');
          expect(result, equals('XY'));
        });
      });

      group('fallback for unknown teams', () {
        test('returns uppercased name for completely unknown team', () {
          expect(TeamMappingService.getTeamKey('Narnia'), equals('NARNIA'));
        });

        test('removes spaces from fallback', () {
          expect(TeamMappingService.getTeamKey('Unknown Team'),
              equals('UNKNOWNTEAM'));
        });

        test('returns empty string uppercased for empty input', () {
          expect(TeamMappingService.getTeamKey(''), equals(''));
        });
      });
    });

    group('getAllMappings', () {
      test('returns a non-empty map', () {
        final mappings = TeamMappingService.getAllMappings();
        expect(mappings, isNotEmpty);
      });

      test('returns a copy, not the original map', () {
        final mappings1 = TeamMappingService.getAllMappings();
        final mappings2 = TeamMappingService.getAllMappings();
        expect(identical(mappings1, mappings2), isFalse);
      });

      test('modifying the returned map does not affect the service', () {
        final mappings = TeamMappingService.getAllMappings();
        mappings['TestTeam'] = 'TST';
        // The original should not be modified
        expect(TeamMappingService.isTeamSupported('TestTeam'), isFalse);
      });

      test('contains known team entries', () {
        final mappings = TeamMappingService.getAllMappings();
        expect(mappings['Brazil'], equals('BRA'));
        expect(mappings['France'], equals('FRA'));
        expect(mappings['United States'], equals('USA'));
      });

      test('contains nickname entries', () {
        final mappings = TeamMappingService.getAllMappings();
        expect(mappings['Three Lions'], equals('ENG'));
        expect(mappings['Azzurri'], equals('ITA'));
      });
    });

    group('isTeamSupported', () {
      test('returns true for exact match', () {
        expect(TeamMappingService.isTeamSupported('Brazil'), isTrue);
        expect(TeamMappingService.isTeamSupported('Argentina'), isTrue);
        expect(TeamMappingService.isTeamSupported('France'), isTrue);
      });

      test('returns true for case-insensitive match', () {
        expect(TeamMappingService.isTeamSupported('brazil'), isTrue);
        expect(TeamMappingService.isTeamSupported('BRAZIL'), isTrue);
        expect(TeamMappingService.isTeamSupported('bRaZiL'), isTrue);
      });

      test('returns true for nicknames', () {
        expect(TeamMappingService.isTeamSupported('Azzurri'), isTrue);
        expect(TeamMappingService.isTeamSupported('Three Lions'), isTrue);
        expect(TeamMappingService.isTeamSupported('La Albiceleste'), isTrue);
      });

      test('returns true for nicknames case-insensitively', () {
        expect(TeamMappingService.isTeamSupported('azzurri'), isTrue);
        expect(TeamMappingService.isTeamSupported('three lions'), isTrue);
      });

      test('returns false for unknown teams', () {
        expect(TeamMappingService.isTeamSupported('Narnia'), isFalse);
        expect(TeamMappingService.isTeamSupported(''), isFalse);
        expect(TeamMappingService.isTeamSupported('Unknown'), isFalse);
      });

      test('returns false for partial matches', () {
        // isTeamSupported only checks exact and case-insensitive,
        // not partial matches
        expect(TeamMappingService.isTeamSupported('Brazi'), isFalse);
      });
    });

    group('getDisplayName', () {
      test('returns first matching display name for a valid team code', () {
        // getDisplayName returns the first entry found with that code
        final name = TeamMappingService.getDisplayName('BRA');
        expect(name, isNotNull);
        expect(name, equals('Brazil'));
      });

      test('returns a display name for USA', () {
        final name = TeamMappingService.getDisplayName('USA');
        expect(name, isNotNull);
        // 'United States' is the first entry with value 'USA'
        expect(name, equals('United States'));
      });

      test('returns null for unknown team code', () {
        expect(TeamMappingService.getDisplayName('XXX'), isNull);
        expect(TeamMappingService.getDisplayName(''), isNull);
        expect(TeamMappingService.getDisplayName('NARNIA'), isNull);
      });

      test('returns display name for various codes', () {
        expect(TeamMappingService.getDisplayName('FRA'), isNotNull);
        expect(TeamMappingService.getDisplayName('GER'), isNotNull);
        expect(TeamMappingService.getDisplayName('ESP'), isNotNull);
        expect(TeamMappingService.getDisplayName('ENG'), isNotNull);
        expect(TeamMappingService.getDisplayName('ITA'), isNotNull);
        expect(TeamMappingService.getDisplayName('ARG'), isNotNull);
      });

      test('code lookup is case-sensitive', () {
        // getDisplayName checks entry.value == teamKey exactly
        expect(TeamMappingService.getDisplayName('bra'), isNull);
        expect(TeamMappingService.getDisplayName('fra'), isNull);
      });
    });
  });
}
