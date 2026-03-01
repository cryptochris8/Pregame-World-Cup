import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/user_sanction.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_action_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ModerationActionService service;

  const moderatorId = 'moderator_123';
  const moderatorName = 'Admin User';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(moderatorId);
    when(() => mockUser.displayName).thenReturn(moderatorName);

    service = ModerationActionService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  // =========================================================================
  // getUserModerationStatus
  // =========================================================================
  group('getUserModerationStatus', () {
    test('returns empty status for unknown user', () async {
      final status = await service.getUserModerationStatus('unknown_user');

      expect(status.usualId, equals('unknown_user'));
      expect(status.warningCount, equals(0));
      expect(status.reportCount, equals(0));
      expect(status.isMuted, isFalse);
      expect(status.isSuspended, isFalse);
      expect(status.isBanned, isFalse);
    });

    test('returns correct status for muted user', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 2)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('muted_user')
          .set({
        'usualId': 'muted_user',
        'isMuted': true,
        'mutedUntil': futureTime,
        'warningCount': 1,
        'reportCount': 2,
      });

      final status = await service.getUserModerationStatus('muted_user');

      expect(status.isMuted, isTrue);
      expect(status.mutedUntil, isNotNull);
      expect(status.warningCount, equals(1));
      expect(status.reportCount, equals(2));
    });

    test('clears expired mute automatically', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('expired_mute_user')
          .set({
        'usualId': 'expired_mute_user',
        'isMuted': true,
        'mutedUntil': pastTime,
      });

      final status =
          await service.getUserModerationStatus('expired_mute_user');

      expect(status.isMuted, isFalse);
      expect(status.mutedUntil, isNull);
    });

    test('clears expired suspension automatically', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('expired_susp_user')
          .set({
        'usualId': 'expired_susp_user',
        'isSuspended': true,
        'suspendedUntil': pastTime,
      });

      final status =
          await service.getUserModerationStatus('expired_susp_user');

      expect(status.isSuspended, isFalse);
      expect(status.suspendedUntil, isNull);
    });

    test('returns banned status without expiration check', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('banned_user')
          .set({
        'usualId': 'banned_user',
        'isBanned': true,
        'banReason': 'Repeated violations',
      });

      final status = await service.getUserModerationStatus('banned_user');

      expect(status.isBanned, isTrue);
      expect(status.banReason, equals('Repeated violations'));
    });

    test('does not clear non-expired mute', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 5)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('active_mute_user')
          .set({
        'usualId': 'active_mute_user',
        'isMuted': true,
        'mutedUntil': futureTime,
      });

      final status =
          await service.getUserModerationStatus('active_mute_user');

      expect(status.isMuted, isTrue);
      expect(status.mutedUntil, isNotNull);
    });

    test('does not clear non-expired suspension', () async {
      final futureTime =
          DateTime.now().add(const Duration(days: 3)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('active_susp_user')
          .set({
        'usualId': 'active_susp_user',
        'isSuspended': true,
        'suspendedUntil': futureTime,
      });

      final status =
          await service.getUserModerationStatus('active_susp_user');

      expect(status.isSuspended, isTrue);
      expect(status.suspendedUntil, isNotNull);
    });
  });

  // =========================================================================
  // isCurrentUserMuted
  // =========================================================================
  group('isCurrentUserMuted', () {
    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isCurrentUserMuted();
      expect(result, isFalse);
    });

    test('returns false when user has no moderation status', () async {
      final result = await service.isCurrentUserMuted();
      expect(result, isFalse);
    });

    test('returns true when user is actively muted', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isMuted': true,
        'mutedUntil': futureTime,
      });

      final result = await service.isCurrentUserMuted();
      expect(result, isTrue);
    });

    test('returns false when mute has expired', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isMuted': true,
        'mutedUntil': pastTime,
      });

      final result = await service.isCurrentUserMuted();
      expect(result, isFalse);
    });
  });

  // =========================================================================
  // isCurrentUserSuspended
  // =========================================================================
  group('isCurrentUserSuspended', () {
    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isCurrentUserSuspended();
      expect(result, isFalse);
    });

    test('returns false when user has no moderation status', () async {
      final result = await service.isCurrentUserSuspended();
      expect(result, isFalse);
    });

    test('returns true when user is actively suspended', () async {
      final futureTime =
          DateTime.now().add(const Duration(days: 3)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isSuspended': true,
        'suspendedUntil': futureTime,
      });

      final result = await service.isCurrentUserSuspended();
      expect(result, isTrue);
    });

    test('returns false when suspension has expired', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isSuspended': true,
        'suspendedUntil': pastTime,
      });

      final result = await service.isCurrentUserSuspended();
      expect(result, isFalse);
    });
  });

  // =========================================================================
  // isCurrentUserBanned
  // =========================================================================
  group('isCurrentUserBanned', () {
    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isCurrentUserBanned();
      expect(result, isFalse);
    });

    test('returns false when user has no moderation status', () async {
      final result = await service.isCurrentUserBanned();
      expect(result, isFalse);
    });

    test('returns true when user is banned', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isBanned': true,
        'banReason': 'Extreme violations',
      });

      final result = await service.isCurrentUserBanned();
      expect(result, isTrue);
    });
  });

  // =========================================================================
  // getCurrentUserRestriction
  // =========================================================================
  group('getCurrentUserRestriction', () {
    test('returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.getCurrentUserRestriction();
      expect(result, isNull);
    });

    test('returns null for unrestricted user', () async {
      final result = await service.getCurrentUserRestriction();
      expect(result, isNull);
    });

    test('returns ban message for banned user', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isBanned': true,
      });

      final result = await service.getCurrentUserRestriction();
      expect(result, equals('Account permanently banned'));
    });

    test('returns suspension message for suspended user', () async {
      final futureTime =
          DateTime.now().add(const Duration(days: 3)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isSuspended': true,
        'suspendedUntil': futureTime,
      });

      final result = await service.getCurrentUserRestriction();
      expect(result, isNotNull);
      expect(result, contains('suspended'));
    });

    test('returns mute message for muted user', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 2)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc(moderatorId)
          .set({
        'usualId': moderatorId,
        'isMuted': true,
        'mutedUntil': futureTime,
      });

      final result = await service.getCurrentUserRestriction();
      expect(result, isNotNull);
      expect(result, contains('Muted'));
    });
  });

  // =========================================================================
  // issueWarning
  // =========================================================================
  group('issueWarning', () {
    test('creates warning sanction and returns it', () async {
      final sanction = await service.issueWarning(
        userId: 'warn_target',
        reason: 'First offense',
      );

      expect(sanction, isNotNull);
      expect(sanction!.usualId, equals('warn_target'));
      expect(sanction.type, equals(SanctionType.warning));
      expect(sanction.action, equals(ModerationAction.warning));
      expect(sanction.reason, equals('First offense'));
      expect(sanction.isActive, isTrue);
      expect(sanction.moderatorId, equals(moderatorId));
      expect(sanction.expiresAt, isNull);
    });

    test('increments warning count in moderation status', () async {
      await service.issueWarning(
        userId: 'warn_count_user',
        reason: 'Warning 1',
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('warn_count_user')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['warningCount'], equals(1));
    });

    test('increments warning count on multiple warnings', () async {
      await service.issueWarning(
        userId: 'multi_warn_user',
        reason: 'First warning',
      );
      await service.issueWarning(
        userId: 'multi_warn_user',
        reason: 'Second warning',
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('multi_warn_user')
          .get();

      expect(doc.data()!['warningCount'], equals(2));
    });

    test('stores sanction in sanctions collection', () async {
      final sanction = await service.issueWarning(
        userId: 'stored_warn_user',
        reason: 'Stored warning',
      );

      final doc = await fakeFirestore
          .collection('user_sanctions')
          .doc(sanction!.sanctionId)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['type'], equals('warning'));
      expect(doc.data()!['usualId'], equals('stored_warn_user'));
    });

    test('includes relatedReportId when provided', () async {
      final sanction = await service.issueWarning(
        userId: 'warn_report_user',
        reason: 'Warning from report',
        relatedReportId: 'report_123',
      );

      expect(sanction, isNotNull);
      expect(sanction!.relatedReportId, equals('report_123'));
    });

    test('returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final sanction = await service.issueWarning(
        userId: 'some_user',
        reason: 'Some reason',
      );

      expect(sanction, isNull);
    });

    test('updates lastWarningAt in moderation status', () async {
      await service.issueWarning(
        userId: 'last_warn_user',
        reason: 'Test warning',
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('last_warn_user')
          .get();

      expect(doc.data()!['lastWarningAt'], isNotNull);
    });
  });

  // =========================================================================
  // muteUser
  // =========================================================================
  group('muteUser', () {
    test('creates mute sanction with expiry', () async {
      final sanction = await service.muteUser(
        userId: 'mute_target',
        reason: 'Profanity',
        duration: const Duration(hours: 24),
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.mute));
      expect(sanction.action, equals(ModerationAction.temporaryMute));
      expect(sanction.expiresAt, isNotNull);
      expect(sanction.usualId, equals('mute_target'));
      expect(sanction.moderatorId, equals(moderatorId));
    });

    test('updates moderation status to muted', () async {
      await service.muteUser(
        userId: 'mute_status_user',
        reason: 'Repeated profanity',
        duration: const Duration(hours: 12),
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('mute_status_user')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['isMuted'], isTrue);
      expect(doc.data()!['mutedUntil'], isNotNull);
    });

    test('returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final sanction = await service.muteUser(
        userId: 'some_user',
        reason: 'Some reason',
        duration: const Duration(hours: 1),
      );

      expect(sanction, isNull);
    });

    test('mute expiry is approximately correct', () async {
      final before = DateTime.now();

      final sanction = await service.muteUser(
        userId: 'mute_time_user',
        reason: 'Time check',
        duration: const Duration(hours: 6),
      );

      final after = DateTime.now().add(const Duration(hours: 6));

      expect(sanction!.expiresAt, isNotNull);
      expect(sanction.expiresAt!.isAfter(before), isTrue);
      expect(
        sanction.expiresAt!.isBefore(after.add(const Duration(seconds: 5))),
        isTrue,
      );
    });
  });

  // =========================================================================
  // suspendUser
  // =========================================================================
  group('suspendUser', () {
    test('creates suspension sanction with expiry', () async {
      final sanction = await service.suspendUser(
        userId: 'suspend_target',
        reason: 'Harassment',
        duration: const Duration(days: 7),
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.suspension));
      expect(sanction.action, equals(ModerationAction.temporarySuspension));
      expect(sanction.expiresAt, isNotNull);
      expect(sanction.reason, equals('Harassment'));
    });

    test('updates moderation status to suspended', () async {
      await service.suspendUser(
        userId: 'susp_status_user',
        reason: 'Repeated harassment',
        duration: const Duration(days: 14),
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('susp_status_user')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['isSuspended'], isTrue);
      expect(doc.data()!['suspendedUntil'], isNotNull);
    });

    test('returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final sanction = await service.suspendUser(
        userId: 'some_user',
        reason: 'Some reason',
        duration: const Duration(days: 1),
      );

      expect(sanction, isNull);
    });

    test('includes relatedReportId when provided', () async {
      final sanction = await service.suspendUser(
        userId: 'susp_report_user',
        reason: 'From report',
        duration: const Duration(days: 3),
        relatedReportId: 'report_456',
      );

      expect(sanction!.relatedReportId, equals('report_456'));
    });
  });

  // =========================================================================
  // banUser
  // =========================================================================
  group('banUser', () {
    test('creates permanent ban sanction without expiry', () async {
      final sanction = await service.banUser(
        userId: 'ban_target',
        reason: 'Extreme violations',
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.permanentBan));
      expect(sanction.action, equals(ModerationAction.permanentBan));
      expect(sanction.expiresAt, isNull);
      expect(sanction.reason, equals('Extreme violations'));
    });

    test('updates moderation status to banned with reason', () async {
      await service.banUser(
        userId: 'ban_status_user',
        reason: 'Policy violation',
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('ban_status_user')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['isBanned'], isTrue);
      expect(doc.data()!['banReason'], equals('Policy violation'));
    });

    test('returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final sanction = await service.banUser(
        userId: 'some_user',
        reason: 'Some reason',
      );

      expect(sanction, isNull);
    });

    test('includes relatedReportId when provided', () async {
      final sanction = await service.banUser(
        userId: 'ban_report_user',
        reason: 'From report',
        relatedReportId: 'report_789',
      );

      expect(sanction!.relatedReportId, equals('report_789'));
    });
  });

  // =========================================================================
  // getUserSanctions
  // =========================================================================
  group('getUserSanctions', () {
    test('returns empty list for user without sanctions', () async {
      final sanctions = await service.getUserSanctions('clean_user');
      expect(sanctions, isEmpty);
    });

    test('returns sanctions for user', () async {
      await service.issueWarning(
        userId: 'sanctioned_user',
        reason: 'First offense',
      );
      await service.muteUser(
        userId: 'sanctioned_user',
        reason: 'Second offense',
        duration: const Duration(hours: 1),
      );

      final sanctions = await service.getUserSanctions('sanctioned_user');

      expect(sanctions.length, equals(2));
      expect(
        sanctions.every((s) => s.usualId == 'sanctioned_user'),
        isTrue,
      );
    });

    test('sanctions are ordered by createdAt descending', () async {
      await service.issueWarning(
        userId: 'ordered_user',
        reason: 'First',
      );
      // Add small delay for ordering
      await Future.delayed(const Duration(milliseconds: 10));
      await service.muteUser(
        userId: 'ordered_user',
        reason: 'Second',
        duration: const Duration(hours: 1),
      );

      final sanctions = await service.getUserSanctions('ordered_user');

      expect(sanctions.length, equals(2));
      // The query orders descending, so newest first
      if (sanctions.length == 2) {
        expect(
          sanctions[0].createdAt.isAfter(sanctions[1].createdAt) ||
              sanctions[0].createdAt.isAtSameMomentAs(sanctions[1].createdAt),
          isTrue,
        );
      }
    });

    test('returns sanctions of different types', () async {
      await service.issueWarning(
        userId: 'multi_type_user',
        reason: 'Warning',
      );
      await service.muteUser(
        userId: 'multi_type_user',
        reason: 'Mute',
        duration: const Duration(hours: 1),
      );
      await service.suspendUser(
        userId: 'multi_type_user',
        reason: 'Suspension',
        duration: const Duration(days: 1),
      );

      final sanctions = await service.getUserSanctions('multi_type_user');

      expect(sanctions.length, equals(3));

      final types = sanctions.map((s) => s.type).toSet();
      expect(types, contains(SanctionType.warning));
      expect(types, contains(SanctionType.mute));
      expect(types, contains(SanctionType.suspension));
    });
  });

  // =========================================================================
  // _copyWithStatus helper (tested indirectly through getUserModerationStatus)
  // =========================================================================
  group('Status copy helper (via getUserModerationStatus)', () {
    test('expired mute returns correct flags but preserves other fields', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('copy_test_user')
          .set({
        'usualId': 'copy_test_user',
        'isMuted': true,
        'mutedUntil': pastTime,
        'warningCount': 3,
        'reportCount': 5,
        'isSuspended': false,
        'isBanned': false,
      });

      final status =
          await service.getUserModerationStatus('copy_test_user');

      expect(status.isMuted, isFalse); // Cleared
      expect(status.mutedUntil, isNull); // Cleared
      expect(status.warningCount, equals(3)); // Preserved
      expect(status.reportCount, equals(5)); // Preserved
    });

    test('expired suspension returns correct flags but preserves other fields', () async {
      final pastTime =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('susp_copy_user')
          .set({
        'usualId': 'susp_copy_user',
        'isSuspended': true,
        'suspendedUntil': pastTime,
        'warningCount': 2,
        'isMuted': false,
        'isBanned': false,
      });

      final status =
          await service.getUserModerationStatus('susp_copy_user');

      expect(status.isSuspended, isFalse); // Cleared
      expect(status.suspendedUntil, isNull); // Cleared
      expect(status.warningCount, equals(2)); // Preserved
    });
  });

  // =========================================================================
  // Integration: full sanction lifecycle
  // =========================================================================
  group('Full sanction lifecycle', () {
    test('warning -> mute -> suspension -> ban escalation', () async {
      const targetUser = 'escalation_user';

      // Issue warning
      final warning = await service.issueWarning(
        userId: targetUser,
        reason: 'First offense',
      );
      expect(warning, isNotNull);
      expect(warning!.type, equals(SanctionType.warning));

      // Mute
      final mute = await service.muteUser(
        userId: targetUser,
        reason: 'Continued behavior',
        duration: const Duration(hours: 24),
      );
      expect(mute, isNotNull);
      expect(mute!.type, equals(SanctionType.mute));

      // Suspend
      final suspension = await service.suspendUser(
        userId: targetUser,
        reason: 'Serious violation',
        duration: const Duration(days: 7),
      );
      expect(suspension, isNotNull);
      expect(suspension!.type, equals(SanctionType.suspension));

      // Ban
      final ban = await service.banUser(
        userId: targetUser,
        reason: 'Final violation',
      );
      expect(ban, isNotNull);
      expect(ban!.type, equals(SanctionType.permanentBan));

      // Verify all sanctions recorded
      final allSanctions = await service.getUserSanctions(targetUser);
      expect(allSanctions.length, equals(4));

      // Verify final moderation status
      final status = await service.getUserModerationStatus(targetUser);
      expect(status.isBanned, isTrue);
    });
  });
}
