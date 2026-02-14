import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../../config/theme_helper.dart';

class FavoriteTeamsScreen extends StatefulWidget {
  const FavoriteTeamsScreen({super.key});

  @override
  State<FavoriteTeamsScreen> createState() => _FavoriteTeamsScreenState();
}

class _FavoriteTeamsScreenState extends State<FavoriteTeamsScreen> {
  /// All 48 FIFA World Cup 2026 qualified national teams, grouped by confederation.
  static const List<String> _worldCupTeams = [
    // CONCACAF (Host nations first)
    'United States', 'Mexico', 'Canada', 'Costa Rica', 'Honduras',
    'Jamaica', 'Panama',
    // CONMEBOL
    'Argentina', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Ecuador',
    'Paraguay', 'Peru', 'Uruguay', 'Venezuela',
    // UEFA
    'Albania', 'Austria', 'Belgium', 'Croatia', 'Denmark', 'England',
    'France', 'Germany', 'Netherlands', 'Poland', 'Portugal', 'Scotland',
    'Serbia', 'Spain', 'Switzerland', 'Turkey', 'Ukraine', 'Wales',
    // AFC
    'Australia', 'Iran', 'Iraq', 'Japan', 'Saudi Arabia', 'South Korea',
    'Qatar', 'Uzbekistan',
    // CAF
    'Cameroon', 'Egypt', 'Morocco', 'Nigeria', 'Senegal',
    // OFC
    'New Zealand',
  ];

  final Set<String> _favoriteTeams = <String>{};
  bool _isLoading = false;
  bool _isLoadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadExistingFavorites();
  }

  Future<void> _loadExistingFavorites() async {
    try {
      List<String> favorites = [];

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data()?['favoriteTeams'] != null) {
            favorites = List<String>.from(userDoc.data()!['favoriteTeams']);
          } else {
            // Fall back to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            favorites = prefs.getStringList('favorite_teams') ?? [];
          }
        } catch (e) {
          // Firebase error, use local storage
          final prefs = await SharedPreferences.getInstance();
          favorites = prefs.getStringList('favorite_teams') ?? [];
        }
      } else {
        // User not logged in, load from local storage
        final prefs = await SharedPreferences.getInstance();
        favorites = prefs.getStringList('favorite_teams') ?? [];
      }

      if (mounted) {
        setState(() {
          _favoriteTeams.addAll(favorites);
          _isLoadingExisting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingExisting = false;
        });
      }
    }
  }

  void _toggleTeam(String team) {
    setState(() {
      if (_favoriteTeams.contains(team)) {
        _favoriteTeams.remove(team);
      } else {
        _favoriteTeams.add(team);
      }
    });
  }

  Future<void> _saveTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoritesList = _favoriteTeams.toList();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_teams', favoritesList);

      // Also save to Firebase if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'favoriteTeams': favoritesList,
          }, SetOptions(merge: true));
        } catch (e) {
          // Firebase save failed, but local save succeeded
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved ${favoritesList.length} favorite team${favoritesList.length == 1 ? '' : 's'}!'),
            backgroundColor: ThemeHelper.favoriteColor,
          ),
        );

        // Return to previous screen with the saved teams
        Navigator.of(context).pop(favoritesList);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save favorite teams. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            TeamLogoHelper.getPregameLogo(height: 32),
            const SizedBox(width: 8),
            const Text(
              'Favorite Teams',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: ThemeHelper.primaryColor(context),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _favoriteTeams.isNotEmpty ? _saveTeams : null,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: _favoriteTeams.isNotEmpty ? ThemeHelper.favoriteColor : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: _isLoadingExisting
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeHelper.favoriteColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select Your Teams',
                      style: TextStyle(
                        color: ThemeHelper.favoriteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your favorite World Cup 2026 teams to get personalized game recommendations and highlights.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Selected teams counter
          if (_favoriteTeams.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ThemeHelper.favoriteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ThemeHelper.favoriteColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: ThemeHelper.favoriteColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_favoriteTeams.length} team${_favoriteTeams.length == 1 ? '' : 's'} selected',
                    style: TextStyle(
                      color: ThemeHelper.favoriteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Teams list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _worldCupTeams.length,
              itemBuilder: (context, index) {
                final team = _worldCupTeams[index];
                final isSelected = _favoriteTeams.contains(team);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: ThemeHelper.favoriteColor, width: 2)
                        : Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      _toggleTeam(team);
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    checkColor: Colors.white,
                    activeColor: ThemeHelper.favoriteColor,
                    title: Row(
                      children: [
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: team,
                          size: 28,
                          fallbackColor: isSelected ? ThemeHelper.favoriteColor : Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            team,
                            style: TextStyle(
                              color: isSelected ? ThemeHelper.favoriteColor : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          Icon(
                            Icons.star,
                            color: ThemeHelper.favoriteColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
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
