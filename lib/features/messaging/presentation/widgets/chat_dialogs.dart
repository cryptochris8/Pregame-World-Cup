import 'package:flutter/material.dart';

/// Static helper class providing reusable chat-related dialogs.
class ChatDialogs {
  ChatDialogs._();

  /// Shows a dialog to select mute duration for a chat.
  static Future<Duration?> showMuteDurationDialog(BuildContext context) {
    return showDialog<Duration?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text('Mute notifications',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  const Text('1 hour', style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(hours: 1)),
            ),
            ListTile(
              title:
                  const Text('8 hours', style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(hours: 8)),
            ),
            ListTile(
              title:
                  const Text('1 day', style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 1)),
            ),
            ListTile(
              title:
                  const Text('1 week', style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 7)),
            ),
            ListTile(
              title:
                  const Text('Forever', style: TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 36500)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for clearing chat history.
  static Future<bool?> showClearHistoryDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Clear Chat History',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for leaving a chat.
  static Future<bool?> showLeaveChatDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Leave Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to leave this chat?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for unblocking a user.
  static Future<bool?> showUnblockDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Unblock User',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to unblock this user? They will be able to message you again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Unblock',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
