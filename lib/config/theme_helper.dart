import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme Helper for consistent styling throughout the app
/// Use this class instead of hardcoded colors to ensure unified appearance
class ThemeHelper {
  // Private constructor to prevent instantiation
  ThemeHelper._();

  // ====================
  // CONTEXT-AWARE COLORS
  // ====================
  
  /// Get primary color based on current theme
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  /// Get secondary/accent color based on current theme
  static Color accentColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  
  /// Get surface color based on current theme
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// Get background color based on current theme
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// Get primary text color based on current theme
  static Color textColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  /// Get secondary text color based on current theme
  static Color textSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  
  /// Get tertiary/hint text color based on current theme
  static Color textHintColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }
  
  // ====================
  // SPORTS APP SPECIFIC COLORS
  // ====================
  
  /// Get the signature orange color for favorites, highlights, etc.
  static Color get favoriteColor => AppTheme.primaryOrange;
  
  /// Get success color (e.g., for winning teams, successful actions)
  static Color get successColor => AppTheme.successColor;
  
  /// Get warning color (e.g., for pending games, cautions)
  static Color get warningColor => AppTheme.warningColor;
  
  /// Get error color (e.g., for failed actions, losing teams)
  static Color get errorColor => AppTheme.primaryRed;
  
  /// Get info color (e.g., for general information)
  static Color get infoColor => AppTheme.infoColor;
  
  /// Get championship gold color for premium features
  static Color get premiumColor => AppTheme.accentGold;
  
  // ====================
  // CARD STYLES
  // ====================
  
  /// Standard card decoration for the app
  static BoxDecoration cardDecoration(BuildContext context, {
    bool elevated = false,
    Color? customColor,
  }) {
    return BoxDecoration(
      color: customColor ?? surfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      boxShadow: elevated ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ] : [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Premium gradient card for special content
  static BoxDecoration premiumCardDecoration() {
    return AppTheme.premiumCardDecoration;
  }
  
  /// Accent gradient card for highlights
  static BoxDecoration accentCardDecoration() {
    return AppTheme.buttonGradientDecoration;
  }
  
  // ====================
  // APP BAR STYLES
  // ====================
  
  /// Consistent app bar styling
  static AppBar createAppBar(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? textColor(context),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: backgroundColor ?? surfaceColor(context),
      foregroundColor: foregroundColor ?? textColor(context),
      elevation: 0,
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      iconTheme: IconThemeData(
        color: foregroundColor ?? textColor(context),
      ),
    );
  }
  
  // ====================
  // BUTTON STYLES
  // ====================
  
  /// Primary button style
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: favoriteColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: favoriteColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
  
  /// Secondary button style
  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor(context),
      side: BorderSide(color: primaryColor(context), width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
  
  /// Success button style
  static ButtonStyle successButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: successColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: successColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
  
  // ====================
  // TEXT STYLES
  // ====================
  
  /// Heading 1 style
  static TextStyle h1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color ?? textColor(context),
      letterSpacing: -0.5,
    );
  }
  
  /// Heading 2 style
  static TextStyle h2(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color ?? textColor(context),
      letterSpacing: -0.3,
    );
  }
  
  /// Heading 3 style
  static TextStyle h3(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? textColor(context),
      letterSpacing: -0.2,
    );
  }
  
  /// Body text style
  static TextStyle body(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? textColor(context),
      height: 1.5,
    );
  }
  
  /// Small text style
  static TextStyle small(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondaryColor(context),
    );
  }
  
  /// Caption text style
  static TextStyle caption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? textHintColor(context),
    );
  }
  
  // ====================
  // UTILITY METHODS
  // ====================
  
  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get contrast color (white for dark backgrounds, dark for light backgrounds)
  static Color contrastColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }
  
  /// Get team-specific color
  static Color teamColor(String teamName) {
    return AppTheme.getTeamColor(teamName);
  }
  
  /// Get venue category color
  static Color categoryColor(String category) {
    return AppTheme.getCategoryColor(category);
  }
  
  /// Get status color
  static Color statusColor(String status) {
    return AppTheme.getStatusColor(status);
  }
  
  // ====================
  // COMMON DECORATIONS
  // ====================
  
  /// Input field decoration
  static InputDecoration inputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDarkMode(context) 
          ? AppTheme.surfaceElevated 
          : AppTheme.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textHintColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textHintColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: favoriteColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: textSecondaryColor(context),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: textHintColor(context),
        fontSize: 16,
      ),
    );
  }
} 