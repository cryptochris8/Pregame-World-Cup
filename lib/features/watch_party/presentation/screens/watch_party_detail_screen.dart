import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/watch_party_bloc.dart';
import '../widgets/widgets.dart';
import '../../domain/entities/watch_party.dart';
import '../../domain/entities/watch_party_member.dart';
import '../../domain/services/watch_party_payment_service.dart';
import 'invite_friends_screen.dart';
import 'edit_watch_party_screen.dart';

/// Screen showing watch party details with chat
class WatchPartyDetailScreen extends StatefulWidget {
  final String watchPartyId;

  const WatchPartyDetailScreen({
    super.key,
    required this.watchPartyId,
  });

  @override
  State<WatchPartyDetailScreen> createState() => _WatchPartyDetailScreenState();
}

class _WatchPartyDetailScreenState extends State<WatchPartyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWatchParty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatScrollController.dispose();
    // Unsubscribe from messages
    context
        .read<WatchPartyBloc>()
        .add(const UnsubscribeFromMessagesEvent());
    super.dispose();
  }

  void _loadWatchParty() {
    context.read<WatchPartyBloc>().add(
          LoadWatchPartyDetailEvent(widget.watchPartyId),
        );
    // Subscribe to messages
    context.read<WatchPartyBloc>().add(
          SubscribeToMessagesEvent(widget.watchPartyId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is WatchPartyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is WatchPartyJoined) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined!')),
          );
          _loadWatchParty();
        }
        if (state is WatchPartyLeft) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (state is WatchPartyLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WatchPartyDetailLoaded) {
          return _buildContent(state);
        }

        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: ElevatedButton(
              onPressed: _loadWatchParty,
              child: const Text('Reload'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(WatchPartyDetailLoaded state) {
    final watchParty = state.watchParty;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(watchParty.name),
        actions: [
          if (state.isHost)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, state),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Party'),
                ),
                const PopupMenuItem(
                  value: 'invite',
                  child: Text('Invite Friends'),
                ),
                if (watchParty.isUpcoming)
                  const PopupMenuItem(
                    value: 'start',
                    child: Text('Start Party'),
                  ),
                if (watchParty.isLive)
                  const PopupMenuItem(
                    value: 'end',
                    child: Text('End Party'),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text(
                    'Cancel Party',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(state, dateFormat, timeFormat),
          _buildChatTab(state),
        ],
      ),
      bottomNavigationBar: !state.isMember
          ? _buildJoinBar(state)
          : null,
    );
  }

  Widget _buildDetailsTab(
    WatchPartyDetailLoaded state,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    final watchParty = state.watchParty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Visibility badges
          Row(
            children: [
              _buildStatusBadge(watchParty.status),
              const SizedBox(width: 8),
              VisibilityBadge(visibility: watchParty.visibility),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if (watchParty.description.isNotEmpty) ...[
            Text(
              watchParty.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Game info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          watchParty.gameName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(dateFormat.format(watchParty.gameDateTime)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(timeFormat.format(watchParty.gameDateTime)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Venue card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          watchParty.venueName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (watchParty.venueAddress != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      watchParty.venueAddress!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openMaps(watchParty),
                    icon: const Icon(Icons.map),
                    label: const Text('View on Map'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Virtual attendance card
          if (watchParty.allowVirtualAttendance)
            VirtualAttendanceInfoCard(
              watchParty: watchParty,
              hasJoined: state.isMember,
              hasPaid: state.currentUserMember?.hasPaid ?? false,
              onJoinPressed: () => _handleVirtualJoin(watchParty),
            ),

          const SizedBox(height: 16),

          // Members section
          Text(
            'Attendees (${state.members.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ...state.goingMembers.map((member) => MemberListItem(
                member: member,
                isCurrentUser: member.userId ==
                    FirebaseAuth.instance.currentUser?.uid,
                canManage: state.canManageMembers,
                onMute: () => _handleToggleMute(member),
                onRemove: () => _handleRemoveMember(member),
                onPromote: () => _handlePromoteMember(member),
                onDemote: () => _handleDemoteMember(member),
              )),
        ],
      ),
    );
  }

  Widget _buildChatTab(WatchPartyDetailLoaded state) {
    final messages = state.messages;
    final canChat = state.canChat;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyChatState()
              : ListView.builder(
                  controller: _chatScrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return WatchPartyChatMessage(
                      message: message,
                      isCurrentUser: message.senderId == userId,
                    );
                  },
                ),
        ),
        WatchPartyChatInput(
          onSend: (content) {
            context.read<WatchPartyBloc>().add(
                  SendMessageEvent(
                    watchPartyId: widget.watchPartyId,
                    content: content,
                  ),
                );
          },
          enabled: canChat,
          disabledMessage: _getChatDisabledMessage(state),
        ),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say hello!',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinBar(WatchPartyDetailLoaded state) {
    final watchParty = state.watchParty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watchParty.attendeesText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (watchParty.hasSpots)
                    Text(
                      '${watchParty.availableSpots} spots left',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (watchParty.hasSpots)
              ElevatedButton(
                onPressed: () => _handleJoin(WatchPartyAttendanceType.inPerson),
                child: const Text('Join In Person'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WatchPartyStatus status) {
    Color color;
    String label;

    switch (status) {
      case WatchPartyStatus.upcoming:
        color = const Color(0xFF1E3A8A);
        label = 'Upcoming';
        break;
      case WatchPartyStatus.live:
        color = const Color(0xFFDC2626);
        label = 'LIVE';
        break;
      case WatchPartyStatus.ended:
        color = Colors.grey;
        label = 'Ended';
        break;
      case WatchPartyStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String? _getChatDisabledMessage(WatchPartyDetailLoaded state) {
    if (!state.isMember) {
      return 'Join the party to chat';
    }
    if (state.currentUserMember?.isMuted == true) {
      return 'You have been muted';
    }
    if (state.currentUserMember?.isVirtual == true &&
        state.currentUserMember?.hasPaid != true) {
      return 'Pay for virtual attendance to chat';
    }
    return null;
  }

  void _handleMenuAction(String action, WatchPartyDetailLoaded state) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditWatchPartyScreen(
              watchParty: state.watchParty,
            ),
          ),
        ).then((_) => _loadWatchParty()); // Reload after editing
        break;
      case 'invite':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InviteFriendsScreen(
              watchPartyId: widget.watchPartyId,
            ),
          ),
        );
        break;
      case 'start':
        context.read<WatchPartyBloc>().add(
              StartWatchPartyEvent(widget.watchPartyId),
            );
        break;
      case 'end':
        context.read<WatchPartyBloc>().add(
              EndWatchPartyEvent(widget.watchPartyId),
            );
        break;
      case 'cancel':
        _showCancelConfirmation();
        break;
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Watch Party?'),
        content: const Text(
          'This action cannot be undone. All attendees will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WatchPartyBloc>().add(
                    CancelWatchPartyEvent(widget.watchPartyId),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Party'),
          ),
        ],
      ),
    );
  }

  void _handleJoin(WatchPartyAttendanceType type) {
    context.read<WatchPartyBloc>().add(
          JoinWatchPartyEvent(
            watchPartyId: widget.watchPartyId,
            attendanceType: type,
          ),
        );
  }

  void _handleVirtualJoin(WatchParty watchParty) {
    context.read<WatchPartyBloc>().add(
          PurchaseVirtualAttendanceEvent(
            watchPartyId: widget.watchPartyId,
            context: context,
          ),
        );
  }

  void _handleToggleMute(WatchPartyMember member) {
    context.read<WatchPartyBloc>().add(
          ToggleMuteMemberEvent(
            watchPartyId: widget.watchPartyId,
            memberId: member.userId,
            mute: !member.isMuted,
          ),
        );
  }

  void _handleRemoveMember(WatchPartyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text('Remove ${member.displayName} from the watch party?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WatchPartyBloc>().add(
                    RemoveMemberEvent(
                      watchPartyId: widget.watchPartyId,
                      memberId: member.userId,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _handlePromoteMember(WatchPartyMember member) {
    context.read<WatchPartyBloc>().add(
          PromoteMemberEvent(
            watchPartyId: widget.watchPartyId,
            memberId: member.userId,
          ),
        );
  }

  void _handleDemoteMember(WatchPartyMember member) {
    context.read<WatchPartyBloc>().add(
          DemoteMemberEvent(
            watchPartyId: widget.watchPartyId,
            memberId: member.userId,
          ),
        );
  }

  Future<void> _openMaps(WatchParty watchParty) async {
    Uri? mapsUri;

    // Prefer coordinates if available
    if (watchParty.venueLatitude != null && watchParty.venueLongitude != null) {
      // Use coordinates for more accurate location
      final lat = watchParty.venueLatitude!;
      final lng = watchParty.venueLongitude!;
      final label = Uri.encodeComponent(watchParty.venueName);

      // Try Google Maps first (works on both platforms)
      mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label',
      );
    } else if (watchParty.venueAddress != null && watchParty.venueAddress!.isNotEmpty) {
      // Fall back to address search
      final address = Uri.encodeComponent(
        '${watchParty.venueName}, ${watchParty.venueAddress}',
      );
      mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    } else {
      // Just search by venue name
      final venueName = Uri.encodeComponent(watchParty.venueName);
      mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$venueName');
    }

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
