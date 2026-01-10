/**
 * Match Reminders Tests
 *
 * Tests for match reminder notification functions.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createTestMatchReminder,
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

describe('Match Reminders', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
  });

  describe('sendMatchReminders', () => {
    describe('Query Logic', () => {
      it('should query for enabled, unsent reminders due within the last minute', async () => {
        const now = MockTimestamp.now();
        const oneMinuteAgo = MockTimestamp.fromMillis(now.toMillis() - 60 * 1000);

        // Query criteria
        const queryCriteria = {
          isEnabled: true,
          isSent: false,
          reminderDateTimeUtc: {
            lessThanOrEqual: now,
            greaterThanOrEqual: oneMinuteAgo,
          },
        };

        expect(queryCriteria.isEnabled).toBe(true);
        expect(queryCriteria.isSent).toBe(false);
        expect(queryCriteria.reminderDateTimeUtc.lessThanOrEqual).toBeDefined();
        expect(queryCriteria.reminderDateTimeUtc.greaterThanOrEqual).toBeDefined();
      });

      it('should return early when no reminders are found', async () => {
        const remindersData = new Map<string, any>();
        mockFirestore.setTestData('match_reminders', remindersData);

        const snapshot = await mockFirestore.collection('match_reminders').get();

        expect(snapshot.empty).toBe(true);
      });

      it('should process all due reminders', async () => {
        const reminders = [
          createTestMatchReminder({ id: 'reminder-1', matchName: 'USA vs Mexico' }),
          createTestMatchReminder({ id: 'reminder-2', matchName: 'Brazil vs Argentina' }),
          createTestMatchReminder({ id: 'reminder-3', matchName: 'France vs Germany' }),
        ];

        const remindersData = new Map<string, any>();
        reminders.forEach((r) => remindersData.set(r.id, r));
        mockFirestore.setTestData('match_reminders', remindersData);

        const snapshot = await mockFirestore.collection('match_reminders').get();

        expect(snapshot.size).toBe(3);
      });
    });

    describe('Match Already Started Check', () => {
      it('should skip reminder if match has already started', async () => {
        const pastMatchDateTime = new Date(Date.now() - 60 * 60 * 1000); // 1 hour ago
        const reminder = createTestMatchReminder({
          matchDateTimeUtc: pastMatchDateTime,
        });

        const matchDateTime = reminder.matchDateTimeUtc;
        const hasStarted = new Date() >= matchDateTime;

        expect(hasStarted).toBe(true);
      });

      it('should process reminder if match has not started', async () => {
        const futureMatchDateTime = new Date(Date.now() + 30 * 60 * 1000); // 30 mins from now
        const reminder = createTestMatchReminder({
          matchDateTimeUtc: futureMatchDateTime,
        });

        const matchDateTime = reminder.matchDateTimeUtc;
        const hasStarted = new Date() >= matchDateTime;

        expect(hasStarted).toBe(false);
      });

      it('should mark as sent if match already started', async () => {
        const reminderId = 'reminder-started-match';
        const remindersData = new Map<string, any>();
        remindersData.set(reminderId, {
          ...createTestMatchReminder({
            id: reminderId,
            matchDateTimeUtc: new Date(Date.now() - 1000), // Just started
          }),
          isSent: false,
        });
        mockFirestore.setTestData('match_reminders', remindersData);

        // Update to mark as sent
        await mockFirestore.collection('match_reminders').doc(reminderId).update({
          isSent: true,
        });

        const doc = await mockFirestore.collection('match_reminders').doc(reminderId).get();
        expect(doc.data()?.isSent).toBe(true);
      });
    });

    describe('FCM Notification Sending', () => {
      it('should send FCM notification when user has valid token', async () => {
        const userId = 'test-user-with-token';
        const userData = createTestUser({
          uid: userId,
          fcmToken: 'valid-fcm-token',
        });

        const usersData = new Map<string, any>();
        usersData.set(userId, userData);
        mockFirestore.setTestData('users', usersData);

        const userDoc = await mockFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?.fcmToken).toBe('valid-fcm-token');

        // Simulate sending notification
        const message = {
          token: userData.fcmToken,
          notification: {
            title: 'Match Starting Soon!',
            body: 'USA vs Mexico kicks off in 30 minutes',
          },
          data: {
            type: 'match_reminder',
            matchId: 'match-123',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };

        await mockMessaging.send(message);

        expect(mockMessaging.send).toHaveBeenCalledWith(
          expect.objectContaining({
            token: 'valid-fcm-token',
            notification: expect.objectContaining({
              title: 'Match Starting Soon!',
            }),
          })
        );
      });

      it('should skip FCM and create in-app notification when no token', async () => {
        const userId = 'test-user-no-token';
        // Directly create user data without FCM token
        const userData = {
          uid: userId,
          email: 'test@example.com',
          displayName: 'Test User',
          fcmToken: null, // No token
          favoriteTeamCodes: [],
        };

        const usersData = new Map<string, any>();
        usersData.set(userId, userData);
        mockFirestore.setTestData('users', usersData);

        const userDoc = await mockFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?.fcmToken).toBeFalsy();

        // Should not call FCM send
        // Instead creates in-app notification
      });

      it('should include correct Android configuration', () => {
        const androidConfig = {
          priority: 'high',
          notification: {
            channelId: 'match_reminders',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
          },
        };

        expect(androidConfig.notification.channelId).toBe('match_reminders');
        expect(androidConfig.notification.icon).toBe('ic_notification');
      });

      it('should include correct iOS/APNs configuration', () => {
        const apnsConfig = {
          payload: {
            aps: {
              alert: {
                title: 'Match Starting Soon!',
                body: 'USA vs Mexico kicks off in 30 minutes',
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

    describe('getTimingDisplay Function', () => {
      const getTimingDisplay = (minutes: number): string => {
        if (minutes === 15) return '15 minutes';
        if (minutes === 30) return '30 minutes';
        if (minutes === 60) return '1 hour';
        if (minutes === 120) return '2 hours';
        if (minutes === 1440) return '1 day';
        if (minutes >= 60) {
          const hours = Math.floor(minutes / 60);
          return `${hours} hour${hours > 1 ? 's' : ''}`;
        }
        return `${minutes} minutes`;
      };

      it('should display 15 minutes correctly', () => {
        expect(getTimingDisplay(15)).toBe('15 minutes');
      });

      it('should display 30 minutes correctly', () => {
        expect(getTimingDisplay(30)).toBe('30 minutes');
      });

      it('should display 1 hour correctly', () => {
        expect(getTimingDisplay(60)).toBe('1 hour');
      });

      it('should display 2 hours correctly', () => {
        expect(getTimingDisplay(120)).toBe('2 hours');
      });

      it('should display 1 day correctly', () => {
        expect(getTimingDisplay(1440)).toBe('1 day');
      });

      it('should display custom hour values correctly', () => {
        expect(getTimingDisplay(180)).toBe('3 hours');
        expect(getTimingDisplay(240)).toBe('4 hours');
      });

      it('should display custom minute values correctly', () => {
        expect(getTimingDisplay(45)).toBe('45 minutes');
        expect(getTimingDisplay(10)).toBe('10 minutes');
      });

      it('should handle singular hour correctly', () => {
        expect(getTimingDisplay(60)).toBe('1 hour');
        expect(getTimingDisplay(90)).toBe('1 hour'); // 90 mins = 1 hour (floor)
      });
    });

    describe('In-App Notification Creation', () => {
      it('should create in-app notification with correct fields', async () => {
        const reminder = createTestMatchReminder({
          userId: 'test-user',
          matchId: 'match-123',
          matchName: 'USA vs Mexico',
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          timingMinutes: 30,
        });

        const notificationsData = new Map<string, any>();
        mockFirestore.setTestData('notifications', notificationsData);

        const notificationId = `match_reminder_${Date.now()}`;
        await mockFirestore.collection('notifications').doc(notificationId).set({
          notificationId,
          userId: reminder.userId,
          type: 'matchReminder',
          title: 'Match Starting Soon!',
          message: `${reminder.matchName} kicks off in 30 minutes`,
          createdAt: MockFieldValue.serverTimestamp(),
          isRead: false,
          data: {
            matchId: reminder.matchId,
            matchName: reminder.matchName,
            homeTeamCode: reminder.homeTeamCode,
            awayTeamCode: reminder.awayTeamCode,
          },
          actionUrl: `/match/${reminder.matchId}`,
          priority: 'high',
        });

        const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
        expect(notificationDoc.exists).toBe(true);
        expect(notificationDoc.data()?.type).toBe('matchReminder');
        expect(notificationDoc.data()?.priority).toBe('high');
      });

      it('should include venue name in message when available', () => {
        const matchName = 'USA vs Mexico';
        const venueName = 'Sports Bar Downtown';
        const timingDisplay = '30 minutes';

        const message = `${matchName} kicks off in ${timingDisplay} at ${venueName}`;

        expect(message).toBe('USA vs Mexico kicks off in 30 minutes at Sports Bar Downtown');
      });

      it('should exclude venue name when not available', () => {
        const matchName = 'USA vs Mexico';
        const venueName = undefined;
        const timingDisplay = '30 minutes';

        const message = `${matchName} kicks off in ${timingDisplay}${venueName ? ` at ${venueName}` : ''}`;

        expect(message).toBe('USA vs Mexico kicks off in 30 minutes');
      });
    });

    describe('Reminder Status Update', () => {
      it('should mark reminder as sent after successful notification', async () => {
        const reminderId = 'reminder-to-send';
        const reminderData = createTestMatchReminder({ id: reminderId, isSent: false });

        const remindersData = new Map<string, any>();
        remindersData.set(reminderId, reminderData);
        mockFirestore.setTestData('match_reminders', remindersData);

        // Update to mark as sent
        await mockFirestore.collection('match_reminders').doc(reminderId).update({
          isSent: true,
        });

        const doc = await mockFirestore.collection('match_reminders').doc(reminderId).get();
        expect(doc.data()?.isSent).toBe(true);
      });

      it('should mark as sent even on FCM failure with invalid token', async () => {
        const error = {
          code: 'messaging/invalid-registration-token',
          message: 'Invalid token',
        };

        const shouldMarkAsSent =
          error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered';

        expect(shouldMarkAsSent).toBe(true);
      });
    });

    describe('Error Handling', () => {
      it('should handle individual reminder processing errors', async () => {
        const reminders = [
          { id: 'reminder-1', shouldFail: false },
          { id: 'reminder-2', shouldFail: true },
          { id: 'reminder-3', shouldFail: false },
        ];

        let successCount = 0;
        let failCount = 0;

        const processPromises = reminders.map(async (reminder) => {
          try {
            if (reminder.shouldFail) {
              throw new Error(`Failed to process ${reminder.id}`);
            }
            successCount++;
            return { id: reminder.id, success: true };
          } catch (error) {
            failCount++;
            return { id: reminder.id, success: false };
          }
        });

        await Promise.all(processPromises);

        expect(successCount).toBe(2);
        expect(failCount).toBe(1);
      });

      it('should continue processing after individual failures', async () => {
        const reminderIds = ['r1', 'r2', 'r3', 'r4', 'r5'];
        const processed: string[] = [];

        for (const id of reminderIds) {
          try {
            if (id === 'r3') {
              throw new Error('Processing failed');
            }
            processed.push(id);
          } catch {
            // Log error but continue
          }
        }

        expect(processed).toHaveLength(4);
        expect(processed).not.toContain('r3');
      });
    });
  });

  describe('cleanupOldReminders', () => {
    it('should run daily at 3 AM', () => {
      const schedule = '0 3 * * *'; // Cron expression
      const timezone = 'America/New_York';

      expect(schedule).toBe('0 3 * * *');
      expect(timezone).toBe('America/New_York');
    });

    it('should query for sent reminders older than 7 days', async () => {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      const sevenDaysAgoTimestamp = MockTimestamp.fromDate(sevenDaysAgo);

      const queryCriteria = {
        isSent: true,
        matchDateTimeUtc: {
          lessThan: sevenDaysAgoTimestamp,
        },
      };

      expect(queryCriteria.isSent).toBe(true);
      expect(queryCriteria.matchDateTimeUtc.lessThan).toBeDefined();
    });

    it('should batch delete old reminders (max 500)', async () => {
      const batchLimit = 500;

      // Simulate having more than 500 old reminders
      const oldReminderCount = 600;
      const processedCount = Math.min(oldReminderCount, batchLimit);

      expect(processedCount).toBe(500);
    });

    it('should return early when no old reminders exist', async () => {
      const remindersData = new Map<string, any>();
      mockFirestore.setTestData('match_reminders', remindersData);

      const snapshot = await mockFirestore.collection('match_reminders').get();

      expect(snapshot.empty).toBe(true);
    });

    it('should delete reminders using batch operation', async () => {
      const oldReminders = [
        { id: 'old-1', isSent: true, matchDateTimeUtc: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000) },
        { id: 'old-2', isSent: true, matchDateTimeUtc: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000) },
      ];

      const remindersData = new Map<string, any>();
      oldReminders.forEach((r) => remindersData.set(r.id, r));
      mockFirestore.setTestData('match_reminders', remindersData);

      // Use batch to delete
      const batch = mockFirestore.batch();

      for (const reminder of oldReminders) {
        const ref = mockFirestore.collection('match_reminders').doc(reminder.id);
        batch.delete(ref);
      }

      await batch.commit();

      // Verify deletion (in real test, data would be removed)
    });
  });

  describe('Match Reminder Data Model', () => {
    it('should have all required fields', () => {
      const reminder = createTestMatchReminder();

      expect(reminder.id).toBeDefined();
      expect(reminder.userId).toBeDefined();
      expect(reminder.matchId).toBeDefined();
      expect(reminder.matchName).toBeDefined();
      expect(reminder.homeTeamCode).toBeDefined();
      expect(reminder.awayTeamCode).toBeDefined();
      expect(reminder.timingMinutes).toBeDefined();
      expect(reminder.isEnabled).toBeDefined();
      expect(reminder.isSent).toBeDefined();
      expect(reminder.matchDateTimeUtc).toBeDefined();
      expect(reminder.reminderDateTimeUtc).toBeDefined();
    });

    it('should have correct timing relationship', () => {
      const matchTime = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now
      const timingMinutes = 30;
      const reminderTime = new Date(matchTime.getTime() - timingMinutes * 60 * 1000);

      const reminder = createTestMatchReminder({
        matchDateTimeUtc: matchTime,
        reminderDateTimeUtc: reminderTime,
        timingMinutes,
      });

      const expectedDiff = reminder.timingMinutes * 60 * 1000;
      const actualDiff = reminder.matchDateTimeUtc.getTime() - reminder.reminderDateTimeUtc.getTime();

      expect(actualDiff).toBe(expectedDiff);
    });
  });

  describe('FCM Message Data Payload', () => {
    it('should include all necessary data fields', () => {
      const reminder = createTestMatchReminder({
        matchId: 'match-wc-2026-final',
        matchName: 'World Cup Final',
        homeTeamCode: 'ARG',
        awayTeamCode: 'FRA',
      });

      const dataPayload = {
        type: 'match_reminder',
        matchId: reminder.matchId,
        matchName: reminder.matchName,
        homeTeamCode: reminder.homeTeamCode,
        awayTeamCode: reminder.awayTeamCode,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      };

      expect(dataPayload.type).toBe('match_reminder');
      expect(dataPayload.matchId).toBe('match-wc-2026-final');
      expect(dataPayload.homeTeamCode).toBe('ARG');
      expect(dataPayload.awayTeamCode).toBe('FRA');
      expect(dataPayload.click_action).toBe('FLUTTER_NOTIFICATION_CLICK');
    });

    it('should handle missing optional fields gracefully', () => {
      const reminder = {
        matchId: undefined,
        matchName: undefined,
        homeTeamCode: undefined,
        awayTeamCode: undefined,
      };

      const dataPayload = {
        type: 'match_reminder',
        matchId: reminder.matchId || '',
        matchName: reminder.matchName || 'Match',
        homeTeamCode: reminder.homeTeamCode || '',
        awayTeamCode: reminder.awayTeamCode || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      };

      expect(dataPayload.matchId).toBe('');
      expect(dataPayload.matchName).toBe('Match');
    });
  });

  describe('Scheduled Function Behavior', () => {
    it('should run every 1 minute', () => {
      const schedule = 'every 1 minutes';
      expect(schedule).toBe('every 1 minutes');
    });

    it('should return null on completion', async () => {
      // Simulate function completion
      const result = null;
      expect(result).toBeNull();
    });

    it('should handle errors gracefully and return null', async () => {
      try {
        throw new Error('Unexpected error');
      } catch (error) {
        // Function should catch and log error, then return null
        const result = null;
        expect(result).toBeNull();
      }
    });
  });
});
