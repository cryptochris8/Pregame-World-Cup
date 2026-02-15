import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:pregame_world_cup/features/auth/presentation/screens/login_screen.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';

// Mock AuthService
class MockAuthService extends Mock implements AuthService {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;
  final sl = GetIt.instance;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    // Reset GetIt and register mock
    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
    mockAuthService = MockAuthService();
    sl.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() {
    if (sl.isRegistered<AuthService>()) {
      sl.unregister<AuthService>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  /// Helper to tap the mode-switch TextButton (which contains RichText).
  /// In login mode it says "Don't have an account? Sign Up"
  /// In signup mode it says "Already have an account? Sign In"
  /// Uses ensureVisible to scroll the button into view before tapping.
  Future<void> tapModeSwitchButton(WidgetTester tester) async {
    final textButton = find.byType(TextButton);
    expect(textButton, findsOneWidget);
    await tester.ensureVisible(textButton);
    await tester.pumpAndSettle();
    await tester.tap(textButton);
    await tester.pumpAndSettle();
  }

  group('LoginScreen - Rendering', () {
    testWidgets('renders the PREGAME title text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('PREGAME'), findsOneWidget);
    });

    testWidgets('renders the tagline text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Where Sports Fans Connect'), findsOneWidget);
    });

    testWidgets('renders email text field with label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders password text field with label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders email hint text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('renders password hint text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('renders Sign In button in login mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders Welcome Back title in login mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('renders mode switch TextButton', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The TextButton is the switch-mode button with RichText inside
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders email icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email_rounded), findsOneWidget);
    });

    testWidgets('renders lock icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('renders two TextFormField widgets', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('renders the app logo image', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('LoginScreen - Mode Switching', () {
    testWidgets('switches to sign up mode when switch button is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially in login mode
      expect(find.text('Welcome Back'), findsOneWidget);

      // Tap the TextButton to switch modes
      await tapModeSwitchButton(tester);

      // Now in sign up mode
      expect(find.text('Join Pregame'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('switches back to login mode from sign up mode',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up mode
      await tapModeSwitchButton(tester);
      expect(find.text('Join Pregame'), findsOneWidget);

      // Switch back to login mode
      await tapModeSwitchButton(tester);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('shows Create Account button in sign up mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tapModeSwitchButton(tester);

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('clears form fields when switching modes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter text in email field
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Switch mode
      await tapModeSwitchButton(tester);

      // Fields should be cleared
      expect(find.text('test@example.com'), findsNothing);
    });
  });

  group('LoginScreen - Form Validation', () {
    testWidgets('shows error when email is empty on submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Enter only password
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when email lacks @ symbol', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalidemail.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty on submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, '12345');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('no validation error with valid email and password',
        (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    testWidgets('validates email with exactly @ character', (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'a@b');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('validates password with exactly 6 characters', (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, '123456');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    testWidgets('shows both email and password errors when both are invalid',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Leave both fields empty and submit
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('LoginScreen - Auth Service Interaction', () {
    testWidgets('calls signInWithEmailAndPassword in login mode',
        (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('calls signUpWithEmailAndPassword in sign up mode',
        (tester) async {
      when(() => mockAuthService.signUpWithEmailAndPassword(
            email: 'new@example.com',
            password: 'password123',
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up mode by tapping TextButton
      await tapModeSwitchButton(tester);

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'new@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signUpWithEmailAndPassword(
            email: 'new@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('shows error message when sign in fails', (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows error message when sign up fails', (tester) async {
      when(() => mockAuthService.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Email already in use'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up mode
      await tapModeSwitchButton(tester);

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'existing@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('displays error icon with error message', (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Test error'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows loading indicator during auth operation',
        (tester) async {
      // Use a Completer to control when the Future resolves
      final completer = Completer<UserCredential?>();
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete(MockUserCredential());
      await tester.pumpAndSettle();
    });

    testWidgets('error message is cleared when switching modes',
        (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Some error'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Trigger error
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Some error'), findsOneWidget);

      // Switch mode should clear error - tap the TextButton
      await tapModeSwitchButton(tester);

      expect(find.text('Some error'), findsNothing);
    });

    testWidgets('trims email input before sending', (tester) async {
      when(() => mockAuthService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, '  test@example.com  ');

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });
  });

  group('LoginScreen - UI Components', () {
    testWidgets('has a scrollable layout', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has a Form widget with validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('password field is obscured', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final passwordTextField = tester.widget<TextField>(textFields.at(1));
      expect(passwordTextField.obscureText, isTrue);
    });

    testWidgets('email field has email keyboard type', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final emailTextField = tester.widget<TextField>(textFields.first);
      expect(emailTextField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('has an ElevatedButton for submission', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('has a TextButton for mode switching', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
