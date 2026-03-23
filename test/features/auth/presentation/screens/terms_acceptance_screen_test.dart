import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/auth/presentation/screens/terms_acceptance_screen.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  Widget buildTestWidget({VoidCallback? onAccepted}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TermsAcceptanceScreen(
        onAccepted: onAccepted ?? () {},
      ),
    );
  }

  group('TermsAcceptanceScreen - Rendering', () {
    testWidgets('renders with title "Terms of Service"', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Please review and accept our terms to continue'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Scroll down to review all terms" when not scrolled',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Scroll down to review all terms'),
        findsOneWidget,
      );
    });

    testWidgets('accept button is disabled before scrolling to bottom',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the ElevatedButton
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      // onPressed should be null when not scrolled to bottom
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('shows "Decline and Sign Out" button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Decline and Sign Out'), findsOneWidget);
    });

    testWidgets('contains "Zero Tolerance Policy" section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The section may need scrolling to be visible, but it should exist in the tree
      expect(
        find.text('Zero Tolerance Policy', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('contains "Community Guidelines" section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Community Guidelines', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('contains "Content Moderation" section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Content Moderation', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('contains "Enforcement" section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Enforcement', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('contains "Full Terms" and "Privacy Policy" links',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Full Terms', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Privacy Policy', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
        'button text changes to agree text after scrolling to bottom',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the SingleChildScrollView's ScrollController by scrolling
      // the Privacy Policy link into view (which is near the bottom of content)
      await tester.scrollUntilVisible(
        find.text('Privacy Policy'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // After scrolling near the bottom, the button text should change
      expect(
        find.text('I Agree to the Terms of Service'),
        findsOneWidget,
      );
    });

    testWidgets('contains End User License Agreement section',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('End User License Agreement', skipOffstage: false),
        findsOneWidget,
      );
    });
  });
}
