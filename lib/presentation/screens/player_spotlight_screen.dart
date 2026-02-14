import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/models/player.dart';
import '../../data/services/player_service.dart';
import '../widgets/player_card.dart';
import 'player_detail_screen.dart';

/// Player Spotlight Screen
/// Displays all 260 World Cup 2026 players with filtering and search
class PlayerSpotlightScreen extends StatefulWidget {
  const PlayerSpotlightScreen({super.key});

  @override
  State<PlayerSpotlightScreen> createState() => _PlayerSpotlightScreenState();
}

class _PlayerSpotlightScreenState extends State<PlayerSpotlightScreen> {
  final PlayerService _playerService = PlayerService();
  final ScrollController _scrollController = ScrollController();

  List<Player> _allPlayers = [];
  List<Player> _displayedPlayers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedFilter = 'All Teams';
  final TextEditingController _searchController = TextEditingController();

  // Pagination - increased for 1000+ players
  static const int _pageSize = 200;
  int _currentOffset = 0;

  // Filter options - All 44 World Cup teams + position filters
  final List<String> _filterOptions = [
    'All Teams',
    // Position filters
    'Goalkeepers',
    'Defenders',
    'Midfielders',
    'Forwards',
    // Stat filters
    'Top Value',
    'Top Scorers',
    'Most Capped',
    // All 44 teams alphabetically
    'Algeria',
    'Argentina',
    'Australia',
    'Austria',
    'Belgium',
    'Brazil',
    'Cameroon',
    'Canada',
    'Chile',
    'Colombia',
    'Costa Rica',
    'Croatia',
    'Denmark',
    'Ecuador',
    'Egypt',
    'England',
    'France',
    'Germany',
    'Ghana',
    'Honduras',
    'Iran',
    'Italy',
    'Ivory Coast',
    'Jamaica',
    'Japan',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Panama',
    'Peru',
    'Poland',
    'Portugal',
    'Qatar',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'South Korea',
    'Spain',
    'Switzerland',
    'Tunisia',
    'Uruguay',
    'USA',
  ];

