import 'package:flutter/material.dart';

/// Bottom sheet for selecting media attachment type (camera, gallery, video, location)
class MessageAttachmentSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;
  final VoidCallback onVideoSelected;
  final VoidCallback onLocationSelected;

  const MessageAttachmentSheet({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onVideoSelected,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95), // Deep purple
            Color(0xFF7C3AED), // Vibrant purple
            Color(0xFF3B82F6), // Electric blue
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Share Media',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Options grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                icon: Icons.photo_camera,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  onCameraSelected();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  onGallerySelected();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.videocam,
                label: 'Video',
                onTap: () {
                  Navigator.pop(context);
                  onVideoSelected();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.location_on,
                label: 'Location',
                onTap: () {
                  Navigator.pop(context);
                  onLocationSelected();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha:0.3)),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
