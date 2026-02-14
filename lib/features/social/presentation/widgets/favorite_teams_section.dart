import 'package:flutter/material.dart';

class FavoriteTeamsSection extends StatelessWidget {
  final List<String> favoriteTeams;
  final bool isCurrentUser;
  final Function(String) onTeamPressed;
  final VoidCallback? onEditTeams;

  const FavoriteTeamsSection({
    super.key,
    required this.favoriteTeams,
    required this.isCurrentUser,
    required this.onTeamPressed,
    this.onEditTeams,
  });

  @override
  Widget build(BuildContext context) {
    if (favoriteTeams.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (isCurrentUser)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Favorite Teams',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onEditTeams,
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: favoriteTeams.length,
            itemBuilder: (context, index) {
              final team = favoriteTeams[index];
              return _buildTeamCard(team);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(String team) {
    return GestureDetector(
      onTap: () => onTeamPressed(team),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B4513),
              Colors.orange[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              team,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorite teams yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(height: 8),
            const Text(
              'Add teams to show your support!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onEditTeams,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Teams'),
            ),
          ],
        ],
      ),
    );
  }
} 