import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWatchParties),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.hosting),
            Tab(text: l10n.attending),
            Tab(text: l10n.past),
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
                    child: Text(l10n.retry),
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

          return Center(child: Text(l10n.loadingYourWatchParties));
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
        label: Text(l10n.create),
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
    final l10n = AppLocalizations.of(context);
    IconData icon;
    String title;
    String subtitle;
    bool showCreateButton;

    switch (type) {
      case 'hosting':
        icon = Icons.celebration;
        title = l10n.noWatchPartiesHosted;
        subtitle = l10n.createFirstWatchParty;
        showCreateButton = true;
        break;
      case 'attending':
        icon = Icons.group;
        title = l10n.noWatchPartiesToAttend;
        subtitle = l10n.discoverOrAcceptInvitations;
        showCreateButton = false;
        break;
      case 'past':
        icon = Icons.history;
        title = l10n.noPastWatchParties;
        subtitle = l10n.completedPartiesAppearHere;
        showCreateButton = false;
        break;
      default:
        icon = Icons.celebration;
        title = l10n.noWatchPartiesFound;
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
                label: Text(l10n.createWatchParty),
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
