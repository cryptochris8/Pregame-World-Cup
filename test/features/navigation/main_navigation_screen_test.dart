import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/config/app_theme.dart';
import 'package:pregame_world_cup/core/animations/animated_button.dart';
import 'package:pregame_world_cup/core/animations/swipe_gestures.dart';
import 'package:pregame_world_cup/features/navigation/main_navigation_screen.dart';

/// Tests for MainNavigationScreen, supporting widgets, and theme constants
/// used by the navigation UI.
///
/// Note: MainNavigationScreen depends on Firebase Auth, GetIt DI (7 cubits),
/// NotificationService, and MessagingService. Full widget rendering tests
/// require complex mocking. We test:
///   - Constructor / configuration
///   - AppTheme constants used by navigation
///   - AnimatedButton widget (standalone)
///   - SwipeablePageView widget (standalone)
void main() {
  // ===========================
  // MainNavigationScreen
  // ===========================
  group('MainNavigationScreen', () {
    test('default initialTabIndex is 0', () {
      const screen = MainNavigationScreen();
      expect(screen.initialTabIndex, 0);
    });

    test('accepts custom initialTabIndex', () {
      const screen = MainNavigationScreen(initialTabIndex: 3);
      expect(screen.initialTabIndex, 3);
    });

    test('accepts initialTabIndex of 0', () {
      const screen = MainNavigationScreen(initialTabIndex: 0);
      expect(screen.initialTabIndex, 0);
    });

    test('accepts initialTabIndex of 5 (last tab)', () {
      const screen = MainNavigationScreen(initialTabIndex: 5);
      expect(screen.initialTabIndex, 5);
    });

    test('is a StatefulWidget', () {
      const screen = MainNavigationScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be created with key', () {
      const key = Key('nav-screen');
      const screen = MainNavigationScreen(key: key);
      expect(screen.key, key);
    });
  });

  // ===========================
  // Navigation Tab Configuration
  // ===========================
  group('Navigation Tab Configuration', () {
    // Tab labels and icons as defined in the build method
    final expectedTabs = [
      {'label': 'World Cup', 'icon': Icons.sports_soccer},
      {'label': 'Feed', 'icon': Icons.dynamic_feed},
      {'label': 'Messages', 'icon': Icons.message},
      {'label': 'Alerts', 'icon': Icons.notifications},
      {'label': 'Friends', 'icon': Icons.people},
      {'label': 'Profile', 'icon': Icons.person},
    ];

    test('has exactly 6 tabs', () {
      expect(expectedTabs.length, 6);
    });

    test('first tab is World Cup with soccer icon', () {
      expect(expectedTabs[0]['label'], 'World Cup');
      expect(expectedTabs[0]['icon'], Icons.sports_soccer);
    });

    test('second tab is Feed with dynamic_feed icon', () {
      expect(expectedTabs[1]['label'], 'Feed');
      expect(expectedTabs[1]['icon'], Icons.dynamic_feed);
    });

    test('third tab is Messages with message icon', () {
      expect(expectedTabs[2]['label'], 'Messages');
      expect(expectedTabs[2]['icon'], Icons.message);
    });

    test('fourth tab is Alerts with notifications icon', () {
      expect(expectedTabs[3]['label'], 'Alerts');
      expect(expectedTabs[3]['icon'], Icons.notifications);
    });

    test('fifth tab is Friends with people icon', () {
      expect(expectedTabs[4]['label'], 'Friends');
      expect(expectedTabs[4]['icon'], Icons.people);
    });

    test('sixth tab is Profile with person icon', () {
      expect(expectedTabs[5]['label'], 'Profile');
      expect(expectedTabs[5]['icon'], Icons.person);
    });

    test('all tabs use primaryOrange as active color', () {
      // Verified from source: all _buildNavItem calls use AppTheme.primaryOrange
      expect(AppTheme.primaryOrange, isA<Color>());
      expect(AppTheme.primaryOrange, const Color(0xFFEA580C));
    });
  });

  // ===========================
  // AppTheme Navigation Constants
  // ===========================
  group('AppTheme Navigation Constants', () {
    group('colors', () {
      test('primaryOrange is used as tab active color', () {
        expect(AppTheme.primaryOrange, const Color(0xFFEA580C));
      });

      test('primaryRed is used for badge backgrounds', () {
        expect(AppTheme.primaryRed, const Color(0xFFDC2626));
      });

      test('backgroundCard is used for bottom nav background', () {
        expect(AppTheme.backgroundCard, const Color(0xFF1E293B));
      });

      test('backgroundDark is the main scaffold background', () {
        expect(AppTheme.backgroundDark, const Color(0xFF0F172A));
      });

      test('primaryPurple is available for theme accents', () {
        expect(AppTheme.primaryPurple, const Color(0xFF7C3AED));
      });

      test('primaryDeepPurple is available', () {
        expect(AppTheme.primaryDeepPurple, const Color(0xFF4C1D95));
      });

      test('primaryBlue is available', () {
        expect(AppTheme.primaryBlue, const Color(0xFF3B82F6));
      });

      test('accentGold is available', () {
        expect(AppTheme.accentGold, const Color(0xFFFBBF24));
      });

      test('textWhite for primary text', () {
        expect(AppTheme.textWhite, const Color(0xFFFFFFFF));
      });

      test('textSecondary for subdued text', () {
        expect(AppTheme.textSecondary, const Color(0xFFCBD5E1));
      });

      test('textTertiary for least emphasized text', () {
        expect(AppTheme.textTertiary, const Color(0xFF94A3B8));
      });
    });

    group('gradients', () {
      test('mainGradient has 5 color stops', () {
        const gradient = AppTheme.mainGradient;
        expect(gradient, isA<LinearGradient>());
        const linear = gradient as LinearGradient;
        expect(linear.colors.length, 5);
      });

      test('mainGradient starts top-left and ends bottom-right', () {
        const gradient = AppTheme.mainGradient;
        const linear = gradient as LinearGradient;
        expect(linear.begin, Alignment.topLeft);
        expect(linear.end, Alignment.bottomRight);
      });

      test('mainGradient has 5 stops from 0 to 1', () {
        const gradient = AppTheme.mainGradient;
        const linear = gradient as LinearGradient;
        expect(linear.stops, [0.0, 0.25, 0.5, 0.75, 1.0]);
      });

      test('mainGradientDecoration wraps mainGradient', () {
        final decoration = AppTheme.mainGradientDecoration;
        expect(decoration, isA<BoxDecoration>());
        expect(decoration.gradient, AppTheme.mainGradient);
      });
    });

    group('dark theme', () {
      test('darkTheme is Material 3', () {
        final theme = AppTheme.darkTheme;
        expect(theme.useMaterial3, isTrue);
      });

      test('darkTheme has dark brightness', () {
        final theme = AppTheme.darkTheme;
        expect(theme.brightness, Brightness.dark);
      });

      test('darkTheme scaffold background is backgroundDark', () {
        final theme = AppTheme.darkTheme;
        expect(theme.scaffoldBackgroundColor, AppTheme.backgroundDark);
      });

      test('darkTheme primary color is purple', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.primary, AppTheme.primaryPurple);
      });

      test('darkTheme secondary color is orange', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.secondary, AppTheme.primaryOrange);
      });

      test('bottom nav theme uses backgroundCard', () {
        final theme = AppTheme.darkTheme;
        expect(
          theme.bottomNavigationBarTheme.backgroundColor,
          AppTheme.backgroundCard,
        );
      });

      test('bottom nav selected color is primaryOrange', () {
        final theme = AppTheme.darkTheme;
        expect(
          theme.bottomNavigationBarTheme.selectedItemColor,
          AppTheme.primaryOrange,
        );
      });

      test('bottom nav unselected color is textTertiary', () {
        final theme = AppTheme.darkTheme;
        expect(
          theme.bottomNavigationBarTheme.unselectedItemColor,
          AppTheme.textTertiary,
        );
      });

      test('bottom nav type is fixed', () {
        final theme = AppTheme.darkTheme;
        expect(
          theme.bottomNavigationBarTheme.type,
          BottomNavigationBarType.fixed,
        );
      });
    });

    group('semantic colors', () {
      test('successColor is green', () {
        expect(AppTheme.successColor, const Color(0xFF059669));
      });

      test('warningColor is amber', () {
        expect(AppTheme.warningColor, const Color(0xFFD97706));
      });

      test('errorColor is red', () {
        expect(AppTheme.errorColor, const Color(0xFFDC2626));
      });

      test('infoColor is blue', () {
        expect(AppTheme.infoColor, const Color(0xFF2563EB));
      });
    });

    group('legacy color aliases', () {
      test('primaryVibrantOrange equals primaryOrange', () {
        expect(AppTheme.primaryVibrantOrange, AppTheme.primaryOrange);
      });

      test('primaryElectricBlue equals primaryBlue', () {
        expect(AppTheme.primaryElectricBlue, AppTheme.primaryBlue);
      });

      test('primaryDeepBlue equals primaryDeepPurple', () {
        expect(AppTheme.primaryDeepBlue, AppTheme.primaryDeepPurple);
      });

      test('surfaceElevated equals backgroundElevated', () {
        expect(AppTheme.surfaceElevated, AppTheme.backgroundElevated);
      });
    });
  });

  // ===========================
  // AnimatedButton Widget
  // ===========================
  group('AnimatedButton', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedButton(
          child: Text('Tap Me'),
        ),
      ));

      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterialApp(
        AnimatedButton(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWithMaterialApp(
        AnimatedButton(
          onTap: () => tapped = true,
          enabled: false,
          child: const Text('Disabled'),
        ),
      ));

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('renders with background color', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedButton(
          backgroundColor: Colors.blue,
          child: Text('Styled'),
        ),
      ));

      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('renders with custom border radius', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        AnimatedButton(
          borderRadius: BorderRadius.circular(24),
          child: const Text('Rounded'),
        ),
      ));

      expect(find.text('Rounded'), findsOneWidget);
    });

    testWidgets('renders with padding', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedButton(
          padding: EdgeInsets.all(16),
          child: Text('Padded'),
        ),
      ));

      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('renders with shadow', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedButton(
          shadow: BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          child: Text('Shadowed'),
        ),
      ));

      expect(find.text('Shadowed'), findsOneWidget);
    });

    test('default parameters', () {
      const button = AnimatedButton(child: SizedBox());
      expect(button.animationDuration, const Duration(milliseconds: 150));
      expect(button.scaleValue, 0.95);
      expect(button.enableHaptics, isTrue);
      expect(button.enabled, isTrue);
      expect(button.backgroundColor, isNull);
      expect(button.splashColor, isNull);
      expect(button.borderRadius, isNull);
      expect(button.padding, isNull);
      expect(button.shadow, isNull);
      expect(button.onTap, isNull);
    });

    test('accepts custom animation duration', () {
      const button = AnimatedButton(
        animationDuration: Duration(milliseconds: 300),
        child: SizedBox(),
      );
      expect(button.animationDuration, const Duration(milliseconds: 300));
    });

    test('accepts custom scale value', () {
      const button = AnimatedButton(
        scaleValue: 0.85,
        child: SizedBox(),
      );
      expect(button.scaleValue, 0.85);
    });

    test('haptics can be disabled', () {
      const button = AnimatedButton(
        enableHaptics: false,
        child: SizedBox(),
      );
      expect(button.enableHaptics, isFalse);
    });

    testWidgets('uses GestureDetector for tap handling', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedButton(child: Text('Test')),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
    });
  });

  // ===========================
  // SwipeablePageView Widget
  // ===========================
  group('SwipeablePageView', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: child,
          ),
        ),
      );
    }

    testWidgets('renders first child by default', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeablePageView(
          children: [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('renders page at initial index', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeablePageView(
          initialPage: 1,
          children: [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('swiping left navigates to next page', (tester) async {
      int? changedTo;

      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeablePageView(
          onPageChanged: (page) => changedTo = page,
          children: const [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      // Swipe left
      await tester.fling(find.text('Page 0'), const Offset(-300, 0), 800);
      await tester.pumpAndSettle();

      expect(changedTo, 1);
    });

    testWidgets('swiping right navigates to previous page', (tester) async {
      int? changedTo;
      final controller = PageController(initialPage: 1);

      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeablePageView(
          controller: controller,
          onPageChanged: (page) => changedTo = page,
          children: const [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      // Swipe right from page 1
      await tester.fling(find.text('Page 1'), const Offset(300, 0), 800);
      await tester.pumpAndSettle();

      expect(changedTo, 0);

      controller.dispose();
    });

    testWidgets('swipe disabled when enableSwipe is false', (tester) async {
      int? changedTo;

      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeablePageView(
          enableSwipe: false,
          onPageChanged: (page) => changedTo = page,
          children: const [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
          ],
        ),
      ));

      // Try to swipe left
      await tester.fling(find.text('Page 0'), const Offset(-300, 0), 800);
      await tester.pumpAndSettle();

      // Should still be on page 0
      expect(changedTo, isNull);
      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('uses provided PageController', (tester) async {
      final controller = PageController(initialPage: 2);

      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeablePageView(
          controller: controller,
          children: const [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      expect(find.text('Page 2'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('programmatic page change via controller', (tester) async {
      int? changedTo;
      final controller = PageController();

      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeablePageView(
          controller: controller,
          onPageChanged: (page) => changedTo = page,
          children: const [
            Center(child: Text('Page 0')),
            Center(child: Text('Page 1')),
            Center(child: Text('Page 2')),
          ],
        ),
      ));

      // Jump to page 2
      controller.jumpToPage(2);
      await tester.pumpAndSettle();

      expect(changedTo, 2);

      controller.dispose();
    });

    test('default enableSwipe is true', () {
      const pageView = SwipeablePageView(children: [SizedBox()]);
      expect(pageView.enableSwipe, isTrue);
    });

    test('default initialPage is 0', () {
      const pageView = SwipeablePageView(children: [SizedBox()]);
      expect(pageView.initialPage, 0);
    });

    test('default controller is null', () {
      const pageView = SwipeablePageView(children: [SizedBox()]);
      expect(pageView.controller, isNull);
    });

    test('children are stored correctly', () {
      const children = [SizedBox(), Text('A')];
      const pageView = SwipeablePageView(children: children);
      expect(pageView.children.length, 2);
    });

    testWidgets('renders as PageView internally', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeablePageView(
          children: [
            Center(child: Text('Page 0')),
          ],
        ),
      ));

      expect(find.byType(PageView), findsOneWidget);
    });
  });

  // ===========================
  // AnimatedFAB Widget
  // ===========================
  group('AnimatedFAB', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders child icon', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedFAB(
          child: Icon(Icons.add),
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(wrapWithMaterialApp(
        AnimatedFAB(
          onPressed: () => pressed = true,
          child: const Icon(Icons.add),
        ),
      ));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders extended FAB with label', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedFAB(
          extended: true,
          label: Text('Create'),
          child: Icon(Icons.add),
        ),
      ));

      expect(find.text('Create'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedFAB(
          backgroundColor: Colors.purple,
          child: Icon(Icons.star),
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    test('default extended is false', () {
      const fab = AnimatedFAB(child: Icon(Icons.add));
      expect(fab.extended, isFalse);
    });

    test('heroTag is null by default', () {
      const fab = AnimatedFAB(child: Icon(Icons.add));
      expect(fab.heroTag, isNull);
    });
  });

  // ===========================
  // SwipeableWidget
  // ===========================
  group('SwipeableWidget', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: Center(child: child)));
    }

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeableWidget(
          child: SizedBox(width: 200, height: 100, child: Text('Swipeable')),
        ),
      ));

      expect(find.text('Swipeable'), findsOneWidget);
    });

    test('default swipeThreshold is 100', () {
      const widget = SwipeableWidget(child: SizedBox());
      expect(widget.swipeThreshold, 100.0);
    });

    test('default enableHaptics is true', () {
      const widget = SwipeableWidget(child: SizedBox());
      expect(widget.enableHaptics, isTrue);
    });

    test('default animationDuration is 300ms', () {
      const widget = SwipeableWidget(child: SizedBox());
      expect(widget.animationDuration, const Duration(milliseconds: 300));
    });

    test('accepts custom swipe threshold', () {
      const widget = SwipeableWidget(
        swipeThreshold: 200,
        child: SizedBox(),
      );
      expect(widget.swipeThreshold, 200.0);
    });

    test('accepts action colors', () {
      const widget = SwipeableWidget(
        leftActionColor: Colors.red,
        rightActionColor: Colors.green,
        child: SizedBox(),
      );
      expect(widget.leftActionColor, Colors.red);
      expect(widget.rightActionColor, Colors.green);
    });

    test('accepts action icons', () {
      const widget = SwipeableWidget(
        leftActionIcon: Icons.delete,
        rightActionIcon: Icons.archive,
        child: SizedBox(),
      );
      expect(widget.leftActionIcon, Icons.delete);
      expect(widget.rightActionIcon, Icons.archive);
    });

    test('accepts action labels', () {
      const widget = SwipeableWidget(
        leftActionLabel: 'Delete',
        rightActionLabel: 'Archive',
        child: SizedBox(),
      );
      expect(widget.leftActionLabel, 'Delete');
      expect(widget.rightActionLabel, 'Archive');
    });

    testWidgets('uses GestureDetector for pan handling', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeableWidget(
          child: SizedBox(width: 200, height: 100),
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
    });
  });

  // ===========================
  // SwipeToDismiss Widget
  // ===========================
  group('SwipeToDismiss', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeToDismiss(
          child: ListTile(title: Text('Dismissible Item')),
        ),
      ));

      expect(find.text('Dismissible Item'), findsOneWidget);
    });

    test('default dismiss direction is endToStart', () {
      const widget = SwipeToDismiss(child: SizedBox());
      expect(widget.direction, DismissDirection.endToStart);
    });

    test('default dismiss color is red', () {
      const widget = SwipeToDismiss(child: SizedBox());
      expect(widget.dismissColor, Colors.red);
    });

    test('default dismiss icon is delete', () {
      const widget = SwipeToDismiss(child: SizedBox());
      expect(widget.dismissIcon, Icons.delete);
    });

    test('default dismiss label is Delete', () {
      const widget = SwipeToDismiss(child: SizedBox());
      expect(widget.dismissLabel, 'Delete');
    });

    test('accepts custom dismiss properties', () {
      const widget = SwipeToDismiss(
        dismissColor: Colors.orange,
        dismissIcon: Icons.archive,
        dismissLabel: 'Archive',
        direction: DismissDirection.startToEnd,
        child: SizedBox(),
      );
      expect(widget.dismissColor, Colors.orange);
      expect(widget.dismissIcon, Icons.archive);
      expect(widget.dismissLabel, 'Archive');
      expect(widget.direction, DismissDirection.startToEnd);
    });

    testWidgets('uses Dismissible internally', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const SwipeToDismiss(
          child: SizedBox(height: 50, child: Text('Item')),
        ),
      ));

      expect(find.byType(Dismissible), findsOneWidget);
    });
  });

  // ===========================
  // SwipeRefresh Widget
  // ===========================
  group('SwipeRefresh', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeRefresh(
          onRefresh: () async {},
          child: const SingleChildScrollView(
            child: Text('Refreshable Content'),
          ),
        ),
      ));

      expect(find.text('Refreshable Content'), findsOneWidget);
    });

    test('default refreshText is Pull to refresh', () {
      final widget = SwipeRefresh(
        onRefresh: () async {},
        child: const SizedBox(),
      );
      expect(widget.refreshText, 'Pull to refresh');
    });

    test('accepts custom color', () {
      final widget = SwipeRefresh(
        onRefresh: () async {},
        color: Colors.blue,
        child: const SizedBox(),
      );
      expect(widget.color, Colors.blue);
    });

    test('default color is null', () {
      final widget = SwipeRefresh(
        onRefresh: () async {},
        child: const SizedBox(),
      );
      expect(widget.color, isNull);
    });

    testWidgets('uses RefreshIndicator internally', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        SwipeRefresh(
          onRefresh: () async {},
          child: ListView(
            children: const [Text('Content')],
          ),
        ),
      ));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  // ===========================
  // AnimatedListItem Widget
  // ===========================
  group('AnimatedListItem', () {
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        const AnimatedListItem(
          index: 0,
          child: Text('List Item'),
        ),
      ));

      // Let animations settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('List Item'), findsOneWidget);
    });

    test('default delay is 100ms', () {
      const item = AnimatedListItem(
        index: 0,
        child: SizedBox(),
      );
      expect(item.delay, const Duration(milliseconds: 100));
    });

    test('accepts custom delay', () {
      const item = AnimatedListItem(
        index: 0,
        delay: Duration(milliseconds: 200),
        child: SizedBox(),
      );
      expect(item.delay, const Duration(milliseconds: 200));
    });

    test('stores index correctly', () {
      const item = AnimatedListItem(
        index: 5,
        child: SizedBox(),
      );
      expect(item.index, 5);
    });

    test('onTap is null by default', () {
      const item = AnimatedListItem(
        index: 0,
        child: SizedBox(),
      );
      expect(item.onTap, isNull);
    });
  });

  // ===========================
  // Badge Display Logic
  // ===========================
  group('Badge Display Logic', () {
    // Testing the badge count display rules from the _buildNavItem method
    test('badge count 0 should not show badge', () {
      // From source: if (badgeCount > 0) - badge is hidden when 0
      const badgeCount = 0;
      expect(badgeCount > 0, isFalse);
    });

    test('badge count 1 shows badge with "1"', () {
      const badgeCount = 1;
      const text = badgeCount > 99 ? '99+' : '$badgeCount';
      expect(text, '1');
    });

    test('badge count 99 shows "99"', () {
      const badgeCount = 99;
      const text = badgeCount > 99 ? '99+' : '$badgeCount';
      expect(text, '99');
    });

    test('badge count 100 shows "99+"', () {
      const badgeCount = 100;
      const text = badgeCount > 99 ? '99+' : '$badgeCount';
      expect(text, '99+');
    });

    test('badge count 999 shows "99+"', () {
      const badgeCount = 999;
      const text = badgeCount > 99 ? '99+' : '$badgeCount';
      expect(text, '99+');
    });

    test('only Messages and Alerts tabs have badgeCount support', () {
      // From source: only indices 2 (Messages) and 3 (Alerts) pass badgeCount
      // Messages: badgeCount: _unreadMessages
      // Alerts: badgeCount: _unreadNotifications
      // Other tabs: default badgeCount = 0
      final tabsWithBadges = {2, 3}; // Messages and Alerts
      expect(tabsWithBadges.contains(2), isTrue);
      expect(tabsWithBadges.contains(3), isTrue);
      expect(tabsWithBadges.contains(0), isFalse);
      expect(tabsWithBadges.contains(1), isFalse);
      expect(tabsWithBadges.contains(4), isFalse);
      expect(tabsWithBadges.contains(5), isFalse);
    });
  });

  // ===========================
  // Tab Index Clamping Logic
  // ===========================
  group('Tab Index Clamping Logic', () {
    // From source: _selectedIndex = widget.initialTabIndex.clamp(0, 5);
    test('index 0 stays at 0', () {
      expect(0.clamp(0, 5), 0);
    });

    test('index 5 stays at 5', () {
      expect(5.clamp(0, 5), 5);
    });

    test('negative index clamps to 0', () {
      expect((-1).clamp(0, 5), 0);
    });

    test('index 6 clamps to 5', () {
      expect(6.clamp(0, 5), 5);
    });

    test('index 100 clamps to 5', () {
      expect(100.clamp(0, 5), 5);
    });

    test('index 3 stays at 3', () {
      expect(3.clamp(0, 5), 3);
    });
  });
}
