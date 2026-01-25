import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface Report {
  reportId: string;
  reporterId: string;
  reporterDisplayName: string;
  contentType: string;
  contentId: string;
  contentOwnerId?: string;
  contentOwnerDisplayName?: string;
  reason: string;
  additionalDetails?: string;
  contentSnapshot?: string;
  status: string;
  createdAt: string;
}

interface UserModerationStatus {
  usualId: string;
  warningCount: number;
  reportCount: number;
  isMuted: boolean;
  mutedUntil?: string;
  isSuspended: boolean;
  suspendedUntil?: string;
  isBanned: boolean;
  banReason?: string;
  lastWarningAt?: string;
}

/**
 * Trigger when a new report is created
 * Sends notification to admin users and checks for auto-moderation thresholds
 */
export const onReportCreated = functions.firestore.onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }

    const report = snapshot.data() as Report;
    console.log(`New report created: ${report.reportId}`);

    try {
      // Check if content owner has reached auto-moderation thresholds
      if (report.contentOwnerId) {
        await checkAutoModerationThresholds(report.contentOwnerId);
      }

      // Notify admin users about the new report
      await notifyAdminsOfReport(report);

      console.log(`Report ${report.reportId} processed successfully`);
    } catch (error) {
      console.error("Error processing report:", error);
      throw error;
    }
  }
);

/**
 * Check if user has reached thresholds for automatic moderation actions
 */
async function checkAutoModerationThresholds(userId: string): Promise<void> {
  const statusDoc = await db.collection("user_moderation_status").doc(userId).get();

  if (!statusDoc.exists) {
    return;
  }

  const status = statusDoc.data() as UserModerationStatus;

  // Auto-mute after 5 reports
  if (status.reportCount >= 5 && !status.isMuted && !status.isSuspended && !status.isBanned) {
    console.log(`User ${userId} reached 5 reports - auto-muting for 24 hours`);

    const mutedUntil = new Date();
    mutedUntil.setHours(mutedUntil.getHours() + 24);

    await db.collection("user_moderation_status").doc(userId).update({
      isMuted: true,
      mutedUntil: mutedUntil.toISOString(),
    });

    // Create a sanction record
    await db.collection("user_sanctions").add({
      sanctionId: db.collection("user_sanctions").doc().id,
      usualId: userId,
      type: "mute",
      reason: "Automatic mute: Received 5+ reports",
      action: "temporaryMute",
      createdAt: new Date().toISOString(),
      expiresAt: mutedUntil.toISOString(),
      isActive: true,
      moderatorId: "system",
    });

    // Notify the user
    await notifyUserOfSanction(userId, "mute", "24 hours");
  }

  // Auto-suspend after 10 reports
  if (status.reportCount >= 10 && !status.isSuspended && !status.isBanned) {
    console.log(`User ${userId} reached 10 reports - auto-suspending for 7 days`);

    const suspendedUntil = new Date();
    suspendedUntil.setDate(suspendedUntil.getDate() + 7);

    await db.collection("user_moderation_status").doc(userId).update({
      isMuted: false,
      mutedUntil: null,
      isSuspended: true,
      suspendedUntil: suspendedUntil.toISOString(),
    });

    // Create a sanction record
    await db.collection("user_sanctions").add({
      sanctionId: db.collection("user_sanctions").doc().id,
      usualId: userId,
      type: "suspension",
      reason: "Automatic suspension: Received 10+ reports",
      action: "temporarySuspension",
      createdAt: new Date().toISOString(),
      expiresAt: suspendedUntil.toISOString(),
      isActive: true,
      moderatorId: "system",
    });

    // Notify the user
    await notifyUserOfSanction(userId, "suspension", "7 days");
  }
}

/**
 * Send push notification to admin users about a new report
 */
async function notifyAdminsOfReport(report: Report): Promise<void> {
  // Get all admin users (users with admin custom claim)
  // For now, we'll store admin FCM tokens in a dedicated collection
  const adminsSnapshot = await db.collection("admin_users").get();

  if (adminsSnapshot.empty) {
    console.log("No admin users to notify");
    return;
  }

  const tokens: string[] = [];
  adminsSnapshot.forEach((doc) => {
    const fcmToken = doc.data().fcmToken;
    if (fcmToken) {
      tokens.push(fcmToken);
    }
  });

  if (tokens.length === 0) {
    console.log("No admin FCM tokens found");
    return;
  }

  const reasonText = formatReportReason(report.reason);
  const contentTypeText = formatContentType(report.contentType);

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: `New ${contentTypeText} Report`,
      body: `${report.reporterDisplayName} reported ${report.contentOwnerDisplayName || "content"} for ${reasonText}`,
    },
    data: {
      type: "moderation_report",
      reportId: report.reportId,
      contentType: report.contentType,
      contentId: report.contentId,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "moderation",
        priority: "high",
      },
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: "default",
        },
      },
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`Sent ${response.successCount} admin notifications`);
  } catch (error) {
    console.error("Error sending admin notifications:", error);
  }
}

