import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a new friend request notification document is created
 * Sends push notification to the recipient
 */
export const onFriendRequestNotificationCreated = functions.firestore
  .document('friend_request_notifications/{notificationId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const notificationData = snapshot.data();
    const notificationId = context.params.notificationId;

    functions.logger.info(`Friend request notification created: ${notificationId}`);

    // Skip if already processed
    if (notificationData.processed) {
      functions.logger.info('Notification already processed, skipping');
      return null;
    }

    try {
      const {
        connectionId,
        fromUserId,
        fromUserName,
        fromUserImageUrl,
        toUserId,
        type,
      } = notificationData;

      if (!toUserId) {
        functions.logger.warn('No recipient specified');
        await markAsProcessed(notificationId);
        return null;
      }

      // Get recipient's FCM token
      const userDoc = await db.collection('users').doc(toUserId).get();

      if (!userDoc.exists) {
        functions.logger.warn(`User ${toUserId} not found`);
        await markAsProcessed(notificationId);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;

      // Check notification preferences
      const prefsDoc = await db.collection('notification_preferences').doc(toUserId).get();
      const prefs = prefsDoc.exists ? prefsDoc.data() : null;

      // Skip if user has friend request notifications disabled
      if (prefs && prefs.friendRequests === false) {
        functions.logger.info(`User ${toUserId} has friend request notifications disabled`);
        await markAsProcessed(notificationId);
        // Still create in-app notification
        await createInAppNotification(notificationData, notificationId);
        return null;
      }

      // Build notification content based on type
      let notificationTitle: string;
      let notificationBody: string;

      if (type === 'friend_request_accepted') {
        notificationTitle = 'Friend Request Accepted';
        notificationBody = `${fromUserName} accepted your friend request`;
      } else {
        notificationTitle = 'New Friend Request';
        notificationBody = `${fromUserName} wants to be your friend`;
      }

      // Send FCM notification if token exists
      if (fcmToken) {
        const message: admin.messaging.Message = {
          token: fcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            type: type || 'friend_request',
            connectionId: connectionId || '',
            fromUserId: fromUserId,
            fromUserName: fromUserName || '',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'friend_requests',
              priority: 'high',
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

        try {
          const response = await admin.messaging().send(message);
          functions.logger.info(`Sent FCM to ${toUserId}: ${response}`);
        } catch (fcmError: any) {
          functions.logger.error(`FCM send failed for ${toUserId}:`, fcmError.message);

          // Remove invalid token
          if (fcmError.code === 'messaging/invalid-registration-token' ||
              fcmError.code === 'messaging/registration-token-not-registered') {
            await db.collection('users').doc(toUserId).update({
              fcmToken: admin.firestore.FieldValue.delete(),
            });
            functions.logger.info(`Removed invalid FCM token for ${toUserId}`);
          }
        }
      } else {
        functions.logger.info(`User ${toUserId} has no FCM token`);
      }

      // Create in-app notification
      await createInAppNotification(notificationData, notificationId);

      // Mark as processed
      await markAsProcessed(notificationId);

      return { success: true };
    } catch (error: any) {
      functions.logger.error('Error processing friend request notification:', error);
      await markAsProcessed(notificationId, error.message);
      return null;
    }
  });

/**
 * Mark notification document as processed
 */
async function markAsProcessed(notificationId: string, error?: string) {
  try {
    await db.collection('friend_request_notifications').doc(notificationId).update({
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      error: error || null,
    });
  } catch (e) {
    functions.logger.error('Error marking notification as processed:', e);
  }
}

/**
 * Create in-app notification for friend request
 */
async function createInAppNotification(notificationData: any, docId: string) {
  try {
    const {
      connectionId,
      fromUserId,
      fromUserName,
      fromUserImageUrl,
      toUserId,
      type,
    } = notificationData;

    const isAccepted = type === 'friend_request_accepted';
    const notificationId = `friend_${isAccepted ? 'accepted' : 'request'}_${Date.now()}`;

    const notificationDoc = {
      notificationId: notificationId,
      userId: toUserId,
      fromUserId: fromUserId,
      fromUserName: fromUserName || 'Someone',
      fromUserImage: fromUserImageUrl,
      type: isAccepted ? 'friendRequestAccepted' : 'friendRequest',
      title: isAccepted ? 'Friend Request Accepted' : 'New Friend Request',
      message: isAccepted
        ? `${fromUserName || 'Someone'} accepted your friend request`
        : `${fromUserName || 'Someone'} wants to be your friend`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      data: {
        connectionId: connectionId,
        fromUserId: fromUserId,
      },
      actionUrl: isAccepted ? `/profile/${fromUserId}` : '/friends/requests',
      priority: 'high',
    };

    await db.collection('notifications').doc(notificationId).set(notificationDoc);
    functions.logger.info(`Created in-app notification for user ${toUserId}`);
  } catch (error) {
    functions.logger.error('Error creating in-app notification:', error);
  }
}

/**
 * Cleanup old processed notification documents (run daily)
 */
export const cleanupOldFriendRequestNotifications = functions.pubsub
  .schedule('0 4 * * *')
  .timeZone('America/New_York')
  .onRun(async () => {
    functions.logger.info('Starting cleanup of old friend request notifications');

    try {
      // Delete notifications older than 7 days
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const oldNotifications = await db
        .collection('friend_request_notifications')
        .where('processed', '==', true)
        .where('processedAt', '<', admin.firestore.Timestamp.fromDate(sevenDaysAgo))
        .limit(500)
        .get();

      if (oldNotifications.empty) {
        functions.logger.info('No old notifications to clean up');
        return null;
      }

      const batch = db.batch();
      oldNotifications.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(`Deleted ${oldNotifications.docs.length} old friend request notifications`);

      return null;
    } catch (error) {
      functions.logger.error('Error cleaning up old notifications:', error);
      return null;
    }
  });
