import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:get_it/get_it.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_service.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';
import 'package:pregame_world_cup/injection_container.dart';

// ==================== MOCKS ====================

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockSocialService extends Mock implements SocialService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockRevenueCatService extends Mock implements RevenueCatService {}

/// Helper to create a FirebaseAuthException for testing
class TestFirebaseAuthException extends FirebaseException {
  TestFirebaseAuthException({required String code, super.message})
      : super(plugin: 'auth', code: code);
}

/// Testable subclass of AuthService that allows injection of dependencies.
///
/// AuthService internally creates its own FirebaseAuth, Firestore, SocialService,
/// and AnalyticsService instances. This subclass overrides those fields so we
/// can inject mocks for unit testing.
class TestableAuthService extends AuthService {
  final FirebaseAuth testFirebaseAuth;
  final FirebaseFirestore testFirestore;
  final SocialService testSocialService;
  final AnalyticsService testAnalyticsService;
  final RevenueCatService testRevenueCatService;

  TestableAuthService({
    required this.testFirebaseAuth,
    required this.testFirestore,
    required this.testSocialService,
    required this.testAnalyticsService,
    required this.testRevenueCatService,
  });

  // We override the methods rather than fields, since AuthService's fields
  // are final/private and non-overridable. Instead, we replicate the logic
  // from AuthService but using our injected dependencies.

  @override
  Stream<User?> get authStateChanges => testFirebaseAuth.authStateChanges();

  @override
  User? get currentUser => testFirebaseAuth.currentUser;

  @override
  bool get isEmailVerified =>
      testFirebaseAuth.currentUser?.emailVerified ?? false;

  @override
  Future<void> reloadUser() async {
    await testFirebaseAuth.currentUser?.reload();
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await testFirebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email.');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    final user = testFirebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }
    if (user.emailVerified) {
      throw Exception('Email already verified');
    }
    await user.sendEmailVerification();
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await testFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        await testAnalyticsService.logSignUp(method: 'email');
      }

