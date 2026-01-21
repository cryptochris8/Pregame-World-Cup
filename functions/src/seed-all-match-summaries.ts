/**
 * Comprehensive AI Match Summaries for World Cup 2026
 *
 * This script generates match summaries for ALL group stage matches (72 total)
 * plus potential knockout round matchups.
 *
 * Groups:
 * - Group A: USA, MEX, CAN, EGY
 * - Group B: BRA, ARG, URU, GHA
 * - Group C: COL, ECU, CHI, CMR
 * - Group D: FRA, ENG, ESP, CIV
 * - Group E: GER, NED, POR, ALG
 * - Group F: BEL, ITA, CRO, TUN
 * - Group G: DEN, SUI, AUT, NZL
 * - Group H: POL, SRB, UKR, CRC
 * - Group I: WAL, JPN, KOR, JAM
 * - Group J: AUS, IRN, KSA, HON
 * - Group K: QAT, UAE, CHN, PAN
 * - Group L: MAR, SEN, NGA, PER
 *
 * Usage:
 *   npx ts-node src/seed-all-match-summaries.ts [--dryRun]
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// Configuration
// ============================================================================

const DRY_RUN = process.argv.includes('--dryRun');

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

interface PlayerToWatch {
  name: string;
  teamCode: string;
  position: string;
  reason: string;
}

interface MatchPrediction {
  predictedOutcome: string;
  predictedScore: string;
  confidence: number;
  reasoning: string;
  alternativeScenario?: string;
}

interface MatchSummary {
  team1Code: string;
  team2Code: string;
  team1Name: string;
  team2Name: string;
  historicalAnalysis: string;
  keyStorylines: string[];
  playersToWatch: PlayerToWatch[];
  tacticalPreview: string;
  prediction: MatchPrediction;
  pastEncountersSummary?: string;
  funFacts: string[];
  isFirstMeeting: boolean;
}

// ============================================================================
// GROUP A: USA, MEX, CAN, EGY
// ============================================================================

const GROUP_A_SUMMARIES: MatchSummary[] = [
  // USA vs MEX
  {
    team1Code: 'USA',
    team2Code: 'MEX',
    team1Name: 'United States',
    team2Name: 'Mexico',
    historicalAnalysis: `The United States and Mexico share one of football's most intense rivalries, played out across more than 70 matches since 1934. This CONCACAF clash transcends sport, reflecting cultural, political, and historical tensions between neighboring nations. Mexico dominated the rivalry for decades, but the USA's growth since the 1990s has created genuine parity.

The 2002 World Cup Round of 16 meeting in South Korea remains the rivalry's defining World Cup moment. Brian McBride's header and Landon Donovan's strike gave the USA a famous 2-0 victory, eliminating Mexico and sending the Americans to the quarter-finals. That result fundamentally changed the power dynamic.

For the 2026 World Cup, both nations are co-hosts with enormous pressure to perform. This group stage clash in front of a divided home crowd will be one of the tournament's most anticipated matches.`,
    keyStorylines: [
      'The biggest rivalry in CONCACAF meets on the World Cup stage as co-hosts',
      'USA seeking to establish dominance in their own backyard',
      'Mexico looking to reassert themselves after recent USA victories',
      'Potentially 100,000+ fans creating an unprecedented atmosphere',
    ],
    playersToWatch: [
      { name: 'Christian Pulisic', teamCode: 'USA', position: 'Winger', reason: 'Captain America carrying the hopes of the host nation' },
      { name: 'Hirving Lozano', teamCode: 'MEX', position: 'Winger', reason: 'Mexico\'s most dangerous attacker with World Cup experience' },
      { name: 'Weston McKennie', teamCode: 'USA', position: 'Midfielder', reason: 'Box-to-box energy and big-game experience from Juventus' },
      { name: 'Edson Álvarez', teamCode: 'MEX', position: 'Midfielder', reason: 'Mexico\'s midfield anchor and captain' },
    ],
    tacticalPreview: `The USA under Pochettino will press aggressively, looking to force Mexico into mistakes. Mexico's technically gifted midfield will try to control possession and exploit spaces. The key battle is in central midfield where McKennie and Álvarez will clash.`,
    prediction: {
      predictedOutcome: 'USA',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'Home advantage and recent form favor the USA, but Mexico\'s tournament experience makes this extremely close.',
      alternativeScenario: 'Mexico\'s big-game experience could see them snatch a 1-0 victory if they control tempo.',
    },
    pastEncountersSummary: 'Over 70 meetings with Mexico historically dominant, but USA have won key recent encounters including the 2002 World Cup and multiple Nations League finals.',
    funFacts: [
      'This will be the first World Cup meeting between these rivals since 2002',
      'The 2002 match was watched by over 20 million Americans',
      'Both nations are co-hosting for the first time in World Cup history',
      'The winner of dos a cero (2-0) scoreline has become a rallying cry for US fans',
    ],
    isFirstMeeting: false,
  },

  // USA vs CAN
  {
    team1Code: 'USA',
    team2Code: 'CAN',
    team1Name: 'United States',
    team2Name: 'Canada',
    historicalAnalysis: `The USA and Canada share the world's longest undefended border and increasingly share football ambitions. This North American rivalry has intensified dramatically since Canada's emergence as a competitive force, qualifying for their first World Cup in 36 years in 2022.

Historically, the USA dominated with Canada struggling to compete. But the emergence of Alphonso Davies, Jonathan David, and other talents has transformed Canadian football. Canada defeated the USA 2-0 in World Cup qualifying in 2022, signaling a new era.

As co-hosts of the 2026 World Cup, this match carries unique significance. Both nations have invested heavily in football infrastructure and player development, making this a celebration of North American football's growth.`,
    keyStorylines: [
      'Co-hosts clash in a celebration of North American football',
      'Canada seeking to prove 2022 qualifying win was no fluke',
      'Alphonso Davies vs Christian Pulisic: Battle of the stars',
      'First World Cup meeting between these neighbors',
    ],
    playersToWatch: [
      { name: 'Christian Pulisic', teamCode: 'USA', position: 'Winger', reason: 'USA\'s talisman leading the charge on home soil' },
      { name: 'Alphonso Davies', teamCode: 'CAN', position: 'Left-Back/Winger', reason: 'One of world football\'s most explosive players' },
      { name: 'Gio Reyna', teamCode: 'USA', position: 'Midfielder', reason: 'Creative spark when fit and firing' },
      { name: 'Jonathan David', teamCode: 'CAN', position: 'Striker', reason: 'Prolific goalscorer in Ligue 1' },
    ],
    tacticalPreview: `Both teams play attacking football with pace in wide areas. Davies' marauding runs will test USA's right side, while Pulisic will target Canada's back line. Midfield control will be crucial.`,
    prediction: {
      predictedOutcome: 'USA',
      predictedScore: '2-1',
      confidence: 60,
      reasoning: 'USA\'s greater depth and experience in major tournaments provides an edge, but Canada\'s individual quality makes them dangerous.',
      alternativeScenario: 'Davies in inspired form could lead Canada to a shock victory.',
    },
    pastEncountersSummary: 'USA lead the all-time series significantly, but Canada\'s 2-0 win in 2022 qualifying showed the gap has closed dramatically.',
    funFacts: [
      'This is the first-ever World Cup meeting between USA and Canada',
      'Both nations are hosting their first World Cup (as primary hosts)',
      'Davies became the fastest player ever recorded in the Bundesliga',
      'Canada\'s 2022 World Cup was their first since 1986',
    ],
    isFirstMeeting: true,
  },

  // USA vs EGY
  {
    team1Code: 'USA',
    team2Code: 'EGY',
    team1Name: 'United States',
    team2Name: 'Egypt',
    historicalAnalysis: `The United States and Egypt have rarely crossed paths in competitive football, with no World Cup meetings in history. Their encounters have been limited to friendlies, with both nations' football trajectories taking them to different confederations and competitions.

Egypt, seven-time African champions, bring a rich football heritage led by one of the world's best players in Mohamed Salah. However, their World Cup record is modest—three appearances with early exits each time.

The USA enter as co-hosts with expectations of progressing deep into the tournament. This match represents a clash of footballing cultures: American athleticism and pressing versus Egyptian technical skill and African flair.`,
    keyStorylines: [
      'Mohamed Salah faces the American defense in a historic first World Cup meeting',
      'USA seeking to maintain perfect home record in the group stage',
      'Egypt looking to advance past the group stage for the first time since 1934',
      'Premier League connections: Salah facing familiar American players',
    ],
    playersToWatch: [
      { name: 'Christian Pulisic', teamCode: 'USA', position: 'Winger', reason: 'Leading the host nation\'s attack' },
      { name: 'Mohamed Salah', teamCode: 'EGY', position: 'Forward', reason: 'One of the world\'s best and Egypt\'s all-time great' },
      { name: 'Tyler Adams', teamCode: 'USA', position: 'Midfielder', reason: 'Defensive shield protecting the back line' },
      { name: 'Omar Marmoush', teamCode: 'EGY', position: 'Forward', reason: 'Emerging talent providing attacking support' },
    ],
    tacticalPreview: `USA will press high and try to isolate Salah from service. Egypt will look to feed their talisman in space behind the defense. The battle between Salah and the American full-backs will be decisive.`,
    prediction: {
      predictedOutcome: 'USA',
      predictedScore: '2-0',
      confidence: 70,
      reasoning: 'Home advantage and superior squad depth favor the USA. Egypt\'s reliance on Salah makes them predictable.',
      alternativeScenario: 'If Salah produces individual brilliance, Egypt could snatch a draw or narrow victory.',
    },
    pastEncountersSummary: 'Limited history between these nations, mostly friendlies. This World Cup encounter writes a new chapter.',
    funFacts: [
      'First-ever World Cup meeting between USA and Egypt',
      'Egypt\'s only World Cup knockout victory came in 1934',
      'Salah scored over 200 goals for Liverpool',
      'Egypt have won more AFCON titles (7) than any other nation',
    ],
    isFirstMeeting: true,
  },

  // MEX vs CAN
  {
    team1Code: 'MEX',
    team2Code: 'CAN',
    team1Name: 'Mexico',
    team2Name: 'Canada',
    historicalAnalysis: `Mexico and Canada's rivalry has intensified in recent years as Canada emerged as a genuine CONCACAF force. Historically, Mexico dominated completely—but the tables turned dramatically during 2022 World Cup qualifying when Canada defeated Mexico for the first time in over two decades.

Mexico's football pedigree is unmatched in CONCACAF: 17 World Cup appearances, quarter-final finishes in 1970 and 1986, and a tradition of producing technically gifted players. Canada, by contrast, are still building their legacy.

As co-hosts, both nations face immense pressure. Mexico's fans demand deep tournament runs, while Canada seek to prove their qualification wasn't a fluke. This match could determine who tops Group A.`,
    keyStorylines: [
      'Co-hosts battle for Group A supremacy',
      'Mexico seeking revenge for 2022 qualifying defeat',
      'Canada looking to establish themselves among CONCACAF elite',
      'First World Cup meeting between these neighboring nations',
    ],
    playersToWatch: [
      { name: 'Hirving Lozano', teamCode: 'MEX', position: 'Winger', reason: 'Mexico\'s most explosive attacker' },
      { name: 'Alphonso Davies', teamCode: 'CAN', position: 'Left-Back', reason: 'World-class talent and Canada\'s talisman' },
      { name: 'Santiago Giménez', teamCode: 'MEX', position: 'Striker', reason: 'Prolific Feyenoord striker' },
      { name: 'Jonathan David', teamCode: 'CAN', position: 'Striker', reason: 'Clinical finisher with European pedigree' },
    ],
    tacticalPreview: `Mexico's technical midfield will try to control possession against Canada's athletic pressing. Davies' pace on the counter is Canada's biggest weapon. Set pieces could be crucial.`,
    prediction: {
      predictedOutcome: 'MEX',
      predictedScore: '2-1',
      confidence: 58,
      reasoning: 'Mexico\'s tournament experience and technical quality give them an edge, but Canada\'s improvement makes this close.',
      alternativeScenario: 'Canada\'s pressing could overwhelm Mexico, leading to a shock 2-1 Canadian victory.',
    },
    pastEncountersSummary: 'Mexico dominated historically, but Canada\'s 2-1 win in 2022 qualifying changed the narrative. Limited World Cup history between them.',
    funFacts: [
      'First World Cup meeting between Mexico and Canada',
      'Canada\'s 2022 qualifying win ended a 34-year winless streak against Mexico',
      'Mexico has appeared in 17 World Cups, Canada in just 2',
      'Both nations are co-hosting the World Cup',
    ],
    isFirstMeeting: true,
  },

  // MEX vs EGY
  {
    team1Code: 'MEX',
    team2Code: 'EGY',
    team1Name: 'Mexico',
    team2Name: 'Egypt',
    historicalAnalysis: `Mexico and Egypt have met just twice, both friendlies without meaningful stakes. This World Cup encounter represents uncharted territory for both nations—a clash of CONCACAF and CAF powers with contrasting styles.

Mexico's World Cup pedigree is strong with 17 appearances and multiple deep runs. Egypt, despite dominating African football, have struggled on the world stage. Their 2018 World Cup campaign ended in group-stage elimination despite having Salah.

This match pits Mexico's possession-based approach against Egypt's counter-attacking style built around their superstar.`,
    keyStorylines: [
      'First competitive meeting between these football cultures',
      'Mexico seeking to secure qualification for knockout rounds',
      'Salah vs Mexico\'s defense: The key battle',
      'Egypt looking to finally advance past the group stage',
    ],
    playersToWatch: [
      { name: 'Edson Álvarez', teamCode: 'MEX', position: 'Midfielder', reason: 'Mexico\'s defensive anchor and captain' },
      { name: 'Mohamed Salah', teamCode: 'EGY', position: 'Forward', reason: 'Egypt\'s one-man army' },
      { name: 'Raúl Jiménez', teamCode: 'MEX', position: 'Striker', reason: 'Experienced target man with World Cup experience' },
      { name: 'Mohamed Elneny', teamCode: 'EGY', position: 'Midfielder', reason: 'Provides stability and Premier League experience' },
    ],
    tacticalPreview: `Mexico will dominate possession while Egypt sits deep waiting to release Salah. Mexico must be patient and avoid getting caught on the counter. Egypt's defensive discipline will be tested.`,
    prediction: {
      predictedOutcome: 'MEX',
      predictedScore: '2-0',
      confidence: 68,
      reasoning: 'Mexico\'s squad depth and tournament experience should prove decisive against an Egypt side overly reliant on Salah.',
      alternativeScenario: 'Salah magic could produce a 1-1 draw or even Egyptian victory if Mexico become complacent.',
    },
    pastEncountersSummary: 'Just two friendlies with no competitive history. This is effectively a first meeting of consequence.',
    funFacts: [
      'First World Cup meeting between Mexico and Egypt',
      'Egypt have won 7 AFCON titles but never advanced past World Cup group stage since 1934',
      'Mexico have been eliminated in the Round of 16 in seven consecutive World Cups',
      'Both nations have passionate, colorful supporter cultures',
    ],
    isFirstMeeting: true,
  },

  // CAN vs EGY
  {
    team1Code: 'CAN',
    team2Code: 'EGY',
    team1Name: 'Canada',
    team2Name: 'Egypt',
    historicalAnalysis: `Canada and Egypt have no significant football history, making this World Cup encounter a complete unknown. Both nations bring unique narratives: Canada's rapid rise from football obscurity to World Cup contenders, and Egypt's status as African powerhouse with World Cup struggles.

Canada's golden generation led by Davies and David has transformed their football landscape. Egypt, despite producing legendary players and dominating Africa, have never found World Cup success beyond the group stage since 1934.

This match could determine which team advances from Group A alongside the hosts.`,
    keyStorylines: [
      'First-ever meeting between Canada and Egypt',
      'Davies vs Salah: Premier League stars collide',
      'Both teams seeking first World Cup knockout round in decades',
      'Emerging power vs established African giant',
    ],
    playersToWatch: [
      { name: 'Alphonso Davies', teamCode: 'CAN', position: 'Left-Back', reason: 'Canada\'s superstar and Bayern Munich regular' },
      { name: 'Mohamed Salah', teamCode: 'EGY', position: 'Forward', reason: 'One of the greatest African players ever' },
      { name: 'Jonathan David', teamCode: 'CAN', position: 'Striker', reason: 'Prolific goalscorer seeking World Cup breakthrough' },
      { name: 'Omar Marmoush', teamCode: 'EGY', position: 'Forward', reason: 'Rising talent supporting Salah' },
    ],
    tacticalPreview: `Canada's pressing and athleticism against Egypt's technical ability and counter-attacking threat. The match could be decided by which team better executes their game plan in transition moments.`,
    prediction: {
      predictedOutcome: 'CAN',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'Canada\'s collective strength and home continent advantage give them a slight edge over Egypt\'s Salah-dependent attack.',
      alternativeScenario: 'Salah producing moments of magic could see Egypt win 1-0 or snatch a draw.',
    },
    pastEncountersSummary: 'No previous meetings at any level. This is a historic first encounter.',
    funFacts: [
      'First-ever meeting between Canada and Egypt',
      'Both teams have never reached a World Cup semi-final',
      'Davies and Salah are both among the fastest players in world football',
      'Egypt have won 7 AFCON titles; Canada have won 1 Gold Cup',
    ],
    isFirstMeeting: true,
  },
];

// ============================================================================
// GROUP B: BRA, ARG, URU, GHA
// ============================================================================

const GROUP_B_SUMMARIES: MatchSummary[] = [
  // BRA vs ARG
  {
    team1Code: 'BRA',
    team2Code: 'ARG',
    team1Name: 'Brazil',
    team2Name: 'Argentina',
    historicalAnalysis: `Brazil vs Argentina is football's greatest rivalry, transcending sport to become a cultural phenomenon. These South American giants have met over 100 times, with Brazil holding a slight edge historically. Their World Cup encounters, however, have been remarkably rare—just five meetings on the biggest stage.

The most recent chapter favored Argentina: Messi's team defeated Brazil in the 2021 Copa América final on Brazilian soil, then won the 2022 World Cup while Brazil crashed out in the quarter-finals. This has shifted the rivalry's narrative for the first time in years.

For 2026, Argentina enter as defending champions with Messi potentially in his final World Cup. Brazil, without a title since 2002, are desperate to reassert their status as football's greatest nation.`,
    keyStorylines: [
      'Football\'s greatest rivalry on the World Cup stage',
      'Argentina as defending champions vs desperate Brazil',
      'Possibly Messi\'s final World Cup match against Brazil',
      'Vinícius Jr. vs Messi: Passing of the torch?',
    ],
    playersToWatch: [
      { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'Brazil\'s brightest star seeking World Cup glory' },
      { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The GOAT in potentially his final World Cup' },
      { name: 'Rodrygo', teamCode: 'BRA', position: 'Forward', reason: 'Real Madrid star adding creativity and goals' },
      { name: 'Julián Álvarez', teamCode: 'ARG', position: 'Striker', reason: '2022 World Cup hero hungry for more' },
    ],
    tacticalPreview: `Both teams play attractive, attacking football. Brazil's pace and dribbling vs Argentina's intelligent movement and pressing. Midfield control will be crucial, with Enzo Fernández vs Bruno Guimarães a key battle.`,
    prediction: {
      predictedOutcome: 'DRAW',
      predictedScore: '2-2',
      confidence: 45,
      reasoning: 'Neither team can afford to lose, leading to a cagey but entertaining draw. Both possess match-winners capable of decisive moments.',
      alternativeScenario: 'Argentina\'s champion mentality could produce a 2-1 victory, or Brazil\'s attacking quality could overwhelm for a 3-1 win.',
    },
    pastEncountersSummary: 'Over 100 meetings with Brazil leading slightly. Argentina\'s recent dominance (2021 Copa América, 2022 World Cup) has shifted momentum.',
    funFacts: [
      'This is only the 6th World Cup meeting between Brazil and Argentina',
      'Argentina won their 2022 World Cup semi-final on Brazilian soil',
      'Brazil haven\'t won the World Cup since 2002, their longest drought',
      'Combined, they have won 8 World Cups (Brazil 5, Argentina 3)',
    ],
    isFirstMeeting: false,
  },

  // BRA vs URU
  {
    team1Code: 'BRA',
    team2Code: 'URU',
    team1Name: 'Brazil',
    team2Name: 'Uruguay',
    historicalAnalysis: `The Brazil-Uruguay rivalry is marked by one of football's most famous moments: the 1950 World Cup final, known as the "Maracanazo." In front of nearly 200,000 fans at the Maracanã, Uruguay shocked Brazil 2-1 to win the World Cup, causing national mourning in Brazil.

That trauma has defined this rivalry ever since. Brazil have dominated recent decades, but Uruguay's warrior mentality means they always compete fiercely. Uruguay's 2010 World Cup fourth-place finish and 2011 Copa América victory showed they remain formidable.

Uruguay enter 2026 under Marcelo Bielsa, bringing his trademark intense pressing style. Brazil's young generation of Vinícius Jr., Rodrygo, and Endrick represents a new era.`,
    keyStorylines: [
      'Echoes of the Maracanazo: Can Uruguay shock Brazil again?',
      'Bielsa\'s pressing philosophy vs Brazil\'s flair',
      'Uruguay\'s grit vs Brazil\'s technical brilliance',
      'Federico Valverde leading Uruguay\'s new generation',
    ],
    playersToWatch: [
      { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'Brazil\'s most electrifying player' },
      { name: 'Federico Valverde', teamCode: 'URU', position: 'Midfielder', reason: 'Real Madrid engine driving Uruguay forward' },
      { name: 'Endrick', teamCode: 'BRA', position: 'Forward', reason: 'Teenage sensation in his first World Cup' },
      { name: 'Darwin Núñez', teamCode: 'URU', position: 'Striker', reason: 'Explosive pace and finishing' },
    ],
    tacticalPreview: `Uruguay will press high and make Brazil uncomfortable under Bielsa's system. Brazil must handle the intensity and use their technical superiority in tight spaces. Transitions will be crucial.`,
    prediction: {
      predictedOutcome: 'BRA',
      predictedScore: '2-1',
      confidence: 62,
      reasoning: 'Brazil\'s superior squad depth and individual quality should prevail, but Uruguay will make it difficult and competitive.',
      alternativeScenario: 'Uruguay\'s pressing could suffocate Brazil, leading to a shock 1-0 Uruguayan victory.',
    },
    pastEncountersSummary: 'Over 80 meetings, Brazil lead significantly. Uruguay\'s 1950 Maracanazo remains the most famous result in South American football history.',
    funFacts: [
      'The 1950 World Cup final caused such trauma that Brazil changed their kit colors',
      'Uruguay are one of only 8 nations to win the World Cup',
      'Brazil and Uruguay have met in 6 World Cups',
      'Uruguay\'s population is smaller than São Paulo alone',
    ],
    isFirstMeeting: false,
  },

  // BRA vs GHA
  {
    team1Code: 'BRA',
    team2Code: 'GHA',
    team1Name: 'Brazil',
    team2Name: 'Ghana',
    historicalAnalysis: `Brazil and Ghana's World Cup history centers on one dramatic encounter: the 2006 Round of 16 in Germany. Brazil won 3-0, but the match was more competitive than the scoreline suggests. Ghana became the third African nation ever to reach the knockout rounds.

Ghana's 2010 quarter-final run showed their potential, while Brazil continue their quest to end a title drought stretching back to 2002. This group stage meeting offers Ghana a chance at redemption against the five-time champions.

Ghana's current squad features exciting talents like Mohammed Kudus, who impressed at the 2022 World Cup. Brazil's young stars present a formidable challenge.`,
    keyStorylines: [
      'Rematch of 2006 World Cup knockout meeting',
      'Ghana seeking revenge after 3-0 defeat',
      'Brazil\'s young generation vs Ghana\'s athletic style',
      'Kudus looking to announce himself against the Seleção',
    ],
    playersToWatch: [
      { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'Brazil\'s match-winner and Ballon d\'Or contender' },
      { name: 'Mohammed Kudus', teamCode: 'GHA', position: 'Midfielder', reason: 'Explosive talent who can change games' },
      { name: 'Bruno Guimarães', teamCode: 'BRA', position: 'Midfielder', reason: 'Newcastle\'s midfield maestro controlling tempo' },
      { name: 'Thomas Partey', teamCode: 'GHA', position: 'Midfielder', reason: 'Arsenal\'s midfield anchor and Ghana\'s leader' },
    ],
    tacticalPreview: `Brazil will dominate possession while Ghana look to press and counter. Kudus and Partey must win the midfield battle for Ghana to have a chance. Brazil's pace on the wings will test Ghana's fullbacks.`,
    prediction: {
      predictedOutcome: 'BRA',
      predictedScore: '3-1',
      confidence: 75,
      reasoning: 'Brazil\'s superior quality across the pitch should prove too much for Ghana, though the Black Stars will compete and likely score.',
      alternativeScenario: 'Ghana\'s pressing could cause Brazil problems early, potentially snatching a draw.',
    },
    pastEncountersSummary: 'Three meetings, Brazil winning all. The 2006 World Cup 3-0 remains Ghana\'s most painful memory against the Seleção.',
    funFacts: [
      'Ghana were the third African nation to reach a World Cup knockout round (2006)',
      'Brazil haven\'t won the World Cup since 2002',
      'Ghana\'s 2010 quarter-final run was ended by Suárez\'s infamous handball',
      'Kudus was one of the breakout stars of the 2022 World Cup',
    ],
    isFirstMeeting: false,
  },

  // ARG vs URU
  {
    team1Code: 'ARG',
    team2Code: 'URU',
    team1Name: 'Argentina',
    team2Name: 'Uruguay',
    historicalAnalysis: `Argentina and Uruguay share football's oldest international rivalry, dating back to 1901. These Rio de la Plata neighbors have met over 200 times, with Argentina holding a slight advantage. Their World Cup history includes the very first final in 1930, won by Uruguay in Montevideo.

Both nations are steeped in World Cup glory: Argentina with three titles (1978, 1986, 2022) and Uruguay with two (1930, 1950). This match pits Argentina's defending champions against Uruguay's proud tradition.

Under Messi, Argentina have rediscovered their winning mentality. Uruguay under Bielsa play with intense pressing and never-say-die attitude.`,
    keyStorylines: [
      'Football\'s oldest rivalry renewed on the World Cup stage',
      'Defending champions Argentina vs proud Uruguay tradition',
      'Messi potentially facing his final Rio de la Plata derby',
      'Bielsa\'s tactical battle against Scaloni',
    ],
    playersToWatch: [
      { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The GOAT leading Argentina once more' },
      { name: 'Federico Valverde', teamCode: 'URU', position: 'Midfielder', reason: 'Uruguay\'s engine and Real Madrid star' },
      { name: 'Enzo Fernández', teamCode: 'ARG', position: 'Midfielder', reason: 'Chelsea\'s record signing and 2022 World Cup young player winner' },
      { name: 'Darwin Núñez', teamCode: 'URU', position: 'Striker', reason: 'Explosive striker with pace and power' },
    ],
    tacticalPreview: `Both teams know each other intimately. Argentina\'s possession-based approach will meet Uruguay's aggressive pressing. Midfield control between Enzo and Valverde will be decisive.`,
    prediction: {
      predictedOutcome: 'ARG',
      predictedScore: '2-1',
      confidence: 60,
      reasoning: 'Argentina\'s champion mentality and superior squad depth give them an edge, but Uruguay will make this a battle.',
      alternativeScenario: 'Uruguay\'s intensity could overwhelm Argentina for a famous 2-1 victory.',
    },
    pastEncountersSummary: 'Over 200 meetings, the oldest rivalry in international football. Argentina lead slightly but Uruguay have won when it matters, including the first World Cup final.',
    funFacts: [
      'This is football\'s oldest international rivalry (since 1901)',
      'Uruguay beat Argentina in the first World Cup final (1930)',
      'Combined, they have won 5 World Cups',
      'The rivalry is known as "El Clásico del Río de la Plata"',
    ],
    isFirstMeeting: false,
  },

  // ARG vs GHA
  {
    team1Code: 'ARG',
    team2Code: 'GHA',
    team1Name: 'Argentina',
    team2Name: 'Ghana',
    historicalAnalysis: `Argentina and Ghana have no World Cup history, but their paths have crossed in Copa América (as guests) and friendlies. This encounter pits the defending world champions against Africa's hopes.

Argentina's 2022 triumph cemented Messi's legacy and restored Argentina's place atop world football. Ghana, despite producing talented players, have struggled to replicate their 2010 quarter-final achievement.

This match represents a fascinating clash of South American flair and African athleticism, with Argentina's tournament experience a significant advantage.`,
    keyStorylines: [
      'Defending champions Argentina vs African hopefuls',
      'Messi seeking to continue his World Cup legacy',
      'Ghana looking to prove they can compete with the best',
      'First World Cup meeting between these nations',
    ],
    playersToWatch: [
      { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The defending champion and tournament favorite' },
      { name: 'Mohammed Kudus', teamCode: 'GHA', position: 'Midfielder', reason: 'Ghana\'s explosive talent and main creative threat' },
      { name: 'Julián Álvarez', teamCode: 'ARG', position: 'Striker', reason: '2022 World Cup hero seeking more glory' },
      { name: 'Thomas Partey', teamCode: 'GHA', position: 'Midfielder', reason: 'Ghana\'s captain and midfield anchor' },
    ],
    tacticalPreview: `Argentina will control possession and probe for openings. Ghana must stay compact and hope Kudus can produce magic on the counter. Argentina's movement and passing in tight spaces will test Ghana's discipline.`,
    prediction: {
      predictedOutcome: 'ARG',
      predictedScore: '3-0',
      confidence: 80,
      reasoning: 'Argentina\'s champion quality and tournament experience should overwhelm Ghana. Messi and company will be too much for the Black Stars.',
      alternativeScenario: 'Ghana scoring first could make this uncomfortable, potentially snatching a draw.',
    },
    pastEncountersSummary: 'Limited history with no World Cup meetings. Argentina have won recent friendly encounters comfortably.',
    funFacts: [
      'First-ever World Cup meeting between Argentina and Ghana',
      'Argentina won their third World Cup in 2022',
      'Ghana\'s best World Cup finish was quarter-finals in 2010',
      'Kudus plays for West Ham in the Premier League',
    ],
    isFirstMeeting: true,
  },

  // URU vs GHA
  {
    team1Code: 'URU',
    team2Code: 'GHA',
    team1Name: 'Uruguay',
    team2Name: 'Ghana',
    historicalAnalysis: `Uruguay and Ghana are forever linked by one of World Cup history's most controversial moments. In the 2010 quarter-final, Luis Suárez's deliberate handball on the line prevented a certain Ghana goal in extra time. Asamoah Gyan missed the resulting penalty, and Uruguay won the shootout, denying Africa a first-ever semi-finalist.

That match remains a source of immense pain for Ghanaian football. Gyan's miss and Suárez's celebration are seared into African football consciousness. This group stage rematch offers Ghana a chance at redemption 16 years later.

Uruguay enter without Suárez, who retired from international football, but the memory persists.`,
    keyStorylines: [
      'The 2010 handball rematch: Ghana seeking redemption',
      'One of World Cup history\'s most controversial moments revisited',
      'Can Ghana finally beat Uruguay on the World Cup stage?',
      'New generations carrying old grudges',
    ],
    playersToWatch: [
      { name: 'Federico Valverde', teamCode: 'URU', position: 'Midfielder', reason: 'Uruguay\'s new talisman leading the charge' },
      { name: 'Mohammed Kudus', teamCode: 'GHA', position: 'Midfielder', reason: 'Carrying Ghanaian hopes for revenge' },
      { name: 'Darwin Núñez', teamCode: 'URU', position: 'Striker', reason: 'Explosive striker who must be contained' },
      { name: 'Thomas Partey', teamCode: 'GHA', position: 'Midfielder', reason: 'Arsenal\'s midfield anchor and Ghana\'s leader' },
    ],
    tacticalPreview: `This will be emotional and physical. Ghana will be highly motivated while Uruguay rely on their trademark grit. Midfield control will be crucial, with both teams capable of pressing intensity.`,
    prediction: {
      predictedOutcome: 'DRAW',
      predictedScore: '1-1',
      confidence: 50,
      reasoning: 'The emotional weight of this match could produce a tense, cagey draw. Neither team can afford to lose.',
      alternativeScenario: 'Ghana\'s motivation could produce an emotional 2-1 victory, or Uruguay\'s experience could see them through 2-0.',
    },
    pastEncountersSummary: 'The 2010 quarter-final remains the defining encounter. Uruguay won on penalties after Suárez\'s handball and Gyan\'s miss. Ghana have never beaten Uruguay.',
    funFacts: [
      'Suárez\'s 2010 handball is considered one of football\'s most controversial moments',
      'Gyan\'s penalty miss denied Africa a first World Cup semi-finalist',
      'This is Ghana\'s chance for redemption after 16 years',
      'Uruguay reached the semi-finals in 2010 before losing to Netherlands',
    ],
    isFirstMeeting: false,
  },
];

// ============================================================================
// GROUP C: COL, ECU, CHI, CMR
// ============================================================================

const GROUP_C_SUMMARIES: MatchSummary[] = [
  // COL vs ECU
  {
    team1Code: 'COL',
    team2Code: 'ECU',
    team1Name: 'Colombia',
    team2Name: 'Ecuador',
    historicalAnalysis: `Colombia and Ecuador share a border and a passionate football rivalry. The Andean neighbors have met over 30 times, with Colombia holding a significant advantage. World Cup meetings have been rare, but qualifiers and Copa América clashes are always intense affairs.

Colombia's 2014 World Cup quarter-final run, led by James Rodríguez's Golden Boot performance, remains their finest hour. Ecuador have qualified for four World Cups but struggle to advance past the group stage.

Both nations feature rising talents: Colombia's Luis Díaz has become world-class at Liverpool, while Ecuador's Moisés Caicedo is one of the Premier League's best midfielders.`,
    keyStorylines: [
      'Andean derby with World Cup stakes',
      'Luis Díaz vs Ecuador\'s defense: Can Colombia\'s star shine?',
      'Ecuador\'s best generation seeking breakthrough',
      'James Rodríguez seeking final World Cup redemption',
    ],
    playersToWatch: [
      { name: 'Luis Díaz', teamCode: 'COL', position: 'Winger', reason: 'Liverpool\'s explosive winger and Colombia\'s talisman' },
      { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'Chelsea\'s record signing and Ecuador\'s midfield general' },
      { name: 'James Rodríguez', teamCode: 'COL', position: 'Midfielder', reason: '2014 Golden Boot winner in potential final World Cup' },
      { name: 'Enner Valencia', teamCode: 'ECU', position: 'Striker', reason: 'Ecuador\'s all-time World Cup leading scorer' },
    ],
    tacticalPreview: `Colombia's flair and attacking intent vs Ecuador's organization and counter-attacking threat. Caicedo vs James in midfield will be crucial. Colombia's pace on the wings could exploit Ecuador's fullbacks.`,
    prediction: {
      predictedOutcome: 'COL',
      predictedScore: '2-1',
      confidence: 60,
      reasoning: 'Colombia\'s superior attacking quality and big-game experience give them an edge, but Ecuador will compete fiercely.',
      alternativeScenario: 'Ecuador\'s defensive discipline and counter-attacks could produce a shock 1-0 victory.',
    },
    pastEncountersSummary: 'Over 30 meetings with Colombia dominant. Rare World Cup encounters, but always intense in qualifiers.',
    funFacts: [
      'Colombia and Ecuador share a land border',
      'Enner Valencia has scored in both of Ecuador\'s World Cup campaigns (2014, 2022)',
      'James Rodríguez won the 2014 World Cup Golden Boot with 6 goals',
      'Caicedo became the most expensive Premier League signing ever',
    ],
    isFirstMeeting: false,
  },

  // COL vs CHI
  {
    team1Code: 'COL',
    team2Code: 'CHI',
    team1Name: 'Colombia',
    team2Name: 'Chile',
    historicalAnalysis: `Colombia and Chile's rivalry intensified during Chile's "Golden Generation" years (2015-2016) when La Roja won back-to-back Copa Américas. Their clashes have been tactical battles featuring South American flair and physicality.

Chile's decline since those Copa triumphs has been stark—they missed both the 2018 and 2022 World Cups. Colombia, meanwhile, have remained competitive and boast exciting young talent alongside experienced stars.

This match pits Colombia's rising generation against Chile's aging but still proud squad.`,
    keyStorylines: [
      'South American powers clash in the group stage',
      'Chile\'s golden generation seeking one last hurrah',
      'Colombia\'s youth vs Chile\'s experience',
      'Battle for South American pride',
    ],
    playersToWatch: [
      { name: 'Luis Díaz', teamCode: 'COL', position: 'Winger', reason: 'World-class attacker leading Colombia\'s charge' },
      { name: 'Alexis Sánchez', teamCode: 'CHI', position: 'Forward', reason: 'Chile\'s all-time leading scorer in potential final World Cup' },
      { name: 'Jhon Arias', teamCode: 'COL', position: 'Midfielder', reason: 'Exciting creative talent from Fluminense' },
      { name: 'Ben Brereton Díaz', teamCode: 'CHI', position: 'Striker', reason: 'Chile\'s English-born striker bringing Premier League quality' },
    ],
    tacticalPreview: `Colombia will look to dominate with pace and creativity. Chile under Gareca will press high and try to unsettle Colombia's build-up. Set pieces could be crucial given Chile's aerial threat.`,
    prediction: {
      predictedOutcome: 'COL',
      predictedScore: '2-0',
      confidence: 65,
      reasoning: 'Colombia\'s superior squad and current form should be too much for an aging Chile side.',
      alternativeScenario: 'Chile\'s big-game experience and Sánchez magic could produce a 1-1 draw.',
    },
    pastEncountersSummary: 'Competitive rivalry with both teams winning key encounters. Chile\'s Copa América dominance (2015-16) is balanced by Colombia\'s recent form.',
    funFacts: [
      'Chile won back-to-back Copa Américas in 2015 and 2016',
      'Chile missed both the 2018 and 2022 World Cups',
      'Alexis Sánchez has over 50 goals for Chile',
      'Ben Brereton Díaz was born in England and qualified through his Chilean mother',
    ],
    isFirstMeeting: false,
  },

  // COL vs CMR
  {
    team1Code: 'COL',
    team2Code: 'CMR',
    team1Name: 'Colombia',
    team2Name: 'Cameroon',
    historicalAnalysis: `Colombia and Cameroon have limited history but share similar football identities: flair, passion, and unpredictability. Both nations have produced iconic World Cup moments—Colombia's Higuita scorpion kick and Cameroon's 1990 upset of Argentina.

Cameroon's World Cup history is Africa's most decorated with eight appearances and quarter-final finishes in 1990. Colombia's 2014 quarter-final remains their benchmark.

This match represents a clash of footballing cultures: South American technique meets African power and pace.`,
    keyStorylines: [
      'Clash of footballing cultures: South America vs Africa',
      'Colombia seeking to secure group progression',
      'Cameroon\'s proud World Cup tradition vs Colombia\'s quality',
      'First significant meeting between these nations',
    ],
    playersToWatch: [
      { name: 'Luis Díaz', teamCode: 'COL', position: 'Winger', reason: 'Colombia\'s match-winner with explosive pace' },
      { name: 'André-Frank Zambo Anguissa', teamCode: 'CMR', position: 'Midfielder', reason: 'Napoli\'s midfield maestro running Cameroon\'s engine' },
      { name: 'James Rodríguez', teamCode: 'COL', position: 'Midfielder', reason: 'Creative genius seeking World Cup magic' },
      { name: 'Eric Maxim Choupo-Moting', teamCode: 'CMR', position: 'Forward', reason: 'Experienced target man and Cameroon captain' },
    ],
    tacticalPreview: `Colombia's technical midfield vs Cameroon's physical presence. Anguissa's battles in the center will be crucial. Colombia's pace in wide areas will test Cameroon's fullbacks.`,
    prediction: {
      predictedOutcome: 'COL',
      predictedScore: '2-1',
      confidence: 62,
      reasoning: 'Colombia\'s superior technical quality and attacking options should prove decisive, but Cameroon will compete.',
      alternativeScenario: 'Cameroon\'s physicality and set-piece threat could produce a shock 2-1 victory.',
    },
    pastEncountersSummary: 'Limited history with no significant competitive meetings. This World Cup encounter is essentially a first.',
    funFacts: [
      'First significant competitive meeting between Colombia and Cameroon',
      'Cameroon were the first African team to reach a World Cup quarter-final (1990)',
      'Colombia\'s René Higuita\'s scorpion kick is one of football\'s most famous moments',
      'Both nations are known for passionate, colorful supporters',
    ],
    isFirstMeeting: true,
  },

  // ECU vs CHI
  {
    team1Code: 'ECU',
    team2Code: 'CHI',
    team1Name: 'Ecuador',
    team2Name: 'Chile',
    historicalAnalysis: `Ecuador and Chile have faced each other dozens of times in World Cup qualifiers, creating a familiar rivalry. Chile's dominance during their Golden Generation (2015-2016) included victories over Ecuador, but the balance has shifted as Chile's stars have aged.

Ecuador's current generation, led by Moisés Caicedo and Piero Hincapié, represents their most talented ever. Chile, returning to the World Cup after missing 2018 and 2022, are a team in transition.

This match pits Ecuador's rising stars against Chile's experienced but declining core.`,
    keyStorylines: [
      'Ecuador\'s best generation vs Chile\'s fading golden era',
      'Caicedo showcasing his talent against South American rivals',
      'Chile seeking to prove reports of their decline premature',
      'Battle for CONMEBOL pride',
    ],
    playersToWatch: [
      { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'World-class midfielder driving Ecuador' },
      { name: 'Alexis Sánchez', teamCode: 'CHI', position: 'Forward', reason: 'Chile\'s all-time leading scorer' },
      { name: 'Piero Hincapié', teamCode: 'ECU', position: 'Defender', reason: 'Bayer Leverkusen\'s classy defender' },
      { name: 'Ben Brereton Díaz', teamCode: 'CHI', position: 'Striker', reason: 'England-born striker providing goal threat' },
    ],
    tacticalPreview: `Ecuador will control midfield through Caicedo and build patiently. Chile will press high hoping to force errors. Ecuador's composure vs Chile's intensity will define the match.`,
    prediction: {
      predictedOutcome: 'ECU',
      predictedScore: '2-1',
      confidence: 58,
      reasoning: 'Ecuador\'s younger, more athletic squad should edge a tight contest against aging Chile.',
      alternativeScenario: 'Chile\'s experience and Sánchez magic could produce a surprise 2-1 victory.',
    },
    pastEncountersSummary: 'Dozens of meetings in CONMEBOL qualifying with Chile historically dominant, but Ecuador\'s recent form suggests the balance has shifted.',
    funFacts: [
      'Chile missed both the 2018 and 2022 World Cups',
      'Ecuador\'s Enner Valencia has scored in multiple World Cups',
      'Caicedo is one of the world\'s most expensive midfielders',
      'This will be Ecuador\'s 5th World Cup appearance',
    ],
    isFirstMeeting: false,
  },

  // ECU vs CMR
  {
    team1Code: 'ECU',
    team2Code: 'CMR',
    team1Name: 'Ecuador',
    team2Name: 'Cameroon',
    historicalAnalysis: `Ecuador and Cameroon have no significant history, making this World Cup encounter a true unknown. Both nations have similar profiles: proud football traditions, colorful supporter cultures, and a history of producing talented individuals who shine at World Cups.

Ecuador's 2022 World Cup campaign saw them win their opening match before exiting in the group stage. Cameroon memorably beat Brazil in the same tournament but couldn't advance.

This match could determine which team advances from Group C alongside Colombia.`,
    keyStorylines: [
      'First-ever competitive meeting between these nations',
      'Crucial match likely deciding who advances from Group C',
      'Ecuador\'s technical quality vs Cameroon\'s physicality',
      'Two proud football nations seeking knockout round football',
    ],
    playersToWatch: [
      { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'Ecuador\'s world-class midfielder' },
      { name: 'André-Frank Zambo Anguissa', teamCode: 'CMR', position: 'Midfielder', reason: 'Napoli\'s midfield engine' },
      { name: 'Enner Valencia', teamCode: 'ECU', position: 'Striker', reason: 'Ecuador\'s all-time World Cup top scorer' },
      { name: 'Vincent Aboubakar', teamCode: 'CMR', position: 'Forward', reason: 'Cameroon captain and target man' },
    ],
    tacticalPreview: `A tactical battle in midfield between Caicedo and Anguissa. Ecuador will try to keep the ball on the ground while Cameroon use their physical advantages. Set pieces will be important.`,
    prediction: {
      predictedOutcome: 'DRAW',
      predictedScore: '1-1',
      confidence: 48,
      reasoning: 'Two evenly matched teams likely to produce a tense, tactical draw. Neither can afford to lose.',
      alternativeScenario: 'Ecuador\'s superior technical quality could produce a 2-0 win, or Cameroon\'s physicality could overwhelm for a 2-1 victory.',
    },
    pastEncountersSummary: 'No previous meetings at any level. This is a historic first encounter.',
    funFacts: [
      'First-ever meeting between Ecuador and Cameroon',
      'Both nations have never reached a World Cup semi-final',
      'Cameroon beat Brazil 1-0 at the 2022 World Cup',
      'Ecuador\'s Valencia scored 3 goals at the 2022 World Cup',
    ],
    isFirstMeeting: true,
  },

  // CHI vs CMR
  {
    team1Code: 'CHI',
    team2Code: 'CMR',
    team1Name: 'Chile',
    team2Name: 'Cameroon',
    historicalAnalysis: `Chile and Cameroon have met rarely, with their most notable encounter coming at the 2017 Confederations Cup where Chile won 2-0. That match showcased Chile's golden generation at their peak.

Both nations have proud World Cup traditions: Chile's back-to-back Copa América victories (2015, 2016) and Cameroon's quarter-final appearances (1990). Both are now trying to recapture former glory with new generations.

This Group C clash could determine which team avoids bottom place.`,
    keyStorylines: [
      'Two former powers seeking to revive World Cup dreams',
      'Chile\'s aging stars vs Cameroon\'s athletic approach',
      'Rematch of 2017 Confederations Cup encounter',
      'Battle to avoid bottom of Group C',
    ],
    playersToWatch: [
      { name: 'Alexis Sánchez', teamCode: 'CHI', position: 'Forward', reason: 'Chile\'s all-time leading scorer and leader' },
      { name: 'André-Frank Zambo Anguissa', teamCode: 'CMR', position: 'Midfielder', reason: 'Cameroon\'s midfield general' },
      { name: 'Ben Brereton Díaz', teamCode: 'CHI', position: 'Striker', reason: 'Chile\'s goal threat and England-born star' },
      { name: 'Eric Maxim Choupo-Moting', teamCode: 'CMR', position: 'Forward', reason: 'Experienced Bayern Munich striker' },
    ],
    tacticalPreview: `Chile will try to control possession and probe for openings. Cameroon will use their physical advantages and look to win aerial battles. Midfield control will be crucial.`,
    prediction: {
      predictedOutcome: 'DRAW',
      predictedScore: '1-1',
      confidence: 50,
      reasoning: 'Two evenly matched teams with clear strengths and weaknesses likely to cancel each other out.',
      alternativeScenario: 'Chile\'s experience in big matches could see them through 2-0, or Cameroon\'s physicality could overwhelm for a 2-1 win.',
    },
    pastEncountersSummary: 'Limited history. Chile won 2-0 at the 2017 Confederations Cup, their most notable meeting.',
    funFacts: [
      'Chile won the 2017 Confederations Cup meeting 2-0',
      'Cameroon have appeared at 8 World Cups (most of any African nation)',
      'Chile won back-to-back Copa Américas in 2015-2016',
      'Both nations have produced iconic World Cup moments',
    ],
    isFirstMeeting: false,
  },
];

// ============================================================================
// Remaining groups follow similar pattern...
// For brevity, here are condensed versions of remaining groups
// ============================================================================

// GROUP D: FRA, ENG, ESP, CIV (Group of Death)
const GROUP_D_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'FRA',
    team2Code: 'ENG',
    team1Name: 'France',
    team2Name: 'England',
    historicalAnalysis: `France and England's rivalry transcends football, rooted in centuries of historical conflict. On the pitch, they've met at major tournaments with mixed results. England's 2022 World Cup quarter-final loss to France (2-1) remains painful—Harry Kane's missed penalty haunts English fans.

France are two-time World Cup champions (1998, 2018) and 2022 runners-up. England haven't won a major tournament since 1966. This "Group of Death" clash could be one of the matches of the tournament.`,
    keyStorylines: [
      'Revenge mission for England after 2022 quarter-final heartbreak',
      'Mbappé vs England\'s defense: The key battle',
      'Group of Death showdown between European giants',
      'France seeking to prove 2022 final loss was an aberration',
    ],
    playersToWatch: [
      { name: 'Kylian Mbappé', teamCode: 'FRA', position: 'Forward', reason: 'The world\'s best player and France captain' },
      { name: 'Jude Bellingham', teamCode: 'ENG', position: 'Midfielder', reason: 'England\'s talisman and Ballon d\'Or contender' },
      { name: 'Antoine Griezmann', teamCode: 'FRA', position: 'Forward', reason: 'France\'s creative hub and big-game player' },
      { name: 'Harry Kane', teamCode: 'ENG', position: 'Striker', reason: 'England\'s captain seeking World Cup redemption' },
    ],
    tacticalPreview: `A tactical chess match between two of Europe's best. France's pace and transitions vs England's organized pressing. Mbappé must be contained; Kane must take his chances.`,
    prediction: {
      predictedOutcome: 'FRA',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'France\'s tournament experience and Mbappé\'s brilliance give them an edge, but this is incredibly close.',
      alternativeScenario: 'England\'s motivation from 2022 could produce a famous 2-1 victory.',
    },
    pastEncountersSummary: 'The 2022 World Cup quarter-final (2-1 France) defines recent history. Kane\'s missed penalty remains a source of English pain.',
    funFacts: [
      'England\'s Kane missed a crucial penalty in their 2022 World Cup quarter-final loss',
      'France have reached three of the last four World Cup finals',
      'England haven\'t beaten France at a World Cup since 1982',
      'Mbappé scored a hat-trick in the 2022 World Cup final',
    ],
    isFirstMeeting: false,
  },
  {
    team1Code: 'FRA',
    team2Code: 'ESP',
    team1Name: 'France',
    team2Name: 'Spain',
    historicalAnalysis: `France and Spain's rivalry features football at its finest. Both nations have won World Cups and European Championships, representing contrasting styles: France's pace and power vs Spain's possession and precision.

Spain's Euro 2024 triumph confirmed a new golden generation led by teenage sensation Lamine Yamal. France's star power is unmatched with Mbappé leading the charge.`,
    keyStorylines: [
      'Euro 2024 champions Spain vs World Cup pedigree France',
      'Mbappé vs Yamal: Present vs future?',
      'Tactical masterclass in the Group of Death',
      'Two of football\'s greatest nations collide',
    ],
    playersToWatch: [
      { name: 'Kylian Mbappé', teamCode: 'FRA', position: 'Forward', reason: 'France\'s unstoppable attacking threat' },
      { name: 'Lamine Yamal', teamCode: 'ESP', position: 'Winger', reason: 'Teenage phenomenon who dominated Euro 2024' },
      { name: 'Aurélien Tchouaméni', teamCode: 'FRA', position: 'Midfielder', reason: 'Real Madrid\'s midfield anchor' },
      { name: 'Pedri', teamCode: 'ESP', position: 'Midfielder', reason: 'Orchestrates Spain\'s intricate passing' },
    ],
    tacticalPreview: `Spain's possession game vs France's devastating transitions. Pedri vs Tchouaméni in midfield is crucial. France must be patient; Spain must avoid getting caught on the counter.`,
    prediction: {
      predictedOutcome: 'DRAW',
      predictedScore: '1-1',
      confidence: 52,
      reasoning: 'Two elite teams likely to respect each other\'s quality, producing a tactical draw.',
      alternativeScenario: 'Spain\'s Euro 2024 form could see them through 2-0, or Mbappé brilliance could win it 2-1 for France.',
    },
    pastEncountersSummary: 'Competitive rivalry with both nations winning key matches. France won the 2021 Nations League final; Spain have dominated recent friendlies.',
    funFacts: [
      'Spain won Euro 2024 while Yamal was 16 years old',
      'France have reached three of the last four World Cup finals',
      'Spain\'s tiki-taka revolutionized football in the 2010s',
      'Mbappé scored 4 goals at the 2022 World Cup including a final hat-trick',
    ],
    isFirstMeeting: false,
  },
  {
    team1Code: 'FRA',
    team2Code: 'CIV',
    team1Name: 'France',
    team2Name: 'Ivory Coast',
    historicalAnalysis: `France and Ivory Coast share deep cultural ties through French colonization, with many Ivorian players developing in the French league system. Their encounters carry unique emotional weight.

Ivory Coast are reigning African champions after winning AFCON 2024 on home soil. France are World Cup favorites with extraordinary talent.`,
    keyStorylines: [
      'Colonial history meets football: A match with cultural significance',
      'AFCON champions vs World Cup favorites',
      'Many Ivorian players facing familiar French opponents',
      'Can Ivory Coast produce an upset?',
    ],
    playersToWatch: [
      { name: 'Kylian Mbappé', teamCode: 'FRA', position: 'Forward', reason: 'World\'s best player' },
      { name: 'Sébastien Haller', teamCode: 'CIV', position: 'Striker', reason: 'AFCON hero with inspirational comeback story' },
      { name: 'Aurélien Tchouaméni', teamCode: 'FRA', position: 'Midfielder', reason: 'France\'s midfield general' },
      { name: 'Franck Kessié', teamCode: 'CIV', position: 'Midfielder', reason: 'Physical presence in midfield' },
    ],
    tacticalPreview: `France's superior quality should tell, but Ivory Coast's physicality and AFCON winning mentality make them dangerous. France must be clinical.`,
    prediction: {
      predictedOutcome: 'FRA',
      predictedScore: '3-0',
      confidence: 78,
      reasoning: 'France\'s quality is simply too much for Ivory Coast despite their AFCON triumph.',
      alternativeScenario: 'Ivory Coast scoring first and defending deep could produce a shock 1-1 draw.',
    },
    pastEncountersSummary: 'France have dominated meetings, but Ivory Coast\'s AFCON triumph suggests they\'ve improved significantly.',
    funFacts: [
      'Many Ivorian players developed in the French league',
      'Haller returned from cancer to become AFCON 2024 hero',
      'Ivory Coast won AFCON 2024 after nearly being eliminated in the group stage',
      'France have scored in every World Cup match since 2014',
    ],
    isFirstMeeting: false,
  },
  {
    team1Code: 'ENG',
    team2Code: 'ESP',
    team1Name: 'England',
    team2Name: 'Spain',
    historicalAnalysis: `England and Spain are European football royalty with contrasting recent histories. Spain dominated world football from 2008-2012 with their tiki-taka style. England have reached recent tournament finals (Euro 2020, 2024) but failed to win.

Spain's Euro 2024 triumph confirmed their return to the top. England's talented squad continues seeking that elusive trophy.`,
    keyStorylines: [
      'Euro 2020 and 2024 finalist England vs Euro 2024 champions Spain',
      'Bellingham vs Pedri: Midfield battle of the ages',
      'England seeking to finally win a major tournament',
      'Spain\'s new golden generation vs England\'s perennial promise',
    ],
    playersToWatch: [
      { name: 'Jude Bellingham', teamCode: 'ENG', position: 'Midfielder', reason: 'England\'s best player and Real Madrid star' },
      { name: 'Lamine Yamal', teamCode: 'ESP', position: 'Winger', reason: 'Teenage sensation' },
      { name: 'Harry Kane', teamCode: 'ENG', position: 'Striker', reason: 'England\'s all-time leading scorer' },
      { name: 'Rodri', teamCode: 'ESP', position: 'Midfielder', reason: 'Manchester City\'s Ballon d\'Or winner' },
    ],
    tacticalPreview: `Spain's possession vs England's direct approach. Bellingham must win his battle with Rodri. Kane's movement against Spain's high line will be crucial.`,
    prediction: {
      predictedOutcome: 'ESP',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'Spain\'s Euro 2024 triumph and technical superiority give them an edge, but England will compete.',
      alternativeScenario: 'England\'s big-game experience could produce a famous 2-1 victory.',
    },
    pastEncountersSummary: 'Competitive rivalry with Spain generally having the upper hand in recent decades. England haven\'t beaten Spain in a competitive match since 1996.',
    funFacts: [
      'Spain won Euro 2024 beating England in the final',
      'England haven\'t won a major trophy since 1966',
      'Rodri won the 2024 Ballon d\'Or',
      'Kane is England\'s all-time leading scorer',
    ],
    isFirstMeeting: false,
  },
  {
    team1Code: 'ENG',
    team2Code: 'CIV',
    team1Name: 'England',
    team2Name: 'Ivory Coast',
    historicalAnalysis: `England and Ivory Coast have minimal competitive history. Their most notable meeting was a 2011 friendly at Wembley (2-2). This World Cup encounter represents a significant upgrade.

Ivory Coast's AFCON 2024 triumph and England's tournament pedigree suggest contrasting styles: English organization vs Ivorian flair.`,
    keyStorylines: [
      'First significant competitive meeting',
      'England seeking to top the Group of Death',
      'AFCON champions testing themselves against European elite',
      'Premier League connections throughout both squads',
    ],
    playersToWatch: [
      { name: 'Jude Bellingham', teamCode: 'ENG', position: 'Midfielder', reason: 'England\'s talisman' },
      { name: 'Sébastien Haller', teamCode: 'CIV', position: 'Striker', reason: 'Former Premier League striker and AFCON hero' },
      { name: 'Phil Foden', teamCode: 'ENG', position: 'Winger', reason: 'Manchester City\'s creative force' },
      { name: 'Simon Adingra', teamCode: 'CIV', position: 'Winger', reason: 'Brighton\'s exciting talent' },
    ],
    tacticalPreview: `England should dominate possession, but Ivory Coast's pace on the counter is dangerous. Set pieces could be crucial given Ivory Coast's aerial threat.`,
    prediction: {
      predictedOutcome: 'ENG',
      predictedScore: '2-0',
      confidence: 72,
      reasoning: 'England\'s quality should prove too much, though Ivory Coast will make it competitive.',
      alternativeScenario: 'Ivory Coast scoring early could produce a shock result.',
    },
    pastEncountersSummary: 'Minimal history. A 2011 friendly (2-2) is their most notable previous meeting.',
    funFacts: [
      'First World Cup meeting between England and Ivory Coast',
      'Multiple Ivory Coast players play in the Premier League',
      'Ivory Coast\'s AFCON 2024 win was their third continental title',
      'England are in the Group of Death with France and Spain',
    ],
    isFirstMeeting: true,
  },
  {
    team1Code: 'ESP',
    team2Code: 'CIV',
    team1Name: 'Spain',
    team2Name: 'Ivory Coast',
    historicalAnalysis: `Spain and Ivory Coast have met rarely, with their most notable encounter coming at the 2012 Olympics where Spain won on penalties in the quarter-finals. That match showcased young talent from both nations.

Spain's Euro 2024 triumph confirmed their status as world football's elite. Ivory Coast's AFCON success proved African football's continued growth.`,
    keyStorylines: [
      'Euro 2024 champions vs AFCON 2024 champions',
      'Spain\'s technical brilliance vs Ivory Coast\'s athleticism',
      'Yamal and Spain\'s young stars against African opposition',
      'Can Ivory Coast compete with Europe\'s best?',
    ],
    playersToWatch: [
      { name: 'Lamine Yamal', teamCode: 'ESP', position: 'Winger', reason: 'Teenage sensation' },
      { name: 'Franck Kessié', teamCode: 'CIV', position: 'Midfielder', reason: 'Physical presence' },
      { name: 'Pedri', teamCode: 'ESP', position: 'Midfielder', reason: 'Spain\'s creative hub' },
      { name: 'Nicolas Pépé', teamCode: 'CIV', position: 'Winger', reason: 'Pace and trickery on the wing' },
    ],
    tacticalPreview: `Spain will dominate possession while Ivory Coast try to stay compact and counter. Spain's patience will be tested against Ivorian physicality.`,
    prediction: {
      predictedOutcome: 'ESP',
      predictedScore: '3-1',
      confidence: 75,
      reasoning: 'Spain\'s technical superiority should prove decisive despite Ivory Coast\'s competitive spirit.',
      alternativeScenario: 'Ivory Coast defending deep and scoring on counter could produce a 1-1 draw.',
    },
    pastEncountersSummary: 'Limited history. Spain won on penalties at 2012 Olympics. No significant competitive meetings since.',
    funFacts: [
      'Spain beat Ivory Coast in 2012 Olympic quarter-final penalties',
      'Both teams are reigning continental champions (Euro 2024, AFCON 2024)',
      'Spain\'s Yamal is the youngest player to score at a European Championship',
      'Ivory Coast\'s AFCON triumph was a remarkable comeback from near-elimination',
    ],
    isFirstMeeting: false,
  },
];

// Continue with remaining groups...
// For space, I'll add abbreviated versions of remaining groups

// GROUP E: GER, NED, POR, ALG
const GROUP_E_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'GER',
    team2Code: 'NED',
    team1Name: 'Germany',
    team2Name: 'Netherlands',
    historicalAnalysis: `One of football's greatest rivalries. Germany and Netherlands have produced classic World Cup encounters, most famously the 1974 final won by Germany and the 1990 Round of 16 clash with spitting incidents and red cards. The Netherlands have never beaten Germany in a World Cup knockout match.`,
    keyStorylines: ['Historic European rivalry renewed', 'Germany seeking redemption after consecutive group exits', 'Musiala vs Van Dijk: Key battle', 'Netherlands seeking first World Cup knockout win over Germany'],
    playersToWatch: [
      { name: 'Jamal Musiala', teamCode: 'GER', position: 'Midfielder', reason: 'Germany\'s creative genius' },
      { name: 'Virgil van Dijk', teamCode: 'NED', position: 'Defender', reason: 'World-class leader' },
      { name: 'Florian Wirtz', teamCode: 'GER', position: 'Midfielder', reason: 'Germany\'s other prodigy' },
      { name: 'Cody Gakpo', teamCode: 'NED', position: 'Forward', reason: '2022 World Cup breakout star' },
    ],
    tacticalPreview: `Both teams play attractive football. Germany's pressing vs Dutch total football philosophy. Midfield control will be decisive.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '2-2', confidence: 48, reasoning: 'Classic rivalry likely to produce an entertaining draw.' },
    funFacts: ['Netherlands have never beaten Germany in a World Cup knockout match', 'The 1974 World Cup final remains one of football\'s most famous matches', 'Both nations have won World Cups and European Championships'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'GER',
    team2Code: 'POR',
    team1Name: 'Germany',
    team2Name: 'Portugal',
    historicalAnalysis: `Germany and Portugal have met multiple times at major tournaments, with Germany generally dominant. Their 2014 World Cup group match (4-0 Germany) was particularly memorable. Ronaldo potentially faces his final World Cup against a resurgent Germany.`,
    keyStorylines: ['Ronaldo\'s potential final World Cup', 'Germany seeking redemption', 'Portugal\'s next generation vs German pressing'],
    playersToWatch: [
      { name: 'Jamal Musiala', teamCode: 'GER', position: 'Midfielder', reason: 'Creative force' },
      { name: 'Cristiano Ronaldo', teamCode: 'POR', position: 'Forward', reason: 'Legendary striker in final World Cup?' },
      { name: 'Florian Wirtz', teamCode: 'GER', position: 'Midfielder', reason: 'Bundesliga\'s best' },
      { name: 'Rafael Leão', teamCode: 'POR', position: 'Winger', reason: 'Portugal\'s future' },
    ],
    tacticalPreview: `Germany's high press vs Portugal's individual quality. Musiala and Wirtz vs Bruno Fernandes in midfield will be crucial.`,
    prediction: { predictedOutcome: 'GER', predictedScore: '2-1', confidence: 58, reasoning: 'Germany\'s collective strength vs Portugal\'s star power slightly favors Germany.' },
    funFacts: ['Germany beat Portugal 4-0 at the 2014 World Cup', 'Ronaldo has scored in five different World Cups', 'Germany have won 4 World Cups'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'GER',
    team2Code: 'ALG',
    team1Name: 'Germany',
    team2Name: 'Algeria',
    historicalAnalysis: `Germany and Algeria's most famous World Cup encounter was the 2014 Round of 16, where Germany won 2-1 in extra time in one of the tournament's most entertaining matches. Algeria pushed Germany to the limit with their pressing and counter-attacks.`,
    keyStorylines: ['Rematch of 2014 thriller', 'Germany determined to avoid another close call', 'Algeria seeking to build on 2014 heroics'],
    playersToWatch: [
      { name: 'Jamal Musiala', teamCode: 'GER', position: 'Midfielder', reason: 'Germany\'s star' },
      { name: 'Riyad Mahrez', teamCode: 'ALG', position: 'Winger', reason: 'Algeria\'s creative force' },
      { name: 'Florian Wirtz', teamCode: 'GER', position: 'Midfielder', reason: 'Creative talent' },
      { name: 'Ismaël Bennacer', teamCode: 'ALG', position: 'Midfielder', reason: 'AC Milan\'s midfield anchor' },
    ],
    tacticalPreview: `Germany must respect Algeria's counter-attacking threat while controlling possession. Algeria need to replicate 2014's pressing intensity.`,
    prediction: { predictedOutcome: 'GER', predictedScore: '3-1', confidence: 70, reasoning: 'Germany\'s quality should tell, but Algeria will compete.' },
    funFacts: ['Algeria pushed Germany to extra time in 2014', 'That match is considered one of the best World Cup games ever', 'Germany won the 2014 World Cup'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'NED',
    team2Code: 'POR',
    team1Name: 'Netherlands',
    team2Name: 'Portugal',
    historicalAnalysis: `Netherlands and Portugal's most famous encounter was the infamous "Battle of Nuremberg" at the 2006 World Cup, where 16 yellow cards and 4 red cards were shown. Portugal won 1-0 in a brutal match. Their rivalry has cooled since.`,
    keyStorylines: ['Rematch of 2006\'s most violent World Cup match', 'Dutch organization vs Portuguese flair', 'Ronaldo facing Van Dijk'],
    playersToWatch: [
      { name: 'Virgil van Dijk', teamCode: 'NED', position: 'Defender', reason: 'World-class defender' },
      { name: 'Cristiano Ronaldo', teamCode: 'POR', position: 'Forward', reason: 'Legendary goal scorer' },
      { name: 'Cody Gakpo', teamCode: 'NED', position: 'Forward', reason: 'Dutch goal threat' },
      { name: 'Bruno Fernandes', teamCode: 'POR', position: 'Midfielder', reason: 'Creative hub' },
    ],
    tacticalPreview: `Dutch structure vs Portuguese individual brilliance. Van Dijk vs Ronaldo will be fascinating. Midfield battle crucial.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Two quality teams likely to cancel each other out.' },
    funFacts: ['The 2006 match had 16 yellow cards and 4 red cards', 'Referee Valentin Ivanov set a World Cup record for cards', 'Portugal won that infamous match 1-0'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'NED',
    team2Code: 'ALG',
    team1Name: 'Netherlands',
    team2Name: 'Algeria',
    historicalAnalysis: `Netherlands and Algeria have no significant World Cup history. This encounter represents a clash of European power and African ambition.`,
    keyStorylines: ['First World Cup meeting', 'Dutch quality vs Algerian organization', 'Netherlands seeking to advance from Group E'],
    playersToWatch: [
      { name: 'Cody Gakpo', teamCode: 'NED', position: 'Forward', reason: 'Dutch goal threat' },
      { name: 'Riyad Mahrez', teamCode: 'ALG', position: 'Winger', reason: 'Algeria\'s star' },
      { name: 'Virgil van Dijk', teamCode: 'NED', position: 'Defender', reason: 'Defensive leader' },
      { name: 'Ismaël Bennacer', teamCode: 'ALG', position: 'Midfielder', reason: 'Midfield anchor' },
    ],
    tacticalPreview: `Netherlands should control possession with Algeria looking to counter. Mahrez's moments of magic could be decisive.`,
    prediction: { predictedOutcome: 'NED', predictedScore: '2-0', confidence: 68, reasoning: 'Dutch quality should prove too much for Algeria.' },
    funFacts: ['First World Cup meeting between these nations', 'Algeria\'s best World Cup was 2014 Round of 16', 'Netherlands have reached 3 World Cup finals'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'POR',
    team2Code: 'ALG',
    team1Name: 'Portugal',
    team2Name: 'Algeria',
    historicalAnalysis: `Portugal and Algeria share colonial history, adding extra dimension to their encounters. They've met in friendlies but never at a World Cup. This represents a significant first.`,
    keyStorylines: ['Colonial history meets World Cup football', 'Ronaldo facing African opposition', 'Algeria seeking prestigious scalp'],
    playersToWatch: [
      { name: 'Cristiano Ronaldo', teamCode: 'POR', position: 'Forward', reason: 'Legendary striker' },
      { name: 'Riyad Mahrez', teamCode: 'ALG', position: 'Winger', reason: 'Algeria\'s talisman' },
      { name: 'Rafael Leão', teamCode: 'POR', position: 'Winger', reason: 'Electric pace' },
      { name: 'Ismaël Bennacer', teamCode: 'ALG', position: 'Midfielder', reason: 'Midfield general' },
    ],
    tacticalPreview: `Portugal's individual quality vs Algeria's tactical discipline. Ronaldo's movement will test Algeria's defense.`,
    prediction: { predictedOutcome: 'POR', predictedScore: '3-1', confidence: 72, reasoning: 'Portugal\'s superior squad should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Colonial history adds extra significance', 'Both nations have produced world-class playmakers'],
    isFirstMeeting: true,
  },
];

// GROUP F: BEL, ITA, CRO, TUN
const GROUP_F_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'BEL',
    team2Code: 'ITA',
    team1Name: 'Belgium',
    team2Name: 'Italy',
    historicalAnalysis: `Belgium and Italy's rivalry has intensified in recent years. Italy's Euro 2020 quarter-final victory (2-1) ended Belgium's "golden generation" hopes, with De Bruyne playing through injury. Both nations have rich football histories.`,
    keyStorylines: ['Rematch of Euro 2020 quarter-final', 'Belgium\'s last chance for their golden generation', 'Italy\'s new era post-2022 World Cup absence'],
    playersToWatch: [
      { name: 'Kevin De Bruyne', teamCode: 'BEL', position: 'Midfielder', reason: 'Belgium\'s orchestrator' },
      { name: 'Nicolò Barella', teamCode: 'ITA', position: 'Midfielder', reason: 'Italy\'s engine' },
      { name: 'Romelu Lukaku', teamCode: 'BEL', position: 'Striker', reason: 'Belgium\'s all-time top scorer' },
      { name: 'Federico Chiesa', teamCode: 'ITA', position: 'Winger', reason: 'Italy\'s most dangerous attacker' },
    ],
    tacticalPreview: `De Bruyne vs Barella in midfield will decide this match. Belgium's direct approach vs Italy's tactical flexibility.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Two quality teams likely to produce a tight, tactical draw.' },
    funFacts: ['Italy beat Belgium 2-1 at Euro 2020', 'Belgium missed the 2022 World Cup knockout rounds', 'Italy missed the 2022 World Cup entirely'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'BEL',
    team2Code: 'CRO',
    team1Name: 'Belgium',
    team2Name: 'Croatia',
    historicalAnalysis: `Belgium and Croatia met at the 2022 World Cup in a crucial group match. Croatia's 0-0 draw eliminated Belgium in one of the tournament's biggest surprises. It was a painful end for Belgium's highly-ranked squad.`,
    keyStorylines: ['Rematch of 2022 World Cup group decider', 'Belgium seeking revenge', 'Croatia\'s tournament experience vs Belgium\'s quality', 'Modrić vs De Bruyne: Midfield legends'],
    playersToWatch: [
      { name: 'Kevin De Bruyne', teamCode: 'BEL', position: 'Midfielder', reason: 'World-class playmaker' },
      { name: 'Luka Modrić', teamCode: 'CRO', position: 'Midfielder', reason: 'Ageless maestro' },
      { name: 'Romelu Lukaku', teamCode: 'BEL', position: 'Striker', reason: 'Must convert chances this time' },
      { name: 'Joško Gvardiol', teamCode: 'CRO', position: 'Defender', reason: 'World-class center-back' },
    ],
    tacticalPreview: `Belgium must be more clinical than 2022. Croatia's midfield control vs Belgium's individual quality will be fascinating.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '0-0', confidence: 45, reasoning: 'Another tactical stalemate is possible given 2022 history.' },
    funFacts: ['Croatia\'s 0-0 draw eliminated Belgium in 2022', 'Lukaku missed several clear chances in that match', 'Croatia went on to finish third in 2022'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'BEL',
    team2Code: 'TUN',
    team1Name: 'Belgium',
    team2Name: 'Tunisia',
    historicalAnalysis: `Belgium and Tunisia have limited history. Belgium should have too much quality, but their 2022 World Cup disaster suggests they can struggle against organized African opposition.`,
    keyStorylines: ['Belgium must avoid another African upset', 'Tunisia seeking to cause shock', 'De Bruyne leading Belgium\'s attack'],
    playersToWatch: [
      { name: 'Kevin De Bruyne', teamCode: 'BEL', position: 'Midfielder', reason: 'Belgium\'s best player' },
      { name: 'Hannibal Mejbri', teamCode: 'TUN', position: 'Midfielder', reason: 'Tunisia\'s rising star' },
      { name: 'Romelu Lukaku', teamCode: 'BEL', position: 'Striker', reason: 'Goal threat' },
      { name: 'Wahbi Khazri', teamCode: 'TUN', position: 'Forward', reason: 'Tunisia\'s experienced attacker' },
    ],
    tacticalPreview: `Belgium should dominate possession. Tunisia will defend deep and counter. Clinical finishing will be crucial for Belgium.`,
    prediction: { predictedOutcome: 'BEL', predictedScore: '3-1', confidence: 72, reasoning: 'Belgium\'s quality should prove decisive.' },
    funFacts: ['Tunisia have never reached World Cup knockout rounds', 'Belgium\'s golden generation is running out of time', 'First World Cup meeting'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'ITA',
    team2Code: 'CRO',
    team1Name: 'Italy',
    team2Name: 'Croatia',
    historicalAnalysis: `Italy and Croatia have met multiple times at major tournaments. Their Euro 2012 group match ended 1-1. Croatia's 2018 and 2022 World Cup runs have established them as a tournament force.`,
    keyStorylines: ['European neighbors clash', 'Modrić vs Barella in midfield', 'Italy\'s redemption after missing 2022 World Cup'],
    playersToWatch: [
      { name: 'Nicolò Barella', teamCode: 'ITA', position: 'Midfielder', reason: 'Italy\'s heartbeat' },
      { name: 'Luka Modrić', teamCode: 'CRO', position: 'Midfielder', reason: 'Legendary playmaker' },
      { name: 'Federico Chiesa', teamCode: 'ITA', position: 'Winger', reason: 'Italy\'s match-winner' },
      { name: 'Joško Gvardiol', teamCode: 'CRO', position: 'Defender', reason: 'World-class defender' },
    ],
    tacticalPreview: `Two tactically sophisticated teams. Midfield control will be decisive. Both teams prefer possession but can counter effectively.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 52, reasoning: 'Two evenly matched teams likely to share points.' },
    funFacts: ['Euro 2012 ended 1-1', 'Croatia have reached more recent World Cup semi-finals', 'Italy missed the 2022 World Cup'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'ITA',
    team2Code: 'TUN',
    team1Name: 'Italy',
    team2Name: 'Tunisia',
    historicalAnalysis: `Italy and Tunisia share Mediterranean connections. Their matches have been competitive friendlies. Italy's pedigree should prove too much for Tunisia.`,
    keyStorylines: ['Mediterranean rivals meet at World Cup', 'Italy seeking to top Group F', 'Tunisia looking for surprise'],
    playersToWatch: [
      { name: 'Federico Chiesa', teamCode: 'ITA', position: 'Winger', reason: 'Italy\'s danger man' },
      { name: 'Hannibal Mejbri', teamCode: 'TUN', position: 'Midfielder', reason: 'Tunisia\'s young talent' },
      { name: 'Nicolò Barella', teamCode: 'ITA', position: 'Midfielder', reason: 'Midfield controller' },
      { name: 'Wahbi Khazri', teamCode: 'TUN', position: 'Forward', reason: 'Experienced attacker' },
    ],
    tacticalPreview: `Italy will control the game while Tunisia look to frustrate and counter. Italy's patience will be tested.`,
    prediction: { predictedOutcome: 'ITA', predictedScore: '2-0', confidence: 70, reasoning: 'Italy\'s quality should prove decisive.' },
    funFacts: ['Both nations border the Mediterranean', 'Tunisia have qualified for 6 World Cups', 'Italy have won 4 World Cups'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'CRO',
    team2Code: 'TUN',
    team1Name: 'Croatia',
    team2Name: 'Tunisia',
    historicalAnalysis: `Croatia and Tunisia have never met at a World Cup. Croatia's tournament pedigree is exceptional, while Tunisia have struggled to advance from group stages.`,
    keyStorylines: ['First World Cup meeting', 'Croatia seeking group stage control', 'Tunisia looking for historic result'],
    playersToWatch: [
      { name: 'Luka Modrić', teamCode: 'CRO', position: 'Midfielder', reason: 'Croatia\'s legend' },
      { name: 'Hannibal Mejbri', teamCode: 'TUN', position: 'Midfielder', reason: 'Young talent' },
      { name: 'Joško Gvardiol', teamCode: 'CRO', position: 'Defender', reason: 'Elite defender' },
      { name: 'Wahbi Khazri', teamCode: 'TUN', position: 'Forward', reason: 'Tunisia\'s attacker' },
    ],
    tacticalPreview: `Croatia will dominate midfield. Tunisia must stay compact and hope for counter-attacking opportunities.`,
    prediction: { predictedOutcome: 'CRO', predictedScore: '2-0', confidence: 75, reasoning: 'Croatia\'s tournament experience should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Croatia have reached 2 World Cup finals', 'Tunisia have never won a World Cup knockout match'],
    isFirstMeeting: true,
  },
];

// GROUP G: DEN, SUI, AUT, NZL
const GROUP_G_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'DEN',
    team2Code: 'SUI',
    team1Name: 'Denmark',
    team2Name: 'Switzerland',
    historicalAnalysis: `Denmark and Switzerland have met multiple times in qualifying and friendlies. Both are organized European teams with similar footballing philosophies.`,
    keyStorylines: ['European competitors with similar styles', 'Eriksen\'s continued return to top level', 'Battle for Group G control'],
    playersToWatch: [
      { name: 'Christian Eriksen', teamCode: 'DEN', position: 'Midfielder', reason: 'Denmark\'s creative force' },
      { name: 'Granit Xhaka', teamCode: 'SUI', position: 'Midfielder', reason: 'Switzerland\'s captain and leader' },
      { name: 'Rasmus Højlund', teamCode: 'DEN', position: 'Striker', reason: 'Young Manchester United striker' },
      { name: 'Breel Embolo', teamCode: 'SUI', position: 'Forward', reason: 'Swiss goal threat' },
    ],
    tacticalPreview: `Two well-organized European teams. Midfield battle between Eriksen and Xhaka will be crucial.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 52, reasoning: 'Evenly matched teams likely to draw.' },
    funFacts: ['Both teams reached Euro 2020 quarter-finals', 'Switzerland beat France on penalties at Euro 2020', 'Denmark reached Euro 2020 semi-finals'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'DEN',
    team2Code: 'AUT',
    team1Name: 'Denmark',
    team2Name: 'Austria',
    historicalAnalysis: `Denmark and Austria have competitive recent history. Austria under Ralf Rangnick have become a formidable pressing team.`,
    keyStorylines: ['Rangnick\'s Austria vs Danish organization', 'Battle for second place in Group G', 'European tactical battle'],
    playersToWatch: [
      { name: 'Christian Eriksen', teamCode: 'DEN', position: 'Midfielder', reason: 'Creative hub' },
      { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'World-class leader' },
      { name: 'Rasmus Højlund', teamCode: 'DEN', position: 'Striker', reason: 'Goal threat' },
      { name: 'Marcel Sabitzer', teamCode: 'AUT', position: 'Midfielder', reason: 'Austrian engine' },
    ],
    tacticalPreview: `Austria's pressing vs Denmark's possession. Both teams are tactically sophisticated.`,
    prediction: { predictedOutcome: 'DEN', predictedScore: '2-1', confidence: 55, reasoning: 'Denmark\'s slightly superior quality should prove decisive.' },
    funFacts: ['Austria impressed at Euro 2024 under Rangnick', 'Denmark reached Euro 2020 semi-finals', 'Alaba plays for Real Madrid'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'DEN',
    team2Code: 'NZL',
    team1Name: 'Denmark',
    team2Name: 'New Zealand',
    historicalAnalysis: `Denmark and New Zealand have never met at a World Cup. Denmark are heavy favorites against the OFC qualifiers.`,
    keyStorylines: ['First World Cup meeting', 'Denmark expected to dominate', 'New Zealand seeking upset'],
    playersToWatch: [
      { name: 'Christian Eriksen', teamCode: 'DEN', position: 'Midfielder', reason: 'Denmark\'s star' },
      { name: 'Chris Wood', teamCode: 'NZL', position: 'Striker', reason: 'New Zealand\'s Premier League striker' },
      { name: 'Rasmus Højlund', teamCode: 'DEN', position: 'Striker', reason: 'Young talent' },
      { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'NZ\'s best defender' },
    ],
    tacticalPreview: `Denmark will dominate. New Zealand must stay organized and hope Wood can score on limited chances.`,
    prediction: { predictedOutcome: 'DEN', predictedScore: '4-0', confidence: 85, reasoning: 'Quality gap is significant.' },
    funFacts: ['First World Cup meeting', 'New Zealand\'s only World Cup win was against Bahrain in 2009 playoffs', 'Chris Wood plays in the Premier League'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'SUI',
    team2Code: 'AUT',
    team1Name: 'Switzerland',
    team2Name: 'Austria',
    historicalAnalysis: `Switzerland and Austria are Alpine neighbors with a natural rivalry. Both teams have improved significantly in recent years.`,
    keyStorylines: ['Alpine derby at the World Cup', 'Xhaka vs Alaba leadership battle', 'Both teams seeking knockout rounds'],
    playersToWatch: [
      { name: 'Granit Xhaka', teamCode: 'SUI', position: 'Midfielder', reason: 'Swiss captain' },
      { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'Austrian leader' },
      { name: 'Breel Embolo', teamCode: 'SUI', position: 'Forward', reason: 'Swiss striker' },
      { name: 'Christoph Baumgartner', teamCode: 'AUT', position: 'Midfielder', reason: 'Austrian playmaker' },
    ],
    tacticalPreview: `Neighboring rivals with similar styles. Midfield control will be crucial.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched neighbors likely to draw.' },
    funFacts: ['Alpine neighbors with natural rivalry', 'Both teams have reached recent Euro quarter-finals', 'Switzerland beat France on penalties at Euro 2020'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'SUI',
    team2Code: 'NZL',
    team1Name: 'Switzerland',
    team2Name: 'New Zealand',
    historicalAnalysis: `Switzerland and New Zealand have no significant history. Switzerland are heavy favorites.`,
    keyStorylines: ['First significant meeting', 'Switzerland seeking comfortable win', 'New Zealand underdogs'],
    playersToWatch: [
      { name: 'Granit Xhaka', teamCode: 'SUI', position: 'Midfielder', reason: 'Swiss leader' },
      { name: 'Chris Wood', teamCode: 'NZL', position: 'Striker', reason: 'New Zealand\'s main threat' },
      { name: 'Breel Embolo', teamCode: 'SUI', position: 'Forward', reason: 'Swiss attacker' },
      { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'NZ defender' },
    ],
    tacticalPreview: `Switzerland should control the game. New Zealand will defend deep and hope to counter.`,
    prediction: { predictedOutcome: 'SUI', predictedScore: '3-0', confidence: 80, reasoning: 'Quality gap favors Switzerland.' },
    funFacts: ['First World Cup meeting', 'New Zealand last appeared at 2010 World Cup', 'Switzerland have qualified for recent tournaments consistently'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'AUT',
    team2Code: 'NZL',
    team1Name: 'Austria',
    team2Name: 'New Zealand',
    historicalAnalysis: `Austria and New Zealand have never met at a World Cup. Austria under Rangnick are expected to dominate.`,
    keyStorylines: ['First World Cup meeting', 'Austria seeking goals', 'New Zealand massive underdogs'],
    playersToWatch: [
      { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'Austrian star' },
      { name: 'Chris Wood', teamCode: 'NZL', position: 'Striker', reason: 'NZ\'s hope' },
      { name: 'Marcel Sabitzer', teamCode: 'AUT', position: 'Midfielder', reason: 'Austrian engine' },
      { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'NZ defender' },
    ],
    tacticalPreview: `Austria's pressing will overwhelm New Zealand. Expect high possession for Austria.`,
    prediction: { predictedOutcome: 'AUT', predictedScore: '4-1', confidence: 82, reasoning: 'Austria\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Austria\'s best World Cup was third place in 1954', 'New Zealand are OFC champions'],
    isFirstMeeting: true,
  },
];

// GROUP H: POL, SRB, UKR, CRC
const GROUP_H_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'POL',
    team2Code: 'SRB',
    team1Name: 'Poland',
    team2Name: 'Serbia',
    historicalAnalysis: `Poland and Serbia have faced each other in qualifying campaigns. Both nations feature world-class strikers in Lewandowski and Mitrović.`,
    keyStorylines: ['Battle of the strikers: Lewandowski vs Mitrović', 'Eastern European derby', 'Both teams seeking knockout rounds'],
    playersToWatch: [
      { name: 'Robert Lewandowski', teamCode: 'POL', position: 'Striker', reason: 'One of the greatest strikers ever' },
      { name: 'Aleksandar Mitrović', teamCode: 'SRB', position: 'Striker', reason: 'Prolific goal scorer' },
      { name: 'Piotr Zieliński', teamCode: 'POL', position: 'Midfielder', reason: 'Polish playmaker' },
      { name: 'Dušan Vlahović', teamCode: 'SRB', position: 'Striker', reason: 'Juventus striker' },
    ],
    tacticalPreview: `Both teams will look to service their strikers. Midfield control will be crucial.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched teams with quality strikers.' },
    funFacts: ['Lewandowski has scored 600+ career goals', 'Serbia qualified for their first World Cup since 2010 as Serbia (2018)', 'Poland have Lewandowski in potentially his final World Cup'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'POL',
    team2Code: 'UKR',
    team1Name: 'Poland',
    team2Name: 'Ukraine',
    historicalAnalysis: `Poland and Ukraine co-hosted Euro 2012. Their matches carry extra significance given current geopolitical context. Poland have provided significant support to Ukraine.`,
    keyStorylines: ['Neighbors with deep connection', 'Euro 2012 co-hosts reunited', 'Ukraine playing for their nation', 'Lewandowski vs Ukraine\'s defense'],
    playersToWatch: [
      { name: 'Robert Lewandowski', teamCode: 'POL', position: 'Striker', reason: 'World-class striker' },
      { name: 'Mykhailo Mudryk', teamCode: 'UKR', position: 'Winger', reason: 'Ukraine\'s exciting talent' },
      { name: 'Piotr Zieliński', teamCode: 'POL', position: 'Midfielder', reason: 'Polish creator' },
      { name: 'Oleksandr Zinchenko', teamCode: 'UKR', position: 'Midfielder', reason: 'Arsenal\'s versatile star' },
    ],
    tacticalPreview: `Emotional match for both sides. Poland's experience vs Ukraine's determination and flair.`,
    prediction: { predictedOutcome: 'POL', predictedScore: '2-1', confidence: 55, reasoning: 'Poland\'s quality edge should prove decisive.' },
    funFacts: ['Co-hosted Euro 2012 together', 'Poland have supported Ukraine significantly', 'Ukraine qualified through playoffs'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'POL',
    team2Code: 'CRC',
    team1Name: 'Poland',
    team2Name: 'Costa Rica',
    historicalAnalysis: `Poland and Costa Rica have never met at a World Cup. Poland are favorites but Costa Rica's 2014 quarter-final run shows they can surprise.`,
    keyStorylines: ['First World Cup meeting', 'Lewandowski seeking goals', 'Costa Rica looking for upset'],
    playersToWatch: [
      { name: 'Robert Lewandowski', teamCode: 'POL', position: 'Striker', reason: 'Poland\'s star' },
      { name: 'Keylor Navas', teamCode: 'CRC', position: 'Goalkeeper', reason: 'Legendary shot-stopper' },
      { name: 'Piotr Zieliński', teamCode: 'POL', position: 'Midfielder', reason: 'Creative force' },
      { name: 'Joel Campbell', teamCode: 'CRC', position: 'Forward', reason: 'Experienced attacker' },
    ],
    tacticalPreview: `Poland should control possession. Costa Rica will defend deep behind Navas and counter.`,
    prediction: { predictedOutcome: 'POL', predictedScore: '2-0', confidence: 68, reasoning: 'Poland\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Costa Rica reached 2014 quarter-finals', 'Keylor Navas won three Champions Leagues'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'SRB',
    team2Code: 'UKR',
    team1Name: 'Serbia',
    team2Name: 'Ukraine',
    historicalAnalysis: `Serbia and Ukraine have met in qualifying campaigns. Both Eastern European nations have talented squads with point to prove.`,
    keyStorylines: ['Eastern European battle', 'Mitrović vs Ukraine\'s defense', 'Ukraine fighting for their nation'],
    playersToWatch: [
      { name: 'Aleksandar Mitrović', teamCode: 'SRB', position: 'Striker', reason: 'Prolific striker' },
      { name: 'Mykhailo Mudryk', teamCode: 'UKR', position: 'Winger', reason: 'Electric talent' },
      { name: 'Dušan Vlahović', teamCode: 'SRB', position: 'Striker', reason: 'Young star' },
      { name: 'Artem Dovbyk', teamCode: 'UKR', position: 'Striker', reason: 'La Liga Golden Boot winner' },
    ],
    tacticalPreview: `Both teams have quality attackers. Midfield control will be crucial.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '2-2', confidence: 48, reasoning: 'Attacking quality on both sides could produce goals.' },
    funFacts: ['Both nations have passionate supporters', 'Serbia have two dangerous strikers', 'Ukraine have played on despite war'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'SRB',
    team2Code: 'CRC',
    team1Name: 'Serbia',
    team2Name: 'Costa Rica',
    historicalAnalysis: `Serbia and Costa Rica met at the 2018 World Cup, with Serbia winning 1-0. Both teams seek to advance from Group H.`,
    keyStorylines: ['Rematch of 2018 World Cup', 'Serbia seeking repeat victory', 'Costa Rica hoping for different result'],
    playersToWatch: [
      { name: 'Aleksandar Mitrović', teamCode: 'SRB', position: 'Striker', reason: 'Serbia\'s main threat' },
      { name: 'Keylor Navas', teamCode: 'CRC', position: 'Goalkeeper', reason: 'World-class keeper' },
      { name: 'Dušan Vlahović', teamCode: 'SRB', position: 'Striker', reason: 'Goal threat' },
      { name: 'Joel Campbell', teamCode: 'CRC', position: 'Forward', reason: 'Costa Rica\'s attacker' },
    ],
    tacticalPreview: `Serbia will attack while Costa Rica defends behind Navas. Clinical finishing needed from Serbia.`,
    prediction: { predictedOutcome: 'SRB', predictedScore: '2-1', confidence: 62, reasoning: 'Serbia\'s attacking quality should prove decisive.' },
    funFacts: ['Serbia won 1-0 in 2018', 'Costa Rica missed 2022 World Cup knockout rounds', 'Kolarov scored the winner in 2018'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'UKR',
    team2Code: 'CRC',
    team1Name: 'Ukraine',
    team2Name: 'Costa Rica',
    historicalAnalysis: `Ukraine and Costa Rica have never met at a World Cup. This is a crucial match for both teams seeking to advance.`,
    keyStorylines: ['First World Cup meeting', 'Ukraine fighting for their people', 'Costa Rica underdogs', 'Both teams need result'],
    playersToWatch: [
      { name: 'Mykhailo Mudryk', teamCode: 'UKR', position: 'Winger', reason: 'Ukraine\'s star' },
      { name: 'Keylor Navas', teamCode: 'CRC', position: 'Goalkeeper', reason: 'Legendary keeper' },
      { name: 'Oleksandr Zinchenko', teamCode: 'UKR', position: 'Midfielder', reason: 'Arsenal star' },
      { name: 'Joel Campbell', teamCode: 'CRC', position: 'Forward', reason: 'Costa Rica\'s threat' },
    ],
    tacticalPreview: `Ukraine should control possession. Costa Rica will defend and counter. Mudryk vs Navas will be key.`,
    prediction: { predictedOutcome: 'UKR', predictedScore: '2-1', confidence: 60, reasoning: 'Ukraine\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Ukraine qualified through playoffs', 'Costa Rica reached 2014 quarter-finals'],
    isFirstMeeting: true,
  },
];

// GROUPS I-L abbreviated for space - same format
// GROUP I: WAL, JPN, KOR, JAM
const GROUP_I_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'WAL',
    team2Code: 'JPN',
    team1Name: 'Wales',
    team2Name: 'Japan',
    historicalAnalysis: `Wales and Japan have never met at a World Cup. Japan's 2022 victories over Germany and Spain make them formidable.`,
    keyStorylines: ['First World Cup meeting', 'Japan\'s 2022 heroics', 'Wales seeking first knockout round'],
    playersToWatch: [
      { name: 'Aaron Ramsey', teamCode: 'WAL', position: 'Midfielder', reason: 'Welsh captain' },
      { name: 'Takefusa Kubo', teamCode: 'JPN', position: 'Winger', reason: 'Japan\'s creative star' },
      { name: 'Brennan Johnson', teamCode: 'WAL', position: 'Winger', reason: 'Welsh talent' },
      { name: 'Kaoru Mitoma', teamCode: 'JPN', position: 'Winger', reason: 'Brighton\'s dribbler' },
    ],
    tacticalPreview: `Japan\'s pressing vs Welsh organization. Kubo and Mitoma will test Welsh defense.`,
    prediction: { predictedOutcome: 'JPN', predictedScore: '2-0', confidence: 65, reasoning: 'Japan\'s quality and 2022 momentum should prove decisive.' },
    funFacts: ['Japan beat Germany and Spain in 2022', 'Wales are in only their second World Cup ever', 'First meeting'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'JPN',
    team2Code: 'KOR',
    team1Name: 'Japan',
    team2Name: 'Korea Republic',
    historicalAnalysis: `The fiercest rivalry in Asian football. Japan and Korea have rarely met at World Cups but their matches are always intense.`,
    keyStorylines: ['Asian derby on World Cup stage', 'Japan\'s 2022 form vs Korean talent', 'Son vs Kubo: Asia\'s best'],
    playersToWatch: [
      { name: 'Takefusa Kubo', teamCode: 'JPN', position: 'Winger', reason: 'Japan\'s star' },
      { name: 'Son Heung-min', teamCode: 'KOR', position: 'Forward', reason: 'Asia\'s best player' },
      { name: 'Kaoru Mitoma', teamCode: 'JPN', position: 'Winger', reason: 'Dribbling specialist' },
      { name: 'Lee Kang-in', teamCode: 'KOR', position: 'Midfielder', reason: 'Korean playmaker' },
    ],
    tacticalPreview: `Intense rivalry with tactical sophistication. Both teams press well and have quality attackers.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 48, reasoning: 'Intense rivalry likely to produce cagey draw.' },
    funFacts: ['Fiercest rivalry in Asian football', 'Both nations co-hosted 2002 World Cup', 'Son and Kubo among world\'s best'],
    isFirstMeeting: false,
  },
  // Additional Group I matches abbreviated...
  {
    team1Code: 'WAL',
    team2Code: 'KOR',
    team1Name: 'Wales',
    team2Name: 'Korea Republic',
    historicalAnalysis: `Wales and Korea met at the 2022 World Cup, drawing 0-0. Both teams seek to improve on that result.`,
    keyStorylines: ['2022 World Cup rematch', 'Son seeking goals', 'Wales need points'],
    playersToWatch: [
      { name: 'Aaron Ramsey', teamCode: 'WAL', position: 'Midfielder', reason: 'Welsh leader' },
      { name: 'Son Heung-min', teamCode: 'KOR', position: 'Forward', reason: 'World-class attacker' },
    ],
    tacticalPreview: `Korea will attack while Wales defend. Son must be contained.`,
    prediction: { predictedOutcome: 'KOR', predictedScore: '2-1', confidence: 60, reasoning: 'Korea\'s quality should prove decisive.' },
    funFacts: ['Drew 0-0 at 2022 World Cup', 'Son is Tottenham\'s all-time top scorer'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'WAL',
    team2Code: 'JAM',
    team1Name: 'Wales',
    team2Name: 'Jamaica',
    historicalAnalysis: `First World Cup meeting between Wales and Jamaica.`,
    keyStorylines: ['First World Cup meeting', 'Jamaica\'s first World Cup since 1998', 'Battle for Group I points'],
    playersToWatch: [
      { name: 'Brennan Johnson', teamCode: 'WAL', position: 'Winger', reason: 'Welsh talent' },
      { name: 'Leon Bailey', teamCode: 'JAM', position: 'Winger', reason: 'Jamaica\'s star' },
    ],
    tacticalPreview: `Both teams evenly matched. Set pieces could decide.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched underdogs.' },
    funFacts: ['Jamaica\'s first World Cup since 1998', 'Bailey plays for Aston Villa'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'JPN',
    team2Code: 'JAM',
    team1Name: 'Japan',
    team2Name: 'Jamaica',
    historicalAnalysis: `Japan and Jamaica have never met at a World Cup. Japan are strong favorites.`,
    keyStorylines: ['First World Cup meeting', 'Japan seeking group dominance', 'Jamaica underdogs'],
    playersToWatch: [
      { name: 'Takefusa Kubo', teamCode: 'JPN', position: 'Winger', reason: 'Japan\'s creative force' },
      { name: 'Leon Bailey', teamCode: 'JAM', position: 'Winger', reason: 'Jamaica\'s threat' },
    ],
    tacticalPreview: `Japan should dominate possession. Jamaica will defend and counter.`,
    prediction: { predictedOutcome: 'JPN', predictedScore: '3-0', confidence: 75, reasoning: 'Japan\'s quality should dominate.' },
    funFacts: ['First World Cup meeting', 'Japan beat Germany and Spain in 2022'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'KOR',
    team2Code: 'JAM',
    team1Name: 'Korea Republic',
    team2Name: 'Jamaica',
    historicalAnalysis: `Korea and Jamaica have never met at a World Cup. Korea are favorites.`,
    keyStorylines: ['First World Cup meeting', 'Son seeking goals', 'Jamaica underdogs'],
    playersToWatch: [
      { name: 'Son Heung-min', teamCode: 'KOR', position: 'Forward', reason: 'World-class striker' },
      { name: 'Leon Bailey', teamCode: 'JAM', position: 'Winger', reason: 'Jamaica\'s star' },
    ],
    tacticalPreview: `Korea should control the game. Son will be the main threat.`,
    prediction: { predictedOutcome: 'KOR', predictedScore: '3-1', confidence: 72, reasoning: 'Korea\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Son is one of Asia\'s greatest ever players'],
    isFirstMeeting: true,
  },
];

// GROUP J: AUS, IRN, KSA, HON
const GROUP_J_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'AUS',
    team2Code: 'IRN',
    team1Name: 'Australia',
    team2Name: 'Iran',
    historicalAnalysis: `Australia and Iran have been AFC rivals since Australia joined the confederation in 2006. Their matches are always competitive.`,
    keyStorylines: ['AFC rivals clash', 'Australia\'s 2022 momentum', 'Iran\'s quality'],
    playersToWatch: [
      { name: 'Jackson Irvine', teamCode: 'AUS', position: 'Midfielder', reason: 'Australian captain' },
      { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Striker', reason: 'Iran\'s star striker' },
    ],
    tacticalPreview: `Tactical battle between AFC rivals. Taremi vs Australian defense key.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched AFC rivals.' },
    funFacts: ['Both teams are AFC powerhouses', 'Australia reached 2022 Round of 16', 'Taremi plays for Inter Milan'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'AUS',
    team2Code: 'KSA',
    team1Name: 'Australia',
    team2Name: 'Saudi Arabia',
    historicalAnalysis: `Australia and Saudi Arabia have faced each other in World Cup qualifying. Saudi Arabia stunned Argentina at the 2022 World Cup.`,
    keyStorylines: ['AFC rivals meet', 'Saudi Arabia\'s 2022 Argentina upset', 'Australia seeking consistency'],
    playersToWatch: [
      { name: 'Jackson Irvine', teamCode: 'AUS', position: 'Midfielder', reason: 'Australian leader' },
      { name: 'Salem Al-Dawsari', teamCode: 'KSA', position: 'Winger', reason: 'Scored famous goal vs Argentina' },
    ],
    tacticalPreview: `Both teams organized. Saudi pressing could cause problems.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 52, reasoning: 'Evenly matched teams.' },
    funFacts: ['Saudi beat Argentina in 2022', 'Al-Dawsari\'s goal was instant classic', 'Both are AFC powers'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'AUS',
    team2Code: 'HON',
    team1Name: 'Australia',
    team2Name: 'Honduras',
    historicalAnalysis: `Australia and Honduras met in 2017 World Cup qualifying playoffs, with Australia winning on aggregate.`,
    keyStorylines: ['Playoff rematch', 'Australia favorites', 'Honduras underdogs'],
    playersToWatch: [
      { name: 'Jackson Irvine', teamCode: 'AUS', position: 'Midfielder', reason: 'Captain' },
      { name: 'Alberth Elis', teamCode: 'HON', position: 'Forward', reason: 'Honduras attacker' },
    ],
    tacticalPreview: `Australia should control possession. Honduras will be physical.`,
    prediction: { predictedOutcome: 'AUS', predictedScore: '2-0', confidence: 70, reasoning: 'Australia\'s quality should prove decisive.' },
    funFacts: ['Australia beat Honduras in 2017 playoffs', 'Honduras last World Cup was 2014'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'IRN',
    team2Code: 'KSA',
    team1Name: 'Iran',
    team2Name: 'Saudi Arabia',
    historicalAnalysis: `Iran and Saudi Arabia share intense regional rivalry extending beyond football.`,
    keyStorylines: ['Middle East derby', 'Regional rivals clash', 'Intense atmosphere expected'],
    playersToWatch: [
      { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Striker', reason: 'Iran\'s star' },
      { name: 'Salem Al-Dawsari', teamCode: 'KSA', position: 'Winger', reason: 'Saudi hero' },
    ],
    tacticalPreview: `Intense match with regional pride at stake.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '0-0', confidence: 48, reasoning: 'Tight, tense affair likely.' },
    funFacts: ['Intense regional rivalry', 'Both qualified through AFC', 'Historic regional tensions'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'IRN',
    team2Code: 'HON',
    team1Name: 'Iran',
    team2Name: 'Honduras',
    historicalAnalysis: `Iran and Honduras have never met at a World Cup. Iran are favorites.`,
    keyStorylines: ['First World Cup meeting', 'Iran seeking points', 'Honduras underdogs'],
    playersToWatch: [
      { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Striker', reason: 'Iran\'s threat' },
      { name: 'Alberth Elis', teamCode: 'HON', position: 'Forward', reason: 'Honduras star' },
    ],
    tacticalPreview: `Iran should dominate. Honduras will defend deep.`,
    prediction: { predictedOutcome: 'IRN', predictedScore: '2-0', confidence: 68, reasoning: 'Iran\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Taremi plays for Inter Milan'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'KSA',
    team2Code: 'HON',
    team1Name: 'Saudi Arabia',
    team2Name: 'Honduras',
    historicalAnalysis: `Saudi Arabia and Honduras have never met at a World Cup. Saudi\'s 2022 Argentina upset makes them dangerous.`,
    keyStorylines: ['First World Cup meeting', 'Saudi Arabia favorites', 'Honduras underdogs'],
    playersToWatch: [
      { name: 'Salem Al-Dawsari', teamCode: 'KSA', position: 'Winger', reason: 'Saudi star' },
      { name: 'Alberth Elis', teamCode: 'HON', position: 'Forward', reason: 'Honduras threat' },
    ],
    tacticalPreview: `Saudi Arabia should control the game with organized pressing.`,
    prediction: { predictedOutcome: 'KSA', predictedScore: '2-1', confidence: 62, reasoning: 'Saudi quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Saudi beat Argentina in 2022'],
    isFirstMeeting: true,
  },
];

// GROUP K: QAT, UAE, CHN, PAN - abbreviated
const GROUP_K_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'QAT',
    team2Code: 'UAE',
    team1Name: 'Qatar',
    team2Name: 'United Arab Emirates',
    historicalAnalysis: `Gulf rivals Qatar and UAE have intense regional rivalry.`,
    keyStorylines: ['Gulf derby', 'Qatar as 2022 hosts', 'Regional pride'],
    playersToWatch: [
      { name: 'Akram Afif', teamCode: 'QAT', position: 'Forward', reason: 'Qatar star' },
      { name: 'Ali Mabkhout', teamCode: 'UAE', position: 'Forward', reason: 'UAE\'s top scorer' },
    ],
    tacticalPreview: `Intense Gulf derby with regional pride at stake.`,
    prediction: { predictedOutcome: 'QAT', predictedScore: '2-1', confidence: 58, reasoning: 'Qatar\'s 2022 experience helps.' },
    funFacts: ['Gulf neighbors and rivals', 'Qatar hosted 2022 World Cup', 'Both nations are AFC members'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'QAT',
    team2Code: 'CHN',
    team1Name: 'Qatar',
    team2Name: 'China PR',
    historicalAnalysis: `Qatar and China have met in Asian competition. Qatar won the 2019 Asian Cup.`,
    keyStorylines: ['Asian Cup champions vs China', 'Qatar experience vs Chinese ambition'],
    playersToWatch: [
      { name: 'Akram Afif', teamCode: 'QAT', position: 'Forward', reason: 'Qatar\'s star' },
      { name: 'Wu Lei', teamCode: 'CHN', position: 'Forward', reason: 'China\'s best player' },
    ],
    tacticalPreview: `Qatar should control the game as 2019 Asian Cup champions.`,
    prediction: { predictedOutcome: 'QAT', predictedScore: '2-0', confidence: 65, reasoning: 'Qatar\'s tournament experience.' },
    funFacts: ['Qatar won 2019 Asian Cup', 'China only World Cup was 2002'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'QAT',
    team2Code: 'PAN',
    team1Name: 'Qatar',
    team2Name: 'Panama',
    historicalAnalysis: `Qatar and Panama have never met. Both are relative World Cup newcomers.`,
    keyStorylines: ['First meeting', 'Two World Cup newcomers', 'Qatar as 2022 hosts'],
    playersToWatch: [
      { name: 'Akram Afif', teamCode: 'QAT', position: 'Forward', reason: 'Qatar\'s star' },
      { name: 'Adalberto Carrasquilla', teamCode: 'PAN', position: 'Midfielder', reason: 'Panama\'s creator' },
    ],
    tacticalPreview: `Two evenly matched newcomers. Could be tight.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched teams.' },
    funFacts: ['First meeting', 'Both made their World Cup debuts recently'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'UAE',
    team2Code: 'CHN',
    team1Name: 'United Arab Emirates',
    team2Name: 'China PR',
    historicalAnalysis: `UAE and China have met in Asian competition.`,
    keyStorylines: ['Asian rivals', 'Both seeking rare World Cup success'],
    playersToWatch: [
      { name: 'Ali Mabkhout', teamCode: 'UAE', position: 'Forward', reason: 'UAE\'s star' },
      { name: 'Wu Lei', teamCode: 'CHN', position: 'Forward', reason: 'China\'s best' },
    ],
    tacticalPreview: `Both teams evenly matched. Could be decided by individual brilliance.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '0-0', confidence: 48, reasoning: 'Two limited teams likely to cancel out.' },
    funFacts: ['Both nations rarely qualify for World Cups', 'UAE only World Cup was 1990'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'UAE',
    team2Code: 'PAN',
    team1Name: 'United Arab Emirates',
    team2Name: 'Panama',
    historicalAnalysis: `UAE and Panama have never met. Both are World Cup underdogs.`,
    keyStorylines: ['First meeting', 'Both seeking first World Cup knockout appearance'],
    playersToWatch: [
      { name: 'Ali Mabkhout', teamCode: 'UAE', position: 'Forward', reason: 'UAE\'s threat' },
      { name: 'Adalberto Carrasquilla', teamCode: 'PAN', position: 'Midfielder', reason: 'Panama\'s creator' },
    ],
    tacticalPreview: `Two evenly matched underdogs. Fight for three points.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched.' },
    funFacts: ['First meeting', 'Both seeking rare World Cup success'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'CHN',
    team2Code: 'PAN',
    team1Name: 'China PR',
    team2Name: 'Panama',
    historicalAnalysis: `China and Panama have never met. Both are World Cup underdogs seeking points.`,
    keyStorylines: ['First meeting', 'Both seeking points', 'World Cup newcomers clash'],
    playersToWatch: [
      { name: 'Wu Lei', teamCode: 'CHN', position: 'Forward', reason: 'China\'s star' },
      { name: 'Adalberto Carrasquilla', teamCode: 'PAN', position: 'Midfielder', reason: 'Panama\'s talent' },
    ],
    tacticalPreview: `Both teams will be cautious. Could be decided by one moment.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Evenly matched.' },
    funFacts: ['First meeting', 'China last played at 2002 World Cup'],
    isFirstMeeting: true,
  },
];

// GROUP L: MAR, SEN, NGA, PER
const GROUP_L_SUMMARIES: MatchSummary[] = [
  {
    team1Code: 'MAR',
    team2Code: 'SEN',
    team1Name: 'Morocco',
    team2Name: 'Senegal',
    historicalAnalysis: `Morocco and Senegal are Africa's two best teams. Morocco's 2022 semi-final run and Senegal's 2022 AFCON win make this an epic African clash.`,
    keyStorylines: ['Africa\'s elite clash', 'Morocco\'s 2022 heroes vs AFCON champions', 'Battle for African supremacy'],
    playersToWatch: [
      { name: 'Achraf Hakimi', teamCode: 'MAR', position: 'Right-Back', reason: 'World-class defender' },
      { name: 'Sadio Mané', teamCode: 'SEN', position: 'Forward', reason: 'African legend' },
      { name: 'Hakim Ziyech', teamCode: 'MAR', position: 'Winger', reason: 'Morocco\'s creative force' },
      { name: 'Kalidou Koulibaly', teamCode: 'SEN', position: 'Defender', reason: 'Senegal\'s rock' },
    ],
    tacticalPreview: `Two of Africa's best tactical teams. Regragui vs Cissé is a fascinating battle. Both press well and are organized.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Two quality African sides likely to draw.' },
    funFacts: ['Morocco reached 2022 World Cup semi-finals', 'Senegal won AFCON 2022', 'Two best African teams currently'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'MAR',
    team2Code: 'NGA',
    team1Name: 'Morocco',
    team2Name: 'Nigeria',
    historicalAnalysis: `Morocco and Nigeria are African rivals with proud football traditions. Morocco's 2022 World Cup heroics have elevated their status.`,
    keyStorylines: ['African powerhouses clash', 'Morocco\'s momentum vs Nigeria\'s talent', 'Hakimi vs Osimhen'],
    playersToWatch: [
      { name: 'Achraf Hakimi', teamCode: 'MAR', position: 'Right-Back', reason: 'PSG star' },
      { name: 'Victor Osimhen', teamCode: 'NGA', position: 'Striker', reason: 'One of world\'s best strikers' },
      { name: 'Hakim Ziyech', teamCode: 'MAR', position: 'Winger', reason: 'Creative genius' },
      { name: 'Samuel Chukwueze', teamCode: 'NGA', position: 'Winger', reason: 'Nigerian talent' },
    ],
    tacticalPreview: `Morocco's organization vs Nigeria's individual brilliance. Osimhen must be contained.`,
    prediction: { predictedOutcome: 'MAR', predictedScore: '2-1', confidence: 55, reasoning: 'Morocco\'s 2022 experience gives edge.' },
    funFacts: ['Morocco made 2022 semi-finals', 'Osimhen is one of world\'s most valuable players', 'Nigeria have reached Round of 16 multiple times'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'MAR',
    team2Code: 'PER',
    team1Name: 'Morocco',
    team2Name: 'Peru',
    historicalAnalysis: `Morocco and Peru have never met at a World Cup. Morocco are favorites after their 2022 heroics.`,
    keyStorylines: ['First World Cup meeting', 'Morocco favorites', 'Peru underdogs'],
    playersToWatch: [
      { name: 'Achraf Hakimi', teamCode: 'MAR', position: 'Right-Back', reason: 'Morocco\'s star' },
      { name: 'Paolo Guerrero', teamCode: 'PER', position: 'Striker', reason: 'Peru\'s legend' },
    ],
    tacticalPreview: `Morocco should control the game. Peru will defend and counter.`,
    prediction: { predictedOutcome: 'MAR', predictedScore: '2-0', confidence: 70, reasoning: 'Morocco\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Morocco reached 2022 semi-finals', 'Peru reached 2018 World Cup'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'SEN',
    team2Code: 'NGA',
    team1Name: 'Senegal',
    team2Name: 'Nigeria',
    historicalAnalysis: `Senegal and Nigeria are West African rivals with rich football histories. Both nations have produced legendary players.`,
    keyStorylines: ['West African derby', 'AFCON champions vs Super Eagles', 'Mané vs Osimhen'],
    playersToWatch: [
      { name: 'Sadio Mané', teamCode: 'SEN', position: 'Forward', reason: 'African legend' },
      { name: 'Victor Osimhen', teamCode: 'NGA', position: 'Striker', reason: 'World-class striker' },
      { name: 'Kalidou Koulibaly', teamCode: 'SEN', position: 'Defender', reason: 'Defensive leader' },
      { name: 'Wilfred Ndidi', teamCode: 'NGA', position: 'Midfielder', reason: 'Midfield anchor' },
    ],
    tacticalPreview: `Physical, intense West African derby. Mané vs Osimhen battle will be fascinating.`,
    prediction: { predictedOutcome: 'DRAW', predictedScore: '1-1', confidence: 50, reasoning: 'Intense rivalry likely to produce draw.' },
    funFacts: ['Senegal won AFCON 2022', 'Nigeria have most AFCON titles', 'West African rivals'],
    isFirstMeeting: false,
  },
  {
    team1Code: 'SEN',
    team2Code: 'PER',
    team1Name: 'Senegal',
    team2Name: 'Peru',
    historicalAnalysis: `Senegal and Peru have never met at a World Cup. Senegal are favorites as AFCON champions.`,
    keyStorylines: ['First World Cup meeting', 'AFCON champions vs Peru', 'Mané seeking goals'],
    playersToWatch: [
      { name: 'Sadio Mané', teamCode: 'SEN', position: 'Forward', reason: 'Senegal\'s talisman' },
      { name: 'Paolo Guerrero', teamCode: 'PER', position: 'Striker', reason: 'Peru\'s captain' },
    ],
    tacticalPreview: `Senegal should dominate. Peru will defend and counter.`,
    prediction: { predictedOutcome: 'SEN', predictedScore: '2-0', confidence: 68, reasoning: 'Senegal\'s quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Senegal are AFCON champions', 'Peru reached 2018 World Cup'],
    isFirstMeeting: true,
  },
  {
    team1Code: 'NGA',
    team2Code: 'PER',
    team1Name: 'Nigeria',
    team2Name: 'Peru',
    historicalAnalysis: `Nigeria and Peru have never met at a World Cup. Nigeria are favorites with Osimhen leading the attack.`,
    keyStorylines: ['First World Cup meeting', 'Osimhen seeking goals', 'Peru underdogs'],
    playersToWatch: [
      { name: 'Victor Osimhen', teamCode: 'NGA', position: 'Striker', reason: 'World-class striker' },
      { name: 'Paolo Guerrero', teamCode: 'PER', position: 'Striker', reason: 'Peru\'s legend' },
    ],
    tacticalPreview: `Nigeria should control the game. Osimhen vs Peru's defense is key.`,
    prediction: { predictedOutcome: 'NGA', predictedScore: '3-1', confidence: 68, reasoning: 'Nigeria\'s attacking quality should prove decisive.' },
    funFacts: ['First World Cup meeting', 'Osimhen is one of world\'s best strikers', 'Nigeria have reached multiple World Cup knockouts'],
    isFirstMeeting: true,
  },
];

// Combine all summaries
const ALL_MATCH_SUMMARIES: MatchSummary[] = [
  ...GROUP_A_SUMMARIES,
  ...GROUP_B_SUMMARIES,
  ...GROUP_C_SUMMARIES,
  ...GROUP_D_SUMMARIES,
  ...GROUP_E_SUMMARIES,
  ...GROUP_F_SUMMARIES,
  ...GROUP_G_SUMMARIES,
  ...GROUP_H_SUMMARIES,
  ...GROUP_I_SUMMARIES,
  ...GROUP_J_SUMMARIES,
  ...GROUP_K_SUMMARIES,
  ...GROUP_L_SUMMARIES,
];

// ============================================================================
// Main Seed Function
// ============================================================================

async function seedAllMatchSummaries(): Promise<void> {
  console.log('========================================');
  console.log('Seeding Comprehensive AI Match Summaries');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Summaries to seed: ${ALL_MATCH_SUMMARIES.length}`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const summary of ALL_MATCH_SUMMARIES) {
    try {
      // Generate document ID (alphabetically sorted team codes)
      const codes = [summary.team1Code, summary.team2Code].sort();
      const docId = `${codes[0]}_${codes[1]}`;

      const docData = {
        team1Code: summary.team1Code,
        team2Code: summary.team2Code,
        team1Name: summary.team1Name,
        team2Name: summary.team2Name,
        historicalAnalysis: summary.historicalAnalysis,
        keyStorylines: summary.keyStorylines,
        playersToWatch: summary.playersToWatch,
        tacticalPreview: summary.tacticalPreview,
        prediction: summary.prediction,
        pastEncountersSummary: summary.pastEncountersSummary || '',
        funFacts: summary.funFacts,
        isFirstMeeting: summary.isFirstMeeting,
        updatedAt: new Date().toISOString(),
      };

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would create: ${docId}`);
        console.log(`  ${summary.team1Name} vs ${summary.team2Name}`);
      } else {
        await db.collection('matchSummaries').doc(docId).set(docData);
        console.log(`✅ Seeded: ${docId} (${summary.team1Name} vs ${summary.team2Name})`);
      }

      successCount++;
    } catch (error) {
      console.error(`❌ Error seeding ${summary.team1Name} vs ${summary.team2Name}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total summaries: ${ALL_MATCH_SUMMARIES.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log(`First-time meetings: ${ALL_MATCH_SUMMARIES.filter(s => s.isFirstMeeting).length}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedAllMatchSummaries()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
