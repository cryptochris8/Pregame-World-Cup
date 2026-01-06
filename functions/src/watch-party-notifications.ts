import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a new watch party invite is created
 * Sends push notification to the invitee
 */
export const onWatchPartyInviteCreated = functions.firestore
  .document('watch_party_invites/{inviteId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const inviteData = snapshot.data();
    const inviteId = context.params.inviteId;

    functions.logger.info(`New watch party invite created: ${inviteId}`);

    try {
      const inviteeId = inviteData.inviteeId;
      const inviterId = inviteData.inviterId;
      const inviterName = inviteData.inviterName || 'Someone';
      const watchPartyId = inviteData.watchPartyId;
      const watchPartyName = inviteData.watchPartyName || 'Watch Party';
      const personalMessage = inviteData.message;

      if (!inviteeId) {
        functions.logger.warn('No invitee ID found in invite document');
        return null;
      }

      // Get invitee's FCM token from their user profile
      const userDoc = await db.collection('users').doc(inviteeId).get();

      if (!userDoc.exists) {
        functions.logger.warn(`User ${inviteeId} not found`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;

      if (!fcmToken) {
        functions.logger.info(`User ${inviteeId} does not have an FCM token registered`);
        // Still create the in-app notification even without FCM token
        await createInAppNotification(inviteData, inviteId);
        return null;
      }

      // Build notification message
      const notificationTitle = 'Watch Party Invitation';
      let notificationBody = `${inviterName} invited you to "${watchPartyName}"`;
      if (personalMessage) {
        notificationBody = `${inviterName}: "${personalMessage}"`;
      }

      // Send FCM notification
      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          type: 'watch_party_invite',
          inviteId: inviteId,
          watchPartyId: watchPartyId,
          inviterId: inviterId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'watch_party_invites',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
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

      const response = await admin.messaging().send(message);
      functions.logger.info(`Successfully sent FCM notification: ${response}`);

      // Also create in-app notification
      await createInAppNotification(inviteData, inviteId);

      return response;
    } catch (error: any) {
      functions.logger.error('Error sending watch party invite notification:', error);

      // If FCM fails due to invalid token, still try to create in-app notification
      if (error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered') {
        functions.logger.info('FCM token invalid, creating in-app notification only');
        await createInAppNotification(inviteData, inviteId);
      }

      return null;
    }
  });

/**
 * Creates an in-app notification document
 */
async function createInAppNotification(inviteData: any, inviteId: string) {
  try {
    const notificationId = `watch_party_invite_${Date.now()}`;

    const notificationDoc = {
      notificationId: notificationId,
      userId: inviteData.inviteeId,
      fromUserId: inviteData.inviterId,
      fromUserName: inviteData.inviterName || 'Someone',
      fromUserImage: inviteData.inviterImageUrl,
      type: 'watchPartyInvite',
      title: 'Watch Party Invitation',
      message: inviteData.message
        ? `${inviteData.inviterName || 'Someone'} invited you to "${inviteData.watchPartyName}": ${inviteData.message}`
        : `${inviteData.inviterName || 'Someone'} invited you to watch together`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      data: {
        inviteId: inviteId,
        watchPartyId: inviteData.watchPartyId,
        watchPartyName: inviteData.watchPartyName,
        gameName: inviteData.gameName,
        gameDateTime: inviteData.gameDateTime,
      },
      actionUrl: `/watch-party/${inviteData.watchPartyId}`,
      priority: 'high',
    };

    await db.collection('notifications').doc(notificationId).set(notificationDoc);
    functions.logger.info(`Created in-app notification: ${notificationId}`);
  } catch (error) {
    functions.logger.error('Error creating in-app notification:', error);
  }
}

/**
 * Triggered when a watch party invite status changes (accepted/declined)
 * Notifies the host
 */
export const onWatchPartyInviteUpdated = functions.firestore
  .document('watch_party_invites/{inviteId}')
  .onUpdate(async (change: functions.Change<functions.firestore.QueryDocumentSnapshot>, context: functions.EventContext) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const inviteId = context.params.inviteId;

    // Only send notification if status changed
    if (beforeData.status === afterData.status) {
      return null;
    }

    const newStatus = afterData.status;

    // Only notify on accepted or declined
    if (newStatus !== 'accepted' && newStatus !== 'declined') {
      return null;
    }

    functions.logger.info(`Watch party invite ${inviteId} status changed to ${newStatus}`);

    try {
      // Get the host's user document to send them a notification
      const watchPartyDoc = await db.collection('watch_parties').doc(afterData.watchPartyId).get();

      if (!watchPartyDoc.exists) {
        functions.logger.warn(`Watch party ${afterData.watchPartyId} not found`);
        return null;
      }

      const watchPartyData = watchPartyDoc.data();
      const hostId = watchPartyData?.hostId;

      if (!hostId) {
        functions.logger.warn('No host ID found for watch party');
        return null;
      }

      // Get invitee's name for the notification
      const inviteeDoc = await db.collection('users').doc(afterData.inviteeId).get();
      const inviteeName = inviteeDoc.exists
        ? inviteeDoc.data()?.displayName || 'Someone'
        : 'Someone';

      // Get host's FCM token
      const hostDoc = await db.collection('users').doc(hostId).get();
      const hostFcmToken = hostDoc.exists ? hostDoc.data()?.fcmToken : null;

      const notificationTitle = newStatus === 'accepted'
        ? 'Invite Accepted!'
        : 'Invite Declined';
      const notificationBody = newStatus === 'accepted'
        ? `${inviteeName} is joining your watch party "${afterData.watchPartyName}"`
        : `${inviteeName} can't make it to "${afterData.watchPartyName}"`;

      // Send FCM if token exists
      if (hostFcmToken) {
        const message: admin.messaging.Message = {
          token: hostFcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            type: 'watch_party_invite_response',
            inviteId: inviteId,
            watchPartyId: afterData.watchPartyId,
            status: newStatus,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'watch_party_updates',
              priority: 'high',
            },
          },
          apns: {
            payload: {
              aps: {
                alert: {
                  title: notificationTitle,
                  body: notificationBody,
                },
                sound: 'default',
              },
            },
          },
        };

        try {
          await admin.messaging().send(message);
          functions.logger.info(`Sent FCM notification to host ${hostId}`);
        } catch (fcmError) {
          functions.logger.error('FCM send failed:', fcmError);
        }
      }

      // Create in-app notification for host
      const notificationId = `invite_response_${Date.now()}`;
      await db.collection('notifications').doc(notificationId).set({
        notificationId: notificationId,
        userId: hostId,
        fromUserId: afterData.inviteeId,
        fromUserName: inviteeName,
        fromUserImage: inviteeDoc.exists ? inviteeDoc.data()?.profileImageUrl : null,
        type: newStatus === 'accepted' ? 'watchPartyInviteAccepted' : 'watchPartyInviteDeclined',
        title: notificationTitle,
        message: notificationBody,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        data: {
          inviteId: inviteId,
          watchPartyId: afterData.watchPartyId,
          watchPartyName: afterData.watchPartyName,
          status: newStatus,
        },
        actionUrl: `/watch-party/${afterData.watchPartyId}`,
        priority: 'normal',
      });

      return null;
    } catch (error) {
      functions.logger.error('Error handling invite status update:', error);
      return null;
    }
  });

