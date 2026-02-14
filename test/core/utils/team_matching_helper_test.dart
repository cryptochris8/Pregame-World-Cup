import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/utils/team_matching_helper.dart';

/// Tests for TeamMatchingHelper utility class (World Cup 2026 edition)
void main() {
  group('TeamMatchingHelper - teamNamesMatch', () {
    group('Direct matches', () {
      test('returns true for exact match', () {
        expect(TeamMatchingHelper.teamNamesMatch('brazil', 'brazil'), isTrue);
      });

      test('returns true for case-insensitive exact match', () {
        expect(TeamMatchingHelper.teamNamesMatch('Brazil', 'brazil'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('BRAZIL', 'brazil'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('brazil', 'BRAZIL'), isTrue);
      });
    });

    group('FIFA code to full name mappings', () {
      test('matches USA to United States', () {
        expect(TeamMatchingHelper.teamNamesMatch('usa', 'United States'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('USA', 'united states'), isTrue);
      });

      test('matches USMNT to United States', () {
        expect(TeamMatchingHelper.teamNamesMatch('usmnt', 'United States'), isTrue);
      });

      test('matches BRA to Brazil', () {
        expect(TeamMatchingHelper.teamNamesMatch('bra', 'Brazil'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('BRA', 'brazil'), isTrue);
      });

      test('matches Brasil alias to Brazil', () {
        expect(TeamMatchingHelper.teamNamesMatch('brasil', 'Brazil'), isTrue);
      });

      test('matches ARG to Argentina', () {
        expect(TeamMatchingHelper.teamNamesMatch('arg', 'Argentina'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('ARG', 'argentina'), isTrue);
      });

      test('matches La Albiceleste to Argentina', () {
        expect(TeamMatchingHelper.teamNamesMatch('la albiceleste', 'Argentina'), isTrue);
      });

      test('matches MEX to Mexico', () {
        expect(TeamMatchingHelper.teamNamesMatch('mex', 'Mexico'), isTrue);
      });

      test('matches El Tri to Mexico', () {
        expect(TeamMatchingHelper.teamNamesMatch('el tri', 'Mexico'), isTrue);
      });

      test('matches CAN to Canada', () {
        expect(TeamMatchingHelper.teamNamesMatch('can', 'Canada'), isTrue);
      });

      test('matches ENG to England', () {
        expect(TeamMatchingHelper.teamNamesMatch('eng', 'England'), isTrue);
      });

      test('matches FRA to France', () {
        expect(TeamMatchingHelper.teamNamesMatch('fra', 'France'), isTrue);
      });

      test('matches GER to Germany', () {
        expect(TeamMatchingHelper.teamNamesMatch('ger', 'Germany'), isTrue);
      });

      test('matches ESP to Spain', () {
        expect(TeamMatchingHelper.teamNamesMatch('esp', 'Spain'), isTrue);
      });

      test('matches NED to Netherlands', () {
        expect(TeamMatchingHelper.teamNamesMatch('ned', 'Netherlands'), isTrue);
      });

      test('matches Holland to Netherlands', () {
        expect(TeamMatchingHelper.teamNamesMatch('holland', 'Netherlands'), isTrue);
      });

      test('matches POR to Portugal', () {
        expect(TeamMatchingHelper.teamNamesMatch('por', 'Portugal'), isTrue);
      });

      test('matches JPN to Japan', () {
        expect(TeamMatchingHelper.teamNamesMatch('jpn', 'Japan'), isTrue);
      });

      test('matches KOR to South Korea', () {
        expect(TeamMatchingHelper.teamNamesMatch('kor', 'South Korea'), isTrue);
      });

      test('matches Korea Republic to South Korea', () {
        expect(TeamMatchingHelper.teamNamesMatch('korea republic', 'South Korea'), isTrue);
      });

      test('matches KSA to Saudi Arabia', () {
        expect(TeamMatchingHelper.teamNamesMatch('ksa', 'Saudi Arabia'), isTrue);
      });

      test('matches NGA to Nigeria', () {
        expect(TeamMatchingHelper.teamNamesMatch('nga', 'Nigeria'), isTrue);
      });

      test('matches MAR to Morocco', () {
        expect(TeamMatchingHelper.teamNamesMatch('mar', 'Morocco'), isTrue);
      });

      test('matches SEN to Senegal', () {
        expect(TeamMatchingHelper.teamNamesMatch('sen', 'Senegal'), isTrue);
      });

      test('matches URU to Uruguay', () {
        expect(TeamMatchingHelper.teamNamesMatch('uru', 'Uruguay'), isTrue);
      });

      test('matches COL to Colombia', () {
        expect(TeamMatchingHelper.teamNamesMatch('col', 'Colombia'), isTrue);
      });

      test('matches CRO to Croatia', () {
        expect(TeamMatchingHelper.teamNamesMatch('cro', 'Croatia'), isTrue);
      });

      test('matches BEL to Belgium', () {
        expect(TeamMatchingHelper.teamNamesMatch('bel', 'Belgium'), isTrue);
      });

      test('matches SUI to Switzerland', () {
        expect(TeamMatchingHelper.teamNamesMatch('sui', 'Switzerland'), isTrue);
      });

      test('matches Turkiye alias to Turkey', () {
        expect(TeamMatchingHelper.teamNamesMatch('turkiye', 'Turkey'), isTrue);
      });

      test('matches IR Iran to Iran', () {
        expect(TeamMatchingHelper.teamNamesMatch('ir iran', 'Iran'), isTrue);
      });

      test('matches NZL to New Zealand', () {
        expect(TeamMatchingHelper.teamNamesMatch('nzl', 'New Zealand'), isTrue);
      });
    });

    group('FIFA code to FIFA code matching', () {
      test('matches code on both sides', () {
        expect(TeamMatchingHelper.teamNamesMatch('usa', 'usa'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('bra', 'bra'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('arg', 'arg'), isTrue);
      });

      test('matches different aliases to same team', () {
        expect(TeamMatchingHelper.teamNamesMatch('usa', 'usmnt'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('holland', 'ned'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('brasil', 'bra'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('korea republic', 'kor'), isTrue);
      });
    });

    group('Non-matching cases', () {
      test('returns false for completely different teams', () {
        expect(TeamMatchingHelper.teamNamesMatch('brazil', 'argentina'), isFalse);
        expect(TeamMatchingHelper.teamNamesMatch('usa', 'mexico'), isFalse);
      });

      test('returns false for unknown teams', () {
        expect(TeamMatchingHelper.teamNamesMatch('unknown team', 'brazil'), isFalse);
        expect(TeamMatchingHelper.teamNamesMatch('xyz', 'argentina'), isFalse);
      });
    });
  });

  group('TeamMatchingHelper - isTeamInFavorites', () {
    test('returns true for direct match in favorites', () {
      final favorites = ['United States', 'Brazil', 'Argentina'];
      expect(TeamMatchingHelper.isTeamInFavorites('United States', favorites), isTrue);
    });

    test('returns true for flexible match via FIFA code', () {
      final favorites = ['United States', 'Brazil'];
      expect(TeamMatchingHelper.isTeamInFavorites('usa', favorites), isTrue);
      expect(TeamMatchingHelper.isTeamInFavorites('bra', favorites), isTrue);
    });

    test('returns true for alias match', () {
      final favorites = ['Mexico', 'Netherlands'];
      expect(TeamMatchingHelper.isTeamInFavorites('el tri', favorites), isTrue);
      expect(TeamMatchingHelper.isTeamInFavorites('holland', favorites), isTrue);
    });

    test('returns false when not in favorites', () {
      final favorites = ['United States', 'Brazil'];
      expect(TeamMatchingHelper.isTeamInFavorites('Argentina', favorites), isFalse);
    });

    test('returns false for empty favorites list', () {
      final favorites = <String>[];
      expect(TeamMatchingHelper.isTeamInFavorites('Brazil', favorites), isFalse);
    });

    test('handles case insensitivity', () {
      final favorites = ['UNITED STATES', 'BRAZIL'];
      expect(TeamMatchingHelper.isTeamInFavorites('united states', favorites), isTrue);
    });
  });

  group('TeamMatchingHelper - getFullTeamName', () {
    test('returns full name for valid FIFA codes', () {
      expect(TeamMatchingHelper.getFullTeamName('usa'), equals('United States'));
      expect(TeamMatchingHelper.getFullTeamName('bra'), equals('Brazil'));
      expect(TeamMatchingHelper.getFullTeamName('arg'), equals('Argentina'));
      expect(TeamMatchingHelper.getFullTeamName('mex'), equals('Mexico'));
    });

    test('returns full name for case-insensitive codes', () {
      expect(TeamMatchingHelper.getFullTeamName('USA'), equals('United States'));
      expect(TeamMatchingHelper.getFullTeamName('BRA'), equals('Brazil'));
    });

    test('returns null for unknown code', () {
      expect(TeamMatchingHelper.getFullTeamName('xyz'), isNull);
      expect(TeamMatchingHelper.getFullTeamName('osu'), isNull);
    });

    test('returns full name for common aliases', () {
      expect(TeamMatchingHelper.getFullTeamName('usmnt'), equals('United States'));
      expect(TeamMatchingHelper.getFullTeamName('el tri'), equals('Mexico'));
      expect(TeamMatchingHelper.getFullTeamName('holland'), equals('Netherlands'));
      expect(TeamMatchingHelper.getFullTeamName('brasil'), equals('Brazil'));
      expect(TeamMatchingHelper.getFullTeamName('la albiceleste'), equals('Argentina'));
      expect(TeamMatchingHelper.getFullTeamName('turkiye'), equals('Turkey'));
      expect(TeamMatchingHelper.getFullTeamName('ir iran'), equals('Iran'));
      expect(TeamMatchingHelper.getFullTeamName('korea republic'), equals('South Korea'));
    });

    test('returns full name for all confederation codes', () {
      // CONCACAF
      expect(TeamMatchingHelper.getFullTeamName('can'), equals('Canada'));
      expect(TeamMatchingHelper.getFullTeamName('crc'), equals('Costa Rica'));
      expect(TeamMatchingHelper.getFullTeamName('hon'), equals('Honduras'));
      expect(TeamMatchingHelper.getFullTeamName('jam'), equals('Jamaica'));
      expect(TeamMatchingHelper.getFullTeamName('pan'), equals('Panama'));

      // CONMEBOL
      expect(TeamMatchingHelper.getFullTeamName('bol'), equals('Bolivia'));
      expect(TeamMatchingHelper.getFullTeamName('chi'), equals('Chile'));
      expect(TeamMatchingHelper.getFullTeamName('col'), equals('Colombia'));
      expect(TeamMatchingHelper.getFullTeamName('ecu'), equals('Ecuador'));
      expect(TeamMatchingHelper.getFullTeamName('par'), equals('Paraguay'));
      expect(TeamMatchingHelper.getFullTeamName('per'), equals('Peru'));
      expect(TeamMatchingHelper.getFullTeamName('uru'), equals('Uruguay'));
      expect(TeamMatchingHelper.getFullTeamName('ven'), equals('Venezuela'));

      // UEFA
      expect(TeamMatchingHelper.getFullTeamName('alb'), equals('Albania'));
      expect(TeamMatchingHelper.getFullTeamName('aut'), equals('Austria'));
      expect(TeamMatchingHelper.getFullTeamName('bel'), equals('Belgium'));
      expect(TeamMatchingHelper.getFullTeamName('cro'), equals('Croatia'));
      expect(TeamMatchingHelper.getFullTeamName('den'), equals('Denmark'));
      expect(TeamMatchingHelper.getFullTeamName('eng'), equals('England'));
      expect(TeamMatchingHelper.getFullTeamName('fra'), equals('France'));
      expect(TeamMatchingHelper.getFullTeamName('ger'), equals('Germany'));
      expect(TeamMatchingHelper.getFullTeamName('ned'), equals('Netherlands'));
      expect(TeamMatchingHelper.getFullTeamName('pol'), equals('Poland'));
      expect(TeamMatchingHelper.getFullTeamName('por'), equals('Portugal'));
      expect(TeamMatchingHelper.getFullTeamName('sco'), equals('Scotland'));
      expect(TeamMatchingHelper.getFullTeamName('srb'), equals('Serbia'));
      expect(TeamMatchingHelper.getFullTeamName('esp'), equals('Spain'));
      expect(TeamMatchingHelper.getFullTeamName('sui'), equals('Switzerland'));
      expect(TeamMatchingHelper.getFullTeamName('tur'), equals('Turkey'));
      expect(TeamMatchingHelper.getFullTeamName('ukr'), equals('Ukraine'));
      expect(TeamMatchingHelper.getFullTeamName('wal'), equals('Wales'));

      // AFC
      expect(TeamMatchingHelper.getFullTeamName('aus'), equals('Australia'));
      expect(TeamMatchingHelper.getFullTeamName('irn'), equals('Iran'));
      expect(TeamMatchingHelper.getFullTeamName('jpn'), equals('Japan'));
      expect(TeamMatchingHelper.getFullTeamName('kor'), equals('South Korea'));
      expect(TeamMatchingHelper.getFullTeamName('ksa'), equals('Saudi Arabia'));
      expect(TeamMatchingHelper.getFullTeamName('qat'), equals('Qatar'));
      expect(TeamMatchingHelper.getFullTeamName('uzb'), equals('Uzbekistan'));
      expect(TeamMatchingHelper.getFullTeamName('irq'), equals('Iraq'));

      // CAF
      expect(TeamMatchingHelper.getFullTeamName('cmr'), equals('Cameroon'));
      expect(TeamMatchingHelper.getFullTeamName('egy'), equals('Egypt'));
      expect(TeamMatchingHelper.getFullTeamName('mar'), equals('Morocco'));
      expect(TeamMatchingHelper.getFullTeamName('nga'), equals('Nigeria'));
      expect(TeamMatchingHelper.getFullTeamName('sen'), equals('Senegal'));

      // OFC
      expect(TeamMatchingHelper.getFullTeamName('nzl'), equals('New Zealand'));
    });
  });

  group('TeamMatchingHelper - Edge Cases', () {
    test('handles empty strings', () {
      expect(TeamMatchingHelper.teamNamesMatch('', ''), isTrue);
      expect(TeamMatchingHelper.teamNamesMatch('brazil', ''), isFalse);
      expect(TeamMatchingHelper.teamNamesMatch('', 'brazil'), isFalse);
    });

    test('handles whitespace in team names', () {
      expect(TeamMatchingHelper.teamNamesMatch(' usa ', 'United States'), isTrue);
      expect(TeamMatchingHelper.teamNamesMatch('brazil ', ' brazil'), isTrue);
    });

    test('handles identical team names with different cases', () {
      expect(TeamMatchingHelper.teamNamesMatch('brazil', 'BRAZIL'), isTrue);
      expect(TeamMatchingHelper.teamNamesMatch('United States', 'united states'), isTrue);
    });
  });
}
