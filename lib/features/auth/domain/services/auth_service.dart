import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../social/domain/services/social_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../services/revenuecat_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SocialService _socialService = SocialService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if current user's email is verified
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  // Reload current user to get latest verification status
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  // Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      LoggingService.info('Verification email sent', tag: 'AuthService');
    } catch (e) {
      LoggingService.error('Error sending verification email: $e', tag: 'AuthService');
      throw Exception('Failed to send verification email.');
    }
  }

  // Resend email verification
  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      if (user.emailVerified) {
        throw Exception('Email already verified');
      }
      await user.sendEmailVerification();
      LoggingService.info('Verification email resent', tag: 'AuthService');
    } catch (e) {
      LoggingService.error('Error resending verification email: $e', tag: 'AuthService');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email after successful signup
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        // Track signup in analytics
        await _analyticsService.logSignUp(method: 'email');
        LoggingService.info('User signed up, verification email sent to $email', tag: 'AuthService');
      }

      // Note: User profile is NOT created here anymore
      // Profile creation happens after email verification in AuthenticationWrapper

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Consider mapping e.code to user-friendly messages
      LoggingService.error('FirebaseAuthException on sign up: ${e.message}', tag: 'AuthService');
      await _analyticsService.logError(
        errorType: 'auth_error',
        message: 'Sign up failed: ${e.message}',
      );
      throw Exception(e.message); // Rethrow or handle more gracefully
    } catch (e) {
      LoggingService.error('Unexpected error on sign up: $e', tag: 'AuthService');
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Track login in analytics
      await _analyticsService.logLogin(method: 'email');
      return result;
    } on FirebaseAuthException catch (e) {
      LoggingService.error('FirebaseAuthException on sign in: ${e.message}', tag: 'AuthService');
      await _analyticsService.logError(
        errorType: 'auth_error',
        message: 'Sign in failed: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      LoggingService.error('Unexpected error on sign in: $e', tag: 'AuthService');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Track logout in analytics
      await _analyticsService.logLogout();

      // Logout from RevenueCat to prevent entitlement leakage on shared devices
      try {
        await RevenueCatService().logoutUser();
      } catch (e) {
        LoggingService.error('RevenueCat logout failed (non-blocking): $e', tag: 'AuthService');
      }

      await _firebaseAuth.signOut();
    } catch (e) {
      LoggingService.error('Error signing out: $e', tag: 'AuthService');
      // Optionally handle error more gracefully
    }
  }

  // Development helper: Create or sign in test user
  Future<UserCredential?> createOrSignInTestUser() async {
    const testEmail = 'test@pregame.dev';
    const testPassword = 'testuser123';
    
    try {
      // Try to sign in first
      return await signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
    } catch (e) {
      // If sign in fails, try to create the user
      try {
        LoggingService.info('Creating test user for development', tag: 'AuthService');
        return await signUpWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      } catch (createError) {
        LoggingService.error('Failed to create test user: $createError', tag: 'AuthService');
        rethrow;
      }
    }
  }

  // Get user's favorite teams
  Future<List<String>> getFavoriteTeams(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('userFavorites').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        // Ensure 'favoriteTeamNames' exists and is a list of strings
        if (data.containsKey('favoriteTeamNames') && data['favoriteTeamNames'] is List) {
          return List<String>.from(data['favoriteTeamNames']);
        }
      }
      return []; // Return empty list if no document or no valid field
    } catch (e) {
      LoggingService.error('Error fetching favorite teams: $e', tag: 'AuthService');
      throw Exception('Could not fetch favorite teams.');
    }
  }

  // Update user's favorite teams
  Future<void> updateFavoriteTeams(String userId, List<String> teamNames) async {
    try {
      await _firestore.collection('userFavorites').doc(userId).set({
        'favoriteTeamNames': teamNames,
        'lastUpdated': FieldValue.serverTimestamp(), // Optional: track last update
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other potential fields
    } catch (e) {
      LoggingService.error('Error updating favorite teams: $e', tag: 'AuthService');
      throw Exception('Could not update favorite teams.');
    }
  }

  // Create user profile for new users (called after email verification)
  Future<void> createUserProfile(User user) async {
    try {
      await _socialService.initialize();
      
      // Check if profile already exists
      final existingProfile = await _socialService.getUserProfile(user.uid);
      if (existingProfile != null) {
        return; // Profile already exists
      }
      
      // Create new user profile
      final userProfile = UserProfile.create(
        userId: user.uid,
        displayName: user.displayName ?? 'Anonymous User',
        email: user.email,
        favoriteTeams: const [],
      );
      
      await _socialService.saveUserProfile(userProfile);
      LoggingService.info('User profile created for ${user.uid}', tag: 'AuthService');
    } catch (e) {
      LoggingService.error('Error creating user profile: $e', tag: 'AuthService');
      // Don't throw error here to avoid blocking signup
    }
  }
} 