import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Scheduled function that runs every minute to check for due match reminders
 * and sends push notifications to users
 */
export const sendMatchReminders = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context: functions.EventContext) => {
    functions.logger.info('Checking for due match reminders...');

    const now = admin.firestore.Timestamp.now();
    const oneMinuteAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - 60 * 1000
    );

    try {
      // Query for reminders that are due (reminderDateTimeUtc <= now)
      // and haven't been sent yet, and the match hasn't started
      const remindersSnapshot = await db
        .collection('match_reminders')
        .where('isEnabled', '==', true)
        .where('isSent', '==', false)
        .where('reminderDateTimeUtc', '<=', now)
        .where('reminderDateTimeUtc', '>=', oneMinuteAgo)
        .get();

      if (remindersSnapshot.empty) {
        functions.logger.info('No due reminders found');
        return null;
      }

      functions.logger.info(`Found ${remindersSnapshot.size} due reminders`);

      const sendPromises = remindersSnapshot.docs.map(async (doc) => {
        const reminder = doc.data();
        const reminderId = doc.id;

        try {
          // Check if match hasn't already started
          const matchDateTime = reminder.matchDateTimeUtc?.toDate();
          if (matchDateTime && new Date() >= matchDateTime) {
            functions.logger.info(`Match already started for reminder ${reminderId}, marking as sent`);
            await doc.ref.update({ isSent: true });
            return;
          }

          // Get user's FCM token
          const userDoc = await db.collection('users').doc(reminder.userId).get();
          const fcmToken = userDoc.exists ? userDoc.data()?.fcmToken : null;

          if (!fcmToken) {
            functions.logger.info(`No FCM token for user ${reminder.userId}, creating in-app notification only`);
            await createInAppNotification(reminder, reminderId);
            await doc.ref.update({ isSent: true });
            return;
          }

          // Build notification message
          const timingMinutes = reminder.timingMinutes || 30;
          const timingDisplay = getTimingDisplay(timingMinutes);
          const matchName = reminder.matchName || 'Match';

          const notificationTitle = 'Match Starting Soon!';
          const notificationBody = `${matchName} kicks off in ${timingDisplay}`;

          // Send FCM notification
          const message: admin.messaging.Message = {
            token: fcmToken,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: {
              type: 'match_reminder',
              matchId: reminder.matchId || '',
              matchName: matchName,
              homeTeamCode: reminder.homeTeamCode || '',
              awayTeamCode: reminder.awayTeamCode || '',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'match_reminders',
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

          await admin.messaging().send(message);
          functions.logger.info(`Sent reminder notification for ${matchName} to user ${reminder.userId}`);

          // Also create in-app notification
          await createInAppNotification(reminder, reminderId);

          // Mark reminder as sent
          await doc.ref.update({ isSent: true });

        } catch (error: any) {
          functions.logger.error(`Error processing reminder ${reminderId}:`, error);

          // If FCM token is invalid, still create in-app notification
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            functions.logger.info(`Invalid FCM token for ${reminderId}, creating in-app notification`);
            await createInAppNotification(reminder, reminderId);
            await doc.ref.update({ isSent: true });
          }
        }
      });

      await Promise.all(sendPromises);
      functions.logger.info(`Processed ${remindersSnapshot.size} reminders`);

      return null;
    } catch (error) {
      functions.logger.error('Error in sendMatchReminders:', error);
      return null;
    }
  });

/**
 * Creates an in-app notification for the match reminder
 */
async function createInAppNotification(reminder: any, reminderId: string) {
  try {
    const timingMinutes = reminder.timingMinutes || 30;
    const timingDisplay = getTimingDisplay(timingMinutes);
    const matchName = reminder.matchName || 'Match';

    const notificationId = `match_reminder_${Date.now()}`;

    await db.collection('notifications').doc(notificationId).set({
      notificationId: notificationId,
      userId: reminder.userId,
      type: 'matchReminder',
      title: 'Match Starting Soon!',
      message: `${matchName} kicks off in ${timingDisplay}${reminder.venueName ? ` at ${reminder.venueName}` : ''}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      data: {
        matchId: reminder.matchId,
        matchName: matchName,
        homeTeamCode: reminder.homeTeamCode,
        awayTeamCode: reminder.awayTeamCode,
        venueName: reminder.venueName,
        matchDateTime: reminder.matchDateTimeUtc,
      },
      actionUrl: `/match/${reminder.matchId}`,
      priority: 'high',
    });

    functions.logger.info(`Created in-app notification for reminder ${reminderId}`);
  } catch (error) {
    functions.logger.error('Error creating in-app notification:', error);
  }
}

/**
 * Converts timing minutes to display string
 */
function getTimingDisplay(minutes: number): string {
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
}

/**
 * Cleanup old sent reminders (runs daily)
 * Removes reminders that were sent more than 7 days ago
 */
export const cleanupOldReminders = functions.pubsub
  .schedule('0 3 * * *') // 3 AM daily
  .timeZone('America/New_York')
  .onRun(async (context: functions.EventContext) => {
    functions.logger.info('Starting old reminders cleanup...');

    const sevenDaysAgo = admin.firestore.Timestamp.fromMillis(
      Date.now() - 7 * 24 * 60 * 60 * 1000
    );

    try {
      // Find old sent reminders
      const oldRemindersSnapshot = await db
        .collection('match_reminders')
        .where('isSent', '==', true)
        .where('matchDateTimeUtc', '<', sevenDaysAgo)
        .limit(500) // Process in batches
        .get();

      if (oldRemindersSnapshot.empty) {
        functions.logger.info('No old reminders to clean up');
        return null;
      }

      // Delete in batches
      const batch = db.batch();
      oldRemindersSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(`Deleted ${oldRemindersSnapshot.size} old reminders`);

      return null;
    } catch (error) {
      functions.logger.error('Error cleaning up old reminders:', error);
      return null;
    }
  });
