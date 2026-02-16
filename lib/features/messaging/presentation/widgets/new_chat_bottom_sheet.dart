import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/services/messaging_service.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../social/domain/services/social_service.dart';
import '../screens/chat_screen.dart';
import 'direct_chat_tab.dart';
import 'chat_member_selector.dart';

class NewChatBottomSheet extends StatefulWidget {
  final Function(Chat) onDirectChatCreated;
  final Function(Chat) onGroupChatCreated;
  final Function(Chat) onTeamChatCreated;

  const NewChatBottomSheet({
    super.key,
    required this.onDirectChatCreated,
    required this.onGroupChatCreated,
    required this.onTeamChatCreated,
  });

  @override
  State<NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<NewChatBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessagingService _messagingService = MessagingService();
  final SocialService _socialService = SocialService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  List<UserProfile> _friends = [];
  List<UserProfile> _filteredFriends = [];
  final Set<String> _selectedFriendIds = {};
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriends();
    _searchController.addListener(() {
      setState(() {
        _filteredFriends = _filterFriends(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _socialService.getUserFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
          _filteredFriends = friends;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load friends: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<UserProfile> _filterFriends(String query) {
    if (query.isEmpty) return _friends;

    return _friends.where((friend) {
      final nameMatch = friend.displayName.toLowerCase().contains(query.toLowerCase());
      final emailMatch = friend.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return nameMatch || emailMatch;
    }).toList();
  }

  void _handleFriendToggled(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  void _handleFriendRemoved(String friendId) {
    setState(() {
      _selectedFriendIds.remove(friendId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.brown[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text(
                  'New Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.brown[800],
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange[300],
              labelColor: Colors.orange[300],
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Direct'),
                Tab(text: 'Group'),
                Tab(text: 'Team'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DirectChatTab(
                  searchController: _searchController,
                  isLoading: _isLoading,
                  friends: _friends,
                  filteredFriends: _filteredFriends,
                  onFriendSelected: _createDirectChat,
                ),
                ChatMemberSelector(
                  nameController: _groupNameController,
                  descriptionController: _groupDescriptionController,
                  searchController: _searchController,
                  nameLabel: 'Group Name',
                  descriptionLabel: 'Description (optional)',
                  searchHint: 'Search friends to add...',
                  createButtonLabel: 'Create Group',
                  selectedFriendIds: _selectedFriendIds,
                  friends: _friends,
                  filteredFriends: _filteredFriends,
                  isLoading: _isLoading,
                  isCreating: _isCreating,
                  onCreatePressed: _groupNameController.text.isNotEmpty &&
                                   _selectedFriendIds.isNotEmpty &&
                                   !_isCreating
                      ? _createGroupChat
                      : null,
                  onFriendToggled: _handleFriendToggled,
                  onFriendRemoved: _handleFriendRemoved,
                ),
                ChatMemberSelector(
                  nameController: _groupNameController,
                  descriptionController: _groupDescriptionController,
                  searchController: _searchController,
                  nameLabel: 'Team Name',
                  descriptionLabel: 'Team Description (optional)',
                  searchHint: 'Search friends to add to team...',
                  createButtonLabel: 'Create Team',
                  selectedFriendIds: _selectedFriendIds,
                  friends: _friends,
                  filteredFriends: _filteredFriends,
                  isLoading: _isLoading,
                  isCreating: _isCreating,
                  onCreatePressed: _groupNameController.text.isNotEmpty &&
                                   _selectedFriendIds.isNotEmpty &&
                                   !_isCreating
                      ? _createTeamChat
                      : null,
                  onFriendToggled: _handleFriendToggled,
                  onFriendRemoved: _handleFriendRemoved,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createDirectChat(UserProfile friend) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final chat = Chat.direct(
        currentUserId: currentUser.uid,
        participantUserId: friend.userId,
      );

      await _messagingService.createChat(chat);

      if (mounted) {
        Navigator.pop(context);
        widget.onDirectChatCreated(chat);

        // Navigate to the chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create direct chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _createGroupChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final chat = Chat.group(
        name: _groupNameController.text.trim(),
        creatorId: currentUser.uid,
        participantIds: _selectedFriendIds.toList(),
        description: _groupDescriptionController.text.trim().isNotEmpty
            ? _groupDescriptionController.text.trim()
            : null,
      );

      await _messagingService.createChat(chat);

      if (mounted) {
        Navigator.pop(context);
        widget.onGroupChatCreated(chat);

        // Navigate to the chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _createTeamChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final chat = Chat.team(
        teamName: _groupNameController.text.trim(),
        creatorId: currentUser.uid,
        memberIds: _selectedFriendIds.toList(),
        description: _groupDescriptionController.text.trim().isNotEmpty
            ? _groupDescriptionController.text.trim()
            : null,
      );

      await _messagingService.createChat(chat);

      if (mounted) {
        Navigator.pop(context);
        widget.onTeamChatCreated(chat);

        // Navigate to the chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create team chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
