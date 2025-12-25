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
// Import v1 functions for scheduled functions
import * as functionsV1 from "firebase-functions/v1"; // HTTP client
import { getSportsDataService } from "./sportsdata-service";
import { getSportsDataFirebaseClient } from "./sportsdata-wrapper";

// Stripe functions will be exported at the bottom of this file

// Initialize Firebase Admin SDK
admin.initializeApp();
functions.logger.info("Firebase Admin SDK initialized. App name:", admin.app().name);
const db = admin.firestore();
functions.logger.info("Firestore instance obtained. Project ID from Admin SDK config:", admin.app().options.projectId);

const SPORTSDATA_API_KEY = process.env.SPORTSDATA_KEY;
const PLACES_API_KEY = process.env.PLACES_API_KEY;

// Enhanced function to fetch schedule data using SportsData.io SDK
async function fetchScheduleFromApi(season: string): Promise<any[]> {
  functions.logger.info(`🏈 Fetching schedule for season: ${season} using SportsData SDK`);
  
  try {
    const sportsDataService = getSportsDataService();
    const games = await sportsDataService.getCollegeFootballGames(season);
    
    functions.logger.info(`✅ Successfully fetched ${games.length} games using SDK`);
    return games;
    
  } catch (error: any) {
    functions.logger.error("❌ Error fetching schedule using SDK:", error.message);
    
    // Fallback to original method if SDK fails
    functions.logger.info("🔄 Falling back to direct API call...");
    return await fetchScheduleFromApiDirect(season);
  }
}

// Fallback function using direct API calls (kept for redundancy)
async function fetchScheduleFromApiDirect(season: string): Promise<any[]> {
  if (!SPORTSDATA_API_KEY) {
    functions.logger.error("SportsData.io API key (SPORTSDATA_KEY) not configured in environment variables.");
    throw new functions.https.HttpsError("internal", "API key configuration error.");
  }
  const uri = `https://api.sportsdata.io/v3/cfb/scores/json/Games/${season}`;
  const headers = { "Ocp-Apim-Subscription-Key": SPORTSDATA_API_KEY };

  functions.logger.info(`Fetching schedule for season: ${season} from SportsData.io (direct API)`);
  try {
    const response = await axios.get(uri, { headers: headers });
    if (response.status === 200 && Array.isArray(response.data)) {
      functions.logger.info(`Successfully fetched ${response.data.length} games from SportsData.io.`);
      return response.data; // Returns the array of game objects
    } else {
      functions.logger.error("Failed to fetch schedule from SportsData.io, status:", response.status, "Data:", response.data);
      throw new functions.https.HttpsError("internal", "Failed to fetch schedule data from provider.");
    }
  } catch (error: any) {
    functions.logger.error("Error calling SportsData.io API:", error.message);
    if (error.response) {
      functions.logger.error("SportsData.io API Error Response:", error.response.status, error.response.data);
    }
    throw new functions.https.HttpsError("internal", "API call to provider failed.");
  }
}

// Function to save game data to Firestore
async function saveGamesToFirestore(games: any[]) {
  if (!games || games.length === 0) {
    functions.logger.info("No games to save.");
    return;
  }

  functions.logger.info(`Firestore client configured Project ID before writes: ${admin.app().options.projectId}`);

  // Optional: Test write (can be removed if no longer needed for diagnostics)
  const testDocId = `testWrite_${Date.now()}`;
  try {
    await db.collection("testWrites").doc(testDocId).set({ timestamp: admin.firestore.FieldValue.serverTimestamp(), status: "test_successful_simplified_function" });
    functions.logger.info(`Successfully wrote test document to testWrites/${testDocId}`);
  } catch (error: any) {
    functions.logger.error(`Error writing test document to ${testDocId}:`, error.message);
  }

  functions.logger.info(`Attempting to save/update ${games.length} games to Firestore 'schedules' collection...`);
  let gamesProcessed = 0;
  let batch = db.batch();

  for (const game of games) {
    const gameId = game.GameID;
    if (gameId === null || gameId === undefined) {
      functions.logger.warn("Skipping game due to missing GameID:", game);
      continue;
    }
    const docId = gameId.toString();
    const docRef = db.collection("schedules").doc(docId);

    // Simplified game data to save, without logo URLs
    const gameDataToSave = {
      ...game, // Spread existing game data from SportsData.io
      // Ensure awayTeamName and homeTeamName are mapped correctly if SportsData.io uses different keys
      // For now, assuming SportsData.io provides game.AwayTeamName and game.HomeTeamName directly
      UpdatedFS: admin.firestore.FieldValue.serverTimestamp(),
    };

    batch.set(docRef, gameDataToSave, { merge: true });
    gamesProcessed++;

    if (gamesProcessed > 0 && gamesProcessed % 490 === 0) {
      functions.logger.info(`Committing batch of (approx) ${gamesProcessed} games...`);
      try {
        await batch.commit();
        functions.logger.info('Batch committed.');
      } catch (e: any) {
        functions.logger.error('Error committing batch:', e.message);
        throw e;
      }
      batch = db.batch();
      functions.logger.info('New batch started.');
    }
  }

  // Commit any remaining operations in the last batch
  if (gamesProcessed % 490 !== 0 && gamesProcessed > 0) { 
    functions.logger.info(`Committing final batch of ${gamesProcessed % 490} games...`);
    try {
      await batch.commit();
      functions.logger.info('Final batch committed.');
    } catch (e: any) {
      functions.logger.error('Error committing final batch:', e.message);
      throw e;
    }
  }
  
  functions.logger.info(`Successfully processed and attempted to save/update ${gamesProcessed} games.`);
}

