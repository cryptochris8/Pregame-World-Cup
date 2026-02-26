/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import express from "express";
import * as functionsV1 from "firebase-functions/v1";
import { checkRateLimit, RATE_LIMITS, cleanupExpiredRateLimits } from './rate-limiter';
import { cleanupExpiredWebhookEvents } from './stripe-config';

// Initialize Firebase Admin SDK
admin.initializeApp();
functions.logger.info("Firebase Admin SDK initialized. App name:", admin.app().name);
const db = admin.firestore();
functions.logger.info("Firestore instance obtained. Project ID from Admin SDK config:", admin.app().options.projectId);

// Google Places API key (set in .env.{project-id} or Cloud Functions environment)
const PLACES_API_KEY = process.env.PLACES_API_KEY;

/**
 * Verify Firebase Auth ID token from Authorization header.
 * Returns the decoded token if valid, or null if missing/invalid.
 * Writes a 401 response when auth fails.
 */
async function verifyAuthToken(
  request: functions.https.Request,
  response: express.Response
): Promise<admin.auth.DecodedIdToken | null> {
  const authHeader = request.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    response.status(401).json({ error: 'Missing or invalid Authorization header' });
    return null;
  }

  try {
    const token = authHeader.split('Bearer ')[1];
    return await admin.auth().verifyIdToken(token);
  } catch {
    response.status(401).json({ error: 'Invalid or expired auth token' });
    return null;
  }
}

if (!PLACES_API_KEY) {
  functions.logger.warn("PLACES_API_KEY not configured. getNearbyVenuesHttp and placePhotoProxy will be unavailable.");
}

// Cloud Function to get nearby venues using Google Places API
export const getNearbyVenuesHttp = functions.https.onRequest(async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight OPTIONS request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  // Verify Firebase Auth token
  const decodedToken = await verifyAuthToken(request, response);
  if (!decodedToken) return;

  if (!(await checkRateLimit(request, response, 'getNearbyVenuesHttp', RATE_LIMITS.VENUE))) return;

  functions.logger.info("getNearbyVenuesHttp function triggered!");

  const lat = request.query.lat?.toString();
  const lng = request.query.lng?.toString();
  const radius = request.query.radius?.toString() || "2000"; // Default 2km
  const requestedTypesString = request.query.types?.toString() || "restaurant|bar"; 

  if (!lat || !lng) {
    functions.logger.error("Missing latitude or longitude query parameters.");
    response.status(400).send("Missing latitude (lat) or longitude (lng) query parameters.");
    return;
  }

  if (!PLACES_API_KEY) { // Check if the environment variable was loaded
    functions.logger.error("Google Places API key (PLACES_API_KEY) is not configured in the function environment.");
    response.status(500).send("API key configuration error for Places API.");
    return;
  }

  // Split the requested types. Places API Nearby Search officially supports one type per request.
  const typesToFetch = requestedTypesString.split(/[|,]/).map(type => type.trim()).filter(type => type);

  if (typesToFetch.length === 0) {
    functions.logger.warn("No valid types provided after parsing. Defaulting to 'restaurant'.");
    typesToFetch.push("restaurant");
  }

  const allResults: any[] = [];
  const fetchedPlaceIds = new Set<string>();

  try {
    for (const type of typesToFetch) {
      const placesUrl = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=${type}&key=${PLACES_API_KEY}`;
      functions.logger.info(`Fetching places of type '${type}' from URL: ${placesUrl}`);
      
      const placesResponse = await axios.get(placesUrl);

      if (placesResponse.data.status === "OK") {
        const places = placesResponse.data.results;
        for (const place of places) {
          if (place.place_id && place.name && !fetchedPlaceIds.has(place.place_id)) {
            // Get the first photo reference if available
            const photoReference = place.photos?.[0]?.photo_reference || null;

            allResults.push({
              placeId: place.place_id,
              name: place.name,
              vicinity: place.vicinity,
              rating: place.rating,
              userRatingsTotal: place.user_ratings_total,
              types: place.types,
              latitude: place.geometry?.location?.lat,
              longitude: place.geometry?.location?.lng,
              priceLevel: place.price_level,
              photoReference: photoReference,
            });
            fetchedPlaceIds.add(place.place_id);
          }
        }
        functions.logger.info(`Fetched ${places.length} results for type '${type}', added ${allResults.length - fetchedPlaceIds.size} new unique places.`);
      } else {
        functions.logger.warn(`Google Places API Error for type '${type}': ${placesResponse.data.status} - ${placesResponse.data.error_message || 'Unknown error'}`);
        // Continue to next type if one type fails
      }
      // Optional: Add a small delay between calls for different types if hitting limits, though less likely than per-game calls.
      // await new Promise(resolve => setTimeout(resolve, 200)); 
    }

    functions.logger.info(`Total unique places fetched: ${allResults.length}`);
    response.status(200).json(allResults);

  } catch (error: any) {
    functions.logger.error("Error calling Google Places API or processing results:", error.message);
    if (error.response) {
      functions.logger.error("Google Places API Full Error Response:", error.response.status, error.response.data);
    }
    response.status(500).send("Failed to fetch data from Google Places API.");
  }
});


// Cloud Function to proxy Google Places photo requests (avoids CORS issues in browser)
// Using v1 (Gen 1) functions for simpler deployment without Cloud Run container issues
export const placePhotoProxy = functionsV1.https.onRequest(async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight OPTIONS request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  // Note: No auth check here -- this endpoint is used as an image URL in
  // Image.network() which cannot send Authorization headers. Rate limiting
  // and the fact that it only proxies public Google photos provide sufficient
  // protection.
  if (!(await checkRateLimit(request, response, 'placePhotoProxy', RATE_LIMITS.VENUE))) return;

  const photoReference = request.query.photoReference?.toString();
  const maxWidth = request.query.maxWidth?.toString() || '400';

  if (!photoReference) {
    response.status(400).send("Missing photoReference query parameter.");
    return;
  }

  if (!PLACES_API_KEY) {
    functions.logger.error("PLACES_API_KEY not configured");
    response.status(500).send("API key configuration error.");
    return;
  }

  try {
    const photoUrl = `https://maps.googleapis.com/maps/api/place/photo?photo_reference=${photoReference}&maxwidth=${maxWidth}&key=${PLACES_API_KEY}`;

    // Fetch the photo from Google and stream it back
    const photoResponse = await axios.get(photoUrl, {
      responseType: 'arraybuffer',
      maxRedirects: 5,
      timeout: 10000,
    });

    // Set appropriate headers for the image
    response.set('Content-Type', photoResponse.headers['content-type'] || 'image/jpeg');
    response.set('Cache-Control', 'public, max-age=86400'); // Cache for 24 hours
    response.send(photoResponse.data);

  } catch (error: any) {
    functions.logger.error("Error fetching place photo:", error.message);
    response.status(500).send("Failed to fetch photo.");
  }
});

