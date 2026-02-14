import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../entities/report.dart';
import '../entities/user_sanction.dart';
import 'profanity_filter_service.dart';

/// Service for handling content moderation, reports, and user sanctions
class ModerationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ProfanityFilterService _profanityFilter;
  final Uuid _uuid = const Uuid();

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

  /// Collection references
  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _sanctionsCollection =>
      _firestore.collection('user_sanctions');

  CollectionReference<Map<String, dynamic>> get _moderationStatusCollection =>
      _firestore.collection('user_moderation_status');

  String? get _currentUserId => _auth.currentUser?.uid;

  // ==================== REPORTING ====================

  /// Submit a report for content or user
  Future<Report?> submitReport({
    required ReportableContentType contentType,
    required String contentId,
    required ReportReason reason,
    String? contentOwnerId,
    String? contentOwnerDisplayName,
    String? additionalDetails,
    String? contentSnapshot,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('Cannot submit report: user not logged in',
          name: 'ModerationService');
      return null;
    }

    try {
      // Get reporter's display name
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final reporterName =
          userDoc.data()?['displayName'] as String? ?? 'Unknown User';

      // Check if user already reported this content
      final existingReport = await _reportsCollection
          .where('reporterId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .where('contentType', isEqualTo: contentType.name)
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        developer.log('User already reported this content',
            name: 'ModerationService');
        return Report.fromJson(existingReport.docs.first.data());
      }

      final reportId = _uuid.v4();
      final report = Report(
        reportId: reportId,
        reporterId: userId,
        reporterDisplayName: reporterName,
        contentType: contentType,
        contentId: contentId,
        contentOwnerId: contentOwnerId,
        contentOwnerDisplayName: contentOwnerDisplayName,
        reason: reason,
        additionalDetails: additionalDetails,
        contentSnapshot: contentSnapshot,
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
      );

      await _reportsCollection.doc(reportId).set(report.toJson());

      // Update report count for content owner
      if (contentOwnerId != null) {
        await _incrementReportCount(contentOwnerId);
      }

      developer.log('Report submitted: $reportId', name: 'ModerationService');
      return report;
    } catch (e) {
      developer.log('Error submitting report: $e', name: 'ModerationService');
      return null;
    }
  }

  /// Get reports submitted by current user
  Future<List<Report>> getMyReports() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _reportsCollection
          .where('reporterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Report.fromJson(doc.data())).toList();
    } catch (e) {
      developer.log('Error getting reports: $e', name: 'ModerationService');
      return [];
    }
  }

  /// Check if current user has reported a specific content
  Future<bool> hasReportedContent(
      String contentId, ReportableContentType contentType) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final snapshot = await _reportsCollection
          .where('reporterId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .where('contentType', isEqualTo: contentType.name)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      developer.log('Error checking report status: $e',
          name: 'ModerationService');
      return false;
    }
  }

  // ==================== USER MODERATION STATUS ====================

  /// Get moderation status for a user
  Future<UserModerationStatus> getUserModerationStatus(String userId) async {
    try {
      final doc = await _moderationStatusCollection.doc(userId).get();

      if (!doc.exists) {
        return UserModerationStatus.empty(userId);
      }

      final status = UserModerationStatus.fromJson(doc.data()!);

      // Check if any time-based sanctions have expired
      if (status.isMuted &&
          status.mutedUntil != null &&
          DateTime.now().isAfter(status.mutedUntil!)) {
        await _clearExpiredMute(userId);
        return status.copyWith(isMuted: false, mutedUntil: null);
      }

      if (status.isSuspended &&
          status.suspendedUntil != null &&
          DateTime.now().isAfter(status.suspendedUntil!)) {
        await _clearExpiredSuspension(userId);
        return status.copyWith(isSuspended: false, suspendedUntil: null);
      }

      return status;
    } catch (e) {
      developer.log('Error getting moderation status: $e',
          name: 'ModerationService');
      return UserModerationStatus.empty(userId);
    }
  }

  /// Check if current user is muted
  Future<bool> isCurrentUserMuted() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final status = await getUserModerationStatus(userId);
    return status.isMuted && !_hasExpired(status.mutedUntil);
  }

  /// Check if current user is suspended
  Future<bool> isCurrentUserSuspended() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final status = await getUserModerationStatus(userId);
    return status.isSuspended && !_hasExpired(status.suspendedUntil);
  }

  /// Check if current user is banned
  Future<bool> isCurrentUserBanned() async {
    final userId = _currentUserId;
    if (userId == null) return false;

    final status = await getUserModerationStatus(userId);
    return status.isBanned;
  }

  /// Get active restriction message for current user
  Future<String?> getCurrentUserRestriction() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final status = await getUserModerationStatus(userId);
    return status.activeRestrictionText;
  }

  bool _hasExpired(DateTime? expiresAt) {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  Future<void> _clearExpiredMute(String userId) async {
    await _moderationStatusCollection.doc(userId).update({
      'isMuted': false,
      'mutedUntil': null,
    });
  }

  Future<void> _clearExpiredSuspension(String userId) async {
    await _moderationStatusCollection.doc(userId).update({
      'isSuspended': false,
      'suspendedUntil': null,
    });
  }

  Future<void> _incrementReportCount(String userId) async {
    await _moderationStatusCollection.doc(userId).set({
      'usualId': userId,
      'reportCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // ==================== CONTENT FILTERING ====================

  /// Filter content before posting
  ContentFilterResult filterContent(String text) {
    return _profanityFilter.filterContent(text);
  }

  /// Check if content is appropriate
  bool isContentAppropriate(String text) {
    return _profanityFilter.isClean(text);
  }

  /// Get censored version of content
  String getCensoredContent(String text) {
    return _profanityFilter.getCensoredText(text);
  }

  /// Validate and filter message before sending
  Future<MessageValidationResult> validateMessage(String message) async {
    // Check profanity
    final filterResult = _profanityFilter.filterContent(message);

    // Check if user is muted
    final isMuted = await isCurrentUserMuted();
    if (isMuted) {
      return const MessageValidationResult(
        isValid: false,
        errorMessage: 'You are currently muted and cannot send messages',
        filteredMessage: null,
      );
    }

    // Auto-reject severely inappropriate content
    if (filterResult.shouldAutoReject) {
      return const MessageValidationResult(
        isValid: false,
        errorMessage: 'This message contains inappropriate content',
        filteredMessage: null,
      );
    }

    // Return filtered message if it contains mild profanity
    if (filterResult.containsProfanity) {
      return MessageValidationResult(
        isValid: true,
        errorMessage: null,
        filteredMessage: filterResult.filteredText,
        wasFiltered: true,
      );
    }

    return MessageValidationResult(
      isValid: true,
      errorMessage: null,
      filteredMessage: message,
      wasFiltered: false,
    );
  }

  /// Validate watch party content
  Future<WatchPartyValidationResult> validateWatchParty({
    required String name,
    required String description,
  }) async {
    // Check if user is suspended
    final isSuspended = await isCurrentUserSuspended();
    if (isSuspended) {
      return const WatchPartyValidationResult(
        isValid: false,
        errorMessage:
            'You are currently suspended and cannot create watch parties',
      );
    }

    final filterResult = _profanityFilter.validateWatchPartyContent(
      name: name,
      description: description,
    );

    if (filterResult.shouldAutoReject) {
      return const WatchPartyValidationResult(
        isValid: false,
        errorMessage: 'Watch party content contains inappropriate language',
      );
    }

    if (filterResult.containsProfanity) {
      final parts = filterResult.filteredText.split('\n');
      return WatchPartyValidationResult(
        isValid: true,
        filteredName: parts[0],
        filteredDescription: parts.length > 1 ? parts[1] : '',
        wasFiltered: true,
      );
    }

    return WatchPartyValidationResult(
      isValid: true,
      filteredName: name,
      filteredDescription: description,
      wasFiltered: false,
    );
  }

  // ==================== USER ACTIONS ====================

  /// Report a user
  Future<Report?> reportUser({
    required String userId,
    required String userDisplayName,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    return submitReport(
      contentType: ReportableContentType.user,
      contentId: userId,
      contentOwnerId: userId,
      contentOwnerDisplayName: userDisplayName,
      reason: reason,
      additionalDetails: additionalDetails,
    );
  }

  /// Report a message
  Future<Report?> reportMessage({
    required String messageId,
    required String senderId,
    required String senderDisplayName,
    required String messageContent,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    return submitReport(
      contentType: ReportableContentType.message,
      contentId: messageId,
      contentOwnerId: senderId,
      contentOwnerDisplayName: senderDisplayName,
      reason: reason,
      additionalDetails: additionalDetails,
      contentSnapshot: messageContent,
    );
  }

  /// Report a watch party
  Future<Report?> reportWatchParty({
    required String watchPartyId,
    required String hostId,
    required String hostDisplayName,
    required String watchPartyName,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    return submitReport(
      contentType: ReportableContentType.watchParty,
      contentId: watchPartyId,
      contentOwnerId: hostId,
      contentOwnerDisplayName: hostDisplayName,
      reason: reason,
      additionalDetails: additionalDetails,
      contentSnapshot: watchPartyName,
    );
  }

  // ==================== ADMIN FUNCTIONS (for future admin panel) ====================

  /// Get pending reports (admin only)
  Future<List<Report>> getPendingReports({int limit = 50}) async {
    try {
      final snapshot = await _reportsCollection
          .where('status', isEqualTo: ReportStatus.pending.name)
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Report.fromJson(doc.data())).toList();
    } catch (e) {
      developer.log('Error getting pending reports: $e',
          name: 'ModerationService');
      return [];
    }
  }

  /// Resolve a report (admin only)
  Future<bool> resolveReport({
    required String reportId,
    required ModerationAction action,
    String? moderatorNotes,
  }) async {
    final moderatorId = _currentUserId;
    if (moderatorId == null) return false;

    try {
      await _reportsCollection.doc(reportId).update({
        'status': ReportStatus.resolved.name,
        'actionTaken': action.name,
        'moderatorId': moderatorId,
        'moderatorNotes': moderatorNotes,
        'reviewedAt': DateTime.now().toIso8601String(),
        'resolvedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      developer.log('Error resolving report: $e', name: 'ModerationService');
      return false;
    }
  }

  /// Issue a warning to a user (admin only)
  Future<UserSanction?> issueWarning({
    required String userId,
    required String reason,
    String? relatedReportId,
  }) async {
    return _createSanction(
      userId: userId,
      type: SanctionType.warning,
      action: ModerationAction.warning,
      reason: reason,
      relatedReportId: relatedReportId,
    );
  }

  /// Mute a user (admin only)
  Future<UserSanction?> muteUser({
    required String userId,
    required String reason,
    required Duration duration,
    String? relatedReportId,
  }) async {
    final sanction = await _createSanction(
      userId: userId,
      type: SanctionType.mute,
      action: ModerationAction.temporaryMute,
      reason: reason,
      expiresAt: DateTime.now().add(duration),
      relatedReportId: relatedReportId,
    );

    if (sanction != null) {
      await _moderationStatusCollection.doc(userId).set({
        'usualId': userId,
        'isMuted': true,
        'mutedUntil': sanction.expiresAt?.toIso8601String(),
      }, SetOptions(merge: true));
    }

    return sanction;
  }

  /// Suspend a user (admin only)
  Future<UserSanction?> suspendUser({
    required String userId,
    required String reason,
    required Duration duration,
    String? relatedReportId,
  }) async {
    final sanction = await _createSanction(
      userId: userId,
      type: SanctionType.suspension,
      action: ModerationAction.temporarySuspension,
      reason: reason,
      expiresAt: DateTime.now().add(duration),
      relatedReportId: relatedReportId,
    );

    if (sanction != null) {
      await _moderationStatusCollection.doc(userId).set({
        'usualId': userId,
        'isSuspended': true,
        'suspendedUntil': sanction.expiresAt?.toIso8601String(),
      }, SetOptions(merge: true));
    }

    return sanction;
  }

  /// Permanently ban a user (admin only)
  Future<UserSanction?> banUser({
    required String userId,
    required String reason,
    String? relatedReportId,
  }) async {
    final sanction = await _createSanction(
      userId: userId,
      type: SanctionType.permanentBan,
      action: ModerationAction.permanentBan,
      reason: reason,
      relatedReportId: relatedReportId,
    );

    if (sanction != null) {
      await _moderationStatusCollection.doc(userId).set({
        'usualId': userId,
        'isBanned': true,
        'banReason': reason,
      }, SetOptions(merge: true));
    }

    return sanction;
  }

  Future<UserSanction?> _createSanction({
    required String userId,
    required SanctionType type,
    required ModerationAction action,
    required String reason,
    DateTime? expiresAt,
    String? relatedReportId,
  }) async {
    final moderatorId = _currentUserId;
    if (moderatorId == null) return null;

    try {
      final sanctionId = _uuid.v4();
      final sanction = UserSanction(
        sanctionId: sanctionId,
        usualId: userId,
        type: type,
        reason: reason,
        relatedReportId: relatedReportId,
        action: action,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        isActive: true,
        moderatorId: moderatorId,
      );

      await _sanctionsCollection.doc(sanctionId).set(sanction.toJson());

      // Update warning count if applicable
      if (type == SanctionType.warning) {
        await _moderationStatusCollection.doc(userId).set({
          'usualId': userId,
          'warningCount': FieldValue.increment(1),
          'lastWarningAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }

      developer.log('Sanction created: $sanctionId for user $userId',
          name: 'ModerationService');
      return sanction;
    } catch (e) {
      developer.log('Error creating sanction: $e', name: 'ModerationService');
      return null;
    }
  }

  /// Get sanctions for a user
  Future<List<UserSanction>> getUserSanctions(String userId) async {
    try {
      final snapshot = await _sanctionsCollection
          .where('usualId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserSanction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      developer.log('Error getting user sanctions: $e',
          name: 'ModerationService');
      return [];
    }
  }
}

/// Result of message validation
class MessageValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? filteredMessage;
  final bool wasFiltered;

  const MessageValidationResult({
    required this.isValid,
    this.errorMessage,
    this.filteredMessage,
    this.wasFiltered = false,
  });
}

/// Result of watch party validation
class WatchPartyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? filteredName;
  final String? filteredDescription;
  final bool wasFiltered;

  const WatchPartyValidationResult({
    required this.isValid,
    this.errorMessage,
    this.filteredName,
    this.filteredDescription,
    this.wasFiltered = false,
  });
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
