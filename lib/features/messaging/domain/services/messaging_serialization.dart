import '../entities/message.dart';
import '../entities/chat.dart';

// Extension methods for JSON conversion
extension ChatJson on Chat {
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type.name,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'participantIds': participantIds,
      'adminIds': adminIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'settings': settings,
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  static Chat fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      type: ChatType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastMessageId: json['lastMessageId'],
      lastMessageContent: json['lastMessageContent'],
      lastMessageTime: json['lastMessageTime'] != null ? DateTime.parse(json['lastMessageTime']) : null,
      lastMessageSenderId: json['lastMessageSenderId'],
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'],
    );
  }
}

extension MessageJson on Message {
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'replyToMessageId': replyToMessageId,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'metadata': metadata,
      'isDeleted': isDeleted,
      'readBy': readBy,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImageUrl: json['senderImageUrl'],
      content: json['content'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: MessageStatus.values.firstWhere((e) => e.name == json['status']),
      replyToMessageId: json['replyToMessageId'],
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromJson(r))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}

extension MessageReactionJson on MessageReaction {
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MessageReaction fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
