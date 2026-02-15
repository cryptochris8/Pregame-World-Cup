import 'package:flutter/material.dart';

import '../../../watch_party/domain/entities/watch_party.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for watch party management
class AdminWatchPartiesScreen extends StatefulWidget {
  const AdminWatchPartiesScreen({super.key});

  @override
  State<AdminWatchPartiesScreen> createState() => _AdminWatchPartiesScreenState();
}

class _AdminWatchPartiesScreenState extends State<AdminWatchPartiesScreen> {
  final AdminService _adminService = AdminService();

  List<WatchParty> _parties = [];
  bool _isLoading = true;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    setState(() => _isLoading = true);

    final parties = await _adminService.getWatchParties(
      isActive: _showActiveOnly,
    );

    setState(() {
      _parties = parties;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Parties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParties,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Active Only'),
                  selected: _showActiveOnly,
                  onSelected: (value) {
                    setState(() => _showActiveOnly = value);
                    _loadParties();
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${_parties.length} parties',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _parties.isEmpty
                    ? Center(
                        child: Text(
                          'No watch parties found',
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadParties,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _parties.length,
                          itemBuilder: (context, index) {
                            final party = _parties[index];
                            return _buildPartyCard(theme, party);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(ThemeData theme, WatchParty party) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        party.gameName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: party.isPrivate ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    party.visibility.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Host', party.hostName),
            _buildInfoRow('Venue', party.venueName),
            _buildInfoRow('Attendees', '${party.currentAttendeesCount}/${party.maxAttendees}'),
            _buildInfoRow('Game Date', _formatDateTime(party.gameDateTime)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewDetails(party),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(party),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _viewDetails(WatchParty party) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              party.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Party ID', party.watchPartyId),
            _buildDetailRow('Host ID', party.hostId),
            _buildDetailRow('Host Name', party.hostName),
            _buildDetailRow('Game', party.gameName),
            _buildDetailRow('Game ID', party.gameId),
            _buildDetailRow('Venue', party.venueName),
            _buildDetailRow('Address', party.venueAddress ?? 'Not specified'),
            _buildDetailRow('Created', _formatDateTime(party.createdAt)),
            _buildDetailRow('Game Date', _formatDateTime(party.gameDateTime)),
            _buildDetailRow('Attendees', party.currentAttendeesCount.toString()),
            _buildDetailRow('Max Attendees', party.maxAttendees.toString()),
            _buildDetailRow('Visibility', party.visibility.name),
            if (party.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(party.description),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(WatchParty party) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Watch Party'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${party.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter deletion reason...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await _adminService.deleteWatchParty(
                party.watchPartyId,
                reasonController.text,
              );
              if (mounted) {
                if (success) {
                  setState(() {
                    _parties.removeWhere((p) => p.watchPartyId == party.watchPartyId);
                  });
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Watch party deleted' : 'Failed to delete'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
