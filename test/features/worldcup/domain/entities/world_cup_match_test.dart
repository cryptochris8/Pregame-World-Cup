import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match.dart';

void main() {
  group('MatchStage', () {
    test('has expected values', () {
      expect(MatchStage.values, hasLength(7));
      expect(MatchStage.values, contains(MatchStage.groupStage));
      expect(MatchStage.values, contains(MatchStage.roundOf32));
      expect(MatchStage.values, contains(MatchStage.roundOf16));
      expect(MatchStage.values, contains(MatchStage.quarterFinal));
      expect(MatchStage.values, contains(MatchStage.semiFinal));
      expect(MatchStage.values, contains(MatchStage.thirdPlace));
      expect(MatchStage.values, contains(MatchStage.final_));
    });
  });

  group('MatchStageExtension', () {
    test('displayName returns correct values', () {
      expect(MatchStage.groupStage.displayName, equals('Group Stage'));
      expect(MatchStage.roundOf32.displayName, equals('Round of 32'));
      expect(MatchStage.roundOf16.displayName, equals('Round of 16'));
      expect(MatchStage.quarterFinal.displayName, equals('Quarter-Final'));
      expect(MatchStage.semiFinal.displayName, equals('Semi-Final'));
      expect(MatchStage.thirdPlace.displayName, equals('Third Place Play-off'));
      expect(MatchStage.final_.displayName, equals('Final'));
    });

    test('shortName returns correct values', () {
      expect(MatchStage.groupStage.shortName, equals('Group'));
      expect(MatchStage.roundOf32.shortName, equals('R32'));
      expect(MatchStage.roundOf16.shortName, equals('R16'));
      expect(MatchStage.quarterFinal.shortName, equals('QF'));
      expect(MatchStage.semiFinal.shortName, equals('SF'));
      expect(MatchStage.thirdPlace.shortName, equals('3rd'));
      expect(MatchStage.final_.shortName, equals('Final'));
    });

    test('isKnockout returns correct values', () {
      expect(MatchStage.groupStage.isKnockout, isFalse);
      expect(MatchStage.roundOf32.isKnockout, isTrue);
      expect(MatchStage.roundOf16.isKnockout, isTrue);
      expect(MatchStage.quarterFinal.isKnockout, isTrue);
      expect(MatchStage.semiFinal.isKnockout, isTrue);
      expect(MatchStage.thirdPlace.isKnockout, isTrue);
      expect(MatchStage.final_.isKnockout, isTrue);
    });
  });

  group('MatchStatus', () {
    test('has expected values', () {
      expect(MatchStatus.values, hasLength(8));
      expect(MatchStatus.values, contains(MatchStatus.scheduled));
      expect(MatchStatus.values, contains(MatchStatus.inProgress));
      expect(MatchStatus.values, contains(MatchStatus.halfTime));
      expect(MatchStatus.values, contains(MatchStatus.extraTime));
      expect(MatchStatus.values, contains(MatchStatus.penalties));
      expect(MatchStatus.values, contains(MatchStatus.completed));
      expect(MatchStatus.values, contains(MatchStatus.postponed));
      expect(MatchStatus.values, contains(MatchStatus.cancelled));
    });
  });

  group('MatchStatusExtension', () {
    test('displayName returns correct values', () {
      expect(MatchStatus.scheduled.displayName, equals('Scheduled'));
      expect(MatchStatus.inProgress.displayName, equals('Live'));
      expect(MatchStatus.halfTime.displayName, equals('Half Time'));
      expect(MatchStatus.extraTime.displayName, equals('Extra Time'));
      expect(MatchStatus.penalties.displayName, equals('Penalties'));
      expect(MatchStatus.completed.displayName, equals('Full Time'));
      expect(MatchStatus.postponed.displayName, equals('Postponed'));
      expect(MatchStatus.cancelled.displayName, equals('Cancelled'));
    });

    test('isLive returns correct values', () {
      expect(MatchStatus.scheduled.isLive, isFalse);
      expect(MatchStatus.inProgress.isLive, isTrue);
      expect(MatchStatus.halfTime.isLive, isTrue);
      expect(MatchStatus.extraTime.isLive, isTrue);
      expect(MatchStatus.penalties.isLive, isTrue);
      expect(MatchStatus.completed.isLive, isFalse);
      expect(MatchStatus.postponed.isLive, isFalse);
      expect(MatchStatus.cancelled.isLive, isFalse);
    });
  });

  group('WorldCupMatch', () {
    final matchDateTime = DateTime(2026, 6, 11, 18, 0, 0);

    WorldCupMatch createTestMatch({
      String matchId = 'match_1',
      int matchNumber = 1,
      MatchStage stage = MatchStage.groupStage,
      String? group,
      int? groupMatchDay,
      DateTime? dateTime,
      DateTime? dateTimeUtc,
      String? venueId,
      String? homeTeamCode,
      String homeTeamName = 'TBD',
      String? homeTeamFlagUrl,
      String? awayTeamCode,
      String awayTeamName = 'TBD',
      String? awayTeamFlagUrl,
      String? homeTeamPlaceholder,
      String? awayTeamPlaceholder,
      int? homeScore,
      int? awayScore,
      int? homeHalfTimeScore,
      int? awayHalfTimeScore,
      int? homeExtraTimeScore,
      int? awayExtraTimeScore,
      int? homePenaltyScore,
      int? awayPenaltyScore,
      String? winnerTeamCode,
      MatchStatus status = MatchStatus.scheduled,
      int? minute,
      int? addedTime,
      List<String> broadcastChannels = const [],
      List<String> homeGoalScorers = const [],
      List<String> awayGoalScorers = const [],
      int? homeYellowCards,
      int? awayYellowCards,
      int? homeRedCards,
      int? awayRedCards,
      bool varUsed = false,
      List<String> varDecisions = const [],
      int? userPredictions,
      int? userComments,
      int? userPhotos,
      double? userRating,
      DateTime? updatedAt,
      DateTime? syncedAt,
    }) {
      return WorldCupMatch(
        matchId: matchId,
        matchNumber: matchNumber,
        stage: stage,
        group: group,
        groupMatchDay: groupMatchDay,
        dateTime: dateTime ?? matchDateTime,
        dateTimeUtc: dateTimeUtc,
        venueId: venueId,
        homeTeamCode: homeTeamCode,
        homeTeamName: homeTeamName,
        homeTeamFlagUrl: homeTeamFlagUrl,
        awayTeamCode: awayTeamCode,
        awayTeamName: awayTeamName,
        awayTeamFlagUrl: awayTeamFlagUrl,
        homeTeamPlaceholder: homeTeamPlaceholder,
        awayTeamPlaceholder: awayTeamPlaceholder,
        homeScore: homeScore,
        awayScore: awayScore,
        homeHalfTimeScore: homeHalfTimeScore,
        awayHalfTimeScore: awayHalfTimeScore,
        homeExtraTimeScore: homeExtraTimeScore,
        awayExtraTimeScore: awayExtraTimeScore,
        homePenaltyScore: homePenaltyScore,
        awayPenaltyScore: awayPenaltyScore,
        winnerTeamCode: winnerTeamCode,
        status: status,
        minute: minute,
        addedTime: addedTime,
        broadcastChannels: broadcastChannels,
        homeGoalScorers: homeGoalScorers,
        awayGoalScorers: awayGoalScorers,
        homeYellowCards: homeYellowCards,
        awayYellowCards: awayYellowCards,
        homeRedCards: homeRedCards,
        awayRedCards: awayRedCards,
        varUsed: varUsed,
        varDecisions: varDecisions,
        userPredictions: userPredictions,
        userComments: userComments,
        userPhotos: userPhotos,
        userRating: userRating,
        updatedAt: updatedAt,
        syncedAt: syncedAt,
      );
    }

    group('Constructor', () {
      test('creates match with required fields', () {
        final match = createTestMatch();

        expect(match.matchId, equals('match_1'));
        expect(match.matchNumber, equals(1));
        expect(match.stage, equals(MatchStage.groupStage));
        expect(match.homeTeamName, equals('TBD'));
        expect(match.awayTeamName, equals('TBD'));
        expect(match.status, equals(MatchStatus.scheduled));
      });

      test('creates match with team details', () {
        final match = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          homeTeamFlagUrl: 'https://flags.com/usa.png',
          awayTeamFlagUrl: 'https://flags.com/mex.png',
        );

        expect(match.homeTeamCode, equals('USA'));
        expect(match.awayTeamCode, equals('MEX'));
        expect(match.homeTeamName, equals('United States'));
        expect(match.awayTeamName, equals('Mexico'));
        expect(match.homeTeamFlagUrl, equals('https://flags.com/usa.png'));
        expect(match.awayTeamFlagUrl, equals('https://flags.com/mex.png'));
      });

      test('creates match with scores', () {
        final match = createTestMatch(
          homeScore: 2,
          awayScore: 1,
          homeHalfTimeScore: 1,
          awayHalfTimeScore: 0,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 1,
          homePenaltyScore: 4,
          awayPenaltyScore: 3,
          status: MatchStatus.completed,
        );

        expect(match.homeScore, equals(2));
        expect(match.awayScore, equals(1));
        expect(match.homeHalfTimeScore, equals(1));
        expect(match.awayHalfTimeScore, equals(0));
        expect(match.homeExtraTimeScore, equals(1));
        expect(match.awayExtraTimeScore, equals(1));
        expect(match.homePenaltyScore, equals(4));
        expect(match.awayPenaltyScore, equals(3));
      });

      test('creates match with group stage info', () {
        final match = createTestMatch(
          group: 'A',
          groupMatchDay: 1,
        );

        expect(match.group, equals('A'));
        expect(match.groupMatchDay, equals(1));
      });

      test('creates match with broadcast channels', () {
        final match = createTestMatch(
          broadcastChannels: ['FOX', 'Telemundo', 'Peacock'],
        );

        expect(match.broadcastChannels, hasLength(3));
        expect(match.broadcastChannels, contains('FOX'));
        expect(match.broadcastChannels, contains('Telemundo'));
      });

      test('creates match with goal scorers', () {
        final match = createTestMatch(
          homeGoalScorers: ["Pulisic 23'", "McKennie 67'"],
          awayGoalScorers: ["Lozano 45+2'"],
        );

        expect(match.homeGoalScorers, hasLength(2));
        expect(match.awayGoalScorers, hasLength(1));
        expect(match.homeGoalScorers, contains("Pulisic 23'"));
      });

      test('creates match with card counts', () {
        final match = createTestMatch(
          homeYellowCards: 2,
          awayYellowCards: 3,
          homeRedCards: 0,
          awayRedCards: 1,
        );

        expect(match.homeYellowCards, equals(2));
        expect(match.awayYellowCards, equals(3));
        expect(match.homeRedCards, equals(0));
        expect(match.awayRedCards, equals(1));
      });

      test('creates match with VAR info', () {
        final match = createTestMatch(
          varUsed: true,
          varDecisions: ['Goal awarded', 'Penalty overturned'],
        );

        expect(match.varUsed, isTrue);
        expect(match.varDecisions, hasLength(2));
        expect(match.varDecisions, contains('Goal awarded'));
      });

      test('creates match with social features', () {
        final match = createTestMatch(
          userPredictions: 1500,
          userComments: 250,
          userPhotos: 45,
          userRating: 4.5,
        );

        expect(match.userPredictions, equals(1500));
        expect(match.userComments, equals(250));
        expect(match.userPhotos, equals(45));
        expect(match.userRating, equals(4.5));
      });
    });

    group('Computed getters', () {
      test('isLive returns true for live statuses', () {
        final inProgress = createTestMatch(status: MatchStatus.inProgress);
        final halfTime = createTestMatch(status: MatchStatus.halfTime);
        final extraTime = createTestMatch(status: MatchStatus.extraTime);
        final penalties = createTestMatch(status: MatchStatus.penalties);
        final scheduled = createTestMatch(status: MatchStatus.scheduled);
        final completed = createTestMatch(status: MatchStatus.completed);

        expect(inProgress.isLive, isTrue);
        expect(halfTime.isLive, isTrue);
        expect(extraTime.isLive, isTrue);
        expect(penalties.isLive, isTrue);
        expect(scheduled.isLive, isFalse);
        expect(completed.isLive, isFalse);
      });

      test('teamsConfirmed returns true when both teams have codes', () {
        final confirmed = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
        );
        final unconfirmed = createTestMatch(
          homeTeamCode: null,
          awayTeamCode: null,
          homeTeamPlaceholder: 'Winner Group A',
          awayTeamPlaceholder: 'Runner-up Group B',
        );
        final partialHome = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: null,
        );
        final partialAway = createTestMatch(
          homeTeamCode: null,
          awayTeamCode: 'MEX',
        );

        expect(confirmed.teamsConfirmed, isTrue);
        expect(unconfirmed.teamsConfirmed, isFalse);
        expect(partialHome.teamsConfirmed, isFalse);
        expect(partialAway.teamsConfirmed, isFalse);
      });

      test('hasExtraTime returns true when extra time scores exist', () {
        final withExtraTime = createTestMatch(
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 0,
        );
        final withoutExtraTime = createTestMatch();

        expect(withExtraTime.hasExtraTime, isTrue);
        expect(withoutExtraTime.hasExtraTime, isFalse);
      });

      test('hasPenalties returns true when penalty scores exist', () {
        final withPenalties = createTestMatch(
          homePenaltyScore: 4,
          awayPenaltyScore: 3,
        );
        final withoutPenalties = createTestMatch();

        expect(withPenalties.hasPenalties, isTrue);
        expect(withoutPenalties.hasPenalties, isFalse);
      });

      test('homeTotalScore calculates correctly', () {
        final regularOnly = createTestMatch(homeScore: 2);
        final withET = createTestMatch(homeScore: 2, homeExtraTimeScore: 1);
        final nullScore = createTestMatch();

        expect(regularOnly.homeTotalScore, equals(2));
        expect(withET.homeTotalScore, equals(3));
        expect(nullScore.homeTotalScore, isNull);
      });

      test('awayTotalScore calculates correctly', () {
        final regularOnly = createTestMatch(awayScore: 1);
        final withET = createTestMatch(awayScore: 1, awayExtraTimeScore: 1);
        final nullScore = createTestMatch();

        expect(regularOnly.awayTotalScore, equals(1));
        expect(withET.awayTotalScore, equals(2));
        expect(nullScore.awayTotalScore, isNull);
      });

      test('stageDisplayName returns correct value', () {
        final groupMatch = createTestMatch(stage: MatchStage.groupStage);
        final finalMatch = createTestMatch(stage: MatchStage.final_);

        expect(groupMatch.stageDisplayName, equals('Group Stage'));
        expect(finalMatch.stageDisplayName, equals('Final'));
      });

      test('homeFlagUrl and awayFlagUrl are aliases', () {
        final match = createTestMatch(
          homeTeamFlagUrl: 'https://flags.com/usa.png',
          awayTeamFlagUrl: 'https://flags.com/mex.png',
        );

        expect(match.homeFlagUrl, equals(match.homeTeamFlagUrl));
        expect(match.awayFlagUrl, equals(match.awayTeamFlagUrl));
      });
    });

    group('scoreDisplay', () {
      test('returns dash for null scores', () {
        final match = createTestMatch();
        expect(match.scoreDisplay, equals('-'));
      });

      test('returns score for regular time', () {
        final match = createTestMatch(
          homeScore: 2,
          awayScore: 1,
          status: MatchStatus.completed,
        );
        expect(match.scoreDisplay, equals('2-1'));
      });

      test('returns score with AET for knockout match with extra time draw', () {
        final match = createTestMatch(
          stage: MatchStage.roundOf16,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
          status: MatchStatus.completed,
        );
        expect(match.scoreDisplay, equals('1-1 AET'));
      });

      test('returns score with extra time total', () {
        final match = createTestMatch(
          stage: MatchStage.quarterFinal,
          homeScore: 2,
          awayScore: 2,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 0,
          status: MatchStatus.completed,
        );
        expect(match.scoreDisplay, equals('3-2'));
      });

      test('returns score with penalties', () {
        final match = createTestMatch(
          stage: MatchStage.semiFinal,
          homeScore: 1,
          awayScore: 1,
          homeExtraTimeScore: 0,
          awayExtraTimeScore: 0,
          homePenaltyScore: 4,
          awayPenaltyScore: 3,
          status: MatchStatus.completed,
        );
        expect(match.scoreDisplay, equals('1-1 AET (4-3 pen)'));
      });
    });

    group('timeDisplay', () {
      test('returns formatted time for scheduled match', () {
        final match = createTestMatch(
          status: MatchStatus.scheduled,
          dateTime: DateTime(2026, 6, 11, 18, 0, 0),
        );
        expect(match.timeDisplay, equals('18:00'));
      });

      test('returns TBD when no date for scheduled match', () {
        const match = WorldCupMatch(
          matchId: 'test',
          matchNumber: 1,
          stage: MatchStage.groupStage,
          homeTeamName: 'TBD',
          awayTeamName: 'TBD',
          dateTime: null,
          status: MatchStatus.scheduled,
        );
        expect(match.timeDisplay, equals('TBD'));
      });

      test('returns minute for live match', () {
        final match = createTestMatch(
          status: MatchStatus.inProgress,
          minute: 45,
        );
        expect(match.timeDisplay, equals("45'"));
      });

      test('returns minute with added time', () {
        final match = createTestMatch(
          status: MatchStatus.inProgress,
          minute: 45,
          addedTime: 3,
        );
        expect(match.timeDisplay, equals("45+3'"));
      });

      test('returns LIVE when in progress without minute', () {
        final match = createTestMatch(
          status: MatchStatus.inProgress,
          minute: null,
        );
        expect(match.timeDisplay, equals('LIVE'));
      });

      test('returns HT for half time', () {
        final match = createTestMatch(status: MatchStatus.halfTime);
        expect(match.timeDisplay, equals('HT'));
      });

      test('returns ET for extra time without minute', () {
        final match = createTestMatch(status: MatchStatus.extraTime);
        expect(match.timeDisplay, equals('ET'));
      });

      test('returns PEN for penalties', () {
        final match = createTestMatch(status: MatchStatus.penalties);
        expect(match.timeDisplay, equals('PEN'));
      });

      test('returns FT for completed match', () {
        final match = createTestMatch(status: MatchStatus.completed);
        expect(match.timeDisplay, equals('FT'));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestMatch();
        final updated = original.copyWith(
          homeScore: 3,
          awayScore: 2,
          status: MatchStatus.completed,
        );

        expect(updated.homeScore, equals(3));
        expect(updated.awayScore, equals(2));
        expect(updated.status, equals(MatchStatus.completed));
        expect(updated.matchId, equals(original.matchId));
      });

      test('preserves unchanged fields', () {
        final original = createTestMatch(
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          broadcastChannels: ['FOX'],
        );
        final updated = original.copyWith(status: MatchStatus.inProgress);

        expect(updated.homeTeamName, equals('United States'));
        expect(updated.awayTeamName, equals('Mexico'));
        expect(updated.broadcastChannels, equals(['FOX']));
      });

      test('can update all score-related fields', () {
        final original = createTestMatch();
        final updated = original.copyWith(
          homeScore: 2,
          awayScore: 2,
          homeHalfTimeScore: 1,
          awayHalfTimeScore: 1,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 0,
          homePenaltyScore: 5,
          awayPenaltyScore: 4,
          winnerTeamCode: 'USA',
        );

        expect(updated.homeScore, equals(2));
        expect(updated.awayScore, equals(2));
        expect(updated.homeHalfTimeScore, equals(1));
        expect(updated.awayHalfTimeScore, equals(1));
        expect(updated.homeExtraTimeScore, equals(1));
        expect(updated.awayExtraTimeScore, equals(0));
        expect(updated.homePenaltyScore, equals(5));
        expect(updated.awayPenaltyScore, equals(4));
        expect(updated.winnerTeamCode, equals('USA'));
      });
    });

    group('Map serialization', () {
      test('toMap serializes all fields', () {
        final match = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          homeScore: 2,
          awayScore: 1,
          group: 'A',
          groupMatchDay: 1,
        );
        final map = match.toMap();

        expect(map['matchId'], equals('match_1'));
        expect(map['matchNumber'], equals(1));
        expect(map['stage'], equals('groupStage'));
        expect(map['group'], equals('A'));
        expect(map['groupMatchDay'], equals(1));
        expect(map['homeTeamCode'], equals('USA'));
        expect(map['awayTeamCode'], equals('MEX'));
        expect(map['homeTeamName'], equals('United States'));
        expect(map['awayTeamName'], equals('Mexico'));
        expect(map['homeScore'], equals(2));
        expect(map['awayScore'], equals(1));
        expect(map['status'], equals('scheduled'));
      });

      test('fromMap deserializes correctly', () {
        final map = {
          'matchId': 'match_test',
          'matchNumber': 5,
          'stage': 'quarterFinal',
          'dateTime': '2026-07-04T18:00:00.000',
          'homeTeamCode': 'ARG',
          'awayTeamCode': 'BRA',
          'homeTeamName': 'Argentina',
          'awayTeamName': 'Brazil',
          'homeScore': 1,
          'awayScore': 0,
          'status': 'completed',
        };

        final match = WorldCupMatch.fromMap(map);

        expect(match.matchId, equals('match_test'));
        expect(match.matchNumber, equals(5));
        expect(match.stage, equals(MatchStage.quarterFinal));
        expect(match.homeTeamCode, equals('ARG'));
        expect(match.awayTeamCode, equals('BRA'));
        expect(match.homeScore, equals(1));
        expect(match.status, equals(MatchStatus.completed));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeScore: 2,
          awayScore: 1,
          homeExtraTimeScore: 1,
          awayExtraTimeScore: 0,
          status: MatchStatus.completed,
          minute: 120,
          broadcastChannels: ['FOX', 'ESPN'],
          homeGoalScorers: ["Pulisic 23'"],
          varUsed: true,
        );
        final map = original.toMap();
        final restored = WorldCupMatch.fromMap(map);

        expect(restored.matchId, equals(original.matchId));
        expect(restored.homeTeamCode, equals(original.homeTeamCode));
        expect(restored.homeScore, equals(original.homeScore));
        expect(restored.homeExtraTimeScore, equals(original.homeExtraTimeScore));
        expect(restored.status, equals(original.status));
        expect(restored.broadcastChannels, equals(original.broadcastChannels));
        expect(restored.varUsed, equals(original.varUsed));
      });

      test('fromMap handles missing optional fields', () {
        final map = <String, dynamic>{
          'matchId': 'match_min',
          'matchNumber': 1,
          'stage': 'groupStage',
          'status': 'scheduled',
        };

        final match = WorldCupMatch.fromMap(map);

        expect(match.matchId, equals('match_min'));
        expect(match.homeTeamCode, isNull);
        expect(match.awayTeamCode, isNull);
        expect(match.homeScore, isNull);
        expect(match.awayScore, isNull);
        expect(match.group, isNull);
        expect(match.minute, isNull);
        expect(match.broadcastChannels, isEmpty);
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes correctly', () {
        final match = createTestMatch(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          group: 'A',
          broadcastChannels: ['FOX'],
        );
        final data = match.toFirestore();

        expect(data['matchNumber'], equals(1));
        expect(data['stage'], equals('groupStage'));
        expect(data['group'], equals('A'));
        expect(data['homeTeamCode'], equals('USA'));
        expect(data['awayTeamCode'], equals('MEX'));
        expect(data['status'], equals('scheduled'));
        expect(data['broadcastChannels'], equals(['FOX']));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'matchNumber': 10,
          'stage': 'semiFinal',
          'dateTime': '2026-07-08T20:00:00.000',
          'homeTeamCode': 'ARG',
          'awayTeamCode': 'BRA',
          'homeTeamName': 'Argentina',
          'awayTeamName': 'Brazil',
          'homeScore': 2,
          'awayScore': 2,
          'homeExtraTimeScore': 1,
          'awayExtraTimeScore': 0,
          'status': 'completed',
        };

        final match = WorldCupMatch.fromFirestore(data, 'match_fs');

        expect(match.matchId, equals('match_fs'));
        expect(match.stage, equals(MatchStage.semiFinal));
        expect(match.homeTeamName, equals('Argentina'));
        expect(match.awayTeamName, equals('Brazil'));
        expect(match.homeExtraTimeScore, equals(1));
        expect(match.status, equals(MatchStatus.completed));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'matchNumber': 1,
          'stage': 'groupStage',
          'status': 'scheduled',
        };

        final match = WorldCupMatch.fromFirestore(data, 'match_min');

        expect(match.matchId, equals('match_min'));
        expect(match.homeTeamCode, isNull);
        expect(match.awayTeamCode, isNull);
        expect(match.homeScore, isNull);
        expect(match.awayScore, isNull);
        expect(match.group, isNull);
        expect(match.minute, isNull);
      });
    });

    group('Stage parsing', () {
      test('parses various stage string formats', () {
        final testCases = {
          'groupStage': MatchStage.groupStage,
          'group_stage': MatchStage.groupStage,
          'group': MatchStage.groupStage,
          'roundOf32': MatchStage.roundOf32,
          'round_of_32': MatchStage.roundOf32,
          'r32': MatchStage.roundOf32,
          'roundOf16': MatchStage.roundOf16,
          'round_of_16': MatchStage.roundOf16,
          'r16': MatchStage.roundOf16,
          'quarterFinal': MatchStage.quarterFinal,
          'quarter_final': MatchStage.quarterFinal,
          'qf': MatchStage.quarterFinal,
          'semiFinal': MatchStage.semiFinal,
          'semi_final': MatchStage.semiFinal,
          'sf': MatchStage.semiFinal,
          'thirdPlace': MatchStage.thirdPlace,
          'third_place': MatchStage.thirdPlace,
          '3rd': MatchStage.thirdPlace,
          'final': MatchStage.final_,
          'final_': MatchStage.final_,
        };

        for (final entry in testCases.entries) {
          final map = {
            'matchId': 'test',
            'matchNumber': 1,
            'stage': entry.key,
            'status': 'scheduled',
          };
          final match = WorldCupMatch.fromMap(map);
          expect(match.stage, equals(entry.value),
              reason: '${entry.key} should parse to ${entry.value}');
        }
      });

      test('defaults to groupStage for unknown stage', () {
        final map = {
          'matchId': 'test',
          'matchNumber': 1,
          'stage': 'unknownStage',
          'status': 'scheduled',
        };
        final match = WorldCupMatch.fromMap(map);
        expect(match.stage, equals(MatchStage.groupStage));
      });

      test('defaults to groupStage for null stage', () {
        final map = {
          'matchId': 'test',
          'matchNumber': 1,
          'stage': null,
          'status': 'scheduled',
        };
        final match = WorldCupMatch.fromMap(map);
        expect(match.stage, equals(MatchStage.groupStage));
      });
    });

    group('Status parsing', () {
      test('parses various status string formats', () {
        final testCases = {
          'scheduled': MatchStatus.scheduled,
          'inProgress': MatchStatus.inProgress,
          'in_progress': MatchStatus.inProgress,
          'live': MatchStatus.inProgress,
          'halfTime': MatchStatus.halfTime,
          'half_time': MatchStatus.halfTime,
          'ht': MatchStatus.halfTime,
          'extraTime': MatchStatus.extraTime,
          'extra_time': MatchStatus.extraTime,
          'et': MatchStatus.extraTime,
          'penalties': MatchStatus.penalties,
          'pen': MatchStatus.penalties,
          'completed': MatchStatus.completed,
          'finished': MatchStatus.completed,
          'ft': MatchStatus.completed,
          'postponed': MatchStatus.postponed,
          'cancelled': MatchStatus.cancelled,
          'canceled': MatchStatus.cancelled,
        };

        for (final entry in testCases.entries) {
          final map = {
            'matchId': 'test',
            'matchNumber': 1,
            'stage': 'groupStage',
            'status': entry.key,
          };
          final match = WorldCupMatch.fromMap(map);
          expect(match.status, equals(entry.value),
              reason: '${entry.key} should parse to ${entry.value}');
        }
      });

      test('defaults to scheduled for unknown status', () {
        final map = {
          'matchId': 'test',
          'matchNumber': 1,
          'stage': 'groupStage',
          'status': 'unknownStatus',
        };
        final match = WorldCupMatch.fromMap(map);
        expect(match.status, equals(MatchStatus.scheduled));
      });

      test('defaults to scheduled for null status', () {
        final map = {
          'matchId': 'test',
          'matchNumber': 1,
          'stage': 'groupStage',
          'status': null,
        };
        final match = WorldCupMatch.fromMap(map);
        expect(match.status, equals(MatchStatus.scheduled));
      });
    });

    group('Equatable', () {
      test('two matches with same props are equal', () {
        final match1 = createTestMatch();
        final match2 = createTestMatch();

        expect(match1, equals(match2));
      });

      test('two matches with different matchId are not equal', () {
        final match1 = createTestMatch(matchId: 'match_1');
        final match2 = createTestMatch(matchId: 'match_2');

        expect(match1, isNot(equals(match2)));
      });

      test('two matches with different scores are not equal', () {
        final match1 = createTestMatch(homeScore: 1, awayScore: 0);
        final match2 = createTestMatch(homeScore: 2, awayScore: 1);

        expect(match1, isNot(equals(match2)));
      });

      test('two matches with different status are not equal', () {
        final match1 = createTestMatch(status: MatchStatus.scheduled);
        final match2 = createTestMatch(status: MatchStatus.inProgress);

        expect(match1, isNot(equals(match2)));
      });

      test('props list contains expected fields', () {
        final match = createTestMatch();
        expect(match.props, hasLength(8));
        expect(match.props, contains(match.matchId));
        expect(match.props, contains(match.matchNumber));
        expect(match.props, contains(match.stage));
        expect(match.props, contains(match.status));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final match = createTestMatch(
          matchNumber: 1,
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
        );
        final str = match.toString();

        expect(str, contains('United States'));
        expect(str, contains('Mexico'));
        expect(str, contains('Match 1'));
      });
    });
  });

  group('MatchTimeFilter', () {
    test('has expected values', () {
      expect(MatchTimeFilter.values, hasLength(5));
      expect(MatchTimeFilter.values, contains(MatchTimeFilter.today));
      expect(MatchTimeFilter.values, contains(MatchTimeFilter.thisWeek));
      expect(MatchTimeFilter.values, contains(MatchTimeFilter.groupStage));
      expect(MatchTimeFilter.values, contains(MatchTimeFilter.knockout));
      expect(MatchTimeFilter.values, contains(MatchTimeFilter.all));
    });
  });
}
