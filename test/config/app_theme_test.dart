import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/config/app_theme.dart';

void main() {
  // ============================================================================
  // Color constants
  // ============================================================================
  group('AppTheme color constants', () {
    group('primary colors', () {
      test('primaryDeepPurple is correct', () {
        expect(AppTheme.primaryDeepPurple, const Color(0xFF4C1D95));
      });

      test('primaryPurple is correct', () {
        expect(AppTheme.primaryPurple, const Color(0xFF7C3AED));
      });

      test('primaryBlue is correct', () {
        expect(AppTheme.primaryBlue, const Color(0xFF3B82F6));
      });

      test('primaryOrange is correct', () {
        expect(AppTheme.primaryOrange, const Color(0xFFEA580C));
      });

      test('primaryRed is correct', () {
        expect(AppTheme.primaryRed, const Color(0xFFDC2626));
      });
    });

    group('legacy aliases', () {
      test('primaryVibrantOrange aliases primaryOrange', () {
        expect(AppTheme.primaryVibrantOrange, AppTheme.primaryOrange);
      });

      test('primaryElectricBlue aliases primaryBlue', () {
        expect(AppTheme.primaryElectricBlue, AppTheme.primaryBlue);
      });

      test('primaryDeepBlue aliases primaryDeepPurple', () {
        expect(AppTheme.primaryDeepBlue, AppTheme.primaryDeepPurple);
      });
    });

    group('accent colors', () {
      test('accentGold is correct', () {
        expect(AppTheme.accentGold, const Color(0xFFFBBF24));
      });

      test('accentYellow is correct', () {
        expect(AppTheme.accentYellow, const Color(0xFFFDE047));
      });
    });

    group('secondary colors', () {
      test('secondaryPurple is correct', () {
        expect(AppTheme.secondaryPurple, const Color(0xFF8B5CF6));
      });

      test('secondaryEmerald is correct', () {
        expect(AppTheme.secondaryEmerald, const Color(0xFF10B981));
      });

      test('secondaryRose is correct', () {
        expect(AppTheme.secondaryRose, const Color(0xFFF43F5E));
      });
    });

    group('background colors', () {
      test('backgroundDark is correct', () {
        expect(AppTheme.backgroundDark, const Color(0xFF0F172A));
      });

      test('backgroundCard is correct', () {
        expect(AppTheme.backgroundCard, const Color(0xFF1E293B));
      });

      test('backgroundElevated is correct', () {
        expect(AppTheme.backgroundElevated, const Color(0xFF334155));
      });

      test('backgroundLight is correct', () {
        expect(AppTheme.backgroundLight, const Color(0xFFF8FAFC));
      });

      test('surfaceElevated aliases backgroundElevated', () {
        expect(AppTheme.surfaceElevated, AppTheme.backgroundElevated);
      });
    });

    group('text colors', () {
      test('textWhite is pure white', () {
        expect(AppTheme.textWhite, const Color(0xFFFFFFFF));
      });

      test('textLight is correct', () {
        expect(AppTheme.textLight, const Color(0xFFF1F5F9));
      });

      test('textSecondary is correct', () {
        expect(AppTheme.textSecondary, const Color(0xFFCBD5E1));
      });

      test('textTertiary is correct', () {
        expect(AppTheme.textTertiary, const Color(0xFFA8B5C4));
      });

      test(
          'textTertiary on backgroundDark meets WCAG AA contrast ratio >= 4.5',
          () {
        // WCAG 2.1 relative luminance: linearize each sRGB channel then
        // combine with L = 0.2126*R + 0.7152*G + 0.0722*B.
        double linearizeSrgb(int channel) {
          final s = channel / 255.0;
          if (s <= 0.04045) return s / 12.92;
          return math.pow((s + 0.055) / 1.055, 2.4).toDouble();
        }

        double relativeLuminance(Color c) {
          final r = linearizeSrgb(c.red.toInt());
          final g = linearizeSrgb(c.green.toInt());
          final b = linearizeSrgb(c.blue.toInt());
          return 0.2126 * r + 0.7152 * g + 0.0722 * b;
        }

        final lumFg = relativeLuminance(AppTheme.textTertiary);
        final lumBg = relativeLuminance(AppTheme.backgroundDark);

        final lighter = lumFg > lumBg ? lumFg : lumBg;
        final darker = lumFg > lumBg ? lumBg : lumFg;
        final contrastRatio = (lighter + 0.05) / (darker + 0.05);

        expect(contrastRatio, greaterThanOrEqualTo(4.5),
            reason:
                'textTertiary on backgroundDark contrast ratio ($contrastRatio) '
                'must be >= 4.5 for WCAG AA compliance');
      });
    });

    group('semantic colors', () {
      test('successColor is correct', () {
        expect(AppTheme.successColor, const Color(0xFF059669));
      });

      test('warningColor is correct', () {
        expect(AppTheme.warningColor, const Color(0xFFD97706));
      });

      test('errorColor is correct', () {
        expect(AppTheme.errorColor, const Color(0xFFDC2626));
      });

      test('infoColor is correct', () {
        expect(AppTheme.infoColor, const Color(0xFF2563EB));
      });

      test('errorColor equals primaryRed', () {
        expect(AppTheme.errorColor, AppTheme.primaryRed);
      });
    });

    group('high contrast colors', () {
      test('highContrastBackground is pure black', () {
        expect(AppTheme.highContrastBackground, const Color(0xFF000000));
      });

      test('highContrastSurface is correct', () {
        expect(AppTheme.highContrastSurface, const Color(0xFF121212));
      });

      test('highContrastText is pure white', () {
        expect(AppTheme.highContrastText, const Color(0xFFFFFFFF));
      });

      test('highContrastPrimary is bright yellow', () {
        expect(AppTheme.highContrastPrimary, const Color(0xFFFFD600));
      });

      test('highContrastSecondary is bright cyan', () {
        expect(AppTheme.highContrastSecondary, const Color(0xFF00E5FF));
      });

      test('highContrastError is bright red', () {
        expect(AppTheme.highContrastError, const Color(0xFFFF5252));
      });

      test('highContrastSuccess is bright green', () {
        expect(AppTheme.highContrastSuccess, const Color(0xFF69F0AE));
      });
    });
  });

  // ============================================================================
  // Gradients
  // ============================================================================
  group('AppTheme gradients', () {
    test('mainGradient is a LinearGradient', () {
      expect(AppTheme.mainGradient, isA<LinearGradient>());
    });

    test('mainGradient has 5 colors', () {
      final gradient = AppTheme.mainGradient as LinearGradient;
      expect(gradient.colors.length, 5);
    });

    test('mainGradient has 5 stops', () {
      final gradient = AppTheme.mainGradient as LinearGradient;
      expect(gradient.stops?.length, 5);
    });

    test('mainGradient goes from topLeft to bottomRight', () {
      final gradient = AppTheme.mainGradient as LinearGradient;
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    test('cardGradient is a LinearGradient with 3 colors', () {
      final gradient = AppTheme.cardGradient as LinearGradient;
      expect(gradient.colors.length, 3);
    });

    test('buttonGradient is a LinearGradient with 2 colors', () {
      final gradient = AppTheme.buttonGradient as LinearGradient;
      expect(gradient.colors.length, 2);
    });

    test('buttonGradient goes left to right', () {
      final gradient = AppTheme.buttonGradient as LinearGradient;
      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
    });

    test('successGradient is a LinearGradient with 2 colors', () {
      final gradient = AppTheme.successGradient as LinearGradient;
      expect(gradient.colors.length, 2);
    });
  });

  // ============================================================================
  // Dark theme
  // ============================================================================
  group('AppTheme.darkTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.darkTheme;
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, true);
    });

    test('has dark brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('color scheme has correct primary', () {
      expect(theme.colorScheme.primary, AppTheme.primaryPurple);
    });

    test('color scheme has correct secondary', () {
      expect(theme.colorScheme.secondary, AppTheme.primaryOrange);
    });

    test('color scheme has correct tertiary', () {
      expect(theme.colorScheme.tertiary, AppTheme.accentGold);
    });

    test('color scheme has correct surface', () {
      expect(theme.colorScheme.surface, AppTheme.backgroundCard);
    });

    test('color scheme has correct error', () {
      expect(theme.colorScheme.error, AppTheme.primaryRed);
    });

    test('scaffold background is dark', () {
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundDark);
    });

    test('app bar background is transparent', () {
      expect(theme.appBarTheme.backgroundColor, Colors.transparent);
    });

    test('app bar has no elevation', () {
      expect(theme.appBarTheme.elevation, 0);
    });

    test('app bar title is centered', () {
      expect(theme.appBarTheme.centerTitle, true);
    });

    test('bottom nav bar uses fixed type', () {
      expect(theme.bottomNavigationBarTheme.type,
          BottomNavigationBarType.fixed);
    });

    test('bottom nav bar selected color is orange', () {
      expect(theme.bottomNavigationBarTheme.selectedItemColor,
          AppTheme.primaryOrange);
    });

    test('card theme has correct color', () {
      expect(theme.cardTheme.color, AppTheme.backgroundCard);
    });

    test('card theme has elevation', () {
      expect(theme.cardTheme.elevation, 8);
    });

    test('card theme uses anti-alias clipping', () {
      expect(theme.cardTheme.clipBehavior, Clip.antiAlias);
    });

    test('tab bar indicator color is orange', () {
      expect(theme.tabBarTheme.indicatorColor, AppTheme.primaryOrange);
    });

    test('input decoration has filled true', () {
      expect(theme.inputDecorationTheme.filled, true);
    });

    test('input decoration fill color is elevated background', () {
      expect(
          theme.inputDecorationTheme.fillColor, AppTheme.backgroundElevated);
    });

    test('text theme headlineLarge has correct size', () {
      expect(theme.textTheme.headlineLarge?.fontSize, 32);
    });

    test('text theme bodyLarge has correct size', () {
      expect(theme.textTheme.bodyLarge?.fontSize, 16);
    });

    test('text theme bodyMedium has correct size', () {
      expect(theme.textTheme.bodyMedium?.fontSize, 14);
    });

    test('text theme bodySmall has correct size', () {
      expect(theme.textTheme.bodySmall?.fontSize, 12);
    });
  });

  // ============================================================================
  // Light theme
  // ============================================================================
  group('AppTheme.lightTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.lightTheme;
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, true);
    });

    test('has light brightness', () {
      expect(theme.brightness, Brightness.light);
    });

    test('color scheme has correct primary', () {
      expect(theme.colorScheme.primary, AppTheme.primaryPurple);
    });

    test('color scheme has correct secondary', () {
      expect(theme.colorScheme.secondary, AppTheme.primaryOrange);
    });

    test('color scheme has correct tertiary', () {
      expect(theme.colorScheme.tertiary, AppTheme.accentGold);
    });

    test('surface is white', () {
      expect(theme.colorScheme.surface, Colors.white);
    });

    test('scaffold background is light', () {
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF8FAFC));
    });
  });

  // ============================================================================
  // High contrast theme
  // ============================================================================
  group('AppTheme.highContrastTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.highContrastTheme;
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, true);
    });

    test('has dark brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('scaffold is pure black', () {
      expect(
          theme.scaffoldBackgroundColor, AppTheme.highContrastBackground);
    });

    test('primary is bright yellow for high visibility', () {
      expect(theme.colorScheme.primary, AppTheme.highContrastPrimary);
    });

    test('secondary is bright cyan for contrast', () {
      expect(theme.colorScheme.secondary, AppTheme.highContrastSecondary);
    });

    test('error is bright red', () {
      expect(theme.colorScheme.error, AppTheme.highContrastError);
    });

    test('card theme has no elevation', () {
      expect(theme.cardTheme.elevation, 0);
    });

    test('card theme has border', () {
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.side.color, AppTheme.highContrastText);
      expect(shape.side.width, 2);
    });

    test('app bar background is pure black', () {
      expect(
          theme.appBarTheme.backgroundColor, AppTheme.highContrastBackground);
    });

    test('bottom nav selected color is bright yellow', () {
      expect(theme.bottomNavigationBarTheme.selectedItemColor,
          AppTheme.highContrastPrimary);
    });

    test('tab bar label color is bright yellow', () {
      expect(theme.tabBarTheme.labelColor, AppTheme.highContrastPrimary);
    });

    test('divider is white for high contrast', () {
      expect(theme.dividerTheme.color, AppTheme.highContrastText);
    });

    test('icon theme color is white', () {
      expect(theme.iconTheme.color, AppTheme.highContrastText);
    });
  });

  // ============================================================================
  // Decoration helpers
  // ============================================================================
  group('AppTheme decoration helpers', () {
    test('mainGradientDecoration uses mainGradient', () {
      final decoration = AppTheme.mainGradientDecoration;
      expect(decoration.gradient, AppTheme.mainGradient);
    });

    test('cardGradientDecoration uses cardGradient', () {
      final decoration = AppTheme.cardGradientDecoration;
      expect(decoration.gradient, AppTheme.cardGradient);
    });

    test('cardGradientDecoration has border radius', () {
      final decoration = AppTheme.cardGradientDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });

    test('cardGradientDecoration has shadow', () {
      final decoration = AppTheme.cardGradientDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });

    test('buttonGradientDecoration uses buttonGradient', () {
      final decoration = AppTheme.buttonGradientDecoration;
      expect(decoration.gradient, AppTheme.buttonGradient);
    });

    test('buttonGradientDecoration has border radius 25', () {
      final decoration = AppTheme.buttonGradientDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(25));
    });

    test('buttonGradientDecoration has shadow', () {
      final decoration = AppTheme.buttonGradientDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });

    test('premiumCardDecoration aliases cardGradientDecoration', () {
      // Both should produce equivalent BoxDecoration
      final premium = AppTheme.premiumCardDecoration;
      final card = AppTheme.cardGradientDecoration;
      expect(premium.gradient, card.gradient);
    });

    test('accentCardDecoration aliases buttonGradientDecoration', () {
      final accent = AppTheme.accentCardDecoration;
      final button = AppTheme.buttonGradientDecoration;
      expect(accent.gradient, button.gradient);
    });

    test('gradientTextStyle has correct properties', () {
      final style = AppTheme.gradientTextStyle;
      expect(style.fontSize, 24);
      expect(style.fontWeight, FontWeight.w800);
      expect(style.letterSpacing, -0.5);
    });
  });

  // ============================================================================
  // getStatusColor
  // ============================================================================
  group('AppTheme.getStatusColor', () {
    test('returns successColor for "success"', () {
      expect(AppTheme.getStatusColor('success'), AppTheme.successColor);
    });

    test('returns successColor for "active"', () {
      expect(AppTheme.getStatusColor('active'), AppTheme.successColor);
    });

    test('returns successColor for "online"', () {
      expect(AppTheme.getStatusColor('online'), AppTheme.successColor);
    });

    test('returns warningColor for "warning"', () {
      expect(AppTheme.getStatusColor('warning'), AppTheme.warningColor);
    });

    test('returns warningColor for "pending"', () {
      expect(AppTheme.getStatusColor('pending'), AppTheme.warningColor);
    });

    test('returns errorColor for "error"', () {
      expect(AppTheme.getStatusColor('error'), AppTheme.errorColor);
    });

    test('returns errorColor for "offline"', () {
      expect(AppTheme.getStatusColor('offline'), AppTheme.errorColor);
    });

    test('returns errorColor for "failed"', () {
      expect(AppTheme.getStatusColor('failed'), AppTheme.errorColor);
    });

    test('returns infoColor for "info"', () {
      expect(AppTheme.getStatusColor('info'), AppTheme.infoColor);
    });

    test('returns infoColor for "neutral"', () {
      expect(AppTheme.getStatusColor('neutral'), AppTheme.infoColor);
    });

    test('returns textSecondary for unknown status', () {
      expect(AppTheme.getStatusColor('unknown'), AppTheme.textSecondary);
      expect(AppTheme.getStatusColor(''), AppTheme.textSecondary);
    });

    test('is case-insensitive', () {
      expect(AppTheme.getStatusColor('SUCCESS'), AppTheme.successColor);
      expect(AppTheme.getStatusColor('Warning'), AppTheme.warningColor);
      expect(AppTheme.getStatusColor('ERROR'), AppTheme.errorColor);
      expect(AppTheme.getStatusColor('Info'), AppTheme.infoColor);
    });
  });

  // ============================================================================
  // getCategoryColor
  // ============================================================================
  group('AppTheme.getCategoryColor', () {
    test('returns primaryOrange for "sports bar"', () {
      expect(AppTheme.getCategoryColor('sports bar'), AppTheme.primaryOrange);
    });

    test('returns primaryOrange for "sports_bar"', () {
      expect(AppTheme.getCategoryColor('sports_bar'), AppTheme.primaryOrange);
    });

    test('returns primaryPurple for "restaurant"', () {
      expect(AppTheme.getCategoryColor('restaurant'), AppTheme.primaryPurple);
    });

    test('returns accentGold for "brewery"', () {
      expect(AppTheme.getCategoryColor('brewery'), AppTheme.accentGold);
    });

    test('returns primaryBlue for "coffee"', () {
      expect(AppTheme.getCategoryColor('coffee'), AppTheme.primaryBlue);
    });

    test('returns primaryBlue for "cafe"', () {
      expect(AppTheme.getCategoryColor('cafe'), AppTheme.primaryBlue);
    });

    test('returns primaryRed for "nightlife"', () {
      expect(AppTheme.getCategoryColor('nightlife'), AppTheme.primaryRed);
    });

    test('returns secondaryEmerald for "fast food"', () {
      expect(
          AppTheme.getCategoryColor('fast food'), AppTheme.secondaryEmerald);
    });

    test('returns primaryPurple for unknown category', () {
      expect(AppTheme.getCategoryColor('unknown'), AppTheme.primaryPurple);
      expect(AppTheme.getCategoryColor(''), AppTheme.primaryPurple);
    });

    test('is case-insensitive', () {
      expect(
          AppTheme.getCategoryColor('Sports Bar'), AppTheme.primaryOrange);
      expect(
          AppTheme.getCategoryColor('RESTAURANT'), AppTheme.primaryPurple);
    });
  });

  // ============================================================================
  // getTeamColor
  // ============================================================================
  group('AppTheme.getTeamColor', () {
    test('returns correct color for Brazil', () {
      expect(AppTheme.getTeamColor('brazil'), const Color(0xFFFFDF00));
    });

    test('returns correct color for Argentina', () {
      expect(AppTheme.getTeamColor('argentina'), const Color(0xFF75AADB));
    });

    test('returns correct color for Germany', () {
      expect(AppTheme.getTeamColor('germany'), const Color(0xFFFFCE00));
    });

    test('returns correct color for France', () {
      expect(AppTheme.getTeamColor('france'), const Color(0xFF002395));
    });

    test('returns correct color for Spain', () {
      expect(AppTheme.getTeamColor('spain'), const Color(0xFFAA151B));
    });

    test('returns correct color for England', () {
      expect(AppTheme.getTeamColor('england'), const Color(0xFFCF081F));
    });

    test('returns correct color for Mexico and Mexico with accent', () {
      expect(AppTheme.getTeamColor('mexico'), const Color(0xFF006847));
      expect(AppTheme.getTeamColor('m\u00e9xico'), const Color(0xFF006847));
    });

    test('returns correct color for USA variants', () {
      expect(AppTheme.getTeamColor('usa'), const Color(0xFF002868));
      expect(
          AppTheme.getTeamColor('united states'), const Color(0xFF002868));
    });

    test('returns correct color for Portugal', () {
      expect(AppTheme.getTeamColor('portugal'), const Color(0xFFDA291C));
    });

    test('returns correct color for Netherlands', () {
      expect(AppTheme.getTeamColor('netherlands'), const Color(0xFFFF6600));
    });

    test('returns correct color for Italy', () {
      expect(AppTheme.getTeamColor('italy'), const Color(0xFF0066B2));
    });

    test('returns correct color for Japan', () {
      expect(AppTheme.getTeamColor('japan'), const Color(0xFF000080));
    });

    test('returns primaryPurple for unknown teams', () {
      expect(AppTheme.getTeamColor('unknown'), AppTheme.primaryPurple);
      expect(AppTheme.getTeamColor('narnia'), AppTheme.primaryPurple);
    });

    test('is case-insensitive', () {
      expect(AppTheme.getTeamColor('Brazil'), const Color(0xFFFFDF00));
      expect(AppTheme.getTeamColor('FRANCE'), const Color(0xFF002395));
      expect(AppTheme.getTeamColor('SpAiN'), const Color(0xFFAA151B));
    });
  });
}
