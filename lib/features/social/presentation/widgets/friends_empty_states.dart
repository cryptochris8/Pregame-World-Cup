import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Empty state widget displayed when the user has no friends or no search results.
class EmptyFriendsState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onAddFriends;

  const EmptyFriendsState({
    super.key,
    required this.searchQuery,
    required this.onAddFriends,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty ? l10n.noFriendsFound : l10n.noFriendsYet,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? l10n.tryAdjustingSearch
                : l10n.startConnectingWithFans,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddFriends,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFriends),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget displayed when there are no pending friend requests.
class EmptyRequestsState extends StatelessWidget {
  const EmptyRequestsState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noFriendRequests,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.friendRequestsAppearHere,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget displayed when the user has no sent friend requests.
class EmptySentRequestsState extends StatelessWidget {
  const EmptySentRequestsState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.send_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noSentRequests,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sentRequestsAppearHere,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
