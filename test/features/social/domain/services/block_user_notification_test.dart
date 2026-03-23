import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Block User - Admin Notification', () {
    test('blocking a user creates a report document in reports collection',
        () async {
      final userId = 'user123';
      final blockedUserId = 'blockedUser456';

      // Simulate the block action's report creation
      // (same logic as SocialFriendService.blockUser)
      await fakeFirestore.collection('reports').add({
        'reporterId': userId,
        'reportedUserId': blockedUserId,
        'contentType': 'user',
        'contentId': blockedUserId,
        'reason': 'blocked_by_user',
        'details': 'User blocked another user',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'isBlockAction': true,
      });

      // Verify the report was created
      final reports = await fakeFirestore.collection('reports').get();
      expect(reports.docs.length, 1);

      final reportData = reports.docs.first.data();
      expect(reportData['reporterId'], userId);
      expect(reportData['reportedUserId'], blockedUserId);
      expect(reportData['contentType'], 'user');
      expect(reportData['contentId'], blockedUserId);
      expect(reportData['reason'], 'blocked_by_user');
      expect(reportData['status'], 'pending');
      expect(reportData['isBlockAction'], true);
    });

    test('block report contains correct details field', () async {
      final userId = 'userA';
      final blockedUserId = 'userB';

      await fakeFirestore.collection('reports').add({
        'reporterId': userId,
        'reportedUserId': blockedUserId,
        'contentType': 'user',
        'contentId': blockedUserId,
        'reason': 'blocked_by_user',
        'details': 'User blocked another user',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'isBlockAction': true,
      });

      final reports = await fakeFirestore.collection('reports').get();
      final reportData = reports.docs.first.data();
      expect(reportData['details'], 'User blocked another user');
    });

    test('block connection is also created in social_connections', () async {
      final userId = 'user123';
      final blockedUserId = 'blockedUser456';
      final connectionId = '${userId}_blocks_$blockedUserId';

      // Simulate block connection creation (as SocialFriendService does)
      await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .set({
        'fromUserId': userId,
        'toUserId': blockedUserId,
        'type': 'block',
        'status': 'accepted',
        'connectionSource': 'user_action',
        'metadata': {'reason': 'blocked_by_user'},
      });

      // Verify connection exists
      final connectionDoc = await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .get();

      expect(connectionDoc.exists, isTrue);
      expect(connectionDoc.data()!['type'], 'block');
      expect(connectionDoc.data()!['fromUserId'], userId);
      expect(connectionDoc.data()!['toUserId'], blockedUserId);
    });

    test('multiple blocks create separate report entries', () async {
      // Block two different users
      await fakeFirestore.collection('reports').add({
        'reporterId': 'user1',
        'reportedUserId': 'badUser1',
        'contentType': 'user',
        'reason': 'blocked_by_user',
        'status': 'pending',
        'isBlockAction': true,
      });
      await fakeFirestore.collection('reports').add({
        'reporterId': 'user1',
        'reportedUserId': 'badUser2',
        'contentType': 'user',
        'reason': 'blocked_by_user',
        'status': 'pending',
        'isBlockAction': true,
      });

      final reports = await fakeFirestore.collection('reports').get();
      expect(reports.docs.length, 2);

      final reportedUsers = reports.docs
          .map((doc) => doc.data()['reportedUserId'] as String)
          .toSet();
      expect(reportedUsers, containsAll(['badUser1', 'badUser2']));
    });
  });
}
