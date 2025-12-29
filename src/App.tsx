import React from 'react';
import { BrowserRouter as Router, Route, Routes, useLocation } from 'react-router-dom';
import LoginScreen from './screens/LoginScreen';
import GameScreen from './screens/GameScreen';
import LeaderboardScreen from './screens/LeaderboardScreen';
import ProfileScreen from './screens/ProfileScreen';
import InventoryScreen from './screens/InventoryScreen';

// Venue Owner Portal Components
import VenueOwnerDashboard from './screens/venue/VenueOwnerDashboard';
import VenueProfile from './screens/venue/VenueProfile';
import LiveStreamManager from './screens/venue/LiveStreamManager';
import SpecialsManager from './screens/venue/SpecialsManager';
import AnalyticsDashboard from './screens/venue/AnalyticsDashboard';
import FanEngagement from './screens/venue/FanEngagement';
import VenueSubscriptionSimple from './screens/venue/VenueSubscriptionSimple';
import BillingSuccess from './screens/venue/BillingSuccess';
import VenueSignupWizard from './screens/venue/VenueSignupWizard';

// Layout wrapper component
function AppLayout({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const isVenueRoute = location.pathname.startsWith('/venue');
  
  if (isVenueRoute) {
    // Venue routes get full width, white background
    return <div className="min-h-screen w-full bg-white">{children}</div>;
  }
  
  // Game app routes get centered green background
  return (
    <div className="min-h-screen w-full bg-[#355E3B] text-white flex flex-col items-center justify-center p-4">
      {children}
    </div>
  );
}

// Main App component
function App() {
  return (
    <Router>
      <AppLayout>
        <Routes>
          {/* User App Routes */}
          <Route path="/" element={<LoginScreen />} />
          <Route path="/game" element={<GameScreen />} />
          <Route path="/leaderboard" element={<LeaderboardScreen />} />
          <Route path="/profile" element={<ProfileScreen />} />
          <Route path="/inventory" element={<InventoryScreen />} />
          
          {/* Venue Owner Portal Routes */}
          <Route path="/venue/signup" element={<VenueSignupWizard />} />
          <Route path="/venue" element={<VenueOwnerDashboard />} />
          <Route path="/venue/profile" element={<VenueProfile />} />
          <Route path="/venue/livestream" element={<LiveStreamManager />} />
          <Route path="/venue/specials" element={<SpecialsManager />} />
          <Route path="/venue/analytics" element={<AnalyticsDashboard />} />
          <Route path="/venue/engagement" element={<FanEngagement />} />
          <Route path="/venue/billing" element={<VenueSubscriptionSimple />} />
          <Route path="/venue/billing/success" element={<BillingSuccess />} />
        </Routes>
      </AppLayout>
    </Router>
  );
}

export default App;