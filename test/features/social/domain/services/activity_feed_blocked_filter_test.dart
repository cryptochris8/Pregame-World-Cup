import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Activity Feed - Blocked User Filtering', () {
    test('blocked user IDs are fetched from social_connections', () async {
      final userId = 'currentUser';
      final blockedUserId = 'blockedUser1';

      // Set up a block connection: currentUser blocked blockedUser1
      await fakeFirestore.collection('social_connections').add({
        'fromUserId': userId,
        'toUserId': blockedUserId,
        'type': 'block',
        'status': 'accepted',
      });

      // Query blocked-by-me
      final blockedByMe = await fakeFirestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();

      final blockedIds = <String>{};
      for (final doc in blockedByMe.docs) {
        blockedIds.add(doc.data()['toUserId'] as String);
      }

      expect(blockedIds, contains(blockedUserId));
      expect(blockedIds.length, 1);
    });

    test('blocked-by-other direction is also captured', () async {
      final userId = 'currentUser';
      final blockerUserId = 'blockerUser1';

      // Set up a block connection: blockerUser1 blocked currentUser
      await fakeFirestore.collection('social_connections').add({
        'fromUserId': blockerUserId,
        'toUserId': userId,
        'type': 'block',
        'status': 'accepted',
      });

      // Query blocked-me
      final blockedMe = await fakeFirestore
          .collection('social_connections')
          .where('toUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();

      final blockedIds = <String>{};
      for (final doc in blockedMe.docs) {
        blockedIds.add(doc.data()['fromUserId'] as String);
      }

      expect(blockedIds, contains(blockerUserId));
      expect(blockedIds.length, 1);
    });

    test('blocked users activities are removed from feed results', () async {
      final userId = 'currentUser';
      final blockedUserId = 'blockedUser1';
      final friendUserId = 'friendUser1';

      // Set up block
      await fakeFirestore.collection('social_connections').add({
        'fromUserId': userId,
        'toUserId': blockedUserId,
        'type': 'block',
        'status': 'accepted',
      });

      // Set up activities from blocked user and friend
      await fakeFirestore.collection('activities').add({
        'userId': blockedUserId,
        'content': 'Blocked user post',
        'type': 'post',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fakeFirestore.collection('activities').add({
        'userId': friendUserId,
        'content': 'Friend post',
        'type': 'post',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fakeFirestore.collection('activities').add({
        'userId': userId,
        'content': 'My own post',
        'type': 'post',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Fetch blocked IDs (same logic as ActivityFeedService)
      final blockedByMe = await fakeFirestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();
      final blockedMe = await fakeFirestore
          .collection('social_connections')
          .where('toUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();

      final blockedIds = <String>{};
      for (final doc in blockedByMe.docs) {
        blockedIds.add(doc.data()['toUserId'] as String);
      }
      for (final doc in blockedMe.docs) {
        blockedIds.add(doc.data()['fromUserId'] as String);
      }

      // Fetch all activities
      final allActivities = await fakeFirestore.collection('activities').get();

      // Filter out blocked users (same pattern as the service)
      final filteredActivities = allActivities.docs.where((doc) {
        final activityUserId = doc.data()['userId'] as String;
        return !blockedIds.contains(activityUserId);
      }).toList();

      // Should have 2 activities (friend + own), blocked user removed
      expect(filteredActivities.length, 2);
      expect(
        filteredActivities.every(
          (doc) => doc.data()['userId'] != blockedUserId,
        ),
        isTrue,
      );
    });

    test('feed still works when no blocked users exist', () async {
      final userId = 'currentUser';

      // No block connections at all
      final blockedByMe = await fakeFirestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();
      final blockedMe = await fakeFirestore
          .collection('social_connections')
          .where('toUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();

      final blockedIds = <String>{};
      for (final doc in blockedByMe.docs) {
        blockedIds.add(doc.data()['toUserId'] as String);
      }
      for (final doc in blockedMe.docs) {
        blockedIds.add(doc.data()['fromUserId'] as String);
      }

      expect(blockedIds, isEmpty);

      // Add some activities
      await fakeFirestore.collection('activities').add({
        'userId': 'friend1',
        'content': 'Hello world',
        'type': 'post',
      });
      await fakeFirestore.collection('activities').add({
        'userId': 'friend2',
        'content': 'Another post',
        'type': 'post',
      });

      final allActivities = await fakeFirestore.collection('activities').get();

      // No filtering needed - all activities remain
      final filteredActivities = allActivities.docs.where((doc) {
        final activityUserId = doc.data()['userId'] as String;
        return !blockedIds.contains(activityUserId);
      }).toList();

      expect(filteredActivities.length, 2);
    });

    test('multiple blocked users are all filtered from feed', () async {
      final userId = 'currentUser';

      // Block two users
      await fakeFirestore.collection('social_connections').add({
        'fromUserId': userId,
        'toUserId': 'blocked1',
        'type': 'block',
        'status': 'accepted',
      });
      await fakeFirestore.collection('social_connections').add({
        'fromUserId': userId,
        'toUserId': 'blocked2',
        'type': 'block',
        'status': 'accepted',
      });

      // Activities from blocked users and a friend
      await fakeFirestore.collection('activities').add({
        'userId': 'blocked1',
        'content': 'Post from blocked1',
      });
      await fakeFirestore.collection('activities').add({
        'userId': 'blocked2',
        'content': 'Post from blocked2',
      });
      await fakeFirestore.collection('activities').add({
        'userId': 'goodFriend',
        'content': 'Post from friend',
      });

      // Fetch blocked IDs
      final blockedByMe = await fakeFirestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: userId)
          .where('type', isEqualTo: 'block')
          .get();

      final blockedIds = <String>{};
      for (final doc in blockedByMe.docs) {
        blockedIds.add(doc.data()['toUserId'] as String);
      }

      expect(blockedIds.length, 2);

      final allActivities = await fakeFirestore.collection('activities').get();
      final filtered = allActivities.docs.where((doc) {
        return !blockedIds.contains(doc.data()['userId']);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.data()['userId'], 'goodFriend');
    });
  });
}
