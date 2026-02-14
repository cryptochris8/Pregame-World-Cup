import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watch_party_bloc.dart';
import '../widgets/widgets.dart';
import '../../domain/entities/watch_party.dart';
import 'create_watch_party_screen.dart';
import 'watch_party_detail_screen.dart';

/// Screen for discovering public watch parties
class WatchPartiesDiscoveryScreen extends StatefulWidget {
  final String? gameId;
  final String? gameName;
  final DateTime? gameDateTime;
  final String? venueId;

  const WatchPartiesDiscoveryScreen({
    super.key,
    this.gameId,
    this.gameName,
    this.gameDateTime,
    this.venueId,
  });

  @override
  State<WatchPartiesDiscoveryScreen> createState() =>
      _WatchPartiesDiscoveryScreenState();
}

class _WatchPartiesDiscoveryScreenState
    extends State<WatchPartiesDiscoveryScreen> {
  String _sortBy = 'date'; // date, attendees
  String _filter = 'all'; // all, upcoming, live

  @override
  void initState() {
    super.initState();
    _loadWatchParties();
  }

  void _loadWatchParties() {
    context.read<WatchPartyBloc>().add(LoadPublicWatchPartiesEvent(
          gameId: widget.gameId,
          venueId: widget.venueId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName != null
            ? 'Watch Parties: ${widget.gameName}'
            : 'Watch Parties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: BlocBuilder<WatchPartyBloc, WatchPartyState>(
        builder: (context, state) {
          if (state is WatchPartyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WatchPartyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWatchParties,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PublicWatchPartiesLoaded) {
            return _buildContent(state.watchParties);
          }

          return const Center(child: Text('Discover watch parties near you'));
        },
      ),
    );
  }

  Widget _buildContent(List<WatchParty> parties) {
    final filteredParties = _filterParties(parties);
    final sortedParties = _sortParties(filteredParties);

    if (sortedParties.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadWatchParties(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedParties.length,
        itemBuilder: (context, index) {
          final party = sortedParties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WatchPartyCard(
              watchParty: party,
              onTap: () => _navigateToDetail(party),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No watch parties found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.gameName != null
                ? 'Be the first to create one for this match!'
                : 'Be the first to create one!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateWatchParty,
            icon: const Icon(Icons.add),
            label: const Text('Create Watch Party'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateWatchParty() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWatchPartyScreen(
          preselectedGameId: widget.gameId,
          preselectedGameName: widget.gameName,
          preselectedGameDateTime: widget.gameDateTime,
        ),
      ),
    );
  }

  List<WatchParty> _filterParties(List<WatchParty> parties) {
    switch (_filter) {
      case 'upcoming':
        return parties.where((p) => p.isUpcoming).toList();
      case 'live':
        return parties.where((p) => p.isLive).toList();
      default:
        return parties.where((p) => !p.hasEnded && !p.isCancelled).toList();
    }
  }

  List<WatchParty> _sortParties(List<WatchParty> parties) {
    switch (_sortBy) {
      case 'attendees':
        return List.from(parties)
          ..sort((a, b) => b.totalAttendees.compareTo(a.totalAttendees));
      default:
        return List.from(parties)
          ..sort((a, b) => a.gameDateTime.compareTo(b.gameDateTime));
    }
  }

  void _navigateToDetail(WatchParty party) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WatchPartyDetailScreen(
          watchPartyId: party.watchPartyId,
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter & Sort',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Filter section
                const Text(
                  'Show',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == 'all',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => _filter = 'all');
                          setState(() => _filter = 'all');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Upcoming'),
                      selected: _filter == 'upcoming',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => _filter = 'upcoming');
                          setState(() => _filter = 'upcoming');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Live Now'),
                      selected: _filter == 'live',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => _filter = 'live');
                          setState(() => _filter = 'live');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sort section
                const Text(
                  'Sort by',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Date'),
                      selected: _sortBy == 'date',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => _sortBy = 'date');
                          setState(() => _sortBy = 'date');
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Most Popular'),
                      selected: _sortBy == 'attendees',
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => _sortBy = 'attendees');
                          setState(() => _sortBy = 'attendees');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
