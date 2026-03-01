import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/config/app_theme.dart';
import 'package:pregame_world_cup/config/theme_helper.dart';

void main() {
  // ============================================================================
  // Sports-specific static color getters (no BuildContext needed)
  // ============================================================================
  group('ThemeHelper static color getters', () {
    test('favoriteColor is primaryOrange', () {
      expect(ThemeHelper.favoriteColor, AppTheme.primaryOrange);
    });

    test('successColor is AppTheme.successColor', () {
      expect(ThemeHelper.successColor, AppTheme.successColor);
    });

    test('warningColor is AppTheme.warningColor', () {
      expect(ThemeHelper.warningColor, AppTheme.warningColor);
    });

    test('errorColor is primaryRed', () {
      expect(ThemeHelper.errorColor, AppTheme.primaryRed);
    });

    test('infoColor is AppTheme.infoColor', () {
      expect(ThemeHelper.infoColor, AppTheme.infoColor);
    });

    test('premiumColor is accentGold', () {
      expect(ThemeHelper.premiumColor, AppTheme.accentGold);
    });
  });

  // ============================================================================
  // Delegate methods to AppTheme
  // ============================================================================
  group('ThemeHelper delegate methods', () {
    test('teamColor delegates to AppTheme.getTeamColor', () {
      expect(ThemeHelper.teamColor('brazil'), AppTheme.getTeamColor('brazil'));
      expect(ThemeHelper.teamColor('france'), AppTheme.getTeamColor('france'));
      expect(
          ThemeHelper.teamColor('unknown'), AppTheme.getTeamColor('unknown'));
    });

    test('categoryColor delegates to AppTheme.getCategoryColor', () {
      expect(ThemeHelper.categoryColor('sports bar'),
          AppTheme.getCategoryColor('sports bar'));
      expect(ThemeHelper.categoryColor('restaurant'),
          AppTheme.getCategoryColor('restaurant'));
      expect(ThemeHelper.categoryColor('unknown'),
          AppTheme.getCategoryColor('unknown'));
    });

    test('statusColor delegates to AppTheme.getStatusColor', () {
      expect(ThemeHelper.statusColor('success'),
          AppTheme.getStatusColor('success'));
      expect(ThemeHelper.statusColor('error'),
          AppTheme.getStatusColor('error'));
      expect(ThemeHelper.statusColor('pending'),
          AppTheme.getStatusColor('pending'));
    });
  });

  // ============================================================================
  // Decoration helpers (no BuildContext)
  // ============================================================================
  group('ThemeHelper decoration helpers (static)', () {
    test('premiumCardDecoration returns AppTheme.premiumCardDecoration', () {
      final decoration = ThemeHelper.premiumCardDecoration();
      expect(decoration.gradient, AppTheme.cardGradient);
    });

    test('accentCardDecoration returns buttonGradientDecoration', () {
      final decoration = ThemeHelper.accentCardDecoration();
      expect(decoration.gradient, AppTheme.buttonGradient);
    });
  });

  // ============================================================================
  // Context-dependent methods (require widget test)
  // ============================================================================
  group('ThemeHelper context-dependent methods (dark theme)', () {
    testWidgets('primaryColor returns theme primary', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.primaryColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.primaryPurple);
    });

    testWidgets('accentColor returns theme secondary', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.accentColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.primaryOrange);
    });

    testWidgets('surfaceColor returns theme surface', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.surfaceColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.backgroundCard);
    });

    testWidgets('backgroundColor returns theme surface', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.backgroundColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.backgroundCard);
    });

    testWidgets('textColor returns onSurface', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.textColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.textWhite);
    });

    testWidgets('textSecondaryColor returns onSurfaceVariant',
        (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.textSecondaryColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.textSecondary);
    });

    testWidgets('textHintColor returns outline', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.textHintColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.textTertiary);
    });

    testWidgets('isDarkMode returns true for dark theme', (tester) async {
      late bool isDark;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              isDark = ThemeHelper.isDarkMode(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(isDark, true);
    });

    testWidgets('contrastColor returns white for dark theme', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.contrastColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, Colors.white);
    });
  });

  group('ThemeHelper context-dependent methods (light theme)', () {
    testWidgets('isDarkMode returns false for light theme', (tester) async {
      late bool isDark;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              isDark = ThemeHelper.isDarkMode(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(isDark, false);
    });

    testWidgets('contrastColor returns black for light theme', (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.contrastColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, Colors.black);
    });

    testWidgets('primaryColor returns theme primary in light theme',
        (tester) async {
      late Color color;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              color = ThemeHelper.primaryColor(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(color, AppTheme.primaryPurple);
    });
  });

  // ============================================================================
  // cardDecoration
  // ============================================================================
  group('ThemeHelper.cardDecoration', () {
    testWidgets('returns BoxDecoration with surface color', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.cardDecoration(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.color, AppTheme.backgroundCard);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('elevated has stronger shadow', (tester) async {
      late BoxDecoration normal;
      late BoxDecoration elevated;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              normal = ThemeHelper.cardDecoration(context);
              elevated = ThemeHelper.cardDecoration(context, elevated: true);
              return const SizedBox();
            },
          ),
        ),
      );
      // Elevated should have greater blur radius
      expect(elevated.boxShadow!.first.blurRadius,
          greaterThan(normal.boxShadow!.first.blurRadius));
    });

    testWidgets('accepts custom color', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.cardDecoration(context,
                  customColor: Colors.red);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.color, Colors.red);
    });
  });

  // ============================================================================
  // Text style helpers
  // ============================================================================
  group('ThemeHelper text styles', () {
    testWidgets('h1 has fontSize 28 and weight 700', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.h1(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 28);
      expect(style.fontWeight, FontWeight.w700);
    });

    testWidgets('h2 has fontSize 24 and weight 600', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.h2(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 24);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('h3 has fontSize 20 and weight 600', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.h3(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 20);
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('body has fontSize 16 and height 1.5', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.body(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 16);
      expect(style.height, 1.5);
    });

    testWidgets('small has fontSize 14', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.small(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 14);
    });

    testWidgets('caption has fontSize 12', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.caption(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, 12);
    });

    testWidgets('h1 accepts custom color', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.h1(context, color: Colors.red);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.color, Colors.red);
    });

    testWidgets('body accepts custom color', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.body(context, color: Colors.green);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.color, Colors.green);
    });
  });

  // ============================================================================
  // Button styles
  // ============================================================================
  group('ThemeHelper button styles', () {
    testWidgets('primaryButtonStyle returns a ButtonStyle', (tester) async {
      late ButtonStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.primaryButtonStyle(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style, isA<ButtonStyle>());
    });

    testWidgets('secondaryButtonStyle returns a ButtonStyle', (tester) async {
      late ButtonStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.secondaryButtonStyle(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style, isA<ButtonStyle>());
    });

    testWidgets('successButtonStyle returns a ButtonStyle', (tester) async {
      late ButtonStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              style = ThemeHelper.successButtonStyle(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style, isA<ButtonStyle>());
    });
  });

  // ============================================================================
  // createAppBar
  // ============================================================================
  group('ThemeHelper.createAppBar', () {
    testWidgets('creates app bar with title', (tester) async {
      late AppBar appBar;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              appBar = ThemeHelper.createAppBar(context, title: 'Test Title');
              return Scaffold(appBar: appBar);
            },
          ),
        ),
      );
      expect(appBar.elevation, 0);
      expect(appBar.centerTitle, true);
    });

    testWidgets('supports custom centerTitle', (tester) async {
      late AppBar appBar;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              appBar = ThemeHelper.createAppBar(
                context,
                title: 'Test',
                centerTitle: false,
              );
              return Scaffold(appBar: appBar);
            },
          ),
        ),
      );
      expect(appBar.centerTitle, false);
    });

    testWidgets('supports custom colors', (tester) async {
      late AppBar appBar;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              appBar = ThemeHelper.createAppBar(
                context,
                title: 'Test',
                backgroundColor: Colors.red,
                foregroundColor: Colors.yellow,
              );
              return Scaffold(appBar: appBar);
            },
          ),
        ),
      );
      expect(appBar.backgroundColor, Colors.red);
      expect(appBar.foregroundColor, Colors.yellow);
    });
  });

  // ============================================================================
  // inputDecoration
  // ============================================================================
  group('ThemeHelper.inputDecoration', () {
    testWidgets('creates InputDecoration with label', (tester) async {
      late InputDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.inputDecoration(
                context,
                labelText: 'Email',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.labelText, 'Email');
      expect(decoration.filled, true);
    });

    testWidgets('supports hint text', (tester) async {
      late InputDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.inputDecoration(
                context,
                labelText: 'Search',
                hintText: 'Type to search...',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.hintText, 'Type to search...');
    });

    testWidgets('supports prefix and suffix icons', (tester) async {
      late InputDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.inputDecoration(
                context,
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: const Icon(Icons.visibility),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.prefixIcon, isA<Icon>());
      expect(decoration.suffixIcon, isA<Icon>());
    });

    testWidgets('uses elevated surface fill in dark mode', (tester) async {
      late InputDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.inputDecoration(
                context,
                labelText: 'Test',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.fillColor, AppTheme.surfaceElevated);
    });

    testWidgets('uses light background fill in light mode', (tester) async {
      late InputDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              decoration = ThemeHelper.inputDecoration(
                context,
                labelText: 'Test',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.fillColor, AppTheme.backgroundLight);
    });
  });
}
