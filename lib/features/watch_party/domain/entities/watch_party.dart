import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'watch_party.g.dart';

/// Visibility options for watch parties
@HiveType(typeId: 31)
enum WatchPartyVisibility {
  @HiveField(0)
  public,
  @HiveField(1)
  private,
}

/// Status of a watch party
@HiveType(typeId: 32)
enum WatchPartyStatus {
  @HiveField(0)
  upcoming,
  @HiveField(1)
  live,
  @HiveField(2)
  ended,
  @HiveField(3)
  cancelled,
}

/// Main WatchParty entity representing a watch party event
@HiveType(typeId: 30)
class WatchParty extends Equatable {
  @HiveField(0)
  final String watchPartyId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String hostId;

  @HiveField(4)
  final String hostName;

  @HiveField(5)
  final String? hostImageUrl;

  @HiveField(6)
  final WatchPartyVisibility visibility;

  @HiveField(7)
  final String gameId;

  @HiveField(8)
  final String gameName;

  @HiveField(9)
  final DateTime gameDateTime;

  @HiveField(10)
  final String venueId;

  @HiveField(11)
  final String venueName;

  @HiveField(12)
  final String? venueAddress;

  @HiveField(13)
  final double? venueLatitude;

  @HiveField(14)
  final double? venueLongitude;

  @HiveField(15)
  final int maxAttendees;

  @HiveField(16)
  final int currentAttendeesCount;

  @HiveField(17)
  final int virtualAttendeesCount;

  @HiveField(18)
  final bool allowVirtualAttendance;

  @HiveField(19)
  final double virtualAttendanceFee;

  @HiveField(20)
  final WatchPartyStatus status;

  @HiveField(21)
  final DateTime createdAt;

  @HiveField(22)
  final DateTime updatedAt;

  @HiveField(23)
  final String? imageUrl;

  @HiveField(24)
  final List<String> tags;

  @HiveField(25)
  final Map<String, dynamic> settings;

  const WatchParty({
    required this.watchPartyId,
    required this.name,
    required this.description,
    required this.hostId,
    required this.hostName,
    this.hostImageUrl,
    required this.visibility,
    required this.gameId,
    required this.gameName,
    required this.gameDateTime,
    required this.venueId,
    required this.venueName,
    this.venueAddress,
    this.venueLatitude,
    this.venueLongitude,
    required this.maxAttendees,
    this.currentAttendeesCount = 1,
    this.virtualAttendeesCount = 0,
    this.allowVirtualAttendance = false,
    this.virtualAttendanceFee = 0.0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.tags = const [],
    this.settings = const {},
  });

