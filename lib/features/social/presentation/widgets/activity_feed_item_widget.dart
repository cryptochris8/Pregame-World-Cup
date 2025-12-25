import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/activity_feed.dart';

class ActivityFeedItemWidget extends StatefulWidget {
  final ActivityFeedItem activity;
  final Function(String) onLike;
  final Function(String, String) onComment;
  final Function(ActivityFeedItem) onShare;
  final Function(String) onUserPressed;

  const ActivityFeedItemWidget({
    super.key,
    required this.activity,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onUserPressed,
  });

  @override
  State<ActivityFeedItemWidget> createState() => _ActivityFeedItemWidgetState();
}

class _ActivityFeedItemWidgetState extends State<ActivityFeedItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      HapticFeedback.lightImpact();
    }
    
    widget.onLike(widget.activity.activityId);
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      widget.onComment(widget.activity.activityId, comment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          _buildActivityHeader(),
          
          // Activity content
          _buildActivityContent(),
          
          // Interaction buttons
          _buildInteractionButtons(),
          
          // Comments section
          if (_showComments) _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF8B4513),
            backgroundImage: widget.activity.userProfileImage != null
                ? NetworkImage(widget.activity.userProfileImage!)
                : null,
            child: widget.activity.userProfileImage == null
                ? Text(
                    widget.activity.userName.isNotEmpty 
                        ? widget.activity.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.onUserPressed(widget.activity.userId),
                  child: Text(
                    widget.activity.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                Text(
                  widget.activity.timeAgo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Activity type icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getActivityTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityTypeIcon(),
              color: _getActivityTypeColor(),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.activity.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.white,
            ),
          ),
          
          // Related content chips
          if (widget.activity.relatedGameId != null || 
              widget.activity.relatedVenueId != null) ...[
            const SizedBox(height: 12),
            _buildRelatedContentChips(),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRelatedContentChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.activity.relatedGameId != null)
          Chip(
            label: const Text('Game Event'),
            avatar: const Icon(Icons.sports_football, size: 16, color: Colors.white),
            backgroundColor: Colors.green.withOpacity(0.3),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        
        if (widget.activity.relatedVenueId != null)
          Chip(
            label: Text(widget.activity.metadata['venueName'] ?? 'Venue'),
            avatar: const Icon(Icons.location_on, size: 16, color: Colors.white),
            backgroundColor: Colors.blue.withOpacity(0.3),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildInteractionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Like button
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: IconButton(
                  onPressed: _handleLike,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red[300] : Colors.white70,
                  ),
                ),
              );
            },
          ),
          
          Text(
            '${widget.activity.likesCount}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Comment button
          IconButton(
            onPressed: _toggleComments,
            icon: Icon(
              Icons.chat_bubble_outline,
              color: _showComments ? const Color(0xFFFF8C00) : Colors.white70,
            ),
          ),
          
          Text(
            '${widget.activity.commentsCount}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
          
          // Share button
          IconButton(
            onPressed: () => widget.onShare(widget.activity),
            icon: const Icon(
              Icons.share,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF0F172A),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    hintStyle: const TextStyle(color: Colors.white54),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              
              const SizedBox(width: 8),
              
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8C00),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          // Comments list placeholder
          if (widget.activity.commentsCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.center,
              child: Text(
                'View ${widget.activity.commentsCount} comment${widget.activity.commentsCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getActivityTypeIcon() {
    switch (widget.activity.type) {
      case ActivityType.checkIn:
        return Icons.location_on;
      case ActivityType.friendConnection:
        return Icons.people;
      case ActivityType.gameAttendance:
        return Icons.sports_football;
      case ActivityType.venueReview:
        return Icons.rate_review;
      case ActivityType.photoShare:
        return Icons.photo_camera;
      case ActivityType.gameComment:
        return Icons.comment;
      case ActivityType.teamFollow:
        return Icons.star;
      case ActivityType.achievement:
        return Icons.emoji_events;
      case ActivityType.groupJoin:
        return Icons.group_add;
    }
  }

  Color _getActivityTypeColor() {
    switch (widget.activity.type) {
      case ActivityType.checkIn:
        return Colors.blue;
      case ActivityType.friendConnection:
        return Colors.green;
      case ActivityType.gameAttendance:
        return Colors.orange;
      case ActivityType.venueReview:
        return Colors.purple;
      case ActivityType.photoShare:
        return Colors.pink;
      case ActivityType.gameComment:
        return Colors.teal;
      case ActivityType.teamFollow:
        return Colors.amber;
      case ActivityType.achievement:
        return Colors.deepOrange;
      case ActivityType.groupJoin:
        return Colors.indigo;
    }
  }
} 