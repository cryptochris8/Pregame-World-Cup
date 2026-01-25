import 'package:equatable/equatable.dart';
import 'report.dart';

/// Type of sanction applied to a user
enum SanctionType {
  warning,
  mute,
  suspension,
  permanentBan,
}

/// A sanction/punishment applied to a user
class UserSanction extends Equatable {
  final String sanctionId;
  final String usualId;
  final SanctionType type;
  final String reason;
  final String? relatedReportId;
  final ModerationAction action;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? moderatorId;
  final String? appealMessage;
  final DateTime? appealedAt;
  final bool appealResolved;
  final String? appealResolution;

  const UserSanction({
    required this.sanctionId,
    required this.usualId,
    required this.type,
    required this.reason,
    this.relatedReportId,
    required this.action,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.moderatorId,
    this.appealMessage,
    this.appealedAt,
    this.appealResolved = false,
    this.appealResolution,
  });

  @override
  List<Object?> get props => [
        sanctionId,
        usualId,
        type,
        reason,
        relatedReportId,
        action,
        createdAt,
        expiresAt,
        isActive,
        moderatorId,
        appealMessage,
        appealedAt,
        appealResolved,
        appealResolution,
      ];

  /// Check if this sanction has expired
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this sanction is currently in effect
  bool get isCurrentlyActive => isActive && !hasExpired;

  /// Get duration text for display
  String get durationText {
    if (expiresAt == null) return 'Permanent';
    final duration = expiresAt!.difference(createdAt);
    if (duration.inDays >= 1) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  UserSanction copyWith({
    String? sanctionId,
    String? usualId,
    SanctionType? type,
    String? reason,
    String? relatedReportId,
    ModerationAction? action,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    String? moderatorId,
    String? appealMessage,
    DateTime? appealedAt,
    bool? appealResolved,
    String? appealResolution,
  }) {
    return UserSanction(
      sanctionId: sanctionId ?? this.sanctionId,
      usualId: usualId ?? this.usualId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      relatedReportId: relatedReportId ?? this.relatedReportId,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      moderatorId: moderatorId ?? this.moderatorId,
      appealMessage: appealMessage ?? this.appealMessage,
      appealedAt: appealedAt ?? this.appealedAt,
      appealResolved: appealResolved ?? this.appealResolved,
      appealResolution: appealResolution ?? this.appealResolution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sanctionId': sanctionId,
      'usualId': usualId,
      'type': type.name,
      'reason': reason,
      'relatedReportId': relatedReportId,
      'action': action.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'moderatorId': moderatorId,
      'appealMessage': appealMessage,
      'appealedAt': appealedAt?.toIso8601String(),
      'appealResolved': appealResolved,
      'appealResolution': appealResolution,
    };
  }

  factory UserSanction.fromJson(Map<String, dynamic> json) {
    return UserSanction(
      sanctionId: json['sanctionId'] as String,
      usualId: json['usualId'] as String,
      type: SanctionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SanctionType.warning,
      ),
      reason: json['reason'] as String,
      relatedReportId: json['relatedReportId'] as String?,
      action: ModerationAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => ModerationAction.warning,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      moderatorId: json['moderatorId'] as String?,
      appealMessage: json['appealMessage'] as String?,
      appealedAt: json['appealedAt'] != null
          ? DateTime.parse(json['appealedAt'] as String)
          : null,
      appealResolved: json['appealResolved'] as bool? ?? false,
      appealResolution: json['appealResolution'] as String?,
    );
  }
}

/// User's moderation status summary
class UserModerationStatus extends Equatable {
  final String usualId;
  final int warningCount;
  final int reportCount;
  final bool isMuted;
  final DateTime? mutedUntil;
  final bool isSuspended;
  final DateTime? suspendedUntil;
  final bool isBanned;
  final String? banReason;
  final List<UserSanction> activeSanctions;
  final DateTime? lastWarningAt;

  const UserModerationStatus({
    required this.usualId,
    this.warningCount = 0,
    this.reportCount = 0,
    this.isMuted = false,
    this.mutedUntil,
    this.isSuspended = false,
    this.suspendedUntil,
    this.isBanned = false,
    this.banReason,
    this.activeSanctions = const [],
    this.lastWarningAt,
  });

  @override
  List<Object?> get props => [
        usualId,
        warningCount,
        reportCount,
        isMuted,
        mutedUntil,
        isSuspended,
        suspendedUntil,
        isBanned,
        banReason,
        activeSanctions,
        lastWarningAt,
      ];

  /// Check if user can send messages
  bool get canSendMessages => !isMuted && !isSuspended && !isBanned;

  /// Check if user can create watch parties
  bool get canCreateWatchParties => !isSuspended && !isBanned;

  /// Check if user can access the app
  bool get canAccessApp => !isBanned;

  /// Get the most severe active restriction
  String? get activeRestrictionText {
    if (isBanned) return 'Account permanently banned';
    if (isSuspended && suspendedUntil != null) {
      return 'Account suspended until ${_formatDate(suspendedUntil!)}';
    }
    if (isMuted && mutedUntil != null) {
      return 'Muted until ${_formatDate(mutedUntil!)}';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'usualId': usualId,
      'warningCount': warningCount,
      'reportCount': reportCount,
      'isMuted': isMuted,
      'mutedUntil': mutedUntil?.toIso8601String(),
      'isSuspended': isSuspended,
      'suspendedUntil': suspendedUntil?.toIso8601String(),
      'isBanned': isBanned,
      'banReason': banReason,
      'activeSanctions': activeSanctions.map((s) => s.toJson()).toList(),
      'lastWarningAt': lastWarningAt?.toIso8601String(),
    };
  }

  factory UserModerationStatus.fromJson(Map<String, dynamic> json) {
    return UserModerationStatus(
      usualId: json['usualId'] as String,
      warningCount: json['warningCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      mutedUntil: json['mutedUntil'] != null
          ? DateTime.parse(json['mutedUntil'] as String)
          : null,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspendedUntil: json['suspendedUntil'] != null
          ? DateTime.parse(json['suspendedUntil'] as String)
          : null,
      isBanned: json['isBanned'] as bool? ?? false,
      banReason: json['banReason'] as String?,
      activeSanctions: (json['activeSanctions'] as List<dynamic>?)
              ?.map((s) => UserSanction.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      lastWarningAt: json['lastWarningAt'] != null
          ? DateTime.parse(json['lastWarningAt'] as String)
          : null,
    );
  }

  /// Create empty status for a user
  factory UserModerationStatus.empty(String usualId) {
    return UserModerationStatus(usualId: usualId);
  }
}
