import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * HTTP endpoint for testing favorite team notifications locally
 * Call: curl https://us-central1-pregame-b089e.cloudfunctions.net/testFavoriteTeamNotifications
 */
export const testFavoriteTeamNotificationsHttp = functions.https.onRequest(async (req, res) => {
  const results: any = {
    timestamp: new Date().toISOString(),
    steps: [],
  };

  try {
    // Step 1: Check for scheduled matches
    const allMatchesSnapshot = await db
      .collection('worldcup_matches')
      .where('status', '==', 'scheduled')
      .limit(10)
      .get();

    results.steps.push({
      step: 1,
      name: 'Scheduled matches check',
      count: allMatchesSnapshot.size,
      sample: allMatchesSnapshot.docs.slice(0, 3).map(doc => {
        const m = doc.data();
        const dateTimeUtc = m.dateTimeUtc && typeof m.dateTimeUtc.toDate === 'function'
          ? m.dateTimeUtc.toDate().toISOString()
          : m.dateTimeUtc;
        return {
          id: doc.id,
          match: `${m.homeTeamName || m.homeTeamCode} vs ${m.awayTeamName || m.awayTeamCode}`,
          dateTimeUtc,
        };
      }),
    });

    // Step 2: Check matches in notification window (24-48 hours)
    const now = admin.firestore.Timestamp.now();
    const in24Hours = admin.firestore.Timestamp.fromMillis(now.toMillis() + 24 * 60 * 60 * 1000);
    const in48Hours = admin.firestore.Timestamp.fromMillis(now.toMillis() + 48 * 60 * 60 * 1000);

    const upcomingMatchesSnapshot = await db
      .collection('worldcup_matches')
      .where('status', '==', 'scheduled')
      .where('dateTimeUtc', '>=', in24Hours)
      .where('dateTimeUtc', '<=', in48Hours)
      .get();

    results.steps.push({
      step: 2,
      name: 'Matches in 24-48 hour window',
      count: upcomingMatchesSnapshot.size,
      matches: upcomingMatchesSnapshot.docs.map(doc => {
        const m = doc.data();
        return {
          id: doc.id,
          match: `${m.homeTeamName} vs ${m.awayTeamName}`,
          homeTeamCode: m.homeTeamCode,
          awayTeamCode: m.awayTeamCode,
        };
      }),
    });

    // Step 3: Check users with favorite teams enabled
    const usersSnapshot = await db
      .collection('users')
      .where('notifyFavoriteTeamMatches', '==', true)
      .limit(20)
      .get();

    results.steps.push({
      step: 3,
      name: 'Users with notifications enabled',
      count: usersSnapshot.size,
      users: usersSnapshot.docs.map(doc => {
        const u = doc.data();
        return {
          id: doc.id.substring(0, 8) + '...',
          favoriteTeams: u.favoriteTeamCodes || [],
          hasFcmToken: !!u.fcmToken,
        };
      }),
    });

    // Step 4: Simulate matching for each upcoming match
    const matchResults: any[] = [];
    for (const matchDoc of upcomingMatchesSnapshot.docs) {
      const match = matchDoc.data();
      const homeTeamCode = match.homeTeamCode?.toUpperCase();
      const awayTeamCode = match.awayTeamCode?.toUpperCase();

      if (!homeTeamCode || !awayTeamCode) continue;

      const matchingUsersSnapshot = await db
        .collection('users')
        .where('notifyFavoriteTeamMatches', '==', true)
        .where('favoriteTeamCodes', 'array-contains-any', [homeTeamCode, awayTeamCode])
        .get();

      matchResults.push({
        matchId: matchDoc.id,
        match: `${match.homeTeamName} vs ${match.awayTeamName}`,
        usersToNotify: matchingUsersSnapshot.size,
        users: matchingUsersSnapshot.docs.map(doc => ({
          id: doc.id.substring(0, 8) + '...',
          favorites: doc.data().favoriteTeamCodes,
        })),
      });
    }

    results.steps.push({
      step: 4,
      name: 'Users matched to upcoming matches',
      matchResults,
    });

    // Step 5: Check sent notifications
    const sentSnapshot = await db
      .collection('sent_notifications')
      .orderBy('sentAt', 'desc')
      .limit(5)
      .get();

    results.steps.push({
      step: 5,
      name: 'Recent sent notification records',
      count: sentSnapshot.size,
      records: sentSnapshot.docs.map(doc => {
        const data = doc.data();
        const sentAt = data.sentAt && typeof data.sentAt.toDate === 'function'
          ? data.sentAt.toDate().toISOString()
          : data.sentAt;
        return {
          id: doc.id,
          matchId: data.matchId,
          homeTeamCode: data.homeTeamCode,
          awayTeamCode: data.awayTeamCode,
          usersNotified: data.usersNotified,
          sentAt,
        };
      }),
    });

    results.success = true;
    res.status(200).json(results);

  } catch (error: any) {
    results.success = false;
    results.error = error.message;
    res.status(500).json(results);
  }
});

