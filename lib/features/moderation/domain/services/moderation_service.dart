import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../entities/report.dart';
import '../entities/user_sanction.dart';
import 'profanity_filter_service.dart';
import 'moderation_report_service.dart';
import 'moderation_action_service.dart';
import 'moderation_content_filter_service.dart';

// Re-export sub-service types so callers can continue to import from this file
export 'moderation_content_filter_service.dart' show MessageValidationResult, WatchPartyValidationResult;

/// Facade service for content moderation, reports, and user sanctions.
///
/// Delegates to focused sub-services:
/// - [ModerationReportService]: Report submission, querying, resolution
/// - [ModerationActionService]: User sanctions (warn, mute, suspend, ban) and status
/// - [ModerationContentFilterService]: Profanity filtering, message/watch party validation
class ModerationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static ModerationService? _instance;

  ModerationService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ProfanityFilterService? profanityFilter,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _profanityFilter = profanityFilter ?? ProfanityFilterService();

  factory ModerationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ProfanityFilterService? profanityFilter,
  }) {
    _instance ??= ModerationService._(
      firestore: firestore,
      auth: auth,
      profanityFilter: profanityFilter,
    );
    return _instance!;
  }

  final ProfanityFilterService _profanityFilter;

  // Sub-services (lazily initialized)
  late final ModerationReportService _reports = ModerationReportService(
    firestore: _firestore,
    auth: _auth,
  );

  late final ModerationActionService _actions = ModerationActionService(
    firestore: _firestore,
    auth: _auth,
  );

  late final ModerationContentFilterService _contentFilter = ModerationContentFilterService(
    profanityFilter: _profanityFilter,
    actionService: _actions,
  );

  // ==================== Reporting (delegated) ====================

  Future<Report?> submitReport({
    required ReportableContentType contentType,
    required String contentId,
    required ReportReason reason,
    String? contentOwnerId,
    String? contentOwnerDisplayName,
    String? additionalDetails,
    String? contentSnapshot,
  }) =>
      _reports.submitReport(
        contentType: contentType,
        contentId: contentId,
        reason: reason,
        contentOwnerId: contentOwnerId,
        contentOwnerDisplayName: contentOwnerDisplayName,
        additionalDetails: additionalDetails,
        contentSnapshot: contentSnapshot,
      );

  Future<List<Report>> getMyReports() =>
      _reports.getMyReports();

  Future<bool> hasReportedContent(
          String contentId, ReportableContentType contentType) =>
      _reports.hasReportedContent(contentId, contentType);

  Future<Report?> reportUser({
    required String userId,
    required String userDisplayName,
    required ReportReason reason,
    String? additionalDetails,
  }) =>
      _reports.reportUser(
        userId: userId,
        userDisplayName: userDisplayName,
        reason: reason,
        additionalDetails: additionalDetails,
      );

  Future<Report?> reportMessage({
    required String messageId,
    required String senderId,
    required String senderDisplayName,
    required String messageContent,
    required ReportReason reason,
    String? additionalDetails,
  }) =>
      _reports.reportMessage(
        messageId: messageId,
        senderId: senderId,
        senderDisplayName: senderDisplayName,
        messageContent: messageContent,
        reason: reason,
        additionalDetails: additionalDetails,
      );

  Future<Report?> reportWatchParty({
    required String watchPartyId,
    required String hostId,
    required String hostDisplayName,
    required String watchPartyName,
    required ReportReason reason,
    String? additionalDetails,
  }) =>
      _reports.reportWatchParty(
        watchPartyId: watchPartyId,
        hostId: hostId,
        hostDisplayName: hostDisplayName,
        watchPartyName: watchPartyName,
        reason: reason,
        additionalDetails: additionalDetails,
      );

  Future<List<Report>> getPendingReports({int limit = 50}) =>
      _reports.getPendingReports(limit: limit);

  Future<bool> resolveReport({
    required String reportId,
    required ModerationAction action,
    String? moderatorNotes,
  }) =>
      _reports.resolveReport(
        reportId: reportId,
        action: action,
        moderatorNotes: moderatorNotes,
      );

  // ==================== User Status & Sanctions (delegated) ====================

  Future<UserModerationStatus> getUserModerationStatus(String userId) =>
      _actions.getUserModerationStatus(userId);

  Future<bool> isCurrentUserMuted() =>
      _actions.isCurrentUserMuted();

  Future<bool> isCurrentUserSuspended() =>
      _actions.isCurrentUserSuspended();

  Future<bool> isCurrentUserBanned() =>
      _actions.isCurrentUserBanned();

  Future<String?> getCurrentUserRestriction() =>
      _actions.getCurrentUserRestriction();

  Future<UserSanction?> issueWarning({
    required String userId,
    required String reason,
    String? relatedReportId,
  }) =>
      _actions.issueWarning(
        userId: userId,
        reason: reason,
        relatedReportId: relatedReportId,
      );

  Future<UserSanction?> muteUser({
    required String userId,
    required String reason,
    required Duration duration,
    String? relatedReportId,
  }) =>
      _actions.muteUser(
        userId: userId,
        reason: reason,
        duration: duration,
        relatedReportId: relatedReportId,
      );

  Future<UserSanction?> suspendUser({
    required String userId,
    required String reason,
    required Duration duration,
    String? relatedReportId,
  }) =>
      _actions.suspendUser(
        userId: userId,
        reason: reason,
        duration: duration,
        relatedReportId: relatedReportId,
      );

  Future<UserSanction?> banUser({
    required String userId,
    required String reason,
    String? relatedReportId,
  }) =>
      _actions.banUser(
        userId: userId,
        reason: reason,
        relatedReportId: relatedReportId,
      );

  Future<List<UserSanction>> getUserSanctions(String userId) =>
      _actions.getUserSanctions(userId);

  // ==================== Content Filtering (delegated) ====================

  ContentFilterResult filterContent(String text) =>
      _contentFilter.filterContent(text);

  bool isContentAppropriate(String text) =>
      _contentFilter.isContentAppropriate(text);

  String getCensoredContent(String text) =>
      _contentFilter.getCensoredContent(text);

  Future<MessageValidationResult> validateMessage(String message) =>
      _contentFilter.validateMessage(message);

  Future<WatchPartyValidationResult> validateWatchParty({
    required String name,
    required String description,
  }) =>
      _contentFilter.validateWatchParty(name: name, description: description);
}

extension UserModerationStatusCopyWith on UserModerationStatus {
  UserModerationStatus copyWith({
    String? usualId,
    int? warningCount,
    int? reportCount,
    bool? isMuted,
    DateTime? mutedUntil,
    bool? isSuspended,
    DateTime? suspendedUntil,
    bool? isBanned,
    String? banReason,
    List<UserSanction>? activeSanctions,
    DateTime? lastWarningAt,
  }) {
    return UserModerationStatus(
      usualId: usualId ?? this.usualId,
      warningCount: warningCount ?? this.warningCount,
      reportCount: reportCount ?? this.reportCount,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      isSuspended: isSuspended ?? this.isSuspended,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      activeSanctions: activeSanctions ?? this.activeSanctions,
      lastWarningAt: lastWarningAt ?? this.lastWarningAt,
    );
  }
}
