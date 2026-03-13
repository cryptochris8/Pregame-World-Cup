import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../social/domain/services/social_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../services/revenuecat_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SocialService _socialService = sl<SocialService>();
  final AnalyticsService _analyticsService = sl<AnalyticsService>();

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

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _analyticsService.logLogin(method: 'google');
      LoggingService.info('Google sign-in successful for ${userCredential.user?.email}', tag: 'AuthService');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      LoggingService.error('FirebaseAuthException on Google sign in: ${e.message}', tag: 'AuthService');
      await _analyticsService.logError(
        errorType: 'auth_error',
        message: 'Google sign in failed: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      LoggingService.error('Error during Google sign in: $e', tag: 'AuthService');
      throw Exception('An unexpected error occurred during Google sign in.');
    }
  }

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] as a hex string.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      await _analyticsService.logLogin(method: 'apple');
      LoggingService.info('Apple sign-in successful for ${userCredential.user?.email}', tag: 'AuthService');
      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      LoggingService.error('Apple sign-in authorization error: ${e.message}', tag: 'AuthService');
      await _analyticsService.logError(
        errorType: 'auth_error',
        message: 'Apple sign in failed: ${e.message}',
      );
      throw Exception(e.message);
    } on FirebaseAuthException catch (e) {
      LoggingService.error('FirebaseAuthException on Apple sign in: ${e.message}', tag: 'AuthService');
      await _analyticsService.logError(
        errorType: 'auth_error',
        message: 'Apple sign in failed: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      LoggingService.error('Error during Apple sign in: $e', tag: 'AuthService');
      throw Exception('An unexpected error occurred during Apple sign in.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Track logout in analytics
      await _analyticsService.logLogout();

      // Logout from RevenueCat to prevent entitlement leakage on shared devices
      try {
        await sl<RevenueCatService>().logoutUser();
      } catch (e) {
        LoggingService.error('RevenueCat logout failed (non-blocking): $e', tag: 'AuthService');
      }

      // Sign out from Google if signed in via Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        LoggingService.error('Google sign-out failed (non-blocking): $e', tag: 'AuthService');
      }

      await _firebaseAuth.signOut();
    } catch (e) {
      LoggingService.error('Error signing out: $e', tag: 'AuthService');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      LoggingService.info('Password reset email sent to $email', tag: 'AuthService');
    } on FirebaseAuthException catch (e) {
      LoggingService.error('Error sending password reset email: ${e.message}', tag: 'AuthService');
      throw Exception(e.message);
    } catch (e) {
      LoggingService.error('Error sending password reset email: $e', tag: 'AuthService');
      throw Exception('Failed to send password reset email.');
    }
  }

  // Delete user account and associated data
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    final uid = user.uid;
    LoggingService.info('Starting account deletion for $uid', tag: 'AuthService');

    try {
      // 1. Delete user profile
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (e) {
        LoggingService.warning('Error deleting user profile: $e', tag: 'AuthService');
      }

      // 2. Delete user favorites
      try {
        await _firestore.collection('userFavorites').doc(uid).delete();
      } catch (e) {
        LoggingService.warning('Error deleting user favorites: $e', tag: 'AuthService');
      }

      // 3. Delete user predictions (query + batch delete)
      try {
        final predictionsQuery = await _firestore
            .collection('user_predictions')
            .where('userId', isEqualTo: uid)
            .get();
        if (predictionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in predictionsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      } catch (e) {
        LoggingService.warning('Error deleting user predictions: $e', tag: 'AuthService');
      }

      // 4. Logout from RevenueCat
      try {
        await sl<RevenueCatService>().logoutUser();
      } catch (e) {
        LoggingService.warning('RevenueCat logout failed during deletion: $e', tag: 'AuthService');
      }

      // 5. Sign out from Google if signed in via Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        LoggingService.warning('Google sign-out failed during deletion: $e', tag: 'AuthService');
      }

      // 6. Delete Firebase Auth account
      await user.delete();
      LoggingService.info('Account deleted for $uid', tag: 'AuthService');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        LoggingService.warning('Account deletion requires recent login', tag: 'AuthService');
        rethrow;
      }
      LoggingService.error('Error deleting account: ${e.message}', tag: 'AuthService');
      rethrow;
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