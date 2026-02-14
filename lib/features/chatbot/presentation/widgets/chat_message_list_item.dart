import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageListItem extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageListItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.type == ChatMessageType.user;
    final isThinking = message.type == ChatMessageType.thinking;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Align(
        alignment: (isUserMessage ? Alignment.centerRight : Alignment.centerLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isUserMessage
                ? Colors.blue[200]
                : isThinking
                    ? Colors.grey[200]
                    : Colors.grey[300],
          ),
          padding: const EdgeInsets.all(16),
          child: isThinking
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              : Text(
                  message.text,
                  style: TextStyle(
                    color: isUserMessage ? Colors.black87 : Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