// Scheduled cleanup for rate limit and webhook event documents (runs daily at 3 AM EST)
export const cleanupRateLimits = functionsV1.pubsub.schedule('0 3 * * *')
  .timeZone('America/New_York')
  .onRun(async () => {
    functions.logger.info('Running scheduled cleanup');
    const rateLimitDeleted = await cleanupExpiredRateLimits();
    const webhookEventsDeleted = await cleanupExpiredWebhookEvents();
    functions.logger.info(`Cleanup complete: ${rateLimitDeleted} rate limits, ${webhookEventsDeleted} webhook events deleted`);
    return null;
  });

// Export Stripe functions
export {
  createCheckoutSession,
  createPortalSession,
  createPaymentIntent,
  handleStripeWebhook,
  setupFreeFanAccount,
  setupFreeVenueAccount,
  createFanCheckoutSession
} from './stripe-simple';

// Export Watch Party Payment functions
export {
  createVirtualAttendancePayment,
  handleVirtualAttendancePayment,
  requestVirtualAttendanceRefund,
  refundAllVirtualAttendees,
  handleWatchPartyWebhook
} from './watch-party-payments';

// Export Watch Party Notification functions
export {
  onWatchPartyInviteCreated,
  onWatchPartyInviteUpdated,
  onWatchPartyCancelled
} from './watch-party-notifications';

// Export Match Reminder functions
export {
  sendMatchReminders,
  cleanupOldReminders
} from './match-reminders';

// Export Favorite Team Notification functions
export {
  sendFavoriteTeamNotifications,
  cleanupSentNotificationRecords,
  testFavoriteTeamNotificationsHttp
} from './favorite-team-notifications';

// Export World Cup Payment functions
export {
  createFanPassCheckout,
  getFanPassStatus,
  createVenuePremiumCheckout,
  getVenuePremiumStatus,
  handleWorldCupPaymentWebhook,
  checkFanPassAccess,
  getWorldCupPricing,
  checkExpiredPasses
} from './world-cup-payments';

// Export Message Notification functions
export {
  onMessageNotificationCreated,
  cleanupOldMessageNotifications
} from './message-notifications';

// Export Friend Request Notification functions
export {
  onFriendRequestNotificationCreated,
  cleanupOldFriendRequestNotifications
} from './friend-request-notifications';

// Export Moderation functions
export {
  onReportCreated,
  clearExpiredSanctions,
  resolveReport
} from './moderation-notifications';

// Export Venue Claiming functions
export {
  claimVenue,
  sendVenueVerificationCode,
  verifyVenueCode,
  reviewVenueClaim,
  submitVenueDispute
} from './venue-claiming';
