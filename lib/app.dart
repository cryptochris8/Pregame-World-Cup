import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';
import 'config/app_theme.dart';
import 'core/services/accessibility_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/presence_service.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/messaging/domain/services/messaging_service.dart';
import 'features/messaging/presentation/screens/chat_screen.dart';
import 'services/revenuecat_service.dart';
import 'injection_container.dart' as di;
import 'app_initializer.dart' show debugLog;
import 'app_providers.dart';

/// Root widget for the Pregame World Cup app.
///
/// Sets up the provider tree and delegates to [_PregameAppContent] for the
/// MaterialApp configuration.
class PregameApp extends StatelessWidget {
  const PregameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppProviders(
      child: _PregameAppContent(),
    );
  }
}

/// The MaterialApp configuration including theme, localization, and routing.
///
/// Separated from [PregameApp] so that [AppProviders] is an ancestor and
/// provider look-ups (e.g. [AccessibilityProvider.settingsOf]) work correctly.
class _PregameAppContent extends StatelessWidget {
  const _PregameAppContent();

  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = AccessibilityProvider.settingsOf(context);

    return MaterialApp(
      title: 'Pregame',
      // Localization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Use the beautiful gradient dark theme by default
      // Switch to high contrast theme if accessibility setting is enabled
      theme: accessibilitySettings.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.darkTheme,
      darkTheme: accessibilitySettings.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.darkTheme,
      // Always use dark theme to show off the gradient design
      themeMode: ThemeMode.dark,
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
      // Accessibility-aware styling
      builder: (context, child) {
        // Get the system MediaQuery
        final mediaQuery = MediaQuery.of(context);

        // Calculate text scale factor:
        // 1. If user has set a custom scale in accessibility settings, use it
        // 2. Otherwise, respect the system text scale (don't override)
        final textScaleFactor = accessibilitySettings.textScaleFactor
            ?? mediaQuery.textScaler.scale(1.0);

        // Clamp text scale to prevent extreme values
        // but still allow reasonable accessibility scaling (up to 2x)
        final clampedScale = textScaleFactor.clamp(0.8, 2.0);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Authentication wrapper that shows login screen or main app based on auth state
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> with WidgetsBindingObserver {
  late Stream<User?> _authStream;
  bool _pushNotificationsInitialized = false;
  bool _presenceInitialized = false;
  bool _profileCreationInProgress = false;

  @override
  void initState() {
    super.initState();
    // Initialize the auth stream
    _authStream = FirebaseAuth.instance.authStateChanges();
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleAppLifecycleChange(state);
  }

  /// Handle app lifecycle changes for presence tracking
  void _handleAppLifecycleChange(AppLifecycleState state) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || !_presenceInitialized) return;

    final presenceService = di.sl<PresenceService>();

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - mark user as online
        debugLog('LIFECYCLE: App resumed - setting user online');
        presenceService.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - mark user as offline
        debugLog('LIFECYCLE: App paused/inactive - setting user offline');
        presenceService.setOffline();
        break;
    }
  }

