import 'package:flutter/material.dart';

/// Modern Sports App Theme with Beautiful Gradient Color Scheme
/// Inspired by the screenshot design with purple-blue to orange-red gradients
class AppTheme {
  // ====================
  // GRADIENT COLOR PALETTE (Inspired by Screenshot)
  // ====================
  
  // Primary Colors - Gradient from Purple/Blue to Orange/Red
  static const Color primaryDeepPurple = Color(0xFF4C1D95); // Deep purple
  static const Color primaryPurple = Color(0xFF7C3AED); // Vibrant purple
  static const Color primaryBlue = Color(0xFF3B82F6); // Electric blue
  static const Color primaryOrange = Color(0xFFEA580C); // Warm orange
  static const Color primaryRed = Color(0xFFDC2626); // Vibrant red
  
  // Legacy color names for backward compatibility
  static const Color primaryVibrantOrange = primaryOrange;
  static const Color primaryElectricBlue = primaryBlue;
  static const Color primaryDeepBlue = primaryDeepPurple;
  
  // Accent Colors
  static const Color accentGold = Color(0xFFFBBF24); // Championship gold
  static const Color accentYellow = Color(0xFFFDE047); // Bright yellow
  
  // Secondary colors for compatibility
  static const Color secondaryPurple = Color(0xFF8B5CF6); // Premium purple
  static const Color secondaryEmerald = Color(0xFF10B981); // Success green
  static const Color secondaryRose = Color(0xFFF43F5E); // Attention-grabbing rose
  
  // Background Colors - Dark Theme Focused
  static const Color backgroundDark = Color(0xFF0F172A); // Rich dark background
  static const Color backgroundCard = Color(0xFF1E293B); // Card background
  static const Color backgroundElevated = Color(0xFF334155); // Elevated surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC); // Light background
  static const Color surfaceElevated = backgroundElevated; // Alias
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF); // Pure white text
  static const Color textLight = Color(0xFFF1F5F9); // Light text
  static const Color textSecondary = Color(0xFFCBD5E1); // Secondary text
  static const Color textTertiary = Color(0xFF94A3B8); // Tertiary text
  
  // Semantic colors
  static const Color successColor = Color(0xFF059669); // Green success
  static const Color warningColor = Color(0xFFD97706); // Amber warning  
  static const Color errorColor = Color(0xFFDC2626); // Red error
  static const Color infoColor = Color(0xFF2563EB); // Blue info
  
  // ====================
  // BEAUTIFUL GRADIENTS (Based on Screenshot)
  // ====================
  
  // Main gradient seen in the screenshot
  static const Gradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4C1D95), // Deep purple
      Color(0xFF7C3AED), // Vibrant purple
      Color(0xFF3B82F6), // Electric blue
      Color(0xFFEA580C), // Warm orange
      Color(0xFFDC2626), // Vibrant red
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  // Card gradient for AI analysis cards
  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED), // Vibrant purple
      Color(0xFF3B82F6), // Electric blue
      Color(0xFFEA580C), // Warm orange
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Button gradient
  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFEA580C), // Warm orange
      Color(0xFFFBBF24), // Gold
    ],
  );
  
  // Success gradient
  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF059669), // Green
      Color(0xFF10B981), // Emerald
    ],
  );
  
  // ====================
  // DARK THEME (Primary Theme)
  // ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        onPrimary: textWhite,
        secondary: primaryOrange,
        onSecondary: textWhite,
        tertiary: accentGold,
        onTertiary: backgroundDark,
        surface: backgroundCard,
        onSurface: textWhite,
        surfaceContainerHighest: backgroundElevated,
        onSurfaceVariant: textSecondary,
        outline: textTertiary,
        error: primaryRed,
        onError: textWhite,
        inverseSurface: textWhite,
        onInverseSurface: backgroundDark,
        background: backgroundDark,
        onBackground: textWhite,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: backgroundDark,
      
      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundCard,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textWhite,
          elevation: 8,
          shadowColor: primaryOrange.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: textWhite,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryOrange,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: textTertiary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: textTertiary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontSize: 16,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineSmall: TextStyle(
          color: textWhite,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
        titleSmall: TextStyle(
          color: textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          ),
        bodyLarge: TextStyle(
          color: textLight,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
  
  // ====================
  // LIGHT THEME (Fallback)
  // ====================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        onPrimary: textWhite,
        secondary: primaryOrange,
        onSecondary: textWhite,
        tertiary: accentGold,
        surface: Colors.white,
        onSurface: backgroundDark,
        background: Color(0xFFF8FAFC),
        onBackground: backgroundDark,
      ),
      
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );
  }
  
  // ====================
  // HELPER METHODS
  // ====================
  
  /// Get the main gradient decoration
  static BoxDecoration get mainGradientDecoration {
    return const BoxDecoration(
      gradient: mainGradient,
  );
  }
  
  /// Get card gradient decoration
  static BoxDecoration get cardGradientDecoration {
    return BoxDecoration(
      gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
          color: primaryPurple.withOpacity(0.3),
        blurRadius: 20,
          offset: const Offset(0, 10),
      ),
    ],
  );
  }
  
  /// Get button gradient decoration
  static BoxDecoration get buttonGradientDecoration {
    return BoxDecoration(
      gradient: buttonGradient,
      borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
          color: primaryOrange.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 5),
      ),
    ],
  );
  }
  
  /// Get text style with gradient (for special cases)
  static TextStyle get gradientTextStyle {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );
  }
  
  // Legacy decoration methods for backward compatibility
  static BoxDecoration get premiumCardDecoration => cardGradientDecoration;
  static BoxDecoration get accentCardDecoration => buttonGradientDecoration;
  
  // Legacy utility methods for backward compatibility
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'online':
        return successColor;
      case 'warning':
      case 'pending':
        return warningColor;
      case 'error':
      case 'offline':
      case 'failed':
        return errorColor;
      case 'info':
      case 'neutral':
        return infoColor;
      default:
        return textSecondary;
    }
  }
  
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sports bar':
      case 'sports_bar':
        return primaryOrange; // Warm orange (matches updated theme)
      case 'restaurant':
        return primaryPurple; // Vibrant purple (matches updated theme)
      case 'brewery':
        return accentGold; // Championship gold (matches updated theme)
      case 'coffee':
      case 'cafe':
        return primaryBlue; // Electric blue (matches updated theme)
      case 'nightlife':
        return primaryRed; // Vibrant red (matches updated theme)
      case 'fast food':
        return secondaryEmerald; // Success green (matches updated theme)
      default:
        return primaryPurple;
    }
  }
  
  static Color getTeamColor(String teamName) {
    switch (teamName.toLowerCase()) {
      case 'alabama crimson tide':
        return const Color(0xFF9E1B32);
      case 'auburn tigers':
        return const Color(0xFF0C2340);
      case 'georgia bulldogs':
        return const Color(0xFFBA0C2F);
      case 'florida gators':
        return const Color(0xFF0021A5);
      case 'lsu tigers':
        return const Color(0xFF461D7C);
      case 'tennessee volunteers':
        return const Color(0xFFFF8200);
      case 'texas a&m aggies':
        return const Color(0xFF500000);
      default:
        return primaryPurple;
    }
  }
} 