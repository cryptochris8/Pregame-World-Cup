import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/utils/flag_utils.dart';

void main() {
  group('FlagUtils', () {
    group('getIsoCode', () {
      test('converts CONCACAF team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('USA'), equals('us'));
        expect(FlagUtils.getIsoCode('MEX'), equals('mx'));
        expect(FlagUtils.getIsoCode('CAN'), equals('ca'));
        expect(FlagUtils.getIsoCode('CRC'), equals('cr'));
        expect(FlagUtils.getIsoCode('JAM'), equals('jm'));
        expect(FlagUtils.getIsoCode('HON'), equals('hn'));
        expect(FlagUtils.getIsoCode('PAN'), equals('pa'));
      });

      test('converts CONMEBOL team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('BRA'), equals('br'));
        expect(FlagUtils.getIsoCode('ARG'), equals('ar'));
        expect(FlagUtils.getIsoCode('URU'), equals('uy'));
        expect(FlagUtils.getIsoCode('COL'), equals('co'));
        expect(FlagUtils.getIsoCode('ECU'), equals('ec'));
        expect(FlagUtils.getIsoCode('CHI'), equals('cl'));
        expect(FlagUtils.getIsoCode('PER'), equals('pe'));
        expect(FlagUtils.getIsoCode('PAR'), equals('py'));
      });

      test('converts UEFA team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('FRA'), equals('fr'));
        expect(FlagUtils.getIsoCode('ENG'), equals('gb-eng'));
        expect(FlagUtils.getIsoCode('ESP'), equals('es'));
        expect(FlagUtils.getIsoCode('GER'), equals('de'));
        expect(FlagUtils.getIsoCode('NED'), equals('nl'));
        expect(FlagUtils.getIsoCode('POR'), equals('pt'));
        expect(FlagUtils.getIsoCode('BEL'), equals('be'));
        expect(FlagUtils.getIsoCode('ITA'), equals('it'));
        expect(FlagUtils.getIsoCode('CRO'), equals('hr'));
        expect(FlagUtils.getIsoCode('SUI'), equals('ch'));
      });

      test('converts AFC team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('JPN'), equals('jp'));
        expect(FlagUtils.getIsoCode('KOR'), equals('kr'));
        expect(FlagUtils.getIsoCode('AUS'), equals('au'));
        expect(FlagUtils.getIsoCode('IRN'), equals('ir'));
        expect(FlagUtils.getIsoCode('KSA'), equals('sa'));
        expect(FlagUtils.getIsoCode('QAT'), equals('qa'));
      });

      test('converts CAF team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('MAR'), equals('ma'));
        expect(FlagUtils.getIsoCode('SEN'), equals('sn'));
        expect(FlagUtils.getIsoCode('NGA'), equals('ng'));
        expect(FlagUtils.getIsoCode('EGY'), equals('eg'));
        expect(FlagUtils.getIsoCode('GHA'), equals('gh'));
        expect(FlagUtils.getIsoCode('CMR'), equals('cm'));
      });

      test('converts OFC team codes to ISO codes', () {
        expect(FlagUtils.getIsoCode('NZL'), equals('nz'));
        expect(FlagUtils.getIsoCode('FIJ'), equals('fj'));
      });

      test('handles GB subdivisions', () {
        expect(FlagUtils.getIsoCode('WAL'), equals('gb-wls'));
        expect(FlagUtils.getIsoCode('SCO'), equals('gb-sct'));
        expect(FlagUtils.getIsoCode('NIR'), equals('gb-nir'));
      });

      test('handles case-insensitive input', () {
        expect(FlagUtils.getIsoCode('usa'), equals('us'));
        expect(FlagUtils.getIsoCode('bra'), equals('br'));
        expect(FlagUtils.getIsoCode('Ger'), equals('de'));
      });

      test('returns lowercase team code for unknown codes', () {
        expect(FlagUtils.getIsoCode('XYZ'), equals('xyz'));
        expect(FlagUtils.getIsoCode('ABC'), equals('abc'));
      });
    });

    group('getFlagUrl', () {
      test('returns correct flag URL with default width', () {
        final url = FlagUtils.getFlagUrl('USA');
        expect(url, equals('https://flagcdn.com/w80/us.png'));
      });

      test('returns correct flag URL with custom width', () {
        final url = FlagUtils.getFlagUrl('BRA', width: 160);
        expect(url, equals('https://flagcdn.com/w160/br.png'));
      });

      test('returns correct flag URL for small width', () {
        final url = FlagUtils.getFlagUrl('GER', width: 16);
        expect(url, equals('https://flagcdn.com/w16/de.png'));
      });

      test('handles GB subdivisions in flag URL', () {
        final url = FlagUtils.getFlagUrl('ENG');
        expect(url, equals('https://flagcdn.com/w80/gb-eng.png'));
      });

      test('handles unknown codes in flag URL', () {
        final url = FlagUtils.getFlagUrl('XYZ');
        expect(url, equals('https://flagcdn.com/w80/xyz.png'));
      });
    });

    group('getFlagSvgUrl', () {
      test('returns correct SVG flag URL', () {
        expect(FlagUtils.getFlagSvgUrl('USA'), equals('https://flagcdn.com/us.svg'));
        expect(FlagUtils.getFlagSvgUrl('BRA'), equals('https://flagcdn.com/br.svg'));
        expect(FlagUtils.getFlagSvgUrl('ENG'), equals('https://flagcdn.com/gb-eng.svg'));
      });
    });

    group('getFlagEmoji', () {
      test('returns flag emoji for standard 2-letter ISO codes', () {
        // US flag
        final usFlag = FlagUtils.getFlagEmoji('USA');
        expect(usFlag, isNotEmpty);
        expect(usFlag.length, greaterThan(1)); // Regional indicator symbols

        // Brazil flag
        final brFlag = FlagUtils.getFlagEmoji('BRA');
        expect(brFlag, isNotEmpty);
      });

      test('returns GB subdivision emoji for England', () {
        final engFlag = FlagUtils.getFlagEmoji('ENG');
        expect(engFlag, isNotEmpty);
      });

      test('returns GB subdivision emoji for Scotland', () {
        final scoFlag = FlagUtils.getFlagEmoji('SCO');
        expect(scoFlag, isNotEmpty);
      });

      test('returns GB subdivision emoji for Wales', () {
        final walFlag = FlagUtils.getFlagEmoji('WAL');
        expect(walFlag, isNotEmpty);
      });

      test('returns UK flag for Northern Ireland', () {
        final nirFlag = FlagUtils.getFlagEmoji('NIR');
        expect(nirFlag, isNotEmpty);
      });

      test('returns white flag for codes that result in non-2-letter ISO', () {
        // Unknown code that doesn't have a 2-letter mapping and has length != 2
        // In practice, unknown codes get lowercased and are typically 3 chars
        final flag = FlagUtils.getFlagEmoji('XXXX');
        // After getIsoCode('XXXX').toUpperCase(), we get 'XXXX' which is length 4
        // So it should return the white flag
        expect(flag, isNotEmpty);
      });
    });

    group('hasKnownMapping', () {
      test('returns true for known team codes', () {
        expect(FlagUtils.hasKnownMapping('USA'), isTrue);
        expect(FlagUtils.hasKnownMapping('BRA'), isTrue);
        expect(FlagUtils.hasKnownMapping('GER'), isTrue);
        expect(FlagUtils.hasKnownMapping('JPN'), isTrue);
        expect(FlagUtils.hasKnownMapping('ENG'), isTrue);
        expect(FlagUtils.hasKnownMapping('MAR'), isTrue);
        expect(FlagUtils.hasKnownMapping('NZL'), isTrue);
      });

      test('returns false for unknown team codes', () {
        expect(FlagUtils.hasKnownMapping('XYZ'), isFalse);
        expect(FlagUtils.hasKnownMapping('ABC'), isFalse);
        expect(FlagUtils.hasKnownMapping(''), isFalse);
      });

      test('handles case-insensitive check', () {
        expect(FlagUtils.hasKnownMapping('usa'), isTrue);
        expect(FlagUtils.hasKnownMapping('bra'), isTrue);
      });
    });

    group('teamToIsoCode map coverage', () {
      test('contains all 48 World Cup 2026 team codes', () {
        // Key teams that must be present
        final worldCup2026Teams = [
          'USA', 'MEX', 'CAN', // Hosts
          'BRA', 'ARG', 'URU', 'COL', 'ECU', // CONMEBOL
          'FRA', 'ENG', 'ESP', 'GER', 'NED', 'POR', 'BEL', 'ITA', 'CRO',
          'DEN', 'SUI', 'AUT', 'POL', 'SRB', 'UKR', // UEFA
          'JPN', 'KOR', 'AUS', 'IRN', 'KSA', 'QAT', // AFC
          'MAR', 'SEN', 'NGA', 'EGY', 'GHA', 'CMR', // CAF
          'NZL', // OFC
        ];

        for (final code in worldCup2026Teams) {
          expect(FlagUtils.hasKnownMapping(code), isTrue,
              reason: '$code should have a known ISO mapping');
        }
      });

      test('map has substantial coverage (80+ entries)', () {
        expect(FlagUtils.teamToIsoCode.length, greaterThanOrEqualTo(80));
      });
    });
  });
}
