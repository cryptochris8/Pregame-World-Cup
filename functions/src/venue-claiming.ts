import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import twilio from "twilio";

const db = admin.firestore();

const MAX_VENUES_PER_USER = 5;
const VERIFICATION_CODE_TTL_MINUTES = 10;
const MAX_CODES_PER_HOUR = 3;
const MAX_CODE_ATTEMPTS = 5;

// =====================
// claimVenue - Transaction-safe venue claiming with per-user limit
// =====================
export const claimVenue = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in to claim a venue.");
  }

  const userId = context.auth.uid;
  const { venueId, businessName, contactEmail, ownerRole, venueType, venuePhoneNumber } = data;

  if (!venueId || !businessName || !contactEmail || !ownerRole || !venueType) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: venueId, businessName, contactEmail, ownerRole, venueType."
    );
  }

  try {
    const result = await db.runTransaction(async (transaction) => {
      // Check if venue is already claimed
      const venueRef = db.collection("venue_enhancements").doc(venueId);
      const venueDoc = await transaction.get(venueRef);

      if (venueDoc.exists) {
        const existingData = venueDoc.data();
        if (existingData && existingData.ownerId) {
          throw new functions.https.HttpsError(
            "already-exists",
            "This venue has already been claimed."
          );
        }
      }

      // Count user's existing claims
      const userClaimsSnapshot = await db
        .collection("venue_enhancements")
        .where("ownerId", "==", userId)
        .get();

      if (userClaimsSnapshot.size >= MAX_VENUES_PER_USER) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          `You have reached the maximum of ${MAX_VENUES_PER_USER} venue claims.`
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      transaction.set(venueRef, {
        ownerId: userId,
        businessName,
        contactEmail,
        ownerRole,
        venueType,
        venuePhoneNumber: venuePhoneNumber || null,
        claimStatus: "pendingVerification",
        isVerified: false,
        subscriptionTier: "free",
        showsMatches: false,
        gameSpecials: [],
        createdAt: now,
        updatedAt: now,
        claimedAt: now,
      });

      return { success: true, venueId };
    });

    functions.logger.info(`Venue ${venueId} claimed by user ${userId}`);
    return result;
  } catch (error: any) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    functions.logger.error("Error claiming venue:", error);
    throw new functions.https.HttpsError("internal", "Failed to claim venue.");
  }
});

// =====================
// sendVenueVerificationCode - Generate and send SMS code
// =====================
export const sendVenueVerificationCode = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  const userId = context.auth.uid;
  const { venueId } = data;

  if (!venueId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing venueId.");
  }

  // Verify caller is the pending claimant
  const venueDoc = await db.collection("venue_enhancements").doc(venueId).get();
  if (!venueDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Venue claim not found.");
  }

  const venueData = venueDoc.data()!;
  if (venueData.ownerId !== userId) {
    throw new functions.https.HttpsError("permission-denied", "You are not the claimant for this venue.");
  }

  if (venueData.claimStatus !== "pendingVerification") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Venue is not in pending verification status."
    );
  }

  // Rate limit: max codes per venue per hour
  const codeRef = db.collection("venue_verification_codes").doc(venueId);
  const codeDoc = await codeRef.get();

  if (codeDoc.exists) {
    const codeData = codeDoc.data()!;
    const codesThisHour = codeData.codesThisHour || 0;
    const hourReset = codeData.hourReset?.toDate();

    if (hourReset && new Date() < hourReset && codesThisHour >= MAX_CODES_PER_HOUR) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Too many verification codes requested. Try again later."
      );
    }
  }

  // Generate 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const now = new Date();
  const expiresAt = new Date(now.getTime() + VERIFICATION_CODE_TTL_MINUTES * 60 * 1000);
  const hourReset = codeDoc.exists && codeDoc.data()!.hourReset?.toDate() > now
    ? codeDoc.data()!.hourReset
    : admin.firestore.Timestamp.fromDate(new Date(now.getTime() + 60 * 60 * 1000));

  const currentCodesThisHour = (codeDoc.exists &&
    codeDoc.data()!.hourReset?.toDate() > now)
    ? (codeDoc.data()!.codesThisHour || 0) + 1
    : 1;

  await codeRef.set({
    code,
    venueId,
    userId,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    attempts: 0,
    codesThisHour: currentCodesThisHour,
    hourReset,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send SMS via Twilio
  const phoneNumber = venueData.venuePhoneNumber || venueData.contactPhone;
  if (phoneNumber) {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const fromNumber = process.env.TWILIO_PHONE_NUMBER;

    if (accountSid && authToken && fromNumber) {
      try {
        const twilioClient = twilio(accountSid, authToken);
        await twilioClient.messages.create({
          body: `Your Pregame World Cup venue verification code is: ${code}`,
          from: fromNumber,
          to: phoneNumber,
        });
        functions.logger.info(`SMS verification code sent to ${phoneNumber} for venue ${venueId}`);
      } catch (smsError: any) {
        functions.logger.error(`Failed to send SMS to ${phoneNumber}: ${smsError.message}`);
        // Still return success - code is stored, user can request resend
      }
    } else {
      functions.logger.warn(`Twilio not configured. Code for venue ${venueId}: ${code}`);
    }
  } else {
    functions.logger.warn(`No phone number available for venue ${venueId}`);
  }

  return { success: true, message: "Verification code sent." };
});

