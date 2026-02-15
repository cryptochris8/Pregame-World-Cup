import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/services/messaging_service.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../social/domain/services/social_service.dart';
import '../screens/chat_screen.dart';

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
                _buildDirectChatTab(),
                _buildGroupChatTab(),
                _buildTeamChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectChatTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : _filteredFriends.isEmpty
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
                            _friends.isEmpty 
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
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = _filteredFriends[index];
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
                          onTap: () => _createDirectChat(friend),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildGroupChatTab() {
    return Column(
      children: [
        // Group info form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _groupNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Group Name',
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
                controller: _groupDescriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
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
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search friends to add...',
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
        
        // Selected friends chips
        if (_selectedFriendIds.isNotEmpty) ...[
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFriendIds.length,
              itemBuilder: (context, index) {
                final friendId = _selectedFriendIds.elementAt(index);
                final friend = _friends.firstWhere((f) => f.userId == friendId);
                
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
                    onDeleted: () {
                      setState(() {
                        _selectedFriendIds.remove(friendId);
                      });
                    },
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
            onPressed: _groupNameController.text.isNotEmpty && 
                       _selectedFriendIds.isNotEmpty && 
                       !_isCreating
                ? _createGroupChat
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              foregroundColor: Colors.brown[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                  )
                : const Text(
                    'Create Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamChatTab() {
    return Column(
      children: [
        // Team info form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _groupNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Team Name',
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
                controller: _groupDescriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Team Description (optional)',
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
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search friends to add to team...',
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
        if (_selectedFriendIds.isNotEmpty) ...[
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFriendIds.length,
              itemBuilder: (context, index) {
                final friendId = _selectedFriendIds.elementAt(index);
                final friend = _friends.firstWhere((f) => f.userId == friendId);
                
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
                    onDeleted: () {
                      setState(() {
                        _selectedFriendIds.remove(friendId);
                      });
                    },
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
            onPressed: _groupNameController.text.isNotEmpty && 
                       _selectedFriendIds.isNotEmpty && 
                       !_isCreating
                ? _createTeamChat
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              foregroundColor: Colors.brown[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                    ),
                  )
                : const Text(
                    'Create Team',
                    style: TextStyle(
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
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          )
        : _filteredFriends.isEmpty
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
                      _friends.isEmpty 
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
                itemCount: _filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = _filteredFriends[index];
                  final isSelected = _selectedFriendIds.contains(friend.userId);
                  
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
                        setState(() {
                          if (value == true) {
                            _selectedFriendIds.add(friend.userId);
                          } else {
                            _selectedFriendIds.remove(friend.userId);
                          }
                        });
                      },
                      activeColor: Colors.orange[300],
                      checkColor: Colors.brown[800],
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedFriendIds.remove(friend.userId);
                        } else {
                          _selectedFriendIds.add(friend.userId);
                        }
                      });
                    },
                  );
                },
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