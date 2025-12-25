import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';

interface VenueStats {
  totalVisits: number;
  todayVisits: number;
  activeSpecials: number;
  fanRating: number;
  liveViewers: number;
}

const VenueOwnerDashboard: React.FC = () => {
  const [venueStats, setVenueStats] = useState<VenueStats>({
    totalVisits: 0,
    todayVisits: 0,
    activeSpecials: 0,
    fanRating: 0,
    liveViewers: 0
  });

  const [isLiveStreaming, setIsLiveStreaming] = useState(false);
  const [venueName, setVenueName] = useState("Your Sports Bar");

  // Simulate loading venue data
  useEffect(() => {
    // In real app, this would fetch from your Firebase/API
    setVenueStats({
      totalVisits: 1247,
      todayVisits: 23,
      activeSpecials: 3,
      fanRating: 4.6,
      liveViewers: 45
    });
  }, []);

  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)', color: 'var(--pregame-text-light)' }}>
      {/* Header */}
      <div className="pregame-gradient text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-8">
            <div>
              <div className="flex items-center mb-2">
                <img src={PregameLogo} alt="Pregame" className="h-12 w-auto mr-4" />
                <h1 className="text-4xl font-bold">Venue Portal</h1>
              </div>
              <p className="text-white opacity-90">Welcome back, {venueName}</p>
            </div>
            <div className="flex items-center space-x-4">
              {isLiveStreaming && (
                <div className="flex items-center bg-red-500 px-4 py-2 rounded-full shadow-lg">
                  <div className="w-2 h-2 bg-white rounded-full mr-2 animate-pulse"></div>
                  <span className="text-sm font-bold">LIVE</span>
                </div>
              )}
              <div className="text-right">
                <p className="text-sm text-white opacity-80">Live Viewers</p>
                <p className="text-2xl font-bold">{venueStats.liveViewers}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Quick Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-3 rounded-xl" style={{ background: 'rgba(76, 110, 245, 0.15)' }}>
                <svg className="w-6 h-6" style={{ color: 'var(--pregame-blue-start)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Today's Visits</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{venueStats.todayVisits}</p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-3 rounded-xl" style={{ background: 'rgba(255, 107, 53, 0.15)' }}>
                <svg className="w-6 h-6" style={{ color: 'var(--pregame-orange)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Fan Rating</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{venueStats.fanRating}/5.0</p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-3 rounded-xl" style={{ background: 'rgba(21, 170, 191, 0.15)' }}>
                <svg className="w-6 h-6" style={{ color: 'var(--pregame-blue-end)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Active Specials</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{venueStats.activeSpecials}</p>
              </div>
            </div>
          </div>

          <div className="pregame-card">
            <div className="flex items-center">
              <div className="p-3 rounded-xl" style={{ background: 'rgba(168, 85, 247, 0.15)' }}>
                <svg className="w-6 h-6 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Total Visits</p>
                <p className="text-2xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>{venueStats.totalVisits}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Main Actions Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Live Stream Management */}
          <Link to="/venue/livestream" className="pregame-card block hover:border-orange-500 transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>Live Stream</h3>
              <div className={`w-3 h-3 rounded-full ${isLiveStreaming ? 'bg-red-500' : 'bg-gray-500'}`}></div>
            </div>
            <p style={{ color: 'var(--pregame-text-muted)' }} className="mb-4">Manage your venue's live stream for game day atmosphere</p>
            <div className="flex items-center font-medium" style={{ color: 'var(--pregame-orange)' }}>
              <span>{isLiveStreaming ? 'Stream Active' : 'Start Streaming'}</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>

          {/* Food & Drink Specials */}
          <Link to="/venue/specials" className="pregame-card block hover:border-orange-500 transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>Game Day Specials</h3>
              <svg className="w-6 h-6" style={{ color: 'var(--pregame-orange)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
              </svg>
            </div>
            <p style={{ color: 'var(--pregame-text-muted)' }} className="mb-4">Create and manage food & drink specials for game days</p>
            <div className="flex items-center font-medium" style={{ color: 'var(--pregame-orange)' }}>
              <span>Manage Specials</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>

          {/* Venue Profile */}
          <Link to="/venue/profile" className="pregame-card block hover:border-orange-500 transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>Venue Profile</h3>
              <svg className="w-6 h-6" style={{ color: 'var(--pregame-blue-start)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
            <p style={{ color: 'var(--pregame-text-muted)' }} className="mb-4">Update your venue information, photos, and hours</p>
            <div className="flex items-center font-medium" style={{ color: 'var(--pregame-orange)' }}>
              <span>Edit Profile</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>

          {/* Analytics */}
          <Link to="/venue/analytics" className="pregame-card block hover:border-orange-500 transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>Analytics</h3>
              <svg className="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <p style={{ color: 'var(--pregame-text-muted)' }} className="mb-4">View detailed analytics and fan engagement metrics</p>
            <div className="flex items-center font-medium" style={{ color: 'var(--pregame-orange)' }}>
              <span>View Analytics</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>

          {/* Fan Engagement */}
          <Link to="/venue/engagement" className="pregame-card block hover:border-orange-500 transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>Fan Engagement</h3>
              <svg className="w-6 h-6 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
            </div>
            <p style={{ color: 'var(--pregame-text-muted)' }} className="mb-4">Interact with fans, respond to reviews, and build community</p>
            <div className="flex items-center font-medium" style={{ color: 'var(--pregame-orange)' }}>
              <span>Engage Fans</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>

          {/* Subscription & Billing - Special Green Card */}
          <Link to="/venue/billing" className="pregame-card block hover:border-green-400 transition-all duration-200 bg-green-600 bg-opacity-20 border-green-500">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-green-400">Subscription & Billing</h3>
              <svg className="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
              </svg>
            </div>
            <p className="text-green-300 mb-4">Manage your subscription plan and billing information</p>
            <div className="flex items-center text-green-400 font-medium">
              <span>Manage Subscription</span>
              <svg className="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </Link>
        </div>

        {/* Quick Links Section */}
        <div className="mt-12 pregame-card">
          <h3 className="text-xl font-semibold mb-6" style={{ color: 'var(--pregame-text-light)' }}>Quick Actions</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Link to="/game" className="flex items-center p-3 rounded-lg hover:bg-gray-700 transition-colors">
              <div className="p-2 rounded-lg mr-3" style={{ background: 'rgba(255, 107, 53, 0.15)' }}>
                <svg className="w-5 h-5" style={{ color: 'var(--pregame-orange)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </div>
              <span className="text-sm font-medium" style={{ color: 'var(--pregame-text-light)' }}>Fan View</span>
            </Link>
            
            <button className="flex items-center p-3 rounded-lg hover:bg-gray-700 transition-colors text-left">
              <div className="p-2 rounded-lg mr-3" style={{ background: 'rgba(76, 110, 245, 0.15)' }}>
                <svg className="w-5 h-5" style={{ color: 'var(--pregame-blue-start)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192L5.636 18.364M12 12h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <span className="text-sm font-medium" style={{ color: 'var(--pregame-text-light)' }}>Help & Support</span>
            </button>
            
            <button className="flex items-center p-3 rounded-lg hover:bg-gray-700 transition-colors text-left">
              <div className="p-2 rounded-lg mr-3" style={{ background: 'rgba(21, 170, 191, 0.15)' }}>
                <svg className="w-5 h-5" style={{ color: 'var(--pregame-blue-end)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <span className="text-sm font-medium" style={{ color: 'var(--pregame-text-light)' }}>Settings</span>
            </button>
            
            <button className="flex items-center p-3 rounded-lg hover:bg-gray-700 transition-colors text-left">
              <div className="p-2 rounded-lg mr-3" style={{ background: 'rgba(168, 85, 247, 0.15)' }}>
                <svg className="w-5 h-5 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
              </div>
              <span className="text-sm font-medium" style={{ color: 'var(--pregame-text-light)' }}>Logout</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default VenueOwnerDashboard; 