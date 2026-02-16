import 'package:flutter/material.dart';
import '../../../social/domain/entities/user_profile.dart';

/// Tab for searching and selecting a friend to start a direct chat
class DirectChatTab extends StatelessWidget {
  final TextEditingController searchController;
  final bool isLoading;
  final List<UserProfile> friends;
  final List<UserProfile> filteredFriends;
  final ValueChanged<UserProfile> onFriendSelected;

  const DirectChatTab({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.friends,
    required this.filteredFriends,
    required this.onFriendSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search friends...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.orange[300]),
              filled: true,
              fillColor: Colors.brown[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Friends list
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : filteredFriends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.white.withValues(alpha:0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            friends.isEmpty
                                ? 'No friends yet'
                                : 'No friends found',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[300],
                            backgroundImage: friend.profileImageUrl != null
                                ? NetworkImage(friend.profileImageUrl!)
                                : null,
                            child: friend.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    color: Colors.brown[800],
                                  )
                                : null,
                          ),
                          title: Text(
                            friend.displayName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            friend.email ?? 'No email',
                            style: TextStyle(color: Colors.white.withValues(alpha:0.7)),
                          ),
                          onTap: () => onFriendSelected(friend),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
