import 'package:flutter/material.dart';
import '../../../../core/utils/team_logo_helper.dart';

/// Bottom sheet that displays a list of available teams to select as favorites.
class TeamSelectorBottomSheet extends StatelessWidget {
  final List<String> availableTeams;
  final List<String> selectedTeams;
  final ValueChanged<String> onTeamToggled;
  final VoidCallback onMaxReached;

  const TeamSelectorBottomSheet({
    super.key,
    required this.availableTeams,
    required this.selectedTeams,
    required this.onTeamToggled,
    required this.onMaxReached,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95),
            Color(0xFF7C3AED),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Favorite Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Team List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableTeams.length,
              itemBuilder: (context, index) {
                final team = availableTeams[index];
                final isSelected = selectedTeams.contains(team);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFBBF24)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: TeamLogoHelper.getTeamLogoWidget(
                      teamName: team,
                      size: 32,
                    ),
                    title: Text(
                      team,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFFFBBF24))
                        : const Icon(Icons.add_circle_outline,
                            color: Colors.white54),
                    onTap: () {
                      if (!isSelected && selectedTeams.length >= 5) {
                        onMaxReached();
                      } else {
                        onTeamToggled(team);
                      }
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
