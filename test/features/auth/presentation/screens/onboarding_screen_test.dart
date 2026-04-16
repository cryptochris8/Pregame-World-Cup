import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'package:pregame_world_cup/features/auth/presentation/screens/onboarding_screen.dart';

final sl = GetIt.instance;

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    // Reset GetIt for each test
    await sl.reset();

    // Set up SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => prefs);
  });

  Widget buildTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(
      home: OnboardingScreen(
        onComplete: onComplete ?? () {},
      ),
    );
  }

  group('OnboardingScreen - Rendering', () {
    testWidgets('renders page 1 with welcome title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Pregame'), findsOneWidget);
    });

    testWidgets('renders page 1 with app description', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Your ultimate companion for the 2026 World Cup.'),
        findsOneWidget,
      );
    });

    testWidgets('shows Skip button on first page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows 3 dot indicators', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // There should be 3 AnimatedContainers for the dots
      final dots = find.byType(AnimatedContainer);
      // AnimatedContainer is used in dot indicators; there should be at least 3
      expect(dots, findsAtLeast(3));
    });

    testWidgets('shows logo image on first page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('OnboardingScreen - Navigation', () {
    testWidgets('swiping to page 2 shows Match Intelligence', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Swipe left to go to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Match Intelligence'), findsOneWidget);
      expect(find.text('AI-powered predictions for every match'), findsOneWidget);
      expect(find.text('Expert pregame analysis and insights'), findsOneWidget);
      expect(find.text('City guides for all host venues'), findsOneWidget);
    });

    testWidgets('swiping to page 3 shows Connect with Fans', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Swipe to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Swipe to page 3
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Connect with Fans'), findsOneWidget);
      expect(find.text('Find watch parties near you'), findsOneWidget);
      expect(find.text('Discover bars, restaurants, and fan zones'), findsOneWidget);
      expect(find.text('Connect with fans from around the world'), findsOneWidget);
    });

    testWidgets('page 3 shows Get Started button instead of Next',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Swipe to page 3
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('tapping Next advances to next page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Match Intelligence'), findsOneWidget);
    });
  });

  group('OnboardingScreen - Completion', () {
    testWidgets('tapping Get Started calls onComplete', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pumpAndSettle();

      // Navigate to last page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('tapping Get Started sets SharedPreferences flag',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Navigate to last page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(prefs.getBool(kHasSeenOnboardingKey), isTrue);
    });

    testWidgets('tapping Skip calls onComplete', (tester) async {
      bool completed = false;
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('tapping Skip sets SharedPreferences flag', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(prefs.getBool(kHasSeenOnboardingKey), isTrue);
    });
  });

  group('OnboardingScreen - Static helpers', () {
    test('hasBeenSeen returns false by default', () async {
      final result = await OnboardingScreen.hasBeenSeen();
      expect(result, isFalse);
    });

    test('hasBeenSeen returns true after markAsSeen', () async {
      await OnboardingScreen.markAsSeen();
      final result = await OnboardingScreen.hasBeenSeen();
      expect(result, isTrue);
    });
  });

  group('OnboardingScreen - No prohibited terms', () {
    testWidgets('does not contain any prohibited trademarked terms',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check all 3 pages for prohibited terms
      for (int i = 0; i < 3; i++) {
        // Verify no prohibited terms appear anywhere
        expect(find.textContaining('FIFA'), findsNothing);

        if (i < 2) {
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