/**
 * Triggered when a watch party is cancelled
 * Notifies all members
 */
export const onWatchPartyCancelled = functions.firestore
  .document('watch_parties/{watchPartyId}')
  .onUpdate(async (change: functions.Change<functions.firestore.QueryDocumentSnapshot>, context: functions.EventContext) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const watchPartyId = context.params.watchPartyId;

    // Only process if status changed to cancelled
    if (beforeData.status === afterData.status || afterData.status !== 'cancelled') {
      return null;
    }

    functions.logger.info(`Watch party ${watchPartyId} was cancelled`);

    try {
      // Get all members
      const membersSnapshot = await db
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('members')
        .get();

      if (membersSnapshot.empty) {
        functions.logger.info('No members to notify');
        return null;
      }

      const hostId = afterData.hostId;
      const watchPartyName = afterData.name || 'Watch Party';
      const gameName = afterData.gameName || 'the game';

      // Send notification to each member (except host)
      const notificationPromises = membersSnapshot.docs
        .filter(doc => doc.id !== hostId)
        .map(async (memberDoc) => {
          const memberId = memberDoc.id;

          try {
            // Create in-app notification
            const notificationId = `party_cancelled_${memberId}_${Date.now()}`;
            await db.collection('notifications').doc(notificationId).set({
              notificationId: notificationId,
              userId: memberId,
              fromUserId: hostId,
              fromUserName: afterData.hostName || 'Host',
              type: 'watchPartyCancelled',
              title: 'Watch Party Cancelled',
              message: `"${watchPartyName}" for ${gameName} has been cancelled`,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              isRead: false,
              data: {
                watchPartyId: watchPartyId,
                watchPartyName: watchPartyName,
              },
              priority: 'high',
            });

            // Try to send FCM
            const userDoc = await db.collection('users').doc(memberId).get();
            const fcmToken = userDoc.exists ? userDoc.data()?.fcmToken : null;

            if (fcmToken) {
              await admin.messaging().send({
                token: fcmToken,
                notification: {
                  title: 'Watch Party Cancelled',
                  body: `"${watchPartyName}" for ${gameName} has been cancelled`,
                },
                data: {
                  type: 'watch_party_cancelled',
                  watchPartyId: watchPartyId,
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
              });
            }
          } catch (memberError) {
            functions.logger.error(`Failed to notify member ${memberId}:`, memberError);
          }
        });

      await Promise.all(notificationPromises);
      functions.logger.info(`Notified ${membersSnapshot.docs.length - 1} members about cancellation`);

      return null;
    } catch (error) {
      functions.logger.error('Error handling watch party cancellation:', error);
      return null;
    }
  });
