import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'watch_party_member.g.dart';

/// Role of a member within a watch party
@HiveType(typeId: 34)
enum WatchPartyMemberRole {
  @HiveField(0)
  host,
  @HiveField(1)
  coHost,
  @HiveField(2)
  member,
}

/// Type of attendance for a watch party member
@HiveType(typeId: 35)
enum WatchPartyAttendanceType {
  @HiveField(0)
  inPerson,
  @HiveField(1)
  virtual,
}

/// RSVP status for a watch party member
@HiveType(typeId: 36)
enum MemberRsvpStatus {
  @HiveField(0)
  going,
  @HiveField(1)
  maybe,
  @HiveField(2)
  notGoing,
}

/// Represents a member of a watch party
@HiveType(typeId: 33)
class WatchPartyMember extends Equatable {
  @HiveField(0)
  final String memberId;

  @HiveField(1)
  final String watchPartyId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String displayName;

  @HiveField(4)
  final String? profileImageUrl;

  @HiveField(5)
  final WatchPartyMemberRole role;

  @HiveField(6)
  final WatchPartyAttendanceType attendanceType;

  @HiveField(7)
  final MemberRsvpStatus rsvpStatus;

  @HiveField(8)
  final DateTime joinedAt;

  @HiveField(9)
  final String? paymentIntentId;

  @HiveField(10)
  final bool hasPaid;

  @HiveField(11)
  final DateTime? checkedInAt;

  @HiveField(12)
  final bool isMuted;

  const WatchPartyMember({
    required this.memberId,
    required this.watchPartyId,
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    required this.role,
    required this.attendanceType,
    required this.rsvpStatus,
    required this.joinedAt,
    this.paymentIntentId,
    this.hasPaid = false,
    this.checkedInAt,
    this.isMuted = false,
  });

  /// Factory constructor to create a new member
  factory WatchPartyMember.create({
    required String watchPartyId,
    required String userId,
    required String displayName,
    String? profileImageUrl,
    required WatchPartyMemberRole role,
    required WatchPartyAttendanceType attendanceType,
    MemberRsvpStatus rsvpStatus = MemberRsvpStatus.going,
  }) {
    return WatchPartyMember(
      memberId: '${watchPartyId}_$userId',
      watchPartyId: watchPartyId,
      userId: userId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      role: role,
      attendanceType: attendanceType,
      rsvpStatus: rsvpStatus,
      joinedAt: DateTime.now(),
      hasPaid: attendanceType == WatchPartyAttendanceType.inPerson,
    );
  }

