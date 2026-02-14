import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/app_theme.dart';
import '../../../../data/services/player_service.dart';
import '../../../../domain/models/player.dart';
import '../../../../presentation/screens/player_spotlight_screen.dart';

/// Screen displaying tournament leaderboards
/// Shows top scorers, assists, most capped players, etc.
class TournamentLeaderboardsScreen extends StatefulWidget {
  const TournamentLeaderboardsScreen({super.key});

  @override
  State<TournamentLeaderboardsScreen> createState() =>
      _TournamentLeaderboardsScreenState();
}

class _TournamentLeaderboardsScreenState
    extends State<TournamentLeaderboardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PlayerService _playerService = PlayerService();

  // Leaderboard data
  List<Player> _topScorers = [];
  List<Player> _topAssists = [];
  List<Player> _mostCapped = [];
  List<Player> _wcVeterans = [];
  List<Player> _topValue = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all leaderboards in parallel
      final results = await Future.wait([
        _playerService.getWorldCupTopScorers(limit: 25),
        _playerService.getWorldCupTopAssists(limit: 25),
        _playerService.getMostCappedPlayers(limit: 25),
        _playerService.getWorldCupVeterans(limit: 25),
        _playerService.getTopPlayersByValue(limit: 25),
      ]);

      if (mounted) {
        setState(() {
          _topScorers = results[0];
          _topAssists = results[1];
          _mostCapped = results[2];
          _wcVeterans = results[3];
          _topValue = results[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournament Leaderboards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'World Cup 2026 Statistics',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadLeaderboards,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppTheme.accentGold,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.backgroundDark,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'WC Goals'),
          Tab(text: 'WC Assists'),
          Tab(text: 'Most Caps'),
          Tab(text: 'WC Veterans'),
          Tab(text: 'Top Value'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildLeaderboardList(_topScorers, LeaderboardType.wcGoals),
        _buildLeaderboardList(_topAssists, LeaderboardType.wcAssists),
        _buildLeaderboardList(_mostCapped, LeaderboardType.caps),
        _buildLeaderboardList(_wcVeterans, LeaderboardType.wcAppearances),
        _buildLeaderboardList(_topValue, LeaderboardType.marketValue),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Error loading leaderboards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLeaderboards,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<Player> players, LeaderboardType type) {
    if (players.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        return _buildPlayerCard(players[index], index + 1, type);
      },
    );
  }

  Widget _buildEmptyState(LeaderboardType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type.displayName} data available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, int rank, LeaderboardType type) {
    final isTopThree = rank <= 3;
    final rankColor = rank == 1
        ? AppTheme.accentGold
        : rank == 2
            ? Colors.grey.shade300
            : rank == 3
                ? Colors.orange.shade300
                : Colors.white60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isTopThree
            ? AppTheme.backgroundCard.withValues(alpha: 0.9)
            : AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: isTopThree
            ? Border.all(color: rankColor.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerDetailScreen(player: player),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isTopThree
                        ? rankColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isTopThree && rank == 1
                        ? Icon(Icons.emoji_events, color: rankColor, size: 20)
                        : Text(
                            '$rank',
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Player photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: player.photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: player.photoUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.person, color: Colors.white54),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.person, color: Colors.white54),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.person, color: Colors.white54),
                        ),
                ),
                const SizedBox(width: 12),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.commonName.isNotEmpty
                            ? player.commonName
                            : player.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _getFlagEmoji(player.fifaCode),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${player.position} • ${player.club}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stat value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getStatValue(player, type),
                      style: TextStyle(
                        color: isTopThree ? rankColor : AppTheme.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      type.unit,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatValue(Player player, LeaderboardType type) {
    switch (type) {
      case LeaderboardType.wcGoals:
        return '${player.worldCupGoals}';
      case LeaderboardType.wcAssists:
        return '${player.worldCupAssists}';
      case LeaderboardType.caps:
        return '${player.caps}';
      case LeaderboardType.wcAppearances:
        return '${player.worldCupAppearances}';
      case LeaderboardType.marketValue:
        return player.formattedMarketValue;
    }
  }

  String _getFlagEmoji(String fifaCode) {
    // Convert FIFA code to flag emoji
    final Map<String, String> codeMap = {
      'USA': 'US', 'GER': 'DE', 'ENG': 'GB', 'NED': 'NL', 'CRO': 'HR',
      'SUI': 'CH', 'POR': 'PT', 'KOR': 'KR', 'JPN': 'JP', 'IRN': 'IR',
      'SAU': 'SA', 'RSA': 'ZA', 'CRC': 'CR', 'URU': 'UY', 'PAR': 'PY',
      'CHI': 'CL', 'COL': 'CO', 'ECU': 'EC', 'VEN': 'VE', 'ALG': 'DZ',
      'MAR': 'MA', 'TUN': 'TN', 'NGA': 'NG', 'SEN': 'SN', 'GHA': 'GH',
      'CMR': 'CM', 'CIV': 'CI', 'EGY': 'EG',
    };

    final code = codeMap[fifaCode] ?? fifaCode.substring(0, 2);
    if (code.length < 2) return '';

    final firstChar = String.fromCharCode(0x1F1E6 + code.codeUnitAt(0) - 65);
    final secondChar = String.fromCharCode(0x1F1E6 + code.codeUnitAt(1) - 65);
    return '$firstChar$secondChar';
  }
}

/// Types of leaderboards
enum LeaderboardType {
  wcGoals,
  wcAssists,
  caps,
  wcAppearances,
  marketValue,
}

extension LeaderboardTypeExtension on LeaderboardType {
  String get displayName {
    switch (this) {
      case LeaderboardType.wcGoals:
        return 'World Cup Goals';
      case LeaderboardType.wcAssists:
        return 'World Cup Assists';
      case LeaderboardType.caps:
        return 'International Caps';
      case LeaderboardType.wcAppearances:
        return 'World Cup Appearances';
      case LeaderboardType.marketValue:
        return 'Market Value';
    }
  }

  String get unit {
    switch (this) {
      case LeaderboardType.wcGoals:
        return 'goals';
      case LeaderboardType.wcAssists:
        return 'assists';
      case LeaderboardType.caps:
        return 'caps';
      case LeaderboardType.wcAppearances:
        return 'apps';
      case LeaderboardType.marketValue:
        return '';
    }
  }
}
