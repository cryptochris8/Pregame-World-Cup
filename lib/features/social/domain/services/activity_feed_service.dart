import 'dart:developer' as developer;
import '../../../../core/constants/firestore_collections.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../entities/activity_feed.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../moderation/domain/services/profanity_filter_service.dart';

class ActivityFeedService {
  static const String _activitiesBoxName = 'activity_feed';
  static const String _likesBoxName = 'activity_likes';
  static const String _commentsBoxName = 'activity_comments';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Box<ActivityFeedItem> _activitiesBox;
  late Box<ActivityLike> _likesBox;
  late Box<ActivityComment> _commentsBox;

  // Fix 1: initialization guard — prevents LateInitializationError on failed init
  bool _isInitialized = false;

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
        // Re-create box on error
        await Hive.deleteBoxFromDisk(_activitiesBoxName);
        _activitiesBox = await Hive.openBox<ActivityFeedItem>(_activitiesBoxName);
      }

      try {
        _likesBox = await Hive.openBox<ActivityLike>(_likesBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(_likesBoxName);
        _likesBox = await Hive.openBox<ActivityLike>(_likesBoxName);
      }

      try {
        _commentsBox = await Hive.openBox<ActivityComment>(_commentsBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(_commentsBoxName);
        _commentsBox = await Hive.openBox<ActivityComment>(_commentsBoxName);
      }

      // Fix 1: only mark initialized after all boxes are successfully opened
      _isInitialized = true;
    } catch (e) {
      // Fix 1: log the error instead of silently swallowing it
      developer.log(
        'ActivityFeedService initialization failed: $e',
        name: 'ActivityFeedService',
        error: e,
      );
      // Do not rethrow — allow app to continue with limited functionality,
      // but _isInitialized stays false so callers get safe empty/false returns.
    }
  }

  /// Create a new activity
  Future<bool> createActivity(ActivityFeedItem activity) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      PerformanceMonitor.startApiCall('create_activity');

      // Filter content for profanity (Apple Guideline 1.2 compliance)
      final filterService = ProfanityFilterService();
      final filterResult = filterService.filterContent(activity.content);
      if (filterResult.shouldAutoReject) {
        PerformanceMonitor.endApiCall('create_activity', success: false);
        return false; // Reject objectionable content
      }

      final data = _activityToFirestore(activity);
      await _firestore.collection(FirestoreCollections.activities).doc(activity.activityId).set(data);

      // Cache locally
      await _activitiesBox.put(activity.activityId, activity);

      // Invalidate all feed caches since any user's feed could include this activity
      _feedCache.clear();

      PerformanceMonitor.endApiCall('create_activity', success: true);
      return true;

    } catch (e) {
      PerformanceMonitor.endApiCall('create_activity', success: false);
      // Error handled silently
      return false;
    }
  }

  /// Get activity feed for a user (includes friend activities)
  Future<List<ActivityFeedItem>> getActivityFeed(String userId, {int limit = 20, DateTime? startAfter}) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return [];

    try {
      // Check memory cache first (only if not paginating)
      if (startAfter == null && _feedCache.containsKey(userId)) {
        return _feedCache[userId]!.take(limit).toList();
      }

      PerformanceMonitor.startApiCall('get_activity_feed');

      // Get user's friends to include their activities
      final friendIds = <String>{userId}; // Include own activities

      try {
        final friendsQuery = await _firestore
            .collection(FirestoreCollections.socialConnections)
            .where('fromUserId', isEqualTo: userId)
            .where('status', isEqualTo: 'accepted')
            .where('type', isEqualTo: 'friend')
            .get();

        final friendsQuery2 = await _firestore
            .collection(FirestoreCollections.socialConnections)
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
      } catch (e) {
        // Continue with just the user's own activities
      }

      // Get blocked users in both directions (Apple Guideline 1.2 compliance)
      final blockedIds = <String>{};
      try {
        final blockedByMe = await _firestore
            .collection(FirestoreCollections.socialConnections)
            .where('fromUserId', isEqualTo: userId)
            .where('type', isEqualTo: 'block')
            .get();
        final blockedMe = await _firestore
            .collection(FirestoreCollections.socialConnections)
            .where('toUserId', isEqualTo: userId)
            .where('type', isEqualTo: 'block')
            .get();
        for (final doc in blockedByMe.docs) {
          blockedIds.add(doc.data()['toUserId'] as String);
        }
        for (final doc in blockedMe.docs) {
          blockedIds.add(doc.data()['fromUserId'] as String);
        }
        friendIds.removeAll(blockedIds);
      } catch (e) {
        // Continue without block filtering if query fails
      }

      final activities = <ActivityFeedItem>[];

      try {
        // Get activities from friends and self
        if (friendIds.isNotEmpty) {
          // Firebase whereIn has a limit of 10 items, so batch in chunks
          final friendIdsList = friendIds.toList();
          final chunks = <List<String>>[];
          for (var i = 0; i < friendIdsList.length; i += 10) {
            chunks.add(friendIdsList.sublist(
              i,
              i + 10 > friendIdsList.length ? friendIdsList.length : i + 10,
            ));
          }

          for (final chunk in chunks) {
            var query = _firestore
                .collection(FirestoreCollections.activities)
                .where('userId', whereIn: chunk)
                .where('isPublic', isEqualTo: true)
                .orderBy('createdAt', descending: true);

            // Add pagination cursor if provided
            if (startAfter != null) {
              query = query.startAfter([Timestamp.fromDate(startAfter)]);
            }

            final activitiesQuery = await query.limit(limit * 2).get();

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
                continue;
              }
            }
          }
        }
      } catch (e) {
        // Try to load from cache instead
        if (_activitiesBox.isOpen) {
          final cachedActivities = _activitiesBox.values.toList();
          activities.addAll(cachedActivities);
        }
      }

      // Remove any activities from blocked users (Apple Guideline 1.2 compliance)
      activities.removeWhere((a) => blockedIds.contains(a.userId));

      // Sort by creation time and limit
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final sortedActivities = activities.take(limit).toList();

      // Populate isLikedByCurrentUser for each activity in parallel
      final likedStatuses = await Future.wait(
        sortedActivities.map((a) => hasUserLikedActivity(a.activityId, userId))
      );
      final limitedActivities = List.generate(sortedActivities.length, (i) =>
        sortedActivities[i].copyWith(isLikedByCurrentUser: likedStatuses[i])
      );

      // Fix 5: evict oldest entry when feed cache exceeds 10 entries
      if (startAfter == null) {
        if (_feedCache.length >= 10) {
          _feedCache.remove(_feedCache.keys.first);
        }
        _feedCache[userId] = limitedActivities;
      }

      PerformanceMonitor.endApiCall('get_activity_feed', success: true);
      return limitedActivities;

    } catch (e) {
      PerformanceMonitor.endApiCall('get_activity_feed', success: false);

      // Return cached data if available
      if (_activitiesBox.isOpen) {
        final cachedActivities = _activitiesBox.values.take(limit).toList();
        // Returning cached activities due to error
        return cachedActivities;
      }

      return [];
    }
  }

  /// Get user's own activities
  Future<List<ActivityFeedItem>> getUserActivities(String userId, {int limit = 20}) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return [];

    try {
      PerformanceMonitor.startApiCall('get_user_activities');

      final query = await _firestore
          .collection(FirestoreCollections.activities)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

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
          continue;
        }
      }

      // Populate isLikedByCurrentUser for each activity in parallel
      final likedStatuses = await Future.wait(
        activities.map((a) => hasUserLikedActivity(a.activityId, userId))
      );
      final activitiesWithLikeState = List.generate(activities.length, (i) =>
        activities[i].copyWith(isLikedByCurrentUser: likedStatuses[i])
      );

      PerformanceMonitor.endApiCall('get_user_activities', success: true);
      return activitiesWithLikeState;

    } catch (e) {
      PerformanceMonitor.endApiCall('get_user_activities', success: false);

      // Try to return cached user activities
      if (_activitiesBox.isOpen) {
        final cachedActivities = _activitiesBox.values
            .where((activity) => activity.userId == userId)
            .take(limit)
            .toList();
        return cachedActivities;
      }

      return [];
    }
  }

  /// Like an activity
  Future<bool> likeActivity(String activityId, String userId, String userName) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      PerformanceMonitor.startApiCall('like_activity');

      final likeId = '${activityId}_$userId';
      final likeRef = _firestore.collection(FirestoreCollections.activityLikes).doc(likeId);
      final activityRef = _firestore.collection(FirestoreCollections.activities).doc(activityId);

      // Fix 2: wrap like write + likesCount increment in a transaction to make it atomic
      // The transaction also prevents duplicate likes via an existence check.
      await _firestore.runTransaction((transaction) async {
        final likeSnapshot = await transaction.get(likeRef);

        // Idempotency guard: do nothing if the like already exists
        if (likeSnapshot.exists) return;

        transaction.set(likeRef, {
          'activityId': activityId,
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });

        transaction.update(activityRef, {
          'likesCount': FieldValue.increment(1),
        });
      });

      // Cache like locally (outside transaction — local cache is best-effort)
      final like = ActivityLike(
        likeId: likeId,
        activityId: activityId,
        userId: userId,
        createdAt: DateTime.now(),
      );
      await _likesBox.put(likeId, like);

      // Invalidate the liker's feed cache (other users' feeds refresh on next load)
      _feedCache.remove(userId);

      PerformanceMonitor.endApiCall('like_activity', success: true);
      return true;

    } catch (e) {
      PerformanceMonitor.endApiCall('like_activity', success: false);
      // Error handled silently
      return false;
    }
  }

  /// Unlike an activity
  Future<bool> unlikeActivity(String activityId, String userId) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      PerformanceMonitor.startApiCall('unlike_activity');

      final likeId = '${activityId}_$userId';
      final likeRef = _firestore.collection(FirestoreCollections.activityLikes).doc(likeId);
      final activityRef = _firestore.collection(FirestoreCollections.activities).doc(activityId);

      // Fix 2: wrap like deletion + likesCount decrement in a transaction
      await _firestore.runTransaction((transaction) async {
        final likeSnapshot = await transaction.get(likeRef);

        // Idempotency guard: do nothing if the like no longer exists
        if (!likeSnapshot.exists) return;

        transaction.delete(likeRef);

        transaction.update(activityRef, {
          'likesCount': FieldValue.increment(-1),
        });
      });

      // Remove from local cache
      await _likesBox.delete(likeId);

      // Invalidate the user's feed cache
      _feedCache.remove(userId);

      PerformanceMonitor.endApiCall('unlike_activity', success: true);
      return true;

    } catch (e) {
      PerformanceMonitor.endApiCall('unlike_activity', success: false);
      // Error handled silently
      return false;
    }
  }

  /// Check if user has liked an activity
  Future<bool> hasUserLikedActivity(String activityId, String userId) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      final likeId = '${activityId}_$userId';

      // Check local cache first
      if (_likesBox.containsKey(likeId)) {
        return true;
      }

      // Check Firestore
      final doc = await _firestore.collection(FirestoreCollections.activityLikes).doc(likeId).get();
      return doc.exists;

    } catch (e) {
      // Error handled silently
      return false;
    }
  }

  /// Add comment to activity
  Future<bool> commentOnActivity(String activityId, String userId, String userName, String comment, {String? userProfileImage}) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      PerformanceMonitor.startApiCall('comment_activity');

      // Filter comment for profanity (Apple Guideline 1.2 compliance)
      final filterService = ProfanityFilterService();
      final filterResult = filterService.filterContent(comment);
      if (filterResult.shouldAutoReject) {
        PerformanceMonitor.endApiCall('comment_activity', success: false);
        return false; // Reject objectionable content
      }

      final activityComment = ActivityComment(
        commentId: '${activityId}_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        activityId: activityId,
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        comment: comment,
        createdAt: DateTime.now(),
      );

      final commentRef = _firestore.collection(FirestoreCollections.activityComments).doc(activityComment.commentId);
      final activityRef = _firestore.collection(FirestoreCollections.activities).doc(activityId);

      // Fix 3: wrap comment write + commentsCount increment in a transaction
      await _firestore.runTransaction((transaction) async {
        transaction.set(commentRef, {
          'activityId': activityId,
          'userId': userId,
          'userName': userName,
          'userProfileImage': userProfileImage,
          'comment': comment,
          'createdAt': Timestamp.fromDate(activityComment.createdAt),
        });

        transaction.update(activityRef, {
          'commentsCount': FieldValue.increment(1),
        });
      });

      // Cache comment locally
      await _commentsBox.put(activityComment.commentId, activityComment);

      // Invalidate the commenter's feed cache and comment cache
      _feedCache.remove(userId);
      _commentsCache.remove(activityId);

      PerformanceMonitor.endApiCall('comment_activity', success: true);
      return true;

    } catch (e) {
      PerformanceMonitor.endApiCall('comment_activity', success: false);
      // Error handled silently
      return false;
    }
  }

  /// Get comments for an activity
  Future<List<ActivityComment>> getActivityComments(String activityId, {int limit = 50}) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return [];

    try {
      // Check memory cache first
      if (_commentsCache.containsKey(activityId)) {
        return _commentsCache[activityId]!;
      }

      PerformanceMonitor.startApiCall('get_activity_comments');

      final query = await _firestore
          .collection(FirestoreCollections.activityComments)
          .where('activityId', isEqualTo: activityId)
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      final comments = <ActivityComment>[];

      for (final doc in query.docs) {
        final data = doc.data();
        final c = ActivityComment(
          commentId: doc.id,
          activityId: data['activityId'],
          userId: data['userId'],
          userName: data['userName'],
          userProfileImage: data['userProfileImage'],
          comment: data['comment'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );

        comments.add(c);
        await _commentsBox.put(c.commentId, c);
      }

      // Fix 5: evict oldest entry when comments cache exceeds 10 entries
      if (_commentsCache.length >= 10) {
        _commentsCache.remove(_commentsCache.keys.first);
      }
      _commentsCache[activityId] = comments;

      PerformanceMonitor.endApiCall('get_activity_comments', success: true);
      return comments;

    } catch (e) {
      PerformanceMonitor.endApiCall('get_activity_comments', success: false);
      // Error handled silently
      return [];
    }
  }

  /// Delete an activity (user can only delete their own activities)
  Future<bool> deleteActivity(String activityId, String userId) async {
    // Fix 1: guard against uninitialized boxes
    if (!_isInitialized) return false;

    try {
      PerformanceMonitor.startApiCall('delete_activity');

      // Verify the activity belongs to the user
      final activityRef = _firestore.collection(FirestoreCollections.activities).doc(activityId);
      final activityDoc = await activityRef.get();

      if (!activityDoc.exists) {
        PerformanceMonitor.endApiCall('delete_activity', success: false);
        return false;
      }

      final activityData = activityDoc.data();
      if (activityData == null || activityData['userId'] != userId) {
        // Activity doesn't belong to this user
        PerformanceMonitor.endApiCall('delete_activity', success: false);
        return false;
      }

      // Fetch all related sub-documents before batching
      final likesQuery = await _firestore
          .collection(FirestoreCollections.activityLikes)
          .where('activityId', isEqualTo: activityId)
          .get();

      final commentsQuery = await _firestore
          .collection(FirestoreCollections.activityComments)
          .where('activityId', isEqualTo: activityId)
          .get();

      // Fix 4: replace serial individual deletes with a WriteBatch.
      // Firestore batches are capped at 500 ops; chunk at 400 to leave headroom.
      const int _batchChunkSize = 400;

      final allDocs = [
        ...likesQuery.docs.map((d) => d.reference),
        ...commentsQuery.docs.map((d) => d.reference),
        activityRef,
      ];

      for (var i = 0; i < allDocs.length; i += _batchChunkSize) {
        final chunk = allDocs.sublist(
          i,
          i + _batchChunkSize > allDocs.length ? allDocs.length : i + _batchChunkSize,
        );
        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.delete(ref);
        }
        await batch.commit();
      }

      // Remove sub-documents from local Hive caches
      for (final likeDoc in likesQuery.docs) {
        await _likesBox.delete(likeDoc.id);
      }
      for (final commentDoc in commentsQuery.docs) {
        await _commentsBox.delete(commentDoc.id);
      }

      // Remove main activity from local Hive cache
      await _activitiesBox.delete(activityId);

      // Invalidate feed cache for the user
      _feedCache.remove(userId);

      // Clear comments cache for this activity
      _commentsCache.remove(activityId);

      PerformanceMonitor.endApiCall('delete_activity', success: true);
      return true;

    } catch (e) {
      PerformanceMonitor.endApiCall('delete_activity', success: false);
      // Error handled silently
      return false;
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
      // Error handled silently
      return null;
    }
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    if (!_isInitialized) {
      return {
        'cached_activities': 0,
        'cached_likes': 0,
        'cached_comments': 0,
        'memory_feeds': _feedCache.length,
        'memory_comments': _commentsCache.length,
      };
    }
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
    if (!_isInitialized) return;
    await _activitiesBox.clear();
    await _likesBox.clear();
    await _commentsBox.clear();
  }
}
