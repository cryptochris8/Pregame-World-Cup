import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/utils/team_matching_helper.dart';

/// Tests for TeamMatchingHelper utility class
void main() {
  group('TeamMatchingHelper - teamNamesMatch', () {
    group('Direct matches', () {
      test('returns true for exact match', () {
        expect(TeamMatchingHelper.teamNamesMatch('alabama', 'alabama'), isTrue);
      });

      test('returns true for case-insensitive exact match', () {
        expect(TeamMatchingHelper.teamNamesMatch('Alabama', 'alabama'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('ALABAMA', 'alabama'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('alabama', 'ALABAMA'), isTrue);
      });
    });

    group('SEC Team API Key Mappings', () {
      test('matches ala to alabama', () {
        expect(TeamMatchingHelper.teamNamesMatch('ala', 'alabama'), isTrue);
        expect(
            TeamMatchingHelper.teamNamesMatch('ala', 'alabama crimson tide'), isTrue);
      });

      test('matches aubrn to auburn', () {
        expect(TeamMatchingHelper.teamNamesMatch('aubrn', 'auburn'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('aubrn', 'auburn tigers'), isTrue);
      });

      test('matches ark to arkansas', () {
        expect(TeamMatchingHelper.teamNamesMatch('ark', 'arkansas'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('ark', 'razorbacks'), isTrue);
      });

      test('matches fl to florida', () {
        expect(TeamMatchingHelper.teamNamesMatch('fl', 'florida'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('fl', 'florida gators'), isTrue);
      });

      test('matches ga to georgia', () {
        expect(TeamMatchingHelper.teamNamesMatch('ga', 'georgia'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('ga', 'georgia bulldogs'), isTrue);
      });

      test('matches uk to kentucky', () {
        expect(TeamMatchingHelper.teamNamesMatch('uk', 'kentucky'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('uk', 'wildcats'), isTrue);
      });

      test('matches lsu to lsu', () {
        expect(TeamMatchingHelper.teamNamesMatch('lsu', 'lsu'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('lsu', 'lsu tigers'), isTrue);
      });

      test('matches mspst to mississippi state', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('mspst', 'mississippi state'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('mspst', 'miss state'), isTrue);
      });

      test('matches missr to missouri', () {
        expect(TeamMatchingHelper.teamNamesMatch('missr', 'missouri'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('missr', 'missouri tigers'), isTrue);
      });

      test('matches miss to ole miss', () {
        expect(TeamMatchingHelper.teamNamesMatch('miss', 'ole miss'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('miss', 'rebels'), isTrue);
      });

      test('matches sc to south carolina', () {
        expect(TeamMatchingHelper.teamNamesMatch('sc', 'south carolina'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('sc', 'gamecocks'), isTrue);
      });

      test('matches tenn to tennessee', () {
        expect(TeamMatchingHelper.teamNamesMatch('tenn', 'tennessee'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('tenn', 'volunteers'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('tenn', 'vols'), isTrue);
      });

      test('matches txam to texas a&m', () {
        expect(TeamMatchingHelper.teamNamesMatch('txam', 'texas a&m'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('txam', 'aggies'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('txam', 'tamu'), isTrue);
      });

      test('matches vand to vanderbilt', () {
        expect(TeamMatchingHelper.teamNamesMatch('vand', 'vanderbilt'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('vand', 'commodores'), isTrue);
      });
    });

    group('Full team name mappings', () {
      test('matches full team names', () {
        expect(
            TeamMatchingHelper.teamNamesMatch(
                'alabama crimson tide', 'alabama crimson tide'),
            isTrue);
        expect(
            TeamMatchingHelper.teamNamesMatch(
                'georgia bulldogs', 'georgia bulldogs'),
            isTrue);
      });

      test('matches school names', () {
        expect(TeamMatchingHelper.teamNamesMatch('alabama', 'alabama'), isTrue);
        expect(TeamMatchingHelper.teamNamesMatch('georgia', 'georgia'), isTrue);
      });
    });

    group('Georgia disambiguation', () {
      test('does not match georgia tech to georgia', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('georgia tech', 'georgia bulldogs'),
            isFalse);
      });

      test('does not match georgia southern to georgia', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('georgia southern', 'georgia bulldogs'),
            isFalse);
      });

      test('does not match georgia state to georgia', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('georgia state', 'georgia bulldogs'),
            isFalse);
      });
    });

    group('Texas disambiguation', () {
      test('does not match texas tech to texas', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('texas tech', 'texas longhorns'),
            isFalse);
      });

      test('does not match texas state to texas', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('texas state', 'texas longhorns'),
            isFalse);
      });

      test('does not match texas san antonio to texas', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('texas san antonio', 'texas longhorns'),
            isFalse);
      });

      test('does not match texas el paso to texas', () {
        expect(
            TeamMatchingHelper.teamNamesMatch('texas el paso', 'texas longhorns'),
            isFalse);
      });
    });

    group('Mississippi State disambiguation', () {
      test('matches mississippi state to mississippi state', () {
        expect(
            TeamMatchingHelper.teamNamesMatch(
                'mississippi state', 'mississippi state'),
            isTrue);
      });

      test('mspst API key matches mississippi state favorites', () {
        expect(
            TeamMatchingHelper.teamNamesMatch(
                'mspst', 'mississippi state'),
            isTrue);
        expect(
            TeamMatchingHelper.teamNamesMatch(
                'mspst', 'miss state'),
            isTrue);
      });
    });

    group('Non-matching cases', () {
      test('returns false for completely different teams', () {
        expect(TeamMatchingHelper.teamNamesMatch('alabama', 'georgia'), isFalse);
        expect(TeamMatchingHelper.teamNamesMatch('lsu', 'florida'), isFalse);
      });

      test('returns false for non-SEC teams', () {
        expect(TeamMatchingHelper.teamNamesMatch('ohio state', 'alabama'), isFalse);
        expect(TeamMatchingHelper.teamNamesMatch('michigan', 'georgia'), isFalse);
      });
    });
  });

  group('TeamMatchingHelper - isTeamInFavorites', () {
    test('returns true for direct match in favorites', () {
      final favorites = ['Alabama', 'Georgia', 'LSU'];
      expect(TeamMatchingHelper.isTeamInFavorites('Alabama', favorites), isTrue);
    });

    test('returns true for flexible match in favorites', () {
      final favorites = ['Alabama Crimson Tide', 'Georgia Bulldogs'];
      expect(TeamMatchingHelper.isTeamInFavorites('ala', favorites), isTrue);
      expect(TeamMatchingHelper.isTeamInFavorites('ga', favorites), isTrue);
    });

    test('returns false when not in favorites', () {
      final favorites = ['Alabama', 'Georgia'];
      expect(TeamMatchingHelper.isTeamInFavorites('LSU', favorites), isFalse);
    });

    test('returns false for empty favorites list', () {
      final favorites = <String>[];
      expect(TeamMatchingHelper.isTeamInFavorites('Alabama', favorites), isFalse);
    });

    test('handles API keys in favorites check', () {
      final favorites = ['alabama crimson tide'];
      expect(TeamMatchingHelper.isTeamInFavorites('ala', favorites), isTrue);
    });

    test('handles case insensitivity', () {
      final favorites = ['ALABAMA', 'GEORGIA'];
      expect(TeamMatchingHelper.isTeamInFavorites('alabama', favorites), isTrue);
    });
  });

  group('TeamMatchingHelper - getFullTeamName', () {
    test('returns full name for valid API key', () {
      expect(TeamMatchingHelper.getFullTeamName('ala'), equals('alabama'));
      expect(TeamMatchingHelper.getFullTeamName('ga'), equals('georgia'));
      expect(TeamMatchingHelper.getFullTeamName('lsu'), equals('lsu'));
    });

    test('returns full name for case-insensitive keys', () {
      expect(TeamMatchingHelper.getFullTeamName('ALA'), equals('alabama'));
      expect(TeamMatchingHelper.getFullTeamName('GA'), equals('georgia'));
    });

    test('returns null for unknown API key', () {
      expect(TeamMatchingHelper.getFullTeamName('xyz'), isNull);
      expect(TeamMatchingHelper.getFullTeamName('osu'), isNull);
    });

    test('returns full name for all SEC team keys', () {
      expect(TeamMatchingHelper.getFullTeamName('ala'), equals('alabama'));
      expect(TeamMatchingHelper.getFullTeamName('aubrn'), equals('auburn'));
      expect(TeamMatchingHelper.getFullTeamName('ark'), equals('arkansas'));
      expect(TeamMatchingHelper.getFullTeamName('fl'), equals('florida'));
      expect(TeamMatchingHelper.getFullTeamName('ga'), equals('georgia'));
      expect(TeamMatchingHelper.getFullTeamName('uk'), equals('kentucky'));
      expect(TeamMatchingHelper.getFullTeamName('lsu'), equals('lsu'));
      expect(TeamMatchingHelper.getFullTeamName('mspst'), equals('mississippi state'));
      expect(TeamMatchingHelper.getFullTeamName('missr'), equals('missouri'));
      expect(TeamMatchingHelper.getFullTeamName('miss'), equals('ole miss'));
      expect(TeamMatchingHelper.getFullTeamName('sc'), equals('south carolina'));
      expect(TeamMatchingHelper.getFullTeamName('tenn'), equals('tennessee'));
      expect(TeamMatchingHelper.getFullTeamName('txam'), equals('texas a&m'));
      expect(TeamMatchingHelper.getFullTeamName('vand'), equals('vanderbilt'));
    });
  });

  group('TeamMatchingHelper - Edge Cases', () {
    test('handles empty strings', () {
      expect(TeamMatchingHelper.teamNamesMatch('', ''), isTrue);
      expect(TeamMatchingHelper.teamNamesMatch('alabama', ''), isFalse);
      expect(TeamMatchingHelper.teamNamesMatch('', 'alabama'), isFalse);
    });

    test('handles special characters in team names', () {
      expect(TeamMatchingHelper.teamNamesMatch('texas a&m', 'texas a&m aggies'),
          isTrue);
    });

    test('handles identical team names with different cases', () {
      // Direct match through exact comparison
      expect(TeamMatchingHelper.teamNamesMatch('alabama', 'ALABAMA'), isTrue);
      expect(TeamMatchingHelper.teamNamesMatch('Georgia Bulldogs', 'georgia bulldogs'),
          isTrue);
    });
  });
}
