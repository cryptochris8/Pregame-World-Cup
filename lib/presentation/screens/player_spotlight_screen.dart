import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../../data/services/player_service.dart';
import '../widgets/player_photo.dart';

/// Player Spotlight Screen
/// Displays all 260 World Cup 2026 players with filtering and search
class PlayerSpotlightScreen extends StatefulWidget {
  const PlayerSpotlightScreen({super.key});

  @override
  State<PlayerSpotlightScreen> createState() => _PlayerSpotlightScreenState();
}

class _PlayerSpotlightScreenState extends State<PlayerSpotlightScreen> {
  final PlayerService _playerService = PlayerService();

  List<Player> _allPlayers = [];
  List<Player> _displayedPlayers = [];
  bool _isLoading = true;
  String _selectedFilter = 'All Teams';
  final TextEditingController _searchController = TextEditingController();

  // Filter options
  final List<String> _filterOptions = [
    'All Teams',
    'Brazil',
    'Argentina',
    'Germany',
    'France',
    'Spain',
    'England',
    'Italy',
    'Uruguay',
    'Netherlands',
    'Portugal',
    'Goalkeepers',
    'Defenders',
    'Midfielders',
    'Forwards',
    'Top Value',
    'Top Scorers',
    'Most Capped',
  ];

  final Map<String, String> _teamCodes = {
    'Brazil': 'BRA',
    'Argentina': 'ARG',
    'Germany': 'GER',
    'France': 'FRA',
    'Spain': 'ESP',
    'England': 'ENG',
    'Italy': 'ITA',
    'Uruguay': 'URU',
    'Netherlands': 'NED',
    'Portugal': 'POR',
  };

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);

    try {
      final players = await _playerService.getAllPlayers();
      setState(() {
        _allPlayers = players;
        _displayedPlayers = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading players: $e')),
        );
      }
    }
  }

  Future<void> _applyFilter(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _isLoading = true;
    });

    try {
      List<Player> filteredPlayers;

      if (filter == 'All Teams') {
        filteredPlayers = await _playerService.getAllPlayers();
      } else if (_teamCodes.containsKey(filter)) {
        filteredPlayers = await _playerService.getPlayersByTeam(_teamCodes[filter]!);
      } else if (filter == 'Goalkeepers') {
        filteredPlayers = await _playerService.getPlayersByCategory('Goalkeeper');
      } else if (filter == 'Defenders') {
        filteredPlayers = await _playerService.getPlayersByCategory('Defender');
      } else if (filter == 'Midfielders') {
        filteredPlayers = await _playerService.getPlayersByCategory('Midfielder');
      } else if (filter == 'Forwards') {
        filteredPlayers = await _playerService.getPlayersByCategory('Forward');
      } else if (filter == 'Top Value') {
        filteredPlayers = await _playerService.getTopPlayersByValue(limit: 50);
      } else if (filter == 'Top Scorers') {
        filteredPlayers = await _playerService.getTopScorers(limit: 50);
      } else if (filter == 'Most Capped') {
        filteredPlayers = await _playerService.getMostCappedPlayers(limit: 50);
      } else {
        filteredPlayers = _allPlayers;
      }

      setState(() {
        _displayedPlayers = filteredPlayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering players: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Spotlight'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
            tooltip: 'Refresh',
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
                hintText: 'Search players...',
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
                    label: Text(filter),
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
                  '${_displayedPlayers.length} players',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_selectedFilter != 'All Teams')
                  TextButton(
                    onPressed: () => _applyFilter('All Teams'),
                    child: const Text('Clear filters'),
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
                    ? const Center(child: Text('No players found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _displayedPlayers.length,
                        itemBuilder: (context, index) {
                          final player = _displayedPlayers[index];
                          return _PlayerCard(
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

/// Player Card Widget
class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player photo from Firebase Storage
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: _buildPlayerImage(player),
                ),
              ),
            ),

            // Player info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.commonName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${player.fifaCode} • #${player.jerseyNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          player.position,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.formattedMarketValue,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '${player.age}y',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerImage(Player player) {
    final photoUrl = player.photoUrl;

    // Check if it's a valid network URL
    if (photoUrl.isNotEmpty && (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(player),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(player);
        },
      );
    }

    return _buildPlaceholder(player);
  }

  Widget _buildPlaceholder(Player player) {
    final initials = _getInitials(player.commonName);
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}

/// Player Detail Screen
class PlayerDetailScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.commonName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Player photo from Firebase Storage
                    CircularPlayerPhoto(
                      photoUrl: player.photoUrl,
                      playerName: player.commonName,
                      size: 120,
                      borderColor: Theme.of(context).primaryColor,
                      borderWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      player.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${player.club} • ${player.clubLeague}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _InfoChip(label: '${player.fifaCode} #${player.jerseyNumber}'),
                        _InfoChip(label: player.positionDisplayName),
                        _InfoChip(label: '${player.age} years'),
                        _InfoChip(label: player.formattedMarketValue),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Stats section
            _SectionCard(
              title: 'Career Statistics',
              child: Column(
                children: [
                  _StatRow(label: 'International Caps', value: '${player.caps}'),
                  _StatRow(label: 'International Goals', value: '${player.goals}'),
                  _StatRow(label: 'International Assists', value: '${player.assists}'),
                  _StatRow(label: 'World Cup Appearances', value: '${player.worldCupAppearances}'),
                  _StatRow(label: 'World Cup Goals', value: '${player.worldCupGoals}'),
                  if (player.previousWorldCups.isNotEmpty)
                    _StatRow(
                      label: 'Previous World Cups',
                      value: player.previousWorldCups.join(', '),
                    ),
                ],
              ),
            ),

            // Honors
            if (player.honors.isNotEmpty)
              _SectionCard(
                title: 'Honors',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: player.honors.map((honor) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(honor)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

            // Strengths & Weaknesses
            _SectionCard(
              title: 'Profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Strengths:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: player.strengths.map((s) =>
                      Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green[100],
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Weaknesses:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: player.weaknesses.map((w) =>
                      Chip(
                        label: Text(w, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.red[100],
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),

            // Play style
            _SectionCard(
              title: 'Play Style',
              child: Text(player.playStyle),
            ),

            // Key moment
            _SectionCard(
              title: 'Key Moment',
              child: Text(player.keyMoment),
            ),

            // Legend comparison
            _SectionCard(
              title: 'Comparison to Legend',
              child: Text(player.comparisonToLegend),
            ),

            // World Cup 2026 prediction
            _SectionCard(
              title: 'World Cup 2026 Prediction',
              child: Text(player.worldCup2026Prediction),
            ),

            // Trivia
            if (player.trivia.isNotEmpty)
              _SectionCard(
                title: 'Fun Facts',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: player.trivia.asMap().entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
