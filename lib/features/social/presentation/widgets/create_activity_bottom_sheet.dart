import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        const SnackBar(
          content: Text('Please add some content'),
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
            const SnackBar(
              content: Text('Please enter a venue name'),
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
            const SnackBar(
              content: Text('Please enter a game title'),
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
            const SnackBar(
              content: Text('Please enter a venue name'),
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
                const Text(
                  'Create Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                
                const SizedBox(width: 8),
                
                ElevatedButton(
                  onPressed: _createActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Post'),
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
            tabs: const [
              Tab(
                icon: Icon(Icons.location_on),
                text: 'Check-in',
              ),
              Tab(
                icon: Icon(Icons.sports_soccer),
                text: 'Game',
              ),
              Tab(
                icon: Icon(Icons.rate_review),
                text: 'Review',
              ),
              Tab(
                icon: Icon(Icons.photo_camera),
                text: 'Photo',
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
          const Text(
            'Where are you checking in?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: 'Venue Name',
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'e.g., The Sports Bar',
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Add a note (optional)',
            style: TextStyle(
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
                hintText: 'What\'s happening? How\'s the atmosphere?',
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
          const Text(
            'Which game are you attending?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _gameController,
            decoration: InputDecoration(
              labelText: 'Game Title',
              prefixIcon: const Icon(Icons.sports_soccer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'e.g., Brazil vs Argentina',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: 'Venue (optional)',
              prefixIcon: const Icon(Icons.stadium),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'e.g., Mercedes-Benz Stadium',
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Share your thoughts',
            style: TextStyle(
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
                hintText: 'How excited are you? Any predictions?',
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
          const Text(
            'Which venue are you reviewing?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _venueController,
            decoration: InputDecoration(
              labelText: 'Venue Name',
              prefixIcon: const Icon(Icons.restaurant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'e.g., Murphy\'s Tavern',
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Your review',
            style: TextStyle(
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
                hintText: 'Share your experience... How was the food, service, atmosphere?',
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
                  'Tap to add photos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(Coming Soon)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Caption',
            style: TextStyle(
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
                hintText: 'Write a caption for your photos...',
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