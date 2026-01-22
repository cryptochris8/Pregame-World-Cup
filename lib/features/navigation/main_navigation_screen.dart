import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/logging_service.dart';
import '../schedule/presentation/screens/upcoming_games_screen.dart';
import '../schedule/presentation/screens/enhanced_schedule_screen.dart';
import '../social/presentation/screens/activity_feed_screen.dart';
import '../messaging/presentation/screens/chats_list_screen.dart';
import '../social/presentation/screens/notifications_screen.dart';
import '../social/presentation/screens/enhanced_friends_list_screen.dart';
import '../social/presentation/screens/user_profile_screen.dart';
import '../social/domain/services/notification_service.dart';
import '../messaging/domain/services/messaging_service.dart';
import '../auth/domain/services/auth_service.dart';
import '../../config/app_theme.dart';

// World Cup 2026
import '../worldcup/worldcup.dart';
import '../../injection_container.dart' as di;

import '../../core/animations/animated_button.dart';
import '../../core/animations/swipe_gestures.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigationScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  final NotificationService _notificationService = NotificationService();
  final MessagingService _messagingService = MessagingService();
  int _unreadNotifications = 0;
  int _unreadMessages = 0;

  late final List<Widget> _screens;
  late AnimationController _navigationController;
  late List<AnimationController> _tabControllers;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Use the initial tab index provided, clamped to valid range
    _selectedIndex = widget.initialTabIndex.clamp(0, 5);

    _screens = [
      // World Cup 2026 - Main feature with all match/group/bracket/team screens
      _WorldCupFeatureWrapper(),
      const ActivityFeedScreen(),
      const ChatsListScreen(),
      const NotificationsScreen(),
      const EnhancedFriendsListScreen(),
      UserProfileScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
    ];

    // Initialize page controller for swipe navigation
    _pageController = PageController(initialPage: _selectedIndex);

    // Initialize navigation animation controller
    _navigationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize tab controllers for individual nav items
    _tabControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _navigationController.forward();
    
    // Initialize services in the background to avoid blocking UI
    Future.microtask(() => _initializeServices());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navigationController.dispose();
    for (final controller in _tabControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Check if widget is still mounted before proceeding
      if (!mounted) return;
      
      // DISABLED: Automatic test user creation - users should see login screen
      // In development mode, create a test user if no user is authenticated
      // if (kDebugMode && FirebaseAuth.instance.currentUser == null) {
      //   LoggingService.info('Development mode: Creating test user for social features', tag: 'MainNavigation');
      //   try {
      //     final authService = AuthService();
      //     await authService.createOrSignInTestUser();
      //     LoggingService.info('Test user created/signed in successfully', tag: 'MainNavigation');
      //   } catch (e) {
      //     LoggingService.error('Failed to create test user: $e', tag: 'MainNavigation');
      //   }
      // }
      
      await _notificationService.initialize();
      if (!mounted) return; // Check again after async operation
      
      await _messagingService.initialize();
      if (!mounted) return; // Check again after async operation
      
      _listenToUnreadCounts();
    } catch (e) {
      LoggingService.error('Error initializing services: $e', tag: 'MainNavigation');
    }
  }

  void _listenToUnreadCounts() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || !mounted) return;

    _notificationService.getUnreadCount(currentUser.uid).listen((count) {
      if (mounted) {
        setState(() {
          _unreadNotifications = count;
        });
      }
    });

    _messagingService.chatsStream.listen((chats) {
      if (mounted) {
        final totalUnread = chats.fold<int>(
          0,
          (sum, chat) => sum + chat.getUnreadCount(currentUser.uid),
        );
        setState(() {
          _unreadMessages = totalUnread;
        });
      }
    });
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animate the selected tab
    _tabControllers[index].forward().then((_) {
      _tabControllers[index].reverse();
    });

    // Reset previous tab animation
    if (_selectedIndex < _tabControllers.length) {
      _tabControllers[_selectedIndex].reset();
    }

    setState(() {
      _selectedIndex = index;
    });

    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );

    // Restart navigation animation for smooth transition
    _navigationController.reset();
    _navigationController.forward();
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Animate the tab indicator
      _tabControllers[index].forward().then((_) {
        _tabControllers[index].reverse();
      });

      // Light haptic feedback for page swipes
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SwipeablePageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        enableSwipe: true,
        children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.sports_soccer, 'World Cup', AppTheme.primaryOrange),
                _buildNavItem(1, Icons.dynamic_feed, 'Feed', AppTheme.primaryOrange),
                _buildNavItem(2, Icons.message, 'Messages', AppTheme.primaryOrange, badgeCount: _unreadMessages),
                _buildNavItem(3, Icons.notifications, 'Alerts', AppTheme.primaryOrange, badgeCount: _unreadNotifications),
                _buildNavItem(4, Icons.people, 'Friends', AppTheme.primaryOrange),
                _buildNavItem(5, Icons.person, 'Profile', AppTheme.primaryOrange),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color, {int badgeCount = 0}) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: AnimatedBuilder(
        animation: _tabControllers[index],
        builder: (context, child) {
          final scaleValue = 1.0 + (_tabControllers[index].value * 0.1);
          
          return Transform.scale(
            scale: scaleValue,
            child: AnimatedButton(
              onTap: () => _onTabSelected(index),
              enableHaptics: false, // We handle haptics manually
              animationDuration: const Duration(milliseconds: 100),
              scaleValue: 0.95,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              icon,
                              key: ValueKey('nav-$index-$icon-$isSelected'),
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                        if (badgeCount > 0)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: AnimatedScale(
                              scale: badgeCount > 0 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.elasticOut,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surface,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryRed.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  badgeCount > 99 ? '99+' : '$badgeCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected ? color : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper widget that creates and links World Cup feature cubits
class _WorldCupFeatureWrapper extends StatefulWidget {
  @override
  State<_WorldCupFeatureWrapper> createState() => _WorldCupFeatureWrapperState();
}

class _WorldCupFeatureWrapperState extends State<_WorldCupFeatureWrapper> {
  late final MatchListCubit _matchListCubit;
  late final GroupStandingsCubit _groupStandingsCubit;
  late final BracketCubit _bracketCubit;
  late final TeamsCubit _teamsCubit;
  late final FavoritesCubit _favoritesCubit;
  late final PredictionsCubit _predictionsCubit;
  late final WorldCupAICubit _worldCupAICubit;

  @override
  void initState() {
    super.initState();

    // Create cubits
    _matchListCubit = di.sl<MatchListCubit>()..init();
    _groupStandingsCubit = di.sl<GroupStandingsCubit>()..init();
    _bracketCubit = di.sl<BracketCubit>()..init();
    _teamsCubit = di.sl<TeamsCubit>()..init();
    _favoritesCubit = di.sl<FavoritesCubit>()..init();
    _worldCupAICubit = di.sl<WorldCupAICubit>();
    _predictionsCubit = di.sl<PredictionsCubit>()..init();

    // TODO: Token rewards integration - disabled pending legal review
    // When re-enabling, uncomment the following:
    // _tokenCubit = di.sl<TokenCubit>()..init();
    // _predictionsCubit.setTokenCubit(_tokenCubit);
  }

  @override
  void dispose() {
    _matchListCubit.close();
    _groupStandingsCubit.close();
    _bracketCubit.close();
    _teamsCubit.close();
    _favoritesCubit.close();
    _predictionsCubit.close();
    _worldCupAICubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchListCubit>.value(value: _matchListCubit),
        BlocProvider<GroupStandingsCubit>.value(value: _groupStandingsCubit),
        BlocProvider<BracketCubit>.value(value: _bracketCubit),
        BlocProvider<TeamsCubit>.value(value: _teamsCubit),
        BlocProvider<FavoritesCubit>.value(value: _favoritesCubit),
        BlocProvider<PredictionsCubit>.value(value: _predictionsCubit),
        BlocProvider<WorldCupAICubit>.value(value: _worldCupAICubit),
        // TODO: Token feature - disabled pending legal review
        // BlocProvider<TokenCubit>.value(value: _tokenCubit),
      ],
      child: const WorldCupHomeScreen(),
    );
  }
} 