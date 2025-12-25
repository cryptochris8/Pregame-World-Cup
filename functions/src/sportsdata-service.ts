import * as functions from "firebase-functions";
const SportsDataAPI = require('node-sportsdata');

/**
 * Enhanced SportsData Service using official SDK
 * Provides better error handling, retry logic, and type safety
 */
export class SportsDataService {
  private client: any;

  constructor(apiKey: string) {
    if (!apiKey) {
      throw new functions.https.HttpsError(
        "internal", 
        "SportsData API key is required"
      );
    }
    
    // Initialize the SportsData client
    this.client = new SportsDataAPI({
      key: apiKey,
      format: 'json',
      // Add timeout and retry configuration
      timeout: 10000, // 10 seconds
      retries: 3
    });
  }

  /**
   * Fetch college football games for a specific season
   * @param season - The season year (e.g., "2024")
   * @returns Promise<any[]> - Array of game objects
   */
  async getCollegeFootballGames(season: string): Promise<any[]> {
    try {
      functions.logger.info(`🏈 Fetching college football games for season: ${season}`);
      
      // Use the SDK's college football games endpoint
      const games = await this.client.cfb.getGames({
        season: season,
        week: 'all' // Get all weeks
      });

      if (!games || !Array.isArray(games)) {
        functions.logger.warn(`No games returned for season ${season}`);
        return [];
      }

      functions.logger.info(`✅ Successfully fetched ${games.length} games for season ${season}`);
      return games;

    } catch (error: any) {
      functions.logger.error(`❌ Error fetching college football games:`, error);
      
      // Provide more specific error handling
      if (error.response?.status === 401) {
        throw new functions.https.HttpsError(
          "unauthenticated", 
          "Invalid SportsData API key"
        );
      } else if (error.response?.status === 429) {
        throw new functions.https.HttpsError(
          "resource-exhausted", 
          "SportsData API rate limit exceeded"
        );
      } else if (error.response?.status === 404) {
        functions.logger.warn(`Season ${season} not found, returning empty array`);
        return [];
      }
      
      throw new functions.https.HttpsError(
        "internal", 
        `Failed to fetch games: ${error.message}`
      );
    }
  }

  /**
   * Get current week's games
   * @returns Promise<any[]> - Array of current week's games
   */
  async getCurrentWeekGames(): Promise<any[]> {
    try {
      const currentDate = new Date();
      const currentYear = currentDate.getFullYear();
      
      // Determine if we're in football season (August - January)
      const month = currentDate.getMonth();
      const season = (month >= 7 || month <= 0) ? currentYear : currentYear - 1;
      
      functions.logger.info(`🗓️ Fetching current week games for season: ${season}`);
      
      const games = await this.client.cfb.getGames({
        season: season.toString(),
        week: 'current'
      });

      return games || [];

    } catch (error: any) {
      functions.logger.error(`❌ Error fetching current week games:`, error);
      throw new functions.https.HttpsError(
        "internal", 
        `Failed to fetch current week games: ${error.message}`
      );
    }
  }

  /**
   * Get team information
   * @param teamId - The team ID
   * @returns Promise<any> - Team data object
   */
  async getTeamInfo(teamId: string): Promise<any> {
    try {
      functions.logger.info(`📋 Fetching team info for: ${teamId}`);
      
      const teamInfo = await this.client.cfb.getTeam({
        teamId: teamId
      });

      return teamInfo;

    } catch (error: any) {
      functions.logger.error(`❌ Error fetching team info for ${teamId}:`, error);
      throw new functions.https.HttpsError(
        "internal", 
        `Failed to fetch team info: ${error.message}`
      );
    }
  }

  /**
   * Get team standings
   * @param season - The season year
   * @returns Promise<any[]> - Array of team standings
   */
  async getStandings(season: string): Promise<any[]> {
    try {
      functions.logger.info(`🏆 Fetching standings for season: ${season}`);
      
      const standings = await this.client.cfb.getStandings({
        season: season
      });

      return standings || [];

    } catch (error: any) {
      functions.logger.error(`❌ Error fetching standings:`, error);
      throw new functions.https.HttpsError(
        "internal", 
        `Failed to fetch standings: ${error.message}`
      );
    }
  }

  /**
   * Test the API connection
   * @returns Promise<boolean> - True if connection successful
   */
  async testConnection(): Promise<boolean> {
    try {
      functions.logger.info("🔧 Testing SportsData API connection...");
      
      // Try to fetch a small amount of data to test the connection
      const currentYear = new Date().getFullYear();
      const testGames = await this.client.cfb.getGames({
        season: currentYear.toString(),
        week: '1',
        limit: 1
      });

      const isConnected = testGames !== null && testGames !== undefined;
      
      if (isConnected) {
        functions.logger.info("✅ SportsData API connection successful");
      } else {
        functions.logger.warn("⚠️ SportsData API connection test returned no data");
      }
      
      return isConnected;

    } catch (error: any) {
      functions.logger.error("❌ SportsData API connection test failed:", error);
      return false;
    }
  }
}

// Create and export a singleton instance
let sportsDataService: SportsDataService | null = null;

export function getSportsDataService(): SportsDataService {
  const apiKey = functions.config().sportsdata?.key;
  
  if (!apiKey) {
    throw new functions.https.HttpsError(
      "internal", 
      "SportsData API key not configured in Firebase Functions config"
    );
  }

  if (!sportsDataService) {
    sportsDataService = new SportsDataService(apiKey);
  }

  return sportsDataService;
} 