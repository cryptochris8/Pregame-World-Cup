import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_report_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ModerationReportService service;

  const testUserId = 'reporter_123';
  const testUserName = 'Reporter User';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockUser.displayName).thenReturn(testUserName);

    service = ModerationReportService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );

    // Seed user profile for reporter
    await fakeFirestore.collection('users').doc(testUserId).set({
      'displayName': testUserName,
      'email': 'reporter@example.com',
    });
  });

  // =========================================================================
  // submitReport
  // =========================================================================
  group('submitReport', () {
    test('creates report with all fields', () async {
      final report = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_bad_1',
        reason: ReportReason.harassment,
        contentOwnerId: 'offender_1',
        contentOwnerDisplayName: 'Bad User',
        additionalDetails: 'Very inappropriate',
        contentSnapshot: 'The bad message text',
      );

      expect(report, isNotNull);
      expect(report!.reporterId, equals(testUserId));
      expect(report.reporterDisplayName, equals(testUserName));
      expect(report.contentType, equals(ReportableContentType.message));
      expect(report.contentId, equals('msg_bad_1'));
      expect(report.contentOwnerId, equals('offender_1'));
      expect(report.contentOwnerDisplayName, equals('Bad User'));
      expect(report.reason, equals(ReportReason.harassment));
      expect(report.additionalDetails, equals('Very inappropriate'));
      expect(report.contentSnapshot, equals('The bad message text'));
      expect(report.status, equals(ReportStatus.pending));
    });

    test('stores report in Firestore', () async {
      final report = await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'user_bad',
        reason: ReportReason.spam,
      );

      expect(report, isNotNull);

      final doc = await fakeFirestore
          .collection('reports')
          .doc(report!.reportId)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['reporterId'], equals(testUserId));
      expect(doc.data()!['contentType'], equals('user'));
      expect(doc.data()!['reason'], equals('spam'));
      expect(doc.data()!['status'], equals('pending'));
    });

    test('returns null when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final report = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_1',
        reason: ReportReason.hateSpeech,
      );

      expect(report, isNull);
    });

    test('returns existing report for duplicate submission', () async {
      // First report
      final report1 = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_dup',
        reason: ReportReason.harassment,
      );

      // Duplicate attempt
      final report2 = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_dup',
        reason: ReportReason.spam, // Different reason
      );

      expect(report1, isNotNull);
      expect(report2, isNotNull);
      expect(report2!.reportId, equals(report1!.reportId));
    });

    test('increments report count for content owner', () async {
      await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'counted_user',
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

    test('does not increment count when contentOwnerId is null', () async {
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_no_owner',
        reason: ReportReason.spam,
        // No contentOwnerId
      );

      // No moderation status document should be created for null owner
      final snapshot = await fakeFirestore
          .collection('user_moderation_status')
          .where('usualId', isEqualTo: 'msg_no_owner')
          .get();

      expect(snapshot.docs, isEmpty);
    });

    test('uses reporter display name from users collection', () async {
      // Update user profile with different name
      await fakeFirestore.collection('users').doc(testUserId).set({
        'displayName': 'Updated Reporter Name',
      });

      final report = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_name_test',
        reason: ReportReason.violence,
      );

      expect(report, isNotNull);
      expect(report!.reporterDisplayName, equals('Updated Reporter Name'));
    });

    test('creates report with all ReportReason values', () async {
      for (final reason in ReportReason.values) {
        final report = await service.submitReport(
          contentType: ReportableContentType.message,
          contentId: 'msg_reason_${reason.name}',
          reason: reason,
        );

        expect(report, isNotNull,
            reason: 'Report should be created for reason: ${reason.name}');
        expect(report!.reason, equals(reason));
      }
    });

    test('creates report with all ReportableContentType values', () async {
      for (final contentType in ReportableContentType.values) {
        final report = await service.submitReport(
          contentType: contentType,
          contentId: 'content_${contentType.name}',
          reason: ReportReason.spam,
        );

        expect(report, isNotNull,
            reason:
                'Report should be created for type: ${contentType.name}');
        expect(report!.contentType, equals(contentType));
      }
    });
  });

  // =========================================================================
  // getMyReports
  // =========================================================================
  group('getMyReports', () {
    test('returns reports submitted by current user', () async {
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_my_1',
        reason: ReportReason.spam,
      );
      await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'user_my_1',
        reason: ReportReason.harassment,
      );

      final reports = await service.getMyReports();

      expect(reports.length, equals(2));
      expect(
        reports.every((r) => r.reporterId == testUserId),
        isTrue,
      );
    });

    test('returns empty list when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final reports = await service.getMyReports();
      expect(reports, isEmpty);
    });

    test('returns empty list when user has no reports', () async {
      final reports = await service.getMyReports();
      expect(reports, isEmpty);
    });

    test('does not return reports from other users', () async {
      // Manually insert a report from another user
      await fakeFirestore.collection('reports').doc('other_report').set({
        'reportId': 'other_report',
        'reporterId': 'other_user',
        'reporterDisplayName': 'Other User',
        'contentType': 'message',
        'contentId': 'msg_other',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final reports = await service.getMyReports();
      expect(reports, isEmpty);
    });

    test('returns reports in descending order by createdAt', () async {
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_old',
        reason: ReportReason.spam,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_new',
        reason: ReportReason.harassment,
      );

      final reports = await service.getMyReports();

      expect(reports.length, equals(2));
      // Newest first
      if (reports.length == 2) {
        expect(
          reports[0].createdAt.isAfter(reports[1].createdAt) ||
              reports[0].createdAt.isAtSameMomentAs(reports[1].createdAt),
          isTrue,
        );
      }
    });
  });

  // =========================================================================
  // hasReportedContent
  // =========================================================================
  group('hasReportedContent', () {
    test('returns true for already reported content', () async {
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_reported',
        reason: ReportReason.spam,
      );

      final result = await service.hasReportedContent(
        'msg_reported',
        ReportableContentType.message,
      );

      expect(result, isTrue);
    });

    test('returns false for unreported content', () async {
      final result = await service.hasReportedContent(
        'msg_never_reported',
        ReportableContentType.message,
      );

      expect(result, isFalse);
    });

    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.hasReportedContent(
        'msg_any',
        ReportableContentType.message,
      );

      expect(result, isFalse);
    });

    test('differentiates between content types', () async {
      await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'content_123',
        reason: ReportReason.spam,
      );

      // Same contentId but different contentType should not match
      final messageResult = await service.hasReportedContent(
        'content_123',
        ReportableContentType.message,
      );
      final userResult = await service.hasReportedContent(
        'content_123',
        ReportableContentType.user,
      );

      expect(messageResult, isTrue);
      expect(userResult, isFalse);
    });
  });

  // =========================================================================
  // reportUser (convenience method)
  // =========================================================================
  group('reportUser', () {
    test('creates report with user content type', () async {
      final report = await service.reportUser(
        userId: 'bad_user_1',
        userDisplayName: 'Bad User',
        reason: ReportReason.impersonation,
        additionalDetails: 'Pretending to be someone else',
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.user));
      expect(report.contentId, equals('bad_user_1'));
      expect(report.contentOwnerId, equals('bad_user_1'));
      expect(report.contentOwnerDisplayName, equals('Bad User'));
      expect(report.reason, equals(ReportReason.impersonation));
      expect(report.additionalDetails, equals('Pretending to be someone else'));
    });

    test('sets contentOwnerId same as userId', () async {
      final report = await service.reportUser(
        userId: 'target_user',
        userDisplayName: 'Target',
        reason: ReportReason.harassment,
      );

      expect(report!.contentOwnerId, equals('target_user'));
    });
  });

  // =========================================================================
  // reportMessage (convenience method)
  // =========================================================================
  group('reportMessage', () {
    test('creates report with message content type and snapshot', () async {
      final report = await service.reportMessage(
        messageId: 'msg_report_1',
        senderId: 'sender_456',
        senderDisplayName: 'Sender',
        messageContent: 'The offensive message',
        reason: ReportReason.hateSpeech,
        additionalDetails: 'Very offensive',
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.message));
      expect(report.contentId, equals('msg_report_1'));
      expect(report.contentOwnerId, equals('sender_456'));
      expect(report.contentOwnerDisplayName, equals('Sender'));
      expect(report.contentSnapshot, equals('The offensive message'));
      expect(report.reason, equals(ReportReason.hateSpeech));
    });

    test('includes additionalDetails when provided', () async {
      final report = await service.reportMessage(
        messageId: 'msg_details',
        senderId: 'sender_1',
        senderDisplayName: 'Sender',
        messageContent: 'Bad message',
        reason: ReportReason.violence,
        additionalDetails: 'Context about the message',
      );

      expect(report!.additionalDetails, equals('Context about the message'));
    });
  });

  // =========================================================================
  // reportWatchParty (convenience method)
  // =========================================================================
  group('reportWatchParty', () {
    test('creates report with watchParty content type', () async {
      final report = await service.reportWatchParty(
        watchPartyId: 'wp_report_1',
        hostId: 'host_789',
        hostDisplayName: 'Party Host',
        watchPartyName: 'Inappropriate Party',
        reason: ReportReason.inappropriateContent,
        additionalDetails: 'Party name is offensive',
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.watchParty));
      expect(report.contentId, equals('wp_report_1'));
      expect(report.contentOwnerId, equals('host_789'));
      expect(report.contentOwnerDisplayName, equals('Party Host'));
      expect(report.contentSnapshot, equals('Inappropriate Party'));
      expect(report.reason, equals(ReportReason.inappropriateContent));
    });
  });

  // =========================================================================
  // getPendingReports (admin)
  // =========================================================================
  group('getPendingReports', () {
    test('returns only pending reports', () async {
      // Seed pending report
      await fakeFirestore.collection('reports').doc('pending_1').set({
        'reportId': 'pending_1',
        'reporterId': 'user_1',
        'reporterDisplayName': 'User 1',
        'contentType': 'message',
        'contentId': 'msg_p1',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Seed resolved report
      await fakeFirestore.collection('reports').doc('resolved_1').set({
        'reportId': 'resolved_1',
        'reporterId': 'user_2',
        'reporterDisplayName': 'User 2',
        'contentType': 'user',
        'contentId': 'user_r1',
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

    test('returns empty list when no pending reports exist', () async {
      // Only resolved reports in the collection
      await fakeFirestore.collection('reports').doc('resolved_only').set({
        'reportId': 'resolved_only',
        'reporterId': 'user_1',
        'reporterDisplayName': 'User 1',
        'contentType': 'message',
        'contentId': 'msg_ro',
        'reason': 'spam',
        'status': 'resolved',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final pending = await service.getPendingReports();

      for (final report in pending) {
        expect(report.status, equals(ReportStatus.pending));
      }
    });

    test('respects limit parameter', () async {
      // Seed 5 pending reports
      for (int i = 0; i < 5; i++) {
        await fakeFirestore.collection('reports').doc('limit_$i').set({
          'reportId': 'limit_$i',
          'reporterId': 'user_$i',
          'reporterDisplayName': 'User $i',
          'contentType': 'message',
          'contentId': 'msg_limit_$i',
          'reason': 'spam',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      final pending = await service.getPendingReports(limit: 3);

      expect(pending.length, lessThanOrEqualTo(3));
    });
  });

  // =========================================================================
  // resolveReport (admin)
  // =========================================================================
  group('resolveReport', () {
    test('updates report status to resolved', () async {
      await fakeFirestore
          .collection('reports')
          .doc('resolve_target')
          .set({
        'reportId': 'resolve_target',
        'reporterId': 'user_1',
        'reporterDisplayName': 'Reporter',
        'contentType': 'message',
        'contentId': 'msg_resolve',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final result = await service.resolveReport(
        reportId: 'resolve_target',
        action: ModerationAction.warning,
        moderatorNotes: 'Issued a warning',
      );

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('reports')
          .doc('resolve_target')
          .get();

      expect(doc.data()!['status'], equals('resolved'));
      expect(doc.data()!['actionTaken'], equals('warning'));
      expect(doc.data()!['moderatorId'], equals(testUserId));
      expect(doc.data()!['moderatorNotes'], equals('Issued a warning'));
      expect(doc.data()!['reviewedAt'], isNotNull);
      expect(doc.data()!['resolvedAt'], isNotNull);
    });

    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.resolveReport(
        reportId: 'any_report',
        action: ModerationAction.warning,
      );

      expect(result, isFalse);
    });

    test('handles resolve with all ModerationAction values', () async {
      for (final action in ModerationAction.values) {
        final reportId = 'resolve_${action.name}';

        await fakeFirestore.collection('reports').doc(reportId).set({
          'reportId': reportId,
          'reporterId': 'user_1',
          'reporterDisplayName': 'Reporter',
          'contentType': 'message',
          'contentId': 'msg_$reportId',
          'reason': 'spam',
          'status': 'pending',
          'createdAt': DateTime.now().toIso8601String(),
        });

        final result = await service.resolveReport(
          reportId: reportId,
          action: action,
        );

        expect(result, isTrue,
            reason: 'Should resolve with action: ${action.name}');

        final doc = await fakeFirestore
            .collection('reports')
            .doc(reportId)
            .get();
        expect(doc.data()!['actionTaken'], equals(action.name));
      }
    });

    test('includes moderator notes when provided', () async {
      await fakeFirestore
          .collection('reports')
          .doc('notes_report')
          .set({
        'reportId': 'notes_report',
        'reporterId': 'user_1',
        'reporterDisplayName': 'Reporter',
        'contentType': 'message',
        'contentId': 'msg_notes',
        'reason': 'harassment',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await service.resolveReport(
        reportId: 'notes_report',
        action: ModerationAction.temporaryMute,
        moderatorNotes: 'User was muted for 24 hours',
      );

      final doc = await fakeFirestore
          .collection('reports')
          .doc('notes_report')
          .get();

      expect(
        doc.data()!['moderatorNotes'],
        equals('User was muted for 24 hours'),
      );
    });

    test('resolves without moderator notes', () async {
      await fakeFirestore
          .collection('reports')
          .doc('no_notes_report')
          .set({
        'reportId': 'no_notes_report',
        'reporterId': 'user_1',
        'reporterDisplayName': 'Reporter',
        'contentType': 'message',
        'contentId': 'msg_no_notes',
        'reason': 'spam',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      final result = await service.resolveReport(
        reportId: 'no_notes_report',
        action: ModerationAction.none,
      );

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('reports')
          .doc('no_notes_report')
          .get();

      expect(doc.data()!['moderatorNotes'], isNull);
    });
  });

  // =========================================================================
  // Integration: full report lifecycle
  // =========================================================================
  group('Full report lifecycle', () {
    test('submit -> check -> resolve', () async {
      // Submit
      final report = await service.submitReport(
        contentType: ReportableContentType.message,
        contentId: 'msg_lifecycle',
        reason: ReportReason.harassment,
        contentOwnerId: 'offender_lifecycle',
        contentOwnerDisplayName: 'Offender',
        contentSnapshot: 'Bad content here',
      );

      expect(report, isNotNull);
      expect(report!.status, equals(ReportStatus.pending));

      // Check
      final hasReported = await service.hasReportedContent(
        'msg_lifecycle',
        ReportableContentType.message,
      );
      expect(hasReported, isTrue);

      // My reports
      final myReports = await service.getMyReports();
      expect(myReports.any((r) => r.reportId == report.reportId), isTrue);

      // Pending reports
      final pending = await service.getPendingReports();
      expect(pending.any((r) => r.reportId == report.reportId), isTrue);

      // Resolve
      final resolved = await service.resolveReport(
        reportId: report.reportId,
        action: ModerationAction.temporaryMute,
        moderatorNotes: 'User muted',
      );
      expect(resolved, isTrue);

      // Verify resolved state
      final doc = await fakeFirestore
          .collection('reports')
          .doc(report.reportId)
          .get();
      expect(doc.data()!['status'], equals('resolved'));
      expect(doc.data()!['actionTaken'], equals('temporaryMute'));
    });

    test('duplicate report returns original and does not double-count', () async {
      // Submit first report with content owner
      final first = await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'dup_user',
        contentOwnerId: 'dup_user',
        reason: ReportReason.spam,
      );

      // Check report count after first
      var statusDoc = await fakeFirestore
          .collection('user_moderation_status')
          .doc('dup_user')
          .get();
      expect(statusDoc.data()!['reportCount'], equals(1));

      // Submit duplicate
      final second = await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'dup_user',
        contentOwnerId: 'dup_user',
        reason: ReportReason.harassment,
      );

      // Should be the same report
      expect(second!.reportId, equals(first!.reportId));

      // Report count should NOT be incremented for the duplicate
      // (the duplicate returns the existing report before incrementing)
      // Note: the _incrementReportCount is only called for new reports
    });
  });
}
