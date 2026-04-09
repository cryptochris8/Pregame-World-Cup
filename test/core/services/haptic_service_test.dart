import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/haptic_service.dart';
import 'package:pregame_world_cup/features/match_chat/domain/entities/match_chat.dart';

void main() {
  late HapticService service;

  setUp(() {
    service = HapticService();
  });

  group('HapticService', () {
    group('enabled toggle', () {
      test('defaults to enabled', () {
        expect(service.enabled, isTrue);
      });

      test('can be disabled', () {
        service.enabled = false;
        expect(service.enabled, isFalse);
      });

      test('can be re-enabled', () {
        service.enabled = false;
        service.enabled = true;
        expect(service.enabled, isTrue);
      });
    });

    // In the test environment, Platform.isIOS and Platform.isAndroid are both
    // false, so haptic calls won't fire through the platform channel. We test
    // the logic by verifying that the service respects the enabled flag and
    // that onMatchEvent routes correctly without throwing.

    group('platform guard', () {
      test('does not throw on unsupported platform', () async {
        await service.onGoal();
      });

      test('does not throw when disabled', () async {
        service.enabled = false;
        await service.onGoal();
        await service.onRedCard();
        await service.onFinalWhistle();
      });
    });

    group('onMatchEvent routing', () {
      test('routes goal without error', () async {
        await service.onMatchEvent(MatchEventType.goal);
      });

      test('routes ownGoal without error', () async {
        await service.onMatchEvent(MatchEventType.ownGoal);
      });

      test('routes redCard without error', () async {
        await service.onMatchEvent(MatchEventType.redCard);
      });

      test('routes penalty without error', () async {
        await service.onMatchEvent(MatchEventType.penalty);
      });

      test('routes penaltyMissed without error', () async {
        await service.onMatchEvent(MatchEventType.penaltyMissed);
      });

      test('routes fulltime without error', () async {
        await service.onMatchEvent(MatchEventType.fulltime);
      });

      test('routes kickoff without error', () async {
        await service.onMatchEvent(MatchEventType.kickoff);
      });

      test('routes yellowCard without error', () async {
        await service.onMatchEvent(MatchEventType.yellowCard);
      });

      test('routes substitution without error', () async {
        await service.onMatchEvent(MatchEventType.substitution);
      });

      test('routes halftime without error', () async {
        await service.onMatchEvent(MatchEventType.halftime);
      });

      test('routes varReview without error', () async {
        await service.onMatchEvent(MatchEventType.varReview);
      });

      test('routes injury without error', () async {
        await service.onMatchEvent(MatchEventType.injury);
      });

      test('routes other without error', () async {
        await service.onMatchEvent(MatchEventType.other);
      });

      test('handles all MatchEventType values without error', () async {
        for (final event in MatchEventType.values) {
          await service.onMatchEvent(event);
        }
      });
    });

    group('individual methods', () {
      test('onGoal completes without error', () async {
        await service.onGoal();
      });

      test('onRedCard completes without error', () async {
        await service.onRedCard();
      });

      test('onPenaltyAwarded completes without error', () async {
        await service.onPenaltyAwarded();
      });

      test('onFinalWhistle completes without error', () async {
        await service.onFinalWhistle();
      });

      test('onMatchStart completes without error', () async {
        await service.onMatchStart();
      });

      test('onYellowCard completes without error', () async {
        await service.onYellowCard();
      });

      test('onSubstitution completes without error', () async {
        await service.onSubstitution();
      });
    });
  });
}
