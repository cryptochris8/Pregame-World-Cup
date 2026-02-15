import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../config/app_theme.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../worldcup/presentation/screens/timezone_settings_screen.dart';
import '../../../settings/presentation/screens/accessibility_preferences_screen.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId;
  final UserProfile? initialProfile;

  const UserProfileScreen({
    super.key,
    this.userId,
    this.initialProfile,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SocialService _socialService = sl<SocialService>();
  final AuthService _authService = sl<AuthService>();
  
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Determine which profile to load
      final targetUserId = widget.userId ?? currentUser.uid;
      _isCurrentUser = targetUserId == currentUser.uid;

      // Use initial profile if provided, otherwise fetch
      UserProfile? profile = widget.initialProfile;
      if (profile == null) {
        if (_isCurrentUser) {
          profile = await _socialService.getCurrentUserProfile();
        } else {
          profile = await _socialService.getUserProfile(targetUserId);
        }
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading profile: $e', tag: 'UserProfileScreen');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error loading profile'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // The AuthenticationWrapper will automatically navigate to LoginScreen
      // when it detects the user has signed out, so no manual navigation needed
    } catch (e) {
      LoggingService.error('Error signing out: $e', tag: 'UserProfileScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error signing out'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with Gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha:0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    if (!_isCurrentUser)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    Expanded(
                      child: Text(
                        _isCurrentUser ? 'My Profile' : (_profile?.displayName ?? 'Profile'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: _isCurrentUser ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                    if (_isCurrentUser) ...[
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccessibilityPreferencesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.accessibility_new, color: Colors.white),
                        tooltip: 'Accessibility Settings',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TimezoneSettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.schedule, color: Colors.white),
                        tooltip: 'Timezone Settings',
                      ),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Sign Out',
                      ),
                    ],
                  ],
                ),
              ),
              
              // Profile Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      )
                    : _buildProfileContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Avatar with online status indicator
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.buttonGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    // Online status indicator (for other users only)
                    if (!_isCurrentUser && _profile != null && _profile!.shouldShowOnlineStatus)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _profile!.isOnline
                                ? Colors.green
                                : _profile!.isRecentlyActive
                                    ? Colors.orange
                                    : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // User Name
                Text(
                  _profile?.displayName ?? currentUser?.displayName ?? 'Sports Fan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Online status text (for other users only)
                if (!_isCurrentUser && _profile != null && _profile!.shouldShowOnlineStatus) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _profile!.isOnline
                              ? Colors.green
                              : _profile!.isRecentlyActive
                                  ? Colors.orange
                                  : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _profile!.lastSeenText,
                        style: TextStyle(
                          fontSize: 14,
                          color: _profile!.isOnline
                              ? Colors.green[300]
                              : Colors.white.withValues(alpha:0.7),
                          fontWeight: _profile!.isOnline
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // User Email
                Text(
                  _profile?.email ?? currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Join Date
                if (currentUser?.metadata.creationTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha:0.3),
                      ),
                    ),
                    child: Text(
                      'Pregame Fan Since ${_formatJoinDate(currentUser!.metadata.creationTime!)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Games Tracked', '0', Icons.sports_soccer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Friends', '0', Icons.people),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Teams', '0', Icons.star),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Venues', '0', Icons.location_on),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Accessibility Settings (Active)
          if (_isCurrentUser)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilityPreferencesScreen(),
                  ),
                );
              },
              child: _buildActiveFeatureCard(
                'Accessibility',
                'Customize text size, contrast, motion, and more',
                Icons.accessibility_new,
              ),
            ),

          if (_isCurrentUser) const SizedBox(height: 16),

          // Profile Customization
          if (_isCurrentUser && _profile != null)
            GestureDetector(
              onTap: () async {
                final updatedProfile = await Navigator.push<UserProfile>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      profile: _profile!,
                    ),
                  ),
                );
                if (updatedProfile != null && mounted) {
                  setState(() {
                    _profile = updatedProfile;
                  });
                }
              },
              child: _buildActiveFeatureCard(
                'Profile Customization',
                'Upload photos, set favorite teams, and personalize your sports fan profile',
                Icons.edit,
              ),
            ),
          
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            'Activity Feed',
            'Track your game predictions, venue check-ins, and social interactions',
            Icons.timeline,
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            'Achievements',
            'Unlock badges for predictions, social activity, and venue discoveries',
            Icons.emoji_events,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha:0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withValues(alpha:0.2),
            Colors.deepPurple.withValues(alpha:0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha:0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.orange,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
} 