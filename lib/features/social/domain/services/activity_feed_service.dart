import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../entities/activity_feed.dart';
import '../../../../core/services/performance_monitor.dart';

class ActivityFeedService {
  static const String _logTag = 'ActivityFeedService';
  static const String _activitiesBoxName = 'activity_feed';
  static const String _likesBoxName = 'activity_likes';
  static const String _commentsBoxName = 'activity_comments';
  static const Duration _activityCacheDuration = Duration(hours: 2);
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Box<ActivityFeedItem> _activitiesBox;
  late Box<ActivityLike> _likesBox;
  late Box<ActivityComment> _commentsBox;
  
  // In-memory cache
  final Map<String, List<ActivityFeedItem>> _feedCache = {};
  final Map<String, List<ActivityComment>> _commentsCache = {};

  /// Initialize the activity feed service
  Future<void> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(ActivityFeedItemAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(ActivityTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(ActivityCommentAdapter());
      }
      if (!Hive.isAdapterRegistered(15)) {
        Hive.registerAdapter(ActivityLikeAdapter());
      }
      
      // Open boxes with error handling
      try {
        _activitiesBox = await Hive.openBox<ActivityFeedItem>(_activitiesBoxName);
      } catch (e) {
        print('Warning: Could not open activities box, creating new one: $e');
        await Hive.deleteBoxFromDisk(_activitiesBoxName);
        _activitiesBox = await Hive.openBox<ActivityFeedItem>(_activitiesBoxName);
      }
      
      try {
        _likesBox = await Hive.openBox<ActivityLike>(_likesBoxName);
      } catch (e) {
        print('Warning: Could not open likes box, creating new one: $e');
        await Hive.deleteBoxFromDisk(_likesBoxName);
        _likesBox = await Hive.openBox<ActivityLike>(_likesBoxName);
      }
      
      try {
        _commentsBox = await Hive.openBox<ActivityComment>(_commentsBoxName);
      } catch (e) {
        print('Warning: Could not open comments box, creating new one: $e');
        await Hive.deleteBoxFromDisk(_commentsBoxName);
        _commentsBox = await Hive.openBox<ActivityComment>(_commentsBoxName);
      }
      
      print('ActivityFeedService initialized successfully');
    } catch (e) {
      print('Error initializing ActivityFeedService: $e');
      // Don't rethrow - allow app to continue with limited functionality
    }
  }

  /// Create a new activity
  Future<bool> createActivity(ActivityFeedItem activity) async {
    try {
      PerformanceMonitor.startApiCall('create_activity');
      
      final data = _activityToFirestore(activity);
      await _firestore.collection('activities').doc(activity.activityId).set(data);
      
      // Cache locally
      await _activitiesBox.put(activity.activityId, activity);
      
      // Clear feed cache to force refresh
      _feedCache.clear();
      
      PerformanceMonitor.endApiCall('create_activity', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('create_activity', success: false);
      print('Error creating activity: $e');
      return false;
    }
  }

  /// Get activity feed for a user (includes friend activities)
  Future<List<ActivityFeedItem>> getActivityFeed(String userId, {int limit = 20}) async {
    try {
      // Check memory cache first
      if (_feedCache.containsKey(userId)) {
        print('Returning cached feed for user: $userId');
        return _feedCache[userId]!.take(limit).toList();
      }
      
      PerformanceMonitor.startApiCall('get_activity_feed');
      print('Loading activity feed for user: $userId');
      
      // Get user's friends to include their activities
      final friendIds = <String>{userId}; // Include own activities
      
      try {
        final friendsQuery = await _firestore
            .collection('social_connections')
            .where('fromUserId', isEqualTo: userId)
            .where('status', isEqualTo: 'accepted')
            .where('type', isEqualTo: 'friend')
            .get();
        
        final friendsQuery2 = await _firestore
            .collection('social_connections')
            .where('toUserId', isEqualTo: userId)
            .where('status', isEqualTo: 'accepted')
            .where('type', isEqualTo: 'friend')
            .get();
        
        for (final doc in [...friendsQuery.docs, ...friendsQuery2.docs]) {
          final data = doc.data();
          final fromUserId = data['fromUserId'];
          final toUserId = data['toUserId'];
          friendIds.add(fromUserId == userId ? toUserId : fromUserId);
        }
        
        print('Found ${friendIds.length} friends/self for feed');
      } catch (e) {
        print('Error getting friends list: $e');
        // Continue with just the user's own activities
      }
      
      final activities = <ActivityFeedItem>[];
      
      try {
        // Get activities from friends and self
        if (friendIds.isNotEmpty) {
          // Firebase whereIn has a limit of 10 items
          final friendIdsList = friendIds.take(10).toList();
          
          final activitiesQuery = await _firestore
              .collection('activities')
              .where('userId', whereIn: friendIdsList)
              .where('isPublic', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .limit(limit * 2) // Get more to account for filtering
              .get();
          
          print('Found ${activitiesQuery.docs.length} activities from Firebase');
          
          for (final doc in activitiesQuery.docs) {
            try {
              final activity = _activityFromFirestore(doc.data(), doc.id);
              if (activity != null) {
                activities.add(activity);
                // Cache individual activity
                if (_activitiesBox.isOpen) {
                  await _activitiesBox.put(activity.activityId, activity);
                }
              }
            } catch (e) {
              print('Error parsing activity ${doc.id}: $e');
              continue;
            }
          }
        }
      } catch (e) {
        print('Error querying activities: $e');
        // Try to load from cache instead
        if (_activitiesBox.isOpen) {
          final cachedActivities = _activitiesBox.values.toList();
          activities.addAll(cachedActivities);
          print('Loaded ${cachedActivities.length} activities from cache');
        }
      }
      
      // Sort by creation time and limit
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limitedActivities = activities.take(limit).toList();
      
      // Cache the feed
      _feedCache[userId] = limitedActivities;
      
      print('Returning ${limitedActivities.length} activities for feed');
      PerformanceMonitor.endApiCall('get_activity_feed', success: true);
      return limitedActivities;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('get_activity_feed', success: false);
      print('Error getting activity feed: $e');
      
      // Return cached data if available
      if (_activitiesBox.isOpen) {
        final cachedActivities = _activitiesBox.values.take(limit).toList();
        print('Returning ${cachedActivities.length} cached activities due to error');
        return cachedActivities;
      }
      
      return [];
    }
  }

  /// Get user's own activities
  Future<List<ActivityFeedItem>> getUserActivities(String userId, {int limit = 20}) async {
    try {
      PerformanceMonitor.startApiCall('get_user_activities');
      print('Loading user activities for: $userId');
      
      final query = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      print('Found ${query.docs.length} user activities from Firebase');
      
      final activities = <ActivityFeedItem>[];
      
      for (final doc in query.docs) {
        try {
          final activity = _activityFromFirestore(doc.data(), doc.id);
          if (activity != null) {
            activities.add(activity);
            if (_activitiesBox.isOpen) {
              await _activitiesBox.put(activity.activityId, activity);
            }
          }
        } catch (e) {
          print('Error parsing user activity ${doc.id}: $e');
          continue;
        }
      }
      
      print('Returning ${activities.length} user activities');
      PerformanceMonitor.endApiCall('get_user_activities', success: true);
      return activities;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('get_user_activities', success: false);
      print('Error getting user activities: $e');
      
      // Try to return cached user activities
      if (_activitiesBox.isOpen) {
        final cachedActivities = _activitiesBox.values
            .where((activity) => activity.userId == userId)
            .take(limit)
            .toList();
        print('Returning ${cachedActivities.length} cached user activities due to error');
        return cachedActivities;
      }
      
      return [];
    }
  }

  /// Like an activity
  Future<bool> likeActivity(String activityId, String userId, String userName) async {
    try {
      PerformanceMonitor.startApiCall('like_activity');
      
      final likeId = '${activityId}_$userId';
      final like = ActivityLike(
        likeId: likeId,
        activityId: activityId,
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      // Add like to Firestore
      await _firestore.collection('activity_likes').doc(likeId).set({
        'activityId': activityId,
        'userId': userId,
        'createdAt': Timestamp.fromDate(like.createdAt),
      });
      
      // Update activity likes count
      await _firestore.collection('activities').doc(activityId).update({
        'likesCount': FieldValue.increment(1),
      });
      
      // Cache like locally
      await _likesBox.put(likeId, like);
      
      // Clear relevant caches
      _feedCache.clear();
      
      PerformanceMonitor.endApiCall('like_activity', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('like_activity', success: false);
      print('Error liking activity: $e');
      return false;
    }
  }

  /// Unlike an activity
  Future<bool> unlikeActivity(String activityId, String userId) async {
    try {
      PerformanceMonitor.startApiCall('unlike_activity');
      
      final likeId = '${activityId}_$userId';
      
      // Remove like from Firestore
      await _firestore.collection('activity_likes').doc(likeId).delete();
      
      // Update activity likes count
      await _firestore.collection('activities').doc(activityId).update({
        'likesCount': FieldValue.increment(-1),
      });
      
      // Remove from local cache
      await _likesBox.delete(likeId);
      
      // Clear relevant caches
      _feedCache.clear();
      
      PerformanceMonitor.endApiCall('unlike_activity', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('unlike_activity', success: false);
      print('Error unliking activity: $e');
      return false;
    }
  }

  /// Check if user has liked an activity
  Future<bool> hasUserLikedActivity(String activityId, String userId) async {
    try {
      final likeId = '${activityId}_$userId';
      
      // Check local cache first
      if (_likesBox.containsKey(likeId)) {
        return true;
      }
      
      // Check Firestore
      final doc = await _firestore.collection('activity_likes').doc(likeId).get();
      return doc.exists;
      
    } catch (e) {
      print('Error checking activity like: $e');
      return false;
    }
  }

  /// Add comment to activity
  Future<bool> commentOnActivity(String activityId, String userId, String userName, String comment, {String? userProfileImage}) async {
    try {
      PerformanceMonitor.startApiCall('comment_activity');
      
      final activityComment = ActivityComment(
        commentId: '${activityId}_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        activityId: activityId,
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        comment: comment,
        createdAt: DateTime.now(),
      );
      
      // Add comment to Firestore
      await _firestore.collection('activity_comments').doc(activityComment.commentId).set({
        'activityId': activityId,
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'comment': comment,
        'createdAt': Timestamp.fromDate(activityComment.createdAt),
      });
      
      // Update activity comments count
      await _firestore.collection('activities').doc(activityId).update({
        'commentsCount': FieldValue.increment(1),
      });
      
      // Cache comment locally
      await _commentsBox.put(activityComment.commentId, activityComment);
      
      // Clear relevant caches
      _feedCache.clear();
      _commentsCache.remove(activityId);
      
      PerformanceMonitor.endApiCall('comment_activity', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('comment_activity', success: false);
      print('Error commenting on activity: $e');
      return false;
    }
  }

  /// Get comments for an activity
  Future<List<ActivityComment>> getActivityComments(String activityId, {int limit = 50}) async {
    try {
      // Check memory cache first
      if (_commentsCache.containsKey(activityId)) {
        return _commentsCache[activityId]!;
      }
      
      PerformanceMonitor.startApiCall('get_activity_comments');
      
      final query = await _firestore
          .collection('activity_comments')
          .where('activityId', isEqualTo: activityId)
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();
      
      final comments = <ActivityComment>[];
      
      for (final doc in query.docs) {
        final data = doc.data();
        final comment = ActivityComment(
          commentId: doc.id,
          activityId: data['activityId'],
          userId: data['userId'],
          userName: data['userName'],
          userProfileImage: data['userProfileImage'],
          comment: data['comment'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
        
        comments.add(comment);
        await _commentsBox.put(comment.commentId, comment);
      }
      
      // Cache comments
      _commentsCache[activityId] = comments;
      
      PerformanceMonitor.endApiCall('get_activity_comments', success: true);
      return comments;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('get_activity_comments', success: false);
      print('Error getting activity comments: $e');
      return [];
    }
  }

  /// Helper methods
  Map<String, dynamic> _activityToFirestore(ActivityFeedItem activity) {
    return {
      'userId': activity.userId,
      'userName': activity.userName,
      'userProfileImage': activity.userProfileImage,
      'type': activity.type.name,
      'content': activity.content,
      'createdAt': Timestamp.fromDate(activity.createdAt),
      'metadata': activity.metadata,
      'mentionedUsers': activity.mentionedUsers,
      'tags': activity.tags,
      'relatedGameId': activity.relatedGameId,
      'relatedVenueId': activity.relatedVenueId,
      'likesCount': activity.likesCount,
      'commentsCount': activity.commentsCount,
      'isPublic': activity.isPublic,
    };
  }

  ActivityFeedItem? _activityFromFirestore(Map<String, dynamic> data, String id) {
    try {
      return ActivityFeedItem(
        activityId: id,
        userId: data['userId'],
        userName: data['userName'],
        userProfileImage: data['userProfileImage'],
        type: ActivityType.values.firstWhere((e) => e.name == data['type']),
        content: data['content'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        mentionedUsers: List<String>.from(data['mentionedUsers'] ?? []),
        tags: List<String>.from(data['tags'] ?? []),
        relatedGameId: data['relatedGameId'],
        relatedVenueId: data['relatedVenueId'],
        likesCount: data['likesCount'] ?? 0,
        commentsCount: data['commentsCount'] ?? 0,
        isPublic: data['isPublic'] ?? true,
      );
    } catch (e) {
      print('Error parsing activity from Firestore: $e');
      return null;
    }
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'cached_activities': _activitiesBox.length,
      'cached_likes': _likesBox.length,
      'cached_comments': _commentsBox.length,
      'memory_feeds': _feedCache.length,
      'memory_comments': _commentsCache.length,
    };
  }

  /// Clear caches
  Future<void> clearCaches() async {
    _feedCache.clear();
    _commentsCache.clear();
    await _activitiesBox.clear();
    await _likesBox.clear();
    await _commentsBox.clear();
  }
} 