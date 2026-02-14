import 'package:flutter/material.dart';

/// Enum for friend list filtering options.
/// Note: This was originally defined in enhanced_friends_list_screen.dart.
/// It's re-exported from here for use in the filter bottom sheet.
enum FriendFilter {
  all,
  online,
  recentlyActive,
  mutual,
}

/// Bottom sheet for selecting friend list filter options.
class FriendsFilterBottomSheet extends StatelessWidget {
  final FriendFilter currentFilter;
  final ValueChanged<FriendFilter> onFilterChanged;

  const FriendsFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  /// Show the filter bottom sheet.
  static void show({
    required BuildContext context,
    required FriendFilter currentFilter,
    required ValueChanged<FriendFilter> onFilterChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FriendsFilterBottomSheet(
        currentFilter: currentFilter,
        onFilterChanged: onFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Friends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...FriendFilter.values.map((filter) => ListTile(
            leading: Radio<FriendFilter>(
              value: filter,
              groupValue: currentFilter,
              onChanged: (value) {
                onFilterChanged(value!);
                Navigator.pop(context);
              },
              activeColor: const Color(0xFF8B4513),
            ),
            title: Text(_getFilterTitle(filter)),
            subtitle: Text(_getFilterDescription(filter)),
          )),
        ],
      ),
    );
  }

  String _getFilterTitle(FriendFilter filter) {
    switch (filter) {
      case FriendFilter.all:
        return 'All Friends';
      case FriendFilter.online:
        return 'Online';
      case FriendFilter.recentlyActive:
        return 'Recently Active';
      case FriendFilter.mutual:
        return 'Mutual Friends';
    }
  }

  String _getFilterDescription(FriendFilter filter) {
    switch (filter) {
      case FriendFilter.all:
        return 'Show all friends';
      case FriendFilter.online:
        return 'Show only online friends';
      case FriendFilter.recentlyActive:
        return 'Show friends active in the last week';
      case FriendFilter.mutual:
        return 'Show friends with mutual connections';
    }
  }
}
