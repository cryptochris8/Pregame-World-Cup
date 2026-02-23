import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/user_sanction.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';

/// Tests for the UserModerationStatusCopyWith extension defined in
/// moderation_service.dart (separate from the entity file).
void main() {
  group('UserModerationStatusCopyWith extension', () {
    test('copies with no changes returns equal status', () {
      const original = UserModerationStatus(
        usualId: 'u1',
        warningCount: 2,
        reportCount: 3,
        isMuted: true,
      );

      final copy = original.copyWith();

      expect(copy.usualId, equals(original.usualId));
      expect(copy.warningCount, equals(original.warningCount));
      expect(copy.reportCount, equals(original.reportCount));
      expect(copy.isMuted, equals(original.isMuted));
    });

    test('copies with single field change', () {
      const original = UserModerationStatus(
        usualId: 'u1',
        isMuted: false,
      );

      final copy = original.copyWith(isMuted: true);

      expect(copy.isMuted, isTrue);
      expect(copy.usualId, equals('u1'));
    });

    test('copies with multiple field changes', () {
      const original = UserModerationStatus(
        usualId: 'u1',
        warningCount: 0,
        isBanned: false,
      );

      final copy = original.copyWith(
        warningCount: 3,
        isBanned: true,
        banReason: 'Severe violations',
      );

      expect(copy.warningCount, equals(3));
      expect(copy.isBanned, isTrue);
      expect(copy.banReason, equals('Severe violations'));
      expect(copy.usualId, equals('u1'));
    });

    test('can update usualId', () {
      const original = UserModerationStatus(usualId: 'u1');
      final copy = original.copyWith(usualId: 'u2');
      expect(copy.usualId, equals('u2'));
    });

    test('can update mutedUntil', () {
      const original = UserModerationStatus(usualId: 'u1');
      final date = DateTime(2026, 7, 1);
      final copy = original.copyWith(mutedUntil: date);
      expect(copy.mutedUntil, equals(date));
    });

    test('can update suspendedUntil', () {
      const original = UserModerationStatus(usualId: 'u1');
      final date = DateTime(2026, 7, 1);
      final copy = original.copyWith(suspendedUntil: date);
      expect(copy.suspendedUntil, equals(date));
    });

    test('can update activeSanctions', () {
      const original = UserModerationStatus(usualId: 'u1');
      final sanctions = [
        UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: DateTime(2026, 6, 1),
        ),
      ];

      final copy = original.copyWith(activeSanctions: sanctions);
      expect(copy.activeSanctions, hasLength(1));
      expect(copy.activeSanctions[0].sanctionId, equals('s1'));
    });

    test('can update lastWarningAt', () {
      const original = UserModerationStatus(usualId: 'u1');
      final date = DateTime(2026, 6, 15);
      final copy = original.copyWith(lastWarningAt: date);
      expect(copy.lastWarningAt, equals(date));
    });

    test('preserves all other fields when updating one', () {
      final sanctions = [
        UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: DateTime(2026, 6, 1),
        ),
      ];

      final original = UserModerationStatus(
        usualId: 'u1',
        warningCount: 2,
        reportCount: 3,
        isMuted: true,
        mutedUntil: DateTime(2026, 6, 2),
        isSuspended: false,
        suspendedUntil: null,
        isBanned: false,
        banReason: null,
        activeSanctions: sanctions,
        lastWarningAt: DateTime(2026, 6, 1),
      );

      final copy = original.copyWith(warningCount: 5);

      expect(copy.warningCount, equals(5));
      expect(copy.usualId, equals('u1'));
      expect(copy.reportCount, equals(3));
      expect(copy.isMuted, isTrue);
      expect(copy.mutedUntil, equals(DateTime(2026, 6, 2)));
      expect(copy.isSuspended, isFalse);
      expect(copy.isBanned, isFalse);
      expect(copy.activeSanctions, hasLength(1));
      expect(copy.lastWarningAt, equals(DateTime(2026, 6, 1)));
    });
  });
}
