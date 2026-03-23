import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../worldcup/presentation/screens/timezone_settings_screen.dart';
import '../../../settings/presentation/screens/accessibility_preferences_screen.dart';
import 'edit_profile_screen.dart';
import '../../../moderation/presentation/widgets/report_button.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_feature_cards.dart';
import '../widgets/profile_account_actions.dart';

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
            content: Text(AppLocalizations.of(context).errorLoadingProfile),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: Text(
            l10n.deleteAccountConfirmTitle,
            style: const TextStyle(color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.deleteAccountConfirmMessage,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.typeDeleteToConfirm,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: AppTheme.backgroundElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (confirmController.text.trim() == 'DELETE') {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                l10n.deleteAccount,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    confirmController.dispose();

    if (confirmed == true && mounted) {
      try {
        await _authService.deleteAccount();
        // Auth state change will redirect to login
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountRequiresRecentLogin),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      } catch (e) {
        LoggingService.error('Error deleting account: $e', tag: 'UserProfileScreen');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportUserData() async {
    final profile = _profile;
    if (profile == null) return;

    final data = <String, dynamic>{
      'userId': profile.userId,
      'displayName': profile.displayName,
      'email': profile.email,
      'bio': profile.bio,
      'homeLocation': profile.homeLocation,
      'favoriteTeams': profile.favoriteTeams,
      'level': profile.level,
      'experiencePoints': profile.experiencePoints,
      'badges': profile.badges,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
      'socialStats': {
        'friendsCount': profile.socialStats.friendsCount,
        'gamesAttended': profile.socialStats.gamesAttended,
        'venuesVisited': profile.socialStats.venuesVisited,
        'reviewsCount': profile.socialStats.reviewsCount,
        'photosShared': profile.socialStats.photosShared,
        'likesReceived': profile.socialStats.likesReceived,
        'checkInsCount': profile.socialStats.checkInsCount,
        'helpfulVotes': profile.socialStats.helpfulVotes,
      },
      'preferences': {
        'showLocation': profile.preferences.showLocation,
        'allowFriendRequests': profile.preferences.allowFriendRequests,
        'receiveNotifications': profile.preferences.receiveNotifications,
        'preferredVenueTypes': profile.preferences.preferredVenueTypes,
        'maxTravelDistance': profile.preferences.maxTravelDistance,
        'dietaryRestrictions': profile.preferences.dietaryRestrictions,
        'preferredPriceRange': profile.preferences.preferredPriceRange,
      },
      'privacySettings': {
        'profileVisible': profile.privacySettings.profileVisible,
        'showRealName': profile.privacySettings.showRealName,
        'showOnlineStatus': profile.privacySettings.showOnlineStatus,
        'showLocation': profile.privacySettings.showLocation,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    await Share.share(jsonString, subject: 'Pregame World Cup - My Data Export');
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
            content: Text(AppLocalizations.of(context).errorSigningOut),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        _isCurrentUser ? l10n.myProfile : (_profile?.displayName ?? 'Profile'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: _isCurrentUser ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                    if (!_isCurrentUser && _profile != null)
                      ReportButton.user(
                        userId: _profile!.userId,
                        displayName: _profile!.displayName,
                        iconColor: Colors.white70,
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
                        tooltip: l10n.accessibilitySettings,
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
                        tooltip: l10n.timezoneSettings,
                      ),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: l10n.signOut,
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
          ProfileHeaderCard(
            profile: _profile,
            currentUser: currentUser,
            isCurrentUser: _isCurrentUser,
          ),

          const SizedBox(height: 24),

          // Stats Cards
          const ProfileStatsRow(),

          const SizedBox(height: 24),

          // Feature Cards
          ProfileFeatureCards(
            isCurrentUser: _isCurrentUser,
            profile: _profile,
            onAccessibilityTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccessibilityPreferencesScreen(),
                ),
              );
            },
            onProfileCustomizeTap: () async {
              if (_profile != null) {
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
              }
            },
          ),

          // Account Actions (current user only)
          if (_isCurrentUser)
            ProfileAccountActions(
              onExportData: _exportUserData,
              onDeleteAccount: _showDeleteAccountDialog,
            ),
        ],
      ),
    );
  }
} 