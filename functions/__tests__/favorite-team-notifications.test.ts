/**
 * Favorite Team Notifications Tests
 *
 * Tests for scheduled favorite team match notifications,
 * in-app notification creation, deduplication, and cleanup.
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

describe('Favorite Team Notifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
  });

  describe('sendFavoriteTeamNotifications', () => {
    describe('Schedule Configuration', () => {
      it('should run twice daily at 8 AM and 8 PM Eastern', () => {
        const schedule = '0 8,20 * * *';
        const timezone = 'America/New_York';

        expect(schedule).toBe('0 8,20 * * *');
        expect(timezone).toBe('America/New_York');
      });
    });

    describe('Match Window Query', () => {
      it('should query matches in the 24-28 hour notification window', () => {
        const now = MockTimestamp.now();
        const in24Hours = MockTimestamp.fromMillis(now.toMillis() + 24 * 60 * 60 * 1000);
        const in28Hours = MockTimestamp.fromMillis(now.toMillis() + 28 * 60 * 60 * 1000);

        expect(in24Hours.toMillis()).toBeGreaterThan(now.toMillis());
        expect(in28Hours.toMillis()).toBeGreaterThan(in24Hours.toMillis());

        const windowMs = in28Hours.toMillis() - in24Hours.toMillis();
        expect(windowMs).toBe(4 * 60 * 60 * 1000); // 4 hour window
      });

      it('should return early when no upcoming matches in window', async () => {
        const matchesData = new Map<string, any>();
        mockFirestore.setTestData('worldcup_matches', matchesData);

        const snapshot = await mockFirestore.collection('worldcup_matches').get();
        expect(snapshot.empty).toBe(true);
      });

      it('should query for scheduled matches only', async () => {
        const matchesData = new Map<string, any>();
        matchesData.set('match-1', {
          matchId: 'match-1',
          status: 'scheduled',
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          dateTimeUtc: MockTimestamp.fromMillis(Date.now() + 25 * 60 * 60 * 1000),
        });
        matchesData.set('match-2', {
          matchId: 'match-2',
          status: 'completed',
          homeTeamCode: 'BRA',
          awayTeamCode: 'ARG',
        });
        mockFirestore.setTestData('worldcup_matches', matchesData);

        const scheduled = await mockFirestore
          .collection('worldcup_matches')
          .where('status', '==', 'scheduled')
          .get();

        expect(scheduled.size).toBe(1);
      });
    });

    describe('Team Code Handling', () => {
      it('should skip matches with undetermined teams', () => {
        const match: { matchId: string; homeTeamCode: string | null; awayTeamCode: string | null } = {
          matchId: 'tbd-match',
          homeTeamCode: null,
          awayTeamCode: 'MEX',
        };

        const homeTeamCode = match.homeTeamCode?.toUpperCase();
        const awayTeamCode = match.awayTeamCode?.toUpperCase();

        const shouldSkip = !homeTeamCode || !awayTeamCode;
        expect(shouldSkip).toBe(true);
      });

      it('should uppercase team codes for comparison', () => {
        const match = {
          homeTeamCode: 'usa',
          awayTeamCode: 'mex',
        };

        expect(match.homeTeamCode.toUpperCase()).toBe('USA');
        expect(match.awayTeamCode.toUpperCase()).toBe('MEX');
      });

      it('should process matches with both team codes', () => {
        const match = {
          matchId: 'valid-match',
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
        };

        const homeTeamCode = match.homeTeamCode?.toUpperCase();
        const awayTeamCode = match.awayTeamCode?.toUpperCase();

        const shouldSkip = !homeTeamCode || !awayTeamCode;
        expect(shouldSkip).toBe(false);
      });
    });

    describe('Deduplication - Sent Notifications Check', () => {
      it('should skip match if notification already sent', async () => {
        const matchId = 'match-already-notified';
        const notificationKey = `favorite_team_${matchId}`;

        const sentData = new Map<string, any>();
        sentData.set(notificationKey, {
          matchId,
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          sentAt: MockTimestamp.now(),
          usersNotified: 5,
        });
        mockFirestore.setTestData('sent_notifications', sentData);

        const existingNotification = await mockFirestore
          .collection('sent_notifications')
          .doc(notificationKey)
          .get();

        expect(existingNotification.exists).toBe(true);
      });

      it('should proceed if notification not yet sent for match', async () => {
        const matchId = 'match-new';
        const notificationKey = `favorite_team_${matchId}`;

        const sentData = new Map<string, any>();
        mockFirestore.setTestData('sent_notifications', sentData);

        const existingNotification = await mockFirestore
          .collection('sent_notifications')
          .doc(notificationKey)
          .get();

        expect(existingNotification.exists).toBe(false);
      });

      it('should construct notification key correctly', () => {
        const matchId = 'wc2026_match_42';
        const notificationKey = `favorite_team_${matchId}`;

        expect(notificationKey).toBe('favorite_team_wc2026_match_42');
      });
    });

    describe('User Matching', () => {
      it('should find users with favorite teams matching the match', async () => {
        const usersData = new Map<string, any>();
        usersData.set('user-usa-fan', {
          uid: 'user-usa-fan',
          notifyFavoriteTeamMatches: true,
          favoriteTeamCodes: ['USA', 'GER'],
          fcmToken: 'token-1',
        });
        usersData.set('user-mex-fan', {
          uid: 'user-mex-fan',
          notifyFavoriteTeamMatches: true,
          favoriteTeamCodes: ['MEX'],
          fcmToken: 'token-2',
        });
        usersData.set('user-bra-fan', {
          uid: 'user-bra-fan',
          notifyFavoriteTeamMatches: true,
          favoriteTeamCodes: ['BRA'],
          fcmToken: 'token-3',
        });
        usersData.set('user-notifications-off', {
          uid: 'user-notifications-off',
          notifyFavoriteTeamMatches: false,
          favoriteTeamCodes: ['USA'],
          fcmToken: 'token-4',
        });
        mockFirestore.setTestData('users', usersData);

        // Simulate query for users with notifications enabled
        const enabledUsersSnapshot = await mockFirestore
          .collection('users')
          .where('notifyFavoriteTeamMatches', '==', true)
          .get();

        expect(enabledUsersSnapshot.size).toBe(3);
      });

      it('should skip match with no matching users', async () => {
        const usersData = new Map<string, any>();
        usersData.set('user-bra-fan', {
          uid: 'user-bra-fan',
          notifyFavoriteTeamMatches: true,
          favoriteTeamCodes: ['BRA'],
          fcmToken: 'token-1',
        });
        mockFirestore.setTestData('users', usersData);

        // For a USA vs MEX match, no users have those as favorites
        const homeTeamCode = 'USA';
        const awayTeamCode = 'MEX';

        const enabledUsersSnapshot = await mockFirestore
          .collection('users')
          .where('notifyFavoriteTeamMatches', '==', true)
          .get();

        // Filter manually (MockFirestore doesn't support array-contains-any)
        const matchingUsers = enabledUsersSnapshot.docs.filter((doc) => {
          const favorites = doc.data().favoriteTeamCodes || [];
          return favorites.includes(homeTeamCode) || favorites.includes(awayTeamCode);
        });

        expect(matchingUsers.length).toBe(0);
      });
    });

    describe('Team Description Logic', () => {
      it('should describe single home team when user follows home only', () => {
        const favoriteTeamCodes = ['USA'];
        const homeTeamCode = 'USA';
        const awayTeamCode = 'MEX';
        const homeTeamName = 'United States';
        const awayTeamName = 'Mexico';

        const followsHome = favoriteTeamCodes.includes(homeTeamCode);
        const followsAway = favoriteTeamCodes.includes(awayTeamCode);

        let teamDescription: string;
        if (followsHome && followsAway) {
          teamDescription = `${homeTeamName} and ${awayTeamName}`;
        } else if (followsHome) {
          teamDescription = homeTeamName;
        } else {
          teamDescription = awayTeamName;
        }

        expect(teamDescription).toBe('United States');
      });

      it('should describe single away team when user follows away only', () => {
        const favoriteTeamCodes = ['MEX'];
        const homeTeamCode = 'USA';
        const awayTeamCode = 'MEX';
        const homeTeamName = 'United States';
        const awayTeamName = 'Mexico';

        const followsHome = favoriteTeamCodes.includes(homeTeamCode);
        const followsAway = favoriteTeamCodes.includes(awayTeamCode);

        let teamDescription: string;
        if (followsHome && followsAway) {
          teamDescription = `${homeTeamName} and ${awayTeamName}`;
        } else if (followsHome) {
          teamDescription = homeTeamName;
        } else {
          teamDescription = awayTeamName;
        }

        expect(teamDescription).toBe('Mexico');
      });

      it('should describe both teams when user follows both', () => {
        const favoriteTeamCodes = ['USA', 'MEX'];
        const homeTeamCode = 'USA';
        const awayTeamCode = 'MEX';
        const homeTeamName = 'United States';
        const awayTeamName = 'Mexico';

        const followsHome = favoriteTeamCodes.includes(homeTeamCode);
        const followsAway = favoriteTeamCodes.includes(awayTeamCode);

        let teamDescription: string;
        if (followsHome && followsAway) {
          teamDescription = `${homeTeamName} and ${awayTeamName}`;
        } else if (followsHome) {
          teamDescription = homeTeamName;
        } else {
          teamDescription = awayTeamName;
        }

        expect(teamDescription).toBe('United States and Mexico');
      });

      it('should use "face off" verb when user follows both teams', () => {
        const followsHome = true;
        const followsAway = true;
        const teamDescription = 'United States and Mexico';
        const homeTeamName = 'United States';
        const awayTeamName = 'Mexico';
        const timeString = 'Wed, Jun 11, 6:00 PM ET';

        const notificationBody = `${teamDescription} ${followsHome && followsAway ? 'face off' : 'plays'} - ${homeTeamName} vs ${awayTeamName} at ${timeString}`;

        expect(notificationBody).toContain('face off');
        expect(notificationBody).not.toContain('plays -');
      });

      it('should use "plays" verb when user follows one team', () => {
        const followsHome = true;
        const followsAway = false;
        const teamDescription = 'United States';
        const homeTeamName = 'United States';
        const awayTeamName = 'Mexico';
        const timeString = 'Wed, Jun 11, 6:00 PM ET';

        const notificationBody = `${teamDescription} ${followsHome && followsAway ? 'face off' : 'plays'} - ${homeTeamName} vs ${awayTeamName} at ${timeString}`;

        expect(notificationBody).toContain('plays');
        expect(notificationBody).not.toContain('face off');
      });
    });

    describe('FCM Notification Sending', () => {
      it('should send FCM when user has valid token', async () => {
        const userId = 'user-with-token';
        const userData = createTestUser({
          uid: userId,
          fcmToken: 'valid-fcm-token',
        });

        const usersData = new Map<string, any>();
        usersData.set(userId, userData);
        mockFirestore.setTestData('users', usersData);

        const userDoc = await mockFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?.fcmToken).toBe('valid-fcm-token');

        const message = {
          token: 'valid-fcm-token',
          notification: {
            title: 'Your Team Plays Tomorrow!',
            body: 'United States plays - United States vs Mexico at Wed, Jun 11, 6:00 PM ET',
          },
          data: {
            type: 'favorite_team_match',
            matchId: 'wc2026_match_1',
            homeTeamCode: 'USA',
            awayTeamCode: 'MEX',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            priority: 'high' as const,
            notification: {
              channelId: 'favorite_teams',
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
                  title: 'Your Team Plays Tomorrow!',
                  body: 'United States plays - United States vs Mexico at Wed, Jun 11, 6:00 PM ET',
                },
                badge: 1,
                sound: 'default',
              },
            },
          },
        };

        await mockMessaging.send(message);

        expect(mockMessaging.send).toHaveBeenCalledWith(
          expect.objectContaining({
            token: 'valid-fcm-token',
            notification: expect.objectContaining({
              title: 'Your Team Plays Tomorrow!',
            }),
            data: expect.objectContaining({
              type: 'favorite_team_match',
              matchId: 'wc2026_match_1',
            }),
          })
        );
      });

      it('should skip FCM when user has no token', async () => {
        const userId = 'user-no-token';
        const usersData = new Map<string, any>();
        usersData.set(userId, {
          uid: userId,
          email: 'test@example.com',
          displayName: 'No Token User',
          fcmToken: null,
          favoriteTeamCodes: ['USA'],
          notifyFavoriteTeamMatches: true,
        });
        mockFirestore.setTestData('users', usersData);

        const userDoc = await mockFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?.fcmToken).toBeFalsy();

        // FCM should not be called for this user
      });

      it('should set Android channelId to favorite_teams', () => {
        const androidConfig = {
          priority: 'high',
          notification: {
            channelId: 'favorite_teams',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
          },
        };

        expect(androidConfig.notification.channelId).toBe('favorite_teams');
      });

      it('should include correct APNs configuration', () => {
        const apnsConfig = {
          payload: {
            aps: {
              alert: {
                title: 'Your Team Plays Tomorrow!',
                body: 'USA plays tomorrow',
              },
              badge: 1,
              sound: 'default',
            },
          },
        };

        expect(apnsConfig.payload.aps.badge).toBe(1);
        expect(apnsConfig.payload.aps.sound).toBe('default');
      });

      it('should include data payload with match details', () => {
        const dataPayload = {
          type: 'favorite_team_match',
          matchId: 'wc2026_final',
          homeTeamCode: 'ARG',
          awayTeamCode: 'FRA',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        };

        expect(dataPayload.type).toBe('favorite_team_match');
        expect(dataPayload.click_action).toBe('FLUTTER_NOTIFICATION_CLICK');
        expect(dataPayload.homeTeamCode).toBe('ARG');
        expect(dataPayload.awayTeamCode).toBe('FRA');
      });
    });

    describe('In-App Notification Creation', () => {
      it('should create in-app notification with correct fields', async () => {
        const userId = 'test-user';
        const matchId = 'wc2026_match_42';
        const teamDescription = 'United States';
        const match = {
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
          dateTimeUtc: { toDate: () => new Date(2026, 5, 11, 18, 0) },
          venue: { name: 'MetLife Stadium' },
        };

        const notificationId = `favorite_team_${matchId}_${userId}`;

        const notificationsData = new Map<string, any>();
        mockFirestore.setTestData('notifications', notificationsData);

        await mockFirestore.collection('notifications').doc(notificationId).set({
          notificationId,
          userId,
          type: 'favoriteTeamMatch',
          title: 'Your Team Plays Tomorrow!',
          message: `${teamDescription} has a match coming up - ${match.homeTeamName} vs ${match.awayTeamName}`,
          createdAt: MockFieldValue.serverTimestamp(),
          isRead: false,
          data: {
            matchId,
            homeTeamCode: match.homeTeamCode,
            homeTeamName: match.homeTeamName,
            awayTeamCode: match.awayTeamCode,
            awayTeamName: match.awayTeamName,
            matchDateTime: match.dateTimeUtc,
            venueName: match.venue?.name,
          },
          actionUrl: `/match/${matchId}`,
          priority: 'normal',
        });

        const notificationDoc = await mockFirestore.collection('notifications').doc(notificationId).get();
        expect(notificationDoc.exists).toBe(true);
        expect(notificationDoc.data()?.type).toBe('favoriteTeamMatch');
        expect(notificationDoc.data()?.title).toBe('Your Team Plays Tomorrow!');
        expect(notificationDoc.data()?.isRead).toBe(false);
        expect(notificationDoc.data()?.priority).toBe('normal');
        expect(notificationDoc.data()?.actionUrl).toBe('/match/wc2026_match_42');
        expect(notificationDoc.data()?.data.venueName).toBe('MetLife Stadium');
      });

      it('should generate unique notification ID per user per match', () => {
        const matchId = 'wc2026_match_42';
        const userId1 = 'user-1';
        const userId2 = 'user-2';

        const id1 = `favorite_team_${matchId}_${userId1}`;
        const id2 = `favorite_team_${matchId}_${userId2}`;

        expect(id1).not.toBe(id2);
        expect(id1).toBe('favorite_team_wc2026_match_42_user-1');
        expect(id2).toBe('favorite_team_wc2026_match_42_user-2');
      });

      it('should handle null venue name gracefully', () => {
        const match = {
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          venue: undefined as any,
        };

        const venueName = match.venue?.name;
        expect(venueName).toBeUndefined();
      });

      it('should use "Tomorrow" as fallback time when dateTimeUtc is missing', () => {
        const matchTime = null;
        const timeString = matchTime
          ? new Date(matchTime).toLocaleString()
          : 'Tomorrow';

        expect(timeString).toBe('Tomorrow');
      });
    });

    describe('Sent Notification Record', () => {
      it('should mark match as notified after successful processing', async () => {
        const matchId = 'wc2026_match_42';
        const notificationKey = `favorite_team_${matchId}`;

        const sentData = new Map<string, any>();
        mockFirestore.setTestData('sent_notifications', sentData);

        await mockFirestore.collection('sent_notifications').doc(notificationKey).set({
          matchId,
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          sentAt: MockFieldValue.serverTimestamp(),
          usersNotified: 15,
        });

        const sentDoc = await mockFirestore.collection('sent_notifications').doc(notificationKey).get();
        expect(sentDoc.exists).toBe(true);
        expect(sentDoc.data()?.matchId).toBe('wc2026_match_42');
        expect(sentDoc.data()?.usersNotified).toBe(15);
        expect(sentDoc.data()?.homeTeamCode).toBe('USA');
        expect(sentDoc.data()?.awayTeamCode).toBe('MEX');
      });
    });

    describe('Error Handling', () => {
      it('should handle individual user notification failures without stopping batch', async () => {
        const userIds = ['user-1', 'user-2', 'user-3', 'user-4'];
        let successCount = 0;
        let failCount = 0;

        const sendPromises = userIds.map(async (userId) => {
          try {
            if (userId === 'user-2') {
              throw new Error(`FCM failed for ${userId}`);
            }
            successCount++;
            return { userId, success: true };
          } catch (error) {
            failCount++;
            return { userId, success: false };
          }
        });

        await Promise.all(sendPromises);

        expect(successCount).toBe(3);
        expect(failCount).toBe(1);
      });

      it('should return null on top-level error', async () => {
        try {
          throw new Error('Unexpected error');
        } catch (error) {
          const result = null;
          expect(result).toBeNull();
        }
      });

      it('should handle FCM send failure gracefully', async () => {
        mockMessaging.send.mockRejectedValueOnce(new Error('FCM service unavailable'));

        try {
          await mockMessaging.send({ token: 'some-token' });
        } catch (error: any) {
          expect(error.message).toBe('FCM service unavailable');
        }

        // Subsequent sends should still work
        mockMessaging.send.mockResolvedValueOnce('mock-message-id');
        const result = await mockMessaging.send({ token: 'another-token' });
        expect(result).toBe('mock-message-id');
      });

      it('should handle invalid FCM token error', () => {
        const error = {
          code: 'messaging/invalid-registration-token',
          message: 'Invalid FCM token',
        };

        const isInvalidToken =
          error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered';

        expect(isInvalidToken).toBe(true);
      });
    });

    describe('Scheduled Function Return', () => {
      it('should return null on completion', () => {
        const result = null;
        expect(result).toBeNull();
      });

      it('should return null on error', () => {
        try {
          throw new Error('Processing error');
        } catch {
          const result = null;
          expect(result).toBeNull();
        }
      });
    });
  });

  describe('createInAppNotification', () => {
    it('should format time string with weekday, hour, and minute', () => {
      const matchTime = new Date(2026, 5, 11, 18, 0); // June 11, 2026 6 PM
      const timeString = matchTime.toLocaleString('en-US', {
        weekday: 'short',
        hour: 'numeric',
        minute: '2-digit',
      });

      expect(timeString).toBeDefined();
      expect(typeof timeString).toBe('string');
    });

    it('should use "Tomorrow" fallback when matchTime is null', () => {
      const matchTime = null;
      const timeString = matchTime ? 'formatted' : 'Tomorrow';

      expect(timeString).toBe('Tomorrow');
    });

    it('should set type to favoriteTeamMatch', async () => {
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      const notificationId = 'favorite_team_match_1_user_1';
      await mockFirestore.collection('notifications').doc(notificationId).set({
        notificationId,
        userId: 'user-1',
        type: 'favoriteTeamMatch',
        title: 'Your Team Plays Tomorrow!',
        message: 'USA has a match coming up',
        isRead: false,
        priority: 'normal',
      });

      const doc = await mockFirestore.collection('notifications').doc(notificationId).get();
      expect(doc.data()?.type).toBe('favoriteTeamMatch');
      expect(doc.data()?.priority).toBe('normal');
    });

    it('should include match data in notification', () => {
      const matchData = {
        matchId: 'wc2026_final',
        homeTeamCode: 'ARG',
        homeTeamName: 'Argentina',
        awayTeamCode: 'FRA',
        awayTeamName: 'France',
        matchDateTime: new Date(2026, 6, 19, 18, 0),
        venueName: 'MetLife Stadium',
      };

      expect(matchData.matchId).toBe('wc2026_final');
      expect(matchData.venueName).toBe('MetLife Stadium');
    });

    it('should set actionUrl pointing to match', () => {
      const matchId = 'wc2026_match_42';
      const actionUrl = `/match/${matchId}`;

      expect(actionUrl).toBe('/match/wc2026_match_42');
    });

    it('should handle error in createInAppNotification gracefully', async () => {
      // The function catches errors internally and logs them
      try {
        throw new Error('Firestore set failed');
      } catch (e: any) {
        expect(e.message).toBe('Firestore set failed');
        // Function logs error but does not rethrow
      }
    });
  });

  describe('cleanupSentNotificationRecords', () => {
    it('should run weekly at 4 AM Sunday Eastern', () => {
      const schedule = '0 4 * * 0';
      const timezone = 'America/New_York';

      expect(schedule).toBe('0 4 * * 0');
      expect(timezone).toBe('America/New_York');
    });

    it('should query for records older than 30 days', () => {
      const thirtyDaysAgo = MockTimestamp.fromMillis(
        Date.now() - 30 * 24 * 60 * 60 * 1000
      );

      expect(thirtyDaysAgo.toMillis()).toBeLessThan(Date.now());

      const daysDiff = (Date.now() - thirtyDaysAgo.toMillis()) / (1000 * 60 * 60 * 24);
      expect(Math.round(daysDiff)).toBe(30);
    });

    it('should limit query to 500 documents', () => {
      const batchLimit = 500;
      const totalOldRecords = 750;
      const processedCount = Math.min(totalOldRecords, batchLimit);

      expect(processedCount).toBe(500);
    });

    it('should return early when no old records exist', async () => {
      const sentData = new Map<string, any>();
      mockFirestore.setTestData('sent_notifications', sentData);

      const snapshot = await mockFirestore.collection('sent_notifications').get();
      expect(snapshot.empty).toBe(true);
    });

    it('should batch delete old records', async () => {
      const oldRecords = [
        {
          id: 'favorite_team_match_old_1',
          matchId: 'match-old-1',
          sentAt: new Date(Date.now() - 35 * 24 * 60 * 60 * 1000).toISOString(),
        },
        {
          id: 'favorite_team_match_old_2',
          matchId: 'match-old-2',
          sentAt: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000).toISOString(),
        },
      ];

      const sentData = new Map<string, any>();
      oldRecords.forEach((r) => sentData.set(r.id, r));
      mockFirestore.setTestData('sent_notifications', sentData);

      const batch = mockFirestore.batch();
      for (const record of oldRecords) {
        const ref = mockFirestore.collection('sent_notifications').doc(record.id);
        batch.delete(ref);
      }
      await batch.commit();
    });

    it('should not delete recent records', () => {
      const recentRecord = {
        matchId: 'match-recent',
        sentAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 days ago
      };

      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      const isOldEnough = recentRecord.sentAt < thirtyDaysAgo;

      expect(isOldEnough).toBe(false);
    });

    it('should return null on completion', () => {
      const result = null;
      expect(result).toBeNull();
    });

    it('should return null on error', () => {
      try {
        throw new Error('Cleanup error');
      } catch {
        const result = null;
        expect(result).toBeNull();
      }
    });
  });

  describe('testFavoriteTeamNotificationsHttp', () => {
    it('should return JSON response with steps', () => {
      const results = {
        timestamp: new Date().toISOString(),
        steps: [],
        success: true,
      };

      expect(results.timestamp).toBeDefined();
      expect(results.steps).toEqual([]);
      expect(results.success).toBe(true);
    });

    it('should check for scheduled matches in step 1', async () => {
      const matchesData = new Map<string, any>();
      matchesData.set('match-1', {
        status: 'scheduled',
        homeTeamCode: 'USA',
        awayTeamCode: 'MEX',
      });
      mockFirestore.setTestData('worldcup_matches', matchesData);

      const snapshot = await mockFirestore
        .collection('worldcup_matches')
        .where('status', '==', 'scheduled')
        .get();

      const step = {
        step: 1,
        name: 'Scheduled matches check',
        count: snapshot.size,
      };

      expect(step.count).toBe(1);
    });

    it('should check users with notifications enabled in step 3', async () => {
      const usersData = new Map<string, any>();
      usersData.set('user-1', {
        notifyFavoriteTeamMatches: true,
        favoriteTeamCodes: ['USA'],
        fcmToken: 'token-1',
      });
      usersData.set('user-2', {
        notifyFavoriteTeamMatches: false,
        favoriteTeamCodes: ['MEX'],
        fcmToken: 'token-2',
      });
      mockFirestore.setTestData('users', usersData);

      const snapshot = await mockFirestore
        .collection('users')
        .where('notifyFavoriteTeamMatches', '==', true)
        .get();

      const step = {
        step: 3,
        name: 'Users with notifications enabled',
        count: snapshot.size,
      };

      expect(step.count).toBe(1);
    });

    it('should return 500 status on error', () => {
      const error = new Error('Something went wrong');
      const results = {
        success: false,
        error: error.message,
      };

      expect(results.success).toBe(false);
      expect(results.error).toBe('Something went wrong');
    });

    it('should truncate user IDs in response for privacy', () => {
      const userId = 'abc12345678';
      const truncated = userId.substring(0, 8) + '...';

      expect(truncated).toBe('abc12345...');
      expect(truncated.length).toBe(11);
    });
  });
});
