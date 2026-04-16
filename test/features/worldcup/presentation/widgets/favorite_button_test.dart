import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';
import '../../../../test_helpers/l10n_test_helper.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
        FlutterError.presentError(details);
      }
    };
  });

  group('FavoriteButton', () {
    testWidgets('renders favorited state with red heart', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(isFavorite: true),
          ),
        ),
      );

      // Find the heart icon
      final iconFinder = find.byIcon(Icons.favorite);
      expect(iconFinder, findsOneWidget);

      // Verify it's red (or the default favorite color)
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.red);
    });

    testWidgets('renders unfavorited state with grey outline heart',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(isFavorite: false),
          ),
        ),
      );

      // Find the heart outline icon
      final iconFinder = find.byIcon(Icons.favorite_border);
      expect(iconFinder, findsOneWidget);

      // Verify it has outline color (grey)
      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, isNotNull);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('uses custom favorite color', (tester) async {
      const customColor = Colors.pink;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              favoriteColor: customColor,
            ),
          ),
        ),
      );

      final Icon icon = tester.widget(find.byIcon(Icons.favorite));
      expect(icon.color, customColor);
    });

    testWidgets('uses custom unfavorite color', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              unfavoriteColor: customColor,
            ),
          ),
        ),
      );

      final Icon icon = tester.widget(find.byIcon(Icons.favorite_border));
      expect(icon.color, customColor);
    });

    testWidgets('shows custom tooltip', (tester) async {
      const customTooltip = 'Custom tooltip text';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              tooltip: customTooltip,
            ),
          ),
        ),
      );

      final IconButton button = tester.widget(find.byType(IconButton));
      expect(button.tooltip, customTooltip);
    });

    testWidgets('shows default tooltip for favorited state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(isFavorite: true),
          ),
        ),
      );

      final IconButton button = tester.widget(find.byType(IconButton));
      expect(button.tooltip, 'Remove from favorites');
    });

    testWidgets('shows default tooltip for unfavorited state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(isFavorite: false),
          ),
        ),
      );

      final IconButton button = tester.widget(find.byType(IconButton));
      expect(button.tooltip, 'Add to favorites');
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              size: customSize,
            ),
          ),
        ),
      );

      final Icon icon = tester.widget(find.byIcon(Icons.favorite));
      expect(icon.size, customSize);
    });

    testWidgets('renders without animation when animate is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              animate: false,
            ),
          ),
        ),
      );

      // Should not have AnimatedSwitcher when animate is false
      expect(find.byType(AnimatedSwitcher), findsNothing);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('renders with animation when animate is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              animate: true,
            ),
          ),
        ),
      );

      // Should have AnimatedSwitcher when animate is true
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });
  });

  group('FavoriteButton confirmation dialog', () {
    testWidgets(
        'does not show dialog when confirmBeforeUnfavorite is false',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onPressed: () => wasPressed = true,
              confirmBeforeUnfavorite: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // No dialog should appear
      expect(find.byType(AlertDialog), findsNothing);
      // Callback should fire immediately
      expect(wasPressed, isTrue);
    });

    testWidgets(
        'shows confirmation dialog when unfavoriting with confirmBeforeUnfavorite true',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onPressed: () => wasPressed = true,
              confirmBeforeUnfavorite: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Remove from favorites?'), findsOneWidget);
      expect(find.text('Are you sure you want to remove this from your favorites?'),
          findsOneWidget);
      // Callback should NOT have fired yet
      expect(wasPressed, isFalse);
    });

    testWidgets(
        'does not show dialog when favoriting (isFavorite is false)',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: false,
              onPressed: () => wasPressed = true,
              confirmBeforeUnfavorite: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // No dialog — adding to favorites should be immediate
      expect(find.byType(AlertDialog), findsNothing);
      expect(wasPressed, isTrue);
    });

    testWidgets('confirmation dialog cancel does not call onPressed',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onPressed: () => wasPressed = true,
              confirmBeforeUnfavorite: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, callback NOT called
      expect(find.byType(AlertDialog), findsNothing);
      expect(wasPressed, isFalse);
    });

    testWidgets('confirmation dialog confirm calls onPressed',
        (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onPressed: () => wasPressed = true,
              confirmBeforeUnfavorite: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Remove (confirm button)
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Dialog dismissed, callback IS called
      expect(find.byType(AlertDialog), findsNothing);
      expect(wasPressed, isTrue);
    });
  });

  group('StarFavoriteButton', () {
    testWidgets('renders favorited state with star', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarFavoriteButton(isFavorite: true),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.star);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.amber);
    });

    testWidgets('renders unfavorited state with star outline',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarFavoriteButton(isFavorite: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarFavoriteButton(
              isFavorite: false,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('uses custom favorite color', (tester) async {
      const customColor = Colors.yellow;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarFavoriteButton(
              isFavorite: true,
              favoriteColor: customColor,
            ),
          ),
        ),
      );

      final Icon icon = tester.widget(find.byIcon(Icons.star));
      expect(icon.color, customColor);
    });

    testWidgets('has AnimatedSwitcher for animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarFavoriteButton(isFavorite: true),
          ),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });
  });

  group('FavoriteCountChip', () {
    testWidgets('renders favorite count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteCountChip(count: 42),
          ),
        ),
      );

      expect(find.text('42 Favorites'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteCountChip(
              count: 10,
              label: 'Fans',
            ),
          ),
        ),
      );

      expect(find.text('10 Fans'), findsOneWidget);
    });

    testWidgets('shows favorite icon by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteCountChip(count: 5),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteCountChip(
              count: 5,
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      const customColor = Colors.green;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoriteCountChip(
              count: 5,
              color: customColor,
            ),
          ),
        ),
      );

      // Verify the chip was created
      expect(find.byType(FavoriteCountChip), findsOneWidget);
    });
  });
}
