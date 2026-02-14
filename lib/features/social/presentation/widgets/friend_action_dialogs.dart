import 'package:flutter/material.dart';

/// Helper class providing confirmation dialogs for friend actions.
class FriendActionDialogs {
  FriendActionDialogs._();

  /// Show a confirmation dialog for removing a friend.
  /// Returns true if the user confirmed, false or null otherwise.
  static Future<bool?> showRemoveConfirmation(
    BuildContext context, {
    required String displayName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $displayName from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block $displayName? They will be removed from your friends and won\'t be able to contact you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
