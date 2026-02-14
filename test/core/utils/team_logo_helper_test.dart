import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/utils/team_logo_helper.dart';

/// Tests for TeamLogoHelper utility class (World Cup 2026 edition)
///
/// TeamLogoHelper now returns emoji flags instead of PNG asset paths.
void main() {
  group('TeamLogoHelper - getTeamFlag', () {
    group('Lookup by FIFA code', () {
      test('returns flag emoji for USA', () {
        final flag = TeamLogoHelper.getTeamFlag('USA');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1FA}\u{1F1F8}'));
      });

      test('returns flag emoji for BRA', () {
        final flag = TeamLogoHelper.getTeamFlag('BRA');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1E7}\u{1F1F7}'));
      });

      test('returns flag emoji for ARG', () {
        final flag = TeamLogoHelper.getTeamFlag('ARG');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1E6}\u{1F1F7}'));
      });

      test('returns flag emoji for MEX', () {
        final flag = TeamLogoHelper.getTeamFlag('MEX');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1F2}\u{1F1FD}'));
      });

      test('returns flag emoji for ENG', () {
        final flag = TeamLogoHelper.getTeamFlag('ENG');
        expect(flag, isNotNull);
        // England uses the subdivision flag tag sequence
        expect(flag, equals('\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}'));
      });

      test('returns flag emoji for FRA', () {
        final flag = TeamLogoHelper.getTeamFlag('FRA');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1EB}\u{1F1F7}'));
      });

      test('returns flag emoji for GER', () {
        final flag = TeamLogoHelper.getTeamFlag('GER');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1E9}\u{1F1EA}'));
      });

      test('returns flag emoji for ESP', () {
        final flag = TeamLogoHelper.getTeamFlag('ESP');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1EA}\u{1F1F8}'));
      });

      test('returns flag emoji for JPN', () {
        final flag = TeamLogoHelper.getTeamFlag('JPN');
        expect(flag, isNotNull);
        expect(flag, equals('\u{1F1EF}\u{1F1F5}'));
      });

      test('FIFA code lookup is case-insensitive', () {
        expect(TeamLogoHelper.getTeamFlag('usa'), equals(TeamLogoHelper.getTeamFlag('USA')));
        expect(TeamLogoHelper.getTeamFlag('bra'), equals(TeamLogoHelper.getTeamFlag('BRA')));
        expect(TeamLogoHelper.getTeamFlag('Arg'), equals(TeamLogoHelper.getTeamFlag('ARG')));
      });
    });

    group('Lookup by full country name', () {
      test('returns flag for United States', () {
        expect(TeamLogoHelper.getTeamFlag('United States'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('United States'),
            equals(TeamLogoHelper.getTeamFlag('USA')));
      });

      test('returns flag for Brazil', () {
        expect(TeamLogoHelper.getTeamFlag('Brazil'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('Brazil'),
            equals(TeamLogoHelper.getTeamFlag('BRA')));
      });

      test('returns flag for Argentina', () {
        expect(TeamLogoHelper.getTeamFlag('Argentina'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('Argentina'),
            equals(TeamLogoHelper.getTeamFlag('ARG')));
      });

      test('returns flag for Mexico', () {
        expect(TeamLogoHelper.getTeamFlag('Mexico'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('Mexico'),
            equals(TeamLogoHelper.getTeamFlag('MEX')));
      });

      test('returns flag for England', () {
        expect(TeamLogoHelper.getTeamFlag('England'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('England'),
            equals(TeamLogoHelper.getTeamFlag('ENG')));
      });

      test('returns flag for Germany', () {
        expect(TeamLogoHelper.getTeamFlag('Germany'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('Germany'),
            equals(TeamLogoHelper.getTeamFlag('GER')));
      });

      test('returns flag for Netherlands', () {
        expect(TeamLogoHelper.getTeamFlag('Netherlands'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('Netherlands'),
            equals(TeamLogoHelper.getTeamFlag('NED')));
      });

      test('returns flag for South Korea', () {
        expect(TeamLogoHelper.getTeamFlag('South Korea'), isNotNull);
        expect(TeamLogoHelper.getTeamFlag('South Korea'),
            equals(TeamLogoHelper.getTeamFlag('KOR')));
      });
    });

    group('Lookup by alias / nickname', () {
      test('returns flag for USMNT', () {
        expect(TeamLogoHelper.getTeamFlag('USMNT'),
            equals(TeamLogoHelper.getTeamFlag('USA')));
      });

      test('returns flag for El Tri', () {
        expect(TeamLogoHelper.getTeamFlag('El Tri'),
            equals(TeamLogoHelper.getTeamFlag('MEX')));
      });

      test('returns flag for Holland', () {
        expect(TeamLogoHelper.getTeamFlag('Holland'),
            equals(TeamLogoHelper.getTeamFlag('NED')));
      });

      test('returns flag for Brasil', () {
        expect(TeamLogoHelper.getTeamFlag('Brasil'),
            equals(TeamLogoHelper.getTeamFlag('BRA')));
      });

      test('returns flag for La Albiceleste', () {
        expect(TeamLogoHelper.getTeamFlag('La Albiceleste'),
            equals(TeamLogoHelper.getTeamFlag('ARG')));
      });

      test('returns flag for Three Lions', () {
        expect(TeamLogoHelper.getTeamFlag('Three Lions'),
            equals(TeamLogoHelper.getTeamFlag('ENG')));
      });

      test('returns flag for Les Bleus', () {
        expect(TeamLogoHelper.getTeamFlag('Les Bleus'),
            equals(TeamLogoHelper.getTeamFlag('FRA')));
      });

      test('returns flag for Korea Republic', () {
        expect(TeamLogoHelper.getTeamFlag('Korea Republic'),
            equals(TeamLogoHelper.getTeamFlag('KOR')));
      });

      test('returns flag for IR Iran', () {
        expect(TeamLogoHelper.getTeamFlag('IR Iran'),
            equals(TeamLogoHelper.getTeamFlag('IRN')));
      });

      test('returns flag for Turkiye', () {
        expect(TeamLogoHelper.getTeamFlag('Turkiye'),
            equals(TeamLogoHelper.getTeamFlag('TUR')));
      });
    });

    group('Edge Cases', () {
      test('returns null for null input', () {
        expect(TeamLogoHelper.getTeamFlag(null), isNull);
      });

      test('returns null for empty string', () {
        expect(TeamLogoHelper.getTeamFlag(''), isNull);
      });

      test('returns null for unknown team', () {
        expect(TeamLogoHelper.getTeamFlag('unknown team'), isNull);
      });

      test('returns null for non-qualified team', () {
        expect(TeamLogoHelper.getTeamFlag('Italy'), isNull);
      });

      test('handles whitespace in input', () {
        expect(TeamLogoHelper.getTeamFlag('  USA  '),
            equals(TeamLogoHelper.getTeamFlag('USA')));
      });
    });
  });

  group('TeamLogoHelper - hasTeamLogo', () {
    test('returns true for World Cup teams', () {
      expect(TeamLogoHelper.hasTeamLogo('USA'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('Brazil'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('Argentina'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('England'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('France'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('Germany'), isTrue);
      expect(TeamLogoHelper.hasTeamLogo('Japan'), isTrue);
    });

    test('returns false for non-qualified teams', () {
      expect(TeamLogoHelper.hasTeamLogo('Italy'), isFalse);
      expect(TeamLogoHelper.hasTeamLogo('Sweden'), isFalse);
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

    test('contains country names in lowercase', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, contains('brazil'));
      expect(teams, contains('argentina'));
      expect(teams, contains('united states'));
      expect(teams, contains('mexico'));
      expect(teams, contains('england'));
      expect(teams, contains('france'));
      expect(teams, contains('germany'));
      expect(teams, contains('japan'));
    });

    test('contains common aliases', () {
      final teams = TeamLogoHelper.getAvailableTeams();
      expect(teams, contains('holland'));
      expect(teams, contains('usmnt'));
      expect(teams, contains('el tri'));
      expect(teams, contains('brasil'));
    });
  });

  group('TeamLogoHelper - getAvailableTeamCodes', () {
    test('returns non-empty list', () {
      final codes = TeamLogoHelper.getAvailableTeamCodes();
      expect(codes, isNotEmpty);
    });

    test('contains 49 FIFA codes for World Cup 2026 teams', () {
      final codes = TeamLogoHelper.getAvailableTeamCodes();
      // 48 qualified teams + IRQ (Iraq) = 49
      expect(codes.length, equals(49));
    });

    test('contains expected FIFA codes', () {
      final codes = TeamLogoHelper.getAvailableTeamCodes();
      expect(codes, contains('USA'));
      expect(codes, contains('BRA'));
      expect(codes, contains('ARG'));
      expect(codes, contains('MEX'));
      expect(codes, contains('CAN'));
      expect(codes, contains('ENG'));
      expect(codes, contains('FRA'));
      expect(codes, contains('GER'));
      expect(codes, contains('ESP'));
      expect(codes, contains('JPN'));
      expect(codes, contains('NGA'));
      expect(codes, contains('MAR'));
    });
  });

  group('TeamLogoHelper - getTeamFlagWidget', () {
    testWidgets('returns a Text widget for recognized team', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamLogoHelper.getTeamFlagWidget('USA'),
          ),
        ),
      );

      // Should contain a Text widget with the flag emoji
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('returns a soccer ball Icon for unrecognized team', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamLogoHelper.getTeamFlagWidget('unknown'),
          ),
        ),
      );

      // Should fall back to a sports_soccer icon
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('returns a soccer ball Icon for null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamLogoHelper.getTeamFlagWidget(null),
          ),
        ),
      );

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });

  group('TeamLogoHelper - getTeamLogoWidget', () {
    testWidgets('returns a flag widget for recognized team name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamLogoHelper.getTeamLogoWidget(teamName: 'Brazil'),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('returns a fallback icon for unrecognized team', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamLogoHelper.getTeamLogoWidget(teamName: 'unknown'),
          ),
        ),
      );

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });
  });
}
