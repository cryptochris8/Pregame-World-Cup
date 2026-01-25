import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A match chat room for real-time discussion during a match
class MatchChat extends Equatable {
  final String chatId;
  final String matchId;
  final String matchName;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDateTime;
  final int participantCount;
  final int messageCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? closedAt;
  final MatchChatSettings settings;

  const MatchChat({
    required this.chatId,
    required this.matchId,
    required this.matchName,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    this.participantCount = 0,
    this.messageCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.closedAt,
    this.settings = const MatchChatSettings(),
  });

  factory MatchChat.fromFirestore(Map<String, dynamic> data, String docId) {
    return MatchChat(
      chatId: docId,
      matchId: data['matchId'] as String,
      matchName: data['matchName'] as String? ?? '',
      homeTeam: data['homeTeam'] as String? ?? '',
      awayTeam: data['awayTeam'] as String? ?? '',
      matchDateTime: data['matchDateTime'] != null
          ? (data['matchDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      participantCount: data['participantCount'] as int? ?? 0,
      messageCount: data['messageCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      closedAt: data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : null,
      settings: data['settings'] != null
          ? MatchChatSettings.fromJson(data['settings'] as Map<String, dynamic>)
          : const MatchChatSettings(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'matchName': matchName,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'matchDateTime': Timestamp.fromDate(matchDateTime),
      'participantCount': participantCount,
      'messageCount': messageCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'settings': settings.toJson(),
    };
  }

  MatchChat copyWith({
    int? participantCount,
    int? messageCount,
    bool? isActive,
    DateTime? closedAt,
    MatchChatSettings? settings,
  }) {
    return MatchChat(
      chatId: chatId,
      matchId: matchId,
      matchName: matchName,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      matchDateTime: matchDateTime,
      participantCount: participantCount ?? this.participantCount,
      messageCount: messageCount ?? this.messageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      closedAt: closedAt ?? this.closedAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [chatId, matchId, isActive];
}

/// Settings for a match chat room
class MatchChatSettings extends Equatable {
  final bool slowModeEnabled;
  final int slowModeSeconds; // Seconds between messages
  final bool subscribersOnly;
  final bool moderatorsOnly;
  final int maxMessageLength;

  const MatchChatSettings({
    this.slowModeEnabled = false,
    this.slowModeSeconds = 5,
    this.subscribersOnly = false,
    this.moderatorsOnly = false,
    this.maxMessageLength = 500,
  });

  factory MatchChatSettings.fromJson(Map<String, dynamic> json) {
    return MatchChatSettings(
      slowModeEnabled: json['slowModeEnabled'] as bool? ?? false,
      slowModeSeconds: json['slowModeSeconds'] as int? ?? 5,
      subscribersOnly: json['subscribersOnly'] as bool? ?? false,
      moderatorsOnly: json['moderatorsOnly'] as bool? ?? false,
      maxMessageLength: json['maxMessageLength'] as int? ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slowModeEnabled': slowModeEnabled,
      'slowModeSeconds': slowModeSeconds,
      'subscribersOnly': subscribersOnly,
      'moderatorsOnly': moderatorsOnly,
      'maxMessageLength': maxMessageLength,
    };
  }

  @override
  List<Object?> get props => [slowModeEnabled, slowModeSeconds, subscribersOnly];
}

/// A message in a match chat
class MatchChatMessage extends Equatable {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String? senderTeamFlair; // Team the user supports
  final String content;
  final MatchChatMessageType type;
  final DateTime sentAt;
  final bool isDeleted;
  final String? deletedBy;
  final Map<String, List<String>> reactions; // emoji -> list of user IDs
  final MatchEventData? eventData; // For goal/event reactions

  const MatchChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    this.senderTeamFlair,
    required this.content,
    this.type = MatchChatMessageType.text,
    required this.sentAt,
    this.isDeleted = false,
    this.deletedBy,
    this.reactions = const {},
    this.eventData,
  });

  factory MatchChatMessage.fromFirestore(Map<String, dynamic> data, String docId) {
    return MatchChatMessage(
      messageId: docId,
      chatId: data['chatId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String? ?? 'Unknown',
      senderImageUrl: data['senderImageUrl'] as String?,
      senderTeamFlair: data['senderTeamFlair'] as String?,
      content: data['content'] as String? ?? '',
      type: MatchChatMessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MatchChatMessageType.text,
      ),
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedBy: data['deletedBy'] as String?,
      reactions: _parseReactions(data['reactions']),
      eventData: data['eventData'] != null
          ? MatchEventData.fromJson(data['eventData'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, List<String>> _parseReactions(dynamic data) {
    if (data == null) return {};
    final map = data as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, List<String>.from(value ?? [])));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'senderTeamFlair': senderTeamFlair,
      'content': content,
      'type': type.name,
      'sentAt': Timestamp.fromDate(sentAt),
      'isDeleted': isDeleted,
      'deletedBy': deletedBy,
      'reactions': reactions,
      'eventData': eventData?.toJson(),
    };
  }

  MatchChatMessage copyWith({
    bool? isDeleted,
    String? deletedBy,
    Map<String, List<String>>? reactions,
  }) {
    return MatchChatMessage(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      senderTeamFlair: senderTeamFlair,
      content: content,
      type: type,
      sentAt: sentAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedBy: deletedBy ?? this.deletedBy,
      reactions: reactions ?? this.reactions,
      eventData: eventData,
    );
  }

  int get totalReactions {
    return reactions.values.fold(0, (total, list) => total + list.length);
  }

  @override
  List<Object?> get props => [messageId, chatId, senderId, sentAt, isDeleted];
}

/// Types of messages in match chat
enum MatchChatMessageType {
  text,
  goalReaction,
  eventReaction,
  system,
  moderator,
}

/// Data for match event reactions (goals, cards, etc.)
class MatchEventData extends Equatable {
  final MatchEventType eventType;
  final String? team;
  final String? playerName;
  final int? minute;
  final String? description;

  const MatchEventData({
    required this.eventType,
    this.team,
    this.playerName,
    this.minute,
    this.description,
  });

  factory MatchEventData.fromJson(Map<String, dynamic> json) {
    return MatchEventData(
      eventType: MatchEventType.values.firstWhere(
        (t) => t.name == json['eventType'],
        orElse: () => MatchEventType.other,
      ),
      team: json['team'] as String?,
      playerName: json['playerName'] as String?,
      minute: json['minute'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType.name,
      'team': team,
      'playerName': playerName,
      'minute': minute,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [eventType, team, minute];
}

/// Types of match events that can trigger reactions
enum MatchEventType {
  goal,
  ownGoal,
  penalty,
  penaltyMissed,
  yellowCard,
  redCard,
  substitution,
  kickoff,
  halftime,
  fulltime,
  varReview,
  injury,
  other,
}

extension MatchEventTypeExtension on MatchEventType {
  String get emoji {
    switch (this) {
      case MatchEventType.goal:
        return '⚽';
      case MatchEventType.ownGoal:
        return '😬';
      case MatchEventType.penalty:
        return '🎯';
      case MatchEventType.penaltyMissed:
        return '❌';
      case MatchEventType.yellowCard:
        return '🟨';
      case MatchEventType.redCard:
        return '🟥';
      case MatchEventType.substitution:
        return '🔄';
      case MatchEventType.kickoff:
        return '📣';
      case MatchEventType.halftime:
        return '⏸️';
      case MatchEventType.fulltime:
        return '🏁';
      case MatchEventType.varReview:
        return '📺';
      case MatchEventType.injury:
        return '🏥';
      case MatchEventType.other:
        return '📝';
    }
  }

  String get displayName {
    switch (this) {
      case MatchEventType.goal:
        return 'Goal!';
      case MatchEventType.ownGoal:
        return 'Own Goal';
      case MatchEventType.penalty:
        return 'Penalty Scored';
      case MatchEventType.penaltyMissed:
        return 'Penalty Missed';
      case MatchEventType.yellowCard:
        return 'Yellow Card';
      case MatchEventType.redCard:
        return 'Red Card';
      case MatchEventType.substitution:
        return 'Substitution';
      case MatchEventType.kickoff:
        return 'Kick Off';
      case MatchEventType.halftime:
        return 'Half Time';
      case MatchEventType.fulltime:
        return 'Full Time';
      case MatchEventType.varReview:
        return 'VAR Review';
      case MatchEventType.injury:
        return 'Injury';
      case MatchEventType.other:
        return 'Event';
    }
  }
}

/// Quick reaction emojis for match chat
class MatchChatReactions {
  static const List<String> quickReactions = [
    '⚽', // Goal celebration
    '🎉', // Celebration
    '😱', // Shock
    '😤', // Frustration
    '👏', // Applause
    '🔥', // Fire/excitement
    '💔', // Heartbreak
    '😂', // Laughter
  ];

  static const Map<String, String> reactionLabels = {
    '⚽': 'Goal!',
    '🎉': 'Celebrate',
    '😱': 'OMG',
    '😤': 'Frustrated',
    '👏': 'Applause',
    '🔥': 'Fire',
    '💔': 'Heartbreak',
    '😂': 'LOL',
  };
}
