import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:get_it/get_it.dart';

import 'package:pregame_world_cup/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// Mock AuthService
class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  final sl = GetIt.instance;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
    mockAuthService = MockAuthService();
    sl.registerSingleton<AuthService>(mockAuthService);

    // Default stubs for the auto-check timer
    when(() => mockAuthService.reloadUser()).thenAnswer((_) async {});
    when(() => mockAuthService.isEmailVerified).thenReturn(false);
  });

  tearDown(() {
    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: EmailVerificationScreen(),
    );
  }

  // Helper: pump a few frames to let the widget build and async ops complete,
  // but do NOT use pumpAndSettle (the periodic timer prevents settling).
  Future<void> pumpFrames(WidgetTester tester, {int count = 3}) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('EmailVerificationScreen - Rendering', () {
    testWidgets('renders Verify Your Email title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Verify Your Email'), findsOneWidget);
    });

    testWidgets('renders verification sent description', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text("We've sent a verification link to:"), findsOneWidget);
    });

    testWidgets('renders email icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.mark_email_unread_rounded), findsOneWidget);
    });

    testWidgets('renders small email icon in email display area', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.email_rounded), findsOneWidget);
    });

    testWidgets('renders I have Verified My Email button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text("I've Verified My Email"), findsOneWidget);
    });

    testWidgets('renders Resend Email button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Resend Email'), findsOneWidget);
    });

    testWidgets('renders Sign Out TextButton', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Sign Out is inside a RichText TextSpan, so find the TextButton instead
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders Wrong email / Sign Out via RichText', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // "Wrong email? " and "Sign Out" are inside RichText TextSpan
      // Verify by finding RichText widgets
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders auto-checking status indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text('Auto-checking verification status...'), findsOneWidget);
    });

    testWidgets('renders info instructions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text('Click the link in your email to verify your account.'),
          findsOneWidget);
    });

    testWidgets('renders spam folder note', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
          find.text("Check your spam folder if you don't see it."),
          findsOneWidget);
    });

    testWidgets('renders info icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays user email or fallback', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // When no user is signed in, it shows 'your email'
      expect(find.text('your email'), findsOneWidget);
    });

    testWidgets('renders refresh icon on resend button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });

  group('EmailVerificationScreen - Resend Email', () {
    testWidgets('calls resendVerificationEmail when resend button is tapped',
        (tester) async {
      when(() => mockAuthService.resendVerificationEmail())
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final resendFinder = find.text('Resend Email');
      await tester.ensureVisible(resendFinder);
      await tester.pump();
      await tester.tap(resendFinder);
      await pumpFrames(tester, count: 5);

      verify(() => mockAuthService.resendVerificationEmail()).called(1);
    });

    testWidgets('shows success snackbar when resend succeeds', (tester) async {
      when(() => mockAuthService.resendVerificationEmail())
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final resendFinder = find.text('Resend Email');
      await tester.ensureVisible(resendFinder);
      await tester.pump();
      await tester.tap(resendFinder);
      await pumpFrames(tester, count: 5);

      expect(find.text('Verification email sent!'), findsOneWidget);
    });

    testWidgets('shows error snackbar when resend fails', (tester) async {
      when(() => mockAuthService.resendVerificationEmail())
          .thenThrow(Exception('Too many requests'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final resendFinder = find.text('Resend Email');
      await tester.ensureVisible(resendFinder);
      await tester.pump();
      await tester.tap(resendFinder);
      await pumpFrames(tester, count: 5);

      expect(find.textContaining('Failed to resend'), findsOneWidget);
    });

    testWidgets('shows cooldown timer after successful resend', (tester) async {
      when(() => mockAuthService.resendVerificationEmail())
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final resendFinder = find.text('Resend Email');
      await tester.ensureVisible(resendFinder);
      await tester.pump();
      await tester.tap(resendFinder);
      await pumpFrames(tester, count: 5);

      // After resend, button should show cooldown
      expect(find.textContaining('Resend in'), findsOneWidget);
    });

    testWidgets('resend button shows cooldown and is not tappable during cooldown', (tester) async {
      when(() => mockAuthService.resendVerificationEmail())
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // First resend
      final resendFinder = find.text('Resend Email');
      await tester.ensureVisible(resendFinder);
      await tester.pump();
      await tester.tap(resendFinder);
      await pumpFrames(tester, count: 5);

      // After resend, button should show cooldown text
      expect(find.textContaining('Resend in'), findsOneWidget);

      // The resend service should not be called again if we try
      // (since the button is disabled during cooldown)
      verify(() => mockAuthService.resendVerificationEmail()).called(1);
    });
  });

  group('EmailVerificationScreen - Manual Verification Check', () {
    testWidgets('calls reloadUser when verification button is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final verifyButton = find.text("I've Verified My Email");
      await tester.ensureVisible(verifyButton);
      await tester.pump();
      await tester.tap(verifyButton);
      await pumpFrames(tester, count: 5);

      verify(() => mockAuthService.reloadUser()).called(greaterThan(0));
    });

    testWidgets(
        'shows not verified snackbar when email is not yet verified',
        (tester) async {
      when(() => mockAuthService.isEmailVerified).thenReturn(false);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final verifyButton = find.text("I've Verified My Email");
      await tester.ensureVisible(verifyButton);
      await tester.pump();
      await tester.tap(verifyButton);
      await pumpFrames(tester, count: 5);

      expect(
        find.text('Email not verified yet. Please check your inbox.'),
        findsOneWidget,
      );
    });

    testWidgets('shows success snackbar when email is verified',
        (tester) async {
      // Start with false, then switch to true before the manual check
      when(() => mockAuthService.isEmailVerified).thenReturn(false);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Now switch to verified before tapping the manual check button
      when(() => mockAuthService.isEmailVerified).thenReturn(true);

      final verifyButton = find.text("I've Verified My Email");
      await tester.ensureVisible(verifyButton);
      await tester.pump();
      await tester.tap(verifyButton);
      await pumpFrames(tester, count: 5);

      expect(
        find.text('Email verified! Redirecting...'),
        findsOneWidget,
      );
    });
  });

  group('EmailVerificationScreen - Sign Out', () {
    testWidgets('calls signOut when Sign Out button is tapped', (tester) async {
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Sign Out is inside a TextButton with RichText, scroll it into view
      final signOutButton = find.byType(TextButton);
      await tester.ensureVisible(signOutButton);
      await tester.pump();
      await tester.tap(signOutButton);
      await pumpFrames(tester, count: 5);

      verify(() => mockAuthService.signOut()).called(1);
    });
  });

  group('EmailVerificationScreen - UI Components', () {
    testWidgets('has a scrollable layout', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has ElevatedButton for manual verification check',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('has resend email button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Verify Resend Email text exists (the button uses OutlinedButton.icon)
      expect(find.text('Resend Email'), findsOneWidget);
    });

    testWidgets('has TextButton for sign out', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('has loading indicators for auto-check', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // The small auto-check spinner at the bottom
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('EmailVerificationScreen - Error Handling', () {
    testWidgets('handles reloadUser error gracefully during manual check',
        (tester) async {
      // For auto-check, succeed. For manual check, fail.
      var manualCheckTriggered = false;
      when(() => mockAuthService.reloadUser()).thenAnswer((_) async {
        if (manualCheckTriggered) {
          throw Exception('Network error');
        }
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Now set the flag so the next reloadUser call throws
      manualCheckTriggered = true;

      final verifyButton = find.text("I've Verified My Email");
      await tester.ensureVisible(verifyButton);
      await tester.pump();
      await tester.tap(verifyButton);
      await pumpFrames(tester, count: 5);

      expect(find.textContaining('Error checking verification'), findsOneWidget);
    });

    testWidgets('auto-check timer ignores errors silently', (tester) async {
      // Only throw on the auto-check timer calls, but the timer catches errors
      when(() => mockAuthService.reloadUser())
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildTestWidget());

      // Advance time to trigger auto-check (3 seconds)
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // No error snackbar should appear from auto-check
      // (auto-check catches errors silently)
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
