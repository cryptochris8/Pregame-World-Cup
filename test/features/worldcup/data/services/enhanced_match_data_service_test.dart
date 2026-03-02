import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

void main() {
  late EnhancedMatchDataService service;

  setUp(() {
    // Access the singleton - it won't be initialized in test env
    service = EnhancedMatchDataService.instance;
  });

  group('getSquadValue', () {
    test('returns null when not initialized', () {
      expect(service.getSquadValue('USA'), isNull);
    });

    test('returns null for empty team code', () {
      expect(service.getSquadValue(''), isNull);
    });
  });

  group('getSquadValueComparison', () {
    test('returns null when squad values not loaded', () {
      final result = service.getSquadValueComparison('USA', 'MEX');
      expect(result, isNull);
    });
  });

  group('getRecentForm', () {
    test('returns null when not initialized', () {
      expect(service.getRecentForm('USA'), isNull);
    });
  });

  group('getRecentFormSummary', () {
    test('returns null when form data not loaded', () {
      expect(service.getRecentFormSummary('USA'), isNull);
    });
  });

  group('getRelevantPatterns', () {
    test('returns empty list when not initialized', () {
      final result = service.getRelevantPatterns();
      expect(result, isEmpty);
    });

    test('returns empty list with various flags', () {
      expect(service.getRelevantPatterns(isHostNation: true), isEmpty);
      expect(service.getRelevantPatterns(isDefendingChampion: true), isEmpty);
      expect(service.getRelevantPatterns(isDebutant: true), isEmpty);
    });
  });

  group('getConfederationMatchup', () {
    test('returns null when not initialized', () {
      expect(service.getConfederationMatchup('UEFA', 'CONMEBOL'), isNull);
    });
  });

  group('getBettingOdds', () {
    test('returns null when not initialized', () {
      expect(service.getBettingOdds('USA'), isNull);
    });
  });

  group('getUpsetPotential', () {
    test('returns null when betting odds not loaded', () {
      expect(service.getUpsetPotential('USA', 'MEX'), isNull);
    });
  });

  group('getInjuryConcerns', () {
    test('returns empty list when not initialized', () {
      expect(service.getInjuryConcerns('USA'), isEmpty);
    });
  });

  group('getEloRating', () {
    test('returns null when not initialized', () {
      expect(service.getEloRating('USA'), isNull);
    });

    test('returns null for empty team code', () {
      expect(service.getEloRating(''), isNull);
    });

    test('returns null for nonexistent team code', () {
      expect(service.getEloRating('XYZ'), isNull);
    });
  });

  group('buildEnhancedPromptSection', () {
    test('returns empty string for empty context', () {
      final result = service.buildEnhancedPromptSection({});
      expect(result, isEmpty);
    });

    test('includes squad value section', () {
      final context = {
        'squadValueComparison': {
          'narrative': 'USA vastly outspend Jamaica in squad value.',
          'homeMVP': {'name': 'Christian Pulisic', 'value': '\u20ac70M'},
          'awayMVP': {'name': 'Michail Antonio', 'value': '\u20ac8M'},
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('SQUAD VALUE SHOWDOWN'));
      expect(result, contains('USA vastly outspend Jamaica'));
      expect(result, contains('Home MVP: Christian Pulisic'));
      expect(result, contains('Away MVP: Michail Antonio'));
    });

    test('includes squad value without MVPs', () {
      final context = {
        'squadValueComparison': {
          'narrative': 'Comparable squad values.',
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('SQUAD VALUE SHOWDOWN'));
      expect(result, contains('Comparable squad values.'));
      expect(result, isNot(contains('Home MVP')));
    });

    test('includes recent form section', () {
      final context = {
        'recentForm': {
          'home': 'Last 5 matches: 3W 1D 1L',
          'away': 'Last 5 matches: 2W 2D 1L',
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('RECENT INTERNATIONAL FORM'));
      expect(result, contains('Home: Last 5 matches: 3W 1D 1L'));
      expect(result, contains('Away: Last 5 matches: 2W 2D 1L'));
    });

    test('includes manager matchup section', () {
      final context = {
        'managerMatchup': {
          'home': {
            'name': 'Mauricio Pochettino',
            'formation': '4-3-3',
            'style': 'Attacking',
            'winRate': 55,
          },
          'away': {
            'name': 'Javier Aguirre',
            'formation': '4-4-2',
            'style': 'Defensive',
            'winRate': 48,
          },
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('MANAGER CHESS'));
      expect(result, contains('Mauricio Pochettino'));
      expect(result, contains('4-3-3'));
      expect(result, contains('Attacking'));
      expect(result, contains('Javier Aguirre'));
    });

    test('includes historical patterns section', () {
      final context = {
        'historicalPatterns': [
          'Host nations reach at least the quarterfinals 75% of the time',
          'Group stage sees 2.4 goals per match on average',
        ],
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('HISTORICAL PATTERNS'));
      expect(result, contains('Host nations reach'));
      expect(result, contains('Group stage sees'));
    });

    test('includes confederation clash section', () {
      final context = {
        'confederationClash': {
          'summary': 'UEFA vs CONMEBOL: 156 matches, UEFA leads 72-51',
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('CONFEDERATION CLASH'));
      expect(result, contains('UEFA vs CONMEBOL'));
    });

    test('includes upset alert section', () {
      final context = {
        'upsetAlert': {
          'narrative':
              'Upset Alert: The odds suggest this could be closer than expected.',
          'underdogChance': '28%',
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('UPSET ALERT'));
      expect(result, contains('closer than expected'));
      expect(result, contains('28%'));
    });

    test('includes injury concerns section', () {
      final context = {
        'injuryConcerns': {
          'home': ['Christian Pulisic (hamstring)', 'Weston McKennie (knee)'],
          'away': ['Hirving Lozano (ACL)'],
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('INJURY CONCERNS'));
      expect(result, contains('Home: Christian Pulisic'));
      expect(result, contains('Away: Hirving Lozano'));
    });

    test('skips injury section when lists are empty', () {
      final context = {
        'injuryConcerns': {
          'home': <dynamic>[],
          'away': <dynamic>[],
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, isNot(contains('INJURY CONCERNS')));
    });

    test('combines all sections', () {
      final context = {
        'squadValueComparison': {
          'narrative': 'Comparable squad values.',
        },
        'recentForm': {
          'home': 'Last 5: 3W 1D 1L',
          'away': 'Last 5: 2W 2D 1L',
        },
        'historicalPatterns': ['Pattern 1'],
        'upsetAlert': {
          'narrative': 'Upset possible.',
          'underdogChance': '30%',
        },
      };
      final result = service.buildEnhancedPromptSection(context);
      expect(result, contains('SQUAD VALUE SHOWDOWN'));
      expect(result, contains('RECENT INTERNATIONAL FORM'));
      expect(result, contains('HISTORICAL PATTERNS'));
      expect(result, contains('UPSET ALERT'));
    });
  });
}
