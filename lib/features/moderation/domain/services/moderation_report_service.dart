import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../entities/report.dart';

/// Handles report submission, querying, and resolution.
class ModerationReportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  ModerationReportService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _moderationStatusCollection =>
      _firestore.collection('user_moderation_status');

  String? get _currentUserId => _auth.currentUser?.uid;

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

  /// Report a user (convenience method)
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

  /// Report a message (convenience method)
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

  /// Report a watch party (convenience method)
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

  Future<void> _incrementReportCount(String userId) async {
    await _moderationStatusCollection.doc(userId).set({
      'usualId': userId,
      'reportCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
}
