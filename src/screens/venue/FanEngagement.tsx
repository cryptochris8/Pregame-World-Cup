import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';

interface Review {
  id: string;
  fanName: string;
  fanAvatar?: string;
  rating: number;
  comment: string;
  date: string;
  response?: string;
  responseDate?: string;
  gameDay?: string;
}

interface Message {
  id: string;
  fanName: string;
  fanAvatar?: string;
  message: string;
  timestamp: string;
  type: 'question' | 'reservation' | 'feedback' | 'general';
  isRead: boolean;
  response?: string;
}

interface Event {
  id: string;
  title: string;
  description: string;
  date: string;
  time: string;
  type: 'game' | 'special' | 'event';
  attendeesCount: number;
  maxAttendees?: number;
}

const FanEngagement: React.FC = () => {
  const [activeTab, setActiveTab] = useState('reviews');
  const [reviews, setReviews] = useState<Review[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [replyText, setReplyText] = useState('');
  const [newEventModal, setNewEventModal] = useState(false);
  const [newEvent, setNewEvent] = useState({
    title: '',
    description: '',
    date: '',
    time: '',
    type: 'event' as const,
    maxAttendees: ''
  });

  // Mock data - in real app, this would come from your database
  useEffect(() => {
    setReviews([
      {
        id: '1',
        fanName: 'Jake Thompson',
        fanAvatar: '/api/placeholder/40/40',
        rating: 5,
        comment: 'Amazing atmosphere during the Auburn game! Great wings and cold beer. Will definitely be back for the next game!',
        date: '2024-01-15',
        gameDay: 'Auburn vs LSU'
      },
      {
        id: '2',
        fanName: 'Sarah Mitchell',
        fanAvatar: '/api/placeholder/40/40',
        rating: 4,
        comment: 'Love the new TVs and seating area. Food was good but service was a bit slow during halftime rush.',
        date: '2024-01-12',
        response: 'Thanks for the feedback, Sarah! We\'ve added more staff for game days to improve service speed. Hope to see you again soon!',
        responseDate: '2024-01-13'
      },
      {
        id: '3',
        fanName: 'Mike Wilson',
        fanAvatar: '/api/placeholder/40/40',
        rating: 5,
        comment: 'Best sports bar in Auburn! The game day specials are unbeatable and the energy is electric.',
        date: '2024-01-10',
        gameDay: 'Alabama vs Georgia'
      },
      {
        id: '4',
        fanName: 'Emma Davis',
        fanAvatar: '/api/placeholder/40/40',
        rating: 3,
        comment: 'Good place to watch games but could use more vegetarian options on the menu.',
        date: '2024-01-08'
      }
    ]);

    setMessages([
      {
        id: '1',
        fanName: 'Connor Riley',
        fanAvatar: '/api/placeholder/40/40',
        message: 'Hi! Do you take reservations for large groups on game days? Planning to bring 12 people for the championship game.',
        timestamp: '2024-01-16T14:30:00',
        type: 'reservation',
        isRead: false
      },
      {
        id: '2',
        fanName: 'Ashley Chen',
        fanAvatar: '/api/placeholder/40/40',
        message: 'What time do you usually open on Saturdays? Wanted to catch the early games.',
        timestamp: '2024-01-16T09:15:00',
        type: 'question',
        isRead: true,
        response: 'We open at 10 AM on Saturdays, 8 AM on game days! See you there!'
      },
      {
        id: '3',
        fanName: 'Tyler Brooks',
        fanAvatar: '/api/placeholder/40/40',
        message: 'The new wing flavors are incredible! Any chance you\'ll add more spicy options?',
        timestamp: '2024-01-15T20:45:00',
        type: 'feedback',
        isRead: true
      },
      {
        id: '4',
        fanName: 'Madison Taylor',
        fanAvatar: '/api/placeholder/40/40',
        message: 'Love the live stream feature! Can you show more of the outdoor seating area?',
        timestamp: '2024-01-15T16:20:00',
        type: 'general',
        isRead: false
      }
    ]);

    setEvents([
      {
        id: '1',
        title: 'SEC Championship Watch Party',
        description: 'Join us for the biggest game of the year! Special menu, drink deals, and prizes!',
        date: '2024-02-15',
        time: '18:00',
        type: 'game',
        attendeesCount: 45,
        maxAttendees: 100
      },
      {
        id: '2',
        title: 'Trivia Night',
        description: 'Weekly sports trivia with prizes and beer specials!',
        date: '2024-01-24',
        time: '19:00',
        type: 'event',
        attendeesCount: 23,
        maxAttendees: 50
      },
      {
        id: '3',
        title: 'New Menu Launch',
        description: 'Try our new lineup of game day favorites and craft cocktails!',
        date: '2024-01-20',
        time: '17:00',
        type: 'special',
        attendeesCount: 12
      }
    ]);
  }, []);

  const handleReplyToReview = (reviewId: string) => {
    if (replyText.trim()) {
      setReviews(reviews.map(review =>
        review.id === reviewId
          ? { ...review, response: replyText, responseDate: new Date().toISOString().split('T')[0] }
          : review
      ));
      setReplyText('');
      setReplyingTo(null);
    }
  };

  const handleReplyToMessage = (messageId: string) => {
    if (replyText.trim()) {
      setMessages(messages.map(message =>
        message.id === messageId
          ? { ...message, response: replyText, isRead: true }
          : message
      ));
      setReplyText('');
      setReplyingTo(null);
    }
  };

  const markMessageAsRead = (messageId: string) => {
    setMessages(messages.map(message =>
      message.id === messageId ? { ...message, isRead: true } : message
    ));
  };

  const handleCreateEvent = () => {
    if (newEvent.title && newEvent.date && newEvent.time) {
      const event: Event = {
        id: Date.now().toString(),
        title: newEvent.title,
        description: newEvent.description,
        date: newEvent.date,
        time: newEvent.time,
        type: newEvent.type,
        attendeesCount: 0,
        maxAttendees: newEvent.maxAttendees ? parseInt(newEvent.maxAttendees) : undefined
      };
      setEvents([event, ...events]);
      setNewEvent({
        title: '',
        description: '',
        date: '',
        time: '',
        type: 'event',
        maxAttendees: ''
      });
      setNewEventModal(false);
    }
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${i < rating ? 'text-yellow-400' : 'text-gray-300'}`}
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
      </svg>
    ));
  };

  const getMessageIcon = (type: string) => {
    switch (type) {
      case 'reservation':
        return '📅';
      case 'question':
        return '❓';
      case 'feedback':
        return '💬';
      default:
        return '📧';
    }
  };

  const unreadCount = messages.filter(m => !m.isRead).length;
  const unansweredReviews = reviews.filter(r => !r.response).length;

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
                <h1 className="text-3xl font-bold">Fan Engagement</h1>
                <p className="text-blue-100">Connect with your fans and build community</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {(unreadCount > 0 || unansweredReviews > 0) && (
                <div className="bg-red-600 text-white px-3 py-1 rounded-full text-sm font-medium">
                  {unreadCount + unansweredReviews} pending
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Tab Navigation */}
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8 px-6" aria-label="Tabs">
              {[
                { key: 'reviews', label: 'Reviews', count: unansweredReviews, icon: '⭐' },
                { key: 'messages', label: 'Messages', count: unreadCount, icon: '💬' },
                { key: 'events', label: 'Events', count: events.length, icon: '🎉' }
              ].map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`${
                    activeTab === tab.key
                      ? 'border-[#355E3B] text-[#355E3B]'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm flex items-center`}
                >
                  <span className="mr-2">{tab.icon}</span>
                  {tab.label}
                  {tab.count > 0 && (
                    <span className="ml-2 bg-red-100 text-red-800 text-xs font-medium px-2 py-1 rounded-full">
                      {tab.count}
                    </span>
                  )}
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Reviews Tab */}
        {activeTab === 'reviews' && (
          <div className="space-y-6">
            {reviews.map((review) => (
              <div key={review.id} className="bg-white rounded-lg shadow p-6">
                <div className="flex items-start space-x-4">
                  <img
                    className="w-10 h-10 rounded-full"
                    src={review.fanAvatar || '/api/placeholder/40/40'}
                    alt={review.fanName}
                  />
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <div>
                        <h4 className="text-lg font-semibold text-gray-900">{review.fanName}</h4>
                        <div className="flex items-center space-x-2">
                          <div className="flex">{renderStars(review.rating)}</div>
                          <span className="text-sm text-gray-500">
                            {new Date(review.date).toLocaleDateString()}
                          </span>
                          {review.gameDay && (
                            <span className="text-sm bg-[#355E3B] text-white px-2 py-1 rounded-full">
                              {review.gameDay}
                            </span>
                          )}
                        </div>
                      </div>
                      {!review.response && (
                        <button
                          onClick={() => setReplyingTo(review.id)}
                          className="text-[#355E3B] hover:bg-green-50 px-3 py-1 rounded-lg transition-colors"
                        >
                          Reply
                        </button>
                      )}
                    </div>
                    
                    <p className="text-gray-700 mb-4">{review.comment}</p>
                    
                    {review.response && (
                      <div className="bg-gray-50 rounded-lg p-4 mt-4">
                        <div className="flex items-center mb-2">
                          <span className="text-sm font-medium text-gray-900">Your Response</span>
                          <span className="text-sm text-gray-500 ml-2">
                            {new Date(review.responseDate!).toLocaleDateString()}
                          </span>
                        </div>
                        <p className="text-gray-700">{review.response}</p>
                      </div>
                    )}
                    
                    {replyingTo === review.id && (
                      <div className="mt-4">
                        <textarea
                          value={replyText}
                          onChange={(e) => setReplyText(e.target.value)}
                          placeholder="Write your response..."
                          rows={3}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                        />
                        <div className="flex justify-end space-x-2 mt-2">
                          <button
                            onClick={() => {
                              setReplyingTo(null);
                              setReplyText('');
                            }}
                            className="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
                          >
                            Cancel
                          </button>
                          <button
                            onClick={() => handleReplyToReview(review.id)}
                            className="px-4 py-2 bg-[#355E3B] text-white rounded-lg hover:bg-[#2d4f31] transition-colors"
                          >
                            Send Reply
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Messages Tab */}
        {activeTab === 'messages' && (
          <div className="space-y-4">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`bg-white rounded-lg shadow p-6 ${!message.isRead ? 'border-l-4 border-[#355E3B]' : ''}`}
              >
                <div className="flex items-start space-x-4">
                  <img
                    className="w-10 h-10 rounded-full"
                    src={message.fanAvatar || '/api/placeholder/40/40'}
                    alt={message.fanName}
                  />
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <h4 className="text-lg font-semibold text-gray-900">{message.fanName}</h4>
                        <span className="text-lg">{getMessageIcon(message.type)}</span>
                        <span className="text-sm bg-gray-100 text-gray-700 px-2 py-1 rounded-full">
                          {message.type}
                        </span>
                        {!message.isRead && (
                          <span className="bg-red-100 text-red-800 text-xs font-medium px-2 py-1 rounded-full">
                            New
                          </span>
                        )}
                      </div>
                      <div className="flex items-center space-x-2">
                        <span className="text-sm text-gray-500">
                          {new Date(message.timestamp).toLocaleString()}
                        </span>
                        {!message.isRead && (
                          <button
                            onClick={() => markMessageAsRead(message.id)}
                            className="text-blue-600 hover:bg-blue-50 px-2 py-1 rounded text-sm"
                          >
                            Mark Read
                          </button>
                        )}
                      </div>
                    </div>
                    
                    <p className="text-gray-700 mb-4">{message.message}</p>
                    
                    {message.response && (
                      <div className="bg-gray-50 rounded-lg p-4 mt-4">
                        <div className="flex items-center mb-2">
                          <span className="text-sm font-medium text-gray-900">Your Response</span>
                        </div>
                        <p className="text-gray-700">{message.response}</p>
                      </div>
                    )}
                    
                    {!message.response && (
                      <div className="flex space-x-2">
                        <button
                          onClick={() => setReplyingTo(message.id)}
                          className="text-[#355E3B] hover:bg-green-50 px-3 py-1 rounded-lg transition-colors"
                        >
                          Reply
                        </button>
                      </div>
                    )}
                    
                    {replyingTo === message.id && (
                      <div className="mt-4">
                        <textarea
                          value={replyText}
                          onChange={(e) => setReplyText(e.target.value)}
                          placeholder="Write your response..."
                          rows={3}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                        />
                        <div className="flex justify-end space-x-2 mt-2">
                          <button
                            onClick={() => {
                              setReplyingTo(null);
                              setReplyText('');
                            }}
                            className="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
                          >
                            Cancel
                          </button>
                          <button
                            onClick={() => handleReplyToMessage(message.id)}
                            className="px-4 py-2 bg-[#355E3B] text-white rounded-lg hover:bg-[#2d4f31] transition-colors"
                          >
                            Send Reply
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Events Tab */}
        {activeTab === 'events' && (
          <div>
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-bold text-gray-900">Upcoming Events</h2>
              <button
                onClick={() => setNewEventModal(true)}
                className="bg-[#355E3B] text-white px-6 py-2 rounded-lg font-medium hover:bg-[#2d4f31] transition-colors"
              >
                + Create Event
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {events.map((event) => (
                <div key={event.id} className="bg-white rounded-lg shadow p-6">
                  <div className="flex items-center justify-between mb-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      event.type === 'game' ? 'bg-red-100 text-red-800' :
                      event.type === 'special' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-blue-100 text-blue-800'
                    }`}>
                      {event.type.charAt(0).toUpperCase() + event.type.slice(1)}
                    </span>
                    <span className="text-sm text-gray-500">
                      {new Date(event.date).toLocaleDateString()}
                    </span>
                  </div>
                  
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">{event.title}</h3>
                  <p className="text-gray-600 mb-4">{event.description}</p>
                  
                  <div className="flex items-center justify-between">
                    <div className="text-sm text-gray-500">
                      🕐 {event.time}
                    </div>
                    <div className="text-sm text-gray-700">
                      👥 {event.attendeesCount}
                      {event.maxAttendees && `/${event.maxAttendees}`} attending
                    </div>
                  </div>
                  
                  {event.maxAttendees && (
                    <div className="mt-3">
                      <div className="bg-gray-200 rounded-full h-2">
                        <div
                          className="bg-[#355E3B] h-2 rounded-full"
                          style={{ width: `${(event.attendeesCount / event.maxAttendees) * 100}%` }}
                        ></div>
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Create Event Modal */}
      {newEventModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-bold text-gray-900">Create New Event</h2>
              <button
                onClick={() => setNewEventModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Event Title
                </label>
                <input
                  type="text"
                  value={newEvent.title}
                  onChange={(e) => setNewEvent({ ...newEvent, title: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                  placeholder="e.g., SEC Championship Watch Party"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Description
                </label>
                <textarea
                  value={newEvent.description}
                  onChange={(e) => setNewEvent({ ...newEvent, description: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                  placeholder="Describe your event..."
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date
                  </label>
                  <input
                    type="date"
                    value={newEvent.date}
                    onChange={(e) => setNewEvent({ ...newEvent, date: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Time
                  </label>
                  <input
                    type="time"
                    value={newEvent.time}
                    onChange={(e) => setNewEvent({ ...newEvent, time: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Event Type
                  </label>
                  <select
                    value={newEvent.type}
                    onChange={(e) => setNewEvent({ ...newEvent, type: e.target.value as any })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                  >
                    <option value="event">General Event</option>
                    <option value="game">Game Day</option>
                    <option value="special">Special Offer</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Max Attendees
                  </label>
                  <input
                    type="number"
                    value={newEvent.maxAttendees}
                    onChange={(e) => setNewEvent({ ...newEvent, maxAttendees: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#355E3B]"
                    placeholder="Optional"
                  />
                </div>
              </div>

              <div className="flex justify-end space-x-4 pt-4">
                <button
                  type="button"
                  onClick={() => setNewEventModal(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleCreateEvent}
                  className="px-6 py-2 bg-[#355E3B] text-white rounded-lg hover:bg-[#2d4f31] transition-colors"
                >
                  Create Event
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default FanEngagement; 