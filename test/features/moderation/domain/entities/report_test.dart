import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';

void main() {
  // Helper to create a fully-populated Report for reuse
  Report createFullReport({
    String reportId = 'r1',
    String reporterId = 'u1',
    String reporterDisplayName = 'User One',
    ReportableContentType contentType = ReportableContentType.message,
    String contentId = 'msg_1',
    String? contentOwnerId = 'u2',
    String? contentOwnerDisplayName = 'User Two',
    ReportReason reason = ReportReason.harassment,
    String? additionalDetails = 'Details here',
    String? contentSnapshot = 'Snapshot text',
    ReportStatus status = ReportStatus.pending,
    ModerationAction? actionTaken,
    String? moderatorId,
    String? moderatorNotes,
    DateTime? createdAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
  }) {
    return Report(
      reportId: reportId,
      reporterId: reporterId,
      reporterDisplayName: reporterDisplayName,
      contentType: contentType,
      contentId: contentId,
      contentOwnerId: contentOwnerId,
      contentOwnerDisplayName: contentOwnerDisplayName,
      reason: reason,
      additionalDetails: additionalDetails,
      contentSnapshot: contentSnapshot,
      status: status,
      actionTaken: actionTaken,
      moderatorId: moderatorId,
      moderatorNotes: moderatorNotes,
      createdAt: createdAt ?? DateTime(2026, 6, 1, 12, 0),
      reviewedAt: reviewedAt,
      resolvedAt: resolvedAt,
    );
  }

  group('ReportableContentType', () {
    test('contains all expected values', () {
      expect(ReportableContentType.values, hasLength(6));
      expect(ReportableContentType.values, containsAll([
        ReportableContentType.user,
        ReportableContentType.message,
        ReportableContentType.watchParty,
        ReportableContentType.chatRoom,
        ReportableContentType.prediction,
        ReportableContentType.comment,
      ]));
    });
  });

  group('ReportReason', () {
    test('contains all expected values', () {
      expect(ReportReason.values, hasLength(10));
      expect(ReportReason.values, containsAll([
        ReportReason.spam,
        ReportReason.harassment,
        ReportReason.hateSpeech,
        ReportReason.violence,
        ReportReason.sexualContent,
        ReportReason.misinformation,
        ReportReason.impersonation,
        ReportReason.scam,
        ReportReason.inappropriateContent,
        ReportReason.other,
      ]));
    });
  });

  group('ReportStatus', () {
    test('contains all expected values', () {
      expect(ReportStatus.values, hasLength(5));
      expect(ReportStatus.values, containsAll([
        ReportStatus.pending,
        ReportStatus.underReview,
        ReportStatus.resolved,
        ReportStatus.dismissed,
        ReportStatus.escalated,
      ]));
    });
  });

  group('ModerationAction', () {
    test('contains all expected values', () {
      expect(ModerationAction.values, hasLength(6));
      expect(ModerationAction.values, containsAll([
        ModerationAction.none,
        ModerationAction.warning,
        ModerationAction.contentRemoved,
        ModerationAction.temporaryMute,
        ModerationAction.temporarySuspension,
        ModerationAction.permanentBan,
      ]));
    });
  });

  group('Report', () {
    group('Constructor', () {
      test('creates report with required fields only', () {
        final now = DateTime.now();
        final report = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.user,
          contentId: 'u2',
          reason: ReportReason.spam,
          createdAt: now,
        );

        expect(report.reportId, equals('r1'));
        expect(report.reporterId, equals('u1'));
        expect(report.reporterDisplayName, equals('User One'));
        expect(report.contentType, equals(ReportableContentType.user));
        expect(report.contentId, equals('u2'));
        expect(report.reason, equals(ReportReason.spam));
        expect(report.createdAt, equals(now));
        // Defaults
        expect(report.status, equals(ReportStatus.pending));
        // Nullable fields default to null
        expect(report.contentOwnerId, isNull);
        expect(report.contentOwnerDisplayName, isNull);
        expect(report.additionalDetails, isNull);
        expect(report.contentSnapshot, isNull);
        expect(report.actionTaken, isNull);
        expect(report.moderatorId, isNull);
        expect(report.moderatorNotes, isNull);
        expect(report.reviewedAt, isNull);
        expect(report.resolvedAt, isNull);
      });

      test('creates report with all fields', () {
        final report = createFullReport(
          status: ReportStatus.resolved,
          actionTaken: ModerationAction.temporaryMute,
          moderatorId: 'mod1',
          moderatorNotes: 'Muted for 24h',
          reviewedAt: DateTime(2026, 6, 1, 13, 0),
          resolvedAt: DateTime(2026, 6, 1, 14, 0),
        );

        expect(report.contentOwnerId, equals('u2'));
        expect(report.contentOwnerDisplayName, equals('User Two'));
        expect(report.additionalDetails, equals('Details here'));
        expect(report.contentSnapshot, equals('Snapshot text'));
        expect(report.status, equals(ReportStatus.resolved));
        expect(report.actionTaken, equals(ModerationAction.temporaryMute));
        expect(report.moderatorId, equals('mod1'));
        expect(report.moderatorNotes, equals('Muted for 24h'));
        expect(report.reviewedAt, equals(DateTime(2026, 6, 1, 13, 0)));
        expect(report.resolvedAt, equals(DateTime(2026, 6, 1, 14, 0)));
      });
    });

    group('copyWith', () {
      test('copies with no changes produces equal report', () {
        final original = createFullReport();
        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(copy.reportId, equals(original.reportId));
        expect(copy.contentType, equals(original.contentType));
      });

      test('copies with single field change', () {
        final original = createFullReport();
        final copy = original.copyWith(
          status: ReportStatus.resolved,
        );

        expect(copy.status, equals(ReportStatus.resolved));
        expect(copy.reportId, equals(original.reportId));
        expect(copy.reason, equals(original.reason));
      });

      test('copies with multiple field changes', () {
        final original = createFullReport();
        final resolvedAt = DateTime(2026, 6, 2);
        final copy = original.copyWith(
          status: ReportStatus.resolved,
          actionTaken: ModerationAction.warning,
          moderatorId: 'mod_99',
          moderatorNotes: 'Warned',
          resolvedAt: resolvedAt,
        );

        expect(copy.status, equals(ReportStatus.resolved));
        expect(copy.actionTaken, equals(ModerationAction.warning));
        expect(copy.moderatorId, equals('mod_99'));
        expect(copy.moderatorNotes, equals('Warned'));
        expect(copy.resolvedAt, equals(resolvedAt));
        // Unchanged fields
        expect(copy.reportId, equals(original.reportId));
        expect(copy.reporterId, equals(original.reporterId));
        expect(copy.contentType, equals(original.contentType));
      });

      test('can update all fields via copyWith', () {
        final original = createFullReport();
        final newDate = DateTime(2026, 7, 1);
        final copy = original.copyWith(
          reportId: 'new_r',
          reporterId: 'new_u',
          reporterDisplayName: 'New User',
          contentType: ReportableContentType.chatRoom,
          contentId: 'new_content',
          contentOwnerId: 'new_owner',
          contentOwnerDisplayName: 'New Owner',
          reason: ReportReason.scam,
          additionalDetails: 'New details',
          contentSnapshot: 'New snapshot',
          status: ReportStatus.escalated,
          actionTaken: ModerationAction.permanentBan,
          moderatorId: 'new_mod',
          moderatorNotes: 'New notes',
          createdAt: newDate,
          reviewedAt: newDate,
          resolvedAt: newDate,
        );

        expect(copy.reportId, equals('new_r'));
        expect(copy.reporterId, equals('new_u'));
        expect(copy.contentType, equals(ReportableContentType.chatRoom));
        expect(copy.reason, equals(ReportReason.scam));
        expect(copy.status, equals(ReportStatus.escalated));
        expect(copy.actionTaken, equals(ModerationAction.permanentBan));
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final report = createFullReport(
          status: ReportStatus.resolved,
          actionTaken: ModerationAction.temporaryMute,
          moderatorId: 'mod1',
          moderatorNotes: 'Some notes',
          reviewedAt: DateTime(2026, 6, 1, 13, 0),
          resolvedAt: DateTime(2026, 6, 1, 14, 0),
        );

        final json = report.toJson();

        expect(json['reportId'], equals('r1'));
        expect(json['reporterId'], equals('u1'));
        expect(json['reporterDisplayName'], equals('User One'));
        expect(json['contentType'], equals('message'));
        expect(json['contentId'], equals('msg_1'));
        expect(json['contentOwnerId'], equals('u2'));
        expect(json['contentOwnerDisplayName'], equals('User Two'));
        expect(json['reason'], equals('harassment'));
        expect(json['additionalDetails'], equals('Details here'));
        expect(json['contentSnapshot'], equals('Snapshot text'));
        expect(json['status'], equals('resolved'));
        expect(json['actionTaken'], equals('temporaryMute'));
        expect(json['moderatorId'], equals('mod1'));
        expect(json['moderatorNotes'], equals('Some notes'));
        expect(json['createdAt'], isA<String>());
        expect(json['reviewedAt'], isA<String>());
        expect(json['resolvedAt'], isA<String>());
      });

      test('serializes null optional fields as null', () {
        final report = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User',
          contentType: ReportableContentType.user,
          contentId: 'u2',
          reason: ReportReason.spam,
          createdAt: DateTime(2026, 6, 1),
        );

        final json = report.toJson();

        expect(json['contentOwnerId'], isNull);
        expect(json['contentOwnerDisplayName'], isNull);
        expect(json['additionalDetails'], isNull);
        expect(json['contentSnapshot'], isNull);
        expect(json['actionTaken'], isNull);
        expect(json['moderatorId'], isNull);
        expect(json['moderatorNotes'], isNull);
        expect(json['reviewedAt'], isNull);
        expect(json['resolvedAt'], isNull);
      });

      test('serializes contentType enum as name string', () {
        for (final type in ReportableContentType.values) {
          final report = Report(
            reportId: 'r1',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: type,
            contentId: 'c1',
            reason: ReportReason.spam,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(report.toJson()['contentType'], equals(type.name));
        }
      });

      test('serializes reason enum as name string', () {
        for (final reason in ReportReason.values) {
          final report = Report(
            reportId: 'r1',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: reason,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(report.toJson()['reason'], equals(reason.name));
        }
      });

      test('serializes status enum as name string', () {
        for (final status in ReportStatus.values) {
          final report = Report(
            reportId: 'r1',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: ReportReason.spam,
            status: status,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(report.toJson()['status'], equals(status.name));
        }
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User One',
          'contentType': 'message',
          'contentId': 'msg_1',
          'contentOwnerId': 'u2',
          'contentOwnerDisplayName': 'User Two',
          'reason': 'harassment',
          'additionalDetails': 'Some details',
          'contentSnapshot': 'Bad message text',
          'status': 'resolved',
          'actionTaken': 'warning',
          'moderatorId': 'mod1',
          'moderatorNotes': 'Issued warning',
          'createdAt': '2026-06-01T12:00:00.000',
          'reviewedAt': '2026-06-01T13:00:00.000',
          'resolvedAt': '2026-06-01T14:00:00.000',
        };

        final report = Report.fromJson(json);

        expect(report.reportId, equals('r1'));
        expect(report.reporterId, equals('u1'));
        expect(report.reporterDisplayName, equals('User One'));
        expect(report.contentType, equals(ReportableContentType.message));
        expect(report.contentId, equals('msg_1'));
        expect(report.contentOwnerId, equals('u2'));
        expect(report.contentOwnerDisplayName, equals('User Two'));
        expect(report.reason, equals(ReportReason.harassment));
        expect(report.additionalDetails, equals('Some details'));
        expect(report.contentSnapshot, equals('Bad message text'));
        expect(report.status, equals(ReportStatus.resolved));
        expect(report.actionTaken, equals(ModerationAction.warning));
        expect(report.moderatorId, equals('mod1'));
        expect(report.moderatorNotes, equals('Issued warning'));
        expect(report.createdAt, equals(DateTime(2026, 6, 1, 12, 0)));
        expect(report.reviewedAt, equals(DateTime(2026, 6, 1, 13, 0)));
        expect(report.resolvedAt, equals(DateTime(2026, 6, 1, 14, 0)));
      });

      test('handles null optional fields', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User',
          'contentType': 'user',
          'contentId': 'u2',
          'reason': 'spam',
          'status': 'pending',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final report = Report.fromJson(json);

        expect(report.contentOwnerId, isNull);
        expect(report.contentOwnerDisplayName, isNull);
        expect(report.additionalDetails, isNull);
        expect(report.contentSnapshot, isNull);
        expect(report.actionTaken, isNull);
        expect(report.moderatorId, isNull);
        expect(report.moderatorNotes, isNull);
        expect(report.reviewedAt, isNull);
        expect(report.resolvedAt, isNull);
      });

      test('defaults to user content type for unknown contentType', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User',
          'contentType': 'unknown_type',
          'contentId': 'c1',
          'reason': 'spam',
          'status': 'pending',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final report = Report.fromJson(json);
        expect(report.contentType, equals(ReportableContentType.user));
      });

      test('defaults to other reason for unknown reason', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User',
          'contentType': 'user',
          'contentId': 'c1',
          'reason': 'unknown_reason',
          'status': 'pending',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final report = Report.fromJson(json);
        expect(report.reason, equals(ReportReason.other));
      });

      test('defaults to pending status for unknown status', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User',
          'contentType': 'user',
          'contentId': 'c1',
          'reason': 'spam',
          'status': 'unknown_status',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final report = Report.fromJson(json);
        expect(report.status, equals(ReportStatus.pending));
      });

      test('defaults to none for unknown actionTaken', () {
        final json = {
          'reportId': 'r1',
          'reporterId': 'u1',
          'reporterDisplayName': 'User',
          'contentType': 'user',
          'contentId': 'c1',
          'reason': 'spam',
          'status': 'pending',
          'actionTaken': 'unknown_action',
          'createdAt': '2026-06-01T12:00:00.000',
        };

        final report = Report.fromJson(json);
        expect(report.actionTaken, equals(ModerationAction.none));
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('preserves all fields through serialization roundtrip', () {
        final original = createFullReport(
          contentType: ReportableContentType.watchParty,
          reason: ReportReason.hateSpeech,
          status: ReportStatus.resolved,
          actionTaken: ModerationAction.temporaryMute,
          moderatorId: 'mod1',
          moderatorNotes: 'Muted for 24h',
          reviewedAt: DateTime(2026, 6, 1, 13, 0),
          resolvedAt: DateTime(2026, 6, 1, 14, 0),
        );

        final json = original.toJson();
        final restored = Report.fromJson(json);

        expect(restored.reportId, equals(original.reportId));
        expect(restored.reporterId, equals(original.reporterId));
        expect(restored.reporterDisplayName, equals(original.reporterDisplayName));
        expect(restored.contentType, equals(original.contentType));
        expect(restored.contentId, equals(original.contentId));
        expect(restored.contentOwnerId, equals(original.contentOwnerId));
        expect(restored.contentOwnerDisplayName, equals(original.contentOwnerDisplayName));
        expect(restored.reason, equals(original.reason));
        expect(restored.additionalDetails, equals(original.additionalDetails));
        expect(restored.contentSnapshot, equals(original.contentSnapshot));
        expect(restored.status, equals(original.status));
        expect(restored.actionTaken, equals(original.actionTaken));
        expect(restored.moderatorId, equals(original.moderatorId));
        expect(restored.moderatorNotes, equals(original.moderatorNotes));
        expect(restored.createdAt, equals(original.createdAt));
        expect(restored.reviewedAt, equals(original.reviewedAt));
        expect(restored.resolvedAt, equals(original.resolvedAt));
      });

      test('roundtrip with minimal fields', () {
        final original = Report(
          reportId: 'r_min',
          reporterId: 'u1',
          reporterDisplayName: 'User',
          contentType: ReportableContentType.comment,
          contentId: 'c1',
          reason: ReportReason.other,
          createdAt: DateTime(2026, 6, 1),
        );

        final restored = Report.fromJson(original.toJson());

        expect(restored.reportId, equals(original.reportId));
        expect(restored.contentType, equals(original.contentType));
        expect(restored.reason, equals(original.reason));
        expect(restored.status, equals(original.status));
        expect(restored.actionTaken, isNull);
      });

      test('roundtrip for every content type', () {
        for (final type in ReportableContentType.values) {
          final original = Report(
            reportId: 'r_${type.name}',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: type,
            contentId: 'c1',
            reason: ReportReason.spam,
            createdAt: DateTime(2026, 6, 1),
          );
          final restored = Report.fromJson(original.toJson());
          expect(restored.contentType, equals(type));
        }
      });

      test('roundtrip for every report reason', () {
        for (final reason in ReportReason.values) {
          final original = Report(
            reportId: 'r_${reason.name}',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: reason,
            createdAt: DateTime(2026, 6, 1),
          );
          final restored = Report.fromJson(original.toJson());
          expect(restored.reason, equals(reason));
        }
      });

      test('roundtrip for every report status', () {
        for (final status in ReportStatus.values) {
          final original = Report(
            reportId: 'r_${status.name}',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: ReportReason.spam,
            status: status,
            createdAt: DateTime(2026, 6, 1),
          );
          final restored = Report.fromJson(original.toJson());
          expect(restored.status, equals(status));
        }
      });

      test('roundtrip for every moderation action', () {
        for (final action in ModerationAction.values) {
          final original = Report(
            reportId: 'r_${action.name}',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: ReportReason.spam,
            actionTaken: action,
            createdAt: DateTime(2026, 6, 1),
          );
          final restored = Report.fromJson(original.toJson());
          expect(restored.actionTaken, equals(action));
        }
      });
    });

    group('reasonDisplayText', () {
      test('returns correct text for each reason', () {
        final expectedTexts = {
          ReportReason.spam: 'Spam',
          ReportReason.harassment: 'Harassment or Bullying',
          ReportReason.hateSpeech: 'Hate Speech',
          ReportReason.violence: 'Violence or Threats',
          ReportReason.sexualContent: 'Sexual Content',
          ReportReason.misinformation: 'Misinformation',
          ReportReason.impersonation: 'Impersonation',
          ReportReason.scam: 'Scam or Fraud',
          ReportReason.inappropriateContent: 'Inappropriate Content',
          ReportReason.other: 'Other',
        };

        for (final entry in expectedTexts.entries) {
          final report = Report(
            reportId: 'r1',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: ReportableContentType.user,
            contentId: 'c1',
            reason: entry.key,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(report.reasonDisplayText, equals(entry.value),
              reason: 'Failed for ${entry.key}');
        }
      });
    });

    group('contentTypeDisplayText', () {
      test('returns correct text for each content type', () {
        final expectedTexts = {
          ReportableContentType.user: 'User',
          ReportableContentType.message: 'Message',
          ReportableContentType.watchParty: 'Watch Party',
          ReportableContentType.chatRoom: 'Chat Room',
          ReportableContentType.prediction: 'Prediction',
          ReportableContentType.comment: 'Comment',
        };

        for (final entry in expectedTexts.entries) {
          final report = Report(
            reportId: 'r1',
            reporterId: 'u1',
            reporterDisplayName: 'User',
            contentType: entry.key,
            contentId: 'c1',
            reason: ReportReason.spam,
            createdAt: DateTime(2026, 6, 1),
          );
          expect(report.contentTypeDisplayText, equals(entry.value),
              reason: 'Failed for ${entry.key}');
        }
      });
    });

    group('Equatable', () {
      test('two reports with same props are equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final report1 = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          createdAt: createdAt,
        );

        final report2 = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          createdAt: createdAt,
        );

        expect(report1, equals(report2));
        expect(report1.hashCode, equals(report2.hashCode));
      });

      test('two reports with different reportId are not equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final report1 = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          createdAt: createdAt,
        );

        final report2 = Report(
          reportId: 'r2',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          createdAt: createdAt,
        );

        expect(report1, isNot(equals(report2)));
      });

      test('two reports with different status are not equal', () {
        final createdAt = DateTime(2026, 6, 1, 12, 0);
        final report1 = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          status: ReportStatus.pending,
          createdAt: createdAt,
        );

        final report2 = Report(
          reportId: 'r1',
          reporterId: 'u1',
          reporterDisplayName: 'User One',
          contentType: ReportableContentType.message,
          contentId: 'msg_1',
          reason: ReportReason.harassment,
          status: ReportStatus.resolved,
          createdAt: createdAt,
        );

        expect(report1, isNot(equals(report2)));
      });

      test('props list includes all fields', () {
        final report = createFullReport(
          actionTaken: ModerationAction.warning,
          moderatorId: 'mod1',
          moderatorNotes: 'Notes',
          reviewedAt: DateTime(2026, 6, 1, 13, 0),
          resolvedAt: DateTime(2026, 6, 1, 14, 0),
        );

        // Equatable props should have 17 entries (all fields)
        expect(report.props, hasLength(17));
      });
    });
  });
}
