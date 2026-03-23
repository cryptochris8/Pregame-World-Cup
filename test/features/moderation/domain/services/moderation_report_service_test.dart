import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_report_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ModerationReportService service;

  const testUserId = 'reporter_123';
  const testUserName = 'Reporter User';

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

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
    test('creates report with all fields in reports collection', () async {
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

    test('stores report document in Firestore', () async {
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

    test('does NOT increment report count client-side (server-side only)',
        () async {
      // Submit a report with a content owner
      await service.submitReport(
        contentType: ReportableContentType.user,
        contentId: 'counted_user',
        contentOwnerId: 'counted_user',
        reason: ReportReason.harassment,
      );

      // Verify NO user_moderation_status document was created or updated.
      // The _incrementReportCount method was removed; report count tracking
      // is now handled server-side by the onReportCreated Cloud Function.
      final moderationDocs =
          await fakeFirestore.collection('user_moderation_status').get();
      expect(moderationDocs.docs, isEmpty);
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

    test('uses reporter display name from users collection', () async {
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
  // Convenience methods
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
    });
  });

  group('reportMessage', () {
    test('creates report with message content type and snapshot', () async {
      final report = await service.reportMessage(
        messageId: 'msg_report_1',
        senderId: 'sender_456',
        senderDisplayName: 'Sender',
        messageContent: 'The offensive message',
        reason: ReportReason.hateSpeech,
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.message));
      expect(report.contentSnapshot, equals('The offensive message'));
    });
  });

  group('reportWatchParty', () {
    test('creates report with watchParty content type', () async {
      final report = await service.reportWatchParty(
        watchPartyId: 'wp_report_1',
        hostId: 'host_789',
        hostDisplayName: 'Party Host',
        watchPartyName: 'Inappropriate Party',
        reason: ReportReason.inappropriateContent,
      );

      expect(report, isNotNull);
      expect(report!.contentType, equals(ReportableContentType.watchParty));
      expect(report.contentSnapshot, equals('Inappropriate Party'));
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
    });

    test('returns false when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.resolveReport(
        reportId: 'any_report',
        action: ModerationAction.warning,
      );

      expect(result, isFalse);
    });
  });

  // =========================================================================
  // Full lifecycle
  // =========================================================================
  group('Full report lifecycle', () {
    test('submit -> check -> resolve without client-side count increment',
        () async {
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

      // Verify report is in the reports collection
      final reportsSnapshot =
          await fakeFirestore.collection('reports').get();
      expect(reportsSnapshot.docs.isNotEmpty, isTrue);

      // Verify NO client-side moderation status was created
      final moderationDocs =
          await fakeFirestore.collection('user_moderation_status').get();
      expect(moderationDocs.docs, isEmpty);

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
  });
}