// Cloud Function to get nearby venues using Google Places API
// Test function for SportsData API integration using custom wrapper
export const testSportsDataWrapper = functions.https.onRequest(async (request, response) => {
  functions.logger.info("🧪 Testing SportsData API with Custom Wrapper");
  
  try {
    // Use our custom Firebase wrapper
    const client = getSportsDataFirebaseClient();
    
    // Test connection
    const isConnected = await client.testConnection();
    
    if (!isConnected) {
      response.status(500).json({
        success: false,
        message: "Failed to connect to SportsData API"
      });
      return;
    }
    
    // Get teams using wrapper
    const teams = await client.getTeams();
    
    // Get recent games  
    const upcomingGames = await client.getUpcomingGames(7);
    
    // Get conference breakdown
    const secTeams = await client.getConferenceTeams('SEC');
    const bigTenTeams = await client.getConferenceTeams('Big Ten');
    
    response.status(200).json({
      success: true,
      message: "SportsData Custom Wrapper working perfectly!",
      data: {
        connected: true,
        wrapperInfo: client.getApiInfo(),
        teams: {
          total: teams.length,
          sampleTeams: teams.slice(0, 5).map(team => ({
            name: team.Name,
            school: team.School,
            conference: team.Conference
          }))
        },
        games: {
          upcomingCount: upcomingGames.length,
          sampleGames: upcomingGames.slice(0, 3).map(game => ({
            homeTeam: game.HomeTeam,
            awayTeam: game.AwayTeam,
            dateTime: game.DateTime,
            status: game.Status
          }))
        },
        conferences: {
          SEC: {
            count: secTeams.length,
            teams: secTeams.slice(0, 3).map(t => t.School)
          },
          BigTen: {
            count: bigTenTeams.length,
            teams: bigTenTeams.slice(0, 3).map(t => t.School)
          }
        }
      }
    });
    
  } catch (error: any) {
    functions.logger.error("❌ SportsData Wrapper test failed:", error);
    response.status(500).json({
      success: false,
      message: `Wrapper test failed: ${error.message}`,
      details: error.code || 'Unknown error'
    });
  }
});

// Legacy test function for SportsData API integration (direct API calls)
export const testSportsDataSDK = functions.https.onRequest(async (request, response) => {
  functions.logger.info("🧪 Testing SportsData API integration (Legacy Direct API)");
  
  try {
    const apiKey = process.env.SPORTSDATA_KEY;
    
    if (!apiKey) {
      response.status(500).json({
        success: false,
        message: "SportsData API key not configured"
      });
      return;
    }
    
    // Test direct API call
    const testResponse = await axios.get(
      'https://api.sportsdata.io/v3/cfb/scores/json/Teams',
      {
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey
        },
        timeout: 10000
      }
    );
    
    if (testResponse.status === 200 && testResponse.data) {
      const teams = testResponse.data;
      
      response.status(200).json({
        success: true,
        message: "SportsData API working correctly (Direct API)",
        data: {
          connected: true,
          teamsFound: teams.length,
          sampleTeams: teams.slice(0, 3).map((team: any) => ({
            name: team.Name,
            conference: team.Conference
          })),
          apiKeyPreview: apiKey.substring(0, 8) + '...'
        }
      });
    } else {
      response.status(500).json({
        success: false,
        message: "API returned unexpected response"
      });
    }
    
  } catch (error: any) {
    functions.logger.error("❌ SportsData API test failed:", error);
    response.status(500).json({
      success: false,
      message: `API test failed: ${error.message}`,
      details: error.response?.status || 'Unknown error'
    });
  }
});

