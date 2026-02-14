import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import 'package:pregame_world_cup/injection_container.dart';
import 'package:pregame_world_cup/config/theme_helper.dart';
import 'package:pregame_world_cup/core/utils/team_logo_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All 48 FIFA World Cup 2026 qualified national teams, grouped by confederation.
const List<String> worldCupTeams = [
  // CONCACAF (Host nations first)
  'United States',
  'Mexico',
  'Canada',
  'Costa Rica',
  'Honduras',
  'Jamaica',
  'Panama',
  // CONMEBOL
  'Argentina',
  'Bolivia',
  'Brazil',
  'Chile',
  'Colombia',
  'Ecuador',
  'Paraguay',
  'Peru',
  'Uruguay',
  'Venezuela',
  // UEFA
  'Albania',
  'Austria',
  'Belgium',
  'Croatia',
  'Denmark',
  'England',
  'France',
  'Germany',
  'Netherlands',
  'Poland',
  'Portugal',
  'Scotland',
  'Serbia',
  'Spain',
  'Switzerland',
  'Turkey',
  'Ukraine',
  'Wales',
  // AFC
  'Australia',
  'Iran',
  'Iraq',
  'Japan',
  'Saudi Arabia',
  'South Korea',
  'Qatar',
  'Uzbekistan',
  // CAF
  'Cameroon',
  'Egypt',
  'Morocco',
  'Nigeria',
  'Senegal',
  // OFC
  'New Zealand',
];

class FavoriteTeamsScreen extends StatefulWidget {
  const FavoriteTeamsScreen({super.key});

  @override
  _FavoriteTeamsScreenState createState() => _FavoriteTeamsScreenState();
}

class _FavoriteTeamsScreenState extends State<FavoriteTeamsScreen> {
  final AuthService _authService = sl<AuthService>();
  List<String> _selectedTeams = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteTeams();
  }

  /// Load favorite teams from Firebase, with local storage fallback
  Future<void> _loadFavoriteTeams() async {
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        // Try to load from Firebase first
        try {
          List<String> favorites = await _authService.getFavoriteTeams(userId);
          if (mounted) {
            setState(() => _selectedTeams = favorites);
          }
          // Save to local storage as backup
          await _saveToLocalStorage(favorites);
        } catch (firebaseError) {
          // If Firebase fails, try local storage
          List<String> localFavorites = await _loadFromLocalStorage();
          if (mounted) {
            setState(() {
              _selectedTeams = localFavorites;
              _errorMessage = null;
            });
          }
        }
      } else {
        // User not logged in, use local storage
        List<String> localFavorites = await _loadFromLocalStorage();
        if (mounted) {
          setState(() {
            _selectedTeams = localFavorites;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Could not load saved favorites. You can still select teams below.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Save favorite teams to Firebase, with local storage fallback
  Future<void> _saveFavoriteTeams() async {
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final userId = _authService.currentUser?.uid;

      // Always save to local storage first
      await _saveToLocalStorage(_selectedTeams);

      if (userId != null) {
        // Try to save to Firebase
        try {
          await _authService.updateFavoriteTeams(userId, _selectedTeams);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Favorite teams saved & synced!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (firebaseError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Favorite teams saved!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Favorite teams saved!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Return the selected teams to the previous screen
      if (mounted) {
        Navigator.pop(context, _selectedTeams);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving favorites. Please try again.'),
            backgroundColor: const Color(0xFF1E293B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Save favorites to local storage
  Future<void> _saveToLocalStorage(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_teams', favorites);
    } catch (e) {
      // Silently handled; local storage is best-effort
    }
  }

  /// Load favorites from local storage
  Future<List<String>> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('favorite_teams') ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: ThemeHelper.primaryColor(context),
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logos/pregame_logo.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.sports_soccer, color: ThemeHelper.favoriteColor, size: 40);
                },
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Select Favorite Teams',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              tooltip: 'Save Favorites',
              onPressed: _selectedTeams.isNotEmpty ? _saveFavoriteTeams : null,
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ThemeHelper.favoriteColor,
                  ),
                ),
              ),
            )
        ],
      ),
      body: _isLoading && _selectedTeams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: ThemeHelper.favoriteColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your favorite teams...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Show error/info message if there is one, but don't block the UI
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Show selected count
                if (_selectedTeams.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '${_selectedTeams.length} team${_selectedTeams.length == 1 ? '' : 's'} selected',
                      style: TextStyle(
                        color: ThemeHelper.favoriteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                // Team selection list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: worldCupTeams.length,
                    itemBuilder: (context, index) {
                      final team = worldCupTeams[index];
                      final isSelected = _selectedTeams.contains(team);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeHelper.favoriteColor.withOpacity(0.1)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: ThemeHelper.favoriteColor, width: 2)
                              : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: CheckboxListTile(
                          secondary: TeamLogoHelper.getTeamLogoWidget(
                            teamName: team,
                            size: 28,
                            fallbackColor: isSelected ? ThemeHelper.favoriteColor : Colors.white70,
                          ),
                          title: Text(
                            team,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: isSelected,
                          activeColor: ThemeHelper.favoriteColor,
                          checkColor: Colors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (!_selectedTeams.contains(team)) {
                                  _selectedTeams.add(team);
                                }
                              } else {
                                _selectedTeams.remove(team);
                              }
                            });
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
