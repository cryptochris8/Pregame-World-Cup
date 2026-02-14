import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/social_connection.dart';
import '../../domain/services/social_service.dart';
import '../widgets/friend_item_widget.dart';
import '../widgets/friend_request_item_widget.dart';
import 'user_search_screen.dart';
import 'user_profile_screen.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../messaging/domain/services/messaging_service.dart';
import '../../../messaging/presentation/screens/chat_screen.dart';

class EnhancedFriendsListScreen extends StatefulWidget {
  const EnhancedFriendsListScreen({super.key});

  @override
  State<EnhancedFriendsListScreen> createState() => _EnhancedFriendsListScreenState();
}

class _EnhancedFriendsListScreenState extends State<EnhancedFriendsListScreen>
    with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserProfile> _friends = [];
  List<UserProfile> _filteredFriends = [];
  List<SocialConnection> _pendingRequests = [];
  List<SocialConnection> _sentRequests = [];
  Map<String, SocialConnection> _friendConnectionMap = {};
  
  bool _isLoading = true;
  String _searchQuery = '';
  FriendFilter _currentFilter = FriendFilter.all;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAndLoadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      // Initializing service
      await _socialService.initialize();
      // Service initialized
      
      await _loadAllData();
    } catch (e) {
      // Error handled silently
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // No current user
      setState(() => _isLoading = false);
      return;
    }

    // Loading friends data
    setState(() => _isLoading = true);

    try {
      // Load friends
      final connections = await _socialService.getUserConnections(currentUser.uid);
      final friendConnections = connections.where((c) => 
          c.status == ConnectionStatus.accepted && 
          c.type == ConnectionType.friend
      ).toList();

      // Found friend connections

      final friendProfiles = <UserProfile>[];
      final connectionMap = <String, SocialConnection>{};
      for (final connection in friendConnections) {
        final friendUserId = connection.fromUserId == currentUser.uid
            ? connection.toUserId
            : connection.fromUserId;
        try {
          final profile = await _socialService.getUserProfile(friendUserId);
          if (profile != null) {
            friendProfiles.add(profile);
            connectionMap[profile.userId] = connection;
          }
        } catch (e) {
          // Error loading profile handled silently
        }
      }

      // Load pending requests (received)
      final pendingRequests = connections.where((c) => 
          c.status == ConnectionStatus.pending && 
          c.toUserId == currentUser.uid
      ).toList();

      // Load sent requests
      final sentRequests = connections.where((c) => 
          c.status == ConnectionStatus.pending && 
          c.fromUserId == currentUser.uid
      ).toList();

      setState(() {
        _friends = friendProfiles;
        _filteredFriends = friendProfiles;
        _pendingRequests = pendingRequests;
        _sentRequests = sentRequests;
        _friendConnectionMap = connectionMap;
        _isLoading = false;
      });

      _applyFilter();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
    _applyFilter();
  }

  void _applyFilter() {
    List<UserProfile> filtered = List.from(_friends);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((friend) {
        return friend.displayName.toLowerCase().contains(_searchQuery) ||
               (friend.bio?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply category filter
    switch (_currentFilter) {
      case FriendFilter.all:
        // No additional filtering
        break;
      case FriendFilter.online:
        filtered = filtered.where((friend) => 
            friend.shouldShowOnlineStatus && friend.isOnline).toList();
        break;
      case FriendFilter.recentlyActive:
        filtered = filtered.where((friend) => 
            friend.shouldShowOnlineStatus && 
            (friend.isOnline || friend.isRecentlyActive)).toList();
        break;
      case FriendFilter.mutual:
        filtered = filtered.where((friend) {
          final connection = _friendConnectionMap[friend.userId];
          return connection != null && connection.mutualFriends.isNotEmpty;
        }).toList();
        break;
    }

    setState(() {
      _filteredFriends = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              children: [
                TeamLogoHelper.getPregameLogo(height: 32),
                const SizedBox(width: 8),
                const Text(
                  'Friends',
                  style: TextStyle(
                        fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
                        letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
              onPressed: _showFilterMenu,
              icon: Icon(
                Icons.filter_list,
                        color: _currentFilter != FriendFilter.all ? AppTheme.primaryOrange : Colors.white,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
              ),
            ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
              onPressed: _showAddFriendDialog,
                    icon: const Icon(Icons.person_add, color: Colors.white),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                    ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
                indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Friends'),
                    if (_friends.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryVibrantOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _friends.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Requests'),
                    if (_pendingRequests.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryVibrantOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _pendingRequests.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Sent'),
            ],
          ),
        ),
        body: Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                child: TextField(
                  controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                          fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading ? _buildLoadingState() : _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading friends...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFriendsList(),
        _buildPendingRequestsList(),
        _buildSentRequestsList(),
      ],
    );
  }

  Widget _buildFriendsList() {
    if (_filteredFriends.isEmpty) {
      return _buildEmptyFriendsState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF8B4513),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = _filteredFriends[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FriendItemWidget(
              friend: friend,
              onTap: () => _navigateToProfile(friend.userId),
              onMessage: () => _startMessage(friend),
              onRemove: () => _removeFriend(friend),
              onBlock: () => _blockUser(friend),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestsList() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyRequestsState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF8B4513),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FriendRequestItemWidget(
              request: request,
              onAccept: () => _acceptFriendRequest(request),
              onDecline: () => _declineFriendRequest(request),
              onViewProfile: () => _navigateToProfile(request.fromUserId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsList() {
    if (_sentRequests.isEmpty) {
      return _buildEmptySentRequestsState();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: const Color(0xFF8B4513),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FriendRequestItemWidget(
              request: request,
              isOutgoing: true,
              onCancel: () => _cancelFriendRequest(request),
              onViewProfile: () => _navigateToProfile(request.toUserId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFriendsState() {
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
            _searchQuery.isNotEmpty ? 'No friends found' : 'No friends yet',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms'
                : 'Start connecting with other sports fans!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Friends'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyRequestsState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'No friend requests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When people send you friend requests,\nthey\'ll appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySentRequestsState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.send_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'No sent requests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Friend requests you send\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
                groupValue: _currentFilter,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value!;
                  });
                  _applyFilter();
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF8B4513),
              ),
              title: Text(_getFilterTitle(filter)),
              subtitle: Text(_getFilterDescription(filter)),
            )),
          ],
        ),
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

  void _showAddFriendDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    ).then((_) {
      // Refresh the friends list when returning from search
      _loadAllData();
    });
  }

  Future<void> _acceptFriendRequest(SocialConnection request) async {
    try {
      await _socialService.acceptFriendRequest(request.connectionId);
      await _loadAllData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _declineFriendRequest(SocialConnection request) async {
    try {
      await _socialService.declineFriendRequest(request.connectionId);
      await _loadAllData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      // Error handled silently
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelFriendRequest(SocialConnection request) async {
    try {
      await _socialService.cancelFriendRequest(request.connectionId);
      await _loadAllData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request cancelled'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      // Error handled silently
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFriend(UserProfile friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove ${friend.displayName} from your friends?'),
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

    if (confirm == true) {
      try {
        final currentUser = await _socialService.getCurrentUserProfile();
        if (currentUser != null) {
          await _socialService.removeFriend(currentUser.userId, friend.userId);
          await _loadAllData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend.displayName} removed from friends'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Error handled silently
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove ${friend.displayName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _blockUser(UserProfile friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${friend.displayName}? They will be removed from your friends and won\'t be able to contact you.'),
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

    if (confirm == true) {
      try {
        final currentUser = await _socialService.getCurrentUserProfile();
        if (currentUser != null) {
          await _socialService.blockUser(currentUser.userId, friend.userId);
          await _loadAllData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend.displayName} has been blocked'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Error handled silently
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to block ${friend.displayName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  Future<void> _startMessage(UserProfile friend) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final messagingService = MessagingService();
      final chat = await messagingService.createDirectChat(
        friend.userId,
        friend.displayName,
      );

      if (chat != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to start chat. User may be blocked.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum FriendFilter {
  all,
  online,
  recentlyActive,
  mutual,
} 