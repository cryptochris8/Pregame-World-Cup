import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/services/messaging_service.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_bottom_sheet.dart';
import 'chat_screen.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/animations/animated_button.dart';
import '../../../../core/animations/swipe_gestures.dart';
import '../../../../core/animations/loading_animations.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/utils/team_logo_helper.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> with TickerProviderStateMixin {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  List<Chat> _allChats = [];
  List<Chat> _filteredChats = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMessaging();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMessaging() async {
    try {
      await _messagingService.initialize();
      
      // Listen to real-time chat updates
      _messagingService.chatsStream.listen((chats) {
        if (mounted) {
          setState(() {
            _allChats = chats;
            _filterChats();
            _isLoading = false;
          });
        }
      });
      
      // Load initial chats
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final chats = await _messagingService.getUserChats(currentUser.uid);
        setState(() {
          _allChats = chats;
          _filterChats();
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error initializing messaging: $e', tag: 'ChatsListScreen');
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterChats();
    });
  }

  void _filterChats() {
    if (_searchQuery.isEmpty) {
      _filteredChats = _allChats;
    } else {
      _filteredChats = _allChats.where((chat) {
        return (chat.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (chat.lastMessageContent?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
  }

  List<Chat> get _directChats => _filteredChats.where((c) => c.isDirectMessage).toList();
  List<Chat> get _groupChats => _filteredChats.where((c) => c.isGroupChat).toList();
  List<Chat> get _teamChats => _filteredChats.where((c) => c.isTeamChat).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white,
                      ),
                    )
                  : _buildChatsList(),
            ),
          ],
        ),
      ),
      ),
      floatingActionButton: Container(
        decoration: AppTheme.buttonGradientDecoration,
        child: FloatingActionButton(
        heroTag: "chats_list_fab",
        onPressed: _showNewChatOptions,
          backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
          elevation: 0,
        child: const Icon(Icons.message, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
              child: Row(
          children: [
            TeamLogoHelper.getPregameLogo(height: 40),
            const SizedBox(width: 12),
            const Text(
              'Messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
            onPressed: _showNewChatOptions,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryVibrantOrange),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear, color: Colors.white54),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryVibrantOrange, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.secondaryEmerald, AppTheme.secondaryEmerald.withValues(alpha:0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryEmerald.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                const Text('Direct'),
                if (_directChats.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_directChats.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group, size: 16),
                const SizedBox(width: 4),
                const Text('Groups'),
                if (_groupChats.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_groupChats.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_soccer, size: 16),
                const SizedBox(width: 4),
                const Text('Teams'),
                if (_teamChats.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_teamChats.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<Chat>>(
      stream: _messagingService.chatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const EnhancedLoadingState(
            message: 'Loading conversations...',
            color: AppTheme.secondaryEmerald,
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final chats = snapshot.data ?? [];
        
        if (chats.isEmpty) {
          return _buildEmptyState();
        }

        return SwipeRefresh(
          onRefresh: _refreshChats,
          color: AppTheme.secondaryEmerald,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              
              return SwipeableWidget(
                key: ValueKey(chat.chatId),
                onSwipeLeft: () => _archiveChat(chat),
                onSwipeRight: () => _markAsRead(chat),
                leftActionColor: AppTheme.errorColor,
                rightActionColor: AppTheme.primaryElectricBlue,
                leftActionIcon: Icons.archive,
                rightActionIcon: Icons.mark_email_read,
                leftActionLabel: 'Archive',
                rightActionLabel: 'Mark Read',
                swipeThreshold: 120,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ChatListItem(
                    chat: chat,
                    onTap: () => _openChat(chat),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your friends',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          AnimatedButton(
            onTap: _showNewChatOptions,
            backgroundColor: AppTheme.secondaryEmerald,
            borderRadius: BorderRadius.circular(25),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shadow: BoxShadow(
              color: AppTheme.secondaryEmerald.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.message,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Start Chatting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading conversations',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            onTap: _refreshChats,
            backgroundColor: AppTheme.secondaryEmerald,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshChats() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trigger a refresh of the data
    setState(() {
      _isLoading = true;
    });
    await _initializeMessaging();
  }

  void _archiveChat(Chat chat) async {
    // For now, just show a message - archive functionality can be implemented later
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Archive feature coming soon!'),
          backgroundColor: AppTheme.secondaryEmerald,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _markAsRead(Chat chat) async {
    try {
      await _messagingService.markChatAsRead(chat.chatId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as read'),
            backgroundColor: AppTheme.primaryElectricBlue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking as read: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chat),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NewChatBottomSheet(
        onDirectChatCreated: (chat) {
          Navigator.pop(context);
          _openChat(chat);
        },
        onGroupChatCreated: (chat) {
          Navigator.pop(context);
          _openChat(chat);
        },
        onTeamChatCreated: (chat) {
          Navigator.pop(context);
          _openChat(chat);
        },
      ),
    );
  }
} 