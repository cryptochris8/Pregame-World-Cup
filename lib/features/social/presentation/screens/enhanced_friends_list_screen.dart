import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/social_connection.dart';
import '../../domain/services/social_service.dart';
import '../widgets/friend_item_widget.dart';
import '../widgets/friend_request_item_widget.dart';
import '../widgets/friends_empty_states.dart';
import '../widgets/friends_filter_bottom_sheet.dart';
import '../widgets/friend_action_dialogs.dart';
import '../widgets/friends_search_bar.dart';
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
      await _socialService.initialize();
      await _loadAllData();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final connections = await _socialService.getUserConnections(currentUser.uid);
      final friendConnections = connections.where((c) =>
          c.status == ConnectionStatus.accepted &&
          c.type == ConnectionType.friend
      ).toList();

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

      final pendingRequests = connections.where((c) =>
          c.status == ConnectionStatus.pending &&
          c.toUserId == currentUser.uid
      ).toList();

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

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((friend) {
        return friend.displayName.toLowerCase().contains(_searchQuery) ||
               (friend.bio?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    switch (_currentFilter) {
      case FriendFilter.all:
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
          if (connection == null) return false;
          final mutualFriends = connection.metadata['mutualFriends'] as List?;
          return mutualFriends != null && mutualFriends.isNotEmpty;
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
              _buildBadgedTab('Friends', _friends.length),
              _buildBadgedTab('Requests', _pendingRequests.length),
              const Tab(text: 'Sent'),
            ],
          ),
        ),
        body: Column(
            children: [
              // Search bar
              FriendsSearchBar(
                controller: _searchController,
                hasQuery: _searchQuery.isNotEmpty,
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

  Tab _buildBadgedTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryVibrantOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
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
      return EmptyFriendsState(
        searchQuery: _searchQuery,
        onAddFriends: _showAddFriendDialog,
      );
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
      return const EmptyRequestsState();
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
      return const EmptySentRequestsState();
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

  void _showFilterMenu() {
    FriendsFilterBottomSheet.show(
      context: context,
      currentFilter: _currentFilter,
      onFilterChanged: (filter) {
        setState(() {
          _currentFilter = filter;
        });
        _applyFilter();
      },
    );
  }

  void _showAddFriendDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    ).then((_) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel friend request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFriend(UserProfile friend) async {
    final confirm = await FriendActionDialogs.showRemoveConfirmation(
      context,
      displayName: friend.displayName,
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
    final confirm = await FriendActionDialogs.showBlockConfirmation(
      context,
      displayName: friend.displayName,
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
