import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import PregameLogo from '../assets/pregame_logo.png';

const LoginScreen: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      // For demo purposes, just navigate to venue dashboard
      // In real app, you'd authenticate with Firebase Auth
      console.log('Login attempt:', { email, password });
      
      // Simulate login delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Navigate to venue dashboard
      navigate('/venue');
    } catch (error) {
      console.error('Login error:', error);
      alert('Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleDemoLogin = () => {
    setEmail('demo@venue.com');
    setPassword('demopassword');
    // Auto-login for demo
    setTimeout(() => navigate('/venue'), 500);
  };

  return (
    <div className="min-h-screen flex" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Left side - Branding */}
      <div className="hidden lg:flex lg:w-1/2 pregame-gradient relative overflow-hidden">
        <div className="flex flex-col justify-center items-center text-white p-12 relative z-10">
          <div className="text-center mb-8">
            <img src={PregameLogo} alt="Pregame" className="h-20 w-auto mx-auto mb-6" />
            <h1 className="text-5xl font-bold mb-4">Venue Portal</h1>
            <p className="text-xl opacity-90 max-w-md">
              Manage your sports venue, engage with fans, and maximize your game day potential
            </p>
          </div>
          
          {/* Stats */}
          <div className="grid grid-cols-3 gap-8 mt-12">
            <div className="text-center">
              <div className="text-3xl font-bold mb-2">500+</div>
              <div className="text-sm opacity-80">Partner Venues</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold mb-2">50K+</div>
              <div className="text-sm opacity-80">Active Fans</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold mb-2">16</div>
              <div className="text-sm opacity-80">SEC Schools</div>
            </div>
          </div>
        </div>
        
        {/* Background decoration */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-1/4 right-1/4 w-64 h-64 rounded-full bg-white"></div>
          <div className="absolute bottom-1/4 left-1/4 w-48 h-48 rounded-full bg-orange-300"></div>
        </div>
      </div>

      {/* Right side - Login Form */}
      <div className="flex-1 flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          {/* Mobile logo */}
          <div className="lg:hidden text-center mb-8">
            <img src={PregameLogo} alt="Pregame" className="h-16 w-auto mx-auto mb-4" />
            <h2 className="text-3xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>
              Venue Portal
            </h2>
          </div>

          {/* Login form */}
          <div className="pregame-card">
            <div className="text-center mb-8">
              <h3 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                Welcome Back
              </h3>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Sign in to your venue dashboard
              </p>
            </div>
            
            <form className="space-y-6" onSubmit={handleLogin}>
              <div className="space-y-4">
                <div>
                  <label htmlFor="email-address" className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Email address
                  </label>
                  <input
                    id="email-address"
                    name="email"
                    type="email"
                    autoComplete="email"
                    required
                    className="w-full px-4 py-3 rounded-xl border border-gray-600 focus:outline-none focus:ring-2 focus:border-transparent transition-all duration-200"
                    style={{
                      background: 'var(--pregame-card-bg)',
                      color: 'var(--pregame-text-light)',
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      '--tw-ring-color': 'var(--pregame-orange)'
                    } as React.CSSProperties}
                    placeholder="Enter your email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                </div>
                <div>
                  <label htmlFor="password" className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Password
                  </label>
                  <input
                    id="password"
                    name="password"
                    type="password"
                    autoComplete="current-password"
                    required
                    className="w-full px-4 py-3 rounded-xl border border-gray-600 focus:outline-none focus:ring-2 focus:border-transparent transition-all duration-200"
                    style={{
                      background: 'var(--pregame-card-bg)',
                      color: 'var(--pregame-text-light)',
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      '--tw-ring-color': 'var(--pregame-orange)'
                    } as React.CSSProperties}
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-4">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <div className="flex items-center justify-center">
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                      Signing in...
                    </div>
                  ) : (
                    'Sign in to Portal'
                  )}
                </button>
                
                <button
                  type="button"
                  onClick={handleDemoLogin}
                  className="w-full py-3 px-4 text-lg font-semibold rounded-xl border-2 transition-all duration-200 hover:border-orange-500"
                  style={{
                    background: 'transparent',
                    color: 'var(--pregame-text-light)',
                    borderColor: 'rgba(255, 255, 255, 0.2)'
                  }}
                >
                  Try Demo Account
                </button>
              </div>
            </form>
          </div>
          
          <div className="text-center">
            <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
              Don't have an account?{' '}
              <Link to="/venue/signup" className="font-medium hover:underline" style={{ color: 'var(--pregame-orange)' }}>
                Create your venue account
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginScreen; 