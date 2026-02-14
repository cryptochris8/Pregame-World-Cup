import 'package:flutter/material.dart';
import '../../domain/models/manager.dart';
import '../../data/services/manager_service.dart';
import '../widgets/manager_card.dart';
import 'manager_detail_screen.dart';

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
                          return ManagerCard(
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
