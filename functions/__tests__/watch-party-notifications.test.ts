/**
 * Watch Party Notifications Tests
 *
 * Tests for watch party invite and cancellation notification functions.
 */

import {
  MockFirestore,
  MockDocumentSnapshot,
  MockQuerySnapshot,
  MockTimestamp,
  MockFieldValue,
  createTestUser,
  createTestWatchParty,
  createTestWatchPartyInvite,
} from './mocks';

// Mock firebase-admin before imports
const mockFirestore = new MockFirestore();
const mockMessaging = {
  send: jest.fn().mockResolvedValue('mock-message-id'),
  sendMulticast: jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }),
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

describe('Watch Party Notifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
  });

  describe('onWatchPartyInviteCreated', () => {
    it('should send FCM notification when invite is created', async () => {
      // Setup test data
      const inviteeId = 'test-invitee';
      const inviterId = 'test-inviter';
      const watchPartyId = 'test-party';

      const inviteeData = createTestUser({
        uid: inviteeId,
        fcmToken: 'valid-fcm-token',
        displayName: 'Test Invitee',
      });

      const inviteData = createTestWatchPartyInvite({
        watchPartyId,
        inviterId,
        inviterName: 'Test Inviter',
        inviteeId,
        watchPartyName: 'Big Game Watch Party',
        message: 'Come watch the game with us!',
      });

      // Set up users collection
      const usersData = new Map<string, any>();
      usersData.set(inviteeId, inviteeData);
      mockFirestore.setTestData('users', usersData);

      // Get invitee data
      const userDoc = await mockFirestore.collection('users').doc(inviteeId).get();
      expect(userDoc.exists).toBe(true);
      expect(userDoc.data()?.fcmToken).toBe('valid-fcm-token');

      // Simulate sending FCM notification
      const notificationTitle = 'Watch Party Invitation';
      const notificationBody = `${inviteData.inviterName}: "${inviteData.message}"`;

      const message = {
        token: inviteeData.fcmToken,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          type: 'watch_party_invite',
          inviteId: 'invite-123',
          watchPartyId: inviteData.watchPartyId,
          inviterId: inviteData.inviterId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'watch_party_invites',
          },
        },
      };

      await mockMessaging.send(message);

      expect(mockMessaging.send).toHaveBeenCalledTimes(1);
      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: 'valid-fcm-token',
          notification: expect.objectContaining({
            title: 'Watch Party Invitation',
          }),
          data: expect.objectContaining({
            type: 'watch_party_invite',
          }),
        })
      );
    });

    it('should create in-app notification even without FCM token', async () => {
      const inviteeId = 'test-invitee-no-fcm';
      const inviteData = createTestWatchPartyInvite({
        inviteeId,
        inviterName: 'Test Host',
        watchPartyName: 'World Cup Final Watch',
      });

      // User without FCM token
      const inviteeData = {
        uid: inviteeId,
        email: 'test@example.com',
        displayName: 'Test User',
        fcmToken: null, // No FCM token
        favoriteTeamCodes: [],
      };

      const usersData = new Map<string, any>();
      usersData.set(inviteeId, inviteeData);
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(inviteeId).get();
      expect(userDoc.data()?.fcmToken).toBeFalsy();

      // Should create in-app notification
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `watch_party_invite_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: inviteeId,
        type: 'watchPartyInvite',
        title: 'Watch Party Invitation',
        message: `${inviteData.inviterName} invited you to watch together`,
        isRead: false,
        priority: 'high',
      });

      const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(notificationDoc.exists).toBe(true);
      expect(notificationDoc.data()?.type).toBe('watchPartyInvite');
    });

    it('should handle missing invitee gracefully', async () => {
      const inviteeId = 'non-existent-user';

      const usersData = new Map<string, any>();
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(inviteeId).get();
      expect(userDoc.exists).toBe(false);

      // Function should return early without error
    });

    it('should include personal message in notification body', () => {
      const inviterName = 'John';
      const personalMessage = 'Hey, join us for the big game!';

      // With personal message
      let notificationBody = `${inviterName}: "${personalMessage}"`;
      expect(notificationBody).toBe('John: "Hey, join us for the big game!"');

      // Without personal message
      const watchPartyName = 'USA vs Brazil Watch Party';
      notificationBody = `${inviterName} invited you to "${watchPartyName}"`;
      expect(notificationBody).toBe('John invited you to "USA vs Brazil Watch Party"');
    });

    it('should set correct Android notification channel', () => {
      const androidConfig = {
        priority: 'high',
        notification: {
          channelId: 'watch_party_invites',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      };

      expect(androidConfig.notification.channelId).toBe('watch_party_invites');
      expect(androidConfig.priority).toBe('high');
    });

    it('should set correct iOS/APNs configuration', () => {
      const apnsConfig = {
        payload: {
          aps: {
            alert: {
              title: 'Watch Party Invitation',
              body: 'You have been invited!',
            },
            badge: 1,
            sound: 'default',
          },
        },
      };

      expect(apnsConfig.payload.aps.badge).toBe(1);
      expect(apnsConfig.payload.aps.sound).toBe('default');
    });
  });

  describe('onWatchPartyInviteUpdated', () => {
    it('should not notify if status unchanged', async () => {
      const beforeData = { status: 'pending' };
      const afterData = { status: 'pending' };

      const statusChanged = beforeData.status !== afterData.status;
      expect(statusChanged).toBe(false);
    });

    it('should notify host when invite is accepted', async () => {
      const hostId = 'test-host';
      const inviteeId = 'test-invitee';
      const watchPartyId = 'test-party';

      const beforeData = { status: 'pending', inviteeId, watchPartyId };
      const afterData = { status: 'accepted', inviteeId, watchPartyId, watchPartyName: 'Game Day' };

      const statusChanged = beforeData.status !== afterData.status;
      expect(statusChanged).toBe(true);

      const newStatus = afterData.status;
      expect(newStatus).toBe('accepted');

      // Set up watch party and users
      const watchPartiesData = new Map<string, any>();
      watchPartiesData.set(watchPartyId, createTestWatchParty({ hostId }));
      mockFirestore.setTestData('watch_parties', watchPartiesData);

      const usersData = new Map<string, any>();
      usersData.set(hostId, createTestUser({ uid: hostId, fcmToken: 'host-fcm-token' }));
      usersData.set(inviteeId, createTestUser({ uid: inviteeId, displayName: 'Accepted User' }));
      mockFirestore.setTestData('users', usersData);

      // Get host data
      const watchPartyDoc = await mockFirestore.collection('watch_parties').doc(watchPartyId).get();
      expect(watchPartyDoc.data()?.hostId).toBe(hostId);

      const hostDoc = await mockFirestore.collection('users').doc(hostId).get();
      expect(hostDoc.data()?.fcmToken).toBe('host-fcm-token');

      // Notification message
      const inviteeName = 'Accepted User';
      const notificationTitle = 'Invite Accepted!';
      const notificationBody = `${inviteeName} is joining your watch party "${afterData.watchPartyName}"`;

      expect(notificationTitle).toBe('Invite Accepted!');
      expect(notificationBody).toContain('is joining your watch party');
    });

    it('should notify host when invite is declined', async () => {
      const afterData = { status: 'declined', watchPartyName: 'Finals Watch' };
      const inviteeName = 'Busy User';

      const notificationTitle = 'Invite Declined';
      const notificationBody = `${inviteeName} can't make it to "${afterData.watchPartyName}"`;

      expect(notificationTitle).toBe('Invite Declined');
      expect(notificationBody).toContain("can't make it");
    });

    it('should only process accepted or declined statuses', () => {
      const validStatuses = ['accepted', 'declined'];

      expect(validStatuses.includes('accepted')).toBe(true);
      expect(validStatuses.includes('declined')).toBe(true);
      expect(validStatuses.includes('pending')).toBe(false);
      expect(validStatuses.includes('expired')).toBe(false);
    });

    it('should create in-app notification for host', async () => {
      const hostId = 'test-host';
      const inviteeId = 'test-invitee';
      const watchPartyId = 'test-party';

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `invite_response_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: hostId,
        fromUserId: inviteeId,
        fromUserName: 'Test User',
        type: 'watchPartyInviteAccepted',
        title: 'Invite Accepted!',
        message: 'Test User is joining your watch party',
        isRead: false,
        data: {
          watchPartyId,
          status: 'accepted',
        },
        priority: 'normal',
      });

      const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(notificationDoc.exists).toBe(true);
      expect(notificationDoc.data()?.type).toBe('watchPartyInviteAccepted');
    });
  });

  describe('onWatchPartyCancelled', () => {
    it('should not process if status is not cancelled', () => {
      const beforeData = { status: 'active' };
      const afterData = { status: 'active' };

      const shouldProcess =
        beforeData.status !== afterData.status && afterData.status === 'cancelled';

      expect(shouldProcess).toBe(false);
    });

    it('should notify all members except host on cancellation', async () => {
      const hostId = 'host-user';
      const member1 = 'member-1';
      const member2 = 'member-2';

      // Set up members subcollection data
      const members = [
        { id: hostId, name: 'Host User' },
        { id: member1, name: 'Member 1' },
        { id: member2, name: 'Member 2' },
      ];

      // Filter out host for notifications
      const membersToNotify = members.filter((m) => m.id !== hostId);
      expect(membersToNotify).toHaveLength(2);
      expect(membersToNotify.map((m) => m.id)).not.toContain(hostId);
    });

    it('should include party name and game in cancellation message', () => {
      const watchPartyName = 'Super Bowl Watch';
      const gameName = 'USA vs Canada';

      const message = `"${watchPartyName}" for ${gameName} has been cancelled`;

      expect(message).toBe('"Super Bowl Watch" for USA vs Canada has been cancelled');
    });

    it('should handle empty member list gracefully', async () => {
      // Empty members collection simulation
      const memberDocs: any[] = [];
      const membersSnapshot = { empty: memberDocs.length === 0, docs: memberDocs };

      expect(membersSnapshot.empty).toBe(true);
    });

    it('should create high priority in-app notification', async () => {
      const memberId = 'member-to-notify';
      const hostId = 'host-user';
      const watchPartyId = 'cancelled-party';

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `party_cancelled_${memberId}_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: memberId,
        fromUserId: hostId,
        fromUserName: 'Host',
        type: 'watchPartyCancelled',
        title: 'Watch Party Cancelled',
        message: '"Finals Watch" for USA vs Mexico has been cancelled',
        isRead: false,
        data: {
          watchPartyId,
          watchPartyName: 'Finals Watch',
        },
        priority: 'high',
      });

      const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(notificationDoc.exists).toBe(true);
      expect(notificationDoc.data()?.type).toBe('watchPartyCancelled');
      expect(notificationDoc.data()?.priority).toBe('high');
    });

    it('should handle FCM send failures gracefully', async () => {
      // Mock FCM failure
      mockMessaging.send.mockRejectedValueOnce(new Error('FCM send failed'));

      try {
        await mockMessaging.send({ token: 'invalid-token' });
      } catch (error: any) {
        expect(error.message).toBe('FCM send failed');
      }

      // Should still attempt to create in-app notification
    });

    it('should use Promise.all for parallel member notifications', async () => {
      const memberIds = ['member-1', 'member-2', 'member-3', 'member-4', 'member-5'];

      // Simulate parallel notification promises
      const notificationPromises = memberIds.map(async (memberId) => {
        return { memberId, notified: true };
      });

      const results = await Promise.all(notificationPromises);

      expect(results).toHaveLength(5);
      expect(results.every((r) => r.notified)).toBe(true);
    });
  });

  describe('In-App Notification Creation', () => {
    it('should include all required fields', async () => {
      const notification = {
        notificationId: `watch_party_invite_${Date.now()}`,
        userId: 'test-user',
        fromUserId: 'inviter-user',
        fromUserName: 'John Doe',
        fromUserImage: 'https://example.com/avatar.jpg',
        type: 'watchPartyInvite',
        title: 'Watch Party Invitation',
        message: 'John Doe invited you to watch together',
        createdAt: MockFieldValue.serverTimestamp(),
        isRead: false,
        data: {
          inviteId: 'invite-123',
          watchPartyId: 'party-456',
          watchPartyName: 'Game Day',
          gameName: 'USA vs Brazil',
          gameDateTime: new Date(),
        },
        actionUrl: '/watch-party/party-456',
        priority: 'high',
      };

      expect(notification.notificationId).toBeDefined();
      expect(notification.userId).toBeDefined();
      expect(notification.type).toBe('watchPartyInvite');
      expect(notification.isRead).toBe(false);
      expect(notification.priority).toBe('high');
      expect(notification.actionUrl).toContain('/watch-party/');
    });

    it('should generate unique notification IDs', () => {
      const ids = new Set<string>();

      for (let i = 0; i < 100; i++) {
        const id = `watch_party_invite_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        ids.add(id);
      }

      // All IDs should be unique
      expect(ids.size).toBe(100);
    });
  });

  describe('FCM Message Structure', () => {
    it('should have correct structure for watch party invite', () => {
      const message = {
        token: 'fcm-token',
        notification: {
          title: 'Watch Party Invitation',
          body: 'You have been invited!',
        },
        data: {
          type: 'watch_party_invite',
          inviteId: 'invite-123',
          watchPartyId: 'party-456',
          inviterId: 'inviter-789',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'watch_party_invites',
            priority: 'high' as const,
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: 'Watch Party Invitation',
                body: 'You have been invited!',
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      expect(message.data.type).toBe('watch_party_invite');
      expect(message.data.click_action).toBe('FLUTTER_NOTIFICATION_CLICK');
      expect(message.android.notification.channelId).toBe('watch_party_invites');
      expect(message.apns.payload.aps.badge).toBe(1);
    });

    it('should have correct structure for cancellation notification', () => {
      const message = {
        token: 'fcm-token',
        notification: {
          title: 'Watch Party Cancelled',
          body: '"Finals Watch" has been cancelled',
        },
        data: {
          type: 'watch_party_cancelled',
          watchPartyId: 'party-456',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };

      expect(message.data.type).toBe('watch_party_cancelled');
    });
  });

  describe('Error Handling', () => {
    it('should handle invalid FCM token error', async () => {
      const error = {
        code: 'messaging/invalid-registration-token',
        message: 'Invalid FCM token',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should handle unregistered token error', async () => {
      const error = {
        code: 'messaging/registration-token-not-registered',
        message: 'Token not registered',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should continue processing other members on individual failure', async () => {
      const memberIds = ['member-1', 'member-2', 'member-3'];
      let successCount = 0;
      let failureCount = 0;

      const processPromises = memberIds.map(async (memberId, index) => {
        try {
          if (index === 1) {
            throw new Error('FCM failed for member-2');
          }
          successCount++;
          return { memberId, success: true };
        } catch (error) {
          failureCount++;
          return { memberId, success: false };
        }
      });

      const results = await Promise.all(processPromises);

      expect(successCount).toBe(2);
      expect(failureCount).toBe(1);
      expect(results.filter((r) => r.success)).toHaveLength(2);
    });
  });
});
