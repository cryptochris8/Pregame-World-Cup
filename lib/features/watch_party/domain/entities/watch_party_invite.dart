import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'watch_party_invite.g.dart';

/// Status of a watch party invite
@HiveType(typeId: 40)
enum WatchPartyInviteStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  accepted,
  @HiveField(2)
  declined,
  @HiveField(3)
  expired,
}

/// Represents an invitation to join a watch party
@HiveType(typeId: 39)
class WatchPartyInvite extends Equatable {
  @HiveField(0)
  final String inviteId;

  @HiveField(1)
  final String watchPartyId;

  @HiveField(2)
  final String watchPartyName;

  @HiveField(3)
  final String inviterId;

  @HiveField(4)
  final String inviterName;

  @HiveField(5)
  final String? inviterImageUrl;

  @HiveField(6)
  final String inviteeId;

  @HiveField(7)
  final WatchPartyInviteStatus status;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime expiresAt;

  @HiveField(10)
  final String? message;

  @HiveField(11)
  final String? gameName;

  @HiveField(12)
  final DateTime? gameDateTime;

  @HiveField(13)
  final String? venueName;

  const WatchPartyInvite({
    required this.inviteId,
    required this.watchPartyId,
    required this.watchPartyName,
    required this.inviterId,
    required this.inviterName,
    this.inviterImageUrl,
    required this.inviteeId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.message,
    this.gameName,
    this.gameDateTime,
    this.venueName,
  });

  /// Factory constructor to create a new invite
  factory WatchPartyInvite.create({
    required String watchPartyId,
    required String watchPartyName,
    required String inviterId,
    required String inviterName,
    String? inviterImageUrl,
    required String inviteeId,
    required DateTime expiresAt,
    String? message,
    String? gameName,
    DateTime? gameDateTime,
    String? venueName,
  }) {
    final now = DateTime.now();
    return WatchPartyInvite(
      inviteId: 'inv_${now.millisecondsSinceEpoch}_${inviterId}_$inviteeId',
      watchPartyId: watchPartyId,
      watchPartyName: watchPartyName,
      inviterId: inviterId,
      inviterName: inviterName,
      inviterImageUrl: inviterImageUrl,
      inviteeId: inviteeId,
      status: WatchPartyInviteStatus.pending,
      createdAt: now,
      expiresAt: expiresAt,
      message: message,
      gameName: gameName,
      gameDateTime: gameDateTime,
      venueName: venueName,
    );
  }

  /// Copy with method for immutable updates
  WatchPartyInvite copyWith({
    WatchPartyInviteStatus? status,
    String? message,
  }) {
    return WatchPartyInvite(
      inviteId: inviteId,
      watchPartyId: watchPartyId,
      watchPartyName: watchPartyName,
      inviterId: inviterId,
      inviterName: inviterName,
      inviterImageUrl: inviterImageUrl,
      inviteeId: inviteeId,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      message: message ?? this.message,
      gameName: gameName,
      gameDateTime: gameDateTime,
      venueName: venueName,
    );
  }

  // Computed getters
  bool get isPending => status == WatchPartyInviteStatus.pending;
  bool get isAccepted => status == WatchPartyInviteStatus.accepted;
  bool get isDeclined => status == WatchPartyInviteStatus.declined;
  bool get isExpiredStatus => status == WatchPartyInviteStatus.expired;

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isValid {
    return isPending && !isExpired;
  }

  bool get canRespond {
    return isPending && !isExpired;
  }

  String get statusDisplayName {
    switch (status) {
      case WatchPartyInviteStatus.pending:
        return 'Pending';
      case WatchPartyInviteStatus.accepted:
        return 'Accepted';
      case WatchPartyInviteStatus.declined:
        return 'Declined';
      case WatchPartyInviteStatus.expired:
        return 'Expired';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  String get expiresIn {
    if (isExpired) return 'Expired';

    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) return 'Expires in ${difference.inDays}d';
    if (difference.inHours > 0) return 'Expires in ${difference.inHours}h';
    if (difference.inMinutes > 0) return 'Expires in ${difference.inMinutes}m';
    return 'Expires soon';
  }

  // Specialized methods
  WatchPartyInvite accept() {
    return copyWith(status: WatchPartyInviteStatus.accepted);
  }

  WatchPartyInvite decline() {
    return copyWith(status: WatchPartyInviteStatus.declined);
  }

  WatchPartyInvite markExpired() {
    return copyWith(status: WatchPartyInviteStatus.expired);
  }

  // JSON serialization
  factory WatchPartyInvite.fromJson(Map<String, dynamic> json) {
    return WatchPartyInvite(
      inviteId: json['inviteId'] as String,
      watchPartyId: json['watchPartyId'] as String,
      watchPartyName: json['watchPartyName'] as String,
      inviterId: json['inviterId'] as String,
      inviterName: json['inviterName'] as String,
      inviterImageUrl: json['inviterImageUrl'] as String?,
      inviteeId: json['inviteeId'] as String,
      status: WatchPartyInviteStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WatchPartyInviteStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      message: json['message'] as String?,
      gameName: json['gameName'] as String?,
      gameDateTime: json['gameDateTime'] != null
          ? DateTime.parse(json['gameDateTime'] as String)
          : null,
      venueName: json['venueName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteId': inviteId,
      'watchPartyId': watchPartyId,
      'watchPartyName': watchPartyName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterImageUrl': inviterImageUrl,
      'inviteeId': inviteeId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'message': message,
      'gameName': gameName,
      'gameDateTime': gameDateTime?.toIso8601String(),
      'venueName': venueName,
    };
  }

  /// Create WatchPartyInvite from Firestore document
  factory WatchPartyInvite.fromFirestore(Map<String, dynamic> data, String documentId) {
    return WatchPartyInvite(
      inviteId: documentId,
      watchPartyId: data['watchPartyId'] as String,
      watchPartyName: data['watchPartyName'] as String? ?? 'Watch Party',
      inviterId: data['inviterId'] as String,
      inviterName: data['inviterName'] as String? ?? 'User',
      inviterImageUrl: data['inviterImageUrl'] as String?,
      inviteeId: data['inviteeId'] as String,
      status: WatchPartyInviteStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => WatchPartyInviteStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] is String
              ? DateTime.parse(data['expiresAt'])
              : (data['expiresAt'] as Timestamp).toDate())
          : DateTime.now().add(const Duration(days: 7)),
      message: data['message'] as String?,
      gameName: data['gameName'] as String?,
      gameDateTime: data['gameDateTime'] != null
          ? (data['gameDateTime'] is String
              ? DateTime.parse(data['gameDateTime'])
              : (data['gameDateTime'] as Timestamp).toDate())
          : null,
      venueName: data['venueName'] as String?,
    );
  }

  /// Convert WatchPartyInvite to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'watchPartyId': watchPartyId,
      'watchPartyName': watchPartyName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterImageUrl': inviterImageUrl,
      'inviteeId': inviteeId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'message': message,
      'gameName': gameName,
      'gameDateTime': gameDateTime != null ? Timestamp.fromDate(gameDateTime!) : null,
      'venueName': venueName,
    };
  }

  @override
  List<Object?> get props => [
        inviteId,
        watchPartyId,
        watchPartyName,
        inviterId,
        inviterName,
        inviterImageUrl,
        inviteeId,
        status,
        createdAt,
        expiresAt,
        message,
        gameName,
        gameDateTime,
        venueName,
      ];
}
