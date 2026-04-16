import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final SocialService _socialService = sl<SocialService>();

  List<UserProfile> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);

    try {
      final blockedIds = await _socialService.getBlockedUserIds();
      final profiles = <UserProfile>[];

      for (final userId in blockedIds) {
        final profile = await _socialService.getUserProfile(userId);
        if (profile != null) {
          profiles.add(profile);
        }
      }

      if (mounted) {
        setState(() {
          _blockedUsers = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading blocked users: $e', tag: 'BlockedUsersScreen');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _unblockUser(UserProfile user) async {
    final l10n = AppLocalizations.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.unblockUser),
        content: Text(l10n.unblockUserConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.unblock),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _socialService.unblockUser(currentUser.uid, user.userId);
      if (success && mounted) {
        setState(() {
          _blockedUsers.removeWhere((u) => u.userId == user.userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unblockSuccess(user.displayName)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.blockedUsers,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : _blockedUsers.isEmpty
                  ? _buildEmptyState(l10n)
                  : _buildBlockedList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noBlockedUsers,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noBlockedUsersSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedList() {
    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _buildBlockedUserTile(user);
        },
      ),
    );
  }

  Widget _buildBlockedUserTile(UserProfile user) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade700,
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: user.homeLocation != null
            ? Text(
                user.homeLocation!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: TextButton(
          onPressed: () => _unblockUser(user),
          child: Text(
            l10n.unblock,
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ),
    );
  }
}