  final Map<String, String> _teamCodes = {
    'Algeria': 'ALG',
    'Argentina': 'ARG',
    'Australia': 'AUS',
    'Austria': 'AUT',
    'Belgium': 'BEL',
    'Brazil': 'BRA',
    'Cameroon': 'CMR',
    'Canada': 'CAN',
    'Chile': 'CHI',
    'Colombia': 'COL',
    'Costa Rica': 'CRC',
    'Croatia': 'CRO',
    'Denmark': 'DEN',
    'Ecuador': 'ECU',
    'Egypt': 'EGY',
    'England': 'ENG',
    'France': 'FRA',
    'Germany': 'GER',
    'Ghana': 'GHA',
    'Honduras': 'HON',
    'Iran': 'IRN',
    'Italy': 'ITA',
    'Ivory Coast': 'CIV',
    'Jamaica': 'JAM',
    'Japan': 'JPN',
    'Mexico': 'MEX',
    'Morocco': 'MAR',
    'Netherlands': 'NED',
    'New Zealand': 'NZL',
    'Nigeria': 'NGA',
    'Panama': 'PAN',
    'Peru': 'PER',
    'Poland': 'POL',
    'Portugal': 'POR',
    'Qatar': 'QAT',
    'Saudi Arabia': 'KSA',
    'Senegal': 'SEN',
    'Serbia': 'SRB',
    'South Korea': 'KOR',
    'Spain': 'ESP',
    'Switzerland': 'SUI',
    'Tunisia': 'TUN',
    'Uruguay': 'URU',
    'USA': 'USA',
  };

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more when user is 80% down the list
    if (currentScroll >= maxScroll * 0.8) {
      _loadMorePlayers();
    }
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _hasMore = true;
      _displayedPlayers = [];
    });

    try {
      final players = await _playerService.getAllPlayers(
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _displayedPlayers = players;
        _currentOffset = players.length;
        _hasMore = players.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingPlayers(e.toString()))),
        );
      }
    }
  }

  Future<void> _loadMorePlayers() async {
    if (_isLoadingMore || !_hasMore || _selectedFilter != 'All Teams') return;

    setState(() => _isLoadingMore = true);

    try {
      final morePlayers = await _playerService.getAllPlayers(
        limit: _pageSize,
        offset: _currentOffset,
      );

      setState(() {
        _displayedPlayers.addAll(morePlayers);
        _currentOffset += morePlayers.length;
        _hasMore = morePlayers.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingPlayers(e.toString()))),
        );
      }
    }
  }

  Future<void> _applyFilter(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _isLoading = true;
      _currentOffset = 0;
      _hasMore = true;
    });

    try {
      List<Player> filteredPlayers;

      if (filter == 'All Teams') {
        // Use pagination for all teams
        filteredPlayers = await _playerService.getAllPlayers(
          limit: _pageSize,
          offset: 0,
        );
        _currentOffset = filteredPlayers.length;
        _hasMore = filteredPlayers.length >= _pageSize;
      } else if (_teamCodes.containsKey(filter)) {
        filteredPlayers = await _playerService.getPlayersByTeam(_teamCodes[filter]!);
        _hasMore = false; // Team filters don't support pagination
      } else if (filter == 'Goalkeepers') {
        filteredPlayers = await _playerService.getPlayersByCategory('Goalkeeper', limit: _pageSize);
        _hasMore = false;
      } else if (filter == 'Defenders') {
        filteredPlayers = await _playerService.getPlayersByCategory('Defender', limit: _pageSize);
        _hasMore = false;
      } else if (filter == 'Midfielders') {
        filteredPlayers = await _playerService.getPlayersByCategory('Midfielder', limit: _pageSize);
        _hasMore = false;
      } else if (filter == 'Forwards') {
        filteredPlayers = await _playerService.getPlayersByCategory('Forward', limit: _pageSize);
        _hasMore = false;
      } else if (filter == 'Top Value') {
        filteredPlayers = await _playerService.getTopPlayersByValue(limit: 50);
        _hasMore = false;
      } else if (filter == 'Top Scorers') {
        filteredPlayers = await _playerService.getTopScorers(limit: 50);
        _hasMore = false;
      } else if (filter == 'Most Capped') {
        filteredPlayers = await _playerService.getMostCappedPlayers(limit: 50);
        _hasMore = false;
      } else {
        filteredPlayers = [];
        _hasMore = false;
      }

      setState(() {
        _displayedPlayers = filteredPlayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorFilteringPlayers(e.toString()))),
        );
      }
    }
  }

  void _searchPlayers(String query) async {
    if (query.isEmpty) {
      _applyFilter(_selectedFilter);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _playerService.searchPlayers(query);
      setState(() {
        _displayedPlayers = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getLocalizedFilterName(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'All Teams':
        return l10n.allTeams;
      case 'Goalkeepers':
        return l10n.goalkeepers;
      case 'Defenders':
        return l10n.defenders;
      case 'Midfielders':
        return l10n.midfielders;
      case 'Forwards':
        return l10n.forwards;
      case 'Top Value':
        return l10n.topValue;
      case 'Top Scorers':
        return l10n.topScorers;
      case 'Most Capped':
        return l10n.mostCapped;
      default:
        return filter; // Keep team names as-is (Brazil, Argentina, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playerSpotlight),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchPlayers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchPlayers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _searchPlayers,
            ),
          ),

          // Filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_getLocalizedFilterName(filter, l10n)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _applyFilter(filter);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Player count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.playersCount(_displayedPlayers.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_selectedFilter != 'All Teams')
                  TextButton(
                    onPressed: () => _applyFilter('All Teams'),
                    child: Text(l10n.clearFilters),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Players grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedPlayers.isEmpty
                    ? Center(child: Text(l10n.noPlayersFound))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _displayedPlayers.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at the end
                          if (index >= _displayedPlayers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final player = _displayedPlayers[index];
                          return PlayerCard(
                            player: player,
                            onTap: () => _showPlayerDetails(player),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showPlayerDetails(Player player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerDetailScreen(player: player),
      ),
    );
  }
}
