import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../../../worldcup/domain/entities/world_cup_match.dart';
import '../../../worldcup/domain/repositories/world_cup_match_repository.dart';
import '../../../worldcup/presentation/widgets/team_flag.dart';

/// Screen for selecting a World Cup match for a watch party
class GameSelectorScreen extends StatefulWidget {
  const GameSelectorScreen({super.key});

  @override
  State<GameSelectorScreen> createState() => _GameSelectorScreenState();
}

class _GameSelectorScreenState extends State<GameSelectorScreen> {
  final WorldCupMatchRepository _matchRepository = sl<WorldCupMatchRepository>();
  final TextEditingController _searchController = TextEditingController();

  List<WorldCupMatch> _allMatches = [];
  List<WorldCupMatch> _filteredMatches = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'upcoming'; // upcoming, all, group, knockout

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matches = await _matchRepository.getAllMatches();

      // Sort by date
      matches.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return a.dateTime!.compareTo(b.dateTime!);
      });

      setState(() {
        _allMatches = matches;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Failed to load matches: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final now = DateTime.now();
    final searchQuery = _searchController.text.toLowerCase();

    List<WorldCupMatch> filtered = _allMatches;

    // Apply time/stage filter
    switch (_selectedFilter) {
      case 'upcoming':
        filtered = filtered.where((m) {
          if (m.dateTime == null) return false;
          return m.dateTime!.isAfter(now) &&
                 m.status == MatchStatus.scheduled;
        }).toList();
        break;
      case 'group':
        filtered = filtered.where((m) => m.stage == MatchStage.groupStage).toList();
        break;
      case 'knockout':
        filtered = filtered.where((m) => m.stage != MatchStage.groupStage).toList();
        break;
      // 'all' shows everything
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final homeTeam = (m.homeTeamName).toLowerCase();
        final awayTeam = (m.awayTeamName).toLowerCase();
        final homeCode = (m.homeTeamCode ?? '').toLowerCase();
        final awayCode = (m.awayTeamCode ?? '').toLowerCase();
        final venue = (m.venueName ?? '').toLowerCase();

        return homeTeam.contains(searchQuery) ||
               awayTeam.contains(searchQuery) ||
               homeCode.contains(searchQuery) ||
               awayCode.contains(searchQuery) ||
               venue.contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredMatches = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Match'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search teams, venues...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Upcoming', 'upcoming'),
                const SizedBox(width: 8),
                _buildFilterChip('Group Stage', 'group'),
                const SizedBox(width: 8),
                _buildFilterChip('Knockout', 'knockout'),
                const SizedBox(width: 8),
                _buildFilterChip('All Matches', 'all'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Match count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredMatches.length} matches',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _filteredMatches.isEmpty
                        ? _buildEmptyState()
                        : _buildMatchList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _applyFilters();
        }
      },
    );
  }

  Widget _buildMatchList() {
    // Group matches by date
    final groupedMatches = <String, List<WorldCupMatch>>{};
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    for (final match in _filteredMatches) {
      final dateKey = match.dateTime != null
          ? dateFormat.format(match.dateTime!)
          : 'Date TBD';

      groupedMatches.putIfAbsent(dateKey, () => []);
      groupedMatches[dateKey]!.add(match);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedMatches.length,
      itemBuilder: (context, index) {
        final dateKey = groupedMatches.keys.elementAt(index);
        final matches = groupedMatches[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            // Matches for this date
            ...matches.map((match) => _buildMatchCard(match)),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(WorldCupMatch match) {
    final timeFormat = DateFormat('h:mm a');
    final time = match.dateTime != null
        ? timeFormat.format(match.dateTime!)
        : 'TBD';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _selectMatch(match),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Stage and time row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStageColor(match.stage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.group != null
                          ? 'Group ${match.group}'
                          : match.stageDisplayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStageColor(match.stage),
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams row
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Row(
                      children: [
                        TeamFlag(
                          flagUrl: match.homeFlagUrl,
                          teamCode: match.homeTeamCode,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            match.homeTeamName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'vs',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Away team
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            match.awayTeamName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TeamFlag(
                          flagUrl: match.awayFlagUrl,
                          teamCode: match.awayTeamCode,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Venue row
              if (match.venueName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stadium,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${match.venueName}${match.venueCity != null ? ', ${match.venueCity}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMatches,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getStageColor(MatchStage stage) {
    switch (stage) {
      case MatchStage.groupStage:
        return Colors.blue;
      case MatchStage.roundOf32:
        return Colors.teal;
      case MatchStage.roundOf16:
        return Colors.green;
      case MatchStage.quarterFinal:
        return Colors.orange;
      case MatchStage.semiFinal:
        return Colors.purple;
      case MatchStage.thirdPlace:
        return Colors.brown;
      case MatchStage.final_:
        return Colors.amber.shade800;
    }
  }

  void _selectMatch(WorldCupMatch match) {
    final gameName = '${match.homeTeamName} vs ${match.awayTeamName}';

    final result = {
      'gameId': match.matchId,
      'gameName': gameName,
      'gameDateTime': match.dateTime,
    };

    Navigator.pop(context, result);
  }
}
