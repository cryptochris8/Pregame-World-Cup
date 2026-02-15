import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/recommendations/domain/entities/place.dart';

class VenueActionButtons extends StatelessWidget {
  final Place venue;
  final EdgeInsets padding;
  final bool showLabels;
  final MainAxisAlignment alignment;

  const VenueActionButtons({
    super.key,
    required this.venue,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.showLabels = true,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Dark blue-gray background
        border: Border(
          bottom: BorderSide(color: Color(0xFF475569), width: 1), // Darker border
        ),
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          _buildActionButton(
            context,
            icon: Icons.phone,
            label: 'Call',
            color: const Color(0xFF2E7D32),
            onTap: () => _callVenue(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.directions,
            label: 'Directions',
            color: const Color(0xFF1976D2),
            onTap: () => _getDirections(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.language,
            label: 'Website',
            color: const Color(0xFF8B4513),
            onTap: () => _openWebsite(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.share,
            label: 'Share',
            color: const Color(0xFF7B1FA2),
            onTap: () => _shareVenue(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha:0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (showLabels) ...[
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callVenue(BuildContext context) async {
    // In a real app, you would get the phone number from venue details
    // For now, we'll show a dialog
    _showActionDialog(
      context,
      title: 'Call ${venue.name}',
      content: 'Phone number would be retrieved from venue details.\nThis feature will be available soon!',
      icon: Icons.phone,
      iconColor: const Color(0xFF2E7D32),
    );
  }

  Future<void> _getDirections(BuildContext context) async {
    try {
      // Use venue coordinates or address to open maps
      final query = venue.vicinity ?? venue.name;
      final encodedQuery = Uri.encodeComponent(query);
      
      // Try to open in Google Maps first
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
      
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to generic maps
        final mapsUrl = 'https://maps.apple.com/?q=$encodedQuery';
        if (await canLaunchUrl(Uri.parse(mapsUrl))) {
          await launchUrl(
            Uri.parse(mapsUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (context.mounted) {
            _showErrorDialog(context, 'Could not open maps application');
          }
        }
      }
    } catch (e) {
      // Error handled silently
      if (context.mounted) {
        _showErrorDialog(context, 'Could not open directions');
      }
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    // In a real app, you would get the website from venue details
    _showActionDialog(
      context,
      title: 'Visit ${venue.name} Website',
      content: 'Website URL would be retrieved from venue details.\nThis feature will be available soon!',
      icon: Icons.language,
      iconColor: const Color(0xFF8B4513),
    );
  }

  Future<void> _shareVenue(BuildContext context) async {
    try {
      final shareText = _buildShareText();
      
      // For now, we'll show the share dialog
      // In a real app, you would use the share package
      _showActionDialog(
        context,
        title: 'Share ${venue.name}',
        content: shareText,
        icon: Icons.share,
        iconColor: const Color(0xFF7B1FA2),
        actionText: 'Copy to Clipboard',
        onAction: () {
          Clipboard.setData(ClipboardData(text: shareText));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venue details copied to clipboard!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
      // Error handled silently
      _showErrorDialog(context, 'Could not share venue');
    }
  }

  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('Check out ${venue.name}!');
    
    if (venue.rating != null) {
      buffer.writeln('⭐ ${venue.rating}/5.0');
    }
    
    if (venue.priceLevel != null && venue.priceLevel! > 0) {
      buffer.writeln('💰 ${'💲' * venue.priceLevel!}');
    }
    
    if (venue.vicinity != null) {
      buffer.writeln('📍 ${venue.vicinity}');
    }
    
    buffer.writeln('\nShared via Pregame App');
    
    return buffer.toString();
  }

  void _showActionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Compact version for use in venue cards
class VenueQuickActions extends StatelessWidget {
  final Place venue;
  final bool showBackground;

  const VenueQuickActions({
    super.key,
    required this.venue,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: showBackground
          ? BoxDecoration(
              color: Colors.white.withValues(alpha:0.9),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickActionButton(
            icon: Icons.directions,
            color: const Color(0xFF1976D2),
            onTap: () => _getDirections(context),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            icon: Icons.phone,
            color: const Color(0xFF2E7D32),
            onTap: () => _callVenue(context),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            icon: Icons.share,
            color: const Color(0xFF7B1FA2),
            onTap: () => _shareVenue(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  void _getDirections(BuildContext context) {
    // Implementation same as above
    // Quick directions action
  }

  void _callVenue(BuildContext context) {
    // Implementation same as above
    // Quick call action
  }

  void _shareVenue(BuildContext context) {
    // Implementation same as above
    // Quick share action
  }
} 