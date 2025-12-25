import React from 'react';
import { Link } from 'react-router-dom';

const GameScreen: React.FC = () => {
  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
      <div className="max-w-4xl mx-auto p-4">
        <div className="pregame-card text-center mb-8">
          <div className="pregame-gradient text-white p-8 rounded-2xl mb-6">
            <div className="text-4xl mb-4">🏈</div>
            <h1 className="text-4xl font-bold mb-2">Pregame</h1>
            <h2 className="text-2xl font-semibold mb-4">Fan Dashboard</h2>
            <p className="text-lg opacity-90">
              Discover games, venues, and live streams in your area
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div className="game-card">
              <div className="game-card-header">
                <h3 className="text-xl font-semibold" style={{ color: 'var(--pregame-text-light)' }}>
                  🔴 Live Games
                </h3>
              </div>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Watch live streams from your favorite venues and track real-time scores
              </p>
              <div className="mt-4">
                <span className="badge-live">Live</span>
              </div>
            </div>
            
            <div className="venue-card">
              <div className="venue-card-content">
                <h3 className="venue-name">
                  📍 Nearby Venues
                </h3>
                <p className="venue-details">
                  Find the best sports bars and restaurants for game day experiences
                </p>
                <div className="mt-4">
                  <span className="badge-upcoming">Discover</span>
                </div>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div className="stats-card">
              <div className="stats-number">500+</div>
              <div className="stats-label">Partner Venues</div>
            </div>
            
            <div className="stats-card">
              <div className="stats-number">50K+</div>
              <div className="stats-label">Active Fans</div>
            </div>
          </div>

          <Link 
            to="/venue"
            className="btn-pregame-primary inline-block text-lg px-8 py-4"
          >
            Switch to Venue Owner Portal
          </Link>
        </div>
      </div>
    </div>
  );
};

export default GameScreen; 