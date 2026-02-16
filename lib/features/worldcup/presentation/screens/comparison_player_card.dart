import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/app_theme.dart';
import '../../../../domain/models/player.dart';
import 'player_comparison_helpers.dart';

/// Card showing a selected player for comparison, or an empty slot to select one
class ComparisonPlayerCard extends StatelessWidget {
  final Player? player;
  final int slot;
  final VoidCallback onTap;

  const ComparisonPlayerCard({
    super.key,
    this.player,
    required this.slot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: player != null
                ? (slot == 1 ? AppTheme.primaryOrange : AppTheme.accentGold)
                    .withValues(alpha: 0.5)
                : Colors.white24,
            width: 1.5,
          ),
        ),
        child: player != null
            ? _buildSelectedPlayer(player!)
            : _buildEmptySlot(),
      ),
    );
  }

  Widget _buildSelectedPlayer(Player player) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: player.photoUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: player.photoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholderAvatar(),
                  errorWidget: (context, url, error) =>
                      _buildPlaceholderAvatar(),
                )
              : _buildPlaceholderAvatar(),
        ),
        const SizedBox(height: 8),
        Text(
          player.commonName.isNotEmpty ? player.commonName : player.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getFlagEmoji(player.fifaCode),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              player.position,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to change',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white.withValues(alpha: 0.5),
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select Player $slot',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to choose',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade800,
      child: const Icon(Icons.person, color: Colors.white54, size: 40),
    );
  }
}
