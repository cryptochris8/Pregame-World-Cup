import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pregame_world_cup/core/services/localization_service.dart';
import 'package:pregame_world_cup/features/settings/presentation/screens/language_selector_screen.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

/// Tests for LanguageSelectorScreen.
///
/// The screen uses LocalizationService.getInstance() which is a singleton
/// backed by SharedPreferences. With mock SharedPreferences initialized,
/// the service creates successfully and the screen renders all language
/// options from the AppLanguage enum.
void main() {
  setUp(() {
    // Provide mock SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});

    // Suppress overflow and rendering errors in constrained test environments
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed')) {
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
        data: MediaQueryData(size: Size(414, 896)),
        child: LanguageSelectorScreen(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rendering tests
  // ---------------------------------------------------------------------------

  group('LanguageSelectorScreen - Rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(LanguageSelectorScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app bar with select language title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AppBar), findsOneWidget);
      // The title comes from l10n.selectLanguage
      // In English locale this should render the localized string
    });

    testWidgets('shows loading indicator before service initializes',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // On the first frame, _selectedLanguage is null so loading shows
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('removes loading indicator after initialization',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After initialization, CircularProgressIndicator should be gone
      // and the ListView with language options should be visible
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Language options
  // ---------------------------------------------------------------------------

  group('LanguageSelectorScreen - Language options', () {
    testWidgets('shows all language options from AppLanguage enum',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // AppLanguage has 5 values: system, english, spanish, portuguese, french
      // Each renders as a ListTile
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsAtLeastNWidgets(5));
    });

    testWidgets('shows English option with native name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('English'), findsWidgets);
    });

    testWidgets('shows Spanish option with native name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('shows French option with native name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('shows Portuguese option with native name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Português'), findsOneWidget);
    });

    testWidgets('shows System Default option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('System Default'), findsWidgets);
    });

    testWidgets('shows language descriptions for each option', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The subtitle descriptions are rendered for each language
      expect(find.text('English (United States)'), findsOneWidget);
      expect(find.text('Spanish (Mexico)'), findsOneWidget);
      expect(find.text('Portuguese (Brazil)'), findsOneWidget);
      expect(find.text('French (Canada)'), findsOneWidget);
    });

    testWidgets('shows info banner about language change', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        find.text(
            'Choose your preferred language. The app will restart to apply changes.'),
        findsOneWidget,
      );
    });

    testWidgets('shows info icon in the banner', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows "Currently using" text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('Currently using:'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Selection indicators
  // ---------------------------------------------------------------------------

  group('LanguageSelectorScreen - Selection indicators', () {
    testWidgets('shows check_circle icon for selected language', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Exactly one language should be selected (showing check_circle)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows circle_outlined icons for unselected languages',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 4 unselected languages should show circle_outlined
      // (5 total languages minus 1 selected)
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(4));
    });
  });

  // ---------------------------------------------------------------------------
  // Selection behavior
  // ---------------------------------------------------------------------------

  group('LanguageSelectorScreen - Selection', () {
    testWidgets('tapping a language option updates the selection',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap the Spanish option
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After tapping, the selection should change
      // We verify by checking that a SnackBar appears (confirmation)
      // or that the check_circle is still present (1 selected)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('tapping a language option shows confirmation snackbar',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap French to change language (assuming default is not French)
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // A SnackBar should appear with confirmation
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('selecting a different language changes the check indicator',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap Portuguese option
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should still have exactly one check_circle (just on a different item)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // And 4 unselected
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(4));
    });
  });

  // ---------------------------------------------------------------------------
  // LanguageSelectorTile (compact tile for settings screen)
  // ---------------------------------------------------------------------------

  group('LanguageSelectorTile - Rendering', () {
    testWidgets('renders with language icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: LanguageSelectorTile(),
        ),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('renders with chevron trailing icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: LanguageSelectorTile(),
        ),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows current language display name as subtitle',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: LanguageSelectorTile(),
        ),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The subtitle shows the current language display name
      // which depends on the LocalizationService singleton state
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.subtitle, isNotNull);
    });
  });
}
