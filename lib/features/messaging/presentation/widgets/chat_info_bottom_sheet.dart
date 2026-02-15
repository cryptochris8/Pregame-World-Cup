import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/services/messaging_service.dart';
import '../../domain/services/messaging_chat_settings_service.dart';

/// Bottom sheet that displays chat information including name, description,
/// creation date, and a list of members with admin controls.
class ChatInfoBottomSheet extends StatelessWidget {
  final Chat chat;
  final MessagingService messagingService;
  final VoidCallback onAddMember;

  const ChatInfoBottomSheet({
    super.key,
    required this.chat,
    required this.messagingService,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = chat.isAdmin(currentUserId ?? '');
    final isCreator = chat.createdBy == currentUserId;

    return StatefulBuilder(
      builder: (context, setSheetState) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Chat Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Chat name and description
            if (chat.name != null) ...[
              Text(
                chat.name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (chat.description != null && chat.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    chat.description!,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Created info
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange[300], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Created ${_formatDateTime(chat.createdAt)}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Members header with add button
            Row(
              children: [
                Text(
                  'Members (${chat.participantIds.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isAdmin && chat.type != ChatType.direct)
                  TextButton.icon(
                    icon: const Icon(Icons.person_add,
                        color: Colors.orange, size: 18),
                    label: const Text('Add',
                        style: TextStyle(color: Colors.orange)),
                    onPressed: () {
                      Navigator.pop(context);
                      onAddMember();
                    },
                  ),
              ],
            ),
            const Divider(color: Colors.white24),

            // Members list
            Expanded(
              child: FutureBuilder<List<ChatMemberInfo>>(
                future: messagingService.getChatMembers(chat.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.orange),
                    );
                  }

                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return const Center(
                      child: Text('No members found',
                          style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isMe = member.userId == currentUserId;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[300],
                          backgroundImage: member.imageUrl != null
                              ? NetworkImage(member.imageUrl!)
                              : null,
                          child: member.imageUrl == null
                              ? Text(
                                  member.displayName.isNotEmpty
                                      ? member.displayName[0]
                                          .toUpperCase()
                                      : '?',
                                  style:
                                      TextStyle(color: Colors.brown[800]),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isMe
                                    ? '${member.displayName} (You)'
                                    : member.displayName,
                                style: const TextStyle(
                                    color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (member.isCreator)
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Owner',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10),
                                ),
                              )
                            else if (member.isAdmin)
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        trailing: (!isMe &&
                                chat.type != ChatType.direct)
                            ? _buildMemberActions(
                                context, member, isAdmin, isCreator)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildMemberActions(BuildContext context,
      ChatMemberInfo member, bool isAdmin, bool isCreator) {
    if (!isAdmin) return null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white70),
      color: Colors.brown[800],
      onSelected: (value) async {
        Navigator.pop(context);

        switch (value) {
          case 'promote':
            await _promoteMember(context, member);
            break;
          case 'demote':
            await _demoteMember(context, member);
            break;
          case 'remove':
            await _removeMember(context, member);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!member.isAdmin)
          const PopupMenuItem(
            value: 'promote',
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Make Admin',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        if (member.isAdmin && !member.isCreator && isCreator)
          const PopupMenuItem(
            value: 'demote',
            child: Row(
              children: [
                Icon(Icons.arrow_downward,
                    color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Remove Admin',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        if (!member.isCreator)
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _promoteMember(
      BuildContext context, ChatMemberInfo member) async {
    final success = await messagingService.promoteToAdmin(
      chat.chatId,
      member.userId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} is now an admin'
              : 'Failed to promote member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _demoteMember(
      BuildContext context, ChatMemberInfo member) async {
    final success = await messagingService.demoteFromAdmin(
      chat.chatId,
      member.userId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} is no longer an admin'
              : 'Failed to demote member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _removeMember(
      BuildContext context, ChatMemberInfo member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text('Remove Member',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${member.displayName} from this chat?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await messagingService.removeMemberFromChat(
      chat.chatId,
      member.userId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} has been removed'
              : 'Failed to remove member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
