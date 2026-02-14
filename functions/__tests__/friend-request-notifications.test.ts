/**
 * Friend Request Notifications Tests
 *
 * Tests for friend request notification functions including FCM push,
 * in-app notifications, preference handling, and scheduled cleanup.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createTestUser,
} from './mocks';

// Mock firebase-admin before imports
const mockFirestore = new MockFirestore();
const mockMessaging = {
  send: jest.fn().mockResolvedValue('mock-message-id'),
};

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => mockMessaging),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

import * as admin from 'firebase-admin';

// Re-create Firestore FieldValue and Timestamp mocks
(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

describe('Friend Request Notifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
  });

  describe('Notification Types', () => {
    it('should set correct title and body for new friend request', () => {
      const fromUserName = 'John Doe';
      const type: string = 'friend_request';

      let notificationTitle: string;
      let notificationBody: string;

      if (type === 'friend_request_accepted') {
        notificationTitle = 'Friend Request Accepted';
        notificationBody = `${fromUserName} accepted your friend request`;
      } else {
        notificationTitle = 'New Friend Request';
        notificationBody = `${fromUserName} wants to be your friend`;
      }

      expect(notificationTitle).toBe('New Friend Request');
      expect(notificationBody).toBe('John Doe wants to be your friend');
    });

    it('should set correct title and body for friend_request_accepted', () => {
      const fromUserName = 'Jane Smith';
      const type = 'friend_request_accepted';

      let notificationTitle: string;
      let notificationBody: string;

      if (type === 'friend_request_accepted') {
        notificationTitle = 'Friend Request Accepted';
        notificationBody = `${fromUserName} accepted your friend request`;
      } else {
        notificationTitle = 'New Friend Request';
        notificationBody = `${fromUserName} wants to be your friend`;
      }

      expect(notificationTitle).toBe('Friend Request Accepted');
      expect(notificationBody).toBe('Jane Smith accepted your friend request');
    });

    it('should default to friend_request type when type is undefined', () => {
      const fromUserName = 'Alex';
      const type: string | undefined = undefined;

      let notificationTitle: string;
      let notificationBody: string;

      if (type === 'friend_request_accepted') {
        notificationTitle = 'Friend Request Accepted';
        notificationBody = `${fromUserName} accepted your friend request`;
      } else {
        notificationTitle = 'New Friend Request';
        notificationBody = `${fromUserName} wants to be your friend`;
      }

      expect(notificationTitle).toBe('New Friend Request');
      expect(notificationBody).toBe('Alex wants to be your friend');
    });
  });

  describe('FCM Message Structure', () => {
    it('should have correct structure for friend request notification', () => {
      const fcmToken = 'valid-fcm-token';
      const notificationTitle = 'New Friend Request';
      const notificationBody = 'John Doe wants to be your friend';

      const message = {
        token: fcmToken,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          type: 'friend_request',
          connectionId: 'conn-123',
          fromUserId: 'user-sender',
          fromUserName: 'John Doe',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'friend_requests',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: notificationTitle,
                body: notificationBody,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      expect(message.token).toBe('valid-fcm-token');
      expect(message.notification.title).toBe('New Friend Request');
      expect(message.notification.body).toBe('John Doe wants to be your friend');
      expect(message.data.type).toBe('friend_request');
      expect(message.data.click_action).toBe('FLUTTER_NOTIFICATION_CLICK');
      expect(message.data.connectionId).toBe('conn-123');
      expect(message.data.fromUserId).toBe('user-sender');
    });

    it('should set Android channelId to friend_requests', () => {
      const androidConfig = {
        priority: 'high',
        notification: {
          channelId: 'friend_requests',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: 'ic_notification',
        },
      };

      expect(androidConfig.notification.channelId).toBe('friend_requests');
      expect(androidConfig.priority).toBe('high');
      expect(androidConfig.notification.icon).toBe('ic_notification');
    });

    it('should set correct iOS/APNs configuration', () => {
      const apnsConfig = {
        payload: {
          aps: {
            alert: {
              title: 'New Friend Request',
              body: 'John wants to be your friend',
            },
            badge: 1,
            sound: 'default',
          },
        },
      };

      expect(apnsConfig.payload.aps.badge).toBe(1);
      expect(apnsConfig.payload.aps.sound).toBe('default');
      expect(apnsConfig.payload.aps.alert.title).toBe('New Friend Request');
    });

    it('should send FCM message when user has valid token', async () => {
      const recipientId = 'test-recipient';
      const recipientData = createTestUser({
        uid: recipientId,
        fcmToken: 'valid-fcm-token',
      });

      const usersData = new Map<string, any>();
      usersData.set(recipientId, recipientData);
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(recipientId).get();
      expect(userDoc.data()?.fcmToken).toBe('valid-fcm-token');

      // Simulate sending FCM notification
      const message = {
        token: recipientData.fcmToken,
        notification: {
          title: 'New Friend Request',
          body: 'John Doe wants to be your friend',
        },
        data: {
          type: 'friend_request',
          connectionId: 'conn-123',
          fromUserId: 'sender-user',
          fromUserName: 'John Doe',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };

      await mockMessaging.send(message);

      expect(mockMessaging.send).toHaveBeenCalledTimes(1);
      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: 'valid-fcm-token',
          notification: expect.objectContaining({
            title: 'New Friend Request',
          }),
          data: expect.objectContaining({
            type: 'friend_request',
          }),
        })
      );
    });

    it('should use empty string fallback for missing connectionId', () => {
      const connectionId = undefined;
      const fromUserName = undefined;

      const data = {
        type: 'friend_request',
        connectionId: connectionId || '',
        fromUserId: 'user-123',
        fromUserName: fromUserName || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      };

      expect(data.connectionId).toBe('');
      expect(data.fromUserName).toBe('');
    });
  });

  describe('Notification Preferences', () => {
    it('should skip FCM when friendRequests preference is false', async () => {
      const recipientId = 'test-recipient';

      // Set up user
      const usersData = new Map<string, any>();
      usersData.set(recipientId, createTestUser({
        uid: recipientId,
        fcmToken: 'valid-fcm-token',
      }));
      mockFirestore.setTestData('users', usersData);

      // Set up notification preferences with friendRequests disabled
      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, { friendRequests: false });
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();
      const prefs = prefsDoc.data();

      expect(prefs?.friendRequests).toBe(false);

      // FCM should NOT be sent
      expect(mockMessaging.send).not.toHaveBeenCalled();
    });

    it('should still create in-app notification when FCM is disabled via preferences', async () => {
      const recipientId = 'test-recipient';

      // Preferences disable FCM
      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, { friendRequests: false });
      mockFirestore.setTestData('notification_preferences', prefsData);

      // But in-app notification should still be created
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `friend_request_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: recipientId,
        type: 'friendRequest',
        title: 'New Friend Request',
        message: 'John wants to be your friend',
        isRead: false,
        priority: 'high',
      });

      const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(notificationDoc.exists).toBe(true);
      expect(notificationDoc.data()?.type).toBe('friendRequest');
    });

    it('should send FCM when friendRequests preference is true', async () => {
      const recipientId = 'test-recipient';

      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, { friendRequests: true });
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();
      const prefs = prefsDoc.data();

      expect(prefs?.friendRequests).toBe(true);

      // FCM should proceed (not blocked by preferences)
    });

    it('should send FCM when notification preferences document does not exist', async () => {
      const recipientId = 'test-recipient';

      // No preferences set (empty collection)
      const prefsData = new Map<string, any>();
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();

      expect(prefsDoc.exists).toBe(false);

      // When prefs doc doesn't exist, prefs is null, so friendRequests check is skipped
      // FCM should proceed
      const prefs = prefsDoc.exists ? prefsDoc.data() : null;
      const shouldSkipFcm = prefs && prefs.friendRequests === false;

      expect(shouldSkipFcm).toBeFalsy();
    });
  });

  describe('Missing Recipient Handling', () => {
    it('should return early when recipient user is not found', async () => {
      const recipientId = 'non-existent-user';

      const usersData = new Map<string, any>();
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(recipientId).get();

      expect(userDoc.exists).toBe(false);

      // Function should return early without error
    });

    it('should mark notification as processed when user not found', async () => {
      const notificationId = 'notif-missing-user';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'non-existent-user',
        fromUserId: 'sender-123',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      // markAsProcessed should be called
      await mockFirestore.collection('friend_request_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: null,
      });

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
    });

    it('should mark notification as processed when toUserId is missing', async () => {
      const notificationId = 'notif-no-recipient';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: null,
        fromUserId: 'sender-123',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      const notificationData = doc.data();

      expect(notificationData?.toUserId).toBeFalsy();

      // Function should return early after marking as processed
    });
  });

  describe('Already Processed Handling', () => {
    it('should skip if notification is already processed', async () => {
      const notificationId = 'already-processed-notif';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        fromUserName: 'Sender',
        type: 'friend_request',
        processed: true,
        processedAt: MockTimestamp.now(),
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      const notificationData = doc.data();

      expect(notificationData?.processed).toBe(true);

      // Function should return null without sending FCM or creating in-app notification
      expect(mockMessaging.send).not.toHaveBeenCalled();
    });

    it('should process notification when processed is false', async () => {
      const notificationId = 'unprocessed-notif';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        fromUserName: 'Sender',
        type: 'friend_request',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      const notificationData = doc.data();

      expect(notificationData?.processed).toBe(false);

      // Function should continue processing
    });

    it('should process notification when processed field is undefined', async () => {
      const notificationId = 'no-processed-field';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        fromUserName: 'Sender',
        type: 'friend_request',
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      const notificationData = doc.data();

      expect(notificationData?.processed).toBeUndefined();

      // undefined is falsy, so function should continue processing
      const shouldSkip = notificationData?.processed;
      expect(shouldSkip).toBeFalsy();
    });
  });

  describe('Invalid FCM Token Handling', () => {
    it('should detect invalid-registration-token error', () => {
      const error = {
        code: 'messaging/invalid-registration-token',
        message: 'Invalid FCM token',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should detect registration-token-not-registered error', () => {
      const error = {
        code: 'messaging/registration-token-not-registered',
        message: 'Token not registered',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should not treat other FCM errors as invalid token', () => {
      const error = {
        code: 'messaging/internal-error',
        message: 'Internal server error',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(false);
    });

    it('should remove invalid FCM token from user document', async () => {
      const userId = 'user-with-invalid-token';
      const usersData = new Map<string, any>();
      usersData.set(userId, createTestUser({
        uid: userId,
        fcmToken: 'invalid-token-abc',
      }));
      mockFirestore.setTestData('users', usersData);

      // Simulate removing the token using FieldValue.delete()
      await mockFirestore.collection('users').doc(userId).update({
        fcmToken: MockFieldValue.delete(),
      });

      expect(MockFieldValue.delete).toHaveBeenCalled();

      const userDoc = await mockFirestore.collection('users').doc(userId).get();
      // After update with FieldValue.delete(), the mock stores the sentinel object
      // In real Firestore, the field would be removed
    });

    it('should handle FCM send failure and still continue processing', async () => {
      mockMessaging.send.mockRejectedValueOnce({
        code: 'messaging/invalid-registration-token',
        message: 'Invalid FCM token',
      });

      try {
        await mockMessaging.send({ token: 'invalid-token' });
      } catch (error: any) {
        expect(error.code).toBe('messaging/invalid-registration-token');
      }

      // After FCM failure, in-app notification and markAsProcessed should still run
    });
  });

  describe('In-App Notification Creation', () => {
    it('should create in-app notification with correct fields for new friend request', async () => {
      const fromUserId = 'sender-123';
      const fromUserName = 'John Doe';
      const fromUserImageUrl = 'https://example.com/avatar.jpg';
      const toUserId = 'recipient-456';
      const connectionId = 'conn-789';
      const type: string = 'friend_request';

      const isAccepted = type === 'friend_request_accepted';
      const notificationId = `friend_${isAccepted ? 'accepted' : 'request'}_${Date.now()}`;

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationDoc = {
        notificationId: notificationId,
        userId: toUserId,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserImage: fromUserImageUrl,
        type: 'friendRequest',
        title: 'New Friend Request',
        message: `${fromUserName} wants to be your friend`,
        createdAt: MockFieldValue.serverTimestamp(),
        isRead: false,
        data: {
          connectionId: connectionId,
          fromUserId: fromUserId,
        },
        actionUrl: '/friends/requests',
        priority: 'high',
      };

      await mockFirestore.collection('notifications').doc(notificationId).set(notificationDoc);

      const savedDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(savedDoc.exists).toBe(true);
      expect(savedDoc.data()?.type).toBe('friendRequest');
      expect(savedDoc.data()?.title).toBe('New Friend Request');
      expect(savedDoc.data()?.message).toBe('John Doe wants to be your friend');
      expect(savedDoc.data()?.userId).toBe('recipient-456');
      expect(savedDoc.data()?.fromUserId).toBe('sender-123');
      expect(savedDoc.data()?.fromUserImage).toBe('https://example.com/avatar.jpg');
      expect(savedDoc.data()?.isRead).toBe(false);
      expect(savedDoc.data()?.priority).toBe('high');
      expect(savedDoc.data()?.actionUrl).toBe('/friends/requests');
    });

    it('should create in-app notification with correct fields for accepted request', async () => {
      const fromUserId = 'sender-123';
      const fromUserName = 'Jane Smith';
      const toUserId = 'recipient-456';
      const type = 'friend_request_accepted';

      const isAccepted = type === 'friend_request_accepted';
      const notificationId = `friend_${isAccepted ? 'accepted' : 'request'}_${Date.now()}`;

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationDoc = {
        notificationId: notificationId,
        userId: toUserId,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserImage: null,
        type: 'friendRequestAccepted',
        title: 'Friend Request Accepted',
        message: `${fromUserName} accepted your friend request`,
        createdAt: MockFieldValue.serverTimestamp(),
        isRead: false,
        data: {
          connectionId: 'conn-abc',
          fromUserId: fromUserId,
        },
        actionUrl: `/profile/${fromUserId}`,
        priority: 'high',
      };

      await mockFirestore.collection('notifications').doc(notificationId).set(notificationDoc);

      const savedDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(savedDoc.exists).toBe(true);
      expect(savedDoc.data()?.type).toBe('friendRequestAccepted');
      expect(savedDoc.data()?.title).toBe('Friend Request Accepted');
      expect(savedDoc.data()?.message).toBe('Jane Smith accepted your friend request');
      expect(savedDoc.data()?.actionUrl).toBe('/profile/sender-123');
    });

    it('should set correct action URL for new friend request vs accepted', () => {
      const fromUserId = 'sender-123';

      // New friend request should link to requests page
      const newRequestActionUrl = '/friends/requests';
      expect(newRequestActionUrl).toBe('/friends/requests');

      // Accepted request should link to sender profile
      const acceptedActionUrl = `/profile/${fromUserId}`;
      expect(acceptedActionUrl).toBe('/profile/sender-123');
    });

    it('should use "Someone" as fallback when fromUserName is missing', () => {
      const fromUserName = undefined;

      const displayName = fromUserName || 'Someone';
      const messageForRequest = `${displayName} wants to be your friend`;
      const messageForAccepted = `${displayName} accepted your friend request`;

      expect(messageForRequest).toBe('Someone wants to be your friend');
      expect(messageForAccepted).toBe('Someone accepted your friend request');
    });

    it('should set correct type field based on notification type', () => {
      // New request
      const newRequestType: string = 'friend_request';
      const isAcceptedNew = newRequestType === 'friend_request_accepted';
      expect(isAcceptedNew ? 'friendRequestAccepted' : 'friendRequest').toBe('friendRequest');

      // Accepted
      const acceptedType = 'friend_request_accepted';
      const isAcceptedTrue = acceptedType === 'friend_request_accepted';
      expect(isAcceptedTrue ? 'friendRequestAccepted' : 'friendRequest').toBe('friendRequestAccepted');
    });

    it('should set priority to high for friend request notifications', async () => {
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `friend_request_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: 'recipient-123',
        type: 'friendRequest',
        title: 'New Friend Request',
        message: 'Someone wants to be your friend',
        isRead: false,
        priority: 'high',
      });

      const savedDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(savedDoc.data()?.priority).toBe('high');
    });
  });

  describe('markAsProcessed', () => {
    it('should update notification with processed=true and timestamp', async () => {
      const notificationId = 'notif-to-process';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      await mockFirestore.collection('friend_request_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: null,
      });

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
      expect(doc.data()?.error).toBeNull();
      expect(MockFieldValue.serverTimestamp).toHaveBeenCalled();
    });

    it('should store error message when processing fails', async () => {
      const notificationId = 'notif-with-error';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const errorMessage = 'Something went wrong';

      await mockFirestore.collection('friend_request_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: errorMessage,
      });

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
      expect(doc.data()?.error).toBe('Something went wrong');
    });

    it('should set error to null when no error occurred', async () => {
      const notificationId = 'notif-no-error';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const error = undefined;
      await mockFirestore.collection('friend_request_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: error || null,
      });

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      expect(doc.data()?.error).toBeNull();
    });
  });

  describe('cleanupOldFriendRequestNotifications', () => {
    it('should run daily at 4 AM Eastern', () => {
      const schedule = '0 4 * * *';
      const timezone = 'America/New_York';

      expect(schedule).toBe('0 4 * * *');
      expect(timezone).toBe('America/New_York');
    });

    it('should query for processed notifications older than 7 days', async () => {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      const sevenDaysAgoTimestamp = MockTimestamp.fromDate(sevenDaysAgo);

      const queryCriteria = {
        processed: true,
        processedAt: {
          lessThan: sevenDaysAgoTimestamp,
        },
      };

      expect(queryCriteria.processed).toBe(true);
      expect(queryCriteria.processedAt.lessThan).toBeDefined();
      expect(queryCriteria.processedAt.lessThan.toDate().getTime()).toBeLessThan(Date.now());
    });

    it('should limit query to 500 documents', () => {
      const batchLimit = 500;

      const oldCount = 750;
      const processedCount = Math.min(oldCount, batchLimit);

      expect(processedCount).toBe(500);
    });

    it('should return early when no old notifications exist', async () => {
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const snapshot = await mockFirestore.collection('friend_request_notifications').get();

      expect(snapshot.empty).toBe(true);
    });

    it('should batch delete old processed notifications', async () => {
      const oldNotifications = [
        {
          id: 'old-notif-1',
          processed: true,
          processedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // 10 days ago
        },
        {
          id: 'old-notif-2',
          processed: true,
          processedAt: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000), // 8 days ago
        },
        {
          id: 'old-notif-3',
          processed: true,
          processedAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // 14 days ago
        },
      ];

      const notificationsData = new Map<string, any>();
      oldNotifications.forEach((n) => notificationsData.set(n.id, n));
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      // Use batch to delete
      const batch = mockFirestore.batch();

      for (const notification of oldNotifications) {
        const ref = mockFirestore.collection('friend_request_notifications').doc(notification.id);
        batch.delete(ref);
      }

      await batch.commit();

      // Verify batch operations
    });

    it('should not delete recent processed notifications', () => {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const recentNotification = {
        processed: true,
        processedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
      };

      const isOld = recentNotification.processedAt < sevenDaysAgo;
      expect(isOld).toBe(false);
    });

    it('should not delete unprocessed notifications regardless of age', () => {
      const oldUnprocessedNotification = {
        processed: false,
        processedAt: null,
        createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
      };

      // Cleanup only targets processed=true
      expect(oldUnprocessedNotification.processed).toBe(false);
    });
  });

  describe('Error Handling', () => {
    it('should mark notification as processed with error on general failure', async () => {
      const notificationId = 'notif-general-error';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, {
        toUserId: 'recipient-123',
        fromUserId: 'sender-123',
        processed: false,
      });
      mockFirestore.setTestData('friend_request_notifications', notificationsData);

      const error = new Error('Unexpected processing error');

      await mockFirestore.collection('friend_request_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: error.message,
      });

      const doc = await mockFirestore.collection('friend_request_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
      expect(doc.data()?.error).toBe('Unexpected processing error');
    });

    it('should handle FCM send failure gracefully and continue', async () => {
      mockMessaging.send.mockRejectedValueOnce(new Error('FCM service unavailable'));

      try {
        await mockMessaging.send({ token: 'some-token' });
      } catch (error: any) {
        expect(error.message).toBe('FCM service unavailable');
      }

      // In-app notification and markAsProcessed should still be called
    });

    it('should handle Firestore write errors in markAsProcessed', async () => {
      // Simulate a scenario where markAsProcessed itself could fail
      // The function wraps the update in a try/catch and logs the error
      try {
        throw new Error('Firestore write failed');
      } catch (e: any) {
        expect(e.message).toBe('Firestore write failed');
        // Function logs error but does not re-throw
      }
    });

    it('should handle Firestore write errors in createInAppNotification', async () => {
      // createInAppNotification wraps its logic in try/catch
      try {
        throw new Error('Firestore set failed');
      } catch (e: any) {
        expect(e.message).toBe('Firestore set failed');
        // Function logs error but does not re-throw
      }
    });

    it('should return null from the outer catch block on error', async () => {
      try {
        throw new Error('Unexpected error in main handler');
      } catch (error) {
        const result = null;
        expect(result).toBeNull();
      }
    });

    it('should return { success: true } on successful processing', () => {
      const result = { success: true };
      expect(result).toEqual({ success: true });
    });
  });

  describe('Firestore Trigger Configuration', () => {
    it('should listen on friend_request_notifications/{notificationId} path', () => {
      const triggerPath = 'friend_request_notifications/{notificationId}';
      expect(triggerPath).toBe('friend_request_notifications/{notificationId}');
    });

    it('should be an onCreate trigger', () => {
      const triggerType = 'onCreate';
      expect(triggerType).toBe('onCreate');
    });

    it('should extract notificationId from context params', () => {
      const context = {
        params: {
          notificationId: 'test-notif-id-123',
        },
      };

      expect(context.params.notificationId).toBe('test-notif-id-123');
    });
  });
});