  /// Copy with method for immutable updates
  WatchPartyMember copyWith({
    String? displayName,
    String? profileImageUrl,
    WatchPartyMemberRole? role,
    WatchPartyAttendanceType? attendanceType,
    MemberRsvpStatus? rsvpStatus,
    String? paymentIntentId,
    bool? hasPaid,
    DateTime? checkedInAt,
    bool? isMuted,
  }) {
    return WatchPartyMember(
      memberId: memberId,
      watchPartyId: watchPartyId,
      userId: userId,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      attendanceType: attendanceType ?? this.attendanceType,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      joinedAt: joinedAt,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      hasPaid: hasPaid ?? this.hasPaid,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  // Computed getters
  bool get isHost => role == WatchPartyMemberRole.host;
  bool get isCoHost => role == WatchPartyMemberRole.coHost;
  bool get isMember => role == WatchPartyMemberRole.member;
  bool get isVirtual => attendanceType == WatchPartyAttendanceType.virtual;
  bool get isInPerson => attendanceType == WatchPartyAttendanceType.inPerson;
  bool get isGoing => rsvpStatus == MemberRsvpStatus.going;
  bool get isMaybe => rsvpStatus == MemberRsvpStatus.maybe;
  bool get isNotGoing => rsvpStatus == MemberRsvpStatus.notGoing;
  bool get hasCheckedIn => checkedInAt != null;

  /// Whether this member can send chat messages
  bool get canChat {
    if (isMuted) return false;
    if (isVirtual && !hasPaid) return false;
    return true;
  }

  /// Whether this member can manage other members
  bool get canManageMembers => isHost || isCoHost;

  String get roleDisplayName {
    switch (role) {
      case WatchPartyMemberRole.host:
        return 'Host';
      case WatchPartyMemberRole.coHost:
        return 'Co-Host';
      case WatchPartyMemberRole.member:
        return 'Member';
    }
  }

  String get attendanceTypeDisplayName {
    switch (attendanceType) {
      case WatchPartyAttendanceType.inPerson:
        return 'In Person';
      case WatchPartyAttendanceType.virtual:
        return 'Virtual';
    }
  }

  String get timeSinceJoined {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  // Specialized methods
  WatchPartyMember checkIn() {
    return copyWith(checkedInAt: DateTime.now());
  }

  WatchPartyMember mute() {
    return copyWith(isMuted: true);
  }

  WatchPartyMember unmute() {
    return copyWith(isMuted: false);
  }

  WatchPartyMember markAsPaid(String paymentIntentId) {
    return copyWith(
      hasPaid: true,
      paymentIntentId: paymentIntentId,
    );
  }

  WatchPartyMember promoteToCoHost() {
    return copyWith(role: WatchPartyMemberRole.coHost);
  }

  WatchPartyMember demoteToMember() {
    return copyWith(role: WatchPartyMemberRole.member);
  }

  // JSON serialization
  factory WatchPartyMember.fromJson(Map<String, dynamic> json) {
    return WatchPartyMember(
      memberId: json['memberId'] as String,
      watchPartyId: json['watchPartyId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: WatchPartyMemberRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => WatchPartyMemberRole.member,
      ),
      attendanceType: WatchPartyAttendanceType.values.firstWhere(
        (a) => a.name == json['attendanceType'],
        orElse: () => WatchPartyAttendanceType.inPerson,
      ),
      rsvpStatus: MemberRsvpStatus.values.firstWhere(
        (s) => s.name == json['rsvpStatus'],
        orElse: () => MemberRsvpStatus.going,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      paymentIntentId: json['paymentIntentId'] as String?,
      hasPaid: json['hasPaid'] as bool? ?? false,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      isMuted: json['isMuted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'watchPartyId': watchPartyId,
      'userId': userId,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'attendanceType': attendanceType.name,
      'rsvpStatus': rsvpStatus.name,
      'joinedAt': joinedAt.toIso8601String(),
      'paymentIntentId': paymentIntentId,
      'hasPaid': hasPaid,
      'checkedInAt': checkedInAt?.toIso8601String(),
      'isMuted': isMuted,
    };
  }

  /// Create WatchPartyMember from Firestore document
  factory WatchPartyMember.fromFirestore(Map<String, dynamic> data, String documentId) {
    return WatchPartyMember(
      memberId: documentId,
      watchPartyId: data['watchPartyId'] as String? ?? '',
      userId: data['userId'] as String? ?? documentId,
      displayName: data['displayName'] as String? ?? 'Member',
      profileImageUrl: data['profileImageUrl'] as String?,
      role: WatchPartyMemberRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => WatchPartyMemberRole.member,
      ),
      attendanceType: WatchPartyAttendanceType.values.firstWhere(
        (a) => a.name == data['attendanceType'],
        orElse: () => WatchPartyAttendanceType.inPerson,
      ),
      rsvpStatus: MemberRsvpStatus.values.firstWhere(
        (s) => s.name == data['rsvpStatus'],
        orElse: () => MemberRsvpStatus.going,
      ),
      joinedAt: data['joinedAt'] != null
          ? (data['joinedAt'] is String
              ? DateTime.parse(data['joinedAt'])
              : (data['joinedAt'] as Timestamp).toDate())
          : DateTime.now(),
      paymentIntentId: data['paymentIntentId'] as String?,
      hasPaid: data['hasPaid'] as bool? ?? false,
      checkedInAt: data['checkedInAt'] != null
          ? (data['checkedInAt'] is String
              ? DateTime.parse(data['checkedInAt'])
              : (data['checkedInAt'] as Timestamp).toDate())
          : null,
      isMuted: data['isMuted'] as bool? ?? false,
    );
  }

  /// Convert WatchPartyMember to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'watchPartyId': watchPartyId,
      'userId': userId,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'attendanceType': attendanceType.name,
      'rsvpStatus': rsvpStatus.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'paymentIntentId': paymentIntentId,
      'hasPaid': hasPaid,
      'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'isMuted': isMuted,
    };
  }

  @override
  List<Object?> get props => [
        memberId,
        watchPartyId,
        userId,
        displayName,
        profileImageUrl,
        role,
        attendanceType,
        rsvpStatus,
        joinedAt,
        paymentIntentId,
        hasPaid,
        checkedInAt,
        isMuted,
      ];
}
