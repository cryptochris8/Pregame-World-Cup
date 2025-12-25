import { environment } from '../config/environment';
import { SportsDataApiWrapper, createSportsDataClient } from './sportsDataApiWrapper';

// Re-export types from wrapper for convenience
export type { Team, Game } from './sportsDataApiWrapper';

/**
 * Enhanced SportsData Service for React Venue Portal
 * Now uses our custom wrapper for better reliability and consistency
 */
export class SportsDataService {
  private client: SportsDataApiWrapper;

  constructor() {
    const apiKey = environment.sportsDataApiKey || '';
    
    if (!apiKey && environment.isDevelopment) {
      console.warn('⚠️ SportsData API key not configured. Some features may not work.');
    }
    
    // Initialize with our custom wrapper
    this.client = createSportsDataClient(apiKey);
  }

  /**
   * Get current season games
   * @param season - Season year (e.g., 2024)
   * @returns Promise<Game[]>
   */
  async getCurrentSeasonGames(season?: number): Promise<any[]> {
    try {
      if (season) {
        return await this.client.getGames(season);
      } else {
        return await this.client.getCurrentSeasonGames();
      }
    } catch (error) {
      console.error('Error fetching current season games:', error);
      throw new Error('Failed to fetch games data');
    }
  }

  /**
   * Get games for a specific week
   * @param season - Season year
   * @param week - Week number
   * @returns Promise<Game[]>
   */
  async getWeekGames(season: number, week: number): Promise<any[]> {
    try {
      return await this.client.getWeekGames(season, week);
    } catch (error) {
      console.error('Error fetching week games:', error);
      throw new Error('Failed to fetch week games data');
    }
  }

  /**
   * Get all teams
   * @returns Promise<Team[]>
   */
  async getTeams(): Promise<any[]> {
    try {
      return await this.client.getTeams();
    } catch (error) {
      console.error('Error fetching teams:', error);
      throw new Error('Failed to fetch teams data');
    }
  }

  /**
   * Get games for a specific team
   * @param season - Season year
   * @param teamName - Team name or abbreviation
   * @returns Promise<Game[]>
   */
  async getTeamGames(season: number, teamName: string): Promise<any[]> {
    try {
      return await this.client.getTeamGames(season, teamName);
    } catch (error) {
      console.error('Error fetching team games:', error);
      throw new Error('Failed to fetch team games data');
    }
  }

  /**
   * Get live/upcoming games for venue display
   * @param daysAhead - Number of days ahead to look (default: 3)
   * @returns Promise<Game[]>
   */
  async getLiveGames(daysAhead: number = 3): Promise<any[]> {
    try {
      return await this.client.getUpcomingGames(daysAhead);
    } catch (error) {
      console.error('Error fetching live games:', error);
      throw new Error('Failed to fetch live games data');
    }
  }

  /**
   * Test API connection
   * @returns Promise<boolean>
   */
  async testConnection(): Promise<boolean> {
    return await this.client.testConnection();
  }

  /**
   * Get popular teams for venue targeting (Power 5 conferences)
   * @returns Promise<Team[]>
   */
  async getPopularTeams(): Promise<any[]> {
    try {
      // Map common names to actual SportsData conference names
      const powerConferenceNames = [
        'Southeastern',    // SEC
        'Atlantic Coast',  // ACC
        'Big Ten',         // Big Ten
        'Big 12',          // Big 12
        'Pac-12'           // Pac-12
      ];
      
      const allTeams = await this.client.getTeams();
      
      return allTeams.filter(team =>
        team.Conference && powerConferenceNames.some(conf => 
          team.Conference.toLowerCase().includes(conf.toLowerCase())
        )
      ).sort((a, b) => a.Name.localeCompare(b.Name));
    } catch (error) {
      console.error('Error fetching popular teams:', error);
      return [];
    }
  }

  /**
   * Get teams by conference
   * @param conference - Conference name (e.g., 'SEC', 'Big Ten')
   * @returns Promise<Team[]>
   */
  async getConferenceTeams(conference: string): Promise<any[]> {
    try {
      return await this.client.getConferenceTeams(conference);
    } catch (error) {
      console.error('Error fetching conference teams:', error);
      throw new Error('Failed to fetch conference teams data');
    }
  }

  /**
   * Get upcoming games for the next week
   * @returns Promise<Game[]>
   */
  async getUpcomingWeekGames(): Promise<any[]> {
    try {
      return await this.client.getUpcomingGames(7);
    } catch (error) {
      console.error('Error fetching upcoming games:', error);
      throw new Error('Failed to fetch upcoming games');
    }
  }

  /**
   * Get API usage information
   * @returns API info object
   */
  getApiInfo() {
    return this.client.getApiInfo();
  }
}

// Create and export singleton instance
export const sportsDataService = new SportsDataService(); 