/**
 * Scheduled function that runs twice daily to notify users about upcoming
 * matches of their favorite teams (24 hours before kickoff)
 */
export const sendFavoriteTeamNotifications = functions.pubsub
  .schedule('0 8,20 * * *') // 8 AM and 8 PM daily
  .timeZone('America/New_York')
  .onRun(async (context: functions.EventContext) => {
    functions.logger.info('Checking for upcoming favorite team matches...');

    try {
      // Find matches starting in the next 24-28 hours
      // This window ensures we catch matches even with schedule variations
      const now = admin.firestore.Timestamp.now();
      const in24Hours = admin.firestore.Timestamp.fromMillis(
        now.toMillis() + 24 * 60 * 60 * 1000
      );
      const in28Hours = admin.firestore.Timestamp.fromMillis(
        now.toMillis() + 28 * 60 * 60 * 1000
      );

      // Query upcoming matches in the 24-28 hour window
      const matchesSnapshot = await db
        .collection('worldcup_matches')
        .where('status', '==', 'scheduled')
        .where('dateTimeUtc', '>=', in24Hours)
        .where('dateTimeUtc', '<=', in28Hours)
        .get();

      if (matchesSnapshot.empty) {
        functions.logger.info('No upcoming matches in notification window');
        return null;
      }

      functions.logger.info(`Found ${matchesSnapshot.size} upcoming matches in window`);

      // Process each match
      for (const matchDoc of matchesSnapshot.docs) {
        const match = matchDoc.data();
        const matchId = matchDoc.id;

        // Get the teams playing in this match
        const homeTeamCode = match.homeTeamCode?.toUpperCase();
        const awayTeamCode = match.awayTeamCode?.toUpperCase();

        if (!homeTeamCode || !awayTeamCode) {
          functions.logger.info(`Match ${matchId} has undetermined teams, skipping`);
          continue;
        }

        // Check if we've already sent notifications for this match
        const notificationKey = `favorite_team_${matchId}`;
        const existingNotification = await db
          .collection('sent_notifications')
          .doc(notificationKey)
          .get();

        if (existingNotification.exists) {
          functions.logger.info(`Already sent notifications for match ${matchId}`);
          continue;
        }

        // Find users who have favorited either team
        const usersSnapshot = await db
          .collection('users')
          .where('notifyFavoriteTeamMatches', '==', true)
          .where('favoriteTeamCodes', 'array-contains-any', [homeTeamCode, awayTeamCode])
          .get();

        if (usersSnapshot.empty) {
          functions.logger.info(`No users with favorite teams for match ${matchId}`);
          continue;
        }

        functions.logger.info(`Found ${usersSnapshot.size} users to notify for ${match.homeTeamName} vs ${match.awayTeamName}`);

        // Send notifications to each user
        const sendPromises = usersSnapshot.docs.map(async (userDoc) => {
          const userId = userDoc.id;
          const userData = userDoc.data();
          const fcmToken = userData.fcmToken;

          // Determine which team(s) the user follows
          const favoriteTeamCodes = userData.favoriteTeamCodes || [];
          const followsHome = favoriteTeamCodes.includes(homeTeamCode);
          const followsAway = favoriteTeamCodes.includes(awayTeamCode);

          let teamDescription: string;
          if (followsHome && followsAway) {
            teamDescription = `${match.homeTeamName} and ${match.awayTeamName}`;
          } else if (followsHome) {
            teamDescription = match.homeTeamName;
          } else {
            teamDescription = match.awayTeamName;
          }

          // Format match time
          const matchTime = match.dateTimeUtc?.toDate();
          const timeString = matchTime
            ? matchTime.toLocaleString('en-US', {
                weekday: 'short',
                month: 'short',
                day: 'numeric',
                hour: 'numeric',
                minute: '2-digit',
                timeZoneName: 'short',
              })
            : 'Tomorrow';

          const notificationTitle = 'Your Team Plays Tomorrow!';
          const notificationBody = `${teamDescription} ${followsHome && followsAway ? 'face off' : 'plays'} - ${match.homeTeamName} vs ${match.awayTeamName} at ${timeString}`;

          try {
            // Send FCM notification if token exists
            if (fcmToken) {
              const message: admin.messaging.Message = {
                token: fcmToken,
                notification: {
                  title: notificationTitle,
                  body: notificationBody,
                },
                data: {
                  type: 'favorite_team_match',
                  matchId: matchId,
                  homeTeamCode: homeTeamCode,
                  awayTeamCode: awayTeamCode,
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                android: {
                  priority: 'high',
                  notification: {
                    channelId: 'favorite_teams',
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
              functions.logger.info(`Sent FCM notification to user ${userId}`);
            }

            // Create in-app notification
            await createInAppNotification(userId, match, matchId, teamDescription);

          } catch (error: any) {
            functions.logger.error(`Error sending notification to ${userId}:`, error.message);
            // Don't fail the whole batch for one user's error
          }
        });

        await Promise.all(sendPromises);

        // Mark this match as notified
        await db.collection('sent_notifications').doc(notificationKey).set({
          matchId: matchId,
          homeTeamCode: homeTeamCode,
          awayTeamCode: awayTeamCode,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          usersNotified: usersSnapshot.size,
        });

        functions.logger.info(`Completed notifications for match ${matchId}`);
      }

      functions.logger.info('Favorite team notifications completed');
      return null;

    } catch (error) {
      functions.logger.error('Error in sendFavoriteTeamNotifications:', error);
      return null;
    }
  });

/**
 * Creates an in-app notification for the favorite team match
 */
async function createInAppNotification(
  userId: string,
  match: any,
  matchId: string,
  teamDescription: string
) {
  try {
    const matchTime = match.dateTimeUtc?.toDate();
    const timeString = matchTime
      ? matchTime.toLocaleString('en-US', {
          weekday: 'short',
          hour: 'numeric',
          minute: '2-digit',
        })
      : 'Tomorrow';

    const notificationId = `favorite_team_${matchId}_${userId}`;

    await db.collection('notifications').doc(notificationId).set({
      notificationId: notificationId,
      userId: userId,
      type: 'favoriteTeamMatch',
      title: 'Your Team Plays Tomorrow!',
      message: `${teamDescription} has a match coming up - ${match.homeTeamName} vs ${match.awayTeamName} on ${timeString}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      data: {
        matchId: matchId,
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

    functions.logger.info(`Created in-app notification for user ${userId}`);
  } catch (error) {
    functions.logger.error('Error creating in-app notification:', error);
  }
}

/**
 * Cleanup old sent notification records (runs weekly)
 */
export const cleanupSentNotificationRecords = functions.pubsub
  .schedule('0 4 * * 0') // 4 AM every Sunday
  .timeZone('America/New_York')
  .onRun(async (context: functions.EventContext) => {
    functions.logger.info('Starting cleanup of old sent notification records...');

    const thirtyDaysAgo = admin.firestore.Timestamp.fromMillis(
      Date.now() - 30 * 24 * 60 * 60 * 1000
    );

    try {
      const oldRecordsSnapshot = await db
        .collection('sent_notifications')
        .where('sentAt', '<', thirtyDaysAgo)
        .limit(500)
        .get();

      if (oldRecordsSnapshot.empty) {
        functions.logger.info('No old records to clean up');
        return null;
      }

      const batch = db.batch();
      oldRecordsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(`Deleted ${oldRecordsSnapshot.size} old notification records`);

      return null;
    } catch (error) {
      functions.logger.error('Error cleaning up old records:', error);
      return null;
    }
  });
