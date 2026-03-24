import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

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

    test('all enum values are unique', () {
      final valueSet = MatchStage.values.toSet();
      expect(valueSet.length, equals(MatchStage.values.length));
    });
  });

  group('MatchStageExtension displayName', () {
    test('returns correct display names for all stages', () {
      expect(MatchStage.groupStage.displayName, equals('Group Stage'));
      expect(MatchStage.roundOf32.displayName, equals('Round of 32'));
      expect(MatchStage.roundOf16.displayName, equals('Round of 16'));
      expect(MatchStage.quarterFinal.displayName, equals('Quarter-Final'));
      expect(MatchStage.semiFinal.displayName, equals('Semi-Final'));
      expect(MatchStage.thirdPlace.displayName, equals('Third Place Play-off'));
      expect(MatchStage.final_.displayName, equals('Final'));
    });

    test('all display names are non-empty', () {
      for (final stage in MatchStage.values) {
        expect(stage.displayName, isNotEmpty);
      }
    });
  });

  group('MatchStageExtension shortName', () {
    test('returns correct short names for all stages', () {
      expect(MatchStage.groupStage.shortName, equals('Group'));
      expect(MatchStage.roundOf32.shortName, equals('R32'));
      expect(MatchStage.roundOf16.shortName, equals('R16'));
      expect(MatchStage.quarterFinal.shortName, equals('QF'));
      expect(MatchStage.semiFinal.shortName, equals('SF'));
      expect(MatchStage.thirdPlace.shortName, equals('3rd'));
      expect(MatchStage.final_.shortName, equals('Final'));
    });

    test('all short names are non-empty', () {
      for (final stage in MatchStage.values) {
        expect(stage.shortName, isNotEmpty);
      }
    });

    test('short names are shorter than or equal to display names', () {
      for (final stage in MatchStage.values) {
        expect(
          stage.shortName.length,
          lessThanOrEqualTo(stage.displayName.length),
        );
      }
    });
  });

  group('MatchStageExtension isKnockout', () {
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

    test('only group stage is not knockout', () {
      final knockoutStages = MatchStage.values.where((s) => s.isKnockout).toList();
      expect(knockoutStages, hasLength(6));
      expect(knockoutStages, isNot(contains(MatchStage.groupStage)));
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

    test('all enum values are unique', () {
      final valueSet = MatchStatus.values.toSet();
      expect(valueSet.length, equals(MatchStatus.values.length));
    });
  });

  group('MatchStatusExtension displayName', () {
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

    test('all display names are non-empty', () {
      for (final status in MatchStatus.values) {
        expect(status.displayName, isNotEmpty);
      }
    });
  });

  group('MatchStatusExtension isLive', () {
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

    test('exactly 4 statuses are live', () {
      final liveStatuses = MatchStatus.values.where((s) => s.isLive).toList();
      expect(liveStatuses, hasLength(4));
      expect(liveStatuses, containsAll([
        MatchStatus.inProgress,
        MatchStatus.halfTime,
        MatchStatus.extraTime,
        MatchStatus.penalties,
      ]));
    });
  });

  group('MatchStatus edge cases', () {
    test('completed is not live', () {
      expect(MatchStatus.completed.isLive, isFalse);
    });

    test('scheduled is not live', () {
      expect(MatchStatus.scheduled.isLive, isFalse);
    });

    test('postponed and cancelled are not live', () {
      expect(MatchStatus.postponed.isLive, isFalse);
      expect(MatchStatus.cancelled.isLive, isFalse);
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

    test('all enum values are unique', () {
      final valueSet = MatchTimeFilter.values.toSet();
      expect(valueSet.length, equals(MatchTimeFilter.values.length));
    });

    test('all filter has all keyword', () {
      expect(MatchTimeFilter.all.name, equals('all'));
    });

    test('time-based filters come before stage-based filters', () {
      final values = MatchTimeFilter.values;
      final todayIndex = values.indexOf(MatchTimeFilter.today);
      final weekIndex = values.indexOf(MatchTimeFilter.thisWeek);
      final groupIndex = values.indexOf(MatchTimeFilter.groupStage);
      final knockoutIndex = values.indexOf(MatchTimeFilter.knockout);

      expect(todayIndex, lessThan(groupIndex));
      expect(weekIndex, lessThan(groupIndex));
      expect(todayIndex, lessThan(knockoutIndex));
      expect(weekIndex, lessThan(knockoutIndex));
    });
  });

  group('Enum consistency', () {
    test('MatchStage has no duplicate display names', () {
      final displayNames = MatchStage.values.map((s) => s.displayName).toSet();
      expect(displayNames.length, equals(MatchStage.values.length));
    });

    test('MatchStage has no duplicate short names', () {
      final shortNames = MatchStage.values.map((s) => s.shortName).toSet();
      expect(shortNames.length, equals(MatchStage.values.length));
    });

    test('MatchStatus has no duplicate display names', () {
      final displayNames = MatchStatus.values.map((s) => s.displayName).toSet();
      expect(displayNames.length, equals(MatchStatus.values.length));
    });
  });

  group('Extension method coverage', () {
    test('all MatchStage values have displayName', () {
      for (final stage in MatchStage.values) {
        expect(() => stage.displayName, returnsNormally);
      }
    });

    test('all MatchStage values have shortName', () {
      for (final stage in MatchStage.values) {
        expect(() => stage.shortName, returnsNormally);
      }
    });

    test('all MatchStage values have isKnockout', () {
      for (final stage in MatchStage.values) {
        expect(() => stage.isKnockout, returnsNormally);
      }
    });

    test('all MatchStatus values have displayName', () {
      for (final status in MatchStatus.values) {
        expect(() => status.displayName, returnsNormally);
      }
    });

    test('all MatchStatus values have isLive', () {
      for (final status in MatchStatus.values) {
        expect(() => status.isLive, returnsNormally);
      }
    });
  });
}
