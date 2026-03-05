import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/activity_feed.dart';

class CreateActivityBottomSheet extends StatefulWidget {
  final Function(ActivityFeedItem) onActivityCreated;

  const CreateActivityBottomSheet({
    super.key,
    required this.onActivityCreated,
  });

  @override
  State<CreateActivityBottomSheet> createState() => _CreateActivityBottomSheetState();
}

class _CreateActivityBottomSheetState extends State<CreateActivityBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _gameController = TextEditingController();
  
  ActivityType _selectedType = ActivityType.checkIn;
  String? _selectedVenueId;
  String? _selectedGameId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    _venueController.dispose();
    _gameController.dispose();
    super.dispose();
  }

  void _createActivity() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseAddContent),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ActivityFeedItem? activity;

    switch (_selectedType) {
      case ActivityType.checkIn:
        if (_venueController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseEnterVenueName),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        activity = ActivityFeedItem.createCheckIn(
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonymous',
          userProfileImage: currentUser.photoURL,
          venueName: _venueController.text.trim(),
          venueId: _selectedVenueId ?? 'venue_${DateTime.now().millisecondsSinceEpoch}',
          gameId: _selectedGameId,
          note: content,
        );
        break;

      case ActivityType.gameAttendance:
        if (_gameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseEnterGameTitle),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        activity = ActivityFeedItem.createGameAttendance(
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonymous',
          userProfileImage: currentUser.photoURL,
          gameId: _selectedGameId ?? 'game_${DateTime.now().millisecondsSinceEpoch}',
          gameTitle: _gameController.text.trim(),
          venue: _venueController.text.trim().isEmpty 
              ? 'Stadium' 
              : _venueController.text.trim(),
        );
        break;

      case ActivityType.venueReview:
        if (_venueController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseEnterVenueName),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        activity = ActivityFeedItem.createVenueReview(
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonymous',
          userProfileImage: currentUser.photoURL,
          venueId: _selectedVenueId ?? 'venue_${DateTime.now().millisecondsSinceEpoch}',
          venueName: _venueController.text.trim(),
          rating: 5, // Default rating for now
          review: content,
        );
        break;

      default:
        // Generic post
        activity = ActivityFeedItem(
          activityId: '${currentUser.uid}_post_${DateTime.now().millisecondsSinceEpoch}',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonymous',
          userProfileImage: currentUser.photoURL,
          type: _selectedType,
          content: content,
          createdAt: DateTime.now(),
        );
        break;
    }

    widget.onActivityCreated(activity);
    Navigator.of(context).pop();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).createActivity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).cancelButton),
                ),
                
                const SizedBox(width: 8),
                
                ElevatedButton(
                  onPressed: _createActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context).postButton),
                ),
              ],
            ),
          ),
          
          // Activity type tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF8B4513),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF8B4513),
            onTap: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    _selectedType = ActivityType.checkIn;
                    break;
                  case 1:
                    _selectedType = ActivityType.gameAttendance;
                    break;
                  case 2:
                    _selectedType = ActivityType.venueReview;
                    break;
                  case 3:
                    _selectedType = ActivityType.photoShare;
                    break;
                }
              });
            },
            tabs: [
              Tab(
                icon: const Icon(Icons.location_on),
                text: AppLocalizations.of(context).tabCheckIn,
              ),
              Tab(
                icon: const Icon(Icons.sports_soccer),
                text: AppLocalizations.of(context).tabGame,
              ),
              Tab(
                icon: const Icon(Icons.rate_review),
                text: AppLocalizations.of(context).tabReview,
              ),
              Tab(
                icon: const Icon(Icons.photo_camera),
                text: AppLocalizations.of(context).tabPhoto,
              ),
            ],
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCheckInTab(),
                _buildGameTab(),
                _buildReviewTab(),
                _buildPhotoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).checkInQuestion,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).venueNameLabel,
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: AppLocalizations.of(context).venueNameHint,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context).addNoteOptional,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).checkInNoteHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).gameAttendanceQuestion,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _gameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).gameTitleLabel,
              prefixIcon: const Icon(Icons.sports_soccer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: AppLocalizations.of(context).gameTitleHint,
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).venueOptionalLabel,
              prefixIcon: const Icon(Icons.stadium),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: AppLocalizations.of(context).venueOptionalHint,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context).shareThoughts,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).gameThoughtsHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).reviewQuestion,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).venueNameLabel,
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: AppLocalizations.of(context).reviewVenueNameHint,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context).yourReview,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).reviewHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[400]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).tapToAddPhotos,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).comingSoon,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context).captionLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).captionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }
} 