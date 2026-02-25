import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../screens/chat_screen.dart';
import 'copa_avatar.dart';

/// Floating action button that opens the chatbot in a bottom sheet.
class ChatbotFab extends StatelessWidget {
  const ChatbotFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chatbot_fab',
      onPressed: () => _openChatSheet(context),
      backgroundColor: AppTheme.accentGold,
      child: const CopaAvatar(size: 28),
    );
  }

  void _openChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ChatScreen(isBottomSheet: true),
        ),
      ),
    );
  }
}
