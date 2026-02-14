import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watch_party_bloc.dart';
import '../widgets/widgets.dart';
import '../../domain/entities/watch_party.dart';
import 'watch_party_detail_screen.dart';
import 'create_watch_party_screen.dart';

/// Screen showing user's watch parties (hosted + attending)
class MyWatchPartiesScreen extends StatefulWidget {
  const MyWatchPartiesScreen({super.key});

  @override
  State<MyWatchPartiesScreen> createState() => _MyWatchPartiesScreenState();
}

class _MyWatchPartiesScreenState extends State<MyWatchPartiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWatchParties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWatchParties() {
    context.read<WatchPartyBloc>().add(const LoadUserWatchPartiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watch Parties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hosting'),
            Tab(text: 'Attending'),
            Tab(text: 'Past'),
          ],
        ),
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

          if (state is UserWatchPartiesLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildPartyList(state.hostedParties, 'hosting'),
                _buildPartyList(state.attendingParties, 'attending'),
                _buildPartyList(state.pastParties, 'past'),
              ],
            );
          }

          return const Center(child: Text('Loading your watch parties...'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWatchPartyScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildPartyList(List<WatchParty> parties, String type) {
    if (parties.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadWatchParties(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parties.length,
        itemBuilder: (context, index) {
          final party = parties[index];
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

  Widget _buildEmptyState(String type) {
    IconData icon;
    String title;
    String subtitle;
    bool showCreateButton;

    switch (type) {
      case 'hosting':
        icon = Icons.celebration;
        title = 'No watch parties hosted';
        subtitle = 'Create your first watch party and invite friends!';
        showCreateButton = true;
        break;
      case 'attending':
        icon = Icons.group;
        title = 'No watch parties to attend';
        subtitle = 'Discover public watch parties or accept invitations';
        showCreateButton = false;
        break;
      case 'past':
        icon = Icons.history;
        title = 'No past watch parties';
        subtitle = 'Your completed watch parties will appear here';
        showCreateButton = false;
        break;
      default:
        icon = Icons.celebration;
        title = 'No watch parties';
        subtitle = '';
        showCreateButton = false;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (showCreateButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWatchPartyScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Watch Party'),
              ),
            ],
          ],
        ),
      ),
    );
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
}
