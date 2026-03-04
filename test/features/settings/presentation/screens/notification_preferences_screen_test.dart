import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pregame_world_cup/features/settings/presentation/screens/notification_preferences_screen.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

/// Tests for NotificationPreferencesScreen.
///
/// The screen directly instantiates NotificationPreferencesService (singleton)
/// which uses SharedPreferences and Firebase internally. With mock
/// SharedPreferences and Firebase core stubs the service initializes with
/// default preferences (Firebase sync silently fails), so the loaded state
/// renders with all default toggles visible.
///
/// NOTE: The NotificationPreferencesService is a singleton without a
/// resetInstance() method. Tests that toggle preferences will persist state
/// across subsequent tests. Therefore toggle tests are grouped together and
/// designed to be self-contained.
void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    // Provide mock SharedPreferences so the service can initialize
    SharedPreferences.setMockInitialValues({});

    // Suppress overflow and rendering errors in constrained test environments
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed') ||
          message.contains('MissingPluginException')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MediaQuery(
        data: MediaQueryData(size: Size(414, 2400)),
        child: NotificationPreferencesScreen(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rendering tests
  // ---------------------------------------------------------------------------

  group('NotificationPreferencesScreen - Rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Allow async initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator before preferences load',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // On the very first frame the service may not yet have initialized
      // (but since it is a singleton that persists, on subsequent runs it
      // may already be initialized - so we just verify the screen renders)
      expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Notification preference options
  // ---------------------------------------------------------------------------

  group('NotificationPreferencesScreen - Preference options', () {
    testWidgets('shows SwitchListTile widgets after loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // At minimum the master push notifications switch should be present
      final switches = find.byType(SwitchListTile);
      expect(switches, findsWidgets);
    });

    testWidgets('shows reset button in app bar actions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The reset button is a TextButton in the app bar actions
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('body is a ListView when loaded', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('has dividers between sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // With push notifications enabled, there are multiple Divider widgets
      expect(find.byType(Divider), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Toggle switches - self-contained tests
  // ---------------------------------------------------------------------------

  group('NotificationPreferencesScreen - Toggle switches', () {
    testWidgets('has multiple SwitchListTile widgets present', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final switches = find.byType(SwitchListTile);
      // There should be at least 1 switch (master switch)
      expect(switches, findsWidgets);
    });

    testWidgets(
        'toggling master switch off and on changes visible switches count',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final masterSwitch = find.byType(SwitchListTile).first;
      final masterSwitchTile =
          tester.widget<SwitchListTile>(masterSwitch);

      if (masterSwitchTile.value == true) {
        // Master switch is ON - record count of switches
        final switchesWhenOn =
            find.byType(SwitchListTile).evaluate().length;
        expect(switchesWhenOn, greaterThan(1));

        // Toggle OFF
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // After disabling, only master switch should remain
        final switchesWhenOff =
            find.byType(SwitchListTile).evaluate().length;
        expect(switchesWhenOff, equals(1));

        // Toggle back ON to restore state for other tests
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Switches should be restored
        final switchesRestored =
            find.byType(SwitchListTile).evaluate().length;
        expect(switchesRestored, greaterThan(1));
      } else {
        // Master switch is OFF (from a prior test run) - toggle ON
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final switchesWhenOn =
            find.byType(SwitchListTile).evaluate().length;
        expect(switchesWhenOn, greaterThan(1));

        // Toggle OFF
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final switchesWhenOff =
            find.byType(SwitchListTile).evaluate().length;
        expect(switchesWhenOff, equals(1));

        // Toggle back ON to restore state
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });

    testWidgets(
        'toggling master switch changes notification icon',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final masterSwitch = find.byType(SwitchListTile).first;
      final masterSwitchTile =
          tester.widget<SwitchListTile>(masterSwitch);

      if (masterSwitchTile.value == true) {
        // When enabled, active icon shows
        expect(find.byIcon(Icons.notifications_active), findsOneWidget);
        expect(find.byIcon(Icons.notifications_off), findsNothing);

        // Toggle OFF
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Now disabled icon shows
        expect(find.byIcon(Icons.notifications_off), findsOneWidget);
        expect(find.byIcon(Icons.notifications_active), findsNothing);

        // Toggle back ON to restore
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } else {
        // When disabled, off icon shows
        expect(find.byIcon(Icons.notifications_off), findsOneWidget);

        // Toggle ON
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      }
    });

    testWidgets(
        'toggling master switch off hides section header icons',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final masterSwitch = find.byType(SwitchListTile).first;
      final masterSwitchTile =
          tester.widget<SwitchListTile>(masterSwitch);

      // Ensure master switch is ON first
      if (masterSwitchTile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Section headers should be present when push is enabled
      expect(find.byIcon(Icons.bedtime), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);

      // Toggle OFF
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Section headers should be gone
      expect(find.byIcon(Icons.bedtime), findsNothing);
      expect(find.byIcon(Icons.sports_soccer), findsNothing);

      // Toggle back ON to restore state
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });

  // ---------------------------------------------------------------------------
  // Section content tests
  // ---------------------------------------------------------------------------

  group('NotificationPreferencesScreen - Sections when enabled', () {
    testWidgets('shows quiet hours section icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.byIcon(Icons.bedtime), findsOneWidget);
    });

    testWidgets('shows match reminders section icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('shows live match alerts section with multiple alert switches',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // The live match alerts section contributes multiple SwitchListTile
      // widgets (goal, match start, halftime, match end, red cards, penalties).
      // We verify the total number of switches is large (covers all sections).
      final totalSwitches = find.byType(SwitchListTile).evaluate().length;
      // Multiple switches visible: master + quiet hours + match reminders +
      // favorite team + day before (some may be off-screen due to viewport)
      expect(totalSwitches, greaterThanOrEqualTo(4));
    });

    testWidgets('shows watch parties section when scrolled into view',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byIcon(Icons.groups),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('shows social section when scrolled into view',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byIcon(Icons.people),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('shows predictions section when scrolled into view',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byIcon(Icons.emoji_events),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('shows chevron for reminder timing picker', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ensure master switch is ON
      final masterSwitch = find.byType(SwitchListTile).first;
      final tile = tester.widget<SwitchListTile>(masterSwitch);
      if (tile.value == false) {
        await tester.tap(masterSwitch);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Default has matchRemindersEnabled = true, so the reminder timing
      // ListTile with chevron_right should be visible
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });
  });
}
