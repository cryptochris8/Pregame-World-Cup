/**
 * Seed AI Match Summaries for June 2026 World Cup Matchups
 *
 * This script generates comprehensive match summaries including:
 * - Historical analysis
 * - Key storylines
 * - Players to watch
 * - Tactical preview
 * - AI predictions
 *
 * Usage:
 *   npx ts-node src/seed-match-summaries.ts [--dryRun]
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
// June 2026 Match Summaries
// ============================================================================

const MATCH_SUMMARIES: MatchSummary[] = [
  // ========== CROATIA vs ENGLAND ==========
  {
    team1Code: 'CRO',
    team2Code: 'ENG',
    team1Name: 'Croatia',
    team2Name: 'England',
    historicalAnalysis: `The rivalry between Croatia and England carries the weight of one of the most dramatic World Cup encounters in recent memory. These two nations have met 10 times, with honors remarkably even at 4 wins apiece and 2 draws. However, the narrative is dominated by that unforgettable night in Moscow during the 2018 World Cup semi-final, when Mario Mandžukić's extra-time winner sent Croatia to their first-ever World Cup final, breaking English hearts in the process.

That 2-1 Croatian victory remains a pivotal moment for both nations. For Croatia, it validated their "golden generation" and proved that a nation of just 4 million could reach football's ultimate stage. For England, it extended their trophy drought and left lingering questions about their ability to perform when it matters most. The redemption storyline adds considerable intrigue to this 2026 encounter.

England gained some measure of revenge at Euro 2020, where Raheem Sterling's goal secured a 1-0 victory at Wembley in the group stage. That result showed England's evolution under Gareth Southgate, though the squad has undergone significant changes since then. Croatia, meanwhile, finished third at the 2022 World Cup, demonstrating their continued quality despite an aging core.`,
    keyStorylines: [
      'Revenge mission: England seeking to exorcise 2018 World Cup semi-final demons',
      'Croatia\'s aging golden generation vs England\'s new wave of talent',
      'Luka Modrić potentially playing his final World Cup at age 40',
      'First World Cup meeting since the 2018 semi-final heartbreak',
    ],
    playersToWatch: [
      {
        name: 'Jude Bellingham',
        teamCode: 'ENG',
        position: 'Midfielder',
        reason: 'England\'s talisman and Ballon d\'Or contender who will orchestrate attacks',
      },
      {
        name: 'Luka Modrić',
        teamCode: 'CRO',
        position: 'Midfielder',
        reason: 'The 40-year-old maestro seeking one last World Cup glory in his farewell tournament',
      },
      {
        name: 'Harry Kane',
        teamCode: 'ENG',
        position: 'Forward',
        reason: 'England\'s all-time leading scorer hunting World Cup redemption',
      },
      {
        name: 'Joško Gvardiol',
        teamCode: 'CRO',
        position: 'Defender',
        reason: 'World-class defender who must neutralize England\'s attacking threats',
      },
    ],
    tacticalPreview: `This matchup features two of Europe's most tactically sophisticated sides. England under their new manager will likely employ a possession-based 4-3-3 system, with Bellingham operating as the creative hub. Croatia's 4-3-3 remains built around midfield control, though questions persist about their aging midfield trio's ability to dominate as they once did.

The key battle will be in central midfield. If Modrić, Kovačić, and Brozović can control tempo as they did in 2018, Croatia can frustrate England. However, England's pressing intensity and athletic superiority could overwhelm Croatia if the game opens up. Expect a cagey, chess-like encounter where the first goal will be crucial.`,
    prediction: {
      predictedOutcome: 'ENG',
      predictedScore: '2-1',
      confidence: 58,
      reasoning: 'England\'s squad depth, younger legs, and home continent advantage give them a slight edge. However, Croatia\'s big-game experience and tournament pedigree make this extremely close. The psychological factor of 2018 could motivate England while potentially adding pressure.',
      alternativeScenario: 'If Croatia control midfield and take an early lead, their experience in knockout situations could see them through. A 1-0 or 2-1 Croatia victory is entirely plausible.',
    },
    pastEncountersSummary: 'Their 10 meetings have produced drama at every turn. The 2018 semi-final (2-1 to Croatia) overshadows all else, but Croatia also dealt England a devastating blow in 2007 when a 2-0 victory in Zagreb contributed to England missing Euro 2008. England\'s Euro 2020 revenge (1-0) showed they can beat Croatia when it counts.',
    funFacts: [
      'Croatia\'s 2018 semi-final win was their first-ever victory over England',
      'Both nations have never won the World Cup despite reaching finals (Croatia 2018, England 1966 as hosts)',
      'This will be the first World Cup meeting between these sides since that fateful 2018 semi-final',
      'Modrić was named player of the match in the 2018 semi-final victory',
    ],
    isFirstMeeting: false,
  },

  // ========== FRANCE vs SENEGAL ==========
  {
    team1Code: 'FRA',
    team2Code: 'SEN',
    team1Name: 'France',
    team2Name: 'Senegal',
    historicalAnalysis: `Few World Cup matches have produced a more stunning upset than the opening game of the 2002 World Cup in South Korea. Defending champions France, boasting icons like Zinedine Zidane, Thierry Henry, and Patrick Vieira, were expected to cruise past debutants Senegal. Instead, Papa Bouba Diop's 30th-minute goal, and his iconic corner flag celebration, announced Africa's arrival on the world stage in unforgettable fashion.

That 1-0 Senegalese victory sent shockwaves through global football. France would go on to exit the tournament without scoring a single goal, while Senegal reached the quarter-finals in their maiden World Cup appearance. The result remains one of the greatest upsets in World Cup history and established a narrative that persists to this day: never underestimate the Lions of Teranga.

Since then, France have won two World Cups (2018, with a 2022 final loss), cementing their status as the dominant force in world football. Senegal, meanwhile, won their first Africa Cup of Nations in 2022, proving their 2002 heroics were no fluke. This 2026 rematch carries the weight of that history while writing a new chapter.`,
    keyStorylines: [
      'Echoes of 2002: Can Senegal produce another shocking upset against the champions?',
      'France seeking World Cup redemption after 2022 final heartbreak',
      'Senegal as African champions looking to prove continental dominance translates globally',
      'The colonial history and cultural ties between France and Senegal add unique context',
    ],
    playersToWatch: [
      {
        name: 'Kylian Mbappé',
        teamCode: 'FRA',
        position: 'Forward',
        reason: 'The world\'s best player and France\'s captain seeking to lead Les Bleus to glory',
      },
      {
        name: 'Sadio Mané',
        teamCode: 'SEN',
        position: 'Forward',
        reason: 'Senegal\'s talisman who led them to AFCON glory in 2022',
      },
      {
        name: 'Aurélien Tchouaméni',
        teamCode: 'FRA',
        position: 'Midfielder',
        reason: 'France\'s new midfield general who must control the tempo',
      },
      {
        name: 'Kalidou Koulibaly',
        teamCode: 'SEN',
        position: 'Defender',
        reason: 'Experienced center-back tasked with containing Mbappé',
      },
    ],
    tacticalPreview: `France's 4-3-3 system maximizes Mbappé's devastating pace and movement, supported by world-class midfielders. Senegal under Aliou Cissé will likely adopt a pragmatic 4-4-2, prioritizing defensive solidity while looking to exploit transitions.

The key for Senegal is to avoid being overrun in midfield while staying compact enough to limit spaces for Mbappé. If they can take their chances on the counter and frustrate France early, the ghosts of 2002 could begin to haunt Les Bleus. France must be patient and clinical, avoiding the complacency that cost them in Seoul.`,
    prediction: {
      predictedOutcome: 'FRA',
      predictedScore: '2-0',
      confidence: 72,
      reasoning: 'France\'s superior squad depth and individual quality should prevail. Mbappé is at his peak, and France\'s 2022 final experience will drive them. However, Senegal\'s AFCON-winning mentality and physical prowess make them dangerous.',
      alternativeScenario: 'If Senegal score first and absorb pressure effectively, a repeat of 2002 is possible. A disciplined 1-0 Senegalese victory would shake the tournament.',
    },
    pastEncountersSummary: 'Four meetings, but none more significant than June 2002. That Papa Bouba Diop goal against the reigning world champions remains etched in World Cup folklore. France have since won 2 of 4 encounters, but the psychological impact of 2002 lingers.',
    funFacts: [
      'Senegal\'s 2002 win came in their first-ever World Cup match as a nation',
      'France went winless in 2002 (0W-1D-2L) and failed to score a single goal',
      'Papa Bouba Diop\'s celebration hiding under the corner flag became iconic',
      'Many Senegalese players in 2002 played in the French league, knowing their opponents intimately',
    ],
    isFirstMeeting: false,
  },

  // ========== BRAZIL vs MOROCCO ==========
  {
    team1Code: 'BRA',
    team2Code: 'MAR',
    team1Name: 'Brazil',
    team2Name: 'Morocco',
    historicalAnalysis: `Brazil and Morocco's rivalry has been transformed by Morocco's stunning 2022 World Cup run to the semi-finals, the first African nation to achieve this feat. Their three meetings tell a story of evolving African football. In 1998, Brazil dominated 3-0 in the group stage, with Rivaldo and Ronaldo showcasing the Seleção's attacking brilliance. The encounter seemed routine—a powerhouse dispatching an African underdog.

Fast forward to March 2023, and the landscape had shifted dramatically. Just months after Morocco had knocked out Spain and Portugal en route to the semi-finals, they hosted Brazil in Tangier and won 2-1. It was a statement victory that confirmed Morocco's 2022 success was no fluke. The Atlas Lions had arrived as a genuine force in world football.

This World Cup 2026 encounter carries enormous weight. Brazil, five-time world champions but without a title since 2002, face a Morocco side brimming with confidence and quality. The dynamics have fundamentally changed since their last World Cup meeting.`,
    keyStorylines: [
      'Morocco\'s 2022 World Cup fairy tale vs Brazil\'s quest to end their title drought',
      'Can Morocco replicate their 2023 friendly upset on the World Cup stage?',
      'Brazil\'s young core seeking to restore the Seleção to their former glory',
      'Morocco as flag-bearers for African football after historic 2022 run',
    ],
    playersToWatch: [
      {
        name: 'Vinícius Jr.',
        teamCode: 'BRA',
        position: 'Winger',
        reason: 'Brazil\'s most electrifying player and potential Ballon d\'Or winner',
      },
      {
        name: 'Achraf Hakimi',
        teamCode: 'MAR',
        position: 'Right-Back',
        reason: 'Dynamic wing-back who terrorizes opponents and scored the winning penalty vs Spain in 2022',
      },
      {
        name: 'Rodrygo',
        teamCode: 'BRA',
        position: 'Forward',
        reason: 'Real Madrid star adding creativity and goals to Brazil\'s attack',
      },
      {
        name: 'Yassine Bounou',
        teamCode: 'MAR',
        position: 'Goalkeeper',
        reason: 'Hero of 2022 whose penalty saves helped Morocco make history',
      },
    ],
    tacticalPreview: `Brazil under their current setup favor an attacking 4-2-3-1 built around Vinícius Jr.'s dribbling and Rodrygo's movement. Morocco's 4-3-3 under Walid Regragui is defensively organized but devastatingly quick in transition, as Spain and Portugal discovered in 2022.

Morocco's key is to frustrate Brazil and hit them on the break. Their defensive organization in 2022 was exceptional, conceding just one goal before the semi-final. Brazil must be patient, moving the ball quickly to create gaps. The match could be decided by a moment of individual brilliance from either side.`,
    prediction: {
      predictedOutcome: 'BRA',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'Brazil\'s attacking quality gives them a narrow edge, but Morocco\'s 2022 pedigree and 2023 victory make this extremely tight. Brazil\'s experience and squad depth could prove decisive, but expect Morocco to make them work for it.',
      alternativeScenario: 'Morocco\'s organized defense and counter-attacking threat could produce a stunning 1-0 or 2-1 upset. A repeat of their 2023 friendly victory is entirely feasible.',
    },
    pastEncountersSummary: 'Three meetings have produced three different outcomes. Brazil\'s dominant 3-0 in 1998 established their superiority, but Morocco\'s 2023 friendly win (2-1) flipped the narrative. The 2026 World Cup encounter will determine whether Morocco\'s rise is truly complete.',
    funFacts: [
      'Morocco became the first African nation to reach a World Cup semi-final in 2022',
      'Brazil haven\'t won the World Cup since 2002 - their longest drought ever',
      'Morocco\'s 2022 run included zero goals conceded in open play until the semi-final',
      'Achraf Hakimi scored a Panenka penalty to eliminate Spain in 2022',
    ],
    isFirstMeeting: false,
  },

  // ========== BRAZIL vs SCOTLAND ==========
  {
    team1Code: 'BRA',
    team2Code: 'SCO',
    team1Name: 'Brazil',
    team2Name: 'Scotland',
    historicalAnalysis: `Brazil and Scotland share a unique World Cup history, having met four times on football's greatest stage. Their encounters span the beautiful game's evolution, from the attacking renaissance of 1974 to the global spectacle of France 1998. Scotland have never beaten Brazil, but they've produced moments of extraordinary defiance against the Seleção.

The legendary 0-0 draw in Frankfurt at the 1974 World Cup stands as Scotland's finest hour against Brazil. In an era when Jairzinho, Rivelino, and the remnants of the 1970 champions roamed, Scotland held firm. It remains the only World Cup match Brazil failed to win that year before their elimination.

However, it's the 1998 World Cup opener in Paris that defines this fixture for modern fans. With 500 million viewers watching the tournament's curtain-raiser, Brazil won 2-1 despite Scotland's spirited resistance. John Collins's penalty gave Scotland hope, but Tom Boyd's own goal sealed Brazil's victory. That match, played at the Stade de France, launched the tournament that would end with France lifting the trophy after shocking Brazil 3-0 in the final.`,
    keyStorylines: [
      'Scotland\'s long-awaited return to the World Cup stage against the five-time champions',
      'Can Scotland channel their 1974 Frankfurt heroics and frustrate Brazil again?',
      'Brazil determined to avoid another group stage shock after 2022 disappointment',
      'Steve Clarke\'s Tartan Army looking to prove they belong among elite nations',
    ],
    playersToWatch: [
      {
        name: 'Vinícius Jr.',
        teamCode: 'BRA',
        position: 'Winger',
        reason: 'Brazil\'s match-winner whose skills can unlock any defense',
      },
      {
        name: 'John McGinn',
        teamCode: 'SCO',
        position: 'Midfielder',
        reason: 'Scotland\'s heartbeat who brings energy, goals, and leadership',
      },
      {
        name: 'Endrick',
        teamCode: 'BRA',
        position: 'Forward',
        reason: 'Teenage sensation making his World Cup debut',
      },
      {
        name: 'Billy Gilmour',
        teamCode: 'SCO',
        position: 'Midfielder',
        reason: 'Technically gifted playmaker who could dictate tempo against Brazil',
      },
    ],
    tacticalPreview: `Scotland's best chance lies in defensive organization and set-pieces. Steve Clarke's pragmatic 3-5-2 system emphasizes compactness and discipline, hoping to frustrate Brazil before striking on the break or from corners.

Brazil will dominate possession and territory, but Scotland's physicality and aerial threat could be problematic. The key for Scotland is to stay in the game beyond 60 minutes; Brazil's attacking quality typically tells in the final quarter. A repeat of 1974's 0-0 would be celebrated as a famous result in Scottish football history.`,
    prediction: {
      predictedOutcome: 'BRA',
      predictedScore: '3-1',
      confidence: 78,
      reasoning: 'Brazil\'s quality advantage is significant. Scotland lack the firepower to consistently threaten, and Brazil\'s attacking depth should prove decisive. However, Scotland\'s organization could keep the score respectable.',
      alternativeScenario: 'If Scotland score first from a set-piece and park the bus effectively, a shock draw is possible. Their fans would consider it equivalent to victory.',
    },
    pastEncountersSummary: 'Four World Cup meetings (1974, 1982, 1990, 1998) have produced three Brazil wins and one draw. That 1974 0-0 remains Scotland\'s proudest moment, while the 1982 encounter saw David Narey score a famous goal (later dubbed the "toe-poke") before Brazil responded with a 4-1 masterclass featuring Zico and Falcão.',
    funFacts: [
      'Scotland\'s 1974 squad remains the only team never to lose a match at a World Cup yet still get eliminated',
      'David Narey\'s 1982 goal against Brazil is still shown in Scottish football highlights reels',
      'The 1998 opener was watched by an estimated 500 million viewers worldwide',
      'Scotland have qualified for only 8 World Cups compared to Brazil\'s record 22 consecutive appearances',
    ],
    isFirstMeeting: false,
  },

  // ========== USA vs PARAGUAY ==========
  {
    team1Code: 'PAR',
    team2Code: 'USA',
    team1Name: 'Paraguay',
    team2Name: 'United States',
    historicalAnalysis: `The United States and Paraguay share a piece of World Cup history that predates most modern football narratives. Their 1930 World Cup encounter in Montevideo saw American striker Bert Patenaude score what is now recognized as the first hat-trick in World Cup history, leading the USA to a 3-0 victory. That match, in the inaugural World Cup, established an unlikely footnote that connects these two nations across nearly a century of football.

The overall head-to-head favors the United States with 5 wins from 9 meetings, though Paraguay have shown they can compete. The rivalry lacks the intensity of CONCACAF clashes for the USA, but it carries historical significance and provides a fascinating tactical matchup between North and South American football philosophies.

For the 2026 World Cup, the USA enter as co-hosts with enormous expectations. This is their moment to prove that American soccer has arrived. Paraguay, meanwhile, return to the World Cup stage looking to recapture the magic of their 2010 quarter-final run, when they came agonizingly close to the semi-finals.`,
    keyStorylines: [
      'USA as co-hosts with expectations of reaching at least the quarter-finals',
      'Paraguay seeking to prove South American football\'s depth beyond the big three',
      'Historical echo: Can the USA replicate Patenaude\'s 1930 heroics?',
      'CONCACAF vs CONMEBOL tactical battle in a World Cup group stage',
    ],
    playersToWatch: [
      {
        name: 'Christian Pulisic',
        teamCode: 'USA',
        position: 'Winger',
        reason: 'Captain America leading the host nation\'s charge with speed and creativity',
      },
      {
        name: 'Miguel Almirón',
        teamCode: 'PAR',
        position: 'Winger',
        reason: 'Premier League experience and technical quality to unlock defenses',
      },
      {
        name: 'Gio Reyna',
        teamCode: 'USA',
        position: 'Attacking Midfielder',
        reason: 'Generational talent whose health is key to USA\'s hopes',
      },
      {
        name: 'Gustavo Gómez',
        teamCode: 'PAR',
        position: 'Defender',
        reason: 'Veteran center-back marshaling Paraguay\'s defensive organization',
      },
    ],
    tacticalPreview: `The USA under Mauricio Pochettino play an intense pressing game with quick transitions, similar to his Spurs and Chelsea sides. Paraguay typically employ a compact 4-4-2 that prioritizes defensive solidity before exploiting space on the counter.

The key battle will be in midfield, where the USA's energetic pressing meets Paraguay's experienced ball retention. If the USA can win the ball high and create chaos, their speed advantage will tell. If Paraguay slow the game and frustrate the home crowd, they can cause problems.`,
    prediction: {
      predictedOutcome: 'USA',
      predictedScore: '2-0',
      confidence: 68,
      reasoning: 'Home advantage, superior squad depth, and Pochettino\'s tactical nous give the USA a clear edge. The crowd at a packed American stadium will lift the team. Paraguay\'s quality shouldn\'t be dismissed, but the hosts should prevail.',
      alternativeScenario: 'If Paraguay take an early lead and kill the game\'s tempo, they could frustrate the USA into a nervy 1-1 draw. South American experience in these situations is invaluable.',
    },
    pastEncountersSummary: 'Nine meetings, five USA victories, but the most significant remains 1930. Bert Patenaude\'s hat-trick in that inaugural World Cup was the first in tournament history (officially recognized after decades of debate). More recent encounters have been friendlies, with the USA generally dominant.',
    funFacts: [
      'Bert Patenaude\'s 1930 hat-trick was only officially recognized as the World Cup\'s first in 2006',
      'Paraguay reached the World Cup quarter-finals in 2010, their best-ever finish',
      'The USA\'s 1930 World Cup campaign (semi-finalists) remains their best performance',
      'Tim Weah made his USA debut against Paraguay in 2018 as the first 2000s-born player for the USMNT',
    ],
    isFirstMeeting: false,
  },

  // ========== USA vs AUSTRALIA ==========
  {
    team1Code: 'AUS',
    team2Code: 'USA',
    team1Name: 'Australia',
    team2Name: 'United States',
    historicalAnalysis: `The United States and Australia have met nine times, but remarkably never at a World Cup. This 2026 encounter represents a historic first: two English-speaking nations with similar football development trajectories meeting on the world's biggest stage.

The USA hold a 5-1-3 advantage in head-to-head meetings, but more significantly, this matchup represents the growth of football in non-traditional markets. Both nations have developed domestic leagues, produced world-class players, and established themselves as regular World Cup participants after years on the periphery.

The 2026 World Cup is particularly significant for the USA as co-hosts, while Australia continue their impressive growth since joining the Asian Football Confederation. Australia's run to the 2022 World Cup round of 16 showed they can compete against top opposition.`,
    keyStorylines: [
      'First-ever World Cup meeting between these two nations',
      'USA hosting vs Australia\'s underdog mentality',
      'Battle of the emerging football nations seeking global respect',
      'Two countries with similar football growth trajectories meet at the summit',
    ],
    playersToWatch: [
      {
        name: 'Christian Pulisic',
        teamCode: 'USA',
        position: 'Winger',
        reason: 'The face of American soccer on home soil',
      },
      {
        name: 'Mathew Ryan',
        teamCode: 'AUS',
        position: 'Goalkeeper',
        reason: 'Experienced shot-stopper who has kept Australia in games against top sides',
      },
      {
        name: 'Weston McKennie',
        teamCode: 'USA',
        position: 'Midfielder',
        reason: 'Box-to-box energy and Champions League experience',
      },
      {
        name: 'Jackson Irvine',
        teamCode: 'AUS',
        position: 'Midfielder',
        reason: 'Captain and leader who embodies Australian fighting spirit',
      },
    ],
    tacticalPreview: `This could be a more open encounter than other group games. Both teams prefer to play progressive football rather than sit deep. The USA's pressing and athleticism against Australia's organized 4-4-2 will create an entertaining tactical battle.

Australia's experience from the AFC, where they face compact Asian defenses, has improved their patience in possession. The USA's home advantage and crowd support will be significant psychological factors.`,
    prediction: {
      predictedOutcome: 'USA',
      predictedScore: '3-1',
      confidence: 70,
      reasoning: 'Home advantage and superior individual quality give the USA a comfortable edge. Australia will compete but likely lack the firepower to truly threaten. This should be a confidence-building win for the hosts.',
      alternativeScenario: 'If Australia frustrate early and score first, their defensive organization could make life difficult. A 1-1 draw isn\'t out of the question if things go wrong for the USA.',
    },
    pastEncountersSummary: 'Nine friendlies with no World Cup meetings. The USA lead 5-1-3, including a 4-0 victory in Melbourne in 2015. The 2025 pre-World Cup friendly (2-1 USA) was the final preparation for this historic first World Cup encounter.',
    funFacts: [
      'This will be the first-ever World Cup match between USA and Australia',
      'Both nations have qualified for the World Cup via different confederations (CONCACAF and AFC)',
      'Australia\'s 2022 World Cup round of 16 appearance was their first knockout stage since 2006',
      'The USA and Australia have met in two consecutive pre-World Cup friendly windows',
    ],
    isFirstMeeting: false, // They have met in friendlies
  },

  // ========== NETHERLANDS vs JAPAN ==========
  {
    team1Code: 'JPN',
    team2Code: 'NED',
    team1Name: 'Japan',
    team2Name: 'Netherlands',
    historicalAnalysis: `The Netherlands and Japan's World Cup history is brief but significant. Their only meeting came during the 2010 World Cup in South Africa, when Wesley Sneijder's goal gave the Dutch a narrow 1-0 victory en route to the final. That tournament saw the Netherlands play some of their most effective football, ultimately falling to Spain in a controversial final.

Japan, meanwhile, have transformed since 2010. Their 2022 World Cup campaign saw them defeat both Germany (2-1) and Spain (2-1) in the group stage, stunning the football world with their tactical sophistication and relentless pressing. The Samurai Blue have evolved from plucky underdogs to genuine contenders.

This 2026 encounter pits Dutch tradition and individual brilliance against Japanese collective excellence. It's a fascinating study in contrasting footballing philosophies: the Netherlands' Total Football heritage versus Japan's organized pressing and transition game.`,
    keyStorylines: [
      'Japan seeking to prove 2022 victories over Germany and Spain were no fluke',
      'Netherlands rebuilding after missing 2018 World Cup and struggling in 2022',
      'Clash of philosophies: Dutch individual brilliance vs Japanese collective pressing',
      'First World Cup meeting since Sneijder\'s winner in 2010',
    ],
    playersToWatch: [
      {
        name: 'Takefusa Kubo',
        teamCode: 'JPN',
        position: 'Winger',
        reason: 'Japan\'s most creative player who can unlock any defense',
      },
      {
        name: 'Cody Gakpo',
        teamCode: 'NED',
        position: 'Forward',
        reason: 'Netherlands\' goal threat who shone at the 2022 World Cup',
      },
      {
        name: 'Wataru Endo',
        teamCode: 'JPN',
        position: 'Midfielder',
        reason: 'Liverpool\'s midfield destroyer who anchors Japan\'s pressing',
      },
      {
        name: 'Virgil van Dijk',
        teamCode: 'NED',
        position: 'Defender',
        reason: 'World-class center-back and Dutch captain',
      },
    ],
    tacticalPreview: `Japan's high-pressing 4-3-3 was devastatingly effective against Germany and Spain in 2022. They will look to suffocate the Netherlands in midfield and force turnovers in dangerous areas. The Dutch 4-3-3 prioritizes technical quality and building from the back, which could play into Japan's hands.

The key for the Netherlands is to bypass Japan's press and find spaces in transition. Van Dijk's distribution and Gakpo's movement will be crucial. Japan must maintain intensity for 90 minutes—their 2022 victories came from sustained pressure and clinical finishing.`,
    prediction: {
      predictedOutcome: 'NED',
      predictedScore: '2-1',
      confidence: 52,
      reasoning: 'The Netherlands have more individual quality, but Japan\'s 2022 victories show they can beat anyone. This is essentially a coin flip, with Dutch experience and quality giving a marginal edge.',
      alternativeScenario: 'Japan\'s pressing could overwhelm the Dutch as it did Germany and Spain. A 2-1 Japan victory would confirm their status as a top-tier nation.',
    },
    pastEncountersSummary: 'Only three meetings, all friendly except the 2010 World Cup. Sneijder\'s goal in that group stage match was part of the Dutch run to the final. Japan have yet to beat the Netherlands but enter this match with more momentum than ever before.',
    funFacts: [
      'Japan\'s 2022 World Cup wins over Germany and Spain were both 2-1 comebacks',
      'The Netherlands\' 2010 team reached the final, losing 1-0 to Spain in extra time',
      'Wesley Sneijder scored 5 goals at the 2010 World Cup, finishing as top scorer equal',
      'Japan and the Netherlands have never drawn in their three meetings',
    ],
    isFirstMeeting: false,
  },

  // ========== SPAIN vs SAUDI ARABIA ==========
  {
    team1Code: 'ESP',
    team2Code: 'SAU',
    team1Name: 'Spain',
    team2Name: 'Saudi Arabia',
    historicalAnalysis: `Spain and Saudi Arabia's World Cup history is limited to one meeting: the 2006 World Cup in Germany, where Spain won 1-0 with a hard-fought victory. However, the context of this 2026 encounter is transformed by Saudi Arabia's stunning 2022 World Cup upset over Argentina in their opening match—a 2-1 victory that ranks among the greatest shocks in tournament history.

That victory over the eventual champions showed Saudi Arabia are capable of competing at the highest level, at least for 90 minutes. Their high-pressing game plan, perfectly executed by manager Hervé Renard, exposed Argentina's offside trap and produced one of the most memorable World Cup matches ever.

Spain, meanwhile, won the 2024 European Championship in dominant fashion, confirming the emergence of a new generation of Spanish talent. La Roja's tiki-taka evolution under Luis de la Fuente produced devastating attacking football, with teenage sensation Lamine Yamal leading the charge.`,
    keyStorylines: [
      'Can Saudi Arabia produce another historic upset after shocking Argentina in 2022?',
      'Spain as Euro 2024 champions seeking World Cup glory',
      'Saudi Arabia representing Asian and Middle Eastern football ambitions',
      'Spain\'s young generation vs Saudi Arabia\'s experienced defensive organization',
    ],
    playersToWatch: [
      {
        name: 'Lamine Yamal',
        teamCode: 'ESP',
        position: 'Winger',
        reason: 'Teenage prodigy who dominated Euro 2024 and could terrorize Saudi defense',
      },
      {
        name: 'Salem Al-Dawsari',
        teamCode: 'SAU',
        position: 'Winger',
        reason: 'Scored that stunning goal against Argentina in 2022',
      },
      {
        name: 'Pedri',
        teamCode: 'ESP',
        position: 'Midfielder',
        reason: 'Orchestrates Spain\'s intricate passing game from midfield',
      },
      {
        name: 'Mohammed Al-Owais',
        teamCode: 'SAU',
        position: 'Goalkeeper',
        reason: 'Shot-stopper who was exceptional against Argentina',
      },
    ],
    tacticalPreview: `Spain's possession-based 4-3-3 is among the most sophisticated in world football. With Yamal and Nico Williams on the wings, they have pace to complement technical excellence. Saudi Arabia will likely replicate their 2022 Argentina approach: high pressing, aggressive offside trap, and clinical finishing on chances.

The key for Saudi Arabia is to disrupt Spain's rhythm early and force mistakes. If Spain settle into their passing game, Saudi Arabia will struggle to get the ball. Spain must be patient but also direct enough to avoid playing into Saudi's pressing trap.`,
    prediction: {
      predictedOutcome: 'ESP',
      predictedScore: '3-0',
      confidence: 82,
      reasoning: 'Spain\'s Euro 2024 form and superior quality should prevail comfortably. Saudi Arabia lack the sustained intensity to press for 90 minutes against Spain\'s ball retention. This should be relatively routine for La Roja.',
      alternativeScenario: 'If Saudi Arabia score first and replicate their Argentina game plan, an upset is possible. Their 2022 performance proved they can beat anyone on their day.',
    },
    pastEncountersSummary: 'Three meetings, all won by Spain without conceding a goal. The 2006 World Cup 1-0 win was tight, while friendlies have been more comfortable. Saudi Arabia\'s 2022 Argentina upset changes the calculus, proving they can compete.',
    funFacts: [
      'Saudi Arabia\'s win over Argentina in 2022 was their first World Cup victory since 1994',
      'Spain haven\'t lost to an Asian team in competitive matches',
      'Salem Al-Dawsari\'s goal against Argentina was voted the best goal of the 2022 World Cup',
      'Spain won Euro 2024 while Lamine Yamal was just 16 years old',
    ],
    isFirstMeeting: false,
  },

  // ========== BELGIUM vs EGYPT ==========
  {
    team1Code: 'BEL',
    team2Code: 'EGY',
    team1Name: 'Belgium',
    team2Name: 'Egypt',
    historicalAnalysis: `Belgium and Egypt have never met at a World Cup, making this 2026 encounter historic. Their three previous meetings have been friendlies, with Egypt surprisingly holding a 2-1 advantage including a notable 2-0 victory in Brussels in 2018 where Mohamed Salah was in brilliant form.

Belgium's "golden generation"—De Bruyne, Lukaku, Courtois—is aging, and the 2026 World Cup may represent their final opportunity to deliver on years of promise. Ranked first in the world for an extended period and third-place finishers at the 2018 World Cup, Belgium have consistently underperformed relative to expectations in knockout rounds.

Egypt, meanwhile, are Africa's most decorated nation (seven AFCON titles) but have struggled to make an impact at World Cups. Their 2018 appearance was their first in 28 years, and it ended in group stage elimination despite having Salah. The 2026 edition offers another chance.`,
    keyStorylines: [
      'Belgium\'s aging golden generation seeking one last shot at glory',
      'Egypt hoping to finally make World Cup knockout rounds for first time since 1934',
      'Mohamed Salah vs Kevin De Bruyne: Premier League superstars collide',
      'First World Cup meeting between these football-passionate nations',
    ],
    playersToWatch: [
      {
        name: 'Kevin De Bruyne',
        teamCode: 'BEL',
        position: 'Midfielder',
        reason: 'Belgium\'s orchestrator and one of the world\'s best playmakers',
      },
      {
        name: 'Mohamed Salah',
        teamCode: 'EGY',
        position: 'Forward',
        reason: 'Egypt\'s talisman and one of the greatest African players ever',
      },
      {
        name: 'Romelu Lukaku',
        teamCode: 'BEL',
        position: 'Striker',
        reason: 'Belgium\'s all-time leading scorer seeking World Cup goals',
      },
      {
        name: 'Mohamed Elneny',
        teamCode: 'EGY',
        position: 'Midfielder',
        reason: 'Experienced midfielder providing defensive stability',
      },
    ],
    tacticalPreview: `Belgium's 3-4-2-1 system maximizes De Bruyne's creativity and provides attacking width, but questions remain about their aging defensive line. Egypt typically play a pragmatic 4-2-3-1 centered around getting the ball to Salah in dangerous positions.

The key matchup is De Bruyne vs Egypt's midfield. If Belgium control the middle, their quality will tell. Egypt need to stay compact, frustrate Belgium, and hope Salah produces moments of magic. Set-pieces could be decisive.`,
    prediction: {
      predictedOutcome: 'BEL',
      predictedScore: '2-1',
      confidence: 65,
      reasoning: 'Belgium\'s overall squad quality remains superior despite aging. However, their 2022 World Cup disaster (group stage exit) raises questions about mentality. Egypt\'s 2-0 win in 2018 shows they can beat Belgium.',
      alternativeScenario: 'If Salah is at his best and Belgium\'s defense struggles, Egypt could pull off a shock. A disciplined 1-0 Egypt win is plausible.',
    },
    pastEncountersSummary: 'Three meetings, all friendlies. Egypt surprisingly lead 2-1 in head-to-head. Their 2-0 victory in Brussels in 2018, with Salah orchestrating, showed they can match Belgium. The 2022 pre-World Cup friendly (2-1 Belgium) was more recent.',
    funFacts: [
      'This is the first World Cup meeting between Belgium and Egypt',
      'Egypt\'s 2-0 win over Belgium in 2018 came months before both teams\' World Cup campaigns',
      'Belgium were ranked #1 in FIFA rankings longer than any team other than Brazil',
      'Egypt\'s last World Cup knockout win came in 1934, when they beat Hungary 4-2',
    ],
    isFirstMeeting: false, // They have met in friendlies
  },

  // ========== ENGLAND vs GHANA ==========
  {
    team1Code: 'ENG',
    team2Code: 'GHA',
    team1Name: 'England',
    team2Name: 'Ghana',
    historicalAnalysis: `England and Ghana have met only once: a 2011 friendly at Wembley that ended 1-1. Andy Carroll opened the scoring for England, but Asamoah Gyan's stoppage-time equalizer earned Ghana a draw. That single meeting makes this 2026 World Cup encounter virtually a blank slate.

However, England fans will forever associate Ghana with 2010. In that World Cup quarter-final, Luis Suárez's deliberate handball on the line denied Ghana a place in the semi-finals. Gyan's subsequent penalty miss meant Ghana—and by extension, Africa—were denied a historic first semi-final appearance. England, meanwhile, suffered their own 2010 trauma: a 4-1 demolition by Germany in the round of 16, compounded by Frank Lampard's wrongly disallowed goal.

Ghana have produced some of English football's finest imports: Michael Essien, Sulley Muntari, and more recently Thomas Partey. The connection between these nations runs deep through the Premier League.`,
    keyStorylines: [
      'First-ever World Cup meeting between England and Ghana',
      'Ghana seeking to advance past the group stage for the first time since 2010',
      'Premier League connections: Multiple Ghana players ply their trade in England',
      'Can Ghana\'s next generation match the 2010 squad\'s heroics?',
    ],
    playersToWatch: [
      {
        name: 'Jude Bellingham',
        teamCode: 'ENG',
        position: 'Midfielder',
        reason: 'England\'s best player and potential tournament star',
      },
      {
        name: 'Thomas Partey',
        teamCode: 'GHA',
        position: 'Midfielder',
        reason: 'Arsenal\'s midfield anchor bringing Premier League class to Ghana',
      },
      {
        name: 'Phil Foden',
        teamCode: 'ENG',
        position: 'Midfielder/Winger',
        reason: 'Creative spark who has evolved into a world-class player',
      },
      {
        name: 'Mohammed Kudus',
        teamCode: 'GHA',
        position: 'Midfielder',
        reason: 'Dynamic, skilful attacker who impressed at the 2022 World Cup',
      },
    ],
    tacticalPreview: `England's 4-3-3 system is built around Bellingham's dynamism and the attacking trio of Foden, Kane, and Saka. Their pressing and quick transitions are dangerous against any opponent.

Ghana typically employ a 4-2-3-1 with Partey shielding the defense and Kudus creating from advanced positions. Their key is to stay organized and hit England on the break. Set-pieces will be crucial given Ghana's aerial threat.`,
    prediction: {
      predictedOutcome: 'ENG',
      predictedScore: '2-0',
      confidence: 75,
      reasoning: 'England\'s squad depth and home continent advantage make them clear favorites. Ghana\'s quality has dipped since their 2010 peak, though individual talents like Kudus could cause problems.',
      alternativeScenario: 'If Partey and Kudus dominate midfield and Ghana score first, a shock draw or even victory is possible. England\'s tournament nerves could resurface.',
    },
    pastEncountersSummary: 'Just one meeting: a 1-1 friendly draw at Wembley in 2011. Carroll\'s opener was cancelled out by Gyan\'s late equalizer. Both nations will enter this World Cup encounter with limited direct knowledge of each other.',
    funFacts: [
      'This is the first World Cup meeting between England and Ghana',
      'Ghana\'s 2010 quarter-final loss to Uruguay remains one of football\'s most controversial moments',
      'Thomas Partey was born in Ghana but has played his entire club career in Europe',
      'Asamoah Gyan remains Ghana\'s all-time leading goalscorer with 51 goals',
    ],
    isFirstMeeting: false, // Met in 2011 friendly
  },

  // ========== GERMANY vs IVORY COAST ==========
  {
    team1Code: 'CIV',
    team2Code: 'GER',
    team1Name: 'Ivory Coast',
    team2Name: 'Germany',
    historicalAnalysis: `Germany and Ivory Coast have never met at a World Cup, making this 2026 encounter historic. Their two previous meetings were both draws: a 2-2 friendly in 2009 where Didier Drogba starred, and a 1-1 draw at the Tokyo Olympics in 2021 that eliminated Germany from the tournament.

Germany, four-time World Cup champions, enter 2026 seeking redemption after consecutive group-stage exits in 2018 and 2022. The 2022 disaster—eliminated despite beating Costa Rica 4-2 in their final match—was particularly painful for a nation that had dominated World Cups for decades.

Ivory Coast, meanwhile, are the reigning African champions after winning AFCON 2024 on home soil. That triumph, featuring a remarkable comeback from the brink of elimination, showcased the Elephants' resilience and quality. Their 2014 World Cup campaign ended in the group stage, and 2026 represents an opportunity to finally make the knockout rounds.`,
    keyStorylines: [
      'Germany seeking redemption after back-to-back World Cup group stage exits',
      'Ivory Coast as AFCON champions looking to announce themselves globally',
      'First World Cup meeting between these two nations',
      'Can Germany\'s young generation restore Die Mannschaft to former glory?',
    ],
    playersToWatch: [
      {
        name: 'Florian Wirtz',
        teamCode: 'GER',
        position: 'Midfielder',
        reason: 'Germany\'s brightest young talent and creative engine',
      },
      {
        name: 'Sébastien Haller',
        teamCode: 'CIV',
        position: 'Striker',
        reason: 'Inspirational story after cancer recovery, AFCON 2024 hero',
      },
      {
        name: 'Jamal Musiala',
        teamCode: 'GER',
        position: 'Midfielder',
        reason: 'Silky dribbler and goal threat from midfield',
      },
      {
        name: 'Franck Kessié',
        teamCode: 'CIV',
        position: 'Midfielder',
        reason: 'Physical presence and leadership in midfield',
      },
    ],
    tacticalPreview: `Germany's 4-2-3-1 under Julian Nagelsmann emphasizes quick passing and pressing. Wirtz and Musiala provide creativity, while the defense remains a concern after recent struggles.

Ivory Coast play a physical 4-3-3 that combines African athleticism with tactical organization. Their key is to match Germany's intensity early and use their pace in transition. Set-pieces could be crucial against Germany's occasionally vulnerable defense.`,
    prediction: {
      predictedOutcome: 'GER',
      predictedScore: '2-1',
      confidence: 60,
      reasoning: 'Germany\'s desperation for redemption and superior individual quality give them an edge. However, their recent World Cup failures and Ivory Coast\'s AFCON form make this closer than many expect.',
      alternativeScenario: 'Ivory Coast\'s physicality and counter-attacking threat could trouble Germany. A shock 2-1 Ivorian victory would confirm their AFCON success was no fluke.',
    },
    pastEncountersSummary: 'Just two meetings, both draws. The 2009 friendly (2-2) featured Drogba in his prime. The 2021 Olympics draw (1-1) eliminated Germany from the tournament, an ominous sign for Die Mannschaft.',
    funFacts: [
      'This is the first World Cup meeting between Germany and Ivory Coast',
      'Germany\'s 2022 elimination marked their second consecutive group stage exit',
      'Ivory Coast\'s AFCON 2024 victory came after they were nearly eliminated in the group stage',
      'Sébastien Haller returned to football after cancer treatment to become AFCON hero',
    ],
    isFirstMeeting: false, // Met in friendlies and Olympics
  },

  // ========== SPAIN vs URUGUAY ==========
  {
    team1Code: 'ESP',
    team2Code: 'URU',
    team1Name: 'Spain',
    team2Name: 'Uruguay',
    historicalAnalysis: `Spain and Uruguay share a unique World Cup history that dates back to 1950, when both nations were among the world's elite. Their encounters have been competitive affairs, with Spain leading 3-2-2 in overall head-to-head. Remarkably, their two World Cup meetings (both in 1950) ended in draws.

The 1950 World Cup's round-robin final group saw Spain and Uruguay draw 2-2 in São Paulo, one of the great matches of the early World Cup era. Both nations were contenders that year—Uruguay would go on to win the tournament with their famous "Maracanazo" victory over Brazil, while Spain finished fourth.

Modern encounters have been friendlies and a memorable 2013 Confederations Cup group match (2-1 Spain). Both nations have since won World Cups (Spain in 2010, Uruguay in 1930 and 1950), making this a meeting of champions.`,
    keyStorylines: [
      'Spain as Euro 2024 champions facing South American grit',
      'Uruguay seeking to prove they remain a World Cup force despite being a small nation',
      'Clash of World Cup winners: Spain\'s tiki-taka legacy vs Uruguay\'s warrior mentality',
      'Can Uruguay\'s young generation match the heroics of Suárez, Cavani, and Godín?',
    ],
    playersToWatch: [
      {
        name: 'Lamine Yamal',
        teamCode: 'ESP',
        position: 'Winger',
        reason: 'Teenage phenomenon who dominated Euro 2024',
      },
      {
        name: 'Federico Valverde',
        teamCode: 'URU',
        position: 'Midfielder',
        reason: 'Real Madrid\'s engine who brings intensity and quality',
      },
      {
        name: 'Nico Williams',
        teamCode: 'ESP',
        position: 'Winger',
        reason: 'Electric pace and skill on the opposite flank to Yamal',
      },
      {
        name: 'Darwin Núñez',
        teamCode: 'URU',
        position: 'Striker',
        reason: 'Liverpool striker with explosive pace and finishing ability',
      },
    ],
    tacticalPreview: `Spain's 4-3-3 under De la Fuente combines traditional possession with devastating speed on the wings. Yamal and Williams are perhaps the most exciting wing combination in world football.

Uruguay's 4-3-3 under Marcelo Bielsa emphasizes aggressive pressing and direct play. Valverde's engine and Núñez's pace will test Spain's defense. Uruguay's physicality could disrupt Spain's rhythm if they execute early.`,
    prediction: {
      predictedOutcome: 'ESP',
      predictedScore: '2-1',
      confidence: 68,
      reasoning: 'Spain\'s Euro 2024 form and superior squad depth give them the edge. Uruguay\'s quality ensures this will be competitive, but Spain\'s young stars should prevail.',
      alternativeScenario: 'Uruguay\'s physical intensity and counter-attacking threat could overwhelm Spain. A 2-1 Uruguayan victory is entirely possible if Valverde and Núñez fire.',
    },
    pastEncountersSummary: 'Seven meetings with Spain leading 3-2-2. Both World Cup encounters (1950) were draws. The 2013 Confederations Cup match (2-1 Spain) was the most recent competitive fixture. Spain\'s 2014 friendly win (2-1) is the latest meeting.',
    funFacts: [
      'Uruguay are one of only eight nations to win the World Cup',
      'The 1950 World Cup\'s round-robin format meant Spain and Uruguay drew 2-2 in a virtual "final group"',
      'Spain\'s 2010 World Cup win was built on beating Uruguay in group stage 2-1',
      'Luis Suárez\'s infamous handball against Ghana in 2010 denied Africa\'s last team; Spain would later beat Uruguay',
    ],
    isFirstMeeting: false,
  },

  // ========== CROATIA vs GHANA ==========
  {
    team1Code: 'CRO',
    team2Code: 'GHA',
    team1Name: 'Croatia',
    team2Name: 'Ghana',
    historicalAnalysis: `Croatia and Ghana have met only once: a goalless friendly draw in 2008 ahead of Euro 2008. That single encounter provides virtually no reference point for this 2026 World Cup match, making it one of the tournament's most intriguing matchups between accomplished football nations.

Croatia's World Cup pedigree is exceptional for a nation of 4 million people. Third place in 1998, runners-up in 2018, and third again in 2022, they consistently overperform expectations. Their midfield trio of Modrić, Kovačić, and Brozović has defined an era.

Ghana's 2010 quarter-final run, cruelly ended by Suárez's handball, remains their finest World Cup hour. They've struggled since, with early exits in 2014 and 2022. The 2026 tournament represents a chance to restore African pride and prove that 2010 wasn't a fluke.`,
    keyStorylines: [
      'Croatia\'s tournament experience vs Ghana\'s hunger to return to knockout rounds',
      'Can Ghana\'s pressing game disrupt Croatia\'s midfield maestros?',
      'First World Cup meeting between these nations',
      'Modrić\'s potential farewell against an African side seeking breakthrough',
    ],
    playersToWatch: [
      {
        name: 'Luka Modrić',
        teamCode: 'CRO',
        position: 'Midfielder',
        reason: 'The 40-year-old maestro in what may be his final World Cup',
      },
      {
        name: 'Mohammed Kudus',
        teamCode: 'GHA',
        position: 'Midfielder',
        reason: 'Explosive talent who can change games single-handedly',
      },
      {
        name: 'Joško Gvardiol',
        teamCode: 'CRO',
        position: 'Defender',
        reason: 'World-class center-back who excels against pace',
      },
      {
        name: 'Thomas Partey',
        teamCode: 'GHA',
        position: 'Midfielder',
        reason: 'Must win the midfield battle for Ghana to succeed',
      },
    ],
    tacticalPreview: `Croatia's 4-3-3 is built around midfield dominance. If Modrić, Kovačić, and Brozović control possession, Ghana will struggle to get the ball. Croatia's patience and experience in tournament football is unmatched.

Ghana's energetic 4-2-3-1 relies on pressing and athleticism. Kudus's dribbling and Partey's tackles could disrupt Croatia's rhythm. Ghana need to stay aggressive for 90 minutes; any let-up and Croatia will punish them.`,
    prediction: {
      predictedOutcome: 'CRO',
      predictedScore: '2-0',
      confidence: 70,
      reasoning: 'Croatia\'s tournament experience and midfield mastery should prove decisive. Ghana have the talent to compete but lack the consistency and tactical discipline that Croatia possess.',
      alternativeScenario: 'If Ghana score early and disrupt Croatia\'s rhythm, a shock result is possible. Their pace and energy could trouble Croatia\'s aging squad.',
    },
    pastEncountersSummary: 'Just one meeting: a 0-0 friendly in 2008. Neither team has any World Cup history against the other. This is a true clash of unknowns on the biggest stage.',
    funFacts: [
      'This is the first World Cup meeting between Croatia and Ghana',
      'Croatia\'s population (4 million) is smaller than Ghana\'s capital city Accra',
      'Ghana\'s 2010 quarter-final run came 12 years after Croatia\'s 1998 third-place finish',
      'Both nations have produced multiple Ballon d\'Or nominees: Modrić (winner), Essien (nominee)',
    ],
    isFirstMeeting: false, // Met in 2008 friendly
  },

  // ========== ARGENTINA vs ALGERIA ==========
  {
    team1Code: 'ALG',
    team2Code: 'ARG',
    team1Name: 'Algeria',
    team2Name: 'Argentina',
    historicalAnalysis: `Argentina and Algeria's World Cup history spans three meetings across four decades. Their first encounter in 1982 saw Diego Maradona's Argentina defeat Algeria 2-0. More recently, at the 2014 World Cup in Brazil, Lionel Messi scored a 91st-minute winner to give Argentina a narrow 2-1 victory—a crucial goal that kept their campaign on track toward the final.

Argentina enter 2026 as the reigning World Cup and Copa América champions, the undisputed best team in the world. Messi's 2022 triumph completed one of football's greatest stories, and Argentina are now looking to become the first nation since Brazil (1958, 1962) to win back-to-back World Cups.

Algeria, meanwhile, have never progressed past the World Cup group stage since their famous 1982 campaign. That tournament saw them defeat West Germany before being eliminated due to the infamous "Disgrace of Gijón" collusion between Germany and Austria. They've qualified for four World Cups but remain in search of knockout round glory.`,
    keyStorylines: [
      'Argentina as defending champions seeking back-to-back titles',
      'Algeria looking to finally advance past the group stage after decades of hurt',
      'Will Messi play in 2026? If so, this could be his final World Cup match',
      'Echo of 2014: Messi\'s late winner haunts Algerian memories',
    ],
    playersToWatch: [
      {
        name: 'Lionel Messi',
        teamCode: 'ARG',
        position: 'Forward',
        reason: 'The GOAT potentially playing his final World Cup games',
      },
      {
        name: 'Riyad Mahrez',
        teamCode: 'ALG',
        position: 'Winger',
        reason: 'Algeria\'s most technically gifted player and creative force',
      },
      {
        name: 'Julián Álvarez',
        teamCode: 'ARG',
        position: 'Forward',
        reason: 'Young striker who impressed at the 2022 World Cup',
      },
      {
        name: 'Ismaël Bennacer',
        teamCode: 'ALG',
        position: 'Midfielder',
        reason: 'AC Milan\'s midfield anchor and Algeria\'s engine',
      },
    ],
    tacticalPreview: `Argentina's 4-3-3 under Lionel Scaloni balances possession with deadly counter-attacks. Even without Messi at his peak, their collective play and winning mentality make them formidable. Álvarez and Lautaro Martínez provide goal threat.

Algeria play an organized 4-3-3 built around Mahrez's creativity and Bennacer's midfield control. Their best chance is to stay compact and hit Argentina on the break. The challenge is containing Argentina's movement and pressing.`,
    prediction: {
      predictedOutcome: 'ARG',
      predictedScore: '3-0',
      confidence: 85,
      reasoning: 'Argentina\'s champion mentality and squad quality make them heavy favorites. Algeria have quality but lack the depth and experience to trouble the defending champions for 90 minutes.',
      alternativeScenario: 'A disciplined Algeria could frustrate Argentina and sneak a draw. If Mahrez produces magic and Argentina struggle to break down the defense, 1-1 is possible.',
    },
    pastEncountersSummary: 'Three meetings, all Argentina victories or draws. The 2014 World Cup encounter (2-1) saw Messi score the winner in the 91st minute. The 1982 meeting (2-0) featured a young Maradona. Algeria have never beaten Argentina.',
    funFacts: [
      'Messi\'s 91st-minute goal against Algeria in 2014 was his 40th for Argentina',
      'Algeria\'s 1982 team beat West Germany but were eliminated due to match-fixing allegations between Germany and Austria',
      'Argentina are seeking to become the first team since Brazil (1958-62) to win back-to-back World Cups',
      'Both nations have French colonial history, adding a unique cultural dimension',
    ],
    isFirstMeeting: false,
  },

  // ========== COLOMBIA vs PORTUGAL ==========
  {
    team1Code: 'COL',
    team2Code: 'POR',
    team1Name: 'Colombia',
    team2Name: 'Portugal',
    historicalAnalysis: `In one of football's most surprising historical footnotes, Colombia and Portugal have never played each other. Despite both nations boasting rich football traditions and producing generations of world-class talent, fate has never brought them together on the pitch.

This 2026 World Cup encounter will be their first-ever meeting, making it one of the most anticipated debuts of the tournament. Colombia's history features the creative genius of Carlos Valderrama and James Rodríguez, while Portugal can claim Eusébio and Cristiano Ronaldo as their greatest icons.

Colombia's 2014 World Cup quarter-final run, led by James Rodríguez (who won the Golden Boot), represents their finest hour. Portugal, meanwhile, won Euro 2016 and the Nations League in 2019, adding to Cristiano Ronaldo's legacy even as his national team career winds down.`,
    keyStorylines: [
      'Historic first meeting between two proud football nations',
      'Cristiano Ronaldo potentially in his final World Cup',
      'Colombia seeking to replicate their 2014 World Cup magic',
      'Portuguese next generation stepping up as Ronaldo\'s era ends',
    ],
    playersToWatch: [
      {
        name: 'Cristiano Ronaldo',
        teamCode: 'POR',
        position: 'Forward',
        reason: 'The legendary striker in what may be his final World Cup',
      },
      {
        name: 'Luis Díaz',
        teamCode: 'COL',
        position: 'Winger',
        reason: 'Liverpool\'s explosive winger and Colombia\'s attacking talisman',
      },
      {
        name: 'Rafael Leão',
        teamCode: 'POR',
        position: 'Winger',
        reason: 'Portugal\'s heir apparent with electric pace and skill',
      },
      {
        name: 'James Rodríguez',
        teamCode: 'COL',
        position: 'Midfielder',
        reason: 'The 2014 Golden Boot winner seeking one more World Cup moment',
      },
    ],
    tacticalPreview: `Portugal's 4-3-3 system balances Ronaldo's predatory instincts with the creative genius of Bruno Fernandes and the pace of Leão. Their midfield depth and defensive quality make them one of the tournament favorites.

Colombia's 4-2-3-1 relies on Luis Díaz's explosiveness and James Rodríguez's vision. Their South American flair combined with pressing intensity can trouble any opponent. The key is defensive discipline against Portugal's quality.`,
    prediction: {
      predictedOutcome: 'POR',
      predictedScore: '2-1',
      confidence: 58,
      reasoning: 'Portugal\'s squad depth and experience in major tournaments give them a slight edge. Colombia\'s attacking quality ensures this will be competitive. This could be one of the matches of the group stage.',
      alternativeScenario: 'If Luis Díaz and James are at their best, Colombia could pull off a historic upset. Their counter-attacking threat is genuine. A 2-1 Colombian victory is entirely feasible.',
    },
    pastEncountersSummary: 'No previous meetings. This is a historic first encounter between these two nations. Both have won major honors (Portugal: Euro 2016, Nations League; Colombia: 2001 Copa América) but never faced each other.',
    funFacts: [
      'This will be the first-ever match between Colombia and Portugal at any level',
      'James Rodríguez won the 2014 World Cup Golden Boot with 6 goals',
      'Cristiano Ronaldo has scored 130+ goals for Portugal, the all-time international record',
      'Both nations have reached World Cup quarter-finals but never progressed to semi-finals',
    ],
    isFirstMeeting: true,
  },

  // ========== CROATIA vs PANAMA ==========
  {
    team1Code: 'CRO',
    team2Code: 'PAN',
    team1Name: 'Croatia',
    team2Name: 'Panama',
    historicalAnalysis: `Croatia and Panama have never met in any competitive or friendly match, making this 2026 World Cup encounter their first-ever meeting. It's a striking illustration of how the World Cup brings together nations from opposite ends of football's global landscape.

Croatia, with their remarkable World Cup pedigree (third in 1998, runners-up in 2018, third in 2022), are one of the tournament's established powers despite their small population of 4 million. Their sustained excellence has made them one of international football's most respected nations.

Panama, by contrast, made their World Cup debut only in 2018, losing all three group games including a 6-1 thrashing by England. Their qualification for 2026 represents just their second World Cup appearance. The contrast in experience could not be more stark.`,
    keyStorylines: [
      'First-ever meeting between these nations',
      'Croatia\'s World Cup experience vs Panama\'s relative inexperience',
      'Can Panama avoid a repeat of their 2018 struggles?',
      'Modrić and the aging Croatian core facing energetic underdogs',
    ],
    playersToWatch: [
      {
        name: 'Luka Modrić',
        teamCode: 'CRO',
        position: 'Midfielder',
        reason: 'The 40-year-old Ballon d\'Or winner leading Croatia once more',
      },
      {
        name: 'Adalberto Carrasquilla',
        teamCode: 'PAN',
        position: 'Midfielder',
        reason: 'Panama\'s creative hub and most technically gifted player',
      },
      {
        name: 'Mateo Kovačić',
        teamCode: 'CRO',
        position: 'Midfielder',
        reason: 'Premier League experience and key part of Croatia\'s midfield three',
      },
      {
        name: 'José Fajardo',
        teamCode: 'PAN',
        position: 'Forward',
        reason: 'Goal threat tasked with troubling Croatia\'s defense',
      },
    ],
    tacticalPreview: `Croatia's 4-3-3 built around midfield dominance should control this match. Their experience in World Cup encounters means they know how to manage games against less experienced opponents.

Panama will likely sit deep in a 5-4-1 or 5-3-2, hoping to frustrate Croatia and hit them on the counter. Their best chance is set-pieces and maintaining defensive shape for as long as possible. Any early goal from Croatia could open floodgates.`,
    prediction: {
      predictedOutcome: 'CRO',
      predictedScore: '3-0',
      confidence: 88,
      reasoning: 'Croatia\'s quality advantage is substantial. Panama\'s 2018 World Cup (0 points, -11 goal difference) showed they struggle against elite opponents. This should be relatively comfortable for Croatia.',
      alternativeScenario: 'If Panama score first and frustrate Croatia, nerves could set in. A shock 1-0 Panama victory, while unlikely, would be one of the great World Cup upsets.',
    },
    pastEncountersSummary: 'No previous meetings in any competition. This first encounter represents a remarkable World Cup moment: a 2018 finalist facing a nation making just their second World Cup appearance.',
    funFacts: [
      'This is the first-ever match between Croatia and Panama',
      'Panama\'s 2018 World Cup goal against England was their first in World Cup history',
      'Croatia\'s population (4 million) is similar to Panama\'s (4.4 million)',
      'Panama qualified for 2018 by ending the USA\'s streak of 7 consecutive World Cup appearances',
    ],
    isFirstMeeting: true,
  },
];

// ============================================================================
// Main Seed Function
// ============================================================================

async function seedMatchSummaries(): Promise<void> {
  console.log('========================================');
  console.log('Seeding AI Match Summaries');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Summaries to seed: ${MATCH_SUMMARIES.length}`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const summary of MATCH_SUMMARIES) {
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
        pastEncountersSummary: summary.pastEncountersSummary,
        funFacts: summary.funFacts,
        isFirstMeeting: summary.isFirstMeeting,
        updatedAt: new Date().toISOString(),
      };

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would create: ${docId}`);
        console.log(`  ${summary.team1Name} vs ${summary.team2Name}`);
        console.log(`  Prediction: ${summary.prediction.predictedOutcome} (${summary.prediction.predictedScore})`);
        console.log(`  Confidence: ${summary.prediction.confidence}%`);
        if (summary.isFirstMeeting) {
          console.log(`  ⭐ FIRST MEETING EVER!`);
        }
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
  console.log(`Total summaries: ${MATCH_SUMMARIES.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log(`First-time meetings: ${MATCH_SUMMARIES.filter(s => s.isFirstMeeting).length}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedMatchSummaries()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
