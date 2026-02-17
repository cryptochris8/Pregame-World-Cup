import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../entities/report.dart';
import '../entities/user_sanction.dart';

/// Handles admin sanctions: warnings, mutes, suspensions, bans, and user
/// moderation status queries.
class ModerationActionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  ModerationActionService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  CollectionReference<Map<String, dynamic>> get _sanctionsCollection =>
      _firestore.collection('user_sanctions');

  CollectionReference<Map<String, dynamic>> get _moderationStatusCollection =>
      _firestore.collection('user_moderation_status');

  String? get _currentUserId => _auth.currentUser?.uid;

  // ==================== User Moderation Status ====================

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
        return _copyWithStatus(status, isMuted: false, clearMutedUntil: true);
      }

      if (status.isSuspended &&
          status.suspendedUntil != null &&
          DateTime.now().isAfter(status.suspendedUntil!)) {
        await _clearExpiredSuspension(userId);
        return _copyWithStatus(status, isSuspended: false, clearSuspendedUntil: true);
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

  // ==================== Admin Sanctions ====================

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

  // ==================== Private Helpers ====================

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

  /// Helper to create a modified copy of UserModerationStatus
  UserModerationStatus _copyWithStatus(
    UserModerationStatus status, {
    bool? isMuted,
    bool? isSuspended,
    bool clearMutedUntil = false,
    bool clearSuspendedUntil = false,
  }) {
    return UserModerationStatus(
      usualId: status.usualId,
      warningCount: status.warningCount,
      reportCount: status.reportCount,
      isMuted: isMuted ?? status.isMuted,
      mutedUntil: clearMutedUntil ? null : status.mutedUntil,
      isSuspended: isSuspended ?? status.isSuspended,
      suspendedUntil: clearSuspendedUntil ? null : status.suspendedUntil,
      isBanned: status.isBanned,
      banReason: status.banReason,
      activeSanctions: status.activeSanctions,
      lastWarningAt: status.lastWarningAt,
    );
  }
}