export const getNearbyVenuesHttp = functions.https.onRequest(async (request, response) => {
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
            allResults.push({
              placeId: place.place_id,
              name: place.name,
              vicinity: place.vicinity,
              rating: place.rating,
              userRatingsTotal: place.user_ratings_total,
              types: place.types,
              latitude: place.geometry?.location?.lat,
              longitude: place.geometry?.location?.lng,
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

export const updateSchedule = functions.https.onRequest(async (request, response) => {
  functions.logger.info("updateSchedule function triggered!");
  functions.logger.info("Attempting to read SPORTSDATA_KEY env var. Found:", SPORTSDATA_API_KEY ? "Yes (hidden)" : "No!");

  if (!SPORTSDATA_API_KEY) {
    functions.logger.error("SPORTSDATA_KEY environment variable not set.");
    response.status(500).send("API key configuration error. Check Firebase environment variables.");
    return;
  }

  const season = request.query.season?.toString();
  if (!season || !/^\d{4}$/.test(season)) {
    functions.logger.error("Invalid or missing 'season' query parameter. Please provide a 4-digit year.");
    response.status(400).send("Invalid or missing 'season' query parameter. Must be a 4-digit year (e.g., 2024).");
    return;
  }

  try {
    functions.logger.info(`Fetching schedule for season: ${season}`);
    const scheduleData = await fetchScheduleFromApi(season);
    functions.logger.info(`Fetched ${scheduleData.length} games for season ${season}.`);

    if (scheduleData.length > 0) {
      functions.logger.info("Attempting to save games to Firestore...");
      await saveGamesToFirestore(scheduleData);
      response.status(200).send(`Successfully fetched and saved ${scheduleData.length} games for season ${season}.`);
    } else {
      response.status(200).send(`No games found for season ${season} from the API.`);
    }
  } catch (error: any) {
    functions.logger.error("Error in updateSchedule function:", error.message, error.stack);
    if (error instanceof functions.https.HttpsError) {
      let httpStatusCode = 500;
      switch (error.code) {
        case 'ok': httpStatusCode = 200; break;
        case 'cancelled': httpStatusCode = 499; break;
        case 'unknown': httpStatusCode = 500; break;
        case 'invalid-argument': httpStatusCode = 400; break;
        case 'deadline-exceeded': httpStatusCode = 504; break;
        case 'not-found': httpStatusCode = 404; break;
        case 'already-exists': httpStatusCode = 409; break;
        case 'permission-denied': httpStatusCode = 403; break;
        case 'resource-exhausted': httpStatusCode = 429; break;
        case 'failed-precondition': httpStatusCode = 400; break;
        case 'aborted': httpStatusCode = 409; break;
        case 'out-of-range': httpStatusCode = 400; break;
        case 'unimplemented': httpStatusCode = 501; break;
        case 'internal': httpStatusCode = 500; break;
        case 'unavailable': httpStatusCode = 503; break;
        case 'data-loss': httpStatusCode = 500; break;
        case 'unauthenticated': httpStatusCode = 401; break;
        default: httpStatusCode = 500;
      }
      response.status(httpStatusCode).send(error.message);
    } else {
      response.status(500).send("An unexpected error occurred processing the schedule.");
    }
  }
});

// Scheduled function to sync schedule data daily (reduces client API calls by 90%)
export const scheduledScheduleSync = functionsV1.pubsub.schedule('0 6 * * *')
  .timeZone('America/New_York')
  .onRun(async (context: any) => {
    functions.logger.info("🕐 Daily schedule sync started");
    
    if (!SPORTSDATA_API_KEY) {
      functions.logger.error("❌ SportsData.io API key not configured for scheduled sync");
      return null;
    }

    try {
      // Sync current season schedule
      const currentYear = new Date().getFullYear();
      const seasons = [currentYear, currentYear + 1]; // Current and next year
      
      for (const season of seasons) {
        try {
          functions.logger.info(`📅 Syncing schedule for season ${season}`);
          const scheduleData = await fetchScheduleFromApi(season.toString());
          
          if (scheduleData.length > 0) {
            await saveGamesToFirestore(scheduleData);
            functions.logger.info(`✅ Successfully synced ${scheduleData.length} games for season ${season}`);
          } else {
            functions.logger.warn(`⚠️ No games found for season ${season}`);
          }
          
          // Add delay between seasons to respect rate limits
          await new Promise(resolve => setTimeout(resolve, 2000));
          
        } catch (seasonError: any) {
          functions.logger.error(`❌ Failed to sync season ${season}:`, seasonError.message);
          // Continue with next season even if one fails
        }
      }
      
      functions.logger.info("🎉 Daily schedule sync completed successfully");
      return null;
      
    } catch (error: any) {
      functions.logger.error("❌ Daily schedule sync failed:", error.message);
      return null;
    }
  });

// Enhanced function to update schedule with rate limiting and caching
export const updateScheduleEnhanced = functions.https.onRequest(async (request, response) => {
  functions.logger.info("🚀 Enhanced schedule update triggered");

  if (!SPORTSDATA_API_KEY) {
    functions.logger.error("❌ SPORTSDATA_KEY environment variable not set");
    response.status(500).send("API key configuration error");
    return;
  }

  const season = request.query.season?.toString();
  const forceRefresh = request.query.force === 'true';
  
  if (!season || !/^\d{4}$/.test(season)) {
    response.status(400).send("Invalid season parameter. Must be 4-digit year.");
    return;
  }

  try {
    // Check if we have recent data in Firestore (unless force refresh)
    if (!forceRefresh) {
      const recentDataQuery = await db.collection("schedules")
        .where("Season", "==", parseInt(season))
        .where("UpdatedFS", ">=", admin.firestore.Timestamp.fromDate(
          new Date(Date.now() - 24 * 60 * 60 * 1000) // 24 hours ago
        ))
        .limit(1)
        .get();

      if (!recentDataQuery.empty) {
        functions.logger.info(`📦 Recent data found for season ${season}, skipping API call`);
        response.status(200).json({
          success: true,
          message: `Using cached data for season ${season}`,
          cached: true,
          timestamp: new Date().toISOString()
        });
        return;
      }
    }

    // Proceed with API call only if no recent data or force refresh
    functions.logger.info(`🌐 Fetching fresh data for season ${season}`);
    const scheduleData = await fetchScheduleFromApi(season);
    
    if (scheduleData.length > 0) {
      await saveGamesToFirestore(scheduleData);
      response.status(200).json({
        success: true,
        message: `Successfully updated ${scheduleData.length} games for season ${season}`,
        gamesUpdated: scheduleData.length,
        cached: false,
        timestamp: new Date().toISOString()
      });
    } else {
      response.status(200).json({
        success: true,
        message: `No games found for season ${season}`,
        gamesUpdated: 0,
        cached: false,
        timestamp: new Date().toISOString()
      });
    }
    
  } catch (error: any) {
    functions.logger.error("❌ Enhanced schedule update failed:", error.message);
    response.status(500).json({
      success: false,
      message: `Failed to update schedule: ${error.message}`,
      timestamp: new Date().toISOString()
    });
  }
});

// Function to get cached schedule data (reduces API calls)
export const getCachedSchedule = functions.https.onRequest(async (request, response) => {
  const season = request.query.season?.toString();
  const week = request.query.week?.toString();
  
  if (!season) {
    response.status(400).send("Season parameter required");
    return;
  }

  try {
    let query = db.collection("schedules").where("Season", "==", parseInt(season));
    
    if (week) {
      query = query.where("Week", "==", parseInt(week));
    }
    
    const snapshot = await query.orderBy("DateTime").get();
    const games = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    
    functions.logger.info(`📦 Served ${games.length} cached games for season ${season}${week ? ` week ${week}` : ''}`);
    
    response.status(200).json({
      success: true,
      games: games,
      count: games.length,
      cached: true,
      timestamp: new Date().toISOString()
    });
    
  } catch (error: any) {
    functions.logger.error("❌ Failed to get cached schedule:", error.message);
    response.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Export Stripe functions
export {
  createCheckoutSession,
  createPortalSession,
  createPaymentIntent,
  handleStripeWebhook,
  setupFreeFanAccount,
  createFanCheckoutSession
} from './stripe-simple';

// // Example of how to define a scheduled function (we'll configure the schedule later)
// export const scheduledUpdateSchedule = functions.pubsub.schedule("every 24 hours")
//   .onRun(async (context) => {
//   functions.logger.info("scheduledUpdateSchedule function triggered by Pub/Sub!");
//   const apiKey = functions.config().sportsdata.key;
//   if (!apiKey) {
//       functions.logger.error("SportsData.io API key not configured.");
//       return null; // Exit gracefully
//   }
//   const seasonToFetch = "2024";
//   try {
//       const games = await fetchScheduleFromApi(seasonToFetch, apiKey);
//       await saveGamesToFirestore(games);
//       return null; // Indicate success
//   } catch (error) {
//       functions.logger.error("Unhandled error in scheduledUpdateSchedule:", error);
//       return null; // Indicate failure but don't crash
//   }
// });
