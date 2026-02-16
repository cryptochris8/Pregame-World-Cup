import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

/// Displays the profile photo section with an avatar and change photo button.
class EditProfilePhotoSection extends StatelessWidget {
  final File? selectedImage;
  final String? profileImageUrl;
  final VoidCallback onSelectImage;

  const EditProfilePhotoSection({
    super.key,
    this.selectedImage,
    this.profileImageUrl,
    required this.onSelectImage,
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
        children: [
          const Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Profile Image
          GestureDetector(
            onTap: onSelectImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: selectedImage != null
                    ? Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : profileImageUrl != null
                        ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Change Photo Button
          TextButton.icon(
            onPressed: onSelectImage,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'Change Photo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.cardGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}
