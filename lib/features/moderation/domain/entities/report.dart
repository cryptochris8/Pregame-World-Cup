import 'package:equatable/equatable.dart';

/// Types of content that can be reported
enum ReportableContentType {
  user,
  message,
  watchParty,
  chatRoom,
  prediction,
  comment,
}

/// Reasons for reporting content
enum ReportReason {
  spam,
  harassment,
  hateSpeech,
  violence,
  sexualContent,
  misinformation,
  impersonation,
  scam,
  inappropriateContent,
  other,
}

/// Status of a report in the moderation queue
enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
  escalated,
}

/// Action taken on a report
enum ModerationAction {
  none,
  warning,
  contentRemoved,
  temporaryMute,
  temporarySuspension,
  permanentBan,
}

/// A report submitted by a user about content or another user
class Report extends Equatable {
  final String reportId;
  final String reporterId;
  final String reporterDisplayName;
  final ReportableContentType contentType;
  final String contentId;
  final String? contentOwnerId;
  final String? contentOwnerDisplayName;
  final ReportReason reason;
  final String? additionalDetails;
  final String? contentSnapshot;
  final ReportStatus status;
  final ModerationAction? actionTaken;
  final String? moderatorId;
  final String? moderatorNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;

  const Report({
    required this.reportId,
    required this.reporterId,
    required this.reporterDisplayName,
    required this.contentType,
    required this.contentId,
    this.contentOwnerId,
    this.contentOwnerDisplayName,
    required this.reason,
    this.additionalDetails,
    this.contentSnapshot,
    this.status = ReportStatus.pending,
    this.actionTaken,
    this.moderatorId,
    this.moderatorNotes,
    required this.createdAt,
    this.reviewedAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        reportId,
        reporterId,
        reporterDisplayName,
        contentType,
        contentId,
        contentOwnerId,
        contentOwnerDisplayName,
        reason,
        additionalDetails,
        contentSnapshot,
        status,
        actionTaken,
        moderatorId,
        moderatorNotes,
        createdAt,
        reviewedAt,
        resolvedAt,
      ];

  Report copyWith({
    String? reportId,
    String? reporterId,
    String? reporterDisplayName,
    ReportableContentType? contentType,
    String? contentId,
    String? contentOwnerId,
    String? contentOwnerDisplayName,
    ReportReason? reason,
    String? additionalDetails,
    String? contentSnapshot,
    ReportStatus? status,
    ModerationAction? actionTaken,
    String? moderatorId,
    String? moderatorNotes,
    DateTime? createdAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
  }) {
    return Report(
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      reporterDisplayName: reporterDisplayName ?? this.reporterDisplayName,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      contentOwnerId: contentOwnerId ?? this.contentOwnerId,
      contentOwnerDisplayName:
          contentOwnerDisplayName ?? this.contentOwnerDisplayName,
      reason: reason ?? this.reason,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      contentSnapshot: contentSnapshot ?? this.contentSnapshot,
      status: status ?? this.status,
      actionTaken: actionTaken ?? this.actionTaken,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reporterDisplayName': reporterDisplayName,
      'contentType': contentType.name,
      'contentId': contentId,
      'contentOwnerId': contentOwnerId,
      'contentOwnerDisplayName': contentOwnerDisplayName,
      'reason': reason.name,
      'additionalDetails': additionalDetails,
      'contentSnapshot': contentSnapshot,
      'status': status.name,
      'actionTaken': actionTaken?.name,
      'moderatorId': moderatorId,
      'moderatorNotes': moderatorNotes,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'] as String,
      reporterId: json['reporterId'] as String,
      reporterDisplayName: json['reporterDisplayName'] as String,
      contentType: ReportableContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => ReportableContentType.user,
      ),
      contentId: json['contentId'] as String,
      contentOwnerId: json['contentOwnerId'] as String?,
      contentOwnerDisplayName: json['contentOwnerDisplayName'] as String?,
      reason: ReportReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => ReportReason.other,
      ),
      additionalDetails: json['additionalDetails'] as String?,
      contentSnapshot: json['contentSnapshot'] as String?,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      actionTaken: json['actionTaken'] != null
          ? ModerationAction.values.firstWhere(
              (e) => e.name == json['actionTaken'],
              orElse: () => ModerationAction.none,
            )
          : null,
      moderatorId: json['moderatorId'] as String?,
      moderatorNotes: json['moderatorNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  /// Get human-readable reason text
  String get reasonDisplayText {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment or Bullying';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence or Threats';
      case ReportReason.sexualContent:
        return 'Sexual Content';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.impersonation:
        return 'Impersonation';
      case ReportReason.scam:
        return 'Scam or Fraud';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.other:
        return 'Other';
    }
  }

  /// Get human-readable content type text
  String get contentTypeDisplayText {
    switch (contentType) {
      case ReportableContentType.user:
        return 'User';
      case ReportableContentType.message:
        return 'Message';
      case ReportableContentType.watchParty:
        return 'Watch Party';
      case ReportableContentType.chatRoom:
        return 'Chat Room';
      case ReportableContentType.prediction:
        return 'Prediction';
      case ReportableContentType.comment:
        return 'Comment';
    }
  }
}
