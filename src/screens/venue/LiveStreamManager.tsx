import React, { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';

interface StreamStats {
  viewerCount: number;
  duration: string;
  quality: string;
  bitrate: string;
}

const LiveStreamManager: React.FC = () => {
  const [isStreaming, setIsStreaming] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [streamStats, setStreamStats] = useState<StreamStats>({
    viewerCount: 0,
    duration: '00:00:00',
    quality: '1080p',
    bitrate: '2500 kbps'
  });
  
  const [streamTitle, setStreamTitle] = useState('Game Day Live at Our Venue');
  const [streamDescription, setStreamDescription] = useState('Join us for live game day atmosphere!');
  const [selectedCamera, setSelectedCamera] = useState('main');
  const [audioLevel, setAudioLevel] = useState(75);
  const [chatEnabled, setChatEnabled] = useState(true);
  
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamDurationRef = useRef<number>();

  // Simulate live stream stats updates
  useEffect(() => {
    if (isStreaming && !isPaused) {
      const interval = setInterval(() => {
        setStreamStats(prev => ({
          ...prev,
          viewerCount: Math.floor(Math.random() * 20) + prev.viewerCount + 1
        }));
      }, 5000);
      return () => clearInterval(interval);
    }
  }, [isStreaming, isPaused]);

  const handleStartStream = async () => {
    try {
      // In a real app, this would initialize the camera and streaming service
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: true, 
        audio: true 
      });
      
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
      }
      
      setIsStreaming(true);
      setStreamStats(prev => ({ ...prev, viewerCount: 1 }));
      
      // Start duration timer
      let seconds = 0;
      streamDurationRef.current = setInterval(() => {
        seconds++;
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        setStreamStats(prev => ({
          ...prev,
          duration: `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
        }));
      }, 1000);
      
    } catch (error) {
      console.error('Error starting stream:', error);
      alert('Could not access camera. Please check permissions.');
    }
  };

  const handleStopStream = () => {
    if (videoRef.current?.srcObject) {
      const stream = videoRef.current.srcObject as MediaStream;
      stream.getTracks().forEach(track => track.stop());
    }
    
    setIsStreaming(false);
    setIsPaused(false);
    
    if (streamDurationRef.current) {
      clearInterval(streamDurationRef.current);
    }
    
    setStreamStats({
      viewerCount: 0,
      duration: '00:00:00',
      quality: '1080p',
      bitrate: '2500 kbps'
    });
  };

  const handlePauseResume = () => {
    setIsPaused(!isPaused);
  };

  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Header */}
      <div className="pregame-gradient text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <Link to="/venue" className="mr-4 hover:opacity-80 transition-opacity">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </Link>
              <img src={PregameLogo} alt="Pregame" className="h-10 w-auto mr-4" />
              <div>
                <h1 className="text-3xl font-bold">Live Stream Manager</h1>
                <p className="text-blue-100">Broadcast your venue's game day atmosphere</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {isStreaming && (
                <div className="flex items-center bg-red-500 px-4 py-2 rounded-full shadow-lg">
                  <div className="w-3 h-3 bg-white rounded-full mr-2 animate-pulse"></div>
                  <span className="font-medium">LIVE</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          
          {/* Main Stream Area */}
          <div className="lg:col-span-2">
            {/* Video Preview */}
            <div className="bg-black rounded-lg overflow-hidden mb-6 relative">
              <video
                ref={videoRef}
                autoPlay
                muted
                playsInline
                className="w-full aspect-video object-cover"
                style={{ minHeight: '400px' }}
              >
                Your browser does not support the video tag.
              </video>
              
              {!isStreaming && (
                <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-80">
                  <div className="text-center text-white">
                    <svg className="w-16 h-16 mx-auto mb-4 opacity-60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                    </svg>
                    <p className="text-xl font-semibold">Stream Preview</p>
                    <p className="text-gray-300">Start streaming to see live video</p>
                  </div>
                </div>
              )}
              
              {isPaused && (
                <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50">
                  <div className="text-white text-center">
                    <svg className="w-12 h-12 mx-auto mb-2" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
                    </svg>
                    <p className="text-lg font-semibold">Stream Paused</p>
                  </div>
                </div>
              )}
            </div>

            {/* Stream Controls */}
            <div className="pregame-card">
              <div className="flex flex-wrap gap-4 mb-6">
                {!isStreaming ? (
                  <button
                    onClick={handleStartStream}
                    className="flex items-center px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium shadow-lg"
                  >
                    <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                    </svg>
                    Go Live
                  </button>
                ) : (
                  <div className="flex gap-4">
                    <button
                      onClick={handlePauseResume}
                      className={`flex items-center px-4 py-2 rounded-lg font-medium transition-colors ${
                        isPaused 
                          ? 'bg-green-600 text-white hover:bg-green-700' 
                          : 'bg-yellow-600 text-white hover:bg-yellow-700'
                      }`}
                    >
                      {isPaused ? (
                        <>
                          <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
                            <path d="m7 4 10 6L7 16V4z"/>
                          </svg>
                          Resume
                        </>
                      ) : (
                        <>
                          <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
                          </svg>
                          Pause
                        </>
                      )}
                    </button>
                    
                    <button
                      onClick={handleStopStream}
                      className="flex items-center px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors font-medium"
                    >
                      <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                      </svg>
                      Stop Stream
                    </button>
                  </div>
                )}
              </div>

              {/* Stream Settings */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Stream Title
                  </label>
                  <input
                    type="text"
                    value={streamTitle}
                    onChange={(e) => setStreamTitle(e.target.value)}
                    className="w-full px-3 py-2 rounded-md border focus:outline-none focus:ring-2 transition-colors"
                    style={{
                      background: 'var(--pregame-card-bg)',
                      color: 'var(--pregame-text-light)',
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      '--tw-ring-color': 'var(--pregame-orange)'
                    } as React.CSSProperties}
                    disabled={isStreaming}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Camera Source
                  </label>
                  <select
                    value={selectedCamera}
                    onChange={(e) => setSelectedCamera(e.target.value)}
                    className="w-full px-3 py-2 rounded-md border focus:outline-none focus:ring-2 transition-colors"
                    style={{
                      background: 'var(--pregame-card-bg)',
                      color: 'var(--pregame-text-light)',
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      '--tw-ring-color': 'var(--pregame-orange)'
                    } as React.CSSProperties}
                    disabled={isStreaming}
                  >
                    <option value="main">Main Camera</option>
                    <option value="bar">Bar Camera</option>
                    <option value="tvarea">TV Area Camera</option>
                    <option value="outdoor">Outdoor Seating</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Stream Description
                  </label>
                  <textarea
                    value={streamDescription}
                    onChange={(e) => setStreamDescription(e.target.value)}
                    rows={3}
                    className="w-full px-3 py-2 rounded-md border focus:outline-none focus:ring-2 transition-colors"
                    style={{
                      background: 'var(--pregame-card-bg)',
                      color: 'var(--pregame-text-light)',
                      borderColor: 'rgba(255, 255, 255, 0.1)',
                      '--tw-ring-color': 'var(--pregame-orange)'
                    } as React.CSSProperties}
                    disabled={isStreaming}
                    placeholder="Describe what fans can expect from your stream..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    Audio Level: <span style={{ color: 'var(--pregame-orange)' }}>{audioLevel}%</span>
                  </label>
                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={audioLevel}
                    onChange={(e) => setAudioLevel(Number(e.target.value))}
                    className="w-full h-2 rounded-lg appearance-none cursor-pointer"
                    style={{
                      background: 'linear-gradient(to right, var(--pregame-orange) 0%, var(--pregame-orange) ' + audioLevel + '%, rgba(255,255,255,0.2) ' + audioLevel + '%, rgba(255,255,255,0.2) 100%)'
                    }}
                  />
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="chatEnabled"
                    checked={chatEnabled}
                    onChange={(e) => setChatEnabled(e.target.checked)}
                    className="h-4 w-4 rounded border-gray-300 focus:ring-2"
                    style={{ 
                      accentColor: 'var(--pregame-orange)'
                    }}
                  />
                  <label htmlFor="chatEnabled" className="ml-2 block text-sm" style={{ color: 'var(--pregame-text-light)' }}>
                    Enable live chat for viewers
                  </label>
                </div>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Stream Stats */}
            <div className="pregame-card">
              <h3 className="text-lg font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>Stream Statistics</h3>
              <div className="space-y-4">
                <div className="flex justify-between">
                  <span style={{ color: 'var(--pregame-text-muted)' }}>Viewers</span>
                  <span className="font-semibold" style={{ color: 'var(--pregame-orange)' }}>{streamStats.viewerCount}</span>
                </div>
                <div className="flex justify-between">
                  <span style={{ color: 'var(--pregame-text-muted)' }}>Duration</span>
                  <span className="font-semibold" style={{ color: 'var(--pregame-text-light)' }}>{streamStats.duration}</span>
                </div>
                <div className="flex justify-between">
                  <span style={{ color: 'var(--pregame-text-muted)' }}>Quality</span>
                  <span className="font-semibold" style={{ color: 'var(--pregame-text-light)' }}>{streamStats.quality}</span>
                </div>
                <div className="flex justify-between">
                  <span style={{ color: 'var(--pregame-text-muted)' }}>Bitrate</span>
                  <span className="font-semibold" style={{ color: 'var(--pregame-text-light)' }}>{streamStats.bitrate}</span>
                </div>
              </div>
            </div>

            {/* Live Chat Preview */}
            {chatEnabled && (
              <div className="pregame-card">
                <h3 className="text-lg font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>Live Chat</h3>
                <div className="space-y-3 max-h-64 overflow-y-auto">
                  {isStreaming ? (
                    <>
                      <div className="text-sm">
                        <span className="font-medium" style={{ color: 'var(--pregame-blue-start)' }}>GameFan2024:</span>
                        <span className="ml-2" style={{ color: 'var(--pregame-text-light)' }}>Great atmosphere! 🏈</span>
                      </div>
                      <div className="text-sm">
                        <span className="font-medium text-green-400">SECFan:</span>
                        <span className="ml-2" style={{ color: 'var(--pregame-text-light)' }}>Love the energy here!</span>
                      </div>
                      <div className="text-sm">
                        <span className="font-medium text-purple-400">TigerFan:</span>
                        <span className="ml-2" style={{ color: 'var(--pregame-text-light)' }}>What's the special today?</span>
                      </div>
                    </>
                  ) : (
                    <p className="text-sm italic" style={{ color: 'var(--pregame-text-muted)' }}>Chat will appear here during live stream</p>
                  )}
                </div>
                {isStreaming && (
                  <div className="mt-4 flex">
                    <input
                      type="text"
                      placeholder="Respond to fans..."
                      className="flex-1 px-3 py-2 text-sm border rounded-l-md focus:outline-none focus:ring-2"
                      style={{
                        background: 'var(--pregame-card-bg)',
                        color: 'var(--pregame-text-light)',
                        borderColor: 'rgba(255, 255, 255, 0.1)'
                      }}
                    />
                    <button className="px-4 py-2 btn-pregame-primary rounded-r-md transition-colors">
                      Send
                    </button>
                  </div>
                )}
              </div>
            )}

            {/* Quick Actions */}
            <div className="pregame-card">
              <h3 className="text-lg font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>Quick Actions</h3>
              <div className="space-y-3">
                <Link 
                  to="/venue/specials" 
                  className="block w-full text-left py-2 px-3 rounded transition-colors text-sm hover:border-orange-500"
                  style={{
                    background: 'rgba(255, 255, 255, 0.05)',
                    color: 'var(--pregame-text-light)',
                    border: '1px solid rgba(255, 255, 255, 0.1)'
                  }}
                >
                  📢 Promote Current Specials
                </Link>
                <button 
                  className="w-full text-left py-2 px-3 rounded transition-colors text-sm hover:border-orange-500"
                  style={{
                    background: 'rgba(255, 255, 255, 0.05)',
                    color: 'var(--pregame-text-light)',
                    border: '1px solid rgba(255, 255, 255, 0.1)'
                  }}
                >
                  📊 Share Game Updates
                </button>
                <button 
                  className="w-full text-left py-2 px-3 rounded transition-colors text-sm hover:border-orange-500"
                  style={{
                    background: 'rgba(255, 255, 255, 0.05)',
                    color: 'var(--pregame-text-light)',
                    border: '1px solid rgba(255, 255, 255, 0.1)'
                  }}
                >
                  🎉 Announce Events
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LiveStreamManager; 