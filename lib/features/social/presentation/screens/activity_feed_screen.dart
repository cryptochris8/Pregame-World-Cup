import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/activity_feed.dart';
import '../../domain/services/activity_feed_service.dart';
import '../widgets/activity_feed_item_widget.dart';
import '../widgets/create_activity_bottom_sheet.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import 'package:share_plus/share_plus.dart';
import 'user_profile_screen.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with SingleTickerProviderStateMixin {
  final ActivityFeedService _activityService = sl<ActivityFeedService>();
  final ScrollController _scrollController = ScrollController();

  List<ActivityFeedItem> _feedActivities = [];
  List<ActivityFeedItem> _userActivities = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _initializeAndLoadFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _initializeAndLoadFeed() async {
    try {
      await _activityService.initialize();

      await _loadActivityFeed();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadActivityFeed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasMore = true;
      });
    }

    try {
      final activities = await _activityService.getActivityFeed(currentUser.uid);

      if (mounted) {
        setState(() {
          _feedActivities = activities;
          _isLoading = false;
          _hasMore = activities.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_feedActivities.isEmpty || !_hasMore || _isLoadingMore) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (mounted) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final lastActivity = _feedActivities.last;
      final moreActivities = await _activityService.getActivityFeed(
        currentUser.uid,
        startAfter: lastActivity.createdAt,
      );

      if (mounted) {
        setState(() {
          _feedActivities.addAll(moreActivities);
          _isLoadingMore = false;
          _hasMore = moreActivities.length >= 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshFeed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      final activities = await _activityService.getActivityFeed(currentUser.uid);

      if (mounted) {
        setState(() {
          _feedActivities = activities;
        });
      }
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _loadUserActivities() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final activities = await _activityService.getUserActivities(currentUser.uid);

      if (mounted) {
        setState(() {
          _userActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateActivityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateActivityBottomSheet(
        onActivityCreated: (activity) async {
          final success = await _activityService.createActivity(activity);
          if (success) {
            _refreshFeed();
          } else {
            // Show error snackbar
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to post activity. Please try again.')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            Text(
              l10n.activityFeed,
              style: const TextStyle(
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
          onTap: (index) {
            if (index == 0) {
              _loadActivityFeed();
            } else {
              _loadUserActivities();
            }
          },
          tabs: [
            Tab(text: l10n.feed),
            Tab(text: l10n.yourPosts),
          ],
        ),
      ),
      body: _buildBody(),
          floatingActionButton: Container(
            decoration: AppTheme.buttonGradientDecoration,
            child: FloatingActionButton(
        heroTag: "activity_feed_fab",
        onPressed: _showCreateActivityBottomSheet,
              backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
              elevation: 0,
        child: const Icon(Icons.add, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).loadingActivities,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppTheme.primaryOrange,
      backgroundColor: AppTheme.backgroundCard,
      strokeWidth: 3,
      child: TabBarView(
        controller: _tabController,
        children: [
          _feedActivities.isEmpty ? _buildEmptyState() : _buildActivityList(_feedActivities),
          _userActivities.isEmpty ? _buildEmptyState() : _buildActivityList(_userActivities),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<ActivityFeedItem> activities) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: activities.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                strokeWidth: 3,
              ),
            ),
          );
        }

        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ActivityFeedItemWidget(
            activity: activity,
            initialIsLiked: activity.isLikedByCurrentUser,
            onLike: (activityId) => _handleLike(activityId, activity),
            onComment: (activityId, comment) => _handleComment(activityId, comment, activity),
            onShare: (activity) => _handleShare(activity),
            onUserPressed: (userId) => _navigateToProfile(userId),
            onDelete: _handleDelete,
            currentUserId: currentUser?.uid,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dynamic_feed,
            size: 80,
            color: AppTheme.primaryOrange,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noActivitiesYet,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.beFirstToShare,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: AppTheme.buttonGradientDecoration,
            child: ElevatedButton.icon(
            onPressed: _showCreateActivityBottomSheet,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
                elevation: 0,
            ),
            icon: const Icon(Icons.add),
            label: Text(
              l10n.createActivity,
              style: const TextStyle(
                fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike(String activityId, ActivityFeedItem activity) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final hasLiked = await _activityService.hasUserLikedActivity(activityId, currentUser.uid);
      
      if (hasLiked) {
        await _activityService.unlikeActivity(activityId, currentUser.uid);
      } else {
        await _activityService.likeActivity(activityId, currentUser.uid, currentUser.displayName ?? 'Anonymous');
      }
      
      // Refresh the specific activity
      _refreshFeed();
      
    } catch (e) {
      // Error handled silently
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToUpdateLike),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleComment(String activityId, String comment, ActivityFeedItem activity) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await _activityService.commentOnActivity(
        activityId,
        currentUser.uid,
        currentUser.displayName ?? 'Anonymous',
        comment,
        userProfileImage: currentUser.photoURL,
      );

      // Refresh the feed
      _refreshFeed();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commentAdded),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Error handled silently
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToAddComment),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleShare(ActivityFeedItem activity) {
    final l10n = AppLocalizations.of(context);
    final text = '${activity.userName}: ${activity.content}\n\n'
        '${l10n.sharedFromPregame}';
    Share.share(text, subject: l10n.appTitle);
  }

  Future<void> _handleDelete(String activityId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: const Text(
          'Delete Activity?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await _activityService.deleteActivity(activityId, currentUser.uid);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshFeed();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete activity'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting activity'),
          backgroundColor: Colors.red,
        ),
      );
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
} 