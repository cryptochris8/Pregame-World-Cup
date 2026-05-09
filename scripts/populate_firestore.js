/**
 * Firestore Data Population Script
 * Uploads World Cup 2026 seed data to Firebase
 *
 * Data included:
 * - Enhanced National Teams (10 teams with historical data)
 * - Head-to-Head Matchups (8 rivalries)
 * - Player Spotlight (260 players from 10 teams)
 * - Manager Database (48 managers for all qualified teams)
 * - Venues (16 stadiums)
 * - Groups (12 groups)
 * - Sample Matches
 *
 * Usage: node scripts/populate_firestore.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require('../firebase-service-account.json'); // You'll need to download this

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'pregame-b089e'
});

const db = admin.firestore();

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

/**
 * Upload National Teams to Firestore
 */
async function uploadTeams() {
  log('\n🏴 Uploading National Teams...', 'blue');

  const teamsPath = path.join(__dirname, '../data/seed/teams/world_cup_teams.json');
  const teamsData = JSON.parse(fs.readFileSync(teamsPath, 'utf8'));

  const batch = db.batch();
  let count = 0;

  for (const team of teamsData.teams) {
    const teamRef = db.collection('national_teams').doc(team.fifaCode);
    batch.set(teamRef, {
      ...team,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    count++;
  }

  await batch.commit();
  log(`✅ Successfully uploaded ${count} national teams`, 'green');

  return count;
}

/**
 * Upload Enhanced Teams with Historical Data to Firestore
 */
async function uploadEnhancedTeams() {
  log('\n📚 Uploading Enhanced National Teams with Historical Data...', 'blue');

  const enhancedTeamsPath = path.join(__dirname, '../data/seed/teams/world_cup_teams_enhanced.json');

  // Check if enhanced data exists
  if (!fs.existsSync(enhancedTeamsPath)) {
    log('⚠️  Enhanced team data not found, skipping...', 'yellow');
    return 0;
  }

  const enhancedData = JSON.parse(fs.readFileSync(enhancedTeamsPath, 'utf8'));

  const batch = db.batch();
  let count = 0;

  for (const team of enhancedData.teams) {
    const teamRef = db.collection('national_teams').doc(team.fifaCode);
    batch.set(teamRef, {
      ...team,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true }); // Merge with existing data
    count++;
    log(`   ${team.fifaCode}: Added ${team.worldCupHistory?.length || 0} World Cup records, ${team.legendaryPlayers?.length || 0} legendary players`, 'yellow');
  }

  await batch.commit();
  log(`✅ Successfully uploaded ${count} enhanced national teams with historical data`, 'green');

  return count;
}

/**
 * Upload Head-to-Head Matchup Data to Firestore
 */
async function uploadHeadToHeadMatchups() {
  log('\n🤝 Uploading Head-to-Head Matchup Data...', 'blue');

  const matchupsPath = path.join(__dirname, '../data/seed/matchups/head_to_head_matchups.json');

  // Check if matchup data exists
  if (!fs.existsSync(matchupsPath)) {
    log('⚠️  Head-to-head matchup data not found, skipping...', 'yellow');
    return 0;
  }

  const matchupsData = JSON.parse(fs.readFileSync(matchupsPath, 'utf8'));

  const batch = db.batch();
  let count = 0;

  for (const matchup of matchupsData.matchups) {
    const matchupRef = db.collection('head_to_head_matchups').doc(matchup.matchupId);
    batch.set(matchupRef, {
      ...matchup,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    count++;
    log(`   ${matchup.matchupId}: ${matchup.rivalryName} (${matchup.worldCupMeetings} World Cup meetings)`, 'yellow');
  }

  await batch.commit();
  log(`✅ Successfully uploaded ${count} head-to-head matchups`, 'green');

  return count;
}

/**
 * Upload Player Spotlight Data to Firestore
 * Uploads all 260 players from 10 national teams
 */
async function uploadPlayers() {
  log('\n⚽ Uploading Player Spotlight Database...', 'blue');

  const playersPath = path.join(__dirname, '../data/seed/players/world_cup_players_2026.json');

  // Check if player data exists
  if (!fs.existsSync(playersPath)) {
    log('⚠️  Player data not found, skipping...', 'yellow');
    return 0;
  }

  const playersData = JSON.parse(fs.readFileSync(playersPath, 'utf8'));

  // Firestore has a batch limit of 500 operations
  // We'll split the 260 players into multiple batches
  const BATCH_SIZE = 500;
  let totalCount = 0;
  let currentBatch = db.batch();
  let operationsInBatch = 0;

  // Track players by team
  const teamCounts = {};

  for (const player of playersData.players) {
    const playerRef = db.collection('players').doc(player.playerId);
    currentBatch.set(playerRef, {
      ...player,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Track team counts
    teamCounts[player.fifaCode] = (teamCounts[player.fifaCode] || 0) + 1;

    operationsInBatch++;
    totalCount++;

    // Commit batch if we hit the limit
    if (operationsInBatch >= BATCH_SIZE) {
      await currentBatch.commit();
      log(`   Committed batch of ${operationsInBatch} players...`, 'yellow');
      currentBatch = db.batch();
      operationsInBatch = 0;
    }
  }

  // Commit remaining operations
  if (operationsInBatch > 0) {
    await currentBatch.commit();
    log(`   Committed final batch of ${operationsInBatch} players`, 'yellow');
  }

  log(`✅ Successfully uploaded ${totalCount} players`, 'green');
  log(`\n   Players by team:`, 'blue');
  Object.entries(teamCounts).sort().forEach(([team, count]) => {
    log(`   ${team}: ${count} players`, 'yellow');
  });

  return totalCount;
}

/**
 * Upload Manager Database to Firestore
 * Uploads all 48 managers for qualified teams
 */
async function uploadManagers() {
  log('\n👔 Uploading Manager Database...', 'blue');

  const managersPath = path.join(__dirname, '../data/seed/managers/world_cup_managers_2026.json');

  // Check if manager data exists
  if (!fs.existsSync(managersPath)) {
    log('⚠️  Manager data not found, skipping...', 'yellow');
    return 0;
  }

  const managersData = JSON.parse(fs.readFileSync(managersPath, 'utf8'));

  const batch = db.batch();
  let count = 0;

  for (const manager of managersData.managers) {
    const managerRef = db.collection('managers').doc(manager.managerId);
    batch.set(managerRef, {
      ...manager,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    count++;
    log(`   ${manager.fifaCode}: ${manager.fullName} (${manager.age} years, ${manager.yearsOfExperience} years exp)`, 'yellow');
  }

  await batch.commit();
  log(`✅ Successfully uploaded ${count} managers`, 'green');

  return count;
}

/**
 * Upload Venues to Firestore
 */
async function uploadVenues() {
  log('\n🏟️  Uploading World Cup Venues...', 'blue');

  const venuesPath = path.join(__dirname, '../data/seed/venues/world_cup_venues.json');
  const venuesData = JSON.parse(fs.readFileSync(venuesPath, 'utf8'));

  const batch = db.batch();
  let count = 0;

  for (const venue of venuesData.venues) {
    const venueRef = db.collection('world_cup_venues').doc(venue.venueId);
    batch.set(venueRef, {
      ...venue,
      // Convert to Firestore GeoPoint
      location: new admin.firestore.GeoPoint(venue.latitude, venue.longitude),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    count++;
  }

  await batch.commit();
  log(`✅ Successfully uploaded ${count} venues`, 'green');

  return count;
}

/**
 * Create Group Stage Structure
 */
async function createGroupStructure() {
  log('\n📊 Creating Group Stage Structure...', 'blue');

  const groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
  const batch = db.batch();

  for (const groupLetter of groups) {
    const groupRef = db.collection('groups').doc(groupLetter);
    batch.set(groupRef, {
      groupLetter: groupLetter,
      teams: [], // Will be populated when teams are assigned
      standings: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }

  await batch.commit();
  log(`✅ Successfully created ${groups.length} group structures`, 'green');

  return groups.length;
}

/**
 * Assign Teams to Groups (based on seed data)
 */
async function assignTeamsToGroups() {
  log('\n🎯 Assigning Teams to Groups...', 'blue');

  const teamsPath = path.join(__dirname, '../data/seed/teams/world_cup_teams.json');
  const teamsData = JSON.parse(fs.readFileSync(teamsPath, 'utf8'));

  // Group teams by their assigned group
  const groupAssignments = {};

  for (const team of teamsData.teams) {
    if (team.group) {
      if (!groupAssignments[team.group]) {
        groupAssignments[team.group] = [];
      }
      groupAssignments[team.group].push({
        fifaCode: team.fifaCode,
        countryName: team.countryName,
        flagUrl: team.flagUrl
      });
    }
  }

  // Update groups with team assignments
  const batch = db.batch();
  let groupsUpdated = 0;

  for (const [groupLetter, teams] of Object.entries(groupAssignments)) {
    const groupRef = db.collection('groups').doc(groupLetter);
    batch.update(groupRef, {
      teams: teams,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    groupsUpdated++;
    log(`   Group ${groupLetter}: ${teams.map(t => t.fifaCode).join(', ')}`, 'yellow');
  }

  await batch.commit();
  log(`✅ Successfully assigned teams to ${groupsUpdated} groups`, 'green');

  return groupsUpdated;
}

/**
 * Create sample match data structure (placeholder for when official schedule is available)
 */
async function createSampleMatches() {
  log('\n⚽ Creating Sample Match Structure...', 'blue');

  // Create a few sample matches as examples
  const sampleMatches = [
    {
      matchId: 'wc2026_001',
      matchNumber: 1,
      stage: 'groupStage',
      group: 'A',
      homeTeamCode: 'MEX',
      homeTeamName: 'Mexico',
      awayTeamCode: 'TBD',
      awayTeamName: 'TBD',
      venueId: 'azteca',
      dateTime: new Date('2026-06-11T14:00:00-06:00'), // Opening match
      status: 'scheduled',
      significance: 'OPENING MATCH'
    },
    {
      matchId: 'wc2026_002',
      matchNumber: 2,
      stage: 'groupStage',
      group: 'B',
      homeTeamCode: 'CAN',
      homeTeamName: 'Canada',
      awayTeamCode: 'TBD',
      awayTeamName: 'TBD',
      venueId: 'bmo',
      dateTime: new Date('2026-06-12T14:00:00-04:00'), // Canada opening
      status: 'scheduled',
      significance: 'Canada Opening Match'
    },
    {
      matchId: 'wc2026_003',
      matchNumber: 3,
      stage: 'groupStage',
      group: 'C',
      homeTeamCode: 'USA',
      homeTeamName: 'United States',
      awayTeamCode: 'TBD',
      awayTeamName: 'TBD',
      venueId: 'sofi',
      dateTime: new Date('2026-06-12T17:00:00-07:00'), // USA opening
      status: 'scheduled',
      significance: 'USA Opening Match'
    },
    {
      matchId: 'wc2026_104',
      matchNumber: 104,
      stage: 'final_',
      homeTeamCode: null,
      homeTeamName: 'Winner Semi-Final 1',
      awayTeamCode: null,
      awayTeamName: 'Winner Semi-Final 2',
      venueId: 'metlife',
      dateTime: new Date('2026-07-19T15:00:00-04:00'), // FINAL
      status: 'scheduled',
      significance: 'WORLD CUP FINAL'
    }
  ];

  const batch = db.batch();

  for (const match of sampleMatches) {
    const matchRef = db.collection('world_cup_matches').doc(match.matchId);
    batch.set(matchRef, {
      ...match,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }

  await batch.commit();
  log(`✅ Successfully created ${sampleMatches.length} sample matches`, 'green');
  log('   Note: Full 104-match schedule will be populated once official FIFA data is available', 'yellow');

  return sampleMatches.length;
}

/**
 * Main execution function
 */
async function main() {
  log('\n' + '='.repeat(60), 'bright');
  log('     FIFA World Cup 2026 - Firestore Data Population', 'bright');
  log('='.repeat(60) + '\n', 'bright');

  try {
    const stats = {
      teams: 0,
      enhancedTeams: 0,
      matchups: 0,
      players: 0,
      managers: 0,
      venues: 0,
      groups: 0,
      matches: 0
    };

    // Upload basic teams (if not using enhanced data)
    // stats.teams = await uploadTeams();

    // Upload enhanced teams with historical data
    stats.enhancedTeams = await uploadEnhancedTeams();

    // Upload head-to-head matchup data
    stats.matchups = await uploadHeadToHeadMatchups();

    // Upload player spotlight database (260 players)
    stats.players = await uploadPlayers();

    // Upload manager database (48 managers)
    stats.managers = await uploadManagers();

    // Upload venues
    stats.venues = await uploadVenues();

    // Create group structure
    stats.groups = await createGroupStructure();

    // Assign teams to groups
    await assignTeamsToGroups();

    // Create sample matches
    stats.matches = await createSampleMatches();

    // Summary
    log('\n' + '='.repeat(60), 'bright');
    log('     Data Population Complete!', 'green');
    log('='.repeat(60), 'bright');
    log(`\n📊 Summary:`, 'blue');
    log(`   ✅ Enhanced National Teams: ${stats.enhancedTeams}`, 'green');
    log(`   ✅ Head-to-Head Matchups: ${stats.matchups}`, 'green');
    log(`   ✅ Player Spotlight: ${stats.players} players`, 'green');
    log(`   ✅ Managers: ${stats.managers} managers`, 'green');
    log(`   ✅ Venues: ${stats.venues}`, 'green');
    log(`   ✅ Groups: ${stats.groups}`, 'green');
    log(`   ✅ Sample Matches: ${stats.matches}`, 'green');

    log('\n🎉 All data successfully uploaded to Firestore!', 'green');
    log('\n💡 Next Steps:', 'yellow');
    log('   1. Verify data in Firebase Console', 'reset');
    log('   2. Test data loading in Flutter app', 'reset');
    log('   3. View player spotlights and manager profiles', 'reset');
    log('   4. View team history and head-to-head matchups in app', 'reset');
    log('   5. Populate full 104-match schedule when available', 'reset');
    log('   6. Update team assignments when qualification completes\n', 'reset');

    process.exit(0);
  } catch (error) {
    log('\n❌ Error during data population:', 'red');
    log(error.message, 'red');
    log(error.stack, 'red');
    process.exit(1);
  }
}

// Run the script
main();
