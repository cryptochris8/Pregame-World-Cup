import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Helper class providing confirmation dialogs for friend actions.
class FriendActionDialogs {
  FriendActionDialogs._();

  /// Show a confirmation dialog for removing a friend.
  /// Returns true if the user confirmed, false or null otherwise.
  static Future<bool?> showRemoveConfirmation(
    BuildContext context, {
    required String displayName,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(l10n.removeFriendConfirm(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog for blocking a user.
  /// Returns true if the user confirmed, false or null otherwise.
  static Future<bool?> showBlockConfirmation(
    BuildContext context, {
    required String displayName,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockUser),
        content: Text(l10n.blockUserConfirm(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
  }
}