  /// Initialize push notifications, RevenueCat, and presence service for the authenticated user
  void _initializeAuthenticatedUserServices() {
    // Only initialize once per session
    if (_pushNotificationsInitialized) return;
    _pushNotificationsInitialized = true;

    // Initialize in background to avoid blocking UI
    Future.microtask(() async {
      // Initialize Push Notifications
      try {
        debugLog('PUSH: Initializing push notifications for authenticated user');
        final pushService = di.sl<PushNotificationService>();
        await pushService.initialize();
        debugLog('PUSH: Push notifications initialized successfully');
      } catch (e) {
        debugLog('PUSH: Failed to initialize push notifications: $e');
        // Non-critical - app continues to work without push notifications
      }

      // Login to RevenueCat for the authenticated user
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          debugLog('REVENUECAT: Logging in user for purchases');
          await RevenueCatService().loginUser(user.uid);
          debugLog('REVENUECAT: User logged in successfully');
        }
      } catch (e) {
        debugLog('REVENUECAT: Failed to login user: $e');
        // Non-critical - app continues to work without RevenueCat
      }

      // Initialize Presence Service for online status tracking
      try {
        debugLog('PRESENCE: Initializing presence service for online status');
        final presenceService = di.sl<PresenceService>();
        await presenceService.initialize();
        _presenceInitialized = true;
        debugLog('PRESENCE: Presence service initialized - user is now online');
      } catch (e) {
        debugLog('PRESENCE: Failed to initialize presence service: $e');
        // Non-critical - app continues to work without presence tracking
      }

      // Set up notification tap handler for navigation
      _setupNotificationNavigation();
    });
  }

  /// Ensure user profile exists after email verification
  void _ensureUserProfileExists(User user) {
    // Only run once per session to avoid duplicate profile creation attempts
    if (_profileCreationInProgress) return;
    _profileCreationInProgress = true;

    // Run in background to avoid blocking UI
    Future.microtask(() async {
      try {
        debugLog('PROFILE: Ensuring user profile exists for verified user');
        final authService = di.sl<AuthService>();
        await authService.createUserProfile(user);
        debugLog('PROFILE: User profile check/creation completed');
      } catch (e) {
        debugLog('PROFILE: Error ensuring user profile: $e');
        // Non-critical - app continues to work
      }
    });
  }

  /// Set up notification tap handler for navigating to appropriate screens
  void _setupNotificationNavigation() {
    PushNotificationService.onNotificationTap = (String type, Map<String, dynamic> data) {
      debugLog('NOTIFICATION TAP: type=$type, data=$data');

      // Ensure we have a valid context
      if (!mounted) return;

      switch (type) {
        case 'new_message':
          _navigateToChat(data);
          break;
        case 'friend_request':
          _navigateToFriendRequests();
          break;
        case 'friend_request_accepted':
          _navigateToUserProfile(data['fromUserId'] as String?);
          break;
        case 'watch_party_invite':
          _navigateToWatchParty(data['watchPartyId'] as String?);
          break;
        default:
          debugLog('NOTIFICATION: Unhandled notification type: $type');
      }
    };
  }

  /// Navigate to chat screen when message notification is tapped
  Future<void> _navigateToChat(Map<String, dynamic> data) async {
    final chatId = data['chatId'] as String?;
    if (chatId == null) {
      debugLog('NOTIFICATION: No chatId in notification data');
      return;
    }

    try {
      debugLog('NOTIFICATION: Navigating to chat $chatId');

      // Get the chat from MessagingService
      final messagingService = MessagingService();
      final chat = await messagingService.getChatById(chatId);

      if (chat != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      } else {
        debugLog('NOTIFICATION: Chat not found: $chatId');
      }
    } catch (e) {
      debugLog('NOTIFICATION: Error navigating to chat: $e');
    }
  }

  /// Navigate to friend requests screen
  void _navigateToFriendRequests() {
    debugLog('NOTIFICATION: Navigating to friend requests');
    if (!mounted) return;

    // Navigate to main navigation with friends tab selected
    // Tab indexes: WorldCup=0, Feed=1, Messages=2, Notifications=3, Friends=4, Profile=5
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialTabIndex: 4),
      ),
      (route) => false,
    );
  }

  /// Navigate to user profile when friend request is accepted
  void _navigateToUserProfile(String? userId) {
    if (userId == null) {
      debugLog('NOTIFICATION: No userId in accepted notification');
      return;
    }
    debugLog('NOTIFICATION: Navigating to user profile $userId');
    if (!mounted) return;

    // Navigate to friends tab first, then the user can view the profile
    // Tab indexes: WorldCup=0, Feed=1, Messages=2, Notifications=3, Friends=4, Profile=5
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialTabIndex: 4),
      ),
      (route) => false,
    );
  }

  /// Navigate to watch party screen
  void _navigateToWatchParty(String? watchPartyId) {
    if (watchPartyId == null) return;
    debugLog('NOTIFICATION: Navigating to watch party $watchPartyId');
    // The navigation will be handled by the main navigation system
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Only proceed if widget is still mounted
        if (!mounted) {
          return const SizedBox.shrink();
        }

        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF1a1a1a),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: const Image(
                      image: AssetImage('assets/logos/pregame_logo.png'),
                      height: 150,
                      width: 150,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.orange),
                ],
              ),
            ),
          );
        }

        // Show main app if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Check if email is verified
          if (user.emailVerified) {
            // Initialize authenticated user services (push, RevenueCat, presence)
            _initializeAuthenticatedUserServices();
            // Ensure user profile exists (for first verified login)
            _ensureUserProfileExists(user);
            return const MainNavigationScreen();
          } else {
            // Email not verified - show verification screen
            return const EmailVerificationScreen();
          }
        }

        // Show login screen if user is not authenticated
        return const LoginScreen();
      },
    );
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Dispose presence service
    if (_presenceInitialized) {
      try {
        final presenceService = di.sl<PresenceService>();
        presenceService.dispose();
      } catch (e) {
        debugLog('PRESENCE: Error disposing presence service: $e');
      }
    }

    super.dispose();
  }
}
