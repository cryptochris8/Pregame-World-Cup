import 'package:flutter/material.dart';

/// Displays the basic information form fields: display name, bio, location.
class EditProfileBasicInfoSection extends StatelessWidget {
  final TextEditingController displayNameController;
  final TextEditingController bioController;
  final TextEditingController locationController;

  const EditProfileBasicInfoSection({
    super.key,
    required this.displayNameController,
    required this.bioController,
    required this.locationController,
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
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Display Name
          TextFormField(
            controller: displayNameController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              labelText: 'Display Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Display name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Bio
          TextFormField(
            controller: bioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _buildInputDecoration(
              labelText: 'Bio',
              hintText: 'Tell everyone about yourself...',
            ),
          ),

          const SizedBox(height: 16),

          // Location
          TextFormField(
            controller: locationController,
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(
              labelText: 'Location',
              hintText: 'City, State',
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      hintText: hintText,
      hintStyle: hintText != null
          ? TextStyle(color: Colors.white.withValues(alpha: 0.5))
          : null,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}
