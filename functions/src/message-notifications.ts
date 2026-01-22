import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a new message notification document is created
 * Sends push notifications to all recipients
 */
export const onMessageNotificationCreated = functions.firestore
  .document('message_notifications/{notificationId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const notificationData = snapshot.data();
    const notificationId = context.params.notificationId;

    functions.logger.info(`New message notification created: ${notificationId}`);

    // Skip if already processed
    if (notificationData.processed) {
      functions.logger.info('Notification already processed, skipping');
      return null;
    }

    try {
      const {
        chatId,
        messageId,
        senderId,
        senderName,
        senderImageUrl,
        content,
        messageType,
        recipientIds,
        chatName,
        chatType,
      } = notificationData;

      if (!recipientIds || recipientIds.length === 0) {
        functions.logger.warn('No recipients specified');
        await markAsProcessed(notificationId);
        return null;
      }

      functions.logger.info(`Sending notifications to ${recipientIds.length} recipients`);

      // Get FCM tokens for all recipients
      const sendPromises = recipientIds.map(async (recipientId: string) => {
        try {
          // Get recipient's FCM token
          const userDoc = await db.collection('users').doc(recipientId).get();

          if (!userDoc.exists) {
            functions.logger.warn(`User ${recipientId} not found`);
            return null;
          }

          const userData = userDoc.data();
          const fcmToken = userData?.fcmToken;

          // Check notification preferences
          const prefsDoc = await db.collection('notification_preferences').doc(recipientId).get();
          const prefs = prefsDoc.exists ? prefsDoc.data() : null;

          // Skip if user has message notifications disabled
          if (prefs && prefs.messages === false) {
            functions.logger.info(`User ${recipientId} has message notifications disabled`);
            return null;
          }

          // Check quiet hours
          if (prefs && isInQuietHours(prefs)) {
            functions.logger.info(`User ${recipientId} is in quiet hours`);
            return null;
          }

          // Build notification content
          const notificationTitle = chatType === 'direct'
            ? senderName
            : chatName || 'New Message';

          let notificationBody = content;
          if (messageType !== 'text') {
            notificationBody = getMessageTypeText(messageType, senderName);
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
                type: 'new_message',
                chatId: chatId,
                messageId: messageId,
                senderId: senderId,
                senderName: senderName,
                chatName: chatName || '',
                chatType: chatType || 'direct',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'messages',
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
                    'mutable-content': 1,
                  },
                },
              },
            };

            try {
              const response = await admin.messaging().send(message);
              functions.logger.info(`Sent FCM to ${recipientId}: ${response}`);
            } catch (fcmError: any) {
              functions.logger.error(`FCM send failed for ${recipientId}:`, fcmError.message);

              // Remove invalid token
              if (fcmError.code === 'messaging/invalid-registration-token' ||
                  fcmError.code === 'messaging/registration-token-not-registered') {
                await db.collection('users').doc(recipientId).update({
                  fcmToken: admin.firestore.FieldValue.delete(),
                });
                functions.logger.info(`Removed invalid FCM token for ${recipientId}`);
              }
            }
          } else {
            functions.logger.info(`User ${recipientId} has no FCM token`);
          }

          // Create in-app notification
          await createInAppMessageNotification(recipientId, notificationData);

          return { recipientId, success: true };
        } catch (recipientError: any) {
          functions.logger.error(`Error processing recipient ${recipientId}:`, recipientError.message);
          return { recipientId, success: false, error: recipientError.message };
        }
      });

      const results = await Promise.all(sendPromises);
      const successCount = results.filter((r: any) => r?.success).length;

      functions.logger.info(`Sent notifications: ${successCount}/${recipientIds.length} successful`);

      // Mark notification as processed
      await markAsProcessed(notificationId);

      return { success: true, sent: successCount, total: recipientIds.length };
    } catch (error: any) {
      functions.logger.error('Error processing message notification:', error);
      await markAsProcessed(notificationId, error.message);
      return null;
    }
  });

/**
 * Mark notification document as processed
 */
async function markAsProcessed(notificationId: string, error?: string) {
  try {
    await db.collection('message_notifications').doc(notificationId).update({
      processed: true,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      error: error || null,
    });
  } catch (e) {
    functions.logger.error('Error marking notification as processed:', e);
  }
}

/**
 * Create in-app notification for message
 */
async function createInAppMessageNotification(userId: string, notificationData: any) {
  try {
    const notificationId = `msg_${notificationData.chatId}_${Date.now()}`;

    const notificationDoc = {
      notificationId: notificationId,
      userId: userId,
      fromUserId: notificationData.senderId,
      fromUserName: notificationData.senderName,
      fromUserImage: notificationData.senderImageUrl,
      type: 'newMessage',
      title: notificationData.chatType === 'direct'
        ? notificationData.senderName
        : notificationData.chatName || 'New Message',
      message: notificationData.content,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
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

    await db.collection('notifications').doc(notificationId).set(notificationDoc);
    functions.logger.info(`Created in-app notification for user ${userId}`);
  } catch (error) {
    functions.logger.error('Error creating in-app notification:', error);
  }
}

/**
 * Check if current time is within user's quiet hours
 */
function isInQuietHours(prefs: any): boolean {
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
}

/**
 * Get human-readable text for non-text message types
 */
function getMessageTypeText(type: string, senderName: string): string {
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
}

/**
 * Cleanup old processed notification documents (run daily)
 */
export const cleanupOldMessageNotifications = functions.pubsub
  .schedule('0 3 * * *')
  .timeZone('America/New_York')
  .onRun(async () => {
    functions.logger.info('Starting cleanup of old message notifications');

    try {
      // Delete notifications older than 7 days
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const oldNotifications = await db
        .collection('message_notifications')
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
      functions.logger.info(`Deleted ${oldNotifications.docs.length} old message notifications`);

      return null;
    } catch (error) {
      functions.logger.error('Error cleaning up old notifications:', error);
      return null;
    }
  });
