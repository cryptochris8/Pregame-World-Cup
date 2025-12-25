import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../config/app_theme.dart';

class SocialStatsCard extends StatelessWidget {
  final SocialStats stats;
  final VoidCallback? onFriendsPressed;
  final VoidCallback? onGamesPressed;
  final VoidCallback? onVenuesPressed;

  const SocialStatsCard({
    super.key,
    required this.stats,
    this.onFriendsPressed,
    this.onGamesPressed,
    this.onVenuesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryPurple, AppTheme.primaryElectricBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Social Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  label: 'Friends',
                  value: stats.friendsCount.toString(),
                  onTap: onFriendsPressed,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildStatItem(
                  icon: Icons.sports_football,
                  label: 'Games',
                  value: stats.gamesAttended.toString(),
                  onTap: onGamesPressed,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildStatItem(
                  icon: Icons.restaurant,
                  label: 'Venues',
                  value: stats.venuesVisited.toString(),
                  onTap: onVenuesPressed,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Secondary stats
          Row(
            children: [
              Expanded(
                child: _buildSecondaryStatItem(
                  icon: Icons.rate_review,
                  label: 'Reviews',
                  value: stats.reviewsCount.toString(),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildSecondaryStatItem(
                  icon: Icons.photo_camera,
                  label: 'Photos',
                  value: stats.photosShared.toString(),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildSecondaryStatItem(
                  icon: Icons.thumb_up,
                  label: 'Likes',
                  value: stats.likesReceived.toString(),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildSecondaryStatItem(
                  icon: Icons.check_circle,
                  label: 'Check-ins',
                  value: stats.checkInsCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 