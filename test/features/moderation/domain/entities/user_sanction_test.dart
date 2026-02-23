import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/user_sanction.dart';

void main() {
  // Helper to create a fully populated UserSanction
  UserSanction createSanction({
    String sanctionId = 's1',
    String usualId = 'u1',
    SanctionType type = SanctionType.mute,
    String reason = 'Test reason',
    String? relatedReportId = 'r1',
    ModerationAction action = ModerationAction.temporaryMute,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool isActive = true,
    String? moderatorId = 'mod1',
    String? appealMessage,
    DateTime? appealedAt,
    bool appealResolved = false,
    String? appealResolution,
  }) {
    return UserSanction(
      sanctionId: sanctionId,
      usualId: usualId,
      type: type,
      reason: reason,
      relatedReportId: relatedReportId,
      action: action,
      createdAt: createdAt ?? DateTime(2026, 6, 1, 12, 0),
      expiresAt: expiresAt,
      isActive: isActive,
      moderatorId: moderatorId,
      appealMessage: appealMessage,
      appealedAt: appealedAt,
      appealResolved: appealResolved,
      appealResolution: appealResolution,
    );
  }

  group('SanctionType', () {
    test('contains all expected values', () {
      expect(SanctionType.values, hasLength(4));
      expect(SanctionType.values, containsAll([
        SanctionType.warning,
        SanctionType.mute,
        SanctionType.suspension,
        SanctionType.permanentBan,
      ]));
    });
  });

  group('UserSanction', () {
    group('Constructor', () {
      test('creates sanction with required fields only', () {
        final now = DateTime.now();
        final sanction = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Profanity',
          action: ModerationAction.warning,
          createdAt: now,
        );

        expect(sanction.sanctionId, equals('s1'));
        expect(sanction.usualId, equals('u1'));
        expect(sanction.type, equals(SanctionType.warning));
        expect(sanction.reason, equals('Profanity'));
        expect(sanction.action, equals(ModerationAction.warning));
        expect(sanction.createdAt, equals(now));
        // Defaults
        expect(sanction.isActive, isTrue);
        expect(sanction.appealResolved, isFalse);
        // Nullable defaults
        expect(sanction.relatedReportId, isNull);
        expect(sanction.expiresAt, isNull);
        expect(sanction.moderatorId, isNull);
        expect(sanction.appealMessage, isNull);
        expect(sanction.appealedAt, isNull);
        expect(sanction.appealResolution, isNull);
      });

      test('creates sanction with all fields', () {
        final appealDate = DateTime(2026, 6, 5);
        final sanction = createSanction(
          expiresAt: DateTime(2026, 6, 2, 12, 0),
          appealMessage: 'I am sorry',
          appealedAt: appealDate,
          appealResolved: true,
          appealResolution: 'Appeal denied',
        );

        expect(sanction.relatedReportId, equals('r1'));
        expect(sanction.expiresAt, equals(DateTime(2026, 6, 2, 12, 0)));
        expect(sanction.moderatorId, equals('mod1'));
        expect(sanction.appealMessage, equals('I am sorry'));
        expect(sanction.appealedAt, equals(appealDate));
        expect(sanction.appealResolved, isTrue);
        expect(sanction.appealResolution, equals('Appeal denied'));
      });
    });

    group('hasExpired', () {
      test('returns false when expiresAt is null (permanent)', () {
        final sanction = createSanction(
          type: SanctionType.permanentBan,
          action: ModerationAction.permanentBan,
          expiresAt: null,
        );

        expect(sanction.hasExpired, isFalse);
      });

      test('returns false when expiresAt is in the future', () {
        final sanction = createSanction(
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(sanction.hasExpired, isFalse);
      });

      test('returns true when expiresAt is in the past', () {
        final sanction = createSanction(
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(sanction.hasExpired, isTrue);
      });
    });

    group('isCurrentlyActive', () {
      test('returns true when active and not expired', () {
        final sanction = createSanction(
          isActive: true,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(sanction.isCurrentlyActive, isTrue);
      });

      test('returns false when not active', () {
        final sanction = createSanction(
          isActive: false,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(sanction.isCurrentlyActive, isFalse);
      });

      test('returns false when expired even if isActive is true', () {
        final sanction = createSanction(
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(sanction.isCurrentlyActive, isFalse);
      });

      test('returns true for permanent ban (null expiresAt) when active', () {
        final sanction = createSanction(
          type: SanctionType.permanentBan,
          action: ModerationAction.permanentBan,
          isActive: true,
          expiresAt: null,
        );

        expect(sanction.isCurrentlyActive, isTrue);
      });

      test('returns false for permanent ban when deactivated', () {
        final sanction = createSanction(
          type: SanctionType.permanentBan,
          action: ModerationAction.permanentBan,
          isActive: false,
          expiresAt: null,
        );

        expect(sanction.isCurrentlyActive, isFalse);
      });
    });

    group('durationText', () {
      test('returns Permanent for null expiresAt', () {
        final sanction = createSanction(expiresAt: null);
        expect(sanction.durationText, equals('Permanent'));
      });

      test('returns days for multi-day sanctions', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
        );

        expect(sanction.durationText, equals('7 days'));
      });

      test('returns singular day for 1-day sanction', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(days: 1)),
        );

        expect(sanction.durationText, equals('1 day'));
      });

      test('returns hours for multi-hour sanctions less than a day', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 12)),
        );

        expect(sanction.durationText, equals('12 hours'));
      });

      test('returns singular hour for 1-hour sanction', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 1)),
        );

        expect(sanction.durationText, equals('1 hour'));
      });

      test('returns minutes for sub-hour sanctions', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 30)),
        );

        expect(sanction.durationText, equals('30 minutes'));
      });

      test('returns singular minute for 1-minute sanction', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 1)),
        );

        expect(sanction.durationText, equals('1 minute'));
      });

      test('returns 0 minute for zero duration', () {
        final now = DateTime(2026, 6, 1, 12, 0);
        final sanction = createSanction(
          createdAt: now,
          expiresAt: now,
        );

        // The code uses `> 1` for plural suffix, so 0 yields singular
        expect(sanction.durationText, equals('0 minute'));
      });
    });

    group('copyWith', () {
      test('copies with no changes produces equal sanction', () {
        final original = createSanction(
          expiresAt: DateTime(2026, 6, 2, 12, 0),
        );
        final copy = original.copyWith();

        expect(copy, equals(original));
      });

      test('copies with single field change', () {
        final original = createSanction();
        final copy = original.copyWith(isActive: false);

        expect(copy.isActive, isFalse);
        expect(copy.sanctionId, equals(original.sanctionId));
        expect(copy.type, equals(original.type));
      });

      test('copies with appeal fields', () {
        final original = createSanction();
        final appealDate = DateTime(2026, 6, 3);
        final copy = original.copyWith(
          appealMessage: 'Please reconsider',
          appealedAt: appealDate,
          appealResolved: true,
          appealResolution: 'Reduced to warning',
        );

        expect(copy.appealMessage, equals('Please reconsider'));
        expect(copy.appealedAt, equals(appealDate));
        expect(copy.appealResolved, isTrue);
        expect(copy.appealResolution, equals('Reduced to warning'));
        // Unchanged
        expect(copy.sanctionId, equals(original.sanctionId));
        expect(copy.usualId, equals(original.usualId));
      });

      test('can update all fields via copyWith', () {
        final original = createSanction();
        final newDate = DateTime(2026, 7, 1);
        final copy = original.copyWith(
          sanctionId: 'new_s',
          usualId: 'new_u',
          type: SanctionType.permanentBan,
          reason: 'New reason',
          relatedReportId: 'new_r',
          action: ModerationAction.permanentBan,
          createdAt: newDate,
          expiresAt: newDate,
          isActive: false,
          moderatorId: 'new_mod',
          appealMessage: 'Appeal',
          appealedAt: newDate,
          appealResolved: true,
          appealResolution: 'Denied',
        );

        expect(copy.sanctionId, equals('new_s'));
        expect(copy.usualId, equals('new_u'));
        expect(copy.type, equals(SanctionType.permanentBan));
        expect(copy.reason, equals('New reason'));
        expect(copy.relatedReportId, equals('new_r'));
        expect(copy.action, equals(ModerationAction.permanentBan));
        expect(copy.createdAt, equals(newDate));
        expect(copy.expiresAt, equals(newDate));
        expect(copy.isActive, isFalse);
        expect(copy.moderatorId, equals('new_mod'));
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final sanction = createSanction(
          expiresAt: DateTime(2026, 6, 2, 12, 0),
          appealMessage: 'I apologize',
          appealedAt: DateTime(2026, 6, 3),
          appealResolved: true,
          appealResolution: 'Denied',
        );

        final json = sanction.toJson();

        expect(json['sanctionId'], equals('s1'));
        expect(json['usualId'], equals('u1'));
        expect(json['type'], equals('mute'));
        expect(json['reason'], equals('Test reason'));
        expect(json['relatedReportId'], equals('r1'));
        expect(json['action'], equals('temporaryMute'));
        expect(json['createdAt'], isA<String>());
        expect(json['expiresAt'], isA<String>());
        expect(json['isActive'], isTrue);
        expect(json['moderatorId'], equals('mod1'));
        expect(json['appealMessage'], equals('I apologize'));
        expect(json['appealedAt'], isA<String>());
        expect(json['appealResolved'], isTrue);
        expect(json['appealResolution'], equals('Denied'));
      });

      test('serializes null fields as null', () {
        final sanction = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: DateTime(2026, 6, 1),
        );

        final json = sanction.toJson();

        expect(json['relatedReportId'], isNull);
        expect(json['expiresAt'], isNull);
        expect(json['moderatorId'], isNull);
        expect(json['appealMessage'], isNull);
        expect(json['appealedAt'], isNull);
        expect(json['appealResolution'], isNull);
      });

      test('serializes type enum as name string', () {
        for (final type in SanctionType.values) {
          final sanction = UserSanction(
            sanctionId: 's1',
            usualId: 'u1',
            type: type,
            reason: 'Test',
            action: ModerationAction.warning,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(sanction.toJson()['type'], equals(type.name));
        }
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'sanctionId': 's1',
          'usualId': 'u1',
          'type': 'suspension',
          'reason': 'Harassment',
          'relatedReportId': 'r5',
          'action': 'temporarySuspension',
          'createdAt': '2026-06-01T12:00:00.000',
          'expiresAt': '2026-06-08T12:00:00.000',
          'isActive': true,
          'moderatorId': 'mod1',
          'appealMessage': 'Please review',
          'appealedAt': '2026-06-02T10:00:00.000',
          'appealResolved': false,
          'appealResolution': null,
        };

        final sanction = UserSanction.fromJson(json);

        expect(sanction.sanctionId, equals('s1'));
        expect(sanction.usualId, equals('u1'));
        expect(sanction.type, equals(SanctionType.suspension));
        expect(sanction.reason, equals('Harassment'));
        expect(sanction.relatedReportId, equals('r5'));
        expect(sanction.action, equals(ModerationAction.temporarySuspension));
        expect(sanction.createdAt, equals(DateTime(2026, 6, 1, 12, 0)));
        expect(sanction.expiresAt, equals(DateTime(2026, 6, 8, 12, 0)));
        expect(sanction.isActive, isTrue);
        expect(sanction.moderatorId, equals('mod1'));
        expect(sanction.appealMessage, equals('Please review'));
        expect(sanction.appealedAt, equals(DateTime(2026, 6, 2, 10, 0)));
        expect(sanction.appealResolved, isFalse);
        expect(sanction.appealResolution, isNull);
      });

      test('handles missing optional boolean fields with defaults', () {
        final json = {
          'sanctionId': 's1',
          'usualId': 'u1',
          'type': 'warning',
          'reason': 'Test',
          'action': 'warning',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final sanction = UserSanction.fromJson(json);

        expect(sanction.isActive, isTrue);
        expect(sanction.appealResolved, isFalse);
      });

      test('defaults to warning type for unknown type', () {
        final json = {
          'sanctionId': 's1',
          'usualId': 'u1',
          'type': 'unknown_type',
          'reason': 'Test',
          'action': 'warning',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final sanction = UserSanction.fromJson(json);
        expect(sanction.type, equals(SanctionType.warning));
      });

      test('defaults to warning action for unknown action', () {
        final json = {
          'sanctionId': 's1',
          'usualId': 'u1',
          'type': 'warning',
          'reason': 'Test',
          'action': 'unknown_action',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final sanction = UserSanction.fromJson(json);
        expect(sanction.action, equals(ModerationAction.warning));
      });

      test('handles null expiresAt', () {
        final json = {
          'sanctionId': 's1',
          'usualId': 'u1',
          'type': 'permanentBan',
          'reason': 'Test',
          'action': 'permanentBan',
          'createdAt': '2026-06-01T12:00:00.000',
          'expiresAt': null,
        };

        final sanction = UserSanction.fromJson(json);
        expect(sanction.expiresAt, isNull);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('preserves all fields through serialization roundtrip', () {
        final original = createSanction(
          type: SanctionType.suspension,
          action: ModerationAction.temporarySuspension,
          expiresAt: DateTime(2026, 6, 8, 12, 0),
          appealMessage: 'Please review',
          appealedAt: DateTime(2026, 6, 2),
          appealResolved: true,
          appealResolution: 'Appeal denied',
        );

        final restored = UserSanction.fromJson(original.toJson());

        expect(restored.sanctionId, equals(original.sanctionId));
        expect(restored.usualId, equals(original.usualId));
        expect(restored.type, equals(original.type));
        expect(restored.reason, equals(original.reason));
        expect(restored.relatedReportId, equals(original.relatedReportId));
        expect(restored.action, equals(original.action));
        expect(restored.createdAt, equals(original.createdAt));
        expect(restored.expiresAt, equals(original.expiresAt));
        expect(restored.isActive, equals(original.isActive));
        expect(restored.moderatorId, equals(original.moderatorId));
        expect(restored.appealMessage, equals(original.appealMessage));
        expect(restored.appealedAt, equals(original.appealedAt));
        expect(restored.appealResolved, equals(original.appealResolved));
        expect(restored.appealResolution, equals(original.appealResolution));
      });

      test('roundtrip for every sanction type', () {
        for (final type in SanctionType.values) {
          final original = UserSanction(
            sanctionId: 's_${type.name}',
            usualId: 'u1',
            type: type,
            reason: 'Test',
            action: ModerationAction.warning,
            createdAt: DateTime(2026, 6, 1),
          );
          final restored = UserSanction.fromJson(original.toJson());
          expect(restored.type, equals(type));
        }
      });
    });

    group('Equatable', () {
      test('two sanctions with same props are equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final s1 = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
        );

        final s2 = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
        );

        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));
      });

      test('two sanctions with different sanctionId are not equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final s1 = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
        );

        final s2 = UserSanction(
          sanctionId: 's2',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
        );

        expect(s1, isNot(equals(s2)));
      });

      test('two sanctions with different isActive are not equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final s1 = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
          isActive: true,
        );

        final s2 = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: createdAt,
          isActive: false,
        );

        expect(s1, isNot(equals(s2)));
      });

      test('props list includes all fields', () {
        final sanction = createSanction(
          expiresAt: DateTime(2026, 6, 2),
          appealMessage: 'Appeal',
          appealedAt: DateTime(2026, 6, 3),
          appealResolved: true,
          appealResolution: 'Denied',
        );

        expect(sanction.props, hasLength(14));
      });
    });
  });

  group('UserModerationStatus', () {
    group('Constructor', () {
      test('creates status with required fields only', () {
        const status = UserModerationStatus(usualId: 'u1');

        expect(status.usualId, equals('u1'));
        expect(status.warningCount, equals(0));
        expect(status.reportCount, equals(0));
        expect(status.isMuted, isFalse);
        expect(status.mutedUntil, isNull);
        expect(status.isSuspended, isFalse);
        expect(status.suspendedUntil, isNull);
        expect(status.isBanned, isFalse);
        expect(status.banReason, isNull);
        expect(status.activeSanctions, isEmpty);
        expect(status.lastWarningAt, isNull);
      });

      test('creates status with all fields', () {
        final mutedUntil = DateTime(2026, 6, 2);
        final suspendedUntil = DateTime(2026, 6, 8);
        final lastWarning = DateTime(2026, 6, 1);
        final sanction = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: DateTime(2026, 6, 1),
        );

        final status = UserModerationStatus(
          usualId: 'u1',
          warningCount: 3,
          reportCount: 5,
          isMuted: true,
          mutedUntil: mutedUntil,
          isSuspended: true,
          suspendedUntil: suspendedUntil,
          isBanned: false,
          banReason: null,
          activeSanctions: [sanction],
          lastWarningAt: lastWarning,
        );

        expect(status.warningCount, equals(3));
        expect(status.reportCount, equals(5));
        expect(status.isMuted, isTrue);
        expect(status.mutedUntil, equals(mutedUntil));
        expect(status.isSuspended, isTrue);
        expect(status.suspendedUntil, equals(suspendedUntil));
        expect(status.activeSanctions, hasLength(1));
        expect(status.lastWarningAt, equals(lastWarning));
      });
    });

    group('empty factory', () {
      test('creates clean status with given userId', () {
        final status = UserModerationStatus.empty('test_user');

        expect(status.usualId, equals('test_user'));
        expect(status.warningCount, equals(0));
        expect(status.reportCount, equals(0));
        expect(status.isMuted, isFalse);
        expect(status.isSuspended, isFalse);
        expect(status.isBanned, isFalse);
        expect(status.activeSanctions, isEmpty);
        expect(status.canSendMessages, isTrue);
        expect(status.canCreateWatchParties, isTrue);
        expect(status.canAccessApp, isTrue);
      });
    });

    group('canSendMessages', () {
      test('returns true when no restrictions', () {
        const status = UserModerationStatus(usualId: 'u1');
        expect(status.canSendMessages, isTrue);
      });

      test('returns false when muted', () {
        const status = UserModerationStatus(usualId: 'u1', isMuted: true);
        expect(status.canSendMessages, isFalse);
      });

      test('returns false when suspended', () {
        const status = UserModerationStatus(usualId: 'u1', isSuspended: true);
        expect(status.canSendMessages, isFalse);
      });

      test('returns false when banned', () {
        const status = UserModerationStatus(usualId: 'u1', isBanned: true);
        expect(status.canSendMessages, isFalse);
      });

      test('returns false when both muted and suspended', () {
        const status = UserModerationStatus(
          usualId: 'u1',
          isMuted: true,
          isSuspended: true,
        );
        expect(status.canSendMessages, isFalse);
      });
    });

    group('canCreateWatchParties', () {
      test('returns true when no restrictions', () {
        const status = UserModerationStatus(usualId: 'u1');
        expect(status.canCreateWatchParties, isTrue);
      });

      test('returns true when only muted (muted users can still create parties)', () {
        const status = UserModerationStatus(usualId: 'u1', isMuted: true);
        expect(status.canCreateWatchParties, isTrue);
      });

      test('returns false when suspended', () {
        const status = UserModerationStatus(usualId: 'u1', isSuspended: true);
        expect(status.canCreateWatchParties, isFalse);
      });

      test('returns false when banned', () {
        const status = UserModerationStatus(usualId: 'u1', isBanned: true);
        expect(status.canCreateWatchParties, isFalse);
      });
    });

    group('canAccessApp', () {
      test('returns true when no restrictions', () {
        const status = UserModerationStatus(usualId: 'u1');
        expect(status.canAccessApp, isTrue);
      });

      test('returns true when muted', () {
        const status = UserModerationStatus(usualId: 'u1', isMuted: true);
        expect(status.canAccessApp, isTrue);
      });

      test('returns true when suspended', () {
        const status = UserModerationStatus(usualId: 'u1', isSuspended: true);
        expect(status.canAccessApp, isTrue);
      });

      test('returns false when banned', () {
        const status = UserModerationStatus(usualId: 'u1', isBanned: true);
        expect(status.canAccessApp, isFalse);
      });
    });

    group('activeRestrictionText', () {
      test('returns null when no restrictions', () {
        const status = UserModerationStatus(usualId: 'u1');
        expect(status.activeRestrictionText, isNull);
      });

      test('returns ban message when banned (highest priority)', () {
        final status = UserModerationStatus(
          usualId: 'u1',
          isBanned: true,
          isSuspended: true,
          suspendedUntil: DateTime(2026, 7, 1),
          isMuted: true,
          mutedUntil: DateTime(2026, 6, 15),
        );

        expect(status.activeRestrictionText, equals('Account permanently banned'));
      });

      test('returns suspension message when suspended but not banned', () {
        final suspendedUntil = DateTime(2026, 7, 1, 14, 30);
        final status = UserModerationStatus(
          usualId: 'u1',
          isSuspended: true,
          suspendedUntil: suspendedUntil,
          isMuted: true,
          mutedUntil: DateTime(2026, 6, 15),
        );

        final text = status.activeRestrictionText;
        expect(text, isNotNull);
        expect(text, contains('Account suspended until'));
        expect(text, contains('7/1/2026'));
      });

      test('returns muted message when only muted', () {
        final mutedUntil = DateTime(2026, 6, 15, 10, 5);
        final status = UserModerationStatus(
          usualId: 'u1',
          isMuted: true,
          mutedUntil: mutedUntil,
        );

        final text = status.activeRestrictionText;
        expect(text, isNotNull);
        expect(text, contains('Muted until'));
        expect(text, contains('6/15/2026'));
      });

      test('returns null when suspended but suspendedUntil is null', () {
        const status = UserModerationStatus(
          usualId: 'u1',
          isSuspended: true,
        );

        // The code checks isSuspended && suspendedUntil != null
        // so with null suspendedUntil it falls through
        expect(status.activeRestrictionText, isNull);
      });

      test('returns null when muted but mutedUntil is null', () {
        const status = UserModerationStatus(
          usualId: 'u1',
          isMuted: true,
        );

        expect(status.activeRestrictionText, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final mutedUntil = DateTime(2026, 6, 2);
        final lastWarning = DateTime(2026, 6, 1);
        final status = UserModerationStatus(
          usualId: 'u1',
          warningCount: 2,
          reportCount: 3,
          isMuted: true,
          mutedUntil: mutedUntil,
          isSuspended: false,
          isBanned: false,
          lastWarningAt: lastWarning,
        );

        final json = status.toJson();

        expect(json['usualId'], equals('u1'));
        expect(json['warningCount'], equals(2));
        expect(json['reportCount'], equals(3));
        expect(json['isMuted'], isTrue);
        expect(json['mutedUntil'], isA<String>());
        expect(json['isSuspended'], isFalse);
        expect(json['suspendedUntil'], isNull);
        expect(json['isBanned'], isFalse);
        expect(json['banReason'], isNull);
        expect(json['activeSanctions'], isA<List>());
        expect(json['lastWarningAt'], isA<String>());
      });

      test('serializes activeSanctions as list of maps', () {
        final sanction = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.warning,
          reason: 'Test',
          action: ModerationAction.warning,
          createdAt: DateTime(2026, 6, 1),
        );

        final status = UserModerationStatus(
          usualId: 'u1',
          activeSanctions: [sanction],
        );

        final json = status.toJson();
        final sanctions = json['activeSanctions'] as List;
        expect(sanctions, hasLength(1));
        expect(sanctions[0], isA<Map<String, dynamic>>());
        expect(sanctions[0]['sanctionId'], equals('s1'));
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'usualId': 'u1',
          'warningCount': 3,
          'reportCount': 5,
          'isMuted': true,
          'mutedUntil': '2026-06-02T12:00:00.000',
          'isSuspended': false,
          'suspendedUntil': null,
          'isBanned': false,
          'banReason': null,
          'activeSanctions': [
            {
              'sanctionId': 's1',
              'usualId': 'u1',
              'type': 'warning',
              'reason': 'Test',
              'action': 'warning',
              'createdAt': '2026-06-01T12:00:00.000',
            },
          ],
          'lastWarningAt': '2026-06-01T10:00:00.000',
        };

        final status = UserModerationStatus.fromJson(json);

        expect(status.usualId, equals('u1'));
        expect(status.warningCount, equals(3));
        expect(status.reportCount, equals(5));
        expect(status.isMuted, isTrue);
        expect(status.mutedUntil, isNotNull);
        expect(status.isSuspended, isFalse);
        expect(status.suspendedUntil, isNull);
        expect(status.isBanned, isFalse);
        expect(status.banReason, isNull);
        expect(status.activeSanctions, hasLength(1));
        expect(status.activeSanctions[0].sanctionId, equals('s1'));
        expect(status.lastWarningAt, isNotNull);
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'usualId': 'u1',
        };

        final status = UserModerationStatus.fromJson(json);

        expect(status.warningCount, equals(0));
        expect(status.reportCount, equals(0));
        expect(status.isMuted, isFalse);
        expect(status.isSuspended, isFalse);
        expect(status.isBanned, isFalse);
        expect(status.activeSanctions, isEmpty);
      });

      test('handles null activeSanctions list', () {
        final json = {
          'usualId': 'u1',
          'activeSanctions': null,
        };

        final status = UserModerationStatus.fromJson(json);
        expect(status.activeSanctions, isEmpty);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('preserves all fields through serialization roundtrip', () {
        final sanction = UserSanction(
          sanctionId: 's1',
          usualId: 'u1',
          type: SanctionType.mute,
          reason: 'Profanity',
          action: ModerationAction.temporaryMute,
          createdAt: DateTime(2026, 6, 1),
          expiresAt: DateTime(2026, 6, 2),
        );

        final original = UserModerationStatus(
          usualId: 'u1',
          warningCount: 3,
          reportCount: 5,
          isMuted: true,
          mutedUntil: DateTime(2026, 6, 2),
          isSuspended: false,
          isBanned: false,
          activeSanctions: [sanction],
          lastWarningAt: DateTime(2026, 6, 1),
        );

        final restored = UserModerationStatus.fromJson(original.toJson());

        expect(restored.usualId, equals(original.usualId));
        expect(restored.warningCount, equals(original.warningCount));
        expect(restored.reportCount, equals(original.reportCount));
        expect(restored.isMuted, equals(original.isMuted));
        expect(restored.isSuspended, equals(original.isSuspended));
        expect(restored.isBanned, equals(original.isBanned));
        expect(restored.activeSanctions, hasLength(1));
      });
    });

    group('Equatable', () {
      test('two statuses with same props are equal', () {
        const s1 = UserModerationStatus(
          usualId: 'u1',
          warningCount: 2,
          isMuted: true,
        );

        const s2 = UserModerationStatus(
          usualId: 'u1',
          warningCount: 2,
          isMuted: true,
        );

        expect(s1, equals(s2));
      });

      test('two statuses with different warningCount are not equal', () {
        const s1 = UserModerationStatus(
          usualId: 'u1',
          warningCount: 2,
        );

        const s2 = UserModerationStatus(
          usualId: 'u1',
          warningCount: 3,
        );

        expect(s1, isNot(equals(s2)));
      });

      test('two statuses with different isBanned are not equal', () {
        const s1 = UserModerationStatus(
          usualId: 'u1',
          isBanned: false,
        );

        const s2 = UserModerationStatus(
          usualId: 'u1',
          isBanned: true,
        );

        expect(s1, isNot(equals(s2)));
      });

      test('props list includes all fields', () {
        const status = UserModerationStatus(usualId: 'u1');
        expect(status.props, hasLength(11));
      });
    });
  });
}
