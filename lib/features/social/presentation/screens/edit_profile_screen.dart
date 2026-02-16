import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../messaging/domain/services/file_upload_service.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../widgets/edit_profile_photo_section.dart';
import '../widgets/edit_profile_basic_info_section.dart';
import '../widgets/edit_profile_favorite_teams_section.dart';
import '../widgets/edit_profile_privacy_section.dart';
import '../widgets/team_selector_bottom_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  final SocialService _socialService = SocialService();
  final FileUploadService _fileUploadService = FileUploadService();

  String? _profileImageUrl;
  File? _selectedImage;
  List<String> _selectedTeams = [];
  bool _isLoading = false;
  bool _isPrivateProfile = false;
  bool _showOnlineStatus = true;

  // FIFA World Cup 2026 qualified national teams (48 teams, alphabetical)
  final List<String> _availableTeams = [
    'Argentina', 'Australia', 'Austria', 'Belgium', 'Bolivia', 'Brazil',
    'Cameroon', 'Canada', 'Chile', 'Colombia', 'Costa Rica', 'Croatia',
    'Czech Republic', 'Denmark', 'DR Congo', 'Ecuador', 'Egypt', 'England',
    'France', 'Germany', 'Ghana', 'Hungary', 'Iran', 'Israel', 'Italy',
    'Ivory Coast', 'Japan', 'Kenya', 'Mexico', 'Morocco', 'Netherlands',
    'New Zealand', 'Nigeria', 'Norway', 'Panama', 'Paraguay', 'Peru',
    'Poland', 'Portugal', 'Saudi Arabia', 'Scotland', 'Senegal', 'Serbia',
    'South Korea', 'Spain', 'Switzerland', 'Turkey', 'USA', 'Uruguay',
    'Venezuela', 'Wales',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _displayNameController.text = widget.profile.displayName;
    _bioController.text = widget.profile.bio ?? '';
    _locationController.text = widget.profile.homeLocation ?? '';
    _profileImageUrl = widget.profile.profileImageUrl;
    _selectedTeams = List.from(widget.profile.favoriteTeams);
    _isPrivateProfile = !widget.profile.privacySettings.profileVisible;
    _showOnlineStatus = widget.profile.privacySettings.showOnlineStatus;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildGradientAppBar(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 12),
          TeamLogoHelper.getPregameLogo(height: 28),
          const SizedBox(width: 12),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            EditProfilePhotoSection(
              selectedImage: _selectedImage,
              profileImageUrl: _profileImageUrl,
              onSelectImage: _selectProfileImage,
            ),
            const SizedBox(height: 24),

            // Basic Information
            EditProfileBasicInfoSection(
              displayNameController: _displayNameController,
              bioController: _bioController,
              locationController: _locationController,
            ),
            const SizedBox(height: 24),

            // Favorite Teams
            EditProfileFavoriteTeamsSection(
              selectedTeams: _selectedTeams,
              onRemoveTeam: (team) {
                setState(() {
                  _selectedTeams.remove(team);
                });
              },
              onAddTeam: _showTeamSelector,
            ),
            const SizedBox(height: 24),

            // Privacy Settings
            EditProfilePrivacySection(
              isPrivateProfile: _isPrivateProfile,
              showOnlineStatus: _showOnlineStatus,
              onPrivateProfileChanged: (value) {
                setState(() {
                  _isPrivateProfile = value;
                });
              },
              onShowOnlineStatusChanged: (value) {
                setState(() {
                  _showOnlineStatus = value;
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    try {
      final attachment = await _fileUploadService.pickAndUploadImage(
        chatId: 'profile_${widget.profile.userId}',
        source: ImageSource.gallery,
      );

      if (attachment != null) {
        setState(() {
          _profileImageUrl = attachment.fileUrl;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: $e');
    }
  }

  void _showTeamSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TeamSelectorBottomSheet(
        availableTeams: _availableTeams,
        selectedTeams: _selectedTeams,
        onTeamToggled: (team) {
          setState(() {
            if (_selectedTeams.contains(team)) {
              _selectedTeams.remove(team);
            } else {
              _selectedTeams.add(team);
            }
          });
        },
        onMaxReached: () {
          _showErrorSnackBar('You can select up to 5 favorite teams');
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated profile with correct field names
      final updatedProfile = widget.profile.copyWith(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        homeLocation: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        profileImageUrl: _profileImageUrl,
        favoriteTeams: _selectedTeams,
        privacySettings: widget.profile.privacySettings.copyWith(
          profileVisible: !_isPrivateProfile,
          showOnlineStatus: _showOnlineStatus,
        ),
      );

      // Save to database using correct method name
      final success = await _socialService.saveUserProfile(updatedProfile);

      if (mounted) {
        if (success) {
          Navigator.pop(context, updatedProfile);
          _showSuccessSnackBar('Profile updated successfully!');
        } else {
          _showErrorSnackBar('Failed to update profile. Please try again.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
