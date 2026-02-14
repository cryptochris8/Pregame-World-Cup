import 'package:flutter/material.dart';
import '../../domain/services/messaging_service.dart';
import '../../../social/domain/services/social_service.dart';

/// Bottom sheet for adding members to a group chat.
/// Shows a list of friends who are not already in the chat.
class AddMemberBottomSheet extends StatefulWidget {
  final String chatId;
  final List<String> existingMemberIds;
  final MessagingService messagingService;

  const AddMemberBottomSheet({
    super.key,
    required this.chatId,
    required this.existingMemberIds,
    required this.messagingService,
  });

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
  final SocialService _socialService = SocialService();
  List<dynamic> _friends = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _socialService.getUserFriends();
      // Filter out existing members
      final availableFriends = friends
          .where((f) => !widget.existingMemberIds.contains(f.userId))
          .toList();

      if (mounted) {
        setState(() {
          _friends = availableFriends;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addMember(dynamic friend) async {
    setState(() {
      _isAdding = true;
    });

    final success = await widget.messagingService.addMemberToChat(
      widget.chatId,
      friend.userId,
      friend.displayName,
    );

    if (mounted) {
      setState(() {
        _isAdding = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.displayName} added to chat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${friend.displayName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Add Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a friend to add to this chat',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Colors.orange),
                  )
                : _friends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off,
                                size: 64,
                                color: Colors.white.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'No friends to add',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All your friends are already in this chat',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[300],
                              backgroundImage:
                                  friend.profileImageUrl != null
                                      ? NetworkImage(
                                          friend.profileImageUrl!)
                                      : null,
                              child: friend.profileImageUrl == null
                                  ? Text(
                                      friend.displayName.isNotEmpty
                                          ? friend.displayName[0]
                                              .toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          color: Colors.brown[800]),
                                    )
                                  : null,
                            ),
                            title: Text(
                              friend.displayName,
                              style:
                                  const TextStyle(color: Colors.white),
                            ),
                            trailing: _isAdding
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.orange),
                                    onPressed: () =>
                                        _addMember(friend),
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
