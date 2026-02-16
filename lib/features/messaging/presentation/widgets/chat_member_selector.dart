import 'package:flutter/material.dart';
import '../../../social/domain/entities/user_profile.dart';

/// Reusable widget for selecting members for group or team chats.
/// Includes name/description fields, search, selected member chips,
/// and a friend selection list with checkboxes.
class ChatMemberSelector extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController searchController;
  final String nameLabel;
  final String descriptionLabel;
  final String searchHint;
  final String createButtonLabel;
  final Set<String> selectedFriendIds;
  final List<UserProfile> friends;
  final List<UserProfile> filteredFriends;
  final bool isLoading;
  final bool isCreating;
  final VoidCallback? onCreatePressed;
  final ValueChanged<String> onFriendToggled;
  final ValueChanged<String> onFriendRemoved;

  const ChatMemberSelector({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.searchController,
    required this.nameLabel,
    required this.descriptionLabel,
    required this.searchHint,
    required this.createButtonLabel,
    required this.selectedFriendIds,
    required this.friends,
    required this.filteredFriends,
    required this.isLoading,
    required this.isCreating,
    this.onCreatePressed,
    required this.onFriendToggled,
    required this.onFriendRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Form fields
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: nameLabel,
                  labelStyle: TextStyle(color: Colors.orange[300]),
                  filled: true,
                  fillColor: Colors.brown[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: descriptionLabel,
                  labelStyle: TextStyle(color: Colors.orange[300]),
                  filled: true,
                  fillColor: Colors.brown[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: searchHint,
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
            ],
          ),
        ),

        // Selected members chips
        if (selectedFriendIds.isNotEmpty) ...[
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFriendIds.length,
              itemBuilder: (context, index) {
                final friendId = selectedFriendIds.elementAt(index);
                final friend = friends.firstWhere((f) => f.userId == friendId);

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    backgroundColor: Colors.orange[300],
                    deleteIconColor: Colors.brown[800],
                    avatar: CircleAvatar(
                      backgroundColor: Colors.brown[800],
                      child: Text(
                        friend.displayName.isNotEmpty ? friend.displayName[0] : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    label: Text(
                      friend.displayName,
                      style: TextStyle(color: Colors.brown[800]),
                    ),
                    onDeleted: () => onFriendRemoved(friendId),
                  ),
                );
              },
            ),
          ),
        ],

        // Friends selection list
        Expanded(
          child: _buildFriendsSelectionList(),
        ),

        // Create button
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCreatePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              foregroundColor: Colors.brown[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                  )
                : Text(
                    createButtonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsSelectionList() {
    return isLoading
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
                  final isSelected = selectedFriendIds.contains(friend.userId);

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
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        onFriendToggled(friend.userId);
                      },
                      activeColor: Colors.orange[300],
                      checkColor: Colors.brown[800],
                    ),
                    onTap: () {
                      onFriendToggled(friend.userId);
                    },
                  );
                },
              );
  }
}
