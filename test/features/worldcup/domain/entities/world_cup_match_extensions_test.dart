import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match_enums.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match_extensions.dart';

void main() {
  // Helper to create a basic WorldCupMatch
  WorldCupMatch createMatch({
    MatchStage stage = MatchStage.groupStage,
    MatchStatus status = MatchStatus.scheduled,
    int? homeScore,
    int? awayScore,
    int? homeExtraTimeScore,
    int? awayExtraTimeScore,
    int? homePenaltyScore,
    int? awayPenaltyScore,
    int? minute,
    int? addedTime,
    DateTime? dateTime,
  }) {
    return WorldCupMatch(
      matchId: 'match_1',
      matchNumber: 1,
      stage: stage,
      homeTeamName: 'USA',
      awayTeamName: 'Mexico',
      homeTeamCode: 'USA',
      awayTeamCode: 'MEX',
      status: status,
      homeScore: homeScore,
      awayScore: awayScore,
      homeExtraTimeScore: homeExtraTimeScore,
      awayExtraTimeScore: awayExtraTimeScore,
      homePenaltyScore: homePenaltyScore,
      awayPenaltyScore: awayPenaltyScore,
      minute: minute,
      addedTime: addedTime,
      dateTime: dateTime,
    );
  }

  group('WorldCupMatchDisplayExtension', () {
    group('hasExtraTime', () {
      test('returns false when no extra time scores', () {
        final match = createMatch();
        expect(match.hasExtraTime, isFalse);
      });

      test('returns true when home extra time score exists', () {
        final match = createMatch(homeExtraTimeScore: 1);
        expect(match.hasExtraTime, isTrue);
      });

      test('returns true when away extra time score exists', () {
        final match = createMatch(awayExtraTimeScore: 0);
        expect(match.hasExtraTime, isTrue);
      });

      test('returns true when both extra time scores exist', () {
        final match = createMatch(homeExtraTimeScore: 1, awayExtraTimeScore: 0);
        expect(match.hasExtraTime, isTrue);
      });
    });

    group('hasPenalties', () {
      test('returns false when no penalty scores', () {
        final match = createMatch();
        expect(match.hasPenalties, isFalse);
      });

      test('returns true when home penalty score exists', () {
        final match = createMatch(homePenaltyScore: 4);
        expect(match.hasPenalties, isTrue);
      });

      test('returns true when away penalty score exists', () {
        final match = createMatch(awayPenaltyScore: 3);
        expect(match.hasPenalties, isTrue);
      });

      test('returns true when both penalty scores exist', () {
        final match = createMatch(homePenaltyScore: 4, awayPenaltyScore: 3);
        expect(match.hasPenalties, isTrue);
      });
    });

    group('homeTotalScore', () {
      test('returns null when homeScore is null', () {
        final match = createMatch();
        expect(match.homeTotalScore, isNull);
      });

      test('returns homeScore when no extra time', () {
        final match = createMatch(homeScore: 2, awayScore: 1);
        expect(match.homeTotalScore, equals(2));
      });

      test('adds extra time score to home score', () {
        final match = createMatch(
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 1,
        );
        expect(match.homeTotalScore, equals(2));
      });
    });

    group('awayTotalScore', () {
      test('returns null when awayScore is null', () {
        final match = createMatch();
        expect(match.awayTotalScore, isNull);
      });

      test('returns awayScore when no extra time', () {
        final match = createMatch(homeScore: 2, awayScore: 1);
        expect(match.awayTotalScore, equals(1));
      });

      test('adds extra time score to away score', () {
        final match = createMatch(
          homeScore: 1,
          awayScore: 1,
          awayExtraTimeScore: 2,
        );
        expect(match.awayTotalScore, equals(3));
      });
    });

    group('scoreDisplay', () {
      test('returns dash when scores are null', () {
        final match = createMatch();
        expect(match.scoreDisplay, equals('-'));
      });

      test('returns simple score for regular time', () {
        final match = createMatch(homeScore: 2, awayScore: 1);
        expect(match.scoreDisplay, equals('2-1'));
      });

      test('returns total score with AET for knockout matches going to extra time with draw', () {
        final match = createMatch(
          stage: MatchStage.roundOf16,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
        );
        // total is 1-1, which is a draw in knockout => AET
        expect(match.scoreDisplay, equals('1-1 AET'));
      });

      test('returns total score without AET when extra time decides winner in knockout', () {
        final match = createMatch(
          stage: MatchStage.quarterFinal,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 0,
        );
        // total is 2-1, not a draw => no AET suffix
        expect(match.scoreDisplay, equals('2-1'));
      });

      test('does not add AET for group stage even if extra time exists', () {
        // Group stage should not show AET (groupStage.isKnockout is false)
        final match = createMatch(
          stage: MatchStage.groupStage,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
        );
        expect(match.scoreDisplay, equals('1-1'));
      });

      test('includes penalty scores', () {
        final match = createMatch(
          stage: MatchStage.semiFinal,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
          homePenaltyScore: 4,
          awayPenaltyScore: 3,
        );
        expect(match.scoreDisplay, equals('1-1 AET (4-3 pen)'));
      });

      test('includes penalty scores for final', () {
        final match = createMatch(
          stage: MatchStage.final_,
          homeScore: 2,
          awayScore: 2,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 1,
          homePenaltyScore: 5,
          awayPenaltyScore: 4,
        );
        expect(match.scoreDisplay, equals('3-3 AET (5-4 pen)'));
      });

      test('handles one-sided extra time with penalties', () {
        final match = createMatch(
          stage: MatchStage.roundOf32,
          homeScore: 0,
          awayScore: 0,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
          homePenaltyScore: 3,
          awayPenaltyScore: 2,
        );
        expect(match.scoreDisplay, equals('0-0 AET (3-2 pen)'));
      });
    });

    group('timeDisplay', () {
      test('returns formatted time for scheduled matches', () {
        final match = createMatch(
          status: MatchStatus.scheduled,
          dateTime: DateTime(2026, 6, 14, 18, 0),
        );
        expect(match.timeDisplay, equals('18:00'));
      });

      test('returns TBD for scheduled matches without dateTime', () {
        final match = createMatch(status: MatchStatus.scheduled);
        expect(match.timeDisplay, equals('TBD'));
      });

      test('returns HT for half time', () {
        final match = createMatch(status: MatchStatus.halfTime);
        expect(match.timeDisplay, equals('HT'));
      });

      test('returns FT for completed', () {
        final match = createMatch(status: MatchStatus.completed);
        expect(match.timeDisplay, equals('FT'));
      });

      test('returns PEN for penalties', () {
        final match = createMatch(status: MatchStatus.penalties);
        expect(match.timeDisplay, equals('PEN'));
      });

      test('returns ET for extra time without minute', () {
        final match = createMatch(status: MatchStatus.extraTime);
        expect(match.timeDisplay, equals('ET'));
      });

      test('returns minute with prime for extra time with minute', () {
        final match = createMatch(
          status: MatchStatus.extraTime,
          minute: 105,
        );
        expect(match.timeDisplay, equals("105'"));
      });

      test('returns minute with added time for extra time', () {
        final match = createMatch(
          status: MatchStatus.extraTime,
          minute: 90,
          addedTime: 3,
        );
        // The extension logic: minute! > 90? minute : minute! + 90 => 90 is not > 90 => 180
        // then addedTime != null => "180+3'"
        expect(match.timeDisplay, equals("180+3'"));
      });

      test('returns minute for in-progress matches', () {
        final match = createMatch(
          status: MatchStatus.inProgress,
          minute: 45,
        );
        expect(match.timeDisplay, equals("45'"));
      });

      test('returns minute with added time for in-progress', () {
        final match = createMatch(
          status: MatchStatus.inProgress,
          minute: 45,
          addedTime: 2,
        );
        expect(match.timeDisplay, equals("45+2'"));
      });

      test('returns LIVE for in-progress without minute', () {
        final match = createMatch(status: MatchStatus.inProgress);
        expect(match.timeDisplay, equals('LIVE'));
      });
    });
  });

  group('WorldCupMatchParsers', () {
    group('parseMatchStage', () {
      test('returns groupStage for null', () {
        expect(WorldCupMatchParsers.parseMatchStage(null), equals(MatchStage.groupStage));
      });

      test('parses groupStage variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('groupstage'), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage('group_stage'), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage('group'), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage('GROUPSTAGE'), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage('Group_Stage'), equals(MatchStage.groupStage));
      });

      test('parses roundOf32 variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('roundof32'), equals(MatchStage.roundOf32));
        expect(WorldCupMatchParsers.parseMatchStage('round_of_32'), equals(MatchStage.roundOf32));
        expect(WorldCupMatchParsers.parseMatchStage('r32'), equals(MatchStage.roundOf32));
        expect(WorldCupMatchParsers.parseMatchStage('R32'), equals(MatchStage.roundOf32));
      });

      test('parses roundOf16 variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('roundof16'), equals(MatchStage.roundOf16));
        expect(WorldCupMatchParsers.parseMatchStage('round_of_16'), equals(MatchStage.roundOf16));
        expect(WorldCupMatchParsers.parseMatchStage('r16'), equals(MatchStage.roundOf16));
      });

      test('parses quarterFinal variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('quarterfinal'), equals(MatchStage.quarterFinal));
        expect(WorldCupMatchParsers.parseMatchStage('quarter_final'), equals(MatchStage.quarterFinal));
        expect(WorldCupMatchParsers.parseMatchStage('qf'), equals(MatchStage.quarterFinal));
        expect(WorldCupMatchParsers.parseMatchStage('QF'), equals(MatchStage.quarterFinal));
      });

      test('parses semiFinal variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('semifinal'), equals(MatchStage.semiFinal));
        expect(WorldCupMatchParsers.parseMatchStage('semi_final'), equals(MatchStage.semiFinal));
        expect(WorldCupMatchParsers.parseMatchStage('sf'), equals(MatchStage.semiFinal));
      });

      test('parses thirdPlace variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('thirdplace'), equals(MatchStage.thirdPlace));
        expect(WorldCupMatchParsers.parseMatchStage('third_place'), equals(MatchStage.thirdPlace));
        expect(WorldCupMatchParsers.parseMatchStage('3rd'), equals(MatchStage.thirdPlace));
      });

      test('parses final variants', () {
        expect(WorldCupMatchParsers.parseMatchStage('final'), equals(MatchStage.final_));
        expect(WorldCupMatchParsers.parseMatchStage('final_'), equals(MatchStage.final_));
        expect(WorldCupMatchParsers.parseMatchStage('FINAL'), equals(MatchStage.final_));
      });

      test('returns groupStage for unknown values', () {
        expect(WorldCupMatchParsers.parseMatchStage('unknown'), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage(''), equals(MatchStage.groupStage));
        expect(WorldCupMatchParsers.parseMatchStage('xyz'), equals(MatchStage.groupStage));
      });
    });

    group('parseMatchStatus', () {
      test('returns scheduled for null', () {
        expect(WorldCupMatchParsers.parseMatchStatus(null), equals(MatchStatus.scheduled));
      });

      test('parses scheduled', () {
        expect(WorldCupMatchParsers.parseMatchStatus('scheduled'), equals(MatchStatus.scheduled));
        expect(WorldCupMatchParsers.parseMatchStatus('SCHEDULED'), equals(MatchStatus.scheduled));
      });

      test('parses inProgress variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('inprogress'), equals(MatchStatus.inProgress));
        expect(WorldCupMatchParsers.parseMatchStatus('in_progress'), equals(MatchStatus.inProgress));
        expect(WorldCupMatchParsers.parseMatchStatus('live'), equals(MatchStatus.inProgress));
        expect(WorldCupMatchParsers.parseMatchStatus('LIVE'), equals(MatchStatus.inProgress));
      });

      test('parses halfTime variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('halftime'), equals(MatchStatus.halfTime));
        expect(WorldCupMatchParsers.parseMatchStatus('half_time'), equals(MatchStatus.halfTime));
        expect(WorldCupMatchParsers.parseMatchStatus('ht'), equals(MatchStatus.halfTime));
        expect(WorldCupMatchParsers.parseMatchStatus('HT'), equals(MatchStatus.halfTime));
      });

      test('parses extraTime variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('extratime'), equals(MatchStatus.extraTime));
        expect(WorldCupMatchParsers.parseMatchStatus('extra_time'), equals(MatchStatus.extraTime));
        expect(WorldCupMatchParsers.parseMatchStatus('et'), equals(MatchStatus.extraTime));
      });

      test('parses penalties variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('penalties'), equals(MatchStatus.penalties));
        expect(WorldCupMatchParsers.parseMatchStatus('pen'), equals(MatchStatus.penalties));
      });

      test('parses completed variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('completed'), equals(MatchStatus.completed));
        expect(WorldCupMatchParsers.parseMatchStatus('finished'), equals(MatchStatus.completed));
        expect(WorldCupMatchParsers.parseMatchStatus('ft'), equals(MatchStatus.completed));
        expect(WorldCupMatchParsers.parseMatchStatus('FT'), equals(MatchStatus.completed));
      });

      test('parses postponed', () {
        expect(WorldCupMatchParsers.parseMatchStatus('postponed'), equals(MatchStatus.postponed));
      });

      test('parses cancelled variants', () {
        expect(WorldCupMatchParsers.parseMatchStatus('cancelled'), equals(MatchStatus.cancelled));
        expect(WorldCupMatchParsers.parseMatchStatus('canceled'), equals(MatchStatus.cancelled));
      });

      test('returns scheduled for unknown values', () {
        expect(WorldCupMatchParsers.parseMatchStatus('unknown'), equals(MatchStatus.scheduled));
        expect(WorldCupMatchParsers.parseMatchStatus(''), equals(MatchStatus.scheduled));
      });
    });

    group('parseDateTime', () {
      test('returns null for null input', () {
        expect(WorldCupMatchParsers.parseDateTime(null), isNull);
      });

      test('parses ISO 8601 string', () {
        final result = WorldCupMatchParsers.parseDateTime('2026-06-14T18:00:00.000Z');
        expect(result, isNotNull);
        expect(result!.year, equals(2026));
        expect(result.month, equals(6));
        expect(result.day, equals(14));
      });

      test('parses epoch milliseconds (int)', () {
        final expected = DateTime(2026, 6, 14, 18, 0);
        final millis = expected.millisecondsSinceEpoch;
        final result = WorldCupMatchParsers.parseDateTime(millis);
        expect(result, isNotNull);
        expect(result!.millisecondsSinceEpoch, equals(millis));
      });

      test('returns null for invalid string', () {
        final result = WorldCupMatchParsers.parseDateTime('not-a-date');
        expect(result, isNull);
      });

      test('returns null for unsupported type', () {
        final result = WorldCupMatchParsers.parseDateTime(3.14);
        expect(result, isNull);
      });

      test('returns null for boolean input', () {
        final result = WorldCupMatchParsers.parseDateTime(true);
        expect(result, isNull);
      });
    });
  });

  group('MatchStageExtension', () {
    group('displayName', () {
      test('returns correct display names for all stages', () {
        expect(MatchStage.groupStage.displayName, equals('Group Stage'));
        expect(MatchStage.roundOf32.displayName, equals('Round of 32'));
        expect(MatchStage.roundOf16.displayName, equals('Round of 16'));
        expect(MatchStage.quarterFinal.displayName, equals('Quarter-Final'));
        expect(MatchStage.semiFinal.displayName, equals('Semi-Final'));
        expect(MatchStage.thirdPlace.displayName, equals('Third Place Play-off'));
        expect(MatchStage.final_.displayName, equals('Final'));
      });
    });

    group('shortName', () {
      test('returns correct short names for all stages', () {
        expect(MatchStage.groupStage.shortName, equals('Group'));
        expect(MatchStage.roundOf32.shortName, equals('R32'));
        expect(MatchStage.roundOf16.shortName, equals('R16'));
        expect(MatchStage.quarterFinal.shortName, equals('QF'));
        expect(MatchStage.semiFinal.shortName, equals('SF'));
        expect(MatchStage.thirdPlace.shortName, equals('3rd'));
        expect(MatchStage.final_.shortName, equals('Final'));
      });
    });

    group('isKnockout', () {
      test('returns false for group stage', () {
        expect(MatchStage.groupStage.isKnockout, isFalse);
      });

      test('returns true for all knockout stages', () {
        expect(MatchStage.roundOf32.isKnockout, isTrue);
        expect(MatchStage.roundOf16.isKnockout, isTrue);
        expect(MatchStage.quarterFinal.isKnockout, isTrue);
        expect(MatchStage.semiFinal.isKnockout, isTrue);
        expect(MatchStage.thirdPlace.isKnockout, isTrue);
        expect(MatchStage.final_.isKnockout, isTrue);
      });
    });
  });

  group('MatchStatusExtension', () {
    group('displayName', () {
      test('returns correct display names for all statuses', () {
        expect(MatchStatus.scheduled.displayName, equals('Scheduled'));
        expect(MatchStatus.inProgress.displayName, equals('Live'));
        expect(MatchStatus.halfTime.displayName, equals('Half Time'));
        expect(MatchStatus.extraTime.displayName, equals('Extra Time'));
        expect(MatchStatus.penalties.displayName, equals('Penalties'));
        expect(MatchStatus.completed.displayName, equals('Full Time'));
        expect(MatchStatus.postponed.displayName, equals('Postponed'));
        expect(MatchStatus.cancelled.displayName, equals('Cancelled'));
      });
    });

    group('isLive', () {
      test('returns true for live statuses', () {
        expect(MatchStatus.inProgress.isLive, isTrue);
        expect(MatchStatus.halfTime.isLive, isTrue);
        expect(MatchStatus.extraTime.isLive, isTrue);
        expect(MatchStatus.penalties.isLive, isTrue);
      });

      test('returns false for non-live statuses', () {
        expect(MatchStatus.scheduled.isLive, isFalse);
        expect(MatchStatus.completed.isLive, isFalse);
        expect(MatchStatus.postponed.isLive, isFalse);
        expect(MatchStatus.cancelled.isLive, isFalse);
      });
    });
  });
}
