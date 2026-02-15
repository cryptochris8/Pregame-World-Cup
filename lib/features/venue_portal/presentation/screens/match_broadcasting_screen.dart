import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Screen for venue owners to select which matches they will broadcast
class MatchBroadcastingScreen extends StatefulWidget {
  final String venueId;
  final String venueName;

  const MatchBroadcastingScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<MatchBroadcastingScreen> createState() => _MatchBroadcastingScreenState();
}

class _MatchBroadcastingScreenState extends State<MatchBroadcastingScreen> {
  List<_MatchItem> _upcomingMatches = [];
  Set<String> _selectedMatchIds = {};
  bool _isLoadingMatches = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUpcomingMatches();
    _loadCurrentSelection();
  }

  void _loadCurrentSelection() {
    final state = context.read<VenueEnhancementCubit>().state;
    if (state.broadcastingSchedule != null) {
      setState(() {
        _selectedMatchIds = Set.from(state.broadcastingSchedule!.matchIds);
      });
    }
  }

  Future<void> _loadUpcomingMatches() async {
    setState(() {
      _isLoadingMatches = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('worldcup_matches')
          .where('status', isEqualTo: 'scheduled')
          .where('dateTimeUtc', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('dateTimeUtc')
          .limit(50)
          .get();

      final matches = snapshot.docs.map((doc) {
        final data = doc.data();
        return _MatchItem(
          id: doc.id,
          homeTeamName: data['homeTeamName'] as String? ?? 'TBD',
          awayTeamName: data['awayTeamName'] as String? ?? 'TBD',
          homeTeamCode: data['homeTeamCode'] as String? ?? '',
          awayTeamCode: data['awayTeamCode'] as String? ?? '',
          dateTimeUtc: (data['dateTimeUtc'] as Timestamp).toDate(),
          stage: data['stage'] as String? ?? '',
          group: data['group'] as String?,
          venueName: data['venue']?['name'] as String? ?? '',
        );
      }).toList();

      setState(() {
        _upcomingMatches = matches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMatches = false;
        _errorMessage = 'Failed to load matches: $e';
      });
    }
  }

  Future<void> _saveSelection() async {
    final cubit = context.read<VenueEnhancementCubit>();
    await cubit.updateBroadcastingSchedule(_selectedMatchIds.toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcasting schedule saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueEnhancementCubit, VenueEnhancementState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Match Broadcasting'),
            actions: [
              if (_selectedMatchIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('${_selectedMatchIds.length} selected'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select the matches your venue will be broadcasting. Users will see your venue when searching for places to watch these matches.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              // Quick actions
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedMatchIds = Set.from(_upcomingMatches.map((m) => m.id));
                        });
                      },
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text('Select All'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedMatchIds.clear();
                        });
                      },
                      icon: const Icon(Icons.deselect, size: 18),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ),

              // Match list
              Expanded(
                child: _isLoadingMatches
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(_errorMessage!),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: _loadUpcomingMatches,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _upcomingMatches.isEmpty
                            ? const Center(
                                child: Text('No upcoming matches found'),
                              )
                            : ListView.builder(
                                itemCount: _upcomingMatches.length,
                                itemBuilder: (context, index) {
                                  final match = _upcomingMatches[index];
                                  final isSelected = _selectedMatchIds.contains(match.id);
                                  return _buildMatchTile(match, isSelected);
                                },
                              ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : _saveSelection,
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(state.isSaving ? 'Saving...' : 'Save Selection'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchTile(_MatchItem match, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha:0.5)
          : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedMatchIds.remove(match.id);
            } else {
              _selectedMatchIds.add(match.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMatchIds.add(match.id);
                    } else {
                      _selectedMatchIds.remove(match.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teams
                    Row(
                      children: [
                        _buildTeamFlag(match.homeTeamCode),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            match.homeTeamName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildTeamFlag(match.awayTeamCode),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            match.awayTeamName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Match info
                    Text(
                      '${match.formattedDate} • ${match.stage}${match.group != null ? ' - ${match.group}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamFlag(String teamCode) {
    if (teamCode.isEmpty) {
      return const SizedBox(width: 24, height: 16);
    }

    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/flags/${teamCode.toLowerCase()}.png',
          ),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.black.withValues(alpha:0.1),
          ),
        ),
      ),
    );
  }
}

class _MatchItem {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamCode;
  final String awayTeamCode;
  final DateTime dateTimeUtc;
  final String stage;
  final String? group;
  final String venueName;

  _MatchItem({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.dateTimeUtc,
    required this.stage,
    this.group,
    required this.venueName,
  });

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final local = dateTimeUtc.toLocal();
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');

    return '$weekday, $month ${local.day} at $hour:$minute $amPm';
  }
}
