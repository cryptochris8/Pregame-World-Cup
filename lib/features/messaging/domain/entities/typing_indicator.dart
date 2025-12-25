import 'package:equatable/equatable.dart';

class TypingIndicator extends Equatable {
  final String chatId;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final bool isTyping;

  const TypingIndicator({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTyping: json['isTyping'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      'isTyping': isTyping,
    };
  }

  TypingIndicator copyWith({
    String? chatId,
    String? userId,
    String? userName,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return TypingIndicator(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  bool get isExpired {
    return DateTime.now().difference(timestamp).inSeconds > 3;
  }

  @override
  List<Object> get props => [chatId, userId, userName, timestamp, isTyping];
} 