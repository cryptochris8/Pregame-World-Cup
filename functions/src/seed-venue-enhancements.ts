/**
 * Seed Venue Enhancements Script
 *
 * Seeds test data for venue enhancements in Firestore.
 * Creates sample venues with various configurations:
 * - Free and premium tiers
 * - TV setups
 * - Game day specials
 * - Atmosphere settings
 * - Live capacity data
 *
 * Usage:
 *   npx ts-node src/seed-venue-enhancements.ts [--dryRun] [--clear]
 *
 * Examples:
 *   npx ts-node src/seed-venue-enhancements.ts              # Seed all test venues
 *   npx ts-node src/seed-venue-enhancements.ts --dryRun     # Preview without uploading
 *   npx ts-node src/seed-venue-enhancements.ts --clear      # Clear existing and reseed
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// Configuration
// ============================================================================

const DRY_RUN = process.argv.includes('--dryRun');
const CLEAR_EXISTING = process.argv.includes('--clear');

// ============================================================================
// Firebase Initialization
// ============================================================================

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  admin.initializeApp({
    projectId: 'pregame-b089e',
  });
}

const db = admin.firestore();

// ============================================================================
// Types
// ============================================================================

interface ScreenDetail {
  id: string;
  size: string;
  location: string;
  hasAudio: boolean;
  isPrimary: boolean;
}

interface TvSetup {
  totalScreens: number;
  screenDetails: ScreenDetail[];
  audioSetup: 'dedicated' | 'shared' | 'headphones_available';
}

interface GameDaySpecial {
  id: string;
  title: string;
  description: string;
  price?: number;
  discountPercent?: number;
  validFor: 'all_matches' | 'specific_matches';
  matchIds: string[];
  validDays: string[];
  validTimeStart?: string;
  validTimeEnd?: string;
  isActive: boolean;
  expiresAt?: admin.firestore.Timestamp;
  createdAt: admin.firestore.Timestamp;
}

interface AtmosphereSettings {
  tags: string[];
  fanBaseAffinity: string[];
  noiseLevel: 'quiet' | 'moderate' | 'loud' | 'very_loud';
  crowdDensity: 'spacious' | 'comfortable' | 'cozy' | 'packed';
}

interface LiveCapacity {
  currentOccupancy: number;
  maxCapacity: number;
  lastUpdated: admin.firestore.Timestamp;
  reservationsAvailable: boolean;
  waitTimeMinutes?: number;
}

interface BroadcastingSchedule {
  matchIds: string[];
  lastUpdated: admin.firestore.Timestamp;
  autoSelectByTeam: string[];
}

interface VenueEnhancementData {
  venueId: string;
  venueName: string; // For logging only
  ownerId: string;
  subscriptionTier: 'free' | 'premium';
  showsMatches: boolean;
  broadcastingSchedule?: BroadcastingSchedule;
  tvSetup?: TvSetup;
  gameSpecials: GameDaySpecial[];
  atmosphere?: AtmosphereSettings;
  liveCapacity?: LiveCapacity;
  isVerified: boolean;
  featuredUntil?: admin.firestore.Timestamp;
}

// ============================================================================
// Sample Match IDs (from World Cup 2026 schedule)
// ============================================================================

const SAMPLE_MATCH_IDS = [
  'wc2026_match_1', // USA vs opponent
  'wc2026_match_2', // Mexico vs opponent
  'wc2026_match_3', // Canada vs opponent
  'wc2026_match_4', // Brazil vs opponent
  'wc2026_match_5', // Argentina vs opponent
];

// ============================================================================
// Test Venue Data
// ============================================================================

const now = admin.firestore.Timestamp.now();
const oneMonthFromNow = admin.firestore.Timestamp.fromDate(
  new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
);

const TEST_VENUES: VenueEnhancementData[] = [
  // ========== PREMIUM VENUE 1 - Sports Bar with full setup ==========
  {
    venueId: 'test_venue_premium_sports_bar_1',
    venueName: 'The Goal Line Sports Bar',
    ownerId: 'test_owner_1',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS.slice(0, 3),
      lastUpdated: now,
      autoSelectByTeam: ['USA', 'MEX'],
    },
    tvSetup: {
      totalScreens: 12,
      screenDetails: [
        { id: 'screen_1', size: '85"', location: 'Main Bar', hasAudio: true, isPrimary: true },
        { id: 'screen_2', size: '75"', location: 'Main Bar', hasAudio: true, isPrimary: false },
        { id: 'screen_3', size: '65"', location: 'Main Bar', hasAudio: false, isPrimary: false },
        { id: 'screen_4', size: '65"', location: 'Patio', hasAudio: true, isPrimary: false },
        { id: 'screen_5', size: '55"', location: 'Private Room', hasAudio: true, isPrimary: false },
      ],
      audioSetup: 'dedicated',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: '$5 Domestic Pitchers',
        description: 'Get $5 pitchers of domestic beer during all World Cup matches',
        price: 5.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_2',
        title: 'Half-Price Wings',
        description: '50% off wings during USA games',
        discountPercent: 50,
        validFor: 'specific_matches',
        matchIds: [SAMPLE_MATCH_IDS[0]],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_3',
        title: 'World Cup Burger Combo',
        description: 'Burger, fries, and beer for $15',
        price: 15.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['rowdy', '21+', 'standing-room'],
      fanBaseAffinity: ['USA', 'MEX'],
      noiseLevel: 'very_loud',
      crowdDensity: 'packed',
    },
    liveCapacity: {
      currentOccupancy: 85,
      maxCapacity: 150,
      lastUpdated: now,
      reservationsAvailable: true,
      waitTimeMinutes: 15,
    },
    isVerified: true,
    featuredUntil: oneMonthFromNow,
  },

  // ========== PREMIUM VENUE 2 - Family Restaurant ==========
  {
    venueId: 'test_venue_premium_family_restaurant_2',
    venueName: 'Soccer Mom\'s Kitchen',
    ownerId: 'test_owner_2',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS,
      lastUpdated: now,
      autoSelectByTeam: ['USA'],
    },
    tvSetup: {
      totalScreens: 6,
      screenDetails: [
        { id: 'screen_1', size: '75"', location: 'Main Dining', hasAudio: false, isPrimary: true },
        { id: 'screen_2', size: '55"', location: 'Main Dining', hasAudio: false, isPrimary: false },
        { id: 'screen_3', size: '55"', location: 'Bar Area', hasAudio: true, isPrimary: false },
        { id: 'screen_4', size: '42"', location: 'Patio', hasAudio: false, isPrimary: false },
      ],
      audioSetup: 'shared',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: 'Kids Eat Free',
        description: 'Kids 12 and under eat free with adult entree purchase during matches',
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_2',
        title: 'Family Platter',
        description: 'Feed the whole family - nachos, wings, and sliders for $35',
        price: 35.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['family-friendly', 'casual', 'outdoor-seating'],
      fanBaseAffinity: ['USA'],
      noiseLevel: 'moderate',
      crowdDensity: 'comfortable',
    },
    liveCapacity: {
      currentOccupancy: 45,
      maxCapacity: 100,
      lastUpdated: now,
      reservationsAvailable: true,
    },
    isVerified: true,
  },

  // ========== PREMIUM VENUE 3 - Upscale Lounge ==========
  {
    venueId: 'test_venue_premium_lounge_3',
    venueName: 'The Pitch Club',
    ownerId: 'test_owner_3',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS.slice(0, 2),
      lastUpdated: now,
      autoSelectByTeam: ['ARG', 'BRA'],
    },
    tvSetup: {
      totalScreens: 8,
      screenDetails: [
        { id: 'screen_1', size: 'Projector 120"', location: 'Main Lounge', hasAudio: true, isPrimary: true },
        { id: 'screen_2', size: '85"', location: 'VIP Area', hasAudio: true, isPrimary: false },
        { id: 'screen_3', size: '65"', location: 'Bar', hasAudio: false, isPrimary: false },
      ],
      audioSetup: 'dedicated',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: 'Champagne Toast',
        description: 'Free champagne toast for every goal scored',
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_2',
        title: 'VIP Table Package',
        description: 'Reserved table, bottle service, and appetizers for $200',
        price: 200.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['upscale', '21+', 'reservations-required', 'private-rooms'],
      fanBaseAffinity: ['ARG', 'BRA'],
      noiseLevel: 'loud',
      crowdDensity: 'cozy',
    },
    liveCapacity: {
      currentOccupancy: 60,
      maxCapacity: 80,
      lastUpdated: now,
      reservationsAvailable: false,
      waitTimeMinutes: 30,
    },
    isVerified: true,
    featuredUntil: oneMonthFromNow,
  },

  // ========== PREMIUM VENUE 4 - Mexican Restaurant ==========
  {
    venueId: 'test_venue_premium_mexican_4',
    venueName: 'El Gol Cantina',
    ownerId: 'test_owner_4',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS,
      lastUpdated: now,
      autoSelectByTeam: ['MEX'],
    },
    tvSetup: {
      totalScreens: 10,
      screenDetails: [
        { id: 'screen_1', size: '75"', location: 'Main Bar', hasAudio: true, isPrimary: true },
        { id: 'screen_2', size: '65"', location: 'Dining Room', hasAudio: false, isPrimary: false },
        { id: 'screen_3', size: '55"', location: 'Patio', hasAudio: true, isPrimary: false },
      ],
      audioSetup: 'dedicated',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: 'Margarita Madness',
        description: '$6 margaritas all day during Mexico games',
        price: 6.00,
        validFor: 'specific_matches',
        matchIds: [SAMPLE_MATCH_IDS[1]],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_2',
        title: 'Taco Tuesday Special',
        description: '$2 tacos every Tuesday during World Cup',
        price: 2.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: ['tuesday'],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_3',
        title: 'Guac & Chips',
        description: 'Free guac and chips with entree during matches',
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['rowdy', 'casual', 'outdoor-seating'],
      fanBaseAffinity: ['MEX'],
      noiseLevel: 'very_loud',
      crowdDensity: 'packed',
    },
    liveCapacity: {
      currentOccupancy: 120,
      maxCapacity: 150,
      lastUpdated: now,
      reservationsAvailable: true,
      waitTimeMinutes: 20,
    },
    isVerified: true,
  },

  // ========== FREE VENUE 1 - Basic bar with shows matches toggle ==========
  {
    venueId: 'test_venue_free_bar_1',
    venueName: 'Corner Pub',
    ownerId: 'test_owner_5',
    subscriptionTier: 'free',
    showsMatches: true,
    gameSpecials: [],
    isVerified: false,
  },

  // ========== FREE VENUE 2 - Another free venue ==========
  {
    venueId: 'test_venue_free_cafe_2',
    venueName: 'Kick Off Cafe',
    ownerId: 'test_owner_6',
    subscriptionTier: 'free',
    showsMatches: true,
    gameSpecials: [],
    isVerified: false,
  },

  // ========== FREE VENUE 3 - Not showing matches ==========
  {
    venueId: 'test_venue_free_restaurant_3',
    venueName: 'Bistro 90',
    ownerId: 'test_owner_7',
    subscriptionTier: 'free',
    showsMatches: false,
    gameSpecials: [],
    isVerified: false,
  },

  // ========== PREMIUM VENUE 5 - Brewery ==========
  {
    venueId: 'test_venue_premium_brewery_5',
    venueName: 'Offside Brewing Co.',
    ownerId: 'test_owner_8',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS,
      lastUpdated: now,
      autoSelectByTeam: ['USA', 'ENG', 'GER'],
    },
    tvSetup: {
      totalScreens: 15,
      screenDetails: [
        { id: 'screen_1', size: 'Projector 150"', location: 'Beer Hall', hasAudio: true, isPrimary: true },
        { id: 'screen_2', size: '75"', location: 'Beer Hall', hasAudio: false, isPrimary: false },
        { id: 'screen_3', size: '75"', location: 'Beer Hall', hasAudio: false, isPrimary: false },
        { id: 'screen_4', size: '65"', location: 'Taproom', hasAudio: true, isPrimary: false },
        { id: 'screen_5', size: '55"', location: 'Beer Garden', hasAudio: true, isPrimary: false },
      ],
      audioSetup: 'dedicated',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: 'Flight Night',
        description: '$12 beer flights during all matches',
        price: 12.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_2',
        title: 'Goal! Get a Free Pint',
        description: 'Free pint for everyone when USA scores',
        validFor: 'specific_matches',
        matchIds: [SAMPLE_MATCH_IDS[0]],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
      {
        id: 'special_3',
        title: 'Pretzel & Beer Combo',
        description: 'Giant pretzel + any pint for $10',
        price: 10.00,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['casual', 'outdoor-seating', '21+', 'standing-room'],
      fanBaseAffinity: ['USA', 'ENG', 'GER'],
      noiseLevel: 'loud',
      crowdDensity: 'comfortable',
    },
    liveCapacity: {
      currentOccupancy: 180,
      maxCapacity: 300,
      lastUpdated: now,
      reservationsAvailable: true,
    },
    isVerified: true,
    featuredUntil: oneMonthFromNow,
  },

  // ========== PREMIUM VENUE 6 - Hotel Bar ==========
  {
    venueId: 'test_venue_premium_hotel_6',
    venueName: 'The Penalty Box Lounge',
    ownerId: 'test_owner_9',
    subscriptionTier: 'premium',
    showsMatches: true,
    broadcastingSchedule: {
      matchIds: SAMPLE_MATCH_IDS.slice(0, 4),
      lastUpdated: now,
      autoSelectByTeam: [],
    },
    tvSetup: {
      totalScreens: 4,
      screenDetails: [
        { id: 'screen_1', size: '65"', location: 'Lounge', hasAudio: true, isPrimary: true },
        { id: 'screen_2', size: '55"', location: 'Lounge', hasAudio: false, isPrimary: false },
        { id: 'screen_3', size: '42"', location: 'Bar', hasAudio: false, isPrimary: false },
      ],
      audioSetup: 'headphones_available',
    },
    gameSpecials: [
      {
        id: 'special_1',
        title: 'Happy Hour Extended',
        description: 'Happy hour prices all game long',
        discountPercent: 25,
        validFor: 'all_matches',
        matchIds: [],
        validDays: [],
        isActive: true,
        createdAt: now,
      },
    ],
    atmosphere: {
      tags: ['chill', 'upscale', '21+'],
      fanBaseAffinity: [],
      noiseLevel: 'moderate',
      crowdDensity: 'spacious',
    },
    liveCapacity: {
      currentOccupancy: 25,
      maxCapacity: 60,
      lastUpdated: now,
      reservationsAvailable: true,
    },
    isVerified: true,
  },
];

// ============================================================================
// Main Function
// ============================================================================

async function seedVenueEnhancements() {
  console.log('========================================');
  console.log('Venue Enhancement Seed Script');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no data will be uploaded)' : 'LIVE (uploading to Firestore)'}`);
  if (CLEAR_EXISTING) {
    console.log('Clear Mode: Will delete existing test venues first');
  }
  console.log('');

  // Clear existing test data if requested
  if (CLEAR_EXISTING && !DRY_RUN) {
    console.log('Clearing existing test venue enhancements...');
    const existingDocs = await db.collection('venue_enhancements')
      .where('ownerId', '>=', 'test_owner_')
      .where('ownerId', '<=', 'test_owner_\uf8ff')
      .get();

    const batch = db.batch();
    existingDocs.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();
    console.log(`Deleted ${existingDocs.size} existing test documents`);
    console.log('');
  }

  console.log(`Processing ${TEST_VENUES.length} test venues...`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const venueData of TEST_VENUES) {
    try {
      const tierLabel = venueData.subscriptionTier === 'premium' ? '⭐ PREMIUM' : '📦 FREE';
      console.log(`Processing: ${venueData.venueName} (${tierLabel})`);

      const doc: Record<string, any> = {
        ownerId: venueData.ownerId,
        subscriptionTier: venueData.subscriptionTier,
        showsMatches: venueData.showsMatches,
        isVerified: venueData.isVerified,
        createdAt: now,
        updatedAt: now,
      };

      // Add premium features if present
      if (venueData.broadcastingSchedule) {
        doc.broadcastingSchedule = venueData.broadcastingSchedule;
      }
      if (venueData.tvSetup) {
        doc.tvSetup = venueData.tvSetup;
      }
      if (venueData.gameSpecials.length > 0) {
        doc.gameSpecials = venueData.gameSpecials;
      }
      if (venueData.atmosphere) {
        doc.atmosphere = venueData.atmosphere;
      }
      if (venueData.liveCapacity) {
        doc.liveCapacity = venueData.liveCapacity;
      }
      if (venueData.featuredUntil) {
        doc.featuredUntil = venueData.featuredUntil;
      }

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would create: ${venueData.venueId}`);
        if (venueData.tvSetup) {
          console.log(`    - TVs: ${venueData.tvSetup.totalScreens}`);
        }
        if (venueData.gameSpecials.length > 0) {
          console.log(`    - Specials: ${venueData.gameSpecials.length}`);
        }
        if (venueData.atmosphere) {
          console.log(`    - Tags: ${venueData.atmosphere.tags.join(', ')}`);
        }
      } else {
        await db.collection('venue_enhancements').doc(venueData.venueId).set(doc);
        console.log(`  Created: ${venueData.venueId}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ERROR processing ${venueData.venueName}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total venues processed: ${TEST_VENUES.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log('');

  const premiumCount = TEST_VENUES.filter(v => v.subscriptionTier === 'premium').length;
  const freeCount = TEST_VENUES.filter(v => v.subscriptionTier === 'free').length;
  console.log(`Premium venues: ${premiumCount}`);
  console.log(`Free venues: ${freeCount}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  } else {
    console.log('Test venue IDs for use in app:');
    TEST_VENUES.forEach(v => {
      console.log(`  - ${v.venueId}`);
    });
  }
}

// Run the script
seedVenueEnhancements()
  .then(() => {
    console.log('');
    console.log('Venue enhancement seed script completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Venue enhancement seed script failed:', error);
    process.exit(1);
  });
