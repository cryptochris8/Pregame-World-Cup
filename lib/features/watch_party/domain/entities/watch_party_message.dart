import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'watch_party_member.dart';

part 'watch_party_message.g.dart';

/// Type of message in watch party chat
@HiveType(typeId: 38)
enum WatchPartyMessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  gif,
  @HiveField(3)
  system,
  @HiveField(4)
  poll,
}

/// Represents a reaction to a message
@HiveType(typeId: 41)
class MessageReaction extends Equatable {
  @HiveField(0)
  final String emoji;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName;

  @HiveField(3)
  final DateTime createdAt;

  const MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [emoji, userId, userName, createdAt];
}

/// Represents a chat message in a watch party
@HiveType(typeId: 37)
class WatchPartyMessage extends Equatable {
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String watchPartyId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String? senderImageUrl;

  @HiveField(5)
  final WatchPartyMemberRole senderRole;

  @HiveField(6)
  final String content;

  @HiveField(7)
  final WatchPartyMessageType type;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final bool isDeleted;

  @HiveField(10)
  final List<MessageReaction> reactions;

  @HiveField(11)
  final String? replyToMessageId;

  @HiveField(12)
  final Map<String, dynamic> metadata;

  const WatchPartyMessage({
    required this.messageId,
    required this.watchPartyId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isDeleted = false,
    this.reactions = const [],
    this.replyToMessageId,
    this.metadata = const {},
  });

  /// Factory constructor for creating a text message
  factory WatchPartyMessage.text({
    required String watchPartyId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required WatchPartyMemberRole senderRole,
    required String content,
    String? replyToMessageId,
  }) {
    final now = DateTime.now();
    return WatchPartyMessage(
      messageId: 'msg_${now.millisecondsSinceEpoch}_$senderId',
      watchPartyId: watchPartyId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      senderRole: senderRole,
      content: content,
      type: WatchPartyMessageType.text,
      createdAt: now,
      replyToMessageId: replyToMessageId,
    );
  }

  /// Factory constructor for creating a system message
  factory WatchPartyMessage.system({
    required String watchPartyId,
    required String content,
  }) {
    final now = DateTime.now();
    return WatchPartyMessage(
      messageId: 'sys_${now.millisecondsSinceEpoch}',
      watchPartyId: watchPartyId,
      senderId: 'system',
      senderName: 'System',
      senderRole: WatchPartyMemberRole.host,
      content: content,
      type: WatchPartyMessageType.system,
      createdAt: now,
    );
  }

  /// Factory constructor for creating an image message
  factory WatchPartyMessage.image({
    required String watchPartyId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required WatchPartyMemberRole senderRole,
    required String imageUrl,
    String? caption,
  }) {
    final now = DateTime.now();
    return WatchPartyMessage(
      messageId: 'img_${now.millisecondsSinceEpoch}_$senderId',
      watchPartyId: watchPartyId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      senderRole: senderRole,
      content: caption ?? '',
      type: WatchPartyMessageType.image,
      createdAt: now,
      metadata: {'imageUrl': imageUrl},
    );
  }

  /// Factory constructor for creating a GIF message
  factory WatchPartyMessage.gif({
    required String watchPartyId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required WatchPartyMemberRole senderRole,
    required String gifUrl,
  }) {
    final now = DateTime.now();
    return WatchPartyMessage(
      messageId: 'gif_${now.millisecondsSinceEpoch}_$senderId',
      watchPartyId: watchPartyId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      senderRole: senderRole,
      content: '',
      type: WatchPartyMessageType.gif,
      createdAt: now,
      metadata: {'gifUrl': gifUrl},
    );
  }

