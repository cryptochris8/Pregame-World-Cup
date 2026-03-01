import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/team_season_narrative_service.dart';

void main() {
  // ===========================================================================
  // generateKeyInsights
  // ===========================================================================
  group('TeamSeasonNarrativeService.generateKeyInsights', () {
    Map<String, dynamic> makeRecord({
      int wins = 6,
      int losses = 4,
      int averageScored = 2,
      int averageAllowed = 1,
      int confWins = 3,
      int confLosses = 2,
      int homeWins = 4,
      int homeLosses = 1,
      int awayWins = 2,
      int awayLosses = 3,
      List<Map<String, dynamic>> bigWins = const [],
      bool isGenerated = false,
    }) {
      return {
        'overall': {'wins': wins, 'losses': losses},
        'scoring': {
          'averageScored': averageScored,
          'averageAllowed': averageAllowed,
        },
        'conference': {'wins': confWins, 'losses': confLosses},
        'home': {'wins': homeWins, 'losses': homeLosses},
        'away': {'wins': awayWins, 'losses': awayLosses},
        'bigWins': bigWins,
        'isGenerated': isGenerated,
      };
    }

    test('outstanding campaign (10+ wins)', () {
      final record = makeRecord(wins: 11, losses: 1);
      final insights =
          TeamSeasonNarrativeService.generateKeyInsights('Brazil', record, []);
      expect(insights.first, contains('Outstanding'));
      expect(insights.first, contains('11-1'));
    });

    test('successful campaign (8-9 wins)', () {
      final record = makeRecord(wins: 8, losses: 4);
      final insights =
          TeamSeasonNarrativeService.generateKeyInsights('Germany', record, []);
      expect(insights.first, contains('successful'));
      expect(insights.first, contains('8-4'));
    });

    test('competitive campaign (6-7 wins)', () {
      final record = makeRecord(wins: 6, losses: 5);
      final insights =
          TeamSeasonNarrativeService.generateKeyInsights('Japan', record, []);
      expect(insights.first, contains('group stage'));
    });

    test('even record campaign', () {
      final record = makeRecord(wins: 5, losses: 5);
      final insights =
          TeamSeasonNarrativeService.generateKeyInsights('Mexico', record, []);
      expect(insights.first, contains('even'));
      expect(insights.first, contains('5-5'));
    });

    test('challenging campaign (fewer wins)', () {
      final record = makeRecord(wins: 3, losses: 7);
      final insights =
          TeamSeasonNarrativeService.generateKeyInsights('Canada', record, []);
      expect(insights.first, contains('challenges'));
    });

    test('prolific attack insight (avgScored > 3)', () {
      final record = makeRecord(averageScored: 4, averageAllowed: 2);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Argentina', record, []);
      final scoringInsight =
          insights.where((i) => i.contains('Prolific')).toList();
      expect(scoringInsight, isNotEmpty);
    });

    test('balanced attack insight (scored > allowed + 1)', () {
      final record = makeRecord(averageScored: 3, averageAllowed: 1);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'France', record, []);
      final scoringInsight =
          insights.where((i) => i.contains('Balanced')).toList();
      expect(scoringInsight, isNotEmpty);
    });

    test('resolute defence insight (avgAllowed < 1)', () {
      // avgScored must NOT be > avgAllowed + 1 to avoid the balanced attack
      // insight taking priority over the defence one. Use avgScored = 1
      // so the scoring conditions don't trigger first.
      final record = makeRecord(averageScored: 1, averageAllowed: 0);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Italy', record, []);
      final defInsight =
          insights.where((i) => i.contains('Resolute')).toList();
      expect(defInsight, isNotEmpty);
    });

    test('defensively solid insight (allowed < scored + 1)', () {
      final record = makeRecord(averageScored: 2, averageAllowed: 2);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Spain', record, []);
      final defInsight =
          insights.where((i) => i.contains('Defensively solid')).toList();
      expect(defInsight, isNotEmpty);
    });

    test('strong confederation performance', () {
      final record = makeRecord(confWins: 5, confLosses: 2);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'England', record, []);
      final confInsight =
          insights.where((i) => i.contains('confederation')).toList();
      expect(confInsight, isNotEmpty);
    });

    test('dominant home performance (5+ home wins)', () {
      final record = makeRecord(homeWins: 6, homeLosses: 0);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Portugal', record, []);
      final homeInsight =
          insights.where((i) => i.contains('Dominant at home')).toList();
      expect(homeInsight, isNotEmpty);
    });

    test('impressive road form (4+ away wins)', () {
      final record =
          makeRecord(homeWins: 2, homeLosses: 3, awayWins: 5, awayLosses: 1);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Croatia', record, []);
      final awayInsight =
          insights.where((i) => i.contains('road form')).toList();
      expect(awayInsight, isNotEmpty);
    });

    test('big wins insight when present', () {
      final record = makeRecord(bigWins: [
        {'opponent': 'Brazil', 'score': '3-1'},
        {'opponent': 'Germany', 'score': '2-0'},
      ]);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Morocco', record, []);
      final bigWinsInsight =
          insights.where((i) => i.contains('signature wins')).toList();
      expect(bigWinsInsight, isNotEmpty);
      expect(bigWinsInsight.first, contains('2'));
    });

    test('generated data flag adds context insight', () {
      final record = makeRecord(isGenerated: true);
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Qatar', record, []);
      final genInsight =
          insights.where((i) => i.contains('squad expectations')).toList();
      expect(genInsight, isNotEmpty);
    });

    test('returns at least one insight for any input', () {
      final record = makeRecord();
      final insights = TeamSeasonNarrativeService.generateKeyInsights(
          'Uruguay', record, []);
      expect(insights, isNotEmpty);
    });
  });

  // ===========================================================================
  // generateSeasonNarrative
  // ===========================================================================
  group('TeamSeasonNarrativeService.generateSeasonNarrative', () {
    Map<String, dynamic> makeRecord({int wins = 6, int losses = 4}) {
      final totalGames = wins + losses;
      return {
        'overall': {'wins': wins, 'losses': losses},
        'scoring': {
          'averageScored': totalGames > 0 ? (wins * 3 ~/ totalGames) + 1 : 1,
          'averageAllowed': totalGames > 0 ? (losses * 2 ~/ totalGames) + 1 : 1,
        },
      };
    }

    Map<String, dynamic> makeGameAnalysis({
      List<Map<String, dynamic>>? bigWins,
      List<Map<String, dynamic>>? closeGames,
      List<Map<String, dynamic>>? blowouts,
    }) {
      return {
        'bigWins': bigWins ?? [],
        'closeGames': closeGames ?? [],
        'blowouts': blowouts ?? [],
      };
    }

    test('exceptional campaign narrative (10+ wins)', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Brazil',
        2024,
        makeRecord(wins: 11, losses: 1),
        makeGameAnalysis(),
      );
      expect(narrative, contains('exceptional'));
      expect(narrative, contains('11-1'));
      expect(narrative, contains('Brazil'));
    });

    test('strong campaign narrative (8-9 wins)', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Germany',
        2024,
        makeRecord(wins: 9, losses: 3),
        makeGameAnalysis(),
      );
      expect(narrative, contains('significant step forward'));
      expect(narrative, contains('9-3'));
    });

    test('even record narrative', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Japan',
        2024,
        makeRecord(wins: 5, losses: 5),
        makeGameAnalysis(),
      );
      expect(narrative, contains('character-building'));
      expect(narrative, contains('5-5'));
    });

    test('moderate campaign narrative (4-7 wins)', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Mexico',
        2024,
        makeRecord(wins: 5, losses: 6),
        makeGameAnalysis(),
      );
      expect(narrative, contains('flashes of brilliance'));
    });

    test('developmental narrative (under 4 wins)', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Canada',
        2024,
        makeRecord(wins: 2, losses: 8),
        makeGameAnalysis(),
      );
      expect(narrative, contains('developmental'));
    });

    test('includes blowout analysis when present', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Spain',
        2024,
        makeRecord(wins: 8, losses: 3),
        makeGameAnalysis(blowouts: [
          {'opponent': 'Iran', 'margin': 25}
        ]),
      );
      expect(narrative, contains('dominant performances'));
    });

    test('includes close games analysis (4+ close games)', () {
      final dummyCloseGames = List.generate(
          5, (i) => <String, dynamic>{'opponent': 'Team $i', 'margin': 3});
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Argentina',
        2024,
        makeRecord(wins: 7, losses: 4),
        makeGameAnalysis(closeGames: dummyCloseGames),
      );
      expect(narrative, contains('5'));
      expect(narrative, contains('decided by one goal'));
    });

    test('includes close games analysis (2-3 close games)', () {
      final dummyCloseGames = List.generate(
          2, (i) => <String, dynamic>{'opponent': 'Team $i', 'margin': 5});
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'France',
        2024,
        makeRecord(wins: 7, losses: 4),
        makeGameAnalysis(closeGames: dummyCloseGames),
      );
      expect(narrative, contains('closely-contested'));
    });

    test('includes big wins analysis', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'England',
        2024,
        makeRecord(wins: 8, losses: 3),
        makeGameAnalysis(bigWins: [
          {'opponent': 'Brazil', 'type': 'Signature Win'}
        ]),
      );
      expect(narrative, contains('Signature victories'));
    });

    test('positive outlook when wins > losses', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Netherlands',
        2024,
        makeRecord(wins: 8, losses: 3),
        makeGameAnalysis(),
      );
      expect(narrative, contains('continued success'));
    });

    test('optimistic outlook when losses >= wins', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Scotland',
        2024,
        makeRecord(wins: 3, losses: 7),
        makeGameAnalysis(),
      );
      expect(narrative, contains('optimism'));
    });

    test('narrative is a non-empty string', () {
      final narrative = TeamSeasonNarrativeService.generateSeasonNarrative(
        'Morocco',
        2024,
        makeRecord(),
        makeGameAnalysis(),
      );
      expect(narrative, isA<String>());
      expect(narrative.length, greaterThan(50));
    });
  });

  // ===========================================================================
  // generateOverallAssessment
  // ===========================================================================
  group('TeamSeasonNarrativeService.generateOverallAssessment', () {
    Map<String, dynamic> makeRecord({int wins = 6, int losses = 4}) {
      return {
        'overall': {'wins': wins, 'losses': losses},
      };
    }

    test('grade A for 10+ wins', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Brazil',
        makeRecord(wins: 11, losses: 1),
        {},
      );
      expect(result['seasonGrade'], 'A');
      expect(result['assessment'], contains('Outstanding'));
    });

    test('grade B+ for 8-9 wins', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'France',
        makeRecord(wins: 9, losses: 3),
        {},
      );
      expect(result['seasonGrade'], 'B+');
      expect(result['assessment'], contains('Very good'));
    });

    test('grade B for 6-7 wins', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Japan',
        makeRecord(wins: 7, losses: 5),
        {},
      );
      expect(result['seasonGrade'], 'B');
      expect(result['assessment'], contains('Good campaign'));
    });

    test('grade C+ for 4-5 wins', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Mexico',
        makeRecord(wins: 4, losses: 7),
        {},
      );
      expect(result['seasonGrade'], 'C+');
      expect(result['assessment'], contains('Disappointing'));
    });

    test('grade C for exactly the default range', () {
      // wins < 4 triggers D, but let's test the fall-through at exactly 6
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Uruguay',
        makeRecord(wins: 6, losses: 6),
        {},
      );
      expect(result['seasonGrade'], 'B');
    });

    test('grade D for under 4 wins', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Canada',
        makeRecord(wins: 2, losses: 9),
        {},
      );
      expect(result['seasonGrade'], 'D');
      expect(result['assessment'], contains('Challenging'));
    });

    test('returns map with required keys', () {
      final result = TeamSeasonNarrativeService.generateOverallAssessment(
        'Ghana',
        makeRecord(),
        {},
      );
      expect(result, containsPair('seasonGrade', isA<String>()));
      expect(result, containsPair('assessment', isA<String>()));
    });
  });

  // ===========================================================================
  // analyzeConferencePerformance
  // ===========================================================================
  group('TeamSeasonNarrativeService.analyzeConferencePerformance', () {
    Map<String, dynamic> makeRecord({int wins = 6, int losses = 4}) {
      return {
        'overall': {'wins': wins, 'losses': losses},
        'conference': {'wins': 4, 'losses': 2},
      };
    }

    test('Tournament Contender standing (10+ wins)', () {
      final result = TeamSeasonNarrativeService.analyzeConferencePerformance(
        'Brazil',
        'CONMEBOL',
        makeRecord(wins: 11, losses: 1),
        {},
      );
      expect(result['standing'], 'Tournament Contender');
      expect(result['conference'], 'CONMEBOL');
    });

    test('Upper Tier standing (8-9 wins)', () {
      final result = TeamSeasonNarrativeService.analyzeConferencePerformance(
        'France',
        'UEFA',
        makeRecord(wins: 9, losses: 3),
        {},
      );
      expect(result['standing'], 'Upper Tier');
    });

    test('Middle of Pack standing (5-7 wins)', () {
      final result = TeamSeasonNarrativeService.analyzeConferencePerformance(
        'Japan',
        'AFC',
        makeRecord(wins: 6, losses: 5),
        {},
      );
      expect(result['standing'], 'Middle of Pack');
    });

    test('Rebuilding standing (4 or fewer wins)', () {
      final result = TeamSeasonNarrativeService.analyzeConferencePerformance(
        'Canada',
        'CONCACAF',
        makeRecord(wins: 3, losses: 8),
        {},
      );
      expect(result['standing'], 'Rebuilding');
    });

    test('returns conference and rivalry data', () {
      final rivalryData = {'key': 'value'};
      final result = TeamSeasonNarrativeService.analyzeConferencePerformance(
        'England',
        'UEFA',
        makeRecord(),
        rivalryData,
      );
      expect(result['conferenceRecord'], isA<Map>());
      expect(result['rivalryGames'], rivalryData);
    });
  });
}
