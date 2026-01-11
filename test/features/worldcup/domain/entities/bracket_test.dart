import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/bracket.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match.dart';

void main() {
  group('BracketSlot', () {
    BracketSlot createTestSlot({
      String slotId = 'R32-1',
      MatchStage stage = MatchStage.roundOf32,
      int matchNumberInStage = 1,
      String? teamCode,
      String teamNameOrPlaceholder = 'Winner Group A',
      String? flagUrl,
      String? source,
      String? matchId,
      bool isConfirmed = false,
      bool? hasAdvanced,
      int? score,
      int? penaltyScore,
    }) {
      return BracketSlot(
        slotId: slotId,
        stage: stage,
        matchNumberInStage: matchNumberInStage,
        teamCode: teamCode,
        teamNameOrPlaceholder: teamNameOrPlaceholder,
        flagUrl: flagUrl,
        source: source,
        matchId: matchId,
        isConfirmed: isConfirmed,
        hasAdvanced: hasAdvanced,
        score: score,
        penaltyScore: penaltyScore,
      );
    }

    group('Constructor', () {
      test('creates slot with required fields', () {
        final slot = createTestSlot();

        expect(slot.slotId, equals('R32-1'));
        expect(slot.stage, equals(MatchStage.roundOf32));
        expect(slot.matchNumberInStage, equals(1));
        expect(slot.teamNameOrPlaceholder, equals('Winner Group A'));
        expect(slot.isConfirmed, isFalse);
      });

      test('creates confirmed slot with team details', () {
        final slot = createTestSlot(
          teamCode: 'USA',
          teamNameOrPlaceholder: 'United States',
          flagUrl: 'https://flags.com/usa.png',
          isConfirmed: true,
          hasAdvanced: true,
          score: 2,
        );

        expect(slot.teamCode, equals('USA'));
        expect(slot.isConfirmed, isTrue);
        expect(slot.hasAdvanced, isTrue);
        expect(slot.score, equals(2));
      });

      test('creates slot with penalty score', () {
        final slot = createTestSlot(
          score: 1,
          penaltyScore: 4,
        );

        expect(slot.score, equals(1));
        expect(slot.penaltyScore, equals(4));
      });
    });

    group('Convenience getters', () {
      test('placeholder returns teamNameOrPlaceholder', () {
        final slot = createTestSlot(teamNameOrPlaceholder: 'Winner Group B');
        expect(slot.placeholder, equals('Winner Group B'));
      });

      test('teamName returns teamNameOrPlaceholder', () {
        final slot = createTestSlot(
          teamNameOrPlaceholder: 'Brazil',
          isConfirmed: true,
        );
        expect(slot.teamName, equals('Brazil'));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final slot = createTestSlot(
          teamCode: 'ARG',
          teamNameOrPlaceholder: 'Argentina',
          isConfirmed: true,
          hasAdvanced: true,
          score: 3,
          penaltyScore: 5,
          source: '1A',
          matchId: 'match_73',
        );
        final map = slot.toMap();

        expect(map['slotId'], equals('R32-1'));
        expect(map['stage'], equals('roundOf32'));
        expect(map['matchNumberInStage'], equals(1));
        expect(map['teamCode'], equals('ARG'));
        expect(map['teamNameOrPlaceholder'], equals('Argentina'));
        expect(map['isConfirmed'], isTrue);
        expect(map['hasAdvanced'], isTrue);
        expect(map['score'], equals(3));
        expect(map['penaltyScore'], equals(5));
        expect(map['source'], equals('1A'));
        expect(map['matchId'], equals('match_73'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'slotId': 'QF-2',
          'stage': 'quarterFinal',
          'matchNumberInStage': 2,
          'teamCode': 'GER',
          'teamNameOrPlaceholder': 'Germany',
          'isConfirmed': true,
          'hasAdvanced': false,
          'score': 1,
        };

        final slot = BracketSlot.fromMap(map);

        expect(slot.slotId, equals('QF-2'));
        expect(slot.stage, equals(MatchStage.quarterFinal));
        expect(slot.matchNumberInStage, equals(2));
        expect(slot.teamCode, equals('GER'));
        expect(slot.isConfirmed, isTrue);
        expect(slot.hasAdvanced, isFalse);
        expect(slot.score, equals(1));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestSlot(
          slotId: 'SF-1',
          stage: MatchStage.semiFinal,
          teamCode: 'FRA',
          teamNameOrPlaceholder: 'France',
          isConfirmed: true,
          score: 2,
        );
        final map = original.toMap();
        final restored = BracketSlot.fromMap(map);

        expect(restored.slotId, equals(original.slotId));
        expect(restored.stage, equals(original.stage));
        expect(restored.teamCode, equals(original.teamCode));
        expect(restored.isConfirmed, equals(original.isConfirmed));
        expect(restored.score, equals(original.score));
      });

      test('fromMap handles missing optional fields', () {
        final map = <String, dynamic>{
          'slotId': 'R16-1',
          'stage': 'roundOf16',
          'matchNumberInStage': 1,
          'teamNameOrPlaceholder': 'TBD',
        };

        final slot = BracketSlot.fromMap(map);

        expect(slot.teamCode, isNull);
        expect(slot.flagUrl, isNull);
        expect(slot.hasAdvanced, isNull);
        expect(slot.score, isNull);
        expect(slot.isConfirmed, isFalse);
      });
    });

    group('Stage parsing', () {
      test('parses all valid stage strings', () {
        expect(BracketSlot.fromMap({'stage': 'roundOf32', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.roundOf32));
        expect(BracketSlot.fromMap({'stage': 'roundOf16', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.roundOf16));
        expect(BracketSlot.fromMap({'stage': 'quarterFinal', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.quarterFinal));
        expect(BracketSlot.fromMap({'stage': 'semiFinal', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.semiFinal));
        expect(BracketSlot.fromMap({'stage': 'thirdPlace', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.thirdPlace));
        expect(BracketSlot.fromMap({'stage': 'final_', 'slotId': '', 'matchNumberInStage': 0, 'teamNameOrPlaceholder': ''}).stage,
            equals(MatchStage.final_));
      });

      test('defaults to roundOf32 for unknown stage', () {
        final slot = BracketSlot.fromMap({
          'stage': 'unknown',
          'slotId': '',
          'matchNumberInStage': 0,
          'teamNameOrPlaceholder': '',
        });
        expect(slot.stage, equals(MatchStage.roundOf32));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestSlot();
        final updated = original.copyWith(
          teamCode: 'BRA',
          isConfirmed: true,
          score: 3,
        );

        expect(updated.teamCode, equals('BRA'));
        expect(updated.isConfirmed, isTrue);
        expect(updated.score, equals(3));
        expect(updated.slotId, equals(original.slotId));
      });
    });

    group('Equatable', () {
      test('two slots with same props are equal', () {
        final slot1 = createTestSlot();
        final slot2 = createTestSlot();

        expect(slot1, equals(slot2));
      });

      test('two slots with different slotId are not equal', () {
        final slot1 = createTestSlot(slotId: 'R32-1');
        final slot2 = createTestSlot(slotId: 'R32-2');

        expect(slot1, isNot(equals(slot2)));
      });
    });
  });

  group('BracketMatch', () {
    BracketSlot createSlot({
      String slotId = 'slot',
      String teamCode = 'USA',
      String teamName = 'United States',
      bool isConfirmed = true,
      int? score,
    }) {
      return BracketSlot(
        slotId: slotId,
        stage: MatchStage.roundOf32,
        matchNumberInStage: 1,
        teamCode: teamCode,
        teamNameOrPlaceholder: teamName,
        isConfirmed: isConfirmed,
        score: score,
      );
    }

    BracketMatch createTestMatch({
      String matchId = 'match_73',
      int matchNumber = 73,
      MatchStage stage = MatchStage.roundOf32,
      int matchNumberInStage = 1,
      BracketSlot? homeSlot,
      BracketSlot? awaySlot,
      String? advancesToSlotId,
      MatchStatus status = MatchStatus.scheduled,
      String? venueId,
      DateTime? dateTime,
      String? winnerCode,
    }) {
      return BracketMatch(
        matchId: matchId,
        matchNumber: matchNumber,
        stage: stage,
        matchNumberInStage: matchNumberInStage,
        homeSlot: homeSlot ?? createSlot(slotId: 'home', teamCode: 'USA', teamName: 'United States'),
        awaySlot: awaySlot ?? createSlot(slotId: 'away', teamCode: 'MEX', teamName: 'Mexico'),
        advancesToSlotId: advancesToSlotId,
        status: status,
        venueId: venueId,
        dateTime: dateTime,
        winnerCode: winnerCode,
      );
    }

    group('Constructor', () {
      test('creates match with required fields', () {
        final match = createTestMatch();

        expect(match.matchId, equals('match_73'));
        expect(match.matchNumber, equals(73));
        expect(match.stage, equals(MatchStage.roundOf32));
        expect(match.status, equals(MatchStatus.scheduled));
      });

      test('creates match with all fields', () {
        final match = createTestMatch(
          advancesToSlotId: 'R16-1',
          venueId: 'metlife',
          dateTime: DateTime(2026, 7, 1, 18, 0),
          winnerCode: 'USA',
          status: MatchStatus.completed,
        );

        expect(match.advancesToSlotId, equals('R16-1'));
        expect(match.venueId, equals('metlife'));
        expect(match.dateTime, equals(DateTime(2026, 7, 1, 18, 0)));
        expect(match.winnerCode, equals('USA'));
      });
    });

    group('Computed getters', () {
      test('teamsConfirmed returns true when both teams confirmed', () {
        final match = createTestMatch(
          homeSlot: createSlot(isConfirmed: true),
          awaySlot: createSlot(isConfirmed: true),
        );
        expect(match.teamsConfirmed, isTrue);
      });

      test('teamsConfirmed returns false when one team not confirmed', () {
        final match = createTestMatch(
          homeSlot: createSlot(isConfirmed: true),
          awaySlot: createSlot(isConfirmed: false),
        );
        expect(match.teamsConfirmed, isFalse);
      });

      test('isComplete returns true for completed status', () {
        final match = createTestMatch(status: MatchStatus.completed);
        expect(match.isComplete, isTrue);
        expect(match.isCompleted, isTrue);
      });

      test('isLive returns true for live statuses', () {
        expect(createTestMatch(status: MatchStatus.inProgress).isLive, isTrue);
        expect(createTestMatch(status: MatchStatus.halfTime).isLive, isTrue);
        expect(createTestMatch(status: MatchStatus.extraTime).isLive, isTrue);
        expect(createTestMatch(status: MatchStatus.penalties).isLive, isTrue);
        expect(createTestMatch(status: MatchStatus.scheduled).isLive, isFalse);
        expect(createTestMatch(status: MatchStatus.completed).isLive, isFalse);
      });

      test('team1 and team2 are aliases', () {
        final match = createTestMatch();
        expect(match.team1, equals(match.homeSlot));
        expect(match.team2, equals(match.awaySlot));
      });

      test('penalty score getters', () {
        final homeSlot = BracketSlot(
          slotId: 'home',
          stage: MatchStage.roundOf16,
          matchNumberInStage: 1,
          teamNameOrPlaceholder: 'USA',
          penaltyScore: 4,
        );
        final awaySlot = BracketSlot(
          slotId: 'away',
          stage: MatchStage.roundOf16,
          matchNumberInStage: 1,
          teamNameOrPlaceholder: 'MEX',
          penaltyScore: 3,
        );
        final match = createTestMatch(homeSlot: homeSlot, awaySlot: awaySlot);

        expect(match.team1PenaltyScore, equals(4));
        expect(match.team2PenaltyScore, equals(3));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final match = createTestMatch(
          advancesToSlotId: 'R16-1',
          venueId: 'metlife',
          dateTime: DateTime(2026, 7, 1, 18, 0),
          status: MatchStatus.completed,
          winnerCode: 'USA',
        );
        final map = match.toMap();

        expect(map['matchId'], equals('match_73'));
        expect(map['matchNumber'], equals(73));
        expect(map['stage'], equals('roundOf32'));
        expect(map['homeSlot'], isA<Map<String, dynamic>>());
        expect(map['awaySlot'], isA<Map<String, dynamic>>());
        expect(map['advancesToSlotId'], equals('R16-1'));
        expect(map['status'], equals('completed'));
        expect(map['venueId'], equals('metlife'));
        expect(map['winnerCode'], equals('USA'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'matchId': 'match_89',
          'matchNumber': 89,
          'stage': 'roundOf16',
          'matchNumberInStage': 1,
          'homeSlot': {
            'slotId': 'R16-1-home',
            'stage': 'roundOf16',
            'matchNumberInStage': 1,
            'teamCode': 'ARG',
            'teamNameOrPlaceholder': 'Argentina',
            'isConfirmed': true,
          },
          'awaySlot': {
            'slotId': 'R16-1-away',
            'stage': 'roundOf16',
            'matchNumberInStage': 1,
            'teamCode': 'AUS',
            'teamNameOrPlaceholder': 'Australia',
            'isConfirmed': true,
          },
          'status': 'completed',
          'winnerCode': 'ARG',
        };

        final match = BracketMatch.fromMap(map);

        expect(match.matchId, equals('match_89'));
        expect(match.matchNumber, equals(89));
        expect(match.stage, equals(MatchStage.roundOf16));
        expect(match.homeSlot.teamCode, equals('ARG'));
        expect(match.awaySlot.teamCode, equals('AUS'));
        expect(match.status, equals(MatchStatus.completed));
        expect(match.winnerCode, equals('ARG'));
      });
    });

    group('Equatable', () {
      test('two matches with same props are equal', () {
        final match1 = createTestMatch();
        final match2 = createTestMatch();

        expect(match1, equals(match2));
      });

      test('two matches with different matchId are not equal', () {
        final match1 = createTestMatch(matchId: 'm1');
        final match2 = createTestMatch(matchId: 'm2');

        expect(match1, isNot(equals(match2)));
      });
    });
  });

  group('WorldCupBracket', () {
    BracketMatch createMatch(String id, MatchStage stage, MatchStatus status) {
      return BracketMatch(
        matchId: id,
        matchNumber: 73,
        stage: stage,
        matchNumberInStage: 1,
        homeSlot: BracketSlot(
          slotId: '${id}_home',
          stage: stage,
          matchNumberInStage: 1,
          teamNameOrPlaceholder: 'Team A',
        ),
        awaySlot: BracketSlot(
          slotId: '${id}_away',
          stage: stage,
          matchNumberInStage: 1,
          teamNameOrPlaceholder: 'Team B',
        ),
        status: status,
      );
    }

    WorldCupBracket createTestBracket({
      List<BracketMatch>? roundOf32,
      List<BracketMatch>? roundOf16,
      List<BracketMatch>? quarterFinals,
      List<BracketMatch>? semiFinals,
      BracketMatch? thirdPlace,
      BracketMatch? finalMatch,
      String? championCode,
      String? championName,
      String? runnerUpCode,
      bool isComplete = false,
    }) {
      return WorldCupBracket(
        roundOf32: roundOf32 ?? [createMatch('r32_1', MatchStage.roundOf32, MatchStatus.completed)],
        roundOf16: roundOf16 ?? [createMatch('r16_1', MatchStage.roundOf16, MatchStatus.scheduled)],
        quarterFinals: quarterFinals ?? [],
        semiFinals: semiFinals ?? [],
        thirdPlace: thirdPlace,
        finalMatch: finalMatch,
        championCode: championCode,
        championName: championName,
        runnerUpCode: runnerUpCode,
        isComplete: isComplete,
      );
    }

    group('Constructor', () {
      test('creates bracket with required fields', () {
        final bracket = createTestBracket();

        expect(bracket.roundOf32, hasLength(1));
        expect(bracket.roundOf16, hasLength(1));
        expect(bracket.quarterFinals, isEmpty);
        expect(bracket.semiFinals, isEmpty);
        expect(bracket.isComplete, isFalse);
      });

      test('creates complete bracket', () {
        final bracket = createTestBracket(
          championCode: 'FRA',
          championName: 'France',
          runnerUpCode: 'ARG',
          isComplete: true,
        );

        expect(bracket.championCode, equals('FRA'));
        expect(bracket.championName, equals('France'));
        expect(bracket.runnerUpCode, equals('ARG'));
        expect(bracket.isComplete, isTrue);
      });
    });

    group('allMatches', () {
      test('returns all knockout matches', () {
        final bracket = createTestBracket(
          roundOf32: [createMatch('r32', MatchStage.roundOf32, MatchStatus.completed)],
          roundOf16: [createMatch('r16', MatchStage.roundOf16, MatchStatus.completed)],
          quarterFinals: [createMatch('qf', MatchStage.quarterFinal, MatchStatus.completed)],
          semiFinals: [createMatch('sf', MatchStage.semiFinal, MatchStatus.completed)],
          thirdPlace: createMatch('3rd', MatchStage.thirdPlace, MatchStatus.completed),
          finalMatch: createMatch('final', MatchStage.final_, MatchStatus.completed),
        );

        expect(bracket.allMatches, hasLength(6));
      });

      test('excludes null thirdPlace and finalMatch', () {
        final bracket = createTestBracket(
          roundOf32: [createMatch('r32', MatchStage.roundOf32, MatchStatus.completed)],
          thirdPlace: null,
          finalMatch: null,
        );

        expect(bracket.allMatches, hasLength(2)); // r32 + r16
      });
    });

    group('getMatchesByStage', () {
      test('returns matches for each stage', () {
        final r32Match = createMatch('r32', MatchStage.roundOf32, MatchStatus.completed);
        final r16Match = createMatch('r16', MatchStage.roundOf16, MatchStatus.scheduled);
        final qfMatch = createMatch('qf', MatchStage.quarterFinal, MatchStatus.scheduled);
        final sfMatch = createMatch('sf', MatchStage.semiFinal, MatchStatus.scheduled);
        final thirdMatch = createMatch('3rd', MatchStage.thirdPlace, MatchStatus.scheduled);
        final finalM = createMatch('final', MatchStage.final_, MatchStatus.scheduled);

        final bracket = createTestBracket(
          roundOf32: [r32Match],
          roundOf16: [r16Match],
          quarterFinals: [qfMatch],
          semiFinals: [sfMatch],
          thirdPlace: thirdMatch,
          finalMatch: finalM,
        );

        expect(bracket.getMatchesByStage(MatchStage.roundOf32), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.roundOf16), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.quarterFinal), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.semiFinal), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.thirdPlace), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.final_), hasLength(1));
        expect(bracket.getMatchesByStage(MatchStage.groupStage), isEmpty);
      });
    });

    group('getMatchById', () {
      test('returns match when found', () {
        final bracket = createTestBracket(
          roundOf32: [createMatch('r32_1', MatchStage.roundOf32, MatchStatus.completed)],
        );

        final match = bracket.getMatchById('r32_1');
        expect(match, isNotNull);
        expect(match!.matchId, equals('r32_1'));
      });

      test('returns null when not found', () {
        final bracket = createTestBracket();
        final match = bracket.getMatchById('nonexistent');
        expect(match, isNull);
      });
    });

    group('nextMatch', () {
      test('returns next scheduled match', () {
        final scheduledMatch = BracketMatch(
          matchId: 'next',
          matchNumber: 89,
          stage: MatchStage.roundOf16,
          matchNumberInStage: 1,
          homeSlot: BracketSlot(
            slotId: 'home',
            stage: MatchStage.roundOf16,
            matchNumberInStage: 1,
            teamNameOrPlaceholder: 'TBD',
          ),
          awaySlot: BracketSlot(
            slotId: 'away',
            stage: MatchStage.roundOf16,
            matchNumberInStage: 1,
            teamNameOrPlaceholder: 'TBD',
          ),
          status: MatchStatus.scheduled,
          dateTime: DateTime(2026, 7, 1, 18, 0),
        );

        final bracket = createTestBracket(
          roundOf16: [scheduledMatch],
        );

        final next = bracket.nextMatch;
        expect(next, isNotNull);
        expect(next!.matchId, equals('next'));
      });

      test('returns null when no scheduled matches', () {
        final bracket = createTestBracket(
          roundOf32: [createMatch('r32', MatchStage.roundOf32, MatchStatus.completed)],
          roundOf16: [createMatch('r16', MatchStage.roundOf16, MatchStatus.completed)],
        );

        expect(bracket.nextMatch, isNull);
      });
    });

    group('liveMatches', () {
      test('returns matches with live status', () {
        final liveMatch = createMatch('live', MatchStage.roundOf32, MatchStatus.inProgress);
        final completedMatch = createMatch('completed', MatchStage.roundOf32, MatchStatus.completed);

        final bracket = createTestBracket(
          roundOf32: [liveMatch, completedMatch],
        );

        expect(bracket.liveMatches, hasLength(1));
        expect(bracket.liveMatches.first.matchId, equals('live'));
      });

      test('includes all live statuses', () {
        final matches = [
          createMatch('in_progress', MatchStage.roundOf32, MatchStatus.inProgress),
          createMatch('half_time', MatchStage.roundOf32, MatchStatus.halfTime),
          createMatch('extra_time', MatchStage.roundOf32, MatchStatus.extraTime),
          createMatch('penalties', MatchStage.roundOf32, MatchStatus.penalties),
        ];

        final bracket = createTestBracket(roundOf32: matches);

        expect(bracket.liveMatches, hasLength(4));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final bracket = createTestBracket(
          championCode: 'BRA',
          championName: 'Brazil',
          isComplete: true,
        );
        final map = bracket.toMap();

        expect(map['roundOf32'], hasLength(1));
        expect(map['roundOf16'], hasLength(1));
        expect(map['quarterFinals'], isEmpty);
        expect(map['semiFinals'], isEmpty);
        expect(map['championCode'], equals('BRA'));
        expect(map['championName'], equals('Brazil'));
        expect(map['isComplete'], isTrue);
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'roundOf32': [
            {
              'matchId': 'r32_test',
              'matchNumber': 73,
              'stage': 'roundOf32',
              'matchNumberInStage': 1,
              'homeSlot': {'slotId': 'h', 'stage': 'roundOf32', 'matchNumberInStage': 1, 'teamNameOrPlaceholder': 'A'},
              'awaySlot': {'slotId': 'a', 'stage': 'roundOf32', 'matchNumberInStage': 1, 'teamNameOrPlaceholder': 'B'},
              'status': 'completed',
            }
          ],
          'roundOf16': <Map<String, dynamic>>[],
          'quarterFinals': <Map<String, dynamic>>[],
          'semiFinals': <Map<String, dynamic>>[],
          'championCode': 'GER',
          'isComplete': false,
        };

        final bracket = WorldCupBracket.fromMap(map);

        expect(bracket.roundOf32, hasLength(1));
        expect(bracket.roundOf32.first.matchId, equals('r32_test'));
        expect(bracket.championCode, equals('GER'));
        expect(bracket.isComplete, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestBracket();
        final updated = original.copyWith(
          championCode: 'ARG',
          championName: 'Argentina',
          isComplete: true,
        );

        expect(updated.championCode, equals('ARG'));
        expect(updated.championName, equals('Argentina'));
        expect(updated.isComplete, isTrue);
        expect(updated.roundOf32, equals(original.roundOf32));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final bracket = createTestBracket(
          roundOf32: List.generate(16, (i) => createMatch('r32_$i', MatchStage.roundOf32, MatchStatus.completed)),
          roundOf16: List.generate(8, (i) => createMatch('r16_$i', MatchStage.roundOf16, MatchStatus.scheduled)),
          quarterFinals: List.generate(4, (i) => createMatch('qf_$i', MatchStage.quarterFinal, MatchStatus.scheduled)),
          semiFinals: List.generate(2, (i) => createMatch('sf_$i', MatchStage.semiFinal, MatchStatus.scheduled)),
        );
        final str = bracket.toString();

        expect(str, contains('R32: 16'));
        expect(str, contains('R16: 8'));
        expect(str, contains('QF: 4'));
        expect(str, contains('SF: 2'));
      });
    });
  });

  group('BracketConstants', () {
    test('has correct match counts', () {
      expect(BracketConstants.roundOf32Matches, equals(16));
      expect(BracketConstants.roundOf16Matches, equals(8));
      expect(BracketConstants.quarterFinalMatches, equals(4));
      expect(BracketConstants.semiFinalMatches, equals(2));
      expect(BracketConstants.totalKnockoutMatches, equals(32));
    });

    test('matchNumberRanges has correct values', () {
      expect(BracketConstants.matchNumberRanges[MatchStage.roundOf32], equals([73, 88]));
      expect(BracketConstants.matchNumberRanges[MatchStage.roundOf16], equals([89, 96]));
      expect(BracketConstants.matchNumberRanges[MatchStage.quarterFinal], equals([97, 100]));
      expect(BracketConstants.matchNumberRanges[MatchStage.semiFinal], equals([101, 102]));
      expect(BracketConstants.matchNumberRanges[MatchStage.thirdPlace], equals([103, 103]));
      expect(BracketConstants.matchNumberRanges[MatchStage.final_], equals([104, 104]));
    });
  });
}
