import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/presentation/widgets/moderation_status_banner.dart';

/// Widget tests for moderation status banner, muted input blocker, and status card.
///
/// Note: These widgets internally instantiate ModerationService() which is a
/// singleton that depends on Firebase. Tests are limited to verifying initial
/// widget construction and rendering behavior that does not require Firebase.
void main() {
  group('ModerationStatusBanner', () {
    group('Constructor', () {
      test('creates with required child', () {
        const banner = ModerationStatusBanner(
          child: Text('Content'),
        );

        expect(banner.showBanner, isTrue);
      });

      test('creates with showBanner false', () {
        const banner = ModerationStatusBanner(
          showBanner: false,
          child: Text('Content'),
        );

        expect(banner.showBanner, isFalse);
      });
    });

    test('is a StatefulWidget', () {
      const banner = ModerationStatusBanner(child: Text('test'));
      expect(banner, isA<StatefulWidget>());
    });
  });

  group('MutedInputBlocker', () {
    group('Constructor', () {
      test('creates with required child', () {
        const blocker = MutedInputBlocker(
          child: Text('Input'),
        );

        expect(blocker.mutedChild, isNull);
      });

      test('creates with custom mutedChild', () {
        const blocker = MutedInputBlocker(
          mutedChild: Text('You are muted'),
          child: Text('Input'),
        );

        expect(blocker.mutedChild, isNotNull);
      });
    });

    test('is a StatefulWidget', () {
      const blocker = MutedInputBlocker(child: Text('test'));
      expect(blocker, isA<StatefulWidget>());
    });
  });

  group('ModerationStatusCard', () {
    group('Constructor', () {
      test('creates with required userId', () {
        const card = ModerationStatusCard(
          userId: 'u1',
        );

        expect(card.userId, equals('u1'));
        expect(card.showIfClean, isFalse);
      });

      test('creates with showIfClean true', () {
        const card = ModerationStatusCard(
          userId: 'u1',
          showIfClean: true,
        );

        expect(card.showIfClean, isTrue);
      });
    });

    test('is a StatefulWidget', () {
      const card = ModerationStatusCard(userId: 'u1');
      expect(card, isA<StatefulWidget>());
    });
  });
}
