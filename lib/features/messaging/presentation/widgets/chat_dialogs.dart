import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Static helper class providing reusable chat-related dialogs.
class ChatDialogs {
  ChatDialogs._();

  /// Shows a dialog to select mute duration for a chat.
  static Future<Duration?> showMuteDurationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<Duration?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(l10n.muteNotifications,
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title:
                  Text(l10n.oneHour, style: const TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(hours: 1)),
            ),
            ListTile(
              title:
                  Text(l10n.eightHours, style: const TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(hours: 8)),
            ),
            ListTile(
              title:
                  Text(l10n.oneDay, style: const TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 1)),
            ),
            ListTile(
              title:
                  Text(l10n.oneWeek, style: const TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 7)),
            ),
            ListTile(
              title:
                  Text(l10n.forever, style: const TextStyle(color: Colors.white)),
              onTap: () =>
                  Navigator.pop(context, const Duration(days: 36500)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for clearing chat history.
  static Future<bool?> showClearHistoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          l10n.clearChatHistory,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.clearChatHistoryConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.clear,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for leaving a chat.
  static Future<bool?> showLeaveChatDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          l10n.leaveChat,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.leaveChatConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.leave,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for unblocking a user.
  static Future<bool?> showUnblockDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          l10n.unblockUser,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.unblockUserConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.unblock,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
