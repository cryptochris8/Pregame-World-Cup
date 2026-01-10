import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/utils/team_logo_helper.dart';

/// Tests for TeamLogoHelper utility class
void main() {
  group('TeamLogoHelper - getTeamLogoPath', () {
    group('Alabama Crimson Tide', () {
      test('returns path for "alabama"', () {
        expect(TeamLogoHelper.getTeamLogoPath('alabama'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "Alabama" (case insensitive)', () {
        expect(TeamLogoHelper.getTeamLogoPath('Alabama'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "ALABAMA" (uppercase)', () {
        expect(TeamLogoHelper.getTeamLogoPath('ALABAMA'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "alabama crimson tide"', () {
        expect(TeamLogoHelper.getTeamLogoPath('alabama crimson tide'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "crimson tide"', () {
        expect(TeamLogoHelper.getTeamLogoPath('crimson tide'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "bama"', () {
        expect(TeamLogoHelper.getTeamLogoPath('bama'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });

      test('returns path for "ala"', () {
        expect(TeamLogoHelper.getTeamLogoPath('ala'),
            equals('assets/logos/alabama_crimson_tide.png'));
      });
    });

    group('Arkansas Razorbacks', () {
      test('returns path for "arkansas"', () {
        expect(TeamLogoHelper.getTeamLogoPath('arkansas'),
            equals('assets/logos/arkansas_razorbacks.png'));
      });

      test('returns path for "razorbacks"', () {
        expect(TeamLogoHelper.getTeamLogoPath('razorbacks'),
            equals('assets/logos/arkansas_razorbacks.png'));
      });

      test('returns path for "ark"', () {
        expect(TeamLogoHelper.getTeamLogoPath('ark'),
            equals('assets/logos/arkansas_razorbacks.png'));
      });
    });

    group('Auburn Tigers', () {
      test('returns path for "auburn"', () {
        expect(TeamLogoHelper.getTeamLogoPath('auburn'),
            equals('assets/logos/auburn_tigers.png'));
      });

      test('returns path for "auburn tigers"', () {
        expect(TeamLogoHelper.getTeamLogoPath('auburn tigers'),
            equals('assets/logos/auburn_tigers.png'));
      });

      test('returns path for "aub"', () {
        expect(TeamLogoHelper.getTeamLogoPath('aub'),
            equals('assets/logos/auburn_tigers.png'));
      });
    });

    group('Florida Gators', () {
      test('returns path for "florida"', () {
        expect(TeamLogoHelper.getTeamLogoPath('florida'),
            equals('assets/logos/florida_gators.png'));
      });

      test('returns path for "gators"', () {
        expect(TeamLogoHelper.getTeamLogoPath('gators'),
            equals('assets/logos/florida_gators.png'));
      });

      test('returns path for "uf"', () {
        expect(TeamLogoHelper.getTeamLogoPath('uf'),
            equals('assets/logos/florida_gators.png'));
      });

      test('returns path for "fla"', () {
        expect(TeamLogoHelper.getTeamLogoPath('fla'),
            equals('assets/logos/florida_gators.png'));
      });
    });

    group('Georgia Bulldogs', () {
      test('returns path for "georgia"', () {
        expect(TeamLogoHelper.getTeamLogoPath('georgia'),
            equals('assets/logos/georgia_bulldogs.png'));
      });

      test('returns path for "bulldogs"', () {
        expect(TeamLogoHelper.getTeamLogoPath('bulldogs'),
            equals('assets/logos/georgia_bulldogs.png'));
      });

      test('returns path for "uga"', () {
        expect(TeamLogoHelper.getTeamLogoPath('uga'),
            equals('assets/logos/georgia_bulldogs.png'));
      });
    });

    group('Kentucky Wildcats', () {
      test('returns path for "kentucky"', () {
        expect(TeamLogoHelper.getTeamLogoPath('kentucky'),
            equals('assets/logos/kentucky_wildcats.png'));
      });

      test('returns path for "wildcats"', () {
        expect(TeamLogoHelper.getTeamLogoPath('wildcats'),
            equals('assets/logos/kentucky_wildcats.png'));
      });

      test('returns path for "uk"', () {
        expect(TeamLogoHelper.getTeamLogoPath('uk'),
            equals('assets/logos/kentucky_wildcats.png'));
      });
    });

    group('LSU Tigers', () {
      test('returns path for "lsu"', () {
        expect(TeamLogoHelper.getTeamLogoPath('lsu'),
            equals('assets/logos/lsu_tigers.png'));
      });

      test('returns path for "lsu tigers"', () {
        expect(TeamLogoHelper.getTeamLogoPath('lsu tigers'),
            equals('assets/logos/lsu_tigers.png'));
      });

      test('returns path for "tigers"', () {
        expect(TeamLogoHelper.getTeamLogoPath('tigers'),
            equals('assets/logos/lsu_tigers.png'));
      });

      test('returns path for "louisiana state"', () {
        expect(TeamLogoHelper.getTeamLogoPath('louisiana state'),
            equals('assets/logos/lsu_tigers.png'));
      });
    });

    group('Mississippi State Bulldogs', () {
      test('returns path for "mississippi state"', () {
        expect(TeamLogoHelper.getTeamLogoPath('mississippi state'),
            equals('assets/logos/mississipi_state.png'));
      });

      test('returns path for "miss state"', () {
        expect(TeamLogoHelper.getTeamLogoPath('miss state'),
            equals('assets/logos/mississipi_state.png'));
      });

      test('returns path for "msu"', () {
        expect(TeamLogoHelper.getTeamLogoPath('msu'),
            equals('assets/logos/mississipi_state.png'));
      });

      test('returns path for "msst"', () {
        expect(TeamLogoHelper.getTeamLogoPath('msst'),
            equals('assets/logos/mississipi_state.png'));
      });
    });

    group('Missouri Tigers', () {
      test('returns path for "missouri"', () {
        expect(TeamLogoHelper.getTeamLogoPath('missouri'),
            equals('assets/logos/missouri_tigers.png'));
      });

      test('returns path for "mizzou"', () {
        expect(TeamLogoHelper.getTeamLogoPath('mizzou'),
            equals('assets/logos/missouri_tigers.png'));
      });

      test('returns path for "miz"', () {
        expect(TeamLogoHelper.getTeamLogoPath('miz'),
            equals('assets/logos/missouri_tigers.png'));
      });
    });

    group('Ole Miss Rebels', () {
      test('returns path for "ole miss"', () {
        expect(TeamLogoHelper.getTeamLogoPath('ole miss'),
            equals('assets/logos/ole_miss_rebels.png'));
      });

      test('returns path for "rebels"', () {
        expect(TeamLogoHelper.getTeamLogoPath('rebels'),
            equals('assets/logos/ole_miss_rebels.png'));
      });

      test('returns path for "mississippi"', () {
        expect(TeamLogoHelper.getTeamLogoPath('mississippi'),
            equals('assets/logos/ole_miss_rebels.png'));
      });
    });

    group('Oklahoma Sooners', () {
      test('returns path for "oklahoma"', () {
        expect(TeamLogoHelper.getTeamLogoPath('oklahoma'),
            equals('assets/logos/oklahoma-sooners.png'));
      });

      test('returns path for "sooners"', () {
        expect(TeamLogoHelper.getTeamLogoPath('sooners'),
            equals('assets/logos/oklahoma-sooners.png'));
      });

      test('returns path for "ou"', () {
        expect(TeamLogoHelper.getTeamLogoPath('ou'),
            equals('assets/logos/oklahoma-sooners.png'));
      });
    });

    group('South Carolina Gamecocks', () {
      test('returns path for "south carolina"', () {
        expect(TeamLogoHelper.getTeamLogoPath('south carolina'),
            equals('assets/logos/south_carolina_gamecocks.png'));
      });

      test('returns path for "gamecocks"', () {
        expect(TeamLogoHelper.getTeamLogoPath('gamecocks'),
            equals('assets/logos/south_carolina_gamecocks.png'));
      });

      test('returns path for "sc"', () {
        expect(TeamLogoHelper.getTeamLogoPath('sc'),
            equals('assets/logos/south_carolina_gamecocks.png'));
      });

      test('returns path for "scar"', () {
        expect(TeamLogoHelper.getTeamLogoPath('scar'),
            equals('assets/logos/south_carolina_gamecocks.png'));
      });
    });

    group('Tennessee Volunteers', () {
      test('returns path for "tennessee"', () {
        expect(TeamLogoHelper.getTeamLogoPath('tennessee'),
            equals('assets/logos/tennessee_vols.png'));
      });

      test('returns path for "vols"', () {
        expect(TeamLogoHelper.getTeamLogoPath('vols'),
            equals('assets/logos/tennessee_vols.png'));
      });

      test('returns path for "volunteers"', () {
        expect(TeamLogoHelper.getTeamLogoPath('volunteers'),
            equals('assets/logos/tennessee_vols.png'));
      });

      test('returns path for "tenn"', () {
        expect(TeamLogoHelper.getTeamLogoPath('tenn'),
            equals('assets/logos/tennessee_vols.png'));
      });
    });

    group('Texas Longhorns', () {
      test('returns path for "texas"', () {
        expect(TeamLogoHelper.getTeamLogoPath('texas'),
            equals('assets/logos/texas_longhonerns.png'));
      });

      test('returns path for "longhorns"', () {
        expect(TeamLogoHelper.getTeamLogoPath('longhorns'),
            equals('assets/logos/texas_longhonerns.png'));
      });

      test('returns path for "ut"', () {
        expect(TeamLogoHelper.getTeamLogoPath('ut'),
            equals('assets/logos/texas_longhonerns.png'));
      });

      test('returns path for "horns"', () {
        expect(TeamLogoHelper.getTeamLogoPath('horns'),
            equals('assets/logos/texas_longhonerns.png'));
      });
    });

    group('Texas A&M Aggies', () {
      test('returns path for "texas a&m"', () {
        expect(TeamLogoHelper.getTeamLogoPath('texas a&m'),
            equals('assets/logos/texas_a&m_aggies.png'));
      });

      test('returns path for "aggies"', () {
        expect(TeamLogoHelper.getTeamLogoPath('aggies'),
            equals('assets/logos/texas_a&m_aggies.png'));
      });

      test('returns path for "tamu"', () {
        expect(TeamLogoHelper.getTeamLogoPath('tamu'),
            equals('assets/logos/texas_a&m_aggies.png'));
      });

      test('returns path for "a&m"', () {
        expect(TeamLogoHelper.getTeamLogoPath('a&m'),
            equals('assets/logos/texas_a&m_aggies.png'));
      });
    });

    group('Vanderbilt Commodores', () {
      test('returns path for "vanderbilt"', () {
        expect(TeamLogoHelper.getTeamLogoPath('vanderbilt'),
            equals('assets/logos/vanderbilt_commodores.png'));
      });

      test('returns path for "commodores"', () {
        expect(TeamLogoHelper.getTeamLogoPath('commodores'),
            equals('assets/logos/vanderbilt_commodores.png'));
      });

      test('returns path for "vandy"', () {
        expect(TeamLogoHelper.getTeamLogoPath('vandy'),
            equals('assets/logos/vanderbilt_commodores.png'));
      });

      test('returns path for "dores"', () {
        expect(TeamLogoHelper.getTeamLogoPath('dores'),
            equals('assets/logos/vanderbilt_commodores.png'));
      });
    });

    group('Edge Cases', () {
      test('returns null for null input', () {
        expect(TeamLogoHelper.getTeamLogoPath(null), isNull);
      });

      test('returns null for empty string', () {
        expect(TeamLogoHelper.getTeamLogoPath(''), isNull);
      });

      test('returns null for unknown team', () {
        expect(TeamLogoHelper.getTeamLogoPath('unknown team'), isNull);
      });

      test('returns null for non-SEC team', () {
        expect(TeamLogoHelper.getTeamLogoPath('ohio state'), isNull);
      });

      test('handles whitespace in input', () {
        expect(TeamLogoHelper.getTeamLogoPath('  alabama  '),
            equals('assets/logos/alabama_crimson_tide.png'));
      });
    });
  });

  group('TeamLogoHelper - hasTeamLogo', () {
    test('returns true for SEC teams', () {
      expect(TeamLogoHelper.hasTeamLogo('alabama'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('georgia'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('lsu'), isTrue);
    });

    test('returns false for non-SEC teams', () {
      expect(TeamLogoHelper.hasTeamLogo('ohio state'), isFalse);
      expect(TeamLogoHelper.hasTeamLogo('michigan'), isFalse);
    });

    test('returns false for null', () {
      expect(TeamLogoHelper.hasTeamLogo(null), isFalse);
    });

    test('returns false for empty string', () {
      expect(TeamLogoHelper.hasTeamLogo(''), isFalse);
    });
  });

  group('TeamLogoHelper - getAvailableTeams', () {
    test('returns non-empty list', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, isNotEmpty);
    });

    test('contains SEC team aliases', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, contains('alabama'));
      expect(teams, contains('georgia'));
      expect(teams, contains('lsu'));
      expect(teams, contains('texas'));
    });

    test('contains team nicknames', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, contains('bulldogs'));
      expect(teams, contains('tigers'));
      expect(teams, contains('gators'));
    });

    test('contains abbreviations', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, contains('uga'));
      expect(teams, contains('tamu'));
      expect(teams, contains('ou'));
    });
  });
}