// =====================
// verifyVenueCode - Verify the SMS code
// =====================
export const verifyVenueCode = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  const userId = context.auth.uid;
  const { venueId, code } = data;

  if (!venueId || !code) {
    throw new functions.https.HttpsError("invalid-argument", "Missing venueId or code.");
  }

  // Verify caller is the pending claimant
  const venueDoc = await db.collection("venue_enhancements").doc(venueId).get();
  if (!venueDoc.exists || venueDoc.data()!.ownerId !== userId) {
    throw new functions.https.HttpsError("permission-denied", "You are not the claimant for this venue.");
  }

  const codeRef = db.collection("venue_verification_codes").doc(venueId);
  const codeDoc = await codeRef.get();

  if (!codeDoc.exists) {
    throw new functions.https.HttpsError("not-found", "No verification code found. Please request a new one.");
  }

  const codeData = codeDoc.data()!;

  // Check expiration
  if (codeData.expiresAt.toDate() < new Date()) {
    await codeRef.delete();
    throw new functions.https.HttpsError("deadline-exceeded", "Verification code has expired. Please request a new one.");
  }

  // Check attempts
  if (codeData.attempts >= MAX_CODE_ATTEMPTS) {
    await codeRef.delete();
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Too many incorrect attempts. Please request a new code."
    );
  }

  // Verify code
  if (codeData.code !== code) {
    await codeRef.update({
      attempts: admin.firestore.FieldValue.increment(1),
    });
    const remaining = MAX_CODE_ATTEMPTS - codeData.attempts - 1;
    throw new functions.https.HttpsError(
      "invalid-argument",
      `Incorrect code. ${remaining} attempt${remaining !== 1 ? 's' : ''} remaining.`
    );
  }

  // Code is correct - update claim status to pending_review
  await db.collection("venue_enhancements").doc(venueId).update({
    claimStatus: "pendingReview",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Delete verification code doc
  await codeRef.delete();

  functions.logger.info(`Venue ${venueId} verified by user ${userId}, now pending review`);

  return { success: true, message: "Phone verified. Your claim is now pending admin review." };
});

// =====================
// reviewVenueClaim - Admin approve/reject
// =====================
export const reviewVenueClaim = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  // Admin check
  if (!context.auth.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required.");
  }

  const { venueId, action, adminNotes } = data;

  if (!venueId || !action || !["approve", "reject"].includes(action)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing venueId or invalid action. Must be 'approve' or 'reject'."
    );
  }

  const venueRef = db.collection("venue_enhancements").doc(venueId);
  const venueDoc = await venueRef.get();

  if (!venueDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Venue claim not found.");
  }

  const venueData = venueDoc.data()!;
  const now = admin.firestore.FieldValue.serverTimestamp();

  if (action === "approve") {
    await venueRef.update({
      claimStatus: "approved",
      isVerified: true,
      updatedAt: now,
    });

    functions.logger.info(`Venue ${venueId} claim approved by admin ${context.auth.uid}`);
  } else {
    await venueRef.update({
      claimStatus: "rejected",
      ownerId: "",
      updatedAt: now,
    });

    functions.logger.info(`Venue ${venueId} claim rejected by admin ${context.auth.uid}`);
  }

  // Log admin action
  await db.collection("admin_logs").add({
    action: `venue_claim_${action}`,
    venueId,
    adminId: context.auth.uid,
    previousOwnerId: venueData.ownerId,
    adminNotes: adminNotes || "",
    timestamp: now,
  });

  return { success: true, action };
});

// =====================
// submitVenueDispute - Report a disputed venue claim
// =====================
export const submitVenueDispute = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  const userId = context.auth.uid;
  const { venueId, reason, details } = data;

  if (!venueId || !reason) {
    throw new functions.https.HttpsError("invalid-argument", "Missing venueId or reason.");
  }

  // Get current venue owner
  const venueDoc = await db.collection("venue_enhancements").doc(venueId).get();
  if (!venueDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Venue not found.");
  }

  const venueData = venueDoc.data()!;
  const currentOwnerId = venueData.ownerId || "";

  if (currentOwnerId === userId) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "You cannot dispute your own venue claim."
    );
  }

  await db.collection("venue_disputes").add({
    venueId,
    disputerId: userId,
    currentOwnerId,
    reason,
    details: details || "",
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info(`Venue dispute submitted for ${venueId} by user ${userId}`);

  return { success: true, message: "Dispute submitted for review." };
});
