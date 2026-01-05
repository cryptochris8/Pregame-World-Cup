import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watch_party_bloc.dart';
import '../../../../features/social/domain/entities/user_profile.dart';
import '../../../../features/social/domain/services/social_service.dart';
import '../../../../injection_container.dart';

/// Screen for inviting friends to a watch party
class InviteFriendsScreen extends StatefulWidget {
  final String watchPartyId;

  const InviteFriendsScreen({
    Key? key,
    required this.watchPartyId,
  }) : super(key: key);

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SocialService _socialService = sl<SocialService>();

  List<UserProfile> _friends = [];
  Set<String> _selectedFriendIds = {};
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _socialService.getUserFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load friends: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is InviteSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite sent!')),
          );
        }
        if (state is WatchPartyError) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invite Friends'),
          actions: [
            if (_selectedFriendIds.isNotEmpty)
              TextButton(
                onPressed: _isSending ? null : _sendInvites,
                child: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send (${_selectedFriendIds.length})',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Optional message field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Add a personal message (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 2,
              ),
            ),

            // Selected count
            if (_selectedFriendIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${_selectedFriendIds.length} friend${_selectedFriendIds.length > 1 ? "s" : ""} selected',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedFriendIds.clear());
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),

            // Friends list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _friends.isEmpty
                          ? _buildEmptyState()
                          : _buildFriendsList(),
            ),
          ],
        ),
        bottomNavigationBar: _selectedFriendIds.isNotEmpty
            ? _buildBottomBar()
            : null,
      ),
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        final isSelected = _selectedFriendIds.contains(friend.userId);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profileImageUrl != null
                ? NetworkImage(friend.profileImageUrl!)
                : null,
            child: friend.profileImageUrl == null
                ? Text(
                    friend.displayName.isNotEmpty
                        ? friend.displayName[0].toUpperCase()
                        : '?',
                  )
                : null,
          ),
          title: Text(friend.displayName),
          subtitle: friend.bio != null && friend.bio!.isNotEmpty
              ? Text(friend.bio!, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedFriendIds.add(friend.userId);
                } else {
                  _selectedFriendIds.remove(friend.userId);
                }
              });
            },
          ),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFriendIds.remove(friend.userId);
              } else {
                _selectedFriendIds.add(friend.userId);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No friends to invite',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Follow some people to invite them to watch parties',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
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
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadFriends();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSending ? null : _sendInvites,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Send ${_selectedFriendIds.length} Invite${_selectedFriendIds.length > 1 ? "s" : ""}',
                ),
        ),
      ),
    );
  }

  Future<void> _sendInvites() async {
    if (_selectedFriendIds.isEmpty) return;

    setState(() => _isSending = true);

    final message = _messageController.text.trim();

    for (final friendId in _selectedFriendIds) {
      context.read<WatchPartyBloc>().add(
            SendInviteEvent(
              watchPartyId: widget.watchPartyId,
              inviteeId: friendId,
              message: message.isNotEmpty ? message : null,
            ),
          );
    }

    // Wait a moment for invites to send
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sent ${_selectedFriendIds.length} invite${_selectedFriendIds.length > 1 ? "s" : ""}!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
