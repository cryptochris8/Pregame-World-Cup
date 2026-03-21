import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification.dart';
import '../../domain/services/notification_service.dart';
import '../widgets/notification_item_widget.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart';

import '../../../../core/utils/team_logo_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = sl<NotificationService>();
  
  List<SocialNotification> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAndLoadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadNotifications() async {
    try {
      await _notificationService.initialize();

      await _loadNotifications();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // No current user
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifications = await _notificationService.getUserNotifications(currentUser.uid);
      final unreadCount = await _notificationService.getUnreadNotificationCount(currentUser.uid);

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load notifications'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      await _loadNotifications(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to mark notification as read'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await _notificationService.markAllNotificationsAsRead(currentUser.uid);
      await _loadNotifications(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to mark notifications as read'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use gradient background instead of solid color
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar with gradient background
              _buildGradientAppBar(),
              
              // Tab bar
              _buildTabBar(),
              
              // Body content
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          TeamLogoHelper.getPregameLogo(height: 32),
          const SizedBox(width: 12),
          const Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (_unreadCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white),
              tooltip: 'Mark all as read',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha:0.2),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
          IconButton(
            onPressed: _showNotificationSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Notification settings',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha:0.2),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('All'),
                if (_notifications.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                const Text('Unread'),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading notifications...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsList(),
        _buildNotificationsList(unreadOnly: true),
      ],
    );
  }

  Widget _buildNotificationsList({bool unreadOnly = false}) {
    final filteredNotifications = unreadOnly 
        ? _notifications.where((n) => !n.isRead).toList()
        : _notifications;

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState(unreadOnly: unreadOnly);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead 
                ? null 
                : Border.all(color: AppTheme.primaryOrange.withValues(alpha:0.5), width: 1),
          ),
          child: NotificationItemWidget(
            notification: notification,
            onTap: () => _markAsRead(notification.notificationId),
            onDelete: () => _deleteNotification(notification.notificationId),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({bool unreadOnly = false}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                unreadOnly ? Icons.mark_email_read : Icons.notifications_off_outlined,
                size: 64,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              unreadOnly ? 'All caught up!' : 'No notifications yet',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              unreadOnly 
                  ? 'You\'ve read all your notifications'
                  : 'When you have activity, notifications will appear here',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            if (!unreadOnly) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha:0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '🔔 Stay tuned for updates!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      await _loadNotifications(); // Refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete notification'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showNotificationSettings() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NotificationSettingsSheet(
        userId: currentUser.uid,
        notificationService: _notificationService,
      ),
    );
  }
}

class _NotificationSettingsSheet extends StatefulWidget {
  final String userId;
  final NotificationService notificationService;

  const _NotificationSettingsSheet({
    required this.userId,
    required this.notificationService,
  });

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  NotificationPreferences? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await widget.notificationService.getUserNotificationPreferences(widget.userId);
      if (mounted) {
        setState(() {
          _preferences = prefs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = NotificationPreferences.defaultPreferences();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    if (_preferences == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final success = await widget.notificationService.saveUserNotificationPreferences(
        widget.userId,
        _preferences!,
      );

      if (mounted) {
        setState(() => _isSaving = false);

        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification preferences saved'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save preferences'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving preferences'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Notification Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
              ),
            )
          else if (_preferences != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Push Notifications section
                    _buildSectionHeader('Push Notifications'),
                    _buildSwitchTile(
                      title: 'Enable Push Notifications',
                      subtitle: 'Receive notifications on this device',
                      value: _preferences!.pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(pushNotifications: value);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Notification Types section
                    _buildSectionHeader('Notification Types'),
                    _buildSwitchTile(
                      title: 'Friend Requests',
                      subtitle: 'When someone sends you a friend request',
                      value: _preferences!.friendRequests,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(friendRequests: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Activity Likes',
                      subtitle: 'When someone likes your activity',
                      value: _preferences!.activityLikes,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(activityLikes: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Activity Comments',
                      subtitle: 'When someone comments on your activity',
                      value: _preferences!.activityComments,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(activityComments: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Game Invites',
                      subtitle: 'Watch party invites and match reminders',
                      value: _preferences!.gameInvites,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(gameInvites: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Venue Recommendations',
                      subtitle: 'Suggested venues near you',
                      value: _preferences!.venueRecommendations,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(venueRecommendations: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'New Followers',
                      subtitle: 'When someone follows you',
                      value: _preferences!.newFollowers,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(newFollowers: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Group Activity',
                      subtitle: 'Updates from groups you joined',
                      value: _preferences!.groupActivity,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(groupActivity: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Achievements',
                      subtitle: 'When you unlock achievements',
                      value: _preferences!.achievements,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(achievements: value);
                        });
                      },
                    ),
                    _buildSwitchTile(
                      title: 'System Updates',
                      subtitle: 'Important app updates and announcements',
                      value: _preferences!.systemUpdates,
                      onChanged: (value) {
                        setState(() {
                          _preferences = _preferences!.copyWith(systemUpdates: value);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quiet Hours section
                    _buildSectionHeader('Quiet Hours'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bedtime, color: Colors.white70, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quiet Hours',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_preferences!.quietHoursStart} - ${_preferences!.quietHoursEnd}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Preferences',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryOrange,
        activeTrackColor: AppTheme.primaryOrange.withValues(alpha: 0.5),
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
} 