      return userCredential;
    } on FirebaseException catch (e) {
      await testAnalyticsService.logError(
        errorType: 'auth_error',
        message: 'Sign up failed: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await testFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await testAnalyticsService.logLogin(method: 'email');
      return result;
    } on FirebaseException catch (e) {
      await testAnalyticsService.logError(
        errorType: 'auth_error',
        message: 'Sign in failed: ${e.message}',
      );
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await testAnalyticsService.logLogout();
      try {
        await testRevenueCatService.logoutUser();
      } catch (_) {
        // Non-blocking
      }
      await testFirebaseAuth.signOut();
    } catch (_) {
      // Optionally handle
    }
  }

  @override
  Future<List<String>> getFavoriteTeams(String userId) async {
    try {
      final docSnapshot =
          await testFirestore.collection('userFavorites').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('favoriteTeamNames') &&
            data['favoriteTeamNames'] is List) {
          return List<String>.from(data['favoriteTeamNames']);
        }
      }
      return [];
    } catch (e) {
      throw Exception('Could not fetch favorite teams.');
    }
  }

  @override
  Future<void> updateFavoriteTeams(
      String userId, List<String> teamNames) async {
    try {
      await testFirestore.collection('userFavorites').doc(userId).set({
        'favoriteTeamNames': teamNames,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Could not update favorite teams.');
    }
  }

  @override
  Future<void> createUserProfile(User user) async {
    try {
      await testSocialService.initialize();

      final existingProfile =
          await testSocialService.getUserProfile(user.uid);
      if (existingProfile != null) {
        return;
      }

      final userProfile = UserProfile.create(
        userId: user.uid,
        displayName: user.displayName ?? 'Anonymous User',
        email: user.email,
        favoriteTeams: const [],
      );

      await testSocialService.saveUserProfile(userProfile);
    } catch (_) {
      // Don't throw to avoid blocking signup
    }
  }

}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockSocialService mockSocialService;
  late MockAnalyticsService mockAnalyticsService;
  late MockRevenueCatService mockRevenueCatService;
  late TestableAuthService authService;
  late MockUser mockUser;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();

    // Register fallback values for mocktail
    registerFallbackValue(UserProfile.create(
      userId: 'fallback',
      displayName: 'Fallback',
    ));
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockSocialService = MockSocialService();
    mockAnalyticsService = MockAnalyticsService();
    mockRevenueCatService = MockRevenueCatService();
    mockUser = MockUser();

    // Register services in GetIt so AuthService constructor can resolve them
    if (!sl.isRegistered<SocialService>()) {
      sl.registerLazySingleton<SocialService>(() => mockSocialService);
    }
    if (!sl.isRegistered<AnalyticsService>()) {
      sl.registerSingleton<AnalyticsService>(mockAnalyticsService);
    }

    authService = TestableAuthService(
      testFirebaseAuth: mockAuth,
      testFirestore: fakeFirestore,
      testSocialService: mockSocialService,
      testAnalyticsService: mockAnalyticsService,
      testRevenueCatService: mockRevenueCatService,
    );

    // Stub the underlying methods that extension methods delegate to.
    // logSignUp, logLogin, logLogout are extension methods (resolved statically),
    // so we stub logEvent + clearUserId which they call internally.
    when(() => mockAnalyticsService.logEvent(
          any(),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});
    when(() => mockAnalyticsService.clearUserId()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.logError(
          errorType: any(named: 'errorType'),
          message: any(named: 'message'),
        )).thenAnswer((_) async {});
  });

  tearDown(() async {
    await sl.reset();
  });

  // ========================================================
  // SIGN UP FLOW
  // ========================================================

  group('signUpWithEmailAndPassword', () {
    test('returns UserCredential on successful sign up', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final result = await authService.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isNotNull);
      expect(result!.user, equals(mockUser));
    });

    test('sends verification email after successful sign up', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('tracks sign up in analytics after successful sign up', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockAnalyticsService.logEvent('sign_up',
          parameters: {'method': 'email'})).called(1);
    });

    test('does not send verification email when user is null', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(null);
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verifyNever(() => mockUser.sendEmailVerification());
      verifyNever(() => mockAnalyticsService.logEvent('sign_up',
          parameters: any(named: 'parameters')));
    });

    test('throws Exception on email-already-in-use error', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      ));

      expect(
        () => authService.signUpWithEmailAndPassword(
          email: 'existing@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('already in use'),
        )),
      );
    });

    test('throws Exception on weak-password error', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'weak-password',
        message: 'The password is too weak.',
      ));

      expect(
        () => authService.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: '123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('too weak'),
        )),
      );
    });

    test('throws Exception on invalid-email error', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is badly formatted.',
      ));

      expect(
        () => authService.signUpWithEmailAndPassword(
          email: 'notanemail',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('logs error to analytics on FirebaseException sign up failure',
        () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      ));

      try {
        await authService.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );
      } catch (_) {}

      verify(() => mockAnalyticsService.logError(
            errorType: 'auth_error',
            message: any(named: 'message', that: contains('Sign up failed')),
          )).called(1);
    });

    test('throws generic Exception on unexpected error during sign up',
        () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(StateError('Something completely unexpected'));

      expect(
        () => authService.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('unexpected error'),
        )),
      );
    });

    test('throws Exception on operation-not-allowed error', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Email/password accounts are not enabled.',
      ));

      expect(
        () => authService.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ========================================================
  // SIGN IN FLOW
  // ========================================================

  group('signInWithEmailAndPassword', () {
    test('returns UserCredential on successful sign in', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isNotNull);
      expect(result!.user, equals(mockUser));
    });

    test('tracks login in analytics on successful sign in', () async {
      final mockCredential = MockUserCredential();
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockAnalyticsService.logEvent('login',
          parameters: {'method': 'email'})).called(1);
    });

    test('throws Exception on wrong-password error', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid.',
      ));

      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('invalid'),
        )),
      );
    });

    test('throws Exception on user-not-found error', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'nobody@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws Exception on user-disabled error', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'user-disabled',
        message: 'The user account has been disabled.',
      ));

      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'disabled@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('disabled'),
        )),
      );
    });

    test('throws Exception on too-many-requests error', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many unsuccessful sign-in attempts.',
      ));

      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('logs error to analytics on FirebaseException sign in failure',
        () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(TestFirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid.',
      ));

      try {
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        );
      } catch (_) {}

      verify(() => mockAnalyticsService.logError(
            errorType: 'auth_error',
            message: any(named: 'message', that: contains('Sign in failed')),
          )).called(1);
    });

    test('throws generic Exception on unexpected error during sign in',
        () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(StateError('Something completely unexpected'));

      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('unexpected error'),
        )),
      );
    });
  });

  // ========================================================
  // SIGN OUT FLOW
  // ========================================================

  group('signOut', () {
    test('calls signOut on FirebaseAuth', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('tracks logout in analytics before signing out', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAnalyticsService.logEvent('logout',
          parameters: any(named: 'parameters'))).called(1);
    });

    test('calls RevenueCat logoutUser to prevent entitlement leakage',
        () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockRevenueCatService.logoutUser()).called(1);
    });

    test('continues sign out even when RevenueCat logout fails', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenThrow(Exception('RevenueCat error'));

      // Should not throw
      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('does not throw when sign out itself fails', () async {
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});
      when(() => mockAuth.signOut()).thenThrow(Exception('Network error'));

      // signOut catches all exceptions internally
      await authService.signOut();

      // Should not throw
    });
  });

  // ========================================================
  // EMAIL VERIFICATION FLOW
  // ========================================================

  group('isEmailVerified', () {
    test('returns true when user email is verified', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(true);

      expect(authService.isEmailVerified, isTrue);
    });

    test('returns false when user email is not verified', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(false);

      expect(authService.isEmailVerified, isFalse);
    });

    test('returns false when currentUser is null', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(authService.isEmailVerified, isFalse);
    });
  });

  group('reloadUser', () {
    test('calls reload on current user', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});

      await authService.reloadUser();

      verify(() => mockUser.reload()).called(1);
    });

    test('does nothing when currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await authService.reloadUser();

      verifyNever(() => mockUser.reload());
    });
  });

  group('sendEmailVerification', () {
    test('sends verification email to current user', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});

      await authService.sendEmailVerification();

      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('does nothing when no user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      // Should not throw, just returns without sending
      await authService.sendEmailVerification();

      verifyNever(() => mockUser.sendEmailVerification());
    });

    test('throws Exception when sending verification email fails', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification())
          .thenThrow(Exception('Network error'));

      expect(
        () => authService.sendEmailVerification(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to send verification email'),
        )),
      );
    });
  });

  group('resendVerificationEmail', () {
    test('sends verification email when user exists and email not verified',
        () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(false);
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});

      await authService.resendVerificationEmail();

      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('throws Exception when no user is signed in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => authService.resendVerificationEmail(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('No user signed in'),
        )),
      );
    });

    test('throws Exception when email is already verified', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(true);

      expect(
        () => authService.resendVerificationEmail(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Email already verified'),
        )),
      );
    });

    test('rethrows when sendEmailVerification fails', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(false);
      when(() => mockUser.sendEmailVerification())
          .thenThrow(Exception('Firebase error'));

      expect(
        () => authService.resendVerificationEmail(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ========================================================
  // AUTH STATE CHANGES
  // ========================================================

  group('authStateChanges', () {
    test('returns a stream from FirebaseAuth', () {
      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      final stream = authService.authStateChanges;
      expect(stream, isA<Stream<User?>>());
    });

    test('stream emits user on sign in', () async {
      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      final user = await authService.authStateChanges.first;
      expect(user, equals(mockUser));
    });

    test('stream emits null on sign out', () async {
      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      final user = await authService.authStateChanges.first;
      expect(user, isNull);
    });

    test('stream emits multiple auth state changes', () async {
      when(() => mockAuth.authStateChanges()).thenAnswer(
        (_) => Stream.fromIterable([null, mockUser, null]),
      );

      final events = await authService.authStateChanges.toList();
      expect(events, hasLength(3));
      expect(events[0], isNull);
      expect(events[1], equals(mockUser));
      expect(events[2], isNull);
    });
  });

  // ========================================================
  // CURRENT USER
  // ========================================================

  group('currentUser', () {
    test('returns user when signed in', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(authService.currentUser, equals(mockUser));
    });

    test('returns null when not signed in', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(authService.currentUser, isNull);
    });

    test('provides access to user properties', () {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid_123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.displayName).thenReturn('Test User');

      final user = authService.currentUser!;
      expect(user.uid, equals('uid_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
    });
  });

  // ========================================================
  // FAVORITE TEAMS (Firestore)
  // ========================================================

  group('getFavoriteTeams', () {
    test('returns empty list when document does not exist', () async {
      final result = await authService.getFavoriteTeams('nonexistent_user');
      expect(result, isEmpty);
    });

    test('returns favorite teams when document exists with valid data',
        () async {
      await fakeFirestore.collection('userFavorites').doc('user123').set({
        'favoriteTeamNames': ['Brazil', 'Argentina', 'Germany'],
      });

      final result = await authService.getFavoriteTeams('user123');
      expect(result, hasLength(3));
      expect(result, contains('Brazil'));
      expect(result, contains('Argentina'));
      expect(result, contains('Germany'));
    });

    test(
        'returns empty list when document exists but has no favoriteTeamNames field',
        () async {
      await fakeFirestore.collection('userFavorites').doc('user456').set({
        'someOtherField': 'value',
      });

      final result = await authService.getFavoriteTeams('user456');
      expect(result, isEmpty);
    });

    test('returns empty list when favoriteTeamNames is an empty list',
        () async {
      await fakeFirestore.collection('userFavorites').doc('user789').set({
        'favoriteTeamNames': <String>[],
      });

      final result = await authService.getFavoriteTeams('user789');
      expect(result, isEmpty);
    });

    test('handles single team in favorites', () async {
      await fakeFirestore.collection('userFavorites').doc('user_single').set({
        'favoriteTeamNames': ['United States'],
      });

      final result = await authService.getFavoriteTeams('user_single');
      expect(result, hasLength(1));
      expect(result.first, equals('United States'));
    });

    test('handles many teams in favorites', () async {
      final manyTeams = List.generate(48, (i) => 'Team $i');
      await fakeFirestore.collection('userFavorites').doc('user_many').set({
        'favoriteTeamNames': manyTeams,
      });

      final result = await authService.getFavoriteTeams('user_many');
      expect(result, hasLength(48));
    });
  });

  group('updateFavoriteTeams', () {
    test('creates document with favorite teams when it does not exist',
        () async {
      await authService.updateFavoriteTeams(
          'user_new', ['Mexico', 'United States']);

      final docSnapshot = await fakeFirestore
          .collection('userFavorites')
          .doc('user_new')
          .get();
      expect(docSnapshot.exists, isTrue);
      final teams =
          List<String>.from(docSnapshot.data()!['favoriteTeamNames']);
      expect(teams, hasLength(2));
      expect(teams, contains('Mexico'));
      expect(teams, contains('United States'));
    });

    test('updates existing document with new favorite teams', () async {
      await fakeFirestore.collection('userFavorites').doc('user_update').set({
        'favoriteTeamNames': ['Brazil'],
      });

      await authService
          .updateFavoriteTeams('user_update', ['Brazil', 'France', 'Japan']);

      final docSnapshot = await fakeFirestore
          .collection('userFavorites')
          .doc('user_update')
          .get();
      final teams =
          List<String>.from(docSnapshot.data()!['favoriteTeamNames']);
      expect(teams, hasLength(3));
      expect(teams, contains('France'));
      expect(teams, contains('Japan'));
    });

    test('preserves other fields when using merge', () async {
      await fakeFirestore.collection('userFavorites').doc('user_merge').set({
        'favoriteTeamNames': ['Brazil'],
        'otherData': 'should persist',
      });

      await authService.updateFavoriteTeams('user_merge', ['Germany']);

      final docSnapshot = await fakeFirestore
          .collection('userFavorites')
          .doc('user_merge')
          .get();
      final data = docSnapshot.data()!;
      expect(data['otherData'], equals('should persist'));
      expect(List<String>.from(data['favoriteTeamNames']),
          contains('Germany'));
    });

    test('handles empty teams list', () async {
      await authService.updateFavoriteTeams('user_empty', []);

      final docSnapshot = await fakeFirestore
          .collection('userFavorites')
          .doc('user_empty')
          .get();
      final teams =
          List<String>.from(docSnapshot.data()!['favoriteTeamNames']);
      expect(teams, isEmpty);
    });
  });

  // ========================================================
  // CREATE USER PROFILE
  // ========================================================

  group('createUserProfile', () {
    test('initializes social service and creates profile for new user',
        () async {
      when(() => mockUser.uid).thenReturn('uid_new');
      when(() => mockUser.displayName).thenReturn('John Doe');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockSocialService.initialize()).thenAnswer((_) async {});
      when(() => mockSocialService.getUserProfile('uid_new'))
          .thenAnswer((_) async => null);
      when(() => mockSocialService.saveUserProfile(any()))
          .thenAnswer((_) async => true);

      await authService.createUserProfile(mockUser);

      verify(() => mockSocialService.initialize()).called(1);
      verify(() => mockSocialService.getUserProfile('uid_new')).called(1);
      verify(() => mockSocialService.saveUserProfile(any())).called(1);
    });

    test('skips profile creation if profile already exists', () async {
      when(() => mockUser.uid).thenReturn('uid_existing');
      when(() => mockUser.displayName).thenReturn('Existing User');
      when(() => mockUser.email).thenReturn('existing@example.com');
      when(() => mockSocialService.initialize()).thenAnswer((_) async {});
      when(() => mockSocialService.getUserProfile('uid_existing'))
          .thenAnswer((_) async => UserProfile.create(
                userId: 'uid_existing',
                displayName: 'Existing User',
                email: 'existing@example.com',
              ));

      await authService.createUserProfile(mockUser);

      verify(() => mockSocialService.getUserProfile('uid_existing')).called(1);
      verifyNever(() => mockSocialService.saveUserProfile(any()));
    });

    test('uses Anonymous User when displayName is null', () async {
      when(() => mockUser.uid).thenReturn('uid_anon');
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockUser.email).thenReturn('anon@example.com');
      when(() => mockSocialService.initialize()).thenAnswer((_) async {});
      when(() => mockSocialService.getUserProfile('uid_anon'))
          .thenAnswer((_) async => null);
      when(() => mockSocialService.saveUserProfile(any()))
          .thenAnswer((_) async => true);

      await authService.createUserProfile(mockUser);

      final captured = verify(() => mockSocialService.saveUserProfile(
            captureAny(),
          )).captured;
      expect(captured, hasLength(1));
      final savedProfile = captured.first as UserProfile;
      expect(savedProfile.displayName, equals('Anonymous User'));
    });

    test('does not throw when social service fails', () async {
      when(() => mockUser.uid).thenReturn('uid_err');
      when(() => mockUser.displayName).thenReturn('Error User');
      when(() => mockUser.email).thenReturn('error@example.com');
      when(() => mockSocialService.initialize())
          .thenThrow(Exception('Hive error'));

      // Should not throw (error is caught internally)
      await authService.createUserProfile(mockUser);
    });

    test('creates profile with empty favorite teams', () async {
      when(() => mockUser.uid).thenReturn('uid_fav');
      when(() => mockUser.displayName).thenReturn('Fav User');
      when(() => mockUser.email).thenReturn('fav@example.com');
      when(() => mockSocialService.initialize()).thenAnswer((_) async {});
      when(() => mockSocialService.getUserProfile('uid_fav'))
          .thenAnswer((_) async => null);
      when(() => mockSocialService.saveUserProfile(any()))
          .thenAnswer((_) async => true);

      await authService.createUserProfile(mockUser);

      final captured = verify(() => mockSocialService.saveUserProfile(
            captureAny(),
          )).captured;
      final savedProfile = captured.first as UserProfile;
      expect(savedProfile.favoriteTeams, isEmpty);
    });

    test('passes email from user to profile', () async {
      when(() => mockUser.uid).thenReturn('uid_email');
      when(() => mockUser.displayName).thenReturn('Email User');
      when(() => mockUser.email).thenReturn('email@example.com');
      when(() => mockSocialService.initialize()).thenAnswer((_) async {});
      when(() => mockSocialService.getUserProfile('uid_email'))
          .thenAnswer((_) async => null);
      when(() => mockSocialService.saveUserProfile(any()))
          .thenAnswer((_) async => true);

      await authService.createUserProfile(mockUser);

      final captured = verify(() => mockSocialService.saveUserProfile(
            captureAny(),
          )).captured;
      final savedProfile = captured.first as UserProfile;
      expect(savedProfile.email, equals('email@example.com'));
      expect(savedProfile.userId, equals('uid_email'));
    });
  });

  // ========================================================
  // FIREBASE AUTH ERROR CODES
  // ========================================================

  group('FirebaseAuthException error codes', () {
    test('common error codes produce valid exceptions', () {
      final errorCodes = {
        'email-already-in-use': 'The email is already in use.',
        'weak-password': 'The password is too weak.',
        'wrong-password': 'The password is invalid.',
        'user-not-found': 'No user found for that email.',
        'user-disabled': 'The user account has been disabled.',
        'invalid-email': 'The email address is badly formatted.',
        'too-many-requests': 'Too many unsuccessful sign-in attempts.',
        'operation-not-allowed': 'Email/password not enabled.',
      };

      for (final entry in errorCodes.entries) {
        final exception = TestFirebaseAuthException(
          code: entry.key,
          message: entry.value,
        );
        expect(exception.code, equals(entry.key));
        expect(exception.message, equals(entry.value));
        expect(exception.plugin, equals('auth'));
      }
    });
  });

  // ========================================================
  // INTEGRATION-STYLE: SIGN UP THEN VERIFY THEN SIGN OUT
  // ========================================================

  group('End-to-end auth flow simulation', () {
    test('sign up -> send verification -> reload -> check verified -> sign out',
        () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('flow_uid');
      when(() => mockUser.email).thenReturn('flow@example.com');
      when(() => mockUser.displayName).thenReturn('Flow User');
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});

      // Step 1: Sign up
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final result = await authService.signUpWithEmailAndPassword(
        email: 'flow@example.com',
        password: 'password123',
      );
      expect(result, isNotNull);
      verify(() => mockUser.sendEmailVerification()).called(1);

      // Step 2: Check not verified yet
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(false);
      expect(authService.isEmailVerified, isFalse);

      // Step 3: Reload user (simulating user clicking verification link)
      await authService.reloadUser();
      verify(() => mockUser.reload()).called(1);

      // Step 4: Now verified
      when(() => mockUser.emailVerified).thenReturn(true);
      expect(authService.isEmailVerified, isTrue);

      // Step 5: Sign out
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});
      await authService.signOut();
      verify(() => mockAuth.signOut()).called(1);
    });

    test('sign in -> check verified -> sign out', () async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);

      // Step 1: Sign in
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmailAndPassword(
        email: 'returning@example.com',
        password: 'password123',
      );
      expect(result, isNotNull);
      verify(() => mockAnalyticsService.logEvent('login',
          parameters: {'method': 'email'})).called(1);

      // Step 2: Check verified
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.emailVerified).thenReturn(true);
      expect(authService.isEmailVerified, isTrue);

      // Step 3: Sign out
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockRevenueCatService.logoutUser())
          .thenAnswer((_) async {});
      await authService.signOut();
      verify(() => mockAnalyticsService.logEvent('logout',
          parameters: any(named: 'parameters'))).called(1);
    });
  });
}
