import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/activity_feed.dart';
import '../../domain/services/activity_feed_service.dart';
import '../widgets/activity_feed_item_widget.dart';
import '../widgets/create_activity_bottom_sheet.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'user_profile_screen.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with SingleTickerProviderStateMixin {
  final ActivityFeedService _activityService = ActivityFeedService();
  
  List<ActivityFeedItem> _activities = [];
  bool _isLoading = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAndLoadFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      setState(() => _isLoading = true);
    }
    
    try {
      final activities = await _activityService.getActivityFeed(currentUser.uid);

      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
          _activities = activities;
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
          _activities = activities;
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
        onActivityCreated: (activity) {
          _activityService.createActivity(activity);
          _refreshFeed();
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

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppTheme.primaryOrange,
      backgroundColor: AppTheme.backgroundCard,
      strokeWidth: 3,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityList(),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ActivityFeedItemWidget(
            activity: activity,
            onLike: (activityId) => _handleLike(activityId, activity),
            onComment: (activityId, comment) => _handleComment(activityId, comment, activity),
            onShare: (activity) => _handleShare(activity),
            onUserPressed: (userId) => _navigateToProfile(userId),
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

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }
} 