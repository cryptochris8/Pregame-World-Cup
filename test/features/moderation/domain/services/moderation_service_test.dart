import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/user_sanction.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/profanity_filter_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  // ModerationService uses a singleton, but accepts injected dependencies
  // on the first construction. We exploit this by constructing it once with
  // a FakeFirebaseFirestore (which we recreate per-group) and a MockAuth.
  //
  // Because the singleton holds on to the first-created Firestore & Auth
  // instances, we organise the tests so that every group that needs a clean
  // slate creates fresh Firestore data rather than a fresh service.
  //
  // IMPORTANT: This file must run in isolation (or at least no other test
  // file in the same process should construct ModerationService beforehand).
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ModerationService service;

  setUpAll(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_user_123');
    when(() => mockUser.displayName).thenReturn('Test User');

    // First (and only) construction -- sets the singleton.
    service = ModerationService(
      firestore: fakeFirestore,
      auth: mockAuth,
      profanityFilter: ProfanityFilterService(),
    );
  });

  // Before each test, make sure a user profile exists for the reporter.
  setUp(() async {
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_user_123');
    when(() => mockUser.displayName).thenReturn('Test User');

    await fakeFirestore.collection('users').doc('test_user_123').set({
      'displayName': 'Test User',
      'email': 'test@example.com',
    });
  });

  // ===========================================================================
  // Content Filtering (synchronous, no Firestore)
  // ===========================================================================
  group('Content Filtering', () {
    test('filterContent returns clean result for appropriate text', () {
      final result = service.filterContent('Great game today!');

      expect(result.containsProfanity, isFalse);
      expect(result.filteredText, equals('Great game today!'));
      expect(result.flaggedWords, isEmpty);
      expect(result.shouldAutoReject, isFalse);
    });

    test('isContentAppropriate returns true for clean text', () {
      expect(service.isContentAppropriate('Go team!'), isTrue);
    });

    test('isContentAppropriate returns false for profane text', () {
      expect(service.isContentAppropriate('this is fucking awesome'), isFalse);
    });

    test('getCensoredContent censors profanity while keeping first/last chars', () {
      final censored = service.getCensoredContent('what the fuck');
      expect(censored, contains('f**k'));
      expect(censored, isNot(equals('what the fuck')));
    });

    test('filterContent detects Spanish profanity', () {
      final result = service.filterContent('eres un pendejo');
      expect(result.containsProfanity, isTrue);
      expect(result.flaggedWords, contains('pendejo'));
    });

    test('filterContent detects Portuguese profanity', () {
      final result = service.filterContent('isso eh uma merda');
      expect(result.containsProfanity, isTrue);
      expect(result.flaggedWords, contains('merda'));
    });

    test('filterContent flags scam content for auto-rejection', () {
      final result = service.filterContent(
        'Congratulations you won a free money prize',
      );
      expect(result.shouldAutoReject, isTrue);
    });

    test('filterContent returns clean for empty text', () {
      final result = service.filterContent('');
      expect(result.containsProfanity, isFalse);
      expect(result.filteredText, isEmpty);
    });
  });

  // ===========================================================================
  // Message Validation
  // ===========================================================================
  group('Message Validation', () {
    test('validateMessage returns valid for clean message', () async {
      final result = await service.validateMessage('Hello everyone!');

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.filteredMessage, equals('Hello everyone!'));
      expect(result.wasFiltered, isFalse);
    });

    test('validateMessage filters mild profanity but remains valid', () async {
      final result =
          await service.validateMessage('What the hell is going on');

      expect(result.isValid, isTrue);
      expect(result.wasFiltered, isTrue);
      expect(result.filteredMessage, isNotNull);
    });

    test('validateMessage returns invalid when user is muted', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 1)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .set({
        'usualId': 'test_user_123',
        'isMuted': true,
        'mutedUntil': futureTime,
      });

      final result = await service.validateMessage('Hello');

      expect(result.isValid, isFalse);
      expect(
        result.errorMessage,
        equals('You are currently muted and cannot send messages'),
      );

      // Clean up for other tests
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .delete();
    });

    test('validateMessage rejects scam content', () async {
      final result = await service.validateMessage(
        'Congratulations you won free money click here now',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });

  // ===========================================================================
  // Report Submission
  // ===========================================================================
  group('Report Submission', () {
    test('submitReport creates report document in Firestore', () async {
      final report = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_submit_test',
        reason: ReportReason.harassment,
        contentOwnerId: 'offending_user',
        contentOwnerDisplayName: 'Bad User',
        additionalDetails: 'This is inappropriate',
        contentSnapshot: 'Some bad message',
      );

      expect(report, isNotNull);
      expect(report!.reporterId, equals('test_user_123'));
      expect(report.reporterDisplayName, equals('Test User'));
      expect(report.contentType, equals(ReportableContentType.message));
      expect(report.contentId, equals('msg_submit_test'));
      expect(report.contentOwnerId, equals('offending_user'));
      expect(report.reason, equals(ReportReason.harassment));
      expect(report.status, equals(ReportStatus.pending));
      expect(report.additionalDetails, equals('This is inappropriate'));
      expect(report.contentSnapshot, equals('Some bad message'));
    });

    test('submitReport returns null when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final report = await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'user_456',
        reason: ReportReason.spam,
      );

      expect(report, isNull);

      // Restore logged-in state
      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    test('submitReport returns existing report for duplicate submission', () async {
      // First report
      final report1 = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_dup_test',
        reason: ReportReason.harassment,
      );

      // Duplicate
      final report2 = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_dup_test',
        reason: ReportReason.spam,
      );

      expect(report1, isNotNull);
      expect(report2, isNotNull);
      // Should return the same report (not create a new one)
      expect(report2!.reportId, equals(report1!.reportId));
    });

    test('submitReport increments report count for content owner', () async {
      await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'owner_count_test',
        contentOwnerId: 'counted_user',
        reason: ReportReason.harassment,
      );

      final doc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('counted_user')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['reportCount'], equals(1));
    });

    test('reportUser creates report with user content type', () async {
      final report = await service.reportUser(
        userId: 'bad_user_report_test',
        userDisplayName: 'Bad User',
        reason: ReportReason.impersonation,
        additionalDetails: 'Pretending to be FIFA official',
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.user));
      expect(report.contentId, equals('bad_user_report_test'));
      expect(report.contentOwnerDisplayName, equals('Bad User'));
    });

    test('reportMessage includes message content as snapshot', () async {
      final report = await service.reportMessage(
        messageId: 'msg_report_test',
        senderId: 'sender_456',
        senderDisplayName: 'Sender',
        messageContent: 'The offensive message text',
        reason: ReportReason.hateSpeech,
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.message));
      expect(report.contentSnapshot, equals('The offensive message text'));
    });

    test('reportWatchParty includes party name as snapshot', () async {
      final report = await service.reportWatchParty(
        watchPartyId: 'wp_report_test',
        hostId: 'host_456',
        hostDisplayName: 'Host Name',
        watchPartyName: 'Inappropriate Party',
        reason: ReportReason.inappropriateContent,
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.watchParty));
      expect(report.contentSnapshot, equals('Inappropriate Party'));
    });
  });

  // ===========================================================================
  // User Moderation Status
  // ===========================================================================
  group('User Moderation Status', () {
    test('getUserModerationStatus returns empty status for unknown user', () async {
      final status = await service.getUserModerationStatus('nonexistent_user');

      expect(status.usualId, equals('nonexistent_user'));
      expect(status.warningCount, equals(0));
      expect(status.reportCount, equals(0));
      expect(status.isMuted, isFalse);
      expect(status.isSuspended, isFalse);
      expect(status.isBanned, isFalse);
    });

    test('getUserModerationStatus returns correct muted status', () async {
      final futureTime =
          DateTime.now().add(const Duration(hours: 2)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('muted_status_user')
          .set({
        'usualId': 'muted_status_user',
        'isMuted': true,
        'mutedUntil': futureTime,
        'warningCount': 2,
        'reportCount': 3,
      });

      final status =
          await service.getUserModerationStatus('muted_status_user');

      expect(status.isMuted, isTrue);
      expect(status.mutedUntil, isNotNull);
      expect(status.warningCount, equals(2));
      expect(status.reportCount, equals(3));
    });

    test('getUserModerationStatus clears expired mute', () async {
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
    });

    test('getUserModerationStatus returns banned status', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('banned_status_user')
          .set({
        'usualId': 'banned_status_user',
        'isBanned': true,
        'banReason': 'Repeated violations',
      });

      final status =
          await service.getUserModerationStatus('banned_status_user');

      expect(status.isBanned, isTrue);
      expect(status.banReason, equals('Repeated violations'));
      expect(status.canAccessApp, isFalse);
    });

    test('getUserModerationStatus clears expired suspension', () async {
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
    });

    test('isCurrentUserMuted returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isCurrentUserMuted();
      expect(result, isFalse);

      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    test('isCurrentUserBanned returns true when banned', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .set({
        'usualId': 'test_user_123',
        'isBanned': true,
        'banReason': 'Policy violation',
      });

      final result = await service.isCurrentUserBanned();
      expect(result, isTrue);

      // Clean up
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .delete();
    });

    test('getCurrentUserRestriction returns null for unrestricted user', () async {
      final result = await service.getCurrentUserRestriction();
      expect(result, isNull);
    });

    test('getCurrentUserRestriction returns ban message for banned user', () async {
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .set({
        'usualId': 'test_user_123',
        'isBanned': true,
      });

      final result = await service.getCurrentUserRestriction();
      expect(result, equals('Account permanently banned'));

      // Clean up
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .delete();
    });
  });

  // ===========================================================================
  // Report Checking
  // ===========================================================================
  group('Report Checking', () {
    setUp(() async {
      await fakeFirestore.collection('reports').doc('check_report_1').set({
        'reportId': 'check_report_1',
        'reporterId': 'test_user_123',
        'reporterDisplayName': 'Test User',
        'contentType': 'message',
        'contentId': 'msg_check_existing',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    });

    test('hasReportedContent returns true for already reported content', () async {
      final result = await service.hasReportedContent(
        'msg_check_existing',
        ReportableContentType.message,
      );
      expect(result, isTrue);
    });

    test('hasReportedContent returns false for unreported content', () async {
      final result = await service.hasReportedContent(
        'msg_never_reported',
        ReportableContentType.message,
      );
      expect(result, isFalse);
    });

    test('hasReportedContent returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.hasReportedContent(
        'msg_check_existing',
        ReportableContentType.message,
      );
      expect(result, isFalse);

      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    test('getMyReports returns reports for current user', () async {
      final reports = await service.getMyReports();
      expect(reports, isNotEmpty);
      expect(
        reports.every((r) => r.reporterId == 'test_user_123'),
        isTrue,
      );
    });

    test('getMyReports returns empty when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final reports = await service.getMyReports();
      expect(reports, isEmpty);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });
  });

  // ===========================================================================
  // Admin Sanction Functions
  // ===========================================================================
  group('Admin Sanction Functions', () {
    test('issueWarning creates warning sanction and increments counter', () async {
      final sanction = await service.issueWarning(
        userId: 'warn_target_1',
        reason: 'First warning for behavior',
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.warning));
      expect(sanction.usualId, equals('warn_target_1'));
      expect(sanction.reason, equals('First warning for behavior'));
      expect(sanction.isActive, isTrue);
      expect(sanction.moderatorId, equals('test_user_123'));

      final statusDoc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('warn_target_1')
          .get();
      expect(statusDoc.data()!['warningCount'], equals(1));
    });

    test('issueWarning returns null when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final sanction = await service.issueWarning(
        userId: 'some_user',
        reason: 'Some reason',
      );
      expect(sanction, isNull);

      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    test('muteUser creates mute sanction and updates status', () async {
      final sanction = await service.muteUser(
        userId: 'mute_target_1',
        reason: 'Repeated profanity',
        duration: const Duration(hours: 24),
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.mute));
      expect(sanction.expiresAt, isNotNull);

      final statusDoc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('mute_target_1')
          .get();
      expect(statusDoc.data()!['isMuted'], isTrue);
      expect(statusDoc.data()!['mutedUntil'], isNotNull);
    });

    test('suspendUser creates suspension and updates status', () async {
      final sanction = await service.suspendUser(
        userId: 'suspend_target_1',
        reason: 'Harassment',
        duration: const Duration(days: 7),
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.suspension));
      expect(sanction.action, equals(ModerationAction.temporarySuspension));
      expect(sanction.expiresAt, isNotNull);

      final statusDoc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('suspend_target_1')
          .get();
      expect(statusDoc.data()!['isSuspended'], isTrue);
    });

    test('banUser creates permanent ban', () async {
      final sanction = await service.banUser(
        userId: 'ban_target_1',
        reason: 'Extreme violations',
      );

      expect(sanction, isNotNull);
      expect(sanction!.type, equals(SanctionType.permanentBan));
      expect(sanction.action, equals(ModerationAction.permanentBan));
      expect(sanction.expiresAt, isNull);

      final statusDoc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('ban_target_1')
          .get();
      expect(statusDoc.data()!['isBanned'], isTrue);
      expect(
        statusDoc.data()!['banReason'],
        equals('Extreme violations'),
      );
    });

    test('getUserSanctions returns sanctions for user', () async {
      await service.issueWarning(
        userId: 'multi_sanction_user',
        reason: 'First offense',
      );
      await service.muteUser(
        userId: 'multi_sanction_user',
        reason: 'Second offense',
        duration: const Duration(hours: 1),
      );

      final sanctions =
          await service.getUserSanctions('multi_sanction_user');

      expect(sanctions.length, equals(2));
      expect(
        sanctions.every((s) => s.usualId == 'multi_sanction_user'),
        isTrue,
      );
    });

    test('getUserSanctions returns empty for user without sanctions', () async {
      final sanctions = await service.getUserSanctions('clean_user_xyz');
      expect(sanctions, isEmpty);
    });

    test('resolveReport updates report status', () async {
      await fakeFirestore
          .collection('reports')
          .doc('resolve_target_1')
          .set({
        'reportId': 'resolve_target_1',
        'reporterId': 'reporter',
        'reporterDisplayName': 'Reporter',
        'contentType': 'message',
        'contentId': 'msg_bad',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final result = await service.resolveReport(
        reportId: 'resolve_target_1',
        action: ModerationAction.warning,
        moderatorNotes: 'Issued a warning',
      );

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('reports')
          .doc('resolve_target_1')
          .get();
      expect(doc.data()!['status'], equals('resolved'));
      expect(doc.data()!['actionTaken'], equals('warning'));
      expect(doc.data()!['moderatorId'], equals('test_user_123'));
    });

    test('resolveReport returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.resolveReport(
        reportId: 'some_report',
        action: ModerationAction.warning,
      );
      expect(result, isFalse);

      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    test('getPendingReports returns only pending reports', () async {
      await fakeFirestore.collection('reports').doc('pending_filter_1').set({
        'reportId': 'pending_filter_1',
        'reporterId': 'user_1',
        'reporterDisplayName': 'User 1',
        'contentType': 'message',
        'contentId': 'msg_pf1',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await fakeFirestore.collection('reports').doc('resolved_filter_1').set({
        'reportId': 'resolved_filter_1',
        'reporterId': 'user_2',
        'reporterDisplayName': 'User 2',
        'contentType': 'user',
        'contentId': 'user_bad',
        'reason': 'harassment',
        'status': 'resolved',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final pending = await service.getPendingReports();

      // All returned reports should have pending status
      for (final report in pending) {
        expect(report.status, equals(ReportStatus.pending));
      }
    });
  });

  // ===========================================================================
  // Watch Party Validation
  // ===========================================================================
  group('Watch Party Validation', () {
    test('validateWatchParty returns valid for clean content', () async {
      final result = await service.validateWatchParty(
        name: 'USA vs Mexico Watch Party',
        description: 'Join us to watch the big game!',
      );

      expect(result.isValid, isTrue);
      expect(result.wasFiltered, isFalse);
      expect(result.filteredName, equals('USA vs Mexico Watch Party'));
      expect(
        result.filteredDescription,
        equals('Join us to watch the big game!'),
      );
    });

    test('validateWatchParty returns invalid for suspended user', () async {
      final futureTime =
          DateTime.now().add(const Duration(days: 3)).toIso8601String();

      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .set({
        'usualId': 'test_user_123',
        'isSuspended': true,
        'suspendedUntil': futureTime,
      });

      final result = await service.validateWatchParty(
        name: 'My Party',
        description: 'A fun gathering',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('suspended'));

      // Clean up
      await fakeFirestore
          .collection('user_moderation_status')
          .doc('test_user_123')
          .delete();
    });
  });

  // ===========================================================================
  // Entity Model Tests (Report, UserSanction, UserModerationStatus)
  // ===========================================================================
  group('Report entity', () {
    test('toJson/fromJson roundtrip preserves all fields', () {
      final original = Report(
        reportId: 'r1',
        reporterId: 'u1',
        reporterDisplayName: 'User One',
        contentType: ReportableContentType.watchParty,
        contentId: 'wp_1',
        contentOwnerId: 'u2',
        contentOwnerDisplayName: 'User Two',
        reason: ReportReason.hateSpeech,
        additionalDetails: 'Details here',
        contentSnapshot: 'Snapshot text',
        status: ReportStatus.resolved,
        actionTaken: ModerationAction.temporaryMute,
        moderatorId: 'mod1',
        moderatorNotes: 'Muted for 24h',
        createdAt: DateTime(2026, 6, 1, 12, 0),
        reviewedAt: DateTime(2026, 6, 1, 13, 0),
        resolvedAt: DateTime(2026, 6, 1, 14, 0),
      );

      final json = original.toJson();
      final restored = Report.fromJson(json);

      expect(restored.reportId, equals(original.reportId));
      expect(restored.reporterId, equals(original.reporterId));
      expect(restored.contentType, equals(original.contentType));
      expect(restored.reason, equals(original.reason));
      expect(restored.status, equals(original.status));
      expect(restored.actionTaken, equals(original.actionTaken));
      expect(restored.moderatorId, equals(original.moderatorId));
    });

    test('reasonDisplayText returns human-readable text', () {
      final report = Report(
        reportId: 'r1',
        reporterId: 'u1',
        reporterDisplayName: 'User',
        contentType: ReportableContentType.user,
        contentId: 'u2',
        reason: ReportReason.harassment,
        createdAt: DateTime.now(),
      );

      expect(report.reasonDisplayText, equals('Harassment or Bullying'));
    });

    test('contentTypeDisplayText returns human-readable text', () {
      final report = Report(
        reportId: 'r1',
        reporterId: 'u1',
        reporterDisplayName: 'User',
        contentType: ReportableContentType.watchParty,
        contentId: 'wp1',
        reason: ReportReason.spam,
        createdAt: DateTime.now(),
      );

      expect(report.contentTypeDisplayText, equals('Watch Party'));
    });
  });

  group('UserSanction entity', () {
    test('toJson/fromJson roundtrip preserves all fields', () {
      final original = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.mute,
        reason: 'Profanity',
        relatedReportId: 'r1',
        action: ModerationAction.temporaryMute,
        createdAt: DateTime(2026, 6, 1, 12, 0),
        expiresAt: DateTime(2026, 6, 2, 12, 0),
        isActive: true,
        moderatorId: 'mod1',
      );

      final json = original.toJson();
      final restored = UserSanction.fromJson(json);

      expect(restored.sanctionId, equals(original.sanctionId));
      expect(restored.usualId, equals(original.usualId));
      expect(restored.type, equals(original.type));
      expect(restored.action, equals(original.action));
      expect(restored.isActive, equals(original.isActive));
    });

    test('hasExpired returns false when expiresAt is in the future', () {
      final sanction = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.mute,
        reason: 'Test',
        action: ModerationAction.temporaryMute,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(sanction.hasExpired, isFalse);
    });

    test('hasExpired returns true when expiresAt is in the past', () {
      final sanction = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.mute,
        reason: 'Test',
        action: ModerationAction.temporaryMute,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(sanction.hasExpired, isTrue);
    });

    test('hasExpired returns false when expiresAt is null (permanent)', () {
      final sanction = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.permanentBan,
        reason: 'Test',
        action: ModerationAction.permanentBan,
        createdAt: DateTime.now(),
        expiresAt: null,
      );

      expect(sanction.hasExpired, isFalse);
    });

    test('durationText returns Permanent for null expiresAt', () {
      final sanction = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.permanentBan,
        reason: 'Test',
        action: ModerationAction.permanentBan,
        createdAt: DateTime.now(),
        expiresAt: null,
      );

      expect(sanction.durationText, equals('Permanent'));
    });

    test('durationText returns days for multi-day sanctions', () {
      final now = DateTime.now();
      final sanction = UserSanction(
        sanctionId: 's1',
        usualId: 'u1',
        type: SanctionType.suspension,
        reason: 'Test',
        action: ModerationAction.temporarySuspension,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      expect(sanction.durationText, equals('7 days'));
    });
  });

  group('UserModerationStatus entity', () {
    test('empty() factory creates clean status', () {
      final status = UserModerationStatus.empty('user1');

      expect(status.usualId, equals('user1'));
      expect(status.canSendMessages, isTrue);
      expect(status.canCreateWatchParties, isTrue);
      expect(status.canAccessApp, isTrue);
      expect(status.activeRestrictionText, isNull);
    });

    test('canSendMessages is false when muted', () {
      const status = UserModerationStatus(
        usualId: 'u1',
        isMuted: true,
      );
      expect(status.canSendMessages, isFalse);
    });

    test('canCreateWatchParties is false when suspended', () {
      const status = UserModerationStatus(
        usualId: 'u1',
        isSuspended: true,
      );
      expect(status.canCreateWatchParties, isFalse);
    });

    test('canAccessApp is false when banned', () {
      const status = UserModerationStatus(
        usualId: 'u1',
        isBanned: true,
      );
      expect(status.canAccessApp, isFalse);
    });

    test('toJson/fromJson roundtrip preserves fields', () {
      final original = UserModerationStatus(
        usualId: 'u1',
        warningCount: 3,
        reportCount: 5,
        isMuted: true,
        mutedUntil: DateTime(2026, 7, 1),
        isSuspended: false,
        isBanned: false,
      );

      final json = original.toJson();
      final restored = UserModerationStatus.fromJson(json);

      expect(restored.usualId, equals('u1'));
      expect(restored.warningCount, equals(3));
      expect(restored.reportCount, equals(5));
      expect(restored.isMuted, isTrue);
    });
  });
}
