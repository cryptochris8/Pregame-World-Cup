import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// Displays the favorite teams section with team chips and an add button.
class EditProfileFavoriteTeamsSection extends StatelessWidget {
  final List<String> selectedTeams;
  final ValueChanged<String> onRemoveTeam;
  final VoidCallback onAddTeam;

  const EditProfileFavoriteTeamsSection({
    super.key,
    required this.selectedTeams,
    required this.onRemoveTeam,
    required this.onAddTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favorite Teams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: onAddTeam,
                child: const Text(
                  'Add Team',
                  style: TextStyle(color: Color(0xFFFBBF24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Teams
          if (selectedTeams.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sports_soccer, color: Colors.white54),
                  SizedBox(width: 12),
                  Text(
                    'No favorite teams selected',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedTeams
                  .map((team) => _buildTeamChip(team))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamChip(String team) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TeamLogoHelper.getTeamLogoWidget(
            teamName: team,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            team,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemoveTeam(team),
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
