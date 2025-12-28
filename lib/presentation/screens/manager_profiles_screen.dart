import 'package:flutter/material.dart';
import '../../domain/models/manager.dart';
import '../../data/services/manager_service.dart';
import '../widgets/manager_photo.dart';

/// Manager Profiles Screen
/// Displays all 48 World Cup 2026 managers with filtering and search
class ManagerProfilesScreen extends StatefulWidget {
  const ManagerProfilesScreen({super.key});

  @override
  State<ManagerProfilesScreen> createState() => _ManagerProfilesScreenState();
}

class _ManagerProfilesScreenState extends State<ManagerProfilesScreen> {
  final ManagerService _managerService = ManagerService();
  final ScrollController _scrollController = ScrollController();

  List<Manager> _allManagers = [];
  List<Manager> _displayedManagers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedFilter = 'All Managers';
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  static const int _pageSize = 20;
  int _currentOffset = 0;

  // Filter options
  final List<String> _filterOptions = [
    'All Managers',
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
    'Most Experienced',
    'Youngest',
    'Oldest',
    'Highest Win %',
    'Most Titles',
    'WC Winners',
    'Controversial',
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
    _loadManagers();
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
      _loadMoreManagers();
    }
  }

  Future<void> _loadManagers() async {
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _hasMore = true;
      _displayedManagers = [];
    });

    try {
      final managers = await _managerService.getAllManagers(
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _displayedManagers = managers;
        _currentOffset = managers.length;
        _hasMore = managers.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading managers: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreManagers() async {
    if (_isLoadingMore || !_hasMore || _selectedFilter != 'All Managers') return;

    setState(() => _isLoadingMore = true);

    try {
      final moreManagers = await _managerService.getAllManagers(
        limit: _pageSize,
        offset: _currentOffset,
      );

      setState(() {
        _displayedManagers.addAll(moreManagers);
        _currentOffset += moreManagers.length;
        _hasMore = moreManagers.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more managers: $e')),
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
      List<Manager> filteredManagers;

      if (filter == 'All Managers') {
        // Use pagination for all managers
        filteredManagers = await _managerService.getAllManagers(
          limit: _pageSize,
          offset: 0,
        );
        _currentOffset = filteredManagers.length;
        _hasMore = filteredManagers.length >= _pageSize;
      } else if (_teamCodes.containsKey(filter)) {
        final manager = await _managerService.getManagerByTeam(_teamCodes[filter]!);
        filteredManagers = manager != null ? [manager] : [];
        _hasMore = false;
      } else if (filter == 'Most Experienced') {
        filteredManagers = await _managerService.getMostExperiencedManagers(limit: 20);
        _hasMore = false;
      } else if (filter == 'Youngest') {
        filteredManagers = await _managerService.getYoungestManagers(limit: 20);
        _hasMore = false;
      } else if (filter == 'Oldest') {
        filteredManagers = await _managerService.getOldestManagers(limit: 20);
        _hasMore = false;
      } else if (filter == 'Highest Win %') {
        filteredManagers = await _managerService.getTopWinningManagers(limit: 20);
        _hasMore = false;
      } else if (filter == 'Most Titles') {
        filteredManagers = await _managerService.getMostSuccessfulManagers(limit: 20);
        _hasMore = false;
      } else if (filter == 'WC Winners') {
        filteredManagers = await _managerService.getWorldCupWinningManagers();
        _hasMore = false;
      } else if (filter == 'Controversial') {
        filteredManagers = await _managerService.getControversialManagers();
        _hasMore = false;
      } else {
        filteredManagers = [];
        _hasMore = false;
      }

      setState(() {
        _displayedManagers = filteredManagers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering managers: $e')),
        );
      }
    }
  }

  void _searchManagers(String query) async {
    if (query.isEmpty) {
      _applyFilter(_selectedFilter);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _managerService.searchManagers(query);
      setState(() {
        _displayedManagers = results;
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
        title: const Text('Manager Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadManagers,
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
                hintText: 'Search managers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchManagers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _searchManagers,
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

          // Manager count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_displayedManagers.length} managers',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_selectedFilter != 'All Managers')
                  TextButton(
                    onPressed: () => _applyFilter('All Managers'),
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Managers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedManagers.isEmpty
                    ? const Center(child: Text('No managers found'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _displayedManagers.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at the end
                          if (index >= _displayedManagers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final manager = _displayedManagers[index];
                          return _ManagerCard(
                            manager: manager,
                            onTap: () => _showManagerDetails(manager),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showManagerDetails(Manager manager) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerDetailScreen(manager: manager),
      ),
    );
  }
}

/// Manager Card Widget
class _ManagerCard extends StatelessWidget {
  final Manager manager;
  final VoidCallback onTap;

  const _ManagerCard({
    required this.manager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Manager photo from Firebase Storage
              ManagerPhoto(
                photoUrl: manager.photoUrl,
                managerName: manager.fullName,
                size: 80,
                circular: true,
              ),

              const SizedBox(width: 16),

              // Manager info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.commonName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manager.currentTeam,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.nationality} • ${manager.age} years',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MiniChip(
                          label: '${manager.yearsOfExperience}y exp',
                          icon: Icons.work_outline,
                        ),
                        _MiniChip(
                          label: manager.stats.formattedWinPercentage,
                          icon: Icons.trending_up,
                        ),
                        _MiniChip(
                          label: '${manager.stats.titlesWon} titles',
                          icon: Icons.emoji_events,
                        ),
                        if (manager.isControversial)
                          const _MiniChip(
                            label: 'Controversial',
                            icon: Icons.warning_amber,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _MiniChip({
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}

/// Manager Detail Screen
class ManagerDetailScreen extends StatelessWidget {
  final Manager manager;

  const ManagerDetailScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manager.commonName),
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
                    // Manager photo from Firebase Storage
                    CircularManagerPhoto(
                      photoUrl: manager.photoUrl,
                      managerName: manager.fullName,
                      size: 120,
                      borderColor: Theme.of(context).primaryColor,
                      borderWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      manager.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      manager.currentTeam,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _InfoChip(label: manager.fifaCode),
                        _InfoChip(label: '${manager.age} years old'),
                        _InfoChip(label: manager.nationality),
                        _InfoChip(label: '${manager.yearsOfExperience}y experience'),
                        _InfoChip(label: manager.experienceCategory),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Managerial stats
            _SectionCard(
              title: 'Managerial Record',
              child: Column(
                children: [
                  _StatRow(label: 'Matches Managed', value: '${manager.stats.matchesManaged}'),
                  _StatRow(label: 'Record (W-D-L)', value: manager.stats.recordDisplay),
                  _StatRow(label: 'Win Percentage', value: manager.stats.formattedWinPercentage),
                  _StatRow(label: 'Titles Won', value: '${manager.stats.titlesWon}'),
                  _StatRow(label: 'Career Started', value: '${manager.managerialCareerStart}'),
                  _StatRow(label: 'Years in Current Role', value: '${manager.yearsInCurrentRole}'),
                ],
              ),
            ),

            // Tactical info
            _SectionCard(
              title: 'Tactical Approach',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Formation:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(manager.tacticalStyle, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text('Philosophy:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(manager.philosophy),
                ],
              ),
            ),

            // Honors
            if (manager.honors.isNotEmpty)
              _SectionCard(
                title: 'Honors & Achievements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: manager.honors.map((honor) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
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
              title: 'Profile Analysis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Strengths:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manager.strengths.map((s) =>
                      Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green[100],
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Weaknesses:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manager.weaknesses.map((w) =>
                      Chip(
                        label: Text(w, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.red[100],
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),

            // Manager style
            _SectionCard(
              title: 'Manager Style',
              child: Text(manager.managerStyle),
            ),

            // Key moment
            _SectionCard(
              title: 'Defining Moment',
              child: Text(manager.keyMoment),
            ),

            // Famous quote
            if (manager.famousQuote.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.format_quote, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Famous Quote',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${manager.famousQuote}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // World Cup 2026 prediction
            _SectionCard(
              title: 'World Cup 2026 Outlook',
              child: Text(manager.worldCup2026Prediction),
            ),

            // Previous clubs
            if (manager.previousClubs.isNotEmpty)
              _SectionCard(
                title: 'Previous Clubs',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: manager.previousClubs.map((club) =>
                    Chip(
                      label: Text(club, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.grey[200],
                    ),
                  ).toList(),
                ),
              ),

            // Controversies
            if (manager.controversies.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Controversies',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...manager.controversies.map((controversy) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16)),
                              Expanded(child: Text(controversy)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Trivia
            if (manager.trivia.isNotEmpty)
              _SectionCard(
                title: 'Did You Know?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: manager.trivia.asMap().entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
