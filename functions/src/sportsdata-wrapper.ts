import * as functions from "firebase-functions";
import axios from "axios";

/**
 * Firebase Functions compatible SportsData API Wrapper
 * Uses axios instead of fetch for better Node.js compatibility
 */

export interface Team {
  TeamID: number;
  Name: string;
  School: string;
  Conference: string;
  ConferenceDivision?: string;
}

export interface Game {
  GameID: number;
  Season: number;
  Week: number;
  AwayTeam: string;
  HomeTeam: string;
  AwayScore?: number;
  HomeScore?: number;
  Status: string;
  DateTime: string;
}

interface SportsDataConfig {
  apiKey: string;
  baseUrl?: string;
  timeout?: number;
}

export class SportsDataFirebaseWrapper {
  private apiKey: string;
  private baseUrl: string;
  private timeout: number;

  constructor(config: SportsDataConfig) {
    this.apiKey = config.apiKey;
    this.baseUrl = config.baseUrl || 'https://api.sportsdata.io/v3/cfb/scores/json';
    this.timeout = config.timeout || 10000;
  }

  /**
   * Make HTTP request with proper headers and error handling
   */
  private async makeRequest<T>(endpoint: string): Promise<T> {
    const url = `${this.baseUrl}/${endpoint}`;
    
    try {
      functions.logger.info(`Making SportsData API request to: ${endpoint}`);
      
      const response = await axios.get(url, {
        headers: {
          'Ocp-Apim-Subscription-Key': this.apiKey,
          'Accept': 'application/json'
        },
        timeout: this.timeout
      });

      if (response.status === 200 && response.data) {
        functions.logger.info(`✅ SportsData API request successful: ${endpoint}`);
        return response.data as T;
      } else {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

    } catch (error: any) {
      functions.logger.error(`❌ SportsData API request failed: ${endpoint}`, error);
      
      if (error.response) {
        const status = error.response.status;
        if (status === 401) {
          throw new functions.https.HttpsError('unauthenticated', 'Invalid SportsData API key');
        } else if (status === 403) {
          throw new functions.https.HttpsError('permission-denied', 'API key does not have access to this endpoint');
        } else if (status === 429) {
          throw new functions.https.HttpsError('resource-exhausted', 'SportsData API rate limit exceeded');
        } else {
          throw new functions.https.HttpsError('internal', `SportsData API error: ${status}`);
        }
      }
      
      if (error.code === 'ECONNABORTED') {
        throw new functions.https.HttpsError('deadline-exceeded', 'SportsData API request timeout');
      }
      
      throw new functions.https.HttpsError('internal', `SportsData API request failed: ${error.message}`);
    }
  }

  /**
   * College Football API Methods
   */
  async getTeams(): Promise<Team[]> {
    return this.makeRequest<Team[]>('Teams');
  }

  async getGames(season: number): Promise<Game[]> {
    return this.makeRequest<Game[]>(`Games/${season}`);
  }

  async getWeekGames(season: number, week: number): Promise<Game[]> {
    return this.makeRequest<Game[]>(`Games/${season}/${week}`);
  }

  async getCurrentSeasonGames(): Promise<Game[]> {
    const currentYear = new Date().getFullYear();
    return this.getGames(currentYear);
  }

  async getTeamGames(season: number, teamName: string): Promise<Game[]> {
    const allGames = await this.getGames(season);
    return allGames.filter(game => 
      game.HomeTeam.toLowerCase().includes(teamName.toLowerCase()) ||
      game.AwayTeam.toLowerCase().includes(teamName.toLowerCase())
    );
  }

  async getUpcomingGames(daysAhead: number = 7): Promise<Game[]> {
    const currentSeason = new Date().getFullYear();
    const allGames = await this.getGames(currentSeason);
    
    const now = new Date();
    const futureDate = new Date(now.getTime() + (daysAhead * 24 * 60 * 60 * 1000));
    
    return allGames.filter(game => {
      const gameDate = new Date(game.DateTime);
      return gameDate >= now && gameDate <= futureDate;
    }).sort((a, b) => new Date(a.DateTime).getTime() - new Date(b.DateTime).getTime());
  }

  async getConferenceTeams(conference: string): Promise<Team[]> {
    const allTeams = await this.getTeams();
    return allTeams.filter(team => 
      team.Conference && team.Conference.toLowerCase().includes(conference.toLowerCase())
    );
  }

  /**
   * Test API connection
   */
  async testConnection(): Promise<boolean> {
    try {
      const teams = await this.getTeams();
      return Array.isArray(teams) && teams.length > 0;
    } catch (error) {
      functions.logger.error('SportsData API connection test failed:', error);
      return false;
    }
  }

  /**
   * Get API usage info (helpful for monitoring)
   */
  getApiInfo() {
    return {
      baseUrl: this.baseUrl,
      timeout: this.timeout,
      hasApiKey: !!this.apiKey,
      apiKeyPreview: this.apiKey ? this.apiKey.substring(0, 8) + '...' : 'Not set'
    };
  }
}

// Factory function for Firebase Functions
export function createSportsDataFirebaseClient(apiKey: string): SportsDataFirebaseWrapper {
  return new SportsDataFirebaseWrapper({ apiKey });
}

// Singleton for Firebase Functions
let firebaseClient: SportsDataFirebaseWrapper | null = null;

export function getSportsDataFirebaseClient(): SportsDataFirebaseWrapper {
  const apiKey = functions.config().sportsdata?.key;
  
  if (!apiKey) {
    throw new functions.https.HttpsError(
      'internal', 
      'SportsData API key not configured in Firebase Functions config'
    );
  }

  if (!firebaseClient) {
    firebaseClient = new SportsDataFirebaseWrapper({ apiKey });
  }

  return firebaseClient;
} 