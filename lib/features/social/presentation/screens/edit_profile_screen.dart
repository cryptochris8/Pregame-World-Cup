import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/services/social_service.dart';
import '../../../messaging/domain/services/file_upload_service.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/utils/team_logo_helper.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _profileImageUrl;
  File? _selectedImage;
  List<String> _selectedTeams = [];
  bool _isLoading = false;
  bool _isPrivateProfile = false;
  bool _showOnlineStatus = true;
  
  // Available college teams
  final List<String> _availableTeams = [
    'Alabama Crimson Tide',
    'Auburn Tigers',
    'Arkansas Razorbacks',
    'Florida Gators',
    'Georgia Bulldogs',
    'Kentucky Wildcats',
    'LSU Tigers',
    'Mississippi State Bulldogs',
    'Missouri Tigers',
    'Ole Miss Rebels',
    'South Carolina Gamecocks',
    'Tennessee Volunteers',
    'Texas A&M Aggies',
    'Vanderbilt Commodores',
    'Clemson Tigers',
    'Duke Blue Devils',
    'Florida State Seminoles',
    'Georgia Tech Yellow Jackets',
    'Louisville Cardinals',
    'Miami Hurricanes',
    'NC State Wolfpack',
    'North Carolina Tar Heels',
    'Pittsburgh Panthers',
    'Syracuse Orange',
    'Virginia Cavaliers',
    'Virginia Tech Hokies',
    'Wake Forest Demon Deacons',
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
              backgroundColor: Colors.white.withOpacity(0.2),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            _buildProfilePhotoSection(),
            const SizedBox(height: 24),
            
            // Basic Information
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            
            // Favorite Teams
            _buildFavoriteTeamsSection(),
            const SizedBox(height: 24),
            
            // Privacy Settings
            _buildPrivacySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            onTap: _selectProfileImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : _profileImageUrl != null
                        ? Image.network(
                            _profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Change Photo Button
          TextButton.icon(
            onPressed: _selectProfileImage,
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
      decoration: BoxDecoration(
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

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            controller: _displayNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Display Name',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
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
            controller: _bioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Tell everyone about yourself...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location
          TextFormField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Location',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'City, State',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteTeamsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favorite Teams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _showTeamSelector,
                child: const Text(
                  'Add Team',
                  style: TextStyle(color: Color(0xFFFBBF24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Selected Teams
          if (_selectedTeams.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sports_football, color: Colors.white54),
                  SizedBox(width: 12),
                  Text(
                    'No favorite teams selected',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTeams.map((team) => _buildTeamChip(team)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamChip(String team) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TeamLogoHelper.getTeamLogoWidget(
            teamName: team,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            team,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTeams.remove(team);
              });
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            value: _isPrivateProfile,
            onChanged: (value) {
              setState(() {
                _isPrivateProfile = value;
              });
            },
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
            value: _showOnlineStatus,
            onChanged: (value) {
              setState(() {
                _showOnlineStatus = value;
              });
            },
            activeColor: const Color(0xFFFBBF24),
            contentPadding: EdgeInsets.zero,
          ),
        ],
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4C1D95),
              Color(0xFF7C3AED),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Favorite Teams',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Team List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _availableTeams.length,
                itemBuilder: (context, index) {
                  final team = _availableTeams[index];
                  final isSelected = _selectedTeams.contains(team);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFFFBBF24)
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      leading: TeamLogoHelper.getTeamLogoWidget(
                        teamName: team,
                        size: 32,
                      ),
                      title: Text(
                        team,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFFFBBF24))
                          : const Icon(Icons.add_circle_outline, color: Colors.white54),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTeams.remove(team);
                          } else {
                            if (_selectedTeams.length < 5) {
                              _selectedTeams.add(team);
                            } else {
                              _showErrorSnackBar('You can select up to 5 favorite teams');
                            }
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        homeLocation: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
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