  /// Factory constructor to create a new watch party
  factory WatchParty.create({
    required String hostId,
    required String hostName,
    String? hostImageUrl,
    required String name,
    required String description,
    required WatchPartyVisibility visibility,
    required String gameId,
    required String gameName,
    required DateTime gameDateTime,
    required String venueId,
    required String venueName,
    String? venueAddress,
    double? venueLatitude,
    double? venueLongitude,
    int maxAttendees = 20,
    bool allowVirtualAttendance = false,
    double virtualAttendanceFee = 0.0,
    String? imageUrl,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return WatchParty(
      watchPartyId: 'wp_${now.millisecondsSinceEpoch}_$hostId',
      name: name,
      description: description,
      hostId: hostId,
      hostName: hostName,
      hostImageUrl: hostImageUrl,
      visibility: visibility,
      gameId: gameId,
      gameName: gameName,
      gameDateTime: gameDateTime,
      venueId: venueId,
      venueName: venueName,
      venueAddress: venueAddress,
      venueLatitude: venueLatitude,
      venueLongitude: venueLongitude,
      maxAttendees: maxAttendees,
      currentAttendeesCount: 1, // Host counts as first attendee
      virtualAttendeesCount: 0,
      allowVirtualAttendance: allowVirtualAttendance,
      virtualAttendanceFee: virtualAttendanceFee,
      status: WatchPartyStatus.upcoming,
      createdAt: now,
      updatedAt: now,
      imageUrl: imageUrl,
      tags: tags,
      settings: {},
    );
  }

  /// Copy with method for immutable updates
  WatchParty copyWith({
    String? name,
    String? description,
    String? hostName,
    String? hostImageUrl,
    WatchPartyVisibility? visibility,
    String? gameName,
    DateTime? gameDateTime,
    String? venueId,
    String? venueName,
    String? venueAddress,
    double? venueLatitude,
    double? venueLongitude,
    int? maxAttendees,
    int? currentAttendeesCount,
    int? virtualAttendeesCount,
    bool? allowVirtualAttendance,
    double? virtualAttendanceFee,
    WatchPartyStatus? status,
    DateTime? updatedAt,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? settings,
  }) {
    return WatchParty(
      watchPartyId: watchPartyId,
      name: name ?? this.name,
      description: description ?? this.description,
      hostId: hostId,
      hostName: hostName ?? this.hostName,
      hostImageUrl: hostImageUrl ?? this.hostImageUrl,
      visibility: visibility ?? this.visibility,
      gameId: gameId,
      gameName: gameName ?? this.gameName,
      gameDateTime: gameDateTime ?? this.gameDateTime,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venueLatitude: venueLatitude ?? this.venueLatitude,
      venueLongitude: venueLongitude ?? this.venueLongitude,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendeesCount: currentAttendeesCount ?? this.currentAttendeesCount,
      virtualAttendeesCount: virtualAttendeesCount ?? this.virtualAttendeesCount,
      allowVirtualAttendance: allowVirtualAttendance ?? this.allowVirtualAttendance,
      virtualAttendanceFee: virtualAttendanceFee ?? this.virtualAttendanceFee,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
    );
  }

  // Computed getters
  bool get isFull => currentAttendeesCount >= maxAttendees;
  bool get hasSpots => currentAttendeesCount < maxAttendees;
  int get availableSpots => maxAttendees - currentAttendeesCount;
  bool get isPublic => visibility == WatchPartyVisibility.public;
  bool get isPrivate => visibility == WatchPartyVisibility.private;
  bool get isUpcoming => status == WatchPartyStatus.upcoming;
  bool get isLive => status == WatchPartyStatus.live;
  bool get hasEnded => status == WatchPartyStatus.ended;
  bool get isCancelled => status == WatchPartyStatus.cancelled;
  bool get canJoin => hasSpots && isUpcoming;
  int get totalAttendees => currentAttendeesCount + virtualAttendeesCount;

  bool get hasStarted {
    final now = DateTime.now();
    return now.isAfter(gameDateTime) || status == WatchPartyStatus.live;
  }

  String get timeUntilStart {
    if (hasStarted) return 'Started';
    if (hasEnded) return 'Ended';

    final now = DateTime.now();
    final difference = gameDateTime.difference(now);

    if (difference.inDays > 0) return 'In ${difference.inDays}d';
    if (difference.inHours > 0) return 'In ${difference.inHours}h';
    if (difference.inMinutes > 0) return 'In ${difference.inMinutes}m';
    return 'Starts soon';
  }

  String get attendeesText {
    if (isFull) return 'Full ($currentAttendeesCount/$maxAttendees)';
    return '$currentAttendeesCount/$maxAttendees attending';
  }

  String get virtualFeeText {
    if (!allowVirtualAttendance) return '';
    if (virtualAttendanceFee <= 0) return 'Free';
    return '\$${virtualAttendanceFee.toStringAsFixed(2)}';
  }

  // JSON serialization
  factory WatchParty.fromJson(Map<String, dynamic> json) {
    return WatchParty(
      watchPartyId: json['watchPartyId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      hostImageUrl: json['hostImageUrl'] as String?,
      visibility: WatchPartyVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => WatchPartyVisibility.public,
      ),
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      gameDateTime: DateTime.parse(json['gameDateTime'] as String),
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      venueAddress: json['venueAddress'] as String?,
      venueLatitude: (json['venueLatitude'] as num?)?.toDouble(),
      venueLongitude: (json['venueLongitude'] as num?)?.toDouble(),
      maxAttendees: json['maxAttendees'] as int? ?? 20,
      currentAttendeesCount: json['currentAttendeesCount'] as int? ?? 1,
      virtualAttendeesCount: json['virtualAttendeesCount'] as int? ?? 0,
      allowVirtualAttendance: json['allowVirtualAttendance'] as bool? ?? false,
      virtualAttendanceFee: (json['virtualAttendanceFee'] as num?)?.toDouble() ?? 0.0,
      status: WatchPartyStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WatchPartyStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watchPartyId': watchPartyId,
      'name': name,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'hostImageUrl': hostImageUrl,
      'visibility': visibility.name,
      'gameId': gameId,
      'gameName': gameName,
      'gameDateTime': gameDateTime.toIso8601String(),
      'venueId': venueId,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'venueLatitude': venueLatitude,
      'venueLongitude': venueLongitude,
      'maxAttendees': maxAttendees,
      'currentAttendeesCount': currentAttendeesCount,
      'virtualAttendeesCount': virtualAttendeesCount,
      'allowVirtualAttendance': allowVirtualAttendance,
      'virtualAttendanceFee': virtualAttendanceFee,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'tags': tags,
      'settings': settings,
    };
  }

  /// Create WatchParty from Firestore document
  factory WatchParty.fromFirestore(Map<String, dynamic> data, String documentId) {
    return WatchParty(
      watchPartyId: documentId,
      name: data['name'] as String? ?? 'Untitled Party',
      description: data['description'] as String? ?? '',
      hostId: data['hostId'] as String,
      hostName: data['hostName'] as String? ?? 'Host',
      hostImageUrl: data['hostImageUrl'] as String?,
      visibility: WatchPartyVisibility.values.firstWhere(
        (v) => v.name == data['visibility'],
        orElse: () => WatchPartyVisibility.public,
      ),
      gameId: data['gameId'] as String,
      gameName: data['gameName'] as String? ?? 'Game',
      gameDateTime: data['gameDateTime'] != null
          ? (data['gameDateTime'] is String
              ? DateTime.parse(data['gameDateTime'])
              : (data['gameDateTime'] as Timestamp).toDate())
          : DateTime.now(),
      venueId: data['venueId'] as String,
      venueName: data['venueName'] as String? ?? 'Venue',
      venueAddress: data['venueAddress'] as String?,
      venueLatitude: (data['venueLatitude'] as num?)?.toDouble(),
      venueLongitude: (data['venueLongitude'] as num?)?.toDouble(),
      maxAttendees: data['maxAttendees'] as int? ?? 20,
      currentAttendeesCount: data['currentAttendeesCount'] as int? ?? 1,
      virtualAttendeesCount: data['virtualAttendeesCount'] as int? ?? 0,
      allowVirtualAttendance: data['allowVirtualAttendance'] as bool? ?? false,
      virtualAttendanceFee: (data['virtualAttendanceFee'] as num?)?.toDouble() ?? 0.0,
      status: WatchPartyStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => WatchPartyStatus.upcoming,
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is String
              ? DateTime.parse(data['updatedAt'])
              : (data['updatedAt'] as Timestamp).toDate())
          : DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
    );
  }

  /// Convert WatchParty to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'hostImageUrl': hostImageUrl,
      'visibility': visibility.name,
      'gameId': gameId,
      'gameName': gameName,
      'gameDateTime': Timestamp.fromDate(gameDateTime),
      'venueId': venueId,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'venueLatitude': venueLatitude,
      'venueLongitude': venueLongitude,
      'maxAttendees': maxAttendees,
      'currentAttendeesCount': currentAttendeesCount,
      'virtualAttendeesCount': virtualAttendeesCount,
      'allowVirtualAttendance': allowVirtualAttendance,
      'virtualAttendanceFee': virtualAttendanceFee,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrl': imageUrl,
      'tags': tags,
      'settings': settings,
    };
  }

  @override
  List<Object?> get props => [
        watchPartyId,
        name,
        description,
        hostId,
        hostName,
        hostImageUrl,
        visibility,
        gameId,
        gameName,
        gameDateTime,
        venueId,
        venueName,
        venueAddress,
        venueLatitude,
        venueLongitude,
        maxAttendees,
        currentAttendeesCount,
        virtualAttendeesCount,
        allowVirtualAttendance,
        virtualAttendanceFee,
        status,
        createdAt,
        updatedAt,
        imageUrl,
        tags,
        settings,
      ];
}
