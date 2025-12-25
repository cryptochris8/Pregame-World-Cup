/**
 * Custom SportsData.io API Wrapper
 * Works in both browser and Node.js environments
 * Provides SDK-like interface with direct HTTP calls
 */

interface SportsDataConfig {
  apiKey: string;
  baseUrl?: string;
  timeout?: number;
}

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

export class SportsDataApiWrapper {
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
    const headers = {
      'Ocp-Apim-Subscription-Key': this.apiKey,
      'Accept': 'application/json'
    };

    try {
      // Use fetch API (works in both browser and Node.js 18+)
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.timeout);

      const response = await fetch(url, {
        headers,
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('Invalid API key');
        } else if (response.status === 403) {
          throw new Error('API key does not have access to this endpoint');
        } else if (response.status === 429) {
          throw new Error('Rate limit exceeded');
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
      }

      const data = await response.json();
      return data as T;

    } catch (error) {
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          throw new Error('Request timeout');
        }
        throw error;
      }
      throw new Error('Unknown error occurred');
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
    
    // Map friendly names to actual SportsData conference names
    const conferenceMap: { [key: string]: string } = {
      'SEC': 'Southeastern',
      'ACC': 'Atlantic Coast',
      'Big Ten': 'Big Ten',
      'Big 12': 'Big 12',
      'Pac-12': 'Pac-12',
      'American': 'American Athletic',
      'Conference USA': 'Conference USA',
      'MAC': 'Mid-American',
      'Mountain West': 'Mountain West',
      'Sun Belt': 'Sun Belt'
    };
    
    // Use mapped name if available, otherwise use original
    const searchConference = conferenceMap[conference] || conference;
    
    return allTeams.filter(team => 
      team.Conference && team.Conference.toLowerCase().includes(searchConference.toLowerCase())
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
      console.error('SportsData API connection test failed:', error);
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

// Factory function for easy instantiation
export function createSportsDataClient(apiKey: string): SportsDataApiWrapper {
  return new SportsDataApiWrapper({ apiKey });
}

// Export singleton for React app
// Note: Initialize this after environment is loaded
export let sportsDataClient: SportsDataApiWrapper;

// Initialize function to be called after environment config is available
export function initializeSportsDataClient(apiKey: string): SportsDataApiWrapper {
  sportsDataClient = new SportsDataApiWrapper({ apiKey });
  return sportsDataClient;
} 