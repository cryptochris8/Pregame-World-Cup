import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// A button to toggle favorite status for teams or matches
class FavoriteButton extends StatelessWidget {
  /// Whether the item is currently favorited
  final bool isFavorite;

  /// Callback when the favorite button is pressed
  final VoidCallback? onPressed;

  /// Size of the icon
  final double size;

  /// Color when favorited (defaults to red)
  final Color? favoriteColor;

  /// Color when not favorited (defaults to grey)
  final Color? unfavoriteColor;

  /// Whether to animate the transition
  final bool animate;

  /// Tooltip text
  final String? tooltip;

  /// Whether to show a confirmation dialog before unfavoriting
  final bool confirmBeforeUnfavorite;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
    this.animate = true,
    this.tooltip,
    this.confirmBeforeUnfavorite = false,
  });

  Future<void> _handlePress(BuildContext context) async {
    if (isFavorite && confirmBeforeUnfavorite) {
      final confirmed = await showUnfavoriteConfirmation(context);
      if (confirmed == true) {
        onPressed?.call();
      }
    } else {
      onPressed?.call();
    }
  }

  /// Show a confirmation dialog before removing from favorites.
  /// Returns true if confirmed, false or null otherwise.
  static Future<bool?> showUnfavoriteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.removeFromFavorites),
        content: Text(l10n.removeFromFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favColor = favoriteColor ?? Colors.red;
    final unfavColor = unfavoriteColor ?? theme.colorScheme.outline;

    Widget icon = Icon(
      isFavorite ? Icons.favorite : Icons.favorite_border,
      color: isFavorite ? favColor : unfavColor,
      size: size,
    );

    if (animate) {
      icon = AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? favColor : unfavColor,
          size: size,
        ),
      );
    }

    return IconButton(
      icon: icon,
      onPressed: onPressed != null ? () => _handlePress(context) : null,
      tooltip: tooltip ?? (isFavorite ? 'Remove from favorites' : 'Add to favorites'),
      splashRadius: size * 0.8,
    );
  }
}

/// A star-based favorite button
class StarFavoriteButton extends StatelessWidget {
  /// Whether the item is currently favorited
  final bool isFavorite;

  /// Callback when the favorite button is pressed
  final VoidCallback? onPressed;

  /// Size of the icon
  final double size;

  /// Color when favorited (defaults to amber)
  final Color? favoriteColor;

  /// Color when not favorited (defaults to grey)
  final Color? unfavoriteColor;

  const StarFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favColor = favoriteColor ?? Colors.amber;
    final unfavColor = unfavoriteColor ?? theme.colorScheme.outline;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? favColor : unfavColor,
          size: size,
        ),
      ),
      onPressed: onPressed,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      splashRadius: size * 0.8,
    );
  }
}

/// A chip displaying favorite count
class FavoriteCountChip extends StatelessWidget {
  /// Number of favorites
  final int count;

  /// Label text
  final String label;

  /// Icon to display
  final IconData icon;

  /// Color for the chip
  final Color? color;

  const FavoriteCountChip({
    super.key,
    required this.count,
    this.label = 'Favorites',
    this.icon = Icons.favorite,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: theme.textTheme.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
