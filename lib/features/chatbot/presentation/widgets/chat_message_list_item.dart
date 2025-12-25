import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart'; // Adjust import path as needed

class ChatMessageListItem extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageListItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUserMessage = message.type == ChatMessageType.user;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Align(
        alignment: (isUserMessage ? Alignment.centerRight : Alignment.centerLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (isUserMessage ? Colors.blue[200] : Colors.grey[300]),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
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