import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/typing_indicator.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/voice_message.dart';

// Sentinel value to distinguish between "not provided" and "explicitly null"
final DateTime _defaultLastMessageTime = DateTime(2026, 6, 15, 14, 30);
const Object _useDefault = Object();

class MessagingTestFactory {
  static Message createTextMessage({
    String messageId = 'msg_001',
    String chatId = 'chat_001',
    String senderId = 'user_001',
    String senderName = 'John Doe',
    String? senderImageUrl,
    String content = 'Hello, World!',
    MessageStatus status = MessageStatus.sent,
    String? replyToMessageId,
    List<MessageReaction> reactions = const [],
    bool isDeleted = false,
    List<String> readBy = const [],
    DateTime? createdAt,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImageUrl: senderImageUrl,
      content: content,
      type: MessageType.text,
      createdAt: createdAt ?? DateTime(2026, 6, 15, 14, 30),
      status: status,
      replyToMessageId: replyToMessageId,
      reactions: reactions,
      isDeleted: isDeleted,
      readBy: readBy,
    );
  }

  static Message createImageMessage({
    String messageId = 'msg_img_001',
    String chatId = 'chat_001',
    String senderId = 'user_001',
    String senderName = 'John Doe',
    String content = '',
    String imageUrl = 'https://example.com/image.jpg',
    DateTime? createdAt,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: MessageType.image,
      createdAt: createdAt ?? DateTime(2026, 6, 15, 14, 30),
      status: MessageStatus.sent,
      metadata: {'imageUrl': imageUrl},
    );
  }

  static Message createSystemMessage({
    String messageId = 'msg_sys_001',
    String chatId = 'chat_001',
    String content = 'User joined the chat',
    DateTime? createdAt,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: 'system',
      senderName: 'System',
      content: content,
      type: MessageType.system,
      createdAt: createdAt ?? DateTime(2026, 6, 15, 14, 30),
      status: MessageStatus.delivered,
    );
  }

  static Message createVoiceMessage({
    String messageId = 'msg_voice_001',
    String chatId = 'chat_001',
    String senderId = 'user_001',
    String senderName = 'John Doe',
    String audioUrl = 'https://example.com/audio.m4a',
    int durationSeconds = 15,
    DateTime? createdAt,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: 'Voice message ${durationSeconds}s',
      type: MessageType.voice,
      createdAt: createdAt ?? DateTime(2026, 6, 15, 14, 30),
      status: MessageStatus.sent,
      metadata: {
        'audioUrl': audioUrl,
        'durationSeconds': durationSeconds,
        'waveformData': <double>[],
      },
    );
  }

  static Chat createDirectChat({
    String chatId = 'chat_direct_001',
    List<String> participantIds = const ['user_001', 'user_002'],
    String? name = 'John & Jane',
    String? lastMessageContent = 'Hey there!',
    Object? lastMessageTime = _useDefault,
    DateTime? createdAt,
    Map<String, int> unreadCounts = const {},
  }) {
    return Chat(
      chatId: chatId,
      type: ChatType.direct,
      participantIds: participantIds,
      adminIds: const [],
      name: name,
      createdAt: createdAt ?? DateTime(2026, 6, 10),
      lastMessageContent: lastMessageContent,
      lastMessageTime: lastMessageTime == _useDefault ? _defaultLastMessageTime : lastMessageTime as DateTime?,
      unreadCounts: unreadCounts,
    );
  }

  static Chat createGroupChat({
    String chatId = 'chat_group_001',
    List<String> participantIds = const ['user_001', 'user_002', 'user_003'],
    List<String> adminIds = const ['user_001'],
    String name = 'World Cup Fans',
    String? description = 'A group for fans',
    String? lastMessageContent = 'Go team!',
    Object? lastMessageTime = _useDefault,
    DateTime? createdAt,
    Map<String, int> unreadCounts = const {},
  }) {
    return Chat(
      chatId: chatId,
      type: ChatType.group,
      participantIds: participantIds,
      adminIds: adminIds,
      name: name,
      description: description,
      createdAt: createdAt ?? DateTime(2026, 6, 10),
      lastMessageContent: lastMessageContent,
      lastMessageTime: lastMessageTime == _useDefault ? _defaultLastMessageTime : lastMessageTime as DateTime?,
      unreadCounts: unreadCounts,
    );
  }

  static TypingIndicator createTypingIndicator({
    String chatId = 'chat_001',
    String userId = 'user_002',
    String userName = 'Jane Smith',
    bool isTyping = true,
    DateTime? timestamp,
  }) {
    return TypingIndicator(
      chatId: chatId,
      userId: userId,
      userName: userName,
      timestamp: timestamp ?? DateTime.now(),
      isTyping: isTyping,
    );
  }

  static VoiceMessage createVoiceMessageEntity({
    String messageId = 'voice_001',
    String audioUrl = 'https://example.com/audio.m4a',
    int durationSeconds = 30,
    List<double> waveformData = const [0.1, 0.5, 0.8, 0.3, 0.6],
    bool isPlaying = false,
    int? currentPosition,
  }) {
    return VoiceMessage(
      messageId: messageId,
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
      waveformData: waveformData,
      isPlaying: isPlaying,
      currentPosition: currentPosition,
    );
  }
}
