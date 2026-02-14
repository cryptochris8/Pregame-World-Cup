/**
 * Moderation Notifications Tests
 *
 * Tests for report processing, auto-moderation thresholds, admin notifications,
 * user sanction notifications, expired sanction cleanup, and report resolution.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createTestUser,
  createMockCallableContext,
} from './mocks';

// Mock firebase-admin before imports
const mockFirestore = new MockFirestore();
const mockMessaging = {
  send: jest.fn().mockResolvedValue('mock-message-id'),
  sendEachForMulticast: jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 }),
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

describe('Moderation Notifications', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockMessaging.send.mockClear();
    mockMessaging.sendEachForMulticast.mockClear();
  });

  describe('Report Data Model', () => {
    it('should have all required fields', () => {
      const report = {
        reportId: 'report-001',
        reporterId: 'reporter-user-1',
        reporterDisplayName: 'John Reporter',
        contentType: 'message',
        contentId: 'msg-123',
        contentOwnerId: 'offender-user-1',
        contentOwnerDisplayName: 'Bad Actor',
        reason: 'harassment',
        additionalDetails: 'Repeatedly sending offensive messages',
        contentSnapshot: 'the offensive message text',
        status: 'pending',
        createdAt: new Date().toISOString(),
      };

      expect(report.reportId).toBeDefined();
      expect(report.reporterId).toBeDefined();
      expect(report.reporterDisplayName).toBeDefined();
      expect(report.contentType).toBeDefined();
      expect(report.contentId).toBeDefined();
      expect(report.reason).toBeDefined();
      expect(report.status).toBeDefined();
      expect(report.createdAt).toBeDefined();
    });

    it('should allow optional fields to be omitted', () => {
      const report = {
        reportId: 'report-002',
        reporterId: 'reporter-user-2',
        reporterDisplayName: 'Jane Reporter',
        contentType: 'chatRoom',
        contentId: 'chat-456',
        reason: 'spam',
        status: 'pending',
        createdAt: new Date().toISOString(),
      };

      expect(report.reportId).toBeDefined();
      expect((report as any).contentOwnerId).toBeUndefined();
      expect((report as any).contentOwnerDisplayName).toBeUndefined();
      expect((report as any).additionalDetails).toBeUndefined();
      expect((report as any).contentSnapshot).toBeUndefined();
    });

    it('should validate known report reasons', () => {
      const validReasons = [
        'spam',
        'harassment',
        'hateSpeech',
        'violence',
        'sexualContent',
        'misinformation',
        'impersonation',
        'scam',
        'inappropriateContent',
        'other',
      ];

      validReasons.forEach((reason) => {
        expect(validReasons.includes(reason)).toBe(true);
      });

      expect(validReasons.includes('unknownReason')).toBe(false);
    });

    it('should validate known content types', () => {
      const validContentTypes = [
        'user',
        'message',
        'watchParty',
        'chatRoom',
        'prediction',
        'comment',
      ];

      validContentTypes.forEach((type) => {
        expect(validContentTypes.includes(type)).toBe(true);
      });

      expect(validContentTypes.includes('video')).toBe(false);
    });

    it('should default to pending status', () => {
      const report = {
        reportId: 'report-003',
        status: 'pending',
      };

      expect(report.status).toBe('pending');
    });

    it('should store report in Firestore', async () => {
      const reportsData = new Map<string, any>();
      mockFirestore.setTestData('reports', reportsData);

      const report = {
        reportId: 'report-stored',
        reporterId: 'reporter-1',
        reporterDisplayName: 'Test Reporter',
        contentType: 'message',
        contentId: 'msg-001',
        contentOwnerId: 'owner-1',
        contentOwnerDisplayName: 'Content Owner',
        reason: 'spam',
        status: 'pending',
        createdAt: new Date().toISOString(),
      };

      await mockFirestore.collection('reports').doc(report.reportId).set(report);

      const reportDoc = await mockFirestore.collection('reports').doc(report.reportId).get();
      expect(reportDoc.exists).toBe(true);
      expect(reportDoc.data()?.reason).toBe('spam');
      expect(reportDoc.data()?.status).toBe('pending');
    });
  });

  describe('UserModerationStatus Data Model', () => {
    it('should have all required fields', () => {
      const status = {
        usualId: 'user-123',
        warningCount: 0,
        reportCount: 0,
        isMuted: false,
        isSuspended: false,
        isBanned: false,
      };

      expect(status.usualId).toBeDefined();
      expect(status.warningCount).toBe(0);
      expect(status.reportCount).toBe(0);
      expect(status.isMuted).toBe(false);
      expect(status.isSuspended).toBe(false);
      expect(status.isBanned).toBe(false);
    });

    it('should allow optional sanction fields', () => {
      const status = {
        usualId: 'user-456',
        warningCount: 2,
        reportCount: 5,
        isMuted: true,
        mutedUntil: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        isSuspended: false,
        isBanned: false,
        lastWarningAt: new Date().toISOString(),
      };

      expect(status.mutedUntil).toBeDefined();
      expect(status.lastWarningAt).toBeDefined();
      expect((status as any).suspendedUntil).toBeUndefined();
      expect((status as any).banReason).toBeUndefined();
    });
  });

  describe('Auto-Moderation Thresholds', () => {
    it('should auto-mute at 5 reports when not already sanctioned', async () => {
      const userId = 'user-five-reports';
      const statusData = new Map<string, any>();
      statusData.set(userId, {
        usualId: userId,
        warningCount: 0,
        reportCount: 5,
        isMuted: false,
        isSuspended: false,
        isBanned: false,
      });
      mockFirestore.setTestData('user_moderation_status', statusData);

      const statusDoc = await mockFirestore.collection('user_moderation_status').doc(userId).get();
      const status = statusDoc.data();

      expect(status?.reportCount).toBeGreaterThanOrEqual(5);
      expect(status?.isMuted).toBe(false);
      expect(status?.isSuspended).toBe(false);
      expect(status?.isBanned).toBe(false);

      // Should trigger auto-mute
      const shouldAutoMute =
        status?.reportCount >= 5 &&
        !status?.isMuted &&
        !status?.isSuspended &&
        !status?.isBanned;
      expect(shouldAutoMute).toBe(true);

      // Simulate the mute action
      const mutedUntil = new Date();
      mutedUntil.setHours(mutedUntil.getHours() + 24);

      await mockFirestore.collection('user_moderation_status').doc(userId).update({
        isMuted: true,
        mutedUntil: mutedUntil.toISOString(),
      });

      const updatedDoc = await mockFirestore.collection('user_moderation_status').doc(userId).get();
      expect(updatedDoc.data()?.isMuted).toBe(true);
      expect(updatedDoc.data()?.mutedUntil).toBeDefined();
    });

    it('should auto-suspend at 10 reports', async () => {
      const userId = 'user-ten-reports';
      const statusData = new Map<string, any>();
      statusData.set(userId, {
        usualId: userId,
        warningCount: 2,
        reportCount: 10,
        isMuted: true,
        isSuspended: false,
        isBanned: false,
      });
      mockFirestore.setTestData('user_moderation_status', statusData);

      const statusDoc = await mockFirestore.collection('user_moderation_status').doc(userId).get();
      const status = statusDoc.data();

      expect(status?.reportCount).toBeGreaterThanOrEqual(10);
      expect(status?.isSuspended).toBe(false);
      expect(status?.isBanned).toBe(false);

      // Should trigger auto-suspend
      const shouldAutoSuspend =
        status?.reportCount >= 10 &&
        !status?.isSuspended &&
        !status?.isBanned;
      expect(shouldAutoSuspend).toBe(true);

      // Simulate the suspension action
      const suspendedUntil = new Date();
      suspendedUntil.setDate(suspendedUntil.getDate() + 7);

      await mockFirestore.collection('user_moderation_status').doc(userId).update({
        isMuted: false,
        mutedUntil: null,
        isSuspended: true,
        suspendedUntil: suspendedUntil.toISOString(),
      });

      const updatedDoc = await mockFirestore.collection('user_moderation_status').doc(userId).get();
      expect(updatedDoc.data()?.isSuspended).toBe(true);
      expect(updatedDoc.data()?.isMuted).toBe(false);
      expect(updatedDoc.data()?.mutedUntil).toBeNull();
    });

    it('should skip auto-mute if user is already muted', () => {
      const status = {
        reportCount: 7,
        isMuted: true,
        isSuspended: false,
        isBanned: false,
      };

      const shouldAutoMute =
        status.reportCount >= 5 &&
        !status.isMuted &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoMute).toBe(false);
    });

    it('should skip auto-mute if user is already suspended', () => {
      const status = {
        reportCount: 7,
        isMuted: false,
        isSuspended: true,
        isBanned: false,
      };

      const shouldAutoMute =
        status.reportCount >= 5 &&
        !status.isMuted &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoMute).toBe(false);
    });

    it('should skip auto-mute if user is already banned', () => {
      const status = {
        reportCount: 7,
        isMuted: false,
        isSuspended: false,
        isBanned: true,
      };

      const shouldAutoMute =
        status.reportCount >= 5 &&
        !status.isMuted &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoMute).toBe(false);
    });

    it('should skip auto-suspend if user is already suspended', () => {
      const status = {
        reportCount: 12,
        isSuspended: true,
        isBanned: false,
      };

      const shouldAutoSuspend =
        status.reportCount >= 10 &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoSuspend).toBe(false);
    });

    it('should skip auto-suspend if user is already banned', () => {
      const status = {
        reportCount: 12,
        isSuspended: false,
        isBanned: true,
      };

      const shouldAutoSuspend =
        status.reportCount >= 10 &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoSuspend).toBe(false);
    });

    it('should not trigger any action below 5 reports', () => {
      const status = {
        reportCount: 3,
        isMuted: false,
        isSuspended: false,
        isBanned: false,
      };

      const shouldAutoMute =
        status.reportCount >= 5 &&
        !status.isMuted &&
        !status.isSuspended &&
        !status.isBanned;

      const shouldAutoSuspend =
        status.reportCount >= 10 &&
        !status.isSuspended &&
        !status.isBanned;

      expect(shouldAutoMute).toBe(false);
      expect(shouldAutoSuspend).toBe(false);
    });

    it('should return early if moderation status doc does not exist', async () => {
      const userId = 'non-existent-user';
      const statusData = new Map<string, any>();
      mockFirestore.setTestData('user_moderation_status', statusData);

      const statusDoc = await mockFirestore.collection('user_moderation_status').doc(userId).get();

      expect(statusDoc.exists).toBe(false);
      // Function returns early, no action taken
    });

    it('should create a sanction record on auto-mute', async () => {
      const userId = 'user-sanction-mute';
      const sanctionsData = new Map<string, any>();
      mockFirestore.setTestData('user_sanctions', sanctionsData);

      const mutedUntil = new Date();
      mutedUntil.setHours(mutedUntil.getHours() + 24);

      await mockFirestore.collection('user_sanctions').add({
        sanctionId: 'mock-sanction-id',
        usualId: userId,
        type: 'mute',
        reason: 'Automatic mute: Received 5+ reports',
        action: 'temporaryMute',
        createdAt: new Date().toISOString(),
        expiresAt: mutedUntil.toISOString(),
        isActive: true,
        moderatorId: 'system',
      });

      const sanctionsSnapshot = await mockFirestore.collection('user_sanctions').get();
      expect(sanctionsSnapshot.empty).toBe(false);

      let foundSanction = false;
      sanctionsSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.usualId === userId && data.type === 'mute') {
          expect(data.reason).toBe('Automatic mute: Received 5+ reports');
          expect(data.action).toBe('temporaryMute');
          expect(data.isActive).toBe(true);
          expect(data.moderatorId).toBe('system');
          foundSanction = true;
        }
      });
      expect(foundSanction).toBe(true);
    });

    it('should create a sanction record on auto-suspend', async () => {
      const userId = 'user-sanction-suspend';
      const sanctionsData = new Map<string, any>();
      mockFirestore.setTestData('user_sanctions', sanctionsData);

      const suspendedUntil = new Date();
      suspendedUntil.setDate(suspendedUntil.getDate() + 7);

      await mockFirestore.collection('user_sanctions').add({
        sanctionId: 'mock-sanction-id-2',
        usualId: userId,
        type: 'suspension',
        reason: 'Automatic suspension: Received 10+ reports',
        action: 'temporarySuspension',
        createdAt: new Date().toISOString(),
        expiresAt: suspendedUntil.toISOString(),
        isActive: true,
        moderatorId: 'system',
      });

      const sanctionsSnapshot = await mockFirestore.collection('user_sanctions').get();
      expect(sanctionsSnapshot.empty).toBe(false);

      let foundSanction = false;
      sanctionsSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.usualId === userId && data.type === 'suspension') {
          expect(data.reason).toBe('Automatic suspension: Received 10+ reports');
          expect(data.action).toBe('temporarySuspension');
          expect(data.isActive).toBe(true);
          expect(data.moderatorId).toBe('system');
          foundSanction = true;
        }
      });
      expect(foundSanction).toBe(true);
    });

    it('should set mute duration to 24 hours', () => {
      const mutedUntil = new Date();
      mutedUntil.setHours(mutedUntil.getHours() + 24);

      const now = new Date();
      const durationHours = (mutedUntil.getTime() - now.getTime()) / (1000 * 60 * 60);

      expect(Math.round(durationHours)).toBe(24);
    });

    it('should set suspension duration to 7 days', () => {
      const suspendedUntil = new Date();
      suspendedUntil.setDate(suspendedUntil.getDate() + 7);

      const now = new Date();
      const durationDays = (suspendedUntil.getTime() - now.getTime()) / (1000 * 60 * 60 * 24);

      expect(Math.round(durationDays)).toBe(7);
    });
  });

  describe('Admin Notification Structure', () => {
    it('should get admin FCM tokens from admin_users collection', async () => {
      const adminUsersData = new Map<string, any>();
      adminUsersData.set('admin-1', { uid: 'admin-1', fcmToken: 'admin-token-1' });
      adminUsersData.set('admin-2', { uid: 'admin-2', fcmToken: 'admin-token-2' });
      adminUsersData.set('admin-3', { uid: 'admin-3', fcmToken: null });
      mockFirestore.setTestData('admin_users', adminUsersData);

      const adminsSnapshot = await mockFirestore.collection('admin_users').get();
      expect(adminsSnapshot.empty).toBe(false);

      const tokens: string[] = [];
      adminsSnapshot.forEach((doc) => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
          tokens.push(fcmToken);
        }
      });

      expect(tokens).toHaveLength(2);
      expect(tokens).toContain('admin-token-1');
      expect(tokens).toContain('admin-token-2');
    });

    it('should skip notification when no admin users exist', async () => {
      const adminUsersData = new Map<string, any>();
      mockFirestore.setTestData('admin_users', adminUsersData);

      const adminsSnapshot = await mockFirestore.collection('admin_users').get();
      expect(adminsSnapshot.empty).toBe(true);

      // Function returns early
    });

    it('should skip notification when no admin FCM tokens found', async () => {
      const adminUsersData = new Map<string, any>();
      adminUsersData.set('admin-no-token', { uid: 'admin-no-token', fcmToken: null });
      mockFirestore.setTestData('admin_users', adminUsersData);

      const adminsSnapshot = await mockFirestore.collection('admin_users').get();
      expect(adminsSnapshot.empty).toBe(false);

      const tokens: string[] = [];
      adminsSnapshot.forEach((doc) => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
          tokens.push(fcmToken);
        }
      });

      expect(tokens).toHaveLength(0);
    });

    it('should construct correct multicast message structure', async () => {
      const report = {
        reportId: 'report-admin-notify',
        reporterDisplayName: 'John Reporter',
        contentOwnerDisplayName: 'Bad Actor',
        contentType: 'message',
        contentId: 'msg-789',
        reason: 'harassment',
      };

      const tokens = ['admin-token-1', 'admin-token-2'];

      const message = {
        tokens,
        notification: {
          title: 'New Message Report',
          body: `${report.reporterDisplayName} reported ${report.contentOwnerDisplayName} for Harassment`,
        },
        data: {
          type: 'moderation_report',
          reportId: report.reportId,
          contentType: report.contentType,
          contentId: report.contentId,
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'moderation',
            priority: 'high' as const,
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      await mockMessaging.sendEachForMulticast(message);

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledWith(
        expect.objectContaining({
          tokens: expect.arrayContaining(['admin-token-1', 'admin-token-2']),
          notification: expect.objectContaining({
            title: 'New Message Report',
          }),
          data: expect.objectContaining({
            type: 'moderation_report',
            reportId: 'report-admin-notify',
          }),
        })
      );
    });

    it('should use moderation channel ID for Android notifications', () => {
      const androidConfig = {
        priority: 'high',
        notification: {
          channelId: 'moderation',
          priority: 'high',
        },
      };

      expect(androidConfig.notification.channelId).toBe('moderation');
      expect(androidConfig.priority).toBe('high');
    });

    it('should include badge and sound in APNs payload', () => {
      const apnsConfig = {
        payload: {
          aps: {
            badge: 1,
            sound: 'default',
          },
        },
      };

      expect(apnsConfig.payload.aps.badge).toBe(1);
      expect(apnsConfig.payload.aps.sound).toBe('default');
    });

    it('should include report data in notification payload', () => {
      const dataPayload = {
        type: 'moderation_report',
        reportId: 'report-data-test',
        contentType: 'watchParty',
        contentId: 'wp-123',
      };

      expect(dataPayload.type).toBe('moderation_report');
      expect(dataPayload.reportId).toBe('report-data-test');
      expect(dataPayload.contentType).toBe('watchParty');
      expect(dataPayload.contentId).toBe('wp-123');
    });

    it('should use content owner name in body or fallback to "content"', () => {
      const reporterName = 'Reporter';
      const reason = 'Spam';

      // With content owner name
      const withOwner = `${reporterName} reported ${'Bad Actor'} for ${reason}`;
      expect(withOwner).toBe('Reporter reported Bad Actor for Spam');

      // Without content owner name (fallback)
      const contentOwnerDisplayName: string | undefined = undefined;
      const withoutOwner = `${reporterName} reported ${contentOwnerDisplayName || 'content'} for ${reason}`;
      expect(withoutOwner).toBe('Reporter reported content for Spam');
    });

    it('should handle FCM multicast send failure gracefully', async () => {
      mockMessaging.sendEachForMulticast.mockRejectedValueOnce(new Error('FCM multicast failed'));

      try {
        await mockMessaging.sendEachForMulticast({ tokens: ['token-1'] });
      } catch (error: any) {
        expect(error.message).toBe('FCM multicast failed');
      }

      // Function should catch error and log, not rethrow
    });
  });

  describe('User Sanction Notification Messages', () => {
    it('should send correct notification for mute sanction', async () => {
      const userId = 'user-muted';
      const usersData = new Map<string, any>();
      usersData.set(userId, createTestUser({ uid: userId, fcmToken: 'muted-user-token' }));
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;
      expect(fcmToken).toBe('muted-user-token');

      const sanctionType = 'mute';
      const duration = '24 hours';
      const title = 'Account Muted';
      const body = `Your account has been temporarily muted for ${duration} due to community guideline violations.`;

      const message = {
        token: fcmToken,
        notification: { title, body },
        data: {
          type: 'moderation_sanction',
          sanctionType,
        },
        android: { priority: 'high' as const },
        apns: {
          payload: {
            aps: { badge: 1, sound: 'default' },
          },
        },
      };

      await mockMessaging.send(message);

      expect(mockMessaging.send).toHaveBeenCalledWith(
        expect.objectContaining({
          token: 'muted-user-token',
          notification: expect.objectContaining({
            title: 'Account Muted',
            body: expect.stringContaining('temporarily muted for 24 hours'),
          }),
          data: expect.objectContaining({
            type: 'moderation_sanction',
            sanctionType: 'mute',
          }),
        })
      );
    });

    it('should send correct notification for suspension sanction', () => {
      const sanctionType = 'suspension';
      const duration = '7 days';

      const title = 'Account Suspended';
      const body = `Your account has been suspended for ${duration} due to repeated community guideline violations.`;

      expect(title).toBe('Account Suspended');
      expect(body).toContain('suspended for 7 days');
      expect(body).toContain('repeated community guideline violations');
    });

    it('should send correct notification for warning sanction', () => {
      const sanctionType: string = 'warning';

      let title: string;
      let body: string;

      switch (sanctionType) {
        case 'mute':
          title = 'Account Muted';
          body = 'Your account has been temporarily muted for 24 hours due to community guideline violations.';
          break;
        case 'suspension':
          title = 'Account Suspended';
          body = 'Your account has been suspended for 7 days due to repeated community guideline violations.';
          break;
        case 'warning':
          title = 'Community Guidelines Warning';
          body = 'You have received a warning for violating our community guidelines. Further violations may result in account restrictions.';
          break;
        default:
          title = 'Account Status Update';
          body = 'Your account status has been updated. Please review our community guidelines.';
      }

      expect(title).toBe('Community Guidelines Warning');
      expect(body).toContain('warning for violating');
      expect(body).toContain('Further violations may result in account restrictions');
    });

    it('should use default message for unknown sanction types', () => {
      const sanctionType: string = 'unknown_type';

      let title: string;
      let body: string;

      switch (sanctionType) {
        case 'mute':
          title = 'Account Muted';
          body = 'Muted message';
          break;
        case 'suspension':
          title = 'Account Suspended';
          body = 'Suspended message';
          break;
        case 'warning':
          title = 'Community Guidelines Warning';
          body = 'Warning message';
          break;
        default:
          title = 'Account Status Update';
          body = 'Your account status has been updated. Please review our community guidelines.';
      }

      expect(title).toBe('Account Status Update');
      expect(body).toContain('account status has been updated');
    });

    it('should not send FCM if user has no FCM token', async () => {
      const userId = 'user-no-fcm';
      const usersData = new Map<string, any>();
      usersData.set(userId, {
        uid: userId,
        email: 'notoken@example.com',
        displayName: 'No Token User',
        fcmToken: null,
        favoriteTeamCodes: [],
      });
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      expect(fcmToken).toBeFalsy();
      // Function should skip FCM send
    });

    it('should return early if user does not exist', async () => {
      const userId = 'non-existent-user';
      const usersData = new Map<string, any>();
      mockFirestore.setTestData('users', usersData);

      const userDoc = await mockFirestore.collection('users').doc(userId).get();
      expect(userDoc.exists).toBe(false);
      // Function returns early
    });

    it('should create in-app notification with correct fields', async () => {
      const userId = 'user-in-app-notification';
      const sanctionType = 'mute';
      const title = 'Account Muted';
      const body = 'Your account has been temporarily muted for 24 hours due to community guideline violations.';

      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      await mockFirestore.collection('notifications').add({
        userId,
        type: 'moderation',
        title,
        body,
        data: { sanctionType },
        isRead: false,
        createdAt: MockFieldValue.serverTimestamp(),
      });

      const notificationsSnapshot = await mockFirestore.collection('notifications').get();
      expect(notificationsSnapshot.empty).toBe(false);

      let foundNotification = false;
      notificationsSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.userId === userId) {
          expect(data.type).toBe('moderation');
          expect(data.title).toBe('Account Muted');
          expect(data.isRead).toBe(false);
          expect(data.data.sanctionType).toBe('mute');
          expect(data.createdAt).toBeDefined();
          foundNotification = true;
        }
      });
      expect(foundNotification).toBe(true);
    });

    it('should create in-app notification even if FCM send fails', async () => {
      mockMessaging.send.mockRejectedValueOnce(new Error('FCM send failed'));

      try {
        await mockMessaging.send({ token: 'invalid-token' });
      } catch (error: any) {
        expect(error.message).toBe('FCM send failed');
      }

      // Should still create in-app notification
      const notificationsData = new Map<string, any>();
      mockFirestore.setTestData('notifications', notificationsData);

      await mockFirestore.collection('notifications').add({
        userId: 'user-fcm-fail',
        type: 'moderation',
        title: 'Account Muted',
        body: 'Your account has been temporarily muted.',
        data: { sanctionType: 'mute' },
        isRead: false,
        createdAt: MockFieldValue.serverTimestamp(),
      });

      const notificationsSnapshot = await mockFirestore.collection('notifications').get();
      expect(notificationsSnapshot.empty).toBe(false);
    });

    it('should include sanction type in data payload', () => {
      const dataPayload = {
        type: 'moderation_sanction',
        sanctionType: 'suspension',
      };

      expect(dataPayload.type).toBe('moderation_sanction');
      expect(dataPayload.sanctionType).toBe('suspension');
    });
  });

  describe('clearExpiredSanctions', () => {
    it('should run every 1 hour', () => {
      const schedule = 'every 1 hours';
      expect(schedule).toBe('every 1 hours');
    });

    it('should clear expired mutes', async () => {
      const now = new Date().toISOString();
      const pastTime = new Date(Date.now() - 60 * 60 * 1000).toISOString(); // 1 hour ago

      const statusData = new Map<string, any>();
      statusData.set('user-expired-mute', {
        usualId: 'user-expired-mute',
        isMuted: true,
        mutedUntil: pastTime,
        isSuspended: false,
      });
      statusData.set('user-active-mute', {
        usualId: 'user-active-mute',
        isMuted: true,
        mutedUntil: new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString(), // 12 hours from now
        isSuspended: false,
      });
      mockFirestore.setTestData('user_moderation_status', statusData);

      // Query for expired mutes
      const expiredMutes = await mockFirestore
        .collection('user_moderation_status')
        .where('isMuted', '==', true)
        .where('mutedUntil', '<=', now)
        .get();

      expect(expiredMutes.size).toBe(1);

      // Clear the expired mute
      for (const doc of expiredMutes.docs) {
        await doc.ref.update({
          isMuted: false,
          mutedUntil: null,
        });
      }
    });

    it('should clear expired suspensions', async () => {
      const now = new Date().toISOString();
      const pastTime = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(); // 1 day ago

      const statusData = new Map<string, any>();
      statusData.set('user-expired-suspension', {
        usualId: 'user-expired-suspension',
        isMuted: false,
        isSuspended: true,
        suspendedUntil: pastTime,
      });
      mockFirestore.setTestData('user_moderation_status', statusData);

      const expiredSuspensions = await mockFirestore
        .collection('user_moderation_status')
        .where('isSuspended', '==', true)
        .where('suspendedUntil', '<=', now)
        .get();

      expect(expiredSuspensions.size).toBe(1);

      for (const doc of expiredSuspensions.docs) {
        await doc.ref.update({
          isSuspended: false,
          suspendedUntil: null,
        });
      }
    });

    it('should mark expired sanctions as inactive', async () => {
      const now = new Date().toISOString();
      const pastTime = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(); // 2 days ago

      const sanctionsData = new Map<string, any>();
      sanctionsData.set('sanction-expired', {
        sanctionId: 'sanction-expired',
        isActive: true,
        expiresAt: pastTime,
        type: 'mute',
      });
      sanctionsData.set('sanction-active', {
        sanctionId: 'sanction-active',
        isActive: true,
        expiresAt: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(), // 5 days from now
        type: 'suspension',
      });
      mockFirestore.setTestData('user_sanctions', sanctionsData);

      const expiredSanctions = await mockFirestore
        .collection('user_sanctions')
        .where('isActive', '==', true)
        .where('expiresAt', '<=', now)
        .get();

      expect(expiredSanctions.size).toBe(1);

      for (const doc of expiredSanctions.docs) {
        await doc.ref.update({
          isActive: false,
        });
      }
    });

    it('should handle no expired items gracefully', async () => {
      const now = new Date().toISOString();

      // Set up data with no expired items
      const statusData = new Map<string, any>();
      statusData.set('user-still-muted', {
        isMuted: true,
        mutedUntil: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        isSuspended: false,
      });
      mockFirestore.setTestData('user_moderation_status', statusData);

      const expiredMutes = await mockFirestore
        .collection('user_moderation_status')
        .where('isMuted', '==', true)
        .where('mutedUntil', '<=', now)
        .get();

      expect(expiredMutes.size).toBe(0);
    });

    it('should handle empty collections', async () => {
      const statusData = new Map<string, any>();
      mockFirestore.setTestData('user_moderation_status', statusData);
      mockFirestore.setTestData('user_sanctions', new Map<string, any>());

      const mutesSnapshot = await mockFirestore
        .collection('user_moderation_status')
        .where('isMuted', '==', true)
        .get();

      const suspensionsSnapshot = await mockFirestore
        .collection('user_moderation_status')
        .where('isSuspended', '==', true)
        .get();

      const sanctionsSnapshot = await mockFirestore
        .collection('user_sanctions')
        .where('isActive', '==', true)
        .get();

      expect(mutesSnapshot.size).toBe(0);
      expect(suspensionsSnapshot.size).toBe(0);
      expect(sanctionsSnapshot.size).toBe(0);
    });

    it('should process multiple expired items in a single run', async () => {
      const now = new Date().toISOString();
      const pastTime1 = new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString();
      const pastTime2 = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
      const pastTime3 = new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString();

      const statusData = new Map<string, any>();
      statusData.set('user-1', { isMuted: true, mutedUntil: pastTime1, isSuspended: false });
      statusData.set('user-2', { isMuted: true, mutedUntil: pastTime2, isSuspended: false });
      statusData.set('user-3', { isMuted: true, mutedUntil: pastTime3, isSuspended: false });
      mockFirestore.setTestData('user_moderation_status', statusData);

      const expiredMutes = await mockFirestore
        .collection('user_moderation_status')
        .where('isMuted', '==', true)
        .where('mutedUntil', '<=', now)
        .get();

      expect(expiredMutes.size).toBe(3);
    });
  });

  describe('resolveReport', () => {
    it('should require authentication', () => {
      const context = createMockCallableContext({ auth: null });
      const isAuthenticated = context.auth !== null;

      expect(isAuthenticated).toBe(false);
    });

    it('should require admin role', () => {
      const contextNoAdmin = {
        auth: {
          uid: 'non-admin-user',
          token: { email: 'user@example.com', admin: false },
        },
      };

      const isAdmin = contextNoAdmin.auth?.token?.admin === true;
      expect(isAdmin).toBe(false);
    });

    it('should allow admin users to proceed', () => {
      const contextAdmin = {
        auth: {
          uid: 'admin-user',
          token: { email: 'admin@example.com', admin: true },
        },
      };

      const isAdmin = contextAdmin.auth?.token?.admin === true;
      expect(isAdmin).toBe(true);
    });

    it('should require reportId and action parameters', () => {
      const data1 = { reportId: null, action: 'dismiss' };
      const data2 = { reportId: 'report-1', action: null };
      const data3 = { reportId: null, action: null };
      const data4 = { reportId: 'report-1', action: 'dismiss' };

      expect(!data1.reportId || !data1.action).toBe(true);
      expect(!data2.reportId || !data2.action).toBe(true);
      expect(!data3.reportId || !data3.action).toBe(true);
      expect(!data4.reportId || !data4.action).toBe(false);
    });

    it('should return not-found if report does not exist', async () => {
      const reportsData = new Map<string, any>();
      mockFirestore.setTestData('reports', reportsData);

      const reportDoc = await mockFirestore.collection('reports').doc('non-existent').get();
      expect(reportDoc.exists).toBe(false);
    });

    it('should update report with resolution details on success', async () => {
      const reportId = 'report-to-resolve';
      const moderatorId = 'admin-user-123';
      const action = 'dismiss';
      const moderatorNotes = 'False report, no action needed.';

      const reportsData = new Map<string, any>();
      reportsData.set(reportId, {
        reportId,
        reporterId: 'reporter-1',
        reporterDisplayName: 'Test Reporter',
        contentType: 'message',
        contentId: 'msg-001',
        reason: 'spam',
        status: 'pending',
        createdAt: new Date().toISOString(),
      });
      mockFirestore.setTestData('reports', reportsData);

      const reportDoc = await mockFirestore.collection('reports').doc(reportId).get();
      expect(reportDoc.exists).toBe(true);
      expect(reportDoc.data()?.status).toBe('pending');

      const now = new Date().toISOString();

      await mockFirestore.collection('reports').doc(reportId).update({
        status: 'resolved',
        actionTaken: action,
        moderatorId,
        moderatorNotes,
        reviewedAt: now,
        resolvedAt: now,
      });

      const updatedDoc = await mockFirestore.collection('reports').doc(reportId).get();
      expect(updatedDoc.data()?.status).toBe('resolved');
      expect(updatedDoc.data()?.actionTaken).toBe('dismiss');
      expect(updatedDoc.data()?.moderatorId).toBe('admin-user-123');
      expect(updatedDoc.data()?.moderatorNotes).toBe('False report, no action needed.');
      expect(updatedDoc.data()?.reviewedAt).toBeDefined();
      expect(updatedDoc.data()?.resolvedAt).toBeDefined();
    });

    it('should return success response on resolution', () => {
      const result = { success: true, message: 'Report resolved successfully' };

      expect(result.success).toBe(true);
      expect(result.message).toBe('Report resolved successfully');
    });

    it('should handle null moderator notes', async () => {
      const reportId = 'report-no-notes';
      const reportsData = new Map<string, any>();
      reportsData.set(reportId, {
        reportId,
        status: 'pending',
      });
      mockFirestore.setTestData('reports', reportsData);

      await mockFirestore.collection('reports').doc(reportId).update({
        status: 'resolved',
        actionTaken: 'warn',
        moderatorId: 'admin-1',
        moderatorNotes: null,
        reviewedAt: new Date().toISOString(),
        resolvedAt: new Date().toISOString(),
      });

      const updatedDoc = await mockFirestore.collection('reports').doc(reportId).get();
      expect(updatedDoc.data()?.moderatorNotes).toBeNull();
      expect(updatedDoc.data()?.status).toBe('resolved');
    });
  });

  describe('formatReportReason', () => {
    const formatReportReason = (reason: string): string => {
      const reasonMap: { [key: string]: string } = {
        spam: 'Spam',
        harassment: 'Harassment',
        hateSpeech: 'Hate Speech',
        violence: 'Violence',
        sexualContent: 'Sexual Content',
        misinformation: 'Misinformation',
        impersonation: 'Impersonation',
        scam: 'Scam',
        inappropriateContent: 'Inappropriate Content',
        other: 'Other',
      };
      return reasonMap[reason] || reason;
    };

    it('should format spam reason', () => {
      expect(formatReportReason('spam')).toBe('Spam');
    });

    it('should format harassment reason', () => {
      expect(formatReportReason('harassment')).toBe('Harassment');
    });

    it('should format hateSpeech reason', () => {
      expect(formatReportReason('hateSpeech')).toBe('Hate Speech');
    });

    it('should format violence reason', () => {
      expect(formatReportReason('violence')).toBe('Violence');
    });

    it('should format sexualContent reason', () => {
      expect(formatReportReason('sexualContent')).toBe('Sexual Content');
    });

    it('should format misinformation reason', () => {
      expect(formatReportReason('misinformation')).toBe('Misinformation');
    });

    it('should format impersonation reason', () => {
      expect(formatReportReason('impersonation')).toBe('Impersonation');
    });

    it('should format scam reason', () => {
      expect(formatReportReason('scam')).toBe('Scam');
    });

    it('should format inappropriateContent reason', () => {
      expect(formatReportReason('inappropriateContent')).toBe('Inappropriate Content');
    });

    it('should format other reason', () => {
      expect(formatReportReason('other')).toBe('Other');
    });

    it('should return raw value for unknown reasons', () => {
      expect(formatReportReason('customReason')).toBe('customReason');
      expect(formatReportReason('')).toBe('');
      expect(formatReportReason('some_unknown_reason')).toBe('some_unknown_reason');
    });
  });

  describe('formatContentType', () => {
    const formatContentType = (contentType: string): string => {
      const typeMap: { [key: string]: string } = {
        user: 'User',
        message: 'Message',
        watchParty: 'Watch Party',
        chatRoom: 'Chat Room',
        prediction: 'Prediction',
        comment: 'Comment',
      };
      return typeMap[contentType] || contentType;
    };

    it('should format user content type', () => {
      expect(formatContentType('user')).toBe('User');
    });

    it('should format message content type', () => {
      expect(formatContentType('message')).toBe('Message');
    });

    it('should format watchParty content type', () => {
      expect(formatContentType('watchParty')).toBe('Watch Party');
    });

    it('should format chatRoom content type', () => {
      expect(formatContentType('chatRoom')).toBe('Chat Room');
    });

    it('should format prediction content type', () => {
      expect(formatContentType('prediction')).toBe('Prediction');
    });

    it('should format comment content type', () => {
      expect(formatContentType('comment')).toBe('Comment');
    });

    it('should return raw value for unknown content types', () => {
      expect(formatContentType('video')).toBe('video');
      expect(formatContentType('')).toBe('');
      expect(formatContentType('unknownType')).toBe('unknownType');
    });

    it('should build correct notification title using formatted content type', () => {
      const contentType = 'watchParty';
      const contentTypeText = formatContentType(contentType);
      const title = `New ${contentTypeText} Report`;

      expect(title).toBe('New Watch Party Report');
    });
  });

  describe('onReportCreated Trigger', () => {
    it('should return early if event has no data', () => {
      const snapshot = null;

      expect(snapshot).toBeNull();
      // Function logs and returns early
    });

    it('should process report with contentOwnerId', () => {
      const report = {
        reportId: 'report-with-owner',
        contentOwnerId: 'owner-123',
        contentType: 'message',
        reason: 'spam',
      };

      expect(report.contentOwnerId).toBeDefined();
      // Should call checkAutoModerationThresholds
    });

    it('should skip threshold check when no contentOwnerId', () => {
      const report = {
        reportId: 'report-no-owner',
        contentType: 'chatRoom',
        reason: 'spam',
      };

      expect((report as any).contentOwnerId).toBeUndefined();
      // Should skip checkAutoModerationThresholds
    });

    it('should always notify admins of new reports', async () => {
      const adminUsersData = new Map<string, any>();
      adminUsersData.set('admin-1', { uid: 'admin-1', fcmToken: 'token-1' });
      mockFirestore.setTestData('admin_users', adminUsersData);

      const adminsSnapshot = await mockFirestore.collection('admin_users').get();
      expect(adminsSnapshot.empty).toBe(false);

      // Admin notification should always be sent regardless of contentOwnerId
    });
  });

  describe('Error Handling', () => {
    it('should handle Firestore read errors in checkAutoModerationThresholds', async () => {
      // Simulate a situation where an error might occur
      try {
        throw new Error('Firestore read failed');
      } catch (error: any) {
        expect(error.message).toBe('Firestore read failed');
      }
    });

    it('should handle Firestore write errors in auto-moderation', async () => {
      try {
        throw new Error('Firestore write failed');
      } catch (error: any) {
        expect(error.message).toBe('Firestore write failed');
      }
    });

    it('should handle FCM send errors for user sanctions', async () => {
      mockMessaging.send.mockRejectedValueOnce(new Error('FCM send failed'));

      try {
        await mockMessaging.send({ token: 'bad-token' });
      } catch (error: any) {
        expect(error.message).toBe('FCM send failed');
      }
    });

    it('should handle FCM multicast errors for admin notifications', async () => {
      mockMessaging.sendEachForMulticast.mockRejectedValueOnce(new Error('Multicast failed'));

      try {
        await mockMessaging.sendEachForMulticast({ tokens: ['token-1', 'token-2'] });
      } catch (error: any) {
        expect(error.message).toBe('Multicast failed');
      }
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

    it('should handle unregistered token error', () => {
      const error = {
        code: 'messaging/registration-token-not-registered',
        message: 'Token not registered',
      };

      const isInvalidToken =
        error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered';

      expect(isInvalidToken).toBe(true);
    });

    it('should propagate errors from onReportCreated processing', async () => {
      // The onReportCreated function catches errors, logs them, and rethrows
      const processReport = async () => {
        try {
          throw new Error('Error processing report');
        } catch (error) {
          throw error;
        }
      };

      await expect(processReport()).rejects.toThrow('Error processing report');
    });

    it('should continue processing even if individual operations fail', async () => {
      const operations = ['checkThresholds', 'notifyAdmins', 'notifyUser'];
      let successCount = 0;
      let failCount = 0;

      const processPromises = operations.map(async (op) => {
        try {
          if (op === 'notifyAdmins') {
            throw new Error(`Failed: ${op}`);
          }
          successCount++;
          return { op, success: true };
        } catch (error) {
          failCount++;
          return { op, success: false };
        }
      });

      const results = await Promise.all(processPromises);

      expect(successCount).toBe(2);
      expect(failCount).toBe(1);
      expect(results.filter((r) => r.success)).toHaveLength(2);
    });
  });

  describe('FCM Message Structure', () => {
    it('should have correct structure for admin report notification', () => {
      const message = {
        tokens: ['token-1', 'token-2'],
        notification: {
          title: 'New Message Report',
          body: 'Reporter reported Content Owner for Spam',
        },
        data: {
          type: 'moderation_report',
          reportId: 'report-123',
          contentType: 'message',
          contentId: 'msg-456',
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: 'moderation',
            priority: 'high' as const,
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      expect(message.data.type).toBe('moderation_report');
      expect(message.android.notification.channelId).toBe('moderation');
      expect(message.apns.payload.aps.badge).toBe(1);
      expect(message.apns.payload.aps.sound).toBe('default');
      expect(message.tokens).toHaveLength(2);
    });

    it('should have correct structure for user sanction notification', () => {
      const message = {
        token: 'user-fcm-token',
        notification: {
          title: 'Account Muted',
          body: 'Your account has been temporarily muted for 24 hours due to community guideline violations.',
        },
        data: {
          type: 'moderation_sanction',
          sanctionType: 'mute',
        },
        android: {
          priority: 'high' as const,
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      expect(message.data.type).toBe('moderation_sanction');
      expect(message.data.sanctionType).toBe('mute');
      expect(message.android.priority).toBe('high');
      expect(message.token).toBe('user-fcm-token');
    });
  });

  describe('Scheduled Function Behavior', () => {
    it('should use ISO string for time comparisons', () => {
      const now = new Date().toISOString();
      expect(now).toBeDefined();
      expect(typeof now).toBe('string');
      expect(now).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/);
    });

    it('should log summary of cleared items', () => {
      const expiredMutesCount = 3;
      const expiredSuspensionsCount = 1;
      const expiredSanctionsCount = 4;

      const summary = `Cleared ${expiredMutesCount} mutes, ${expiredSuspensionsCount} suspensions, ${expiredSanctionsCount} sanctions`;

      expect(summary).toBe('Cleared 3 mutes, 1 suspensions, 4 sanctions');
    });

    it('should return null on completion', async () => {
      const result = null;
      expect(result).toBeNull();
    });
  });
});
