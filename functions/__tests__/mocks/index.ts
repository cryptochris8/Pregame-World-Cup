/**
 * Mock Index
 *
 * Central export for all test mocks.
 */

export * from './firebase-admin.mock';
export * from './stripe.mock';

// Test data factories
export const createTestUser = (overrides: Partial<{
  uid: string;
  email: string;
  displayName: string;
  fcmToken: string;
  favoriteTeamCodes: string[];
}> = {}) => ({
  uid: overrides.uid || 'test-user-id',
  email: overrides.email || 'test@example.com',
  displayName: overrides.displayName || 'Test User',
  fcmToken: overrides.fcmToken || 'test-fcm-token',
  favoriteTeamCodes: overrides.favoriteTeamCodes || ['USA', 'MEX'],
  createdAt: new Date(),
  updatedAt: new Date(),
});

export const createTestWatchParty = (overrides: Partial<{
  id: string;
  hostId: string;
  hostName: string;
  name: string;
  gameId: string;
  gameName: string;
  status: string;
}> = {}) => ({
  id: overrides.id || 'test-party-id',
  hostId: overrides.hostId || 'test-host-id',
  hostName: overrides.hostName || 'Test Host',
  name: overrides.name || 'Test Watch Party',
  gameId: overrides.gameId || 'test-game-id',
  gameName: overrides.gameName || 'USA vs Mexico',
  status: overrides.status || 'active',
  visibility: 'private',
  createdAt: new Date(),
  gameDateTime: new Date(Date.now() + 24 * 60 * 60 * 1000), // Tomorrow
});

export const createTestWatchPartyInvite = (overrides: Partial<{
  id: string;
  watchPartyId: string;
  watchPartyName: string;
  inviterId: string;
  inviterName: string;
  inviteeId: string;
  message: string;
  status: string;
}> = {}) => ({
  id: overrides.id || 'test-invite-id',
  watchPartyId: overrides.watchPartyId || 'test-party-id',
  watchPartyName: overrides.watchPartyName || 'Test Watch Party',
  inviterId: overrides.inviterId || 'test-inviter-id',
  inviterName: overrides.inviterName || 'Test Inviter',
  inviteeId: overrides.inviteeId || 'test-invitee-id',
  message: overrides.message || 'Come watch the game!',
  status: overrides.status || 'pending',
  createdAt: new Date(),
});

export const createTestMatchReminder = (overrides: Partial<{
  id: string;
  userId: string;
  matchId: string;
  matchName: string;
  homeTeamCode: string;
  awayTeamCode: string;
  timingMinutes: number;
  isEnabled: boolean;
  isSent: boolean;
  matchDateTimeUtc: Date;
  reminderDateTimeUtc: Date;
}> = {}) => {
  const matchDateTime = overrides.matchDateTimeUtc || new Date(Date.now() + 30 * 60 * 1000); // 30 mins from now
  const reminderDateTime = overrides.reminderDateTimeUtc || new Date(Date.now()); // Now

  return {
    id: overrides.id || 'test-reminder-id',
    userId: overrides.userId || 'test-user-id',
    matchId: overrides.matchId || 'test-match-id',
    matchName: overrides.matchName || 'USA vs Mexico',
    homeTeamCode: overrides.homeTeamCode || 'USA',
    awayTeamCode: overrides.awayTeamCode || 'MEX',
    timingMinutes: overrides.timingMinutes || 30,
    isEnabled: overrides.isEnabled !== undefined ? overrides.isEnabled : true,
    isSent: overrides.isSent !== undefined ? overrides.isSent : false,
    matchDateTimeUtc: matchDateTime,
    reminderDateTimeUtc: reminderDateTime,
    createdAt: new Date(),
  };
};

export const createTestFanPass = (overrides: Partial<{
  userId: string;
  passType: 'fan_pass' | 'superfan_pass';
  status: 'active' | 'expired' | 'cancelled';
}> = {}) => ({
  userId: overrides.userId || 'test-user-id',
  passType: overrides.passType || 'fan_pass',
  status: overrides.status || 'active',
  features: {
    adFree: true,
    advancedStats: true,
    customAlerts: true,
  },
  purchasedAt: new Date(),
  validFrom: new Date('2026-06-11'),
  validUntil: new Date('2026-07-20'),
});

export const createTestVenueEnhancement = (overrides: Partial<{
  venueId: string;
  ownerId: string;
  subscriptionTier: 'free' | 'premium';
}> = {}) => ({
  venueId: overrides.venueId || 'test-venue-id',
  ownerId: overrides.ownerId || 'test-owner-id',
  subscriptionTier: overrides.subscriptionTier || 'free',
  showsMatches: true,
  createdAt: new Date(),
  updatedAt: new Date(),
});

// Mock HTTP request/response for testing HTTP functions
export const createMockHttpRequest = (overrides: Partial<{
  method: string;
  query: Record<string, string>;
  body: any;
  headers: Record<string, string>;
  rawBody: Buffer;
}> = {}) => ({
  method: overrides.method || 'GET',
  query: overrides.query || {},
  body: overrides.body || {},
  headers: overrides.headers || {},
  rawBody: overrides.rawBody || Buffer.from(''),
});

export const createMockHttpResponse = () => {
  const response: any = {
    status: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    set: jest.fn().mockReturnThis(),
    end: jest.fn().mockReturnThis(),
    _statusCode: 200,
    _body: null,
    _headers: {} as Record<string, string>,
  };

  // Track actual values
  response.status.mockImplementation((code: number) => {
    response._statusCode = code;
    return response;
  });

  response.send.mockImplementation((body: any) => {
    response._body = body;
    return response;
  });

  response.json.mockImplementation((body: any) => {
    response._body = body;
    return response;
  });

  response.set.mockImplementation((key: string, value: string) => {
    response._headers[key] = value;
    return response;
  });

  return response;
};

// Mock callable context for onCall functions
export const createMockCallableContext = (overrides: Partial<{
  auth: { uid: string; token: { email?: string } } | null;
}> = {}) => ({
  auth: overrides.auth !== undefined ? overrides.auth : {
    uid: 'test-user-id',
    token: { email: 'test@example.com' },
  },
});
