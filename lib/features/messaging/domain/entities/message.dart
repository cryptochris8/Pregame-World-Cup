import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 17)
class Message extends Equatable {
  @HiveField(0)
  final String messageId;
  
  @HiveField(1)
  final String chatId;
  
  @HiveField(2)
  final String senderId;
  
  @HiveField(3)
  final String senderName;
  
  @HiveField(4)
  final String? senderImageUrl;
  
  @HiveField(5)
  final String content;
  
  @HiveField(6)
  final MessageType type;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? updatedAt;
  
  @HiveField(9)
  final MessageStatus status;
  
  @HiveField(10)
  final String? replyToMessageId;
  
  @HiveField(11)
  final List<MessageReaction> reactions;
  
  @HiveField(12)
  final Map<String, dynamic> metadata;
  
  @HiveField(13)
  final bool isDeleted;
  
  @HiveField(14)
  final List<String> readBy;

  const Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.replyToMessageId,
    this.reactions = const [],
    this.metadata = const {},
    this.isDeleted = false,
    this.readBy = const [],
  });

  factory Message.text({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String content,
    String? replyToMessageId,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: content,
      type: MessageType.text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
    );
  }

  factory Message.image({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String imageUrl,
    String? caption,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: caption ?? '',
      type: MessageType.image,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      metadata: {'imageUrl': imageUrl},
    );
  }

  factory Message.system({
    required String chatId,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'system',
      senderName: 'System',
      content: content,
      type: MessageType.system,
      createdAt: DateTime.now(),
      status: MessageStatus.delivered,
      metadata: metadata ?? {},
    );
  }

  // Phase 3C: Advanced Message Types
  factory Message.voice({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String audioUrl,
    required int durationSeconds,
    List<double>? waveformData,
    String? replyToMessageId,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: 'Voice message ${durationSeconds}s',
      type: MessageType.voice,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
      metadata: {
        'audioUrl': audioUrl,
        'durationSeconds': durationSeconds,
        'waveformData': waveformData ?? [],
      },
    );
  }

  factory Message.video({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String videoUrl,
    String? thumbnailUrl,
    required int durationSeconds,
    int? width,
    int? height,
    int? fileSizeBytes,
    String? caption,
    String? replyToMessageId,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: caption ?? 'Video message ${durationSeconds}s',
      type: MessageType.video,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
      metadata: {
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
        'width': width,
        'height': height,
        'fileSizeBytes': fileSizeBytes ?? 0,
      },
    );
  }

  factory Message.file({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String fileName,
    required String fileUrl,
    required String fileType,
    required int fileSizeBytes,
    String? mimeType,
    String? thumbnailUrl,
    String? caption,
    String? replyToMessageId,
  }) {
    return Message(
      messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: caption ?? 'File: $fileName',
      type: MessageType.file,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      replyToMessageId: replyToMessageId,
      metadata: {
        'fileName': fileName,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'fileSizeBytes': fileSizeBytes,
        'mimeType': mimeType,
        'thumbnailUrl': thumbnailUrl,
      },
    );
  }

  Message copyWith({
    MessageStatus? status,
    DateTime? updatedAt,
    List<MessageReaction>? reactions,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    List<String>? readBy,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: content,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      readBy: readBy ?? this.readBy,
    );
  }

  Message markAsRead(String userId) {
    final updatedReadBy = List<String>.from(readBy);
    if (!updatedReadBy.contains(userId)) {
      updatedReadBy.add(userId);
    }
    return copyWith(
      readBy: updatedReadBy,
      status: MessageStatus.read,
    );
  }

  Message addReaction(String userId, String emoji) {
    final updatedReactions = List<MessageReaction>.from(reactions);
    
    // Remove existing reaction from this user
    updatedReactions.removeWhere((r) => r.userId == userId);
    
    // Add new reaction
    updatedReactions.add(MessageReaction(
      userId: userId,
      emoji: emoji,
      createdAt: DateTime.now(),
    ));
    
    return copyWith(reactions: updatedReactions);
  }

  Message removeReaction(String userId) {
    final updatedReactions = List<MessageReaction>.from(reactions);
    updatedReactions.removeWhere((r) => r.userId == userId);
    return copyWith(reactions: updatedReactions);
  }

  // Helper getters
  bool get isRead => status == MessageStatus.read;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isSent => status == MessageStatus.sent;
  bool get isSystemMessage => type == MessageType.system;
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyToMessageId != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  List<Object?> get props => [
        messageId,
        chatId,
        senderId,
        senderName,
        senderImageUrl,
        content,
        type,
        createdAt,
        updatedAt,
        status,
        replyToMessageId,
        reactions,
        metadata,
        isDeleted,
        readBy,
      ];

  // JSON serialization
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String?,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      replyToMessageId: json['replyToMessageId'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isDeleted: json['isDeleted'] as bool? ?? false,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'replyToMessageId': replyToMessageId,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'metadata': metadata,
      'isDeleted': isDeleted,
      'readBy': readBy,
    };
  }
}

@HiveType(typeId: 18)
enum MessageType {
  @HiveField(0)
  text,
  
  @HiveField(1)
  image,
  
  @HiveField(2)
  location,
  
  @HiveField(3)
  system,
  
  @HiveField(4)
  gameInvite,
  
  @HiveField(5)
  venueShare,
  
  @HiveField(6)
  voice,
  
  @HiveField(7)
  video,
  
  @HiveField(8)
  file,
}

@HiveType(typeId: 19)
enum MessageStatus {
  @HiveField(0)
  sending,
  
  @HiveField(1)
  sent,
  
  @HiveField(2)
  delivered,
  
  @HiveField(3)
  read,
  
  @HiveField(4)
  failed,
}

@HiveType(typeId: 20)
class MessageReaction extends Equatable {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String emoji;
  
  @HiveField(2)
  final DateTime createdAt;

  const MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  @override
  List<Object> get props => [userId, emoji, createdAt];

  // JSON serialization
  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 