  /// Copy with method for immutable updates
  WatchPartyMessage copyWith({
    String? content,
    bool? isDeleted,
    List<MessageReaction>? reactions,
    Map<String, dynamic>? metadata,
  }) {
    return WatchPartyMessage(
      messageId: messageId,
      watchPartyId: watchPartyId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      senderRole: senderRole,
      content: content ?? this.content,
      type: type,
      createdAt: createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Computed getters
  bool get isText => type == WatchPartyMessageType.text;
  bool get isImage => type == WatchPartyMessageType.image;
  bool get isGif => type == WatchPartyMessageType.gif;
  bool get isSystem => type == WatchPartyMessageType.system;
  bool get isPoll => type == WatchPartyMessageType.poll;
  bool get isReply => replyToMessageId != null;
  bool get hasReactions => reactions.isNotEmpty;
  bool get isFromHost => senderRole == WatchPartyMemberRole.host;
  bool get isFromCoHost => senderRole == WatchPartyMemberRole.coHost;

  String? get imageUrl => metadata['imageUrl'] as String?;
  String? get gifUrl => metadata['gifUrl'] as String?;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get count of a specific reaction emoji
  int getReactionCount(String emoji) {
    return reactions.where((r) => r.emoji == emoji).length;
  }

  /// Check if a user has reacted with a specific emoji
  bool hasUserReacted(String userId, String emoji) {
    return reactions.any((r) => r.userId == userId && r.emoji == emoji);
  }

  /// Get unique emojis used in reactions
  List<String> get uniqueReactionEmojis {
    return reactions.map((r) => r.emoji).toSet().toList();
  }

  // Specialized methods
  WatchPartyMessage delete() {
    return copyWith(isDeleted: true, content: 'This message was deleted');
  }

  WatchPartyMessage addReaction(MessageReaction reaction) {
    final updatedReactions = List<MessageReaction>.from(reactions)..add(reaction);
    return copyWith(reactions: updatedReactions);
  }

  WatchPartyMessage removeReaction(String userId, String emoji) {
    final updatedReactions = reactions
        .where((r) => !(r.userId == userId && r.emoji == emoji))
        .toList();
    return copyWith(reactions: updatedReactions);
  }

  // JSON serialization
  factory WatchPartyMessage.fromJson(Map<String, dynamic> json) {
    return WatchPartyMessage(
      messageId: json['messageId'] as String,
      watchPartyId: json['watchPartyId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String?,
      senderRole: WatchPartyMemberRole.values.firstWhere(
        (r) => r.name == json['senderRole'],
        orElse: () => WatchPartyMemberRole.member,
      ),
      content: json['content'] as String,
      type: WatchPartyMessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WatchPartyMessageType.text,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      replyToMessageId: json['replyToMessageId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'watchPartyId': watchPartyId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'senderRole': senderRole.name,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyToMessageId': replyToMessageId,
      'metadata': metadata,
    };
  }

  /// Create WatchPartyMessage from Firestore document
  factory WatchPartyMessage.fromFirestore(Map<String, dynamic> data, String documentId) {
    return WatchPartyMessage(
      messageId: documentId,
      watchPartyId: data['watchPartyId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'User',
      senderImageUrl: data['senderImageUrl'] as String?,
      senderRole: WatchPartyMemberRole.values.firstWhere(
        (r) => r.name == data['senderRole'],
        orElse: () => WatchPartyMemberRole.member,
      ),
      content: data['content'] as String? ?? '',
      type: WatchPartyMessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => WatchPartyMessageType.text,
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      reactions: (data['reactions'] as List<dynamic>?)
              ?.map((r) => MessageReaction.fromJson(Map<String, dynamic>.from(r)))
              .toList() ??
          [],
      replyToMessageId: data['replyToMessageId'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert WatchPartyMessage to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'watchPartyId': watchPartyId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'senderRole': senderRole.name,
      'content': content,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyToMessageId': replyToMessageId,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        messageId,
        watchPartyId,
        senderId,
        senderName,
        senderImageUrl,
        senderRole,
        content,
        type,
        createdAt,
        isDeleted,
        reactions,
        replyToMessageId,
        metadata,
      ];
}
