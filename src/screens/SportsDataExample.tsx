import React, { useState, useEffect } from 'react';
import { sportsDataService, Team, Game } from '../services/sportsDataService';

/**
 * Example React Component demonstrating SportsData API usage
 * Shows how to use our custom wrapper for:
 * - Getting teams
 * - Getting games
 * - Getting conference data
 * - Error handling
 */
export const SportsDataExample: React.FC = () => {
  const [teams, setTeams] = useState<Team[]>([]);
  const [games, setGames] = useState<Game[]>([]);
  const [conferences, setConferences] = useState<{ [key: string]: Team[] }>({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<boolean | null>(null);

  // Test API connection on component mount
  useEffect(() => {
    testConnection();
  }, []);

  const testConnection = async () => {
    try {
      setLoading(true);
      const isConnected = await sportsDataService.testConnection();
      setConnectionStatus(isConnected);
      
      if (isConnected) {
        console.log('✅ SportsData API connection successful');
        console.log('API Info:', sportsDataService.getApiInfo());
      } else {
        setError('Failed to connect to SportsData API');
      }
    } catch (err: any) {
      setError(`Connection test failed: ${err.message}`);
      setConnectionStatus(false);
    } finally {
      setLoading(false);
    }
  };

  const loadTeams = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const allTeams = await sportsDataService.getTeams();
      setTeams(allTeams);
      
      console.log(`✅ Loaded ${allTeams.length} teams`);
    } catch (err: any) {
      setError(`Failed to load teams: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const loadUpcomingGames = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const upcomingGames = await sportsDataService.getLiveGames(7);
      setGames(upcomingGames);
      
      console.log(`✅ Loaded ${upcomingGames.length} upcoming games`);
    } catch (err: any) {
      setError(`Failed to load games: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const loadConferenceData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const powerConferences = ['SEC', 'Big Ten', 'Big 12', 'ACC', 'Pac-12'];
      const conferenceData: { [key: string]: Team[] } = {};
      
      // Load each conference in parallel
      const conferencePromises = powerConferences.map(async (conf) => {
        const teams = await sportsDataService.getConferenceTeams(conf);
        return { conference: conf, teams };
      });
      
      const results = await Promise.all(conferencePromises);
      
      results.forEach(({ conference, teams }) => {
        conferenceData[conference] = teams;
      });
      
      setConferences(conferenceData);
      
      const totalTeams = Object.values(conferenceData).reduce((sum, teams) => sum + teams.length, 0);
      console.log(`✅ Loaded ${totalTeams} teams across ${powerConferences.length} conferences`);
      
    } catch (err: any) {
      setError(`Failed to load conference data: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const getTeamGames = async (teamName: string) => {
    try {
      setLoading(true);
      setError(null);
      
      const currentSeason = new Date().getFullYear();
      const teamGames = await sportsDataService.getTeamGames(currentSeason, teamName);
      setGames(teamGames);
      
      console.log(`✅ Loaded ${teamGames.length} games for ${teamName}`);
    } catch (err: any) {
      setError(`Failed to load games for ${teamName}: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <h1>🏈 SportsData API Wrapper Demo</h1>
      
      {/* Connection Status */}
      <div style={{ 
        marginBottom: '20px', 
        padding: '15px', 
        backgroundColor: connectionStatus ? '#d4edda' : '#f8d7da',
        borderRadius: '5px',
        border: `1px solid ${connectionStatus ? '#c3e6cb' : '#f5c6cb'}`
      }}>
        <h3>🔌 Connection Status</h3>
        <p>
          API Connection: {' '}
          <strong style={{ color: connectionStatus ? 'green' : 'red' }}>
            {connectionStatus === null ? 'Testing...' : connectionStatus ? 'Connected ✅' : 'Failed ❌'}
          </strong>
        </p>
        <button onClick={testConnection} disabled={loading}>
          {loading ? 'Testing...' : 'Test Connection'}
        </button>
      </div>

      {/* Error Display */}
      {error && (
        <div style={{ 
          marginBottom: '20px', 
          padding: '15px', 
          backgroundColor: '#f8d7da',
          borderRadius: '5px',
          border: '1px solid #f5c6cb',
          color: '#721c24'
        }}>
          <h4>❌ Error</h4>
          <p>{error}</p>
          <button onClick={() => setError(null)}>Clear Error</button>
        </div>
      )}

      {/* Action Buttons */}
      <div style={{ marginBottom: '20px' }}>
        <h3>🎮 Actions</h3>
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <button onClick={loadTeams} disabled={loading}>
            {loading ? 'Loading...' : 'Load All Teams'}
          </button>
          <button onClick={loadUpcomingGames} disabled={loading}>
            {loading ? 'Loading...' : 'Load Upcoming Games'}
          </button>
          <button onClick={loadConferenceData} disabled={loading}>
            {loading ? 'Loading...' : 'Load Conference Data'}
          </button>
          <button onClick={() => getTeamGames('Alabama')} disabled={loading}>
            {loading ? 'Loading...' : 'Get Alabama Games'}
          </button>
          <button onClick={() => getTeamGames('Georgia')} disabled={loading}>
            {loading ? 'Loading...' : 'Get Georgia Games'}
          </button>
        </div>
      </div>

      {/* Teams Display */}
      {teams.length > 0 && (
        <div style={{ marginBottom: '20px' }}>
          <h3>🏫 Teams ({teams.length} total)</h3>
          <div style={{ maxHeight: '300px', overflow: 'auto', border: '1px solid #ddd', padding: '10px' }}>
            {teams.slice(0, 20).map((team, index) => (
              <div key={team.TeamID || index} style={{ 
                padding: '8px', 
                margin: '5px 0', 
                backgroundColor: '#f8f9fa',
                borderRadius: '3px',
                cursor: 'pointer'
              }}
              onClick={() => getTeamGames(team.Name)}
              >
                <strong>{team.School || team.Name}</strong>
                <br />
                <small style={{ color: '#666' }}>
                  {team.Conference} {team.ConferenceDivision && `- ${team.ConferenceDivision}`}
                </small>
              </div>
            ))}
            {teams.length > 20 && (
              <p style={{ textAlign: 'center', color: '#666' }}>
                ... and {teams.length - 20} more teams
              </p>
            )}
          </div>
        </div>
      )}

      {/* Games Display */}
      {games.length > 0 && (
        <div style={{ marginBottom: '20px' }}>
          <h3>🏈 Games ({games.length} total)</h3>
          <div style={{ maxHeight: '400px', overflow: 'auto', border: '1px solid #ddd', padding: '10px' }}>
            {games.slice(0, 10).map((game, index) => (
              <div key={game.GameID || index} style={{ 
                padding: '10px', 
                margin: '5px 0', 
                backgroundColor: '#f8f9fa',
                borderRadius: '3px',
                border: '1px solid #e9ecef'
              }}>
                <div style={{ fontWeight: 'bold', marginBottom: '5px' }}>
                  {game.AwayTeam} @ {game.HomeTeam}
                </div>
                <div style={{ fontSize: '0.9em', color: '#666' }}>
                  📅 {new Date(game.DateTime).toLocaleDateString()} {' '}
                  {new Date(game.DateTime).toLocaleTimeString()}
                </div>
                <div style={{ fontSize: '0.9em', color: '#666' }}>
                  Status: {game.Status}
                  {game.HomeScore !== undefined && game.AwayScore !== undefined && (
                    <span> - Score: {game.AwayScore} - {game.HomeScore}</span>
                  )}
                </div>
              </div>
            ))}
            {games.length > 10 && (
              <p style={{ textAlign: 'center', color: '#666' }}>
                ... and {games.length - 10} more games
              </p>
            )}
          </div>
        </div>
      )}

      {/* Conference Data Display */}
      {Object.keys(conferences).length > 0 && (
        <div style={{ marginBottom: '20px' }}>
          <h3>🏆 Conference Breakdown</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '15px' }}>
            {Object.entries(conferences).map(([confName, confTeams]) => (
              <div key={confName} style={{ 
                border: '1px solid #ddd', 
                borderRadius: '5px', 
                padding: '10px',
                backgroundColor: '#f8f9fa'
              }}>
                <h4 style={{ margin: '0 0 10px 0', color: '#495057' }}>{confName}</h4>
                <p style={{ margin: '0 0 10px 0', fontSize: '0.9em', color: '#666' }}>
                  {confTeams.length} teams
                </p>
                <div style={{ maxHeight: '150px', overflow: 'auto' }}>
                  {confTeams.map((team, idx) => (
                    <div key={team.TeamID || idx} style={{ 
                      fontSize: '0.85em', 
                      padding: '2px 0',
                      cursor: 'pointer'
                    }}
                    onClick={() => getTeamGames(team.Name)}
                    >
                      {team.School || team.Name}
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Loading Indicator */}
      {loading && (
        <div style={{ 
          position: 'fixed', 
          top: '50%', 
          left: '50%', 
          transform: 'translate(-50%, -50%)',
          backgroundColor: 'rgba(0,0,0,0.8)',
          color: 'white',
          padding: '20px',
          borderRadius: '10px',
          zIndex: 1000
        }}>
          <div style={{ textAlign: 'center' }}>
            <div className="spinner" style={{ 
              border: '3px solid #f3f3f3',
              borderTop: '3px solid #3498db',
              borderRadius: '50%',
              width: '30px',
              height: '30px',
              margin: '0 auto 10px'
            }} />
            Loading...
          </div>
          <style dangerouslySetInnerHTML={{
            __html: `
              .spinner {
                animation: spin 1s linear infinite;
              }
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            `
          }} />
        </div>
      )}

      {/* Usage Instructions */}
      <div style={{ 
        marginTop: '30px', 
        padding: '15px', 
        backgroundColor: '#e9ecef',
        borderRadius: '5px',
        fontSize: '0.9em'
      }}>
        <h4>📋 How to Use This Demo</h4>
        <ol>
          <li><strong>Test Connection:</strong> Verify your API key is working</li>
          <li><strong>Load All Teams:</strong> Get all 272 college football teams</li>
          <li><strong>Load Upcoming Games:</strong> Get games in the next 7 days</li>
          <li><strong>Load Conference Data:</strong> Get teams organized by Power 5 conferences</li>
          <li><strong>Get Team Games:</strong> Click any team name or use the buttons to see their games</li>
        </ol>
        <p style={{ marginBottom: 0, fontStyle: 'italic' }}>
          💡 This demonstrates the full capability of our custom SportsData wrapper!
        </p>
      </div>
    </div>
  );
}; 