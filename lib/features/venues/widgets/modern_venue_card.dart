import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../recommendations/domain/entities/place.dart';

/// Modern venue card inspired by popular social media apps
/// Features gradients, shadows, and vibrant colors for better engagement
class ModernVenueCard extends StatelessWidget {
  final Place venue;
  final VoidCallback? onTap;
  final bool isCompact;

  const ModernVenueCard({
    super.key,
    required this.venue,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: isCompact ? _buildCompactCard(context) : _buildFullCard(context),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Image Section with Gradient Overlay
        Stack(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.getCategoryColor(_getVenueCategory()),
                    AppTheme.getCategoryColor(_getVenueCategory()).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(_getVenueCategory()),
                  size: 60,
                  color: AppTheme.textWhite.withValues(alpha: 0.9),
                ),
              ),
            ),
            
            // Top badges
            Positioned(
              top: 12,
              left: 12,
              child: _buildCategoryBadge(_getVenueCategory()),
            ),
            
            Positioned(
              top: 12,
              right: 12,
              child: _buildRatingBadge(venue.rating ?? 0.0),
            ),
          ],
        ),
        
        // Content Section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Name
              Text(
                venue.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                                          color: AppTheme.secondaryPurple,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venue.vicinity ?? 'Address not available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getCategoryColor(_getVenueCategory()),
                  AppTheme.getCategoryColor(_getVenueCategory()).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(_getVenueCategory()),
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  _getVenueCategory(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                                          Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.accentGold,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      (venue.rating ?? 0.0).toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.getCategoryColor(category),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentGold,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getVenueCategory() {
    // Extract category from venue types
    if (venue.types != null && venue.types!.isNotEmpty) {
      final types = venue.types!;
      if (types.contains('bar')) return 'Sports Bar';
      if (types.contains('restaurant')) return 'Restaurant';
      if (types.contains('cafe')) return 'Cafe';
      if (types.contains('night_club')) return 'Nightlife';
      if (types.contains('meal_takeaway')) return 'Fast Food';
      return types.first.replaceAll('_', ' ').split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
    }
    return 'Venue';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sports bar':
      case 'sports_bar':
        return Icons.sports_bar;
      case 'restaurant':
        return Icons.restaurant;
      case 'brewery':
        return Icons.local_drink;
      case 'coffee':
      case 'cafe':
        return Icons.local_cafe;
      case 'nightlife':
        return Icons.nightlife;
      case 'fast food':
        return Icons.fastfood;
      default:
        return Icons.store;
    }
  }
} 