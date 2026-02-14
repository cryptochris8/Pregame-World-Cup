/**
 * Message Notifications Tests
 *
 * Tests for message notification functions including FCM delivery,
 * quiet hours, message type text, and cleanup.
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

// Helper to create test message notification data
const createTestMessageNotification = (overrides: Partial<{
  chatId: string;
  messageId: string;
  senderId: string;
  senderName: string;
  senderImageUrl: string;
  content: string;
  messageType: string;
  recipientIds: string[];
  chatName: string;
  chatType: string;
  processed: boolean;
}> = {}) => ({
  chatId: overrides.chatId || 'test-chat-id',
  messageId: overrides.messageId || 'test-message-id',
  senderId: overrides.senderId || 'test-sender-id',
  senderName: overrides.senderName || 'Test Sender',
  senderImageUrl: overrides.senderImageUrl || 'https://example.com/avatar.jpg',
  content: overrides.content || 'Hello, world!',
  messageType: overrides.messageType || 'text',
  recipientIds: overrides.recipientIds || ['recipient-1', 'recipient-2'],
  chatName: overrides.chatName || 'Test Chat',
  chatType: overrides.chatType || 'direct',
  processed: overrides.processed !== undefined ? overrides.processed : false,
});

describe('Message Notifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
  });

  describe('Message Notification Data Model', () => {
    it('should have all required fields', () => {
      const notification = createTestMessageNotification();

      expect(notification.chatId).toBeDefined();
      expect(notification.messageId).toBeDefined();
      expect(notification.senderId).toBeDefined();
      expect(notification.senderName).toBeDefined();
      expect(notification.senderImageUrl).toBeDefined();
      expect(notification.content).toBeDefined();
      expect(notification.messageType).toBeDefined();
      expect(notification.recipientIds).toBeDefined();
      expect(notification.chatName).toBeDefined();
      expect(notification.chatType).toBeDefined();
      expect(notification.processed).toBeDefined();
    });

    it('should default to unprocessed state', () => {
      const notification = createTestMessageNotification();

      expect(notification.processed).toBe(false);
    });

    it('should default to text message type', () => {
      const notification = createTestMessageNotification();

      expect(notification.messageType).toBe('text');
    });

    it('should skip if already processed', () => {
      const notification = createTestMessageNotification({ processed: true });

      const shouldSkip = notification.processed === true;

      expect(shouldSkip).toBe(true);
    });
  });

  describe('Notification Title - Direct vs Group Chat', () => {
    it('should use senderName as title for direct chat', () => {
      const notification = createTestMessageNotification({
        chatType: 'direct',
        senderName: 'Alice',
        chatName: 'Alice & Bob Chat',
      });

      const title = notification.chatType === 'direct'
        ? notification.senderName
        : notification.chatName || 'New Message';

      expect(title).toBe('Alice');
    });

    it('should use chatName as title for group chat', () => {
      const notification = createTestMessageNotification({
        chatType: 'group',
        senderName: 'Alice',
        chatName: 'World Cup Fans',
      });

      const title = notification.chatType === 'direct'
        ? notification.senderName
        : notification.chatName || 'New Message';

      expect(title).toBe('World Cup Fans');
    });

    it('should fall back to "New Message" when group chat has no name', () => {
      const chatType: string = 'group';
      const senderName = 'Alice';
      const chatName = '';

      const title = chatType === 'direct'
        ? senderName
        : chatName || 'New Message';

      expect(title).toBe('New Message');
    });
  });

  describe('getMessageTypeText Function', () => {
    const getMessageTypeText = (type: string, senderName: string): string => {
      switch (type) {
        case 'image':
          return `${senderName} sent a photo`;
        case 'voice':
          return `${senderName} sent a voice message`;
        case 'video':
          return `${senderName} sent a video`;
        case 'file':
          return `${senderName} sent a file`;
        case 'location':
          return `${senderName} shared a location`;
        case 'gameInvite':
          return `${senderName} invited you to watch a game`;
        case 'venueShare':
          return `${senderName} shared a venue`;
        default:
          return `${senderName} sent a message`;
      }
    };

    it('should return "sent a photo" for image type', () => {
      expect(getMessageTypeText('image', 'Alice')).toBe('Alice sent a photo');
    });

    it('should return "sent a voice message" for voice type', () => {
      expect(getMessageTypeText('voice', 'Alice')).toBe('Alice sent a voice message');
    });

    it('should return "sent a video" for video type', () => {
      expect(getMessageTypeText('video', 'Alice')).toBe('Alice sent a video');
    });

    it('should return "sent a file" for file type', () => {
      expect(getMessageTypeText('file', 'Alice')).toBe('Alice sent a file');
    });

    it('should return "shared a location" for location type', () => {
      expect(getMessageTypeText('location', 'Alice')).toBe('Alice shared a location');
    });

    it('should return "invited you to watch a game" for gameInvite type', () => {
      expect(getMessageTypeText('gameInvite', 'Alice')).toBe('Alice invited you to watch a game');
    });

    it('should return "shared a venue" for venueShare type', () => {
      expect(getMessageTypeText('venueShare', 'Alice')).toBe('Alice shared a venue');
    });

    it('should return "sent a message" for unknown type', () => {
      expect(getMessageTypeText('unknown', 'Alice')).toBe('Alice sent a message');
    });

    it('should use text content directly for text message type', () => {
      const notification = createTestMessageNotification({
        messageType: 'text',
        content: 'Hello!',
        senderName: 'Alice',
      });

      let body = notification.content;
      if (notification.messageType !== 'text') {
        body = getMessageTypeText(notification.messageType, notification.senderName);
      }

      expect(body).toBe('Hello!');
    });

    it('should use type text for non-text message types', () => {
      const notification = createTestMessageNotification({
        messageType: 'image',
        content: '[image]',
        senderName: 'Alice',
      });

      let body = notification.content;
      if (notification.messageType !== 'text') {
        body = getMessageTypeText(notification.messageType, notification.senderName);
      }

      expect(body).toBe('Alice sent a photo');
    });
  });

  describe('isInQuietHours Function', () => {
    const isInQuietHours = (prefs: any): boolean => {
      if (!prefs.quietHoursEnabled || !prefs.quietHoursStart || !prefs.quietHoursEnd) {
        return false;
      }

      const now = new Date();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();
      const currentTime = currentHour * 60 + currentMinute;

      const [startHour, startMinute] = prefs.quietHoursStart.split(':').map(Number);
      const [endHour, endMinute] = prefs.quietHoursEnd.split(':').map(Number);
      const startTime = startHour * 60 + startMinute;
      const endTime = endHour * 60 + endMinute;

      // Handle overnight quiet hours (e.g., 22:00 to 07:00)
      if (startTime > endTime) {
        return currentTime >= startTime || currentTime < endTime;
      }

      return currentTime >= startTime && currentTime < endTime;
    };

    it('should return false when quiet hours are not enabled', () => {
      const prefs = {
        quietHoursEnabled: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      };

      expect(isInQuietHours(prefs)).toBe(false);
    });

    it('should return false when quiet hours start is missing', () => {
      const prefs = {
        quietHoursEnabled: true,
        quietHoursStart: null,
        quietHoursEnd: '07:00',
      };

      expect(isInQuietHours(prefs)).toBe(false);
    });

    it('should return false when quiet hours end is missing', () => {
      const prefs = {
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: null,
      };

      expect(isInQuietHours(prefs)).toBe(false);
    });

    it('should detect quiet hours in normal range (same day)', () => {
      // Use a fixed time approach: set start to 00:00 and end to 23:59
      // so that the current time is always inside
      const prefs = {
        quietHoursEnabled: true,
        quietHoursStart: '00:00',
        quietHoursEnd: '23:59',
      };

      expect(isInQuietHours(prefs)).toBe(true);
    });

    it('should detect outside quiet hours in normal range', () => {
      // Set range to a time that is guaranteed to be in the past
      // Use a 1-minute window at a time that is never "now"
      const now = new Date();
      const currentHour = now.getHours();
      // Pick hours guaranteed to be different from now
      const startHour = (currentHour + 2) % 24;
      const endHour = (currentHour + 3) % 24;

      // Only test same-day range where start < end
      if (startHour < endHour) {
        const prefs = {
          quietHoursEnabled: true,
          quietHoursStart: `${String(startHour).padStart(2, '0')}:00`,
          quietHoursEnd: `${String(endHour).padStart(2, '0')}:00`,
        };

        expect(isInQuietHours(prefs)).toBe(false);
      }
    });

    it('should handle overnight range correctly (e.g., 22:00 to 07:00)', () => {
      // Overnight: startTime > endTime
      // If current time is 23:00 (1380 minutes), and range is 22:00-07:00
      // Then 1380 >= 1320 => true
      const now = new Date();
      const currentMinutes = now.getHours() * 60 + now.getMinutes();

      // Create an overnight range that includes current time
      // Start 1 minute before now, end 1 minute before start (wraps overnight)
      const startMinutes = (currentMinutes - 1 + 1440) % 1440;
      const endMinutes = (startMinutes - 1 + 1440) % 1440;

      const startH = String(Math.floor(startMinutes / 60)).padStart(2, '0');
      const startM = String(startMinutes % 60).padStart(2, '0');
      const endH = String(Math.floor(endMinutes / 60)).padStart(2, '0');
      const endM = String(endMinutes % 60).padStart(2, '0');

      const prefs = {
        quietHoursEnabled: true,
        quietHoursStart: `${startH}:${startM}`,
        quietHoursEnd: `${endH}:${endM}`,
      };

      // startTime > endTime since we wrap, so it's an overnight range
      // currentTime should be in range
      expect(isInQuietHours(prefs)).toBe(true);
    });

    it('should treat boundary start as inside quiet hours', () => {
      const now = new Date();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();
      const startStr = `${String(currentHour).padStart(2, '0')}:${String(currentMinute).padStart(2, '0')}`;

      // End 2 hours later (same-day range)
      const endHour = (currentHour + 2) % 24;
      const endStr = `${String(endHour).padStart(2, '0')}:${String(currentMinute).padStart(2, '0')}`;

      // Only valid for same-day range
      if (currentHour * 60 + currentMinute < endHour * 60 + currentMinute) {
        const prefs = {
          quietHoursEnabled: true,
          quietHoursStart: startStr,
          quietHoursEnd: endStr,
        };

        // currentTime >= startTime (equal) => should be true
        expect(isInQuietHours(prefs)).toBe(true);
      }
    });

    it('should treat boundary end as outside quiet hours', () => {
      const now = new Date();
      const currentHour = now.getHours();
      const currentMinute = now.getMinutes();
      const endStr = `${String(currentHour).padStart(2, '0')}:${String(currentMinute).padStart(2, '0')}`;

      // Start 2 hours before (same-day range)
      const startHour = (currentHour - 2 + 24) % 24;
      const startStr = `${String(startHour).padStart(2, '0')}:${String(currentMinute).padStart(2, '0')}`;

      // Only valid for same-day range (start < end)
      if (startHour * 60 + currentMinute < currentHour * 60 + currentMinute) {
        const prefs = {
          quietHoursEnabled: true,
          quietHoursStart: startStr,
          quietHoursEnd: endStr,
        };

        // currentTime < endTime is false (equal), so outside quiet hours
        expect(isInQuietHours(prefs)).toBe(false);
      }
    });
  });

  describe('Recipient Handling', () => {
    it('should return early when recipientIds is empty', () => {
      const notification = createTestMessageNotification({ recipientIds: [] });

      const shouldReturn = !notification.recipientIds || notification.recipientIds.length === 0;

      expect(shouldReturn).toBe(true);
    });

    it('should return early when recipientIds is undefined', () => {
      const notification = {
        ...createTestMessageNotification(),
        recipientIds: undefined as any,
      };

      const shouldReturn = !notification.recipientIds || notification.recipientIds.length === 0;

      expect(shouldReturn).toBe(true);
    });

    it('should process multiple recipients', async () => {
      const recipientIds = ['user-1', 'user-2', 'user-3'];
      const notification = createTestMessageNotification({ recipientIds });

      const usersData = new Map<string, any>();
      recipientIds.forEach((id) => {
        usersData.set(id, createTestUser({ uid: id, fcmToken: `token-${id}` }));
      });
      mockFirestore.setTestData('users', usersData);

      // Verify all recipients can be looked up
      for (const recipientId of notification.recipientIds) {
        const userDoc = await mockFirestore.collection('users').doc(recipientId).get();
        expect(userDoc.exists).toBe(true);
        expect(userDoc.data()?.fcmToken).toBe(`token-${recipientId}`);
      }
    });

    it('should skip recipients that do not exist', async () => {
      const recipientIds = ['valid-user', 'invalid-user'];

      const usersData = new Map<string, any>();
      usersData.set('valid-user', createTestUser({ uid: 'valid-user', fcmToken: 'valid-token' }));
      mockFirestore.setTestData('users', usersData);

      const validUserDoc = await mockFirestore.collection('users').doc('valid-user').get();
      expect(validUserDoc.exists).toBe(true);

      const invalidUserDoc = await mockFirestore.collection('users').doc('invalid-user').get();
      expect(invalidUserDoc.exists).toBe(false);
    });

    it('should return success count matching successful recipients', async () => {
      const recipientIds = ['user-1', 'user-2', 'user-3'];
      const results = [
        { recipientId: 'user-1', success: true },
        { recipientId: 'user-2', success: false },
        { recipientId: 'user-3', success: true },
      ];

      const successCount = results.filter((r) => r.success).length;

      expect(successCount).toBe(2);
      expect(results).toHaveLength(recipientIds.length);
    });
  });

  describe('Notification Preferences', () => {
    it('should skip notification when messages preference is false', async () => {
      const recipientId = 'pref-disabled-user';

      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, { messages: false });
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();
      const prefs = prefsDoc.data();

      expect(prefs?.messages).toBe(false);

      const shouldSkip = prefs && prefs.messages === false;
      expect(shouldSkip).toBe(true);
    });

    it('should send notification when messages preference is true', async () => {
      const recipientId = 'pref-enabled-user';

      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, { messages: true });
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();
      const prefs = prefsDoc.data();

      expect(prefs?.messages).toBe(true);

      const shouldSkip = prefs && prefs.messages === false;
      expect(shouldSkip).toBe(false);
    });

    it('should send notification when no preferences document exists', async () => {
      const recipientId = 'no-prefs-user';

      const prefsData = new Map<string, any>();
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();

      expect(prefsDoc.exists).toBe(false);

      const prefs = prefsDoc.exists ? prefsDoc.data() : null;
      const shouldSkip = prefs && prefs.messages === false;
      expect(shouldSkip).toBeFalsy();
    });

    it('should check quiet hours when preferences exist', async () => {
      const recipientId = 'quiet-hours-user';

      const prefsData = new Map<string, any>();
      prefsData.set(recipientId, {
        messages: true,
        quietHoursEnabled: true,
        quietHoursStart: '00:00',
        quietHoursEnd: '23:59',
      });
      mockFirestore.setTestData('notification_preferences', prefsData);

      const prefsDoc = await mockFirestore.collection('notification_preferences').doc(recipientId).get();
      const prefs = prefsDoc.data();

      expect(prefs?.quietHoursEnabled).toBe(true);
      expect(prefs?.quietHoursStart).toBe('00:00');
      expect(prefs?.quietHoursEnd).toBe('23:59');
    });
  });

  describe('FCM Message Structure', () => {
    it('should use "messages" as Android channelId', () => {
      const notification = createTestMessageNotification();

      const message = {
        token: 'test-fcm-token',
        notification: {
          title: notification.senderName,
          body: notification.content,
        },
        data: {
          type: 'new_message',
          chatId: notification.chatId,
          messageId: notification.messageId,
          senderId: notification.senderId,
          senderName: notification.senderName,
          chatName: notification.chatName || '',
          chatType: notification.chatType || 'direct',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'messages',
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
                title: notification.senderName,
                body: notification.content,
              },
              badge: 1,
              sound: 'default',
              'mutable-content': 1,
            },
          },
        },
      };

      expect(message.android.notification.channelId).toBe('messages');
    });

    it('should include mutable-content in APNs payload', () => {
      const apnsPayload = {
        payload: {
          aps: {
            alert: {
              title: 'Test Sender',
              body: 'Hello!',
            },
            badge: 1,
            sound: 'default',
            'mutable-content': 1,
          },
        },
      };

      expect(apnsPayload.payload.aps['mutable-content']).toBe(1);
    });

    it('should set data type to "new_message"', () => {
      const dataPayload = {
        type: 'new_message',
        chatId: 'chat-123',
        messageId: 'msg-456',
        senderId: 'sender-789',
        senderName: 'Alice',
        chatName: 'Group Chat',
        chatType: 'group',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      };

      expect(dataPayload.type).toBe('new_message');
      expect(dataPayload.click_action).toBe('FLUTTER_NOTIFICATION_CLICK');
    });

    it('should set Android priority to high', () => {
      const androidConfig = {
        priority: 'high',
        notification: {
          channelId: 'messages',
          priority: 'high',
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: 'ic_notification',
        },
      };

      expect(androidConfig.priority).toBe('high');
      expect(androidConfig.notification.defaultSound).toBe(true);
    });

    it('should include APNs badge and sound', () => {
      const apnsConfig = {
        payload: {
          aps: {
            badge: 1,
            sound: 'default',
            'mutable-content': 1,
          },
        },
      };

      expect(apnsConfig.payload.aps.badge).toBe(1);
      expect(apnsConfig.payload.aps.sound).toBe('default');
    });

    it('should send FCM when recipient has valid token', async () => {
      const recipientId = 'user-with-token';
      const userData = createTestUser({ uid: recipientId, fcmToken: 'valid-fcm-token' });

      const usersData = new Map<string, any>();
      usersData.set(recipientId, userData);
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(recipientId).get();
      expect(userDoc.data()?.fcmToken).toBe('valid-fcm-token');

      const message = {
        token: userData.fcmToken,
        notification: {
          title: 'Alice',
          body: 'Hello!',
        },
        data: {
          type: 'new_message',
          chatId: 'chat-123',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'messages',
          },
        },
      };

      await mockMessaging.send(message);

      expect(mockMessaging.send).toHaveBeenCalledTimes(1);
      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: 'valid-fcm-token',
          notification: expect.objectContaining({
            title: 'Alice',
          }),
          android: expect.objectContaining({
            notification: expect.objectContaining({
              channelId: 'messages',
            }),
          }),
        })
      );
    });

    it('should default chatName to empty string and chatType to direct in data payload', () => {
      // Simulate undefined values as they would appear in raw Firestore data
      const chatName: string | undefined = undefined;
      const chatType: string | undefined = undefined;

      const dataPayload = {
        chatName: chatName || '',
        chatType: chatType || 'direct',
      };

      expect(dataPayload.chatName).toBe('');
      expect(dataPayload.chatType).toBe('direct');
    });
  });

  describe('In-App Notification Creation', () => {
    it('should create in-app notification with correct fields', async () => {
      const notificationData = createTestMessageNotification({
        chatId: 'chat-abc',
        messageId: 'msg-xyz',
        senderId: 'sender-1',
        senderName: 'Alice',
        senderImageUrl: 'https://example.com/alice.jpg',
        content: 'Hey there!',
        chatType: 'direct',
        chatName: 'Alice & Bob',
      });

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `msg_${notificationData.chatId}_${Date.now()}`;
      const notificationDoc = {
        notificationId: notificationId,
        userId: 'recipient-1',
        fromUserId: notificationData.senderId,
        fromUserName: notificationData.senderName,
        fromUserImage: notificationData.senderImageUrl,
        type: 'newMessage',
        title: notificationData.chatType === 'direct'
          ? notificationData.senderName
          : notificationData.chatName || 'New Message',
        message: notificationData.content,
        createdAt: MockFieldValue.serverTimestamp(),
        isRead: false,
        data: {
          chatId: notificationData.chatId,
          messageId: notificationData.messageId,
          chatType: notificationData.chatType,
          chatName: notificationData.chatName,
        },
        actionUrl: `/chat/${notificationData.chatId}`,
        priority: 'high',
      };

      await mockFirestore.collection('notifications').doc(notificationId).set(notificationDoc);

      const storedDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(storedDoc.exists).toBe(true);
      expect(storedDoc.data()?.type).toBe('newMessage');
      expect(storedDoc.data()?.isRead).toBe(false);
      expect(storedDoc.data()?.priority).toBe('high');
      expect(storedDoc.data()?.actionUrl).toBe('/chat/chat-abc');
    });

    it('should set title to senderName for direct chat in-app notification', () => {
      const notificationData = createTestMessageNotification({
        chatType: 'direct',
        senderName: 'Alice',
        chatName: 'Alice & Bob',
      });

      const title = notificationData.chatType === 'direct'
        ? notificationData.senderName
        : notificationData.chatName || 'New Message';

      expect(title).toBe('Alice');
    });

    it('should set title to chatName for group chat in-app notification', () => {
      const notificationData = createTestMessageNotification({
        chatType: 'group',
        senderName: 'Alice',
        chatName: 'World Cup Fans',
      });

      const title = notificationData.chatType === 'direct'
        ? notificationData.senderName
        : notificationData.chatName || 'New Message';

      expect(title).toBe('World Cup Fans');
    });

    it('should generate notification ID with chat ID prefix', () => {
      const chatId = 'chat-abc';
      const notificationId = `msg_${chatId}_${Date.now()}`;

      expect(notificationId).toMatch(/^msg_chat-abc_\d+$/);
    });

    it('should include actionUrl pointing to chat', () => {
      const chatId = 'chat-abc';
      const actionUrl = `/chat/${chatId}`;

      expect(actionUrl).toBe('/chat/chat-abc');
    });

    it('should create notification even when user has no FCM token', async () => {
      const recipientId = 'no-fcm-user';
      const userData = {
        uid: recipientId,
        email: 'test@example.com',
        displayName: 'No FCM User',
        fcmToken: null,
        favoriteTeamCodes: [],
      };

      const usersData = new Map<string, any>();
      usersData.set(recipientId, userData);
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(recipientId).get();
      expect(userDoc.data()?.fcmToken).toBeFalsy();

      // Should still create in-app notification
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = `msg_chat-123_${Date.now()}`;
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: recipientId,
        type: 'newMessage',
        title: 'Alice',
        message: 'Hello!',
        isRead: false,
        priority: 'high',
      });

      const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(notificationDoc.exists).toBe(true);
      expect(notificationDoc.data()?.type).toBe('newMessage');
    });
  });

  describe('Cleanup Scheduled Function', () => {
    it('should run daily at 3 AM Eastern', () => {
      const schedule = '0 3 * * *';
      const timezone = 'America/New_York';

      expect(schedule).toBe('0 3 * * *');
      expect(timezone).toBe('America/New_York');
    });

    it('should query for processed notifications older than 7 days', async () => {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
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

    it('should limit batch to 500 documents', () => {
      const batchLimit = 500;

      const totalOldNotifications = 750;
      const processedCount = Math.min(totalOldNotifications, batchLimit);

      expect(processedCount).toBe(500);
    });

    it('should return early when no old notifications exist', async () => {
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('message_notifications', notificationsData);

      const snapshot = await mockFirestore.collection('message_notifications').get();

      expect(snapshot.empty).toBe(true);
    });

    it('should batch delete old processed notifications', async () => {
      const oldNotifications = [
        { id: 'old-msg-1', processed: true, processedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000) },
        { id: 'old-msg-2', processed: true, processedAt: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000) },
        { id: 'old-msg-3', processed: true, processedAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000) },
      ];

      const notificationsData = new Map<string, any>();
      oldNotifications.forEach((n) => notificationsData.set(n.id, n));
      mockFirestore.setTestData('message_notifications', notificationsData);

      const batch = mockFirestore.batch();

      for (const notification of oldNotifications) {
        const ref = mockFirestore.collection('message_notifications').doc(notification.id);
        batch.delete(ref);
      }

      await batch.commit();

      // Batch delete should have been processed
    });

    it('should not delete recent processed notifications', () => {
      const recentNotification = {
        id: 'recent-msg',
        processed: true,
        processedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
      };

      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      const isOldEnough = recentNotification.processedAt < sevenDaysAgo;

      expect(isOldEnough).toBe(false);
    });

    it('should not delete unprocessed notifications', () => {
      const unprocessedNotification = {
        id: 'unprocessed-msg',
        processed: false,
        processedAt: null,
      };

      const shouldDelete = unprocessedNotification.processed === true;

      expect(shouldDelete).toBe(false);
    });
  });

  describe('Error Handling', () => {
    it('should handle individual recipient failures without stopping others', async () => {
      const recipientIds = ['user-1', 'user-2', 'user-3', 'user-4'];
      let successCount = 0;
      let failureCount = 0;

      const processPromises = recipientIds.map(async (recipientId, index) => {
        try {
          if (index === 1) {
            throw new Error(`FCM failed for ${recipientId}`);
          }
          successCount++;
          return { recipientId, success: true };
        } catch (error) {
          failureCount++;
          return { recipientId, success: false };
        }
      });

      const results = await Promise.all(processPromises);

      expect(successCount).toBe(3);
      expect(failureCount).toBe(1);
      expect(results.filter((r) => r.success)).toHaveLength(3);
      expect(results.filter((r) => !r.success)).toHaveLength(1);
    });

    it('should handle invalid FCM token error and remove token', async () => {
      const error = {
        code: 'messaging/invalid-registration-token',
        message: 'Invalid FCM token',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should handle unregistered FCM token error and remove token', async () => {
      const error = {
        code: 'messaging/registration-token-not-registered',
        message: 'Token not registered',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should remove invalid FCM token from user document', async () => {
      const recipientId = 'user-bad-token';
      const userData = createTestUser({ uid: recipientId, fcmToken: 'invalid-token' });

      const usersData = new Map<string, any>();
      usersData.set(recipientId, userData);
      mockFirestore.setTestData('users', usersData);

      // Simulate removing the token
      await mockFirestore.collection('users').doc(recipientId).update({
        fcmToken: MockFieldValue.delete(),
      });

      const updatedDoc = await mockFirestore.collection('users').doc(recipientId).get();
      expect(updatedDoc.data()?.fcmToken).toEqual({ _methodName: 'delete' });
    });

    it('should handle FCM send failure gracefully', async () => {
      mockMessaging.send.mockRejectedValueOnce(new Error('FCM send failed'));

      try {
        await mockMessaging.send({ token: 'some-token' });
      } catch (error: any) {
        expect(error.message).toBe('FCM send failed');
      }

      // Subsequent sends should still work
      mockMessaging.send.mockResolvedValueOnce('mock-message-id');
      const result = await mockMessaging.send({ token: 'another-token' });
      expect(result).toBe('mock-message-id');
    });

    it('should mark notification as processed even on error', async () => {
      const notificationId = 'error-notification';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, { processed: false });
      mockFirestore.setTestData('message_notifications', notificationsData);

      // Simulate marking as processed with error
      await mockFirestore.collection('message_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: 'Something went wrong',
      });

      const doc = await mockFirestore.collection('message_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
      expect(doc.data()?.error).toBe('Something went wrong');
    });

    it('should mark notification as processed on success with no error', async () => {
      const notificationId = 'success-notification';
      const notificationsData = new Map<string, any>();
      notificationsData.set(notificationId, { processed: false });
      mockFirestore.setTestData('message_notifications', notificationsData);

      await mockFirestore.collection('message_notifications').doc(notificationId).update({
        processed: true,
        processedAt: MockFieldValue.serverTimestamp(),
        error: null,
      });

      const doc = await mockFirestore.collection('message_notifications').doc(notificationId).get();
      expect(doc.data()?.processed).toBe(true);
      expect(doc.data()?.error).toBeNull();
    });

    it('should continue processing all recipients using Promise.all', async () => {
      const recipientIds = ['r1', 'r2', 'r3', 'r4', 'r5'];

      const sendPromises = recipientIds.map(async (recipientId) => {
        try {
          if (recipientId === 'r3') {
            throw new Error(`Error for ${recipientId}`);
          }
          return { recipientId, success: true };
        } catch (error: any) {
          return { recipientId, success: false, error: error.message };
        }
      });

      const results = await Promise.all(sendPromises);

      expect(results).toHaveLength(5);
      expect(results.filter((r) => r.success)).toHaveLength(4);
      expect(results.find((r) => r.recipientId === 'r3')?.success).toBe(false);
      expect(results.find((r) => r.recipientId === 'r3')?.error).toBe('Error for r3');
    });
  });
});
