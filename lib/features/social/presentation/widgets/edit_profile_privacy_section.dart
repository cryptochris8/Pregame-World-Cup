import 'package:flutter/material.dart';

/// Displays the privacy settings section with toggle switches.
class EditProfilePrivacySection extends StatelessWidget {
  final bool isPrivateProfile;
  final bool showOnlineStatus;
  final ValueChanged<bool> onPrivateProfileChanged;
  final ValueChanged<bool> onShowOnlineStatusChanged;

  const EditProfilePrivacySection({
    super.key,
    required this.isPrivateProfile,
    required this.showOnlineStatus,
    required this.onPrivateProfileChanged,
    required this.onShowOnlineStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text(
              'Private Profile',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Only approved followers can see your profile',
              style: TextStyle(color: Colors.white70),
            ),
            value: isPrivateProfile,
            onChanged: onPrivateProfileChanged,
            activeColor: const Color(0xFFFBBF24),
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(color: Colors.white24, height: 24),

          SwitchListTile(
            title: const Text(
              'Show Online Status',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Let others see when you\'re online or last active',
              style: TextStyle(color: Colors.white70),
            ),
            value: showOnlineStatus,
            onChanged: onShowOnlineStatusChanged,
            activeColor: const Color(0xFFFBBF24),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