/**
 * Notify user when they receive a moderation sanction
 */
async function notifyUserOfSanction(
  userId: string,
  sanctionType: string,
  duration: string
): Promise<void> {
  // Get user's FCM token
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) {
    return;
  }

  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) {
    return;
  }

  let title: string;
  let body: string;

  switch (sanctionType) {
    case "mute":
      title = "Account Muted";
      body = `Your account has been temporarily muted for ${duration} due to community guideline violations.`;
      break;
    case "suspension":
      title = "Account Suspended";
      body = `Your account has been suspended for ${duration} due to repeated community guideline violations.`;
      break;
    case "warning":
      title = "Community Guidelines Warning";
      body = "You have received a warning for violating our community guidelines. Further violations may result in account restrictions.";
      break;
    default:
      title = "Account Status Update";
      body = "Your account status has been updated. Please review our community guidelines.";
  }

  const message: admin.messaging.Message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    data: {
      type: "moderation_sanction",
      sanctionType,
    },
    android: {
      priority: "high",
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: "default",
        },
      },
    },
  };

  try {
    await admin.messaging().send(message);
    console.log(`Sent sanction notification to user ${userId}`);
  } catch (error) {
    console.error(`Error sending sanction notification to ${userId}:`, error);
  }

  // Also create an in-app notification
  await db.collection("notifications").add({
    userId,
    type: "moderation",
    title,
    body,
    data: { sanctionType },
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Scheduled function to clear expired sanctions
 * Runs every hour
 */
export const clearExpiredSanctions = functions.scheduler.onSchedule(
  "every 1 hours",
  async () => {
    const now = new Date().toISOString();
    console.log(`Checking for expired sanctions at ${now}`);

    // Find expired mutes
    const expiredMutes = await db
      .collection("user_moderation_status")
      .where("isMuted", "==", true)
      .where("mutedUntil", "<=", now)
      .get();

    for (const doc of expiredMutes.docs) {
      console.log(`Clearing expired mute for user ${doc.id}`);
      await doc.ref.update({
        isMuted: false,
        mutedUntil: null,
      });
    }

    // Find expired suspensions
    const expiredSuspensions = await db
      .collection("user_moderation_status")
      .where("isSuspended", "==", true)
      .where("suspendedUntil", "<=", now)
      .get();

    for (const doc of expiredSuspensions.docs) {
      console.log(`Clearing expired suspension for user ${doc.id}`);
      await doc.ref.update({
        isSuspended: false,
        suspendedUntil: null,
      });
    }

    // Update sanctions to inactive
    const expiredSanctions = await db
      .collection("user_sanctions")
      .where("isActive", "==", true)
      .where("expiresAt", "<=", now)
      .get();

    for (const doc of expiredSanctions.docs) {
      console.log(`Marking sanction ${doc.id} as inactive`);
      await doc.ref.update({
        isActive: false,
      });
    }

    console.log(
      `Cleared ${expiredMutes.size} mutes, ${expiredSuspensions.size} suspensions, ${expiredSanctions.size} sanctions`
    );
  }
);

/**
 * HTTP function for admins to take action on a report
 */
export const resolveReport = functions.https.onCall(async (request) => {
  const { reportId, action, moderatorNotes } = request.data;
  const auth = request.auth;

  if (!auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  // Check if user is admin (via custom claims)
  if (!auth.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Only admins can resolve reports");
  }

  if (!reportId || !action) {
    throw new functions.https.HttpsError("invalid-argument", "reportId and action are required");
  }

  const reportRef = db.collection("reports").doc(reportId);
  const reportDoc = await reportRef.get();

  if (!reportDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Report not found");
  }

  const now = new Date().toISOString();

  await reportRef.update({
    status: "resolved",
    actionTaken: action,
    moderatorId: auth.uid,
    moderatorNotes: moderatorNotes || null,
    reviewedAt: now,
    resolvedAt: now,
  });

  return { success: true, message: "Report resolved successfully" };
});

// Helper functions
function formatReportReason(reason: string): string {
  const reasonMap: { [key: string]: string } = {
    spam: "Spam",
    harassment: "Harassment",
    hateSpeech: "Hate Speech",
    violence: "Violence",
    sexualContent: "Sexual Content",
    misinformation: "Misinformation",
    impersonation: "Impersonation",
    scam: "Scam",
    inappropriateContent: "Inappropriate Content",
    other: "Other",
  };
  return reasonMap[reason] || reason;
}

function formatContentType(contentType: string): string {
  const typeMap: { [key: string]: string } = {
    user: "User",
    message: "Message",
    watchParty: "Watch Party",
    chatRoom: "Chat Room",
    prediction: "Prediction",
    comment: "Comment",
  };
  return typeMap[contentType] || contentType;
}
