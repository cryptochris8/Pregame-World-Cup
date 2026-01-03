/**
 * Seed remaining AI Match Summaries for June 2026 World Cup
 *
 * Creates summaries for all matches with known teams that don't already have summaries
 *
 * Usage:
 *   npx ts-node src/seed-remaining-summaries.ts
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

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

interface MatchSummary {
  team1Code: string;
  team2Code: string;
  team1Name: string;
  team2Name: string;
  historicalAnalysis: string;
  keyStorylines: string[];
  playersToWatch: Array<{
    name: string;
    teamCode: string;
    position: string;
    reason: string;
  }>;
  tacticalPreview: string;
  prediction: {
    predictedOutcome: string;
    predictedScore: string;
    confidence: number;
    reasoning: string;
    alternativeScenario: string;
  };
  pastEncountersSummary: string;
  funFacts: string[];
  isFirstMeeting: boolean;
  updatedAt: string;
}

// Create document ID from team codes (alphabetically sorted)
function createDocId(team1: string, team2: string): string {
  const codes = [team1, team2].sort();
  return `${codes[0]}_${codes[1]}`;
}

const summaries: Array<{ docId: string; data: MatchSummary }> = [
  // Match 1: Mexico vs South Africa (Group A)
  {
    docId: createDocId('MEX', 'RSA'),
    data: {
      team1Code: 'MEX',
      team2Code: 'RSA',
      team1Name: 'Mexico',
      team2Name: 'South Africa',
      historicalAnalysis: `Mexico and South Africa share a historic connection—South Africa hosted the 2010 World Cup where their opening match was against Mexico, ending 1-1. That draw in Johannesburg remains one of the most memorable moments in Bafana Bafana history, with Siphiwe Tshabalala's stunning opening goal becoming iconic.

This 2026 encounter sees Mexico as co-hosts, desperate to break their Round of 16 curse that has haunted them since 1986. El Tri have failed to advance past the first knockout round in seven consecutive World Cups. South Africa, meanwhile, are making their first World Cup appearance since hosting in 2010.

The stakes couldn't be higher for Mexico playing at the Estadio Azteca in the tournament opener. The weight of expectation from millions of Mexican fans will be immense, but so too is the opportunity to set the tone for their home World Cup.`,
      keyStorylines: [
        'Tournament opener at the iconic Estadio Azteca with Mexico as co-hosts',
        'Rematch of the historic 2010 World Cup opening match',
        'Mexico seeking to exorcise their Round of 16 demons',
        'South Africa\'s first World Cup since hosting in 2010',
      ],
      playersToWatch: [
        { name: 'Santiago Giménez', teamCode: 'MEX', position: 'Forward', reason: 'Feyenoord\'s goal machine leading Mexico\'s attack' },
        { name: 'Percy Tau', teamCode: 'RSA', position: 'Winger', reason: 'South Africa\'s most experienced European-based player' },
        { name: 'Edson Álvarez', teamCode: 'MEX', position: 'Midfielder', reason: 'West Ham\'s midfield enforcer and El Tri captain' },
        { name: 'Ronwen Williams', teamCode: 'RSA', position: 'Goalkeeper', reason: 'AFCON 2024 Best Goalkeeper, Bafana\'s last line' },
      ],
      tacticalPreview: `Mexico's 4-3-3 under Javier Aguirre emphasizes ball retention and patient buildup, with Giménez as the focal point. Their home support will drive aggressive pressing in the opening stages.

South Africa's 4-4-2 will be compact and defensively disciplined, looking to frustrate Mexico and hit on the counter. Williams' shot-stopping abilities will be crucial, and set-pieces could be their best route to goal.`,
      prediction: {
        predictedOutcome: 'MEX',
        predictedScore: '2-0',
        confidence: 72,
        reasoning: 'Home advantage at the Azteca and superior squad depth should see Mexico through. South Africa will compete but lack the firepower to threaten consistently.',
        alternativeScenario: 'If South Africa score early and sit deep, their defensive organization could force a nervy 1-0 or even a shock draw.',
      },
      pastEncountersSummary: 'Two meetings, both at World Cups. The 2010 opener in Johannesburg ended 1-1 with iconic goals from Tshabalala and Márquez. They also met in the 2010 group stage.',
      funFacts: [
        'Siphiwe Tshabalala\'s goal in 2010 was the first of that World Cup and became iconic in South Africa',
        'The Estadio Azteca has hosted two World Cup finals (1970, 1986)',
        'Mexico are the only team to host the World Cup three times',
        'South Africa are the only host nation to be eliminated in the group stage (2010)',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 5: Haiti vs Scotland (Group C)
  {
    docId: createDocId('HAI', 'SCO'),
    data: {
      team1Code: 'HAI',
      team2Code: 'SCO',
      team1Name: 'Haiti',
      team2Name: 'Scotland',
      historicalAnalysis: `This is a historic first meeting between Haiti and Scotland. Haiti are making their first World Cup appearance since 1974, when they became the first Caribbean nation to qualify. Scotland return to the World Cup looking to make an impact after years of near-misses.

Haiti's qualification is one of the great stories of this World Cup cycle, emerging from a competitive CONCACAF region despite limited resources. Their passionate fanbase and attacking flair have captured neutral hearts worldwide.

Scotland's journey has been marked by heartbreak—agonizing playoff defeats and last-day qualification failures. This 2026 squad, featuring Premier League quality throughout, represents perhaps their strongest generation in decades.`,
      keyStorylines: [
        'Haiti\'s first World Cup in 52 years vs Scotland\'s returning generation',
        'Historic first meeting between these nations',
        'Caribbean flair vs Scottish pragmatism',
        'Both teams looking to make group stage statements',
      ],
      playersToWatch: [
        { name: 'John McGinn', teamCode: 'SCO', position: 'Midfielder', reason: 'Aston Villa\'s dynamic captain driving Scotland\'s attack' },
        { name: 'Frantzdy Pierrot', teamCode: 'HAI', position: 'Forward', reason: 'Haiti\'s powerful target man and leading scorer' },
        { name: 'Billy Gilmour', teamCode: 'SCO', position: 'Midfielder', reason: 'Brighton\'s creative maestro controlling the tempo' },
        { name: 'Derrick Etienne Jr.', teamCode: 'HAI', position: 'Winger', reason: 'MLS winger providing pace and creativity' },
      ],
      tacticalPreview: `Scotland's 3-5-2 provides defensive solidity while allowing McGinn and Adams to drive forward. Their pressing intensity could overwhelm Haiti in the middle third.

Haiti's 4-3-3 is built on energy and counter-attacking speed. Their physical forwards can cause problems in the air, and they won't be intimidated by Scotland's European pedigree.`,
      prediction: {
        predictedOutcome: 'SCO',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'Scotland\'s Premier League quality should prove decisive, but Haiti\'s physicality and spirit will make this competitive.',
        alternativeScenario: 'Haiti\'s passionate approach and set-piece threat could earn a famous draw if Scotland struggle with the occasion.',
      },
      pastEncountersSummary: 'First ever meeting between these nations at any level.',
      funFacts: [
        'Haiti\'s 1974 World Cup squad included Emmanuel Sanon, who scored against Italy',
        'Scotland have never progressed past the World Cup group stage',
        'Haiti are one of only two Caribbean nations to play at a World Cup (with Jamaica)',
        'This is the first World Cup match in Gillette Stadium history',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 8: Qatar vs Switzerland (Group B)
  {
    docId: createDocId('QAT', 'SUI'),
    data: {
      team1Code: 'QAT',
      team2Code: 'SUI',
      team1Name: 'Qatar',
      team2Name: 'Switzerland',
      historicalAnalysis: `Qatar and Switzerland have never met in competitive action. This matchup pits the 2022 World Cup hosts against one of Europe's most consistent performers. Qatar's home World Cup saw them eliminated in the group stage without a win—a disappointment they're eager to avenge.

Switzerland have established themselves as perennial Round of 16 contenders, with memorable victories over France (Euro 2020) and Spain (2010 World Cup). Their blend of experienced veterans and emerging talents makes them dangerous opponents.

Qatar have rebuilt significantly since 2022, investing heavily in their domestic league and youth development. This is their chance to prove that hosting the World Cup wasn't their peak.`,
      keyStorylines: [
        'Qatar seeking redemption after disappointing home World Cup',
        'Switzerland\'s consistent knockout round pedigree',
        'First ever competitive meeting between these nations',
        'Asian champions vs European dark horses',
      ],
      playersToWatch: [
        { name: 'Granit Xhaka', teamCode: 'SUI', position: 'Midfielder', reason: 'Bayer Leverkusen\'s title-winning captain and Swiss talisman' },
        { name: 'Akram Afif', teamCode: 'QAT', position: 'Winger', reason: 'Asian Player of the Year and Qatar\'s creative hub' },
        { name: 'Breel Embolo', teamCode: 'SUI', position: 'Forward', reason: 'Monaco\'s powerful striker leading the line' },
        { name: 'Almoez Ali', teamCode: 'QAT', position: 'Forward', reason: 'Qatar\'s all-time leading scorer' },
      ],
      tacticalPreview: `Switzerland's 3-4-2-1 provides defensive solidity while Xhaka orchestrates from deep. Their ability to absorb pressure and strike on the counter is world-class.

Qatar's 5-3-2 emphasizes compact defending and quick transitions through Afif. Their technical quality is underrated, but consistency against top European sides remains a question.`,
      prediction: {
        predictedOutcome: 'SUI',
        predictedScore: '2-0',
        confidence: 75,
        reasoning: 'Switzerland\'s tournament experience and superior squad depth should prove decisive. Qatar will compete but lack the cutting edge.',
        alternativeScenario: 'If Afif produces individual brilliance and Qatar defend resolutely, a 1-1 draw is possible.',
      },
      pastEncountersSummary: 'First competitive meeting. No previous history between these nations.',
      funFacts: [
        'Qatar became the first host nation to lose all three group games (2022)',
        'Switzerland have reached the knockout rounds in 4 of their last 5 major tournaments',
        'Xhaka has played more games for Switzerland than any outfield player',
        'Qatar won the Asian Cup in 2019 and 2023',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 10: Germany vs Curaçao (Group F)
  {
    docId: createDocId('GER', 'CUR'),
    data: {
      team1Code: 'GER',
      team2Code: 'CUR',
      team1Name: 'Germany',
      team2Name: 'Curaçao',
      historicalAnalysis: `This is a David vs Goliath matchup of historic proportions. Germany, four-time World Cup champions, face Curaçao, a tiny Caribbean island nation making their World Cup debut with a population of just 150,000.

Germany's recent World Cup performances have been disappointing—group stage exits in 2018 and 2022 have shaken German football's foundations. Die Mannschaft are desperate to restore their reputation on the world stage.

Curaçao's qualification is the ultimate underdog story. Competing against nations with far greater resources, they've emerged from CONCACAF through sheer determination and excellent coaching. This is the culmination of years of development in Dutch Caribbean football.`,
      keyStorylines: [
        'Curaçao\'s historic World Cup debut against the four-time champions',
        'Germany seeking redemption after consecutive group stage exits',
        'Population of 150,000 vs football superpower',
        'The smallest nation ever to face Germany at a World Cup',
      ],
      playersToWatch: [
        { name: 'Florian Wirtz', teamCode: 'GER', position: 'Midfielder', reason: 'Leverkusen\'s wonderkid leading Germany\'s new generation' },
        { name: 'Juninho Bacuna', teamCode: 'CUR', position: 'Midfielder', reason: 'Curaçao\'s most experienced player with Championship pedigree' },
        { name: 'Jamal Musiala', teamCode: 'GER', position: 'Midfielder', reason: 'Bayern Munich\'s dazzling talent and Germany\'s creative spark' },
        { name: 'Kenji Gorré', teamCode: 'CUR', position: 'Winger', reason: 'Tricky winger who can cause problems on the counter' },
      ],
      tacticalPreview: `Germany's 4-2-3-1 unleashes Wirtz and Musiala in the creative zones, with Havertz providing the focal point. Expect waves of possession and attacking intent.

Curaçao will park the bus in a deep 5-4-1, looking to frustrate Germany and hit on rare counter-attacks. Their discipline and concentration for 90 minutes will be tested to the maximum.`,
      prediction: {
        predictedOutcome: 'GER',
        predictedScore: '4-0',
        confidence: 90,
        reasoning: 'The gulf in quality is simply too large. Germany should dominate possession and create numerous chances against Curaçao\'s defense.',
        alternativeScenario: 'If Curaçao defend heroically and Germany are wasteful, a 2-0 win with German frustration is possible.',
      },
      pastEncountersSummary: 'First ever meeting between these nations at any level.',
      funFacts: [
        'Curaçao has a population of approximately 150,000—smaller than most World Cup stadiums',
        'Germany have scored in 30 consecutive World Cup group matches',
        'Curaçao are a constituent country of the Netherlands',
        'This is Germany\'s 20th World Cup appearance, tying Brazil for most',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 11: Ivory Coast vs Ecuador (Group F)
  {
    docId: createDocId('CIV', 'ECU'),
    data: {
      team1Code: 'CIV',
      team2Code: 'ECU',
      team1Name: 'Ivory Coast',
      team2Name: 'Ecuador',
      historicalAnalysis: `Ivory Coast and Ecuador have met only once—a 2006 friendly that the Elephants won 3-2. Both nations have been consistent World Cup qualifiers in the modern era, representing the best of African and South American football respectively.

Ivory Coast are the reigning AFCON champions, winning on home soil in 2024 after a dramatic tournament. Their blend of European-based stars and local heroes has created a balanced squad capable of competing with anyone.

Ecuador impressed at the 2022 World Cup with wins over Qatar and draws against the Netherlands and Senegal. Their young squad has matured, with several players now featuring at top European clubs.`,
      keyStorylines: [
        'Reigning AFCON champions vs South American dark horses',
        'African physical power vs South American technical flair',
        'Both teams have World Cup knockout round aspirations',
        'Two nations with similar World Cup pedigree in a crucial group match',
      ],
      playersToWatch: [
        { name: 'Sébastien Haller', teamCode: 'CIV', position: 'Forward', reason: 'Dortmund striker who overcame cancer to lead the Elephants' },
        { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'Chelsea\'s £100m+ midfield dynamo' },
        { name: 'Serge Aurier', teamCode: 'CIV', position: 'Defender', reason: 'Experienced former Spurs defender marshaling the backline' },
        { name: 'Kendry Páez', teamCode: 'ECU', position: 'Midfielder', reason: 'Teenage prodigy already signed by Chelsea' },
      ],
      tacticalPreview: `Ivory Coast's 4-3-3 is built on power and pace, with Haller as the target man and wingers providing width. Their physicality in midfield could overwhelm Ecuador.

Ecuador's 4-4-2 emphasizes quick passing and movement. Caicedo's ability to break up play and drive forward will be crucial, with their forwards looking to capitalize on any defensive errors.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 55,
        reasoning: 'Two evenly matched sides should produce a tight encounter. Both have the quality to score but also defensive organization to limit chances.',
        alternativeScenario: 'If Ivory Coast\'s physicality dominates, a 2-1 win is possible. If Ecuador control midfield through Caicedo, they could edge it.',
      },
      pastEncountersSummary: 'One meeting in 2006, a friendly won 3-2 by Ivory Coast. No competitive history.',
      funFacts: [
        'Sébastien Haller returned to football after beating testicular cancer in 2022',
        'Ecuador have qualified for 5 of the last 6 World Cups',
        'Ivory Coast\'s AFCON 2024 win was their third title',
        'Caicedo\'s £115m transfer fee is a British record',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 13: Spain vs Cape Verde (Group G)
  {
    docId: createDocId('ESP', 'CPV'),
    data: {
      team1Code: 'ESP',
      team2Code: 'CPV',
      team1Name: 'Spain',
      team2Name: 'Cape Verde',
      historicalAnalysis: `This is a historic first meeting as Cape Verde make their World Cup debut. The tiny island nation of just 500,000 people has produced remarkable footballers, many playing in Portugal's top divisions, but this is their crowning achievement.

Spain, the 2024 European Champions, enter as one of the favorites. Their young, dynamic squad destroyed England 2-1 in the Euro final with a performance that announced a new golden generation. Lamine Yamal, Nico Williams, and Pedri represent the future of Spanish football.

For Cape Verde, simply being here is a triumph. But their Portuguese-influenced technical football means they won't roll over—they'll compete with pride and try to create historic moments.`,
      keyStorylines: [
        'Cape Verde\'s historic World Cup debut against European champions',
        'Spain\'s new golden generation seeking World Cup glory',
        'The smallest nation ever to face Spain at a World Cup',
        'Portuguese-influenced Cape Verde style vs Spanish tiki-taka',
      ],
      playersToWatch: [
        { name: 'Lamine Yamal', teamCode: 'ESP', position: 'Winger', reason: 'Barcelona\'s teenage sensation and Euro 2024 star' },
        { name: 'Ryan Mendes', teamCode: 'CPV', position: 'Winger', reason: 'Cape Verde\'s most dangerous attacker' },
        { name: 'Pedri', teamCode: 'ESP', position: 'Midfielder', reason: 'Barcelona\'s midfield maestro pulling the strings' },
        { name: 'Garry Rodrigues', teamCode: 'CPV', position: 'Forward', reason: 'Experienced striker with European pedigree' },
      ],
      tacticalPreview: `Spain's 4-3-3 emphasizes possession and quick combinations. With Yamal and Williams on the wings, they have devastating pace to complement their technical mastery.

Cape Verde's 4-4-2 will be compact and organized. They'll look to frustrate Spain and hit on the counter, with set-pieces potentially their best route to goal.`,
      prediction: {
        predictedOutcome: 'ESP',
        predictedScore: '4-0',
        confidence: 88,
        reasoning: 'Spain\'s quality is simply overwhelming. Their attacking firepower should prove too much for Cape Verde\'s defense.',
        alternativeScenario: 'If Cape Verde defend heroically, Spain might only manage 2-0 with growing frustration.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Cape Verde has a population of about 500,000—smaller than many European cities',
        'Many Cape Verdean players have Portuguese citizenship due to colonial ties',
        'Lamine Yamal became the youngest ever European Championship scorer at 16',
        'Spain have won 3 major tournaments in the last 20 years (Euro 2008, 2012, 2024; WC 2010)',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 14: Iran vs New Zealand (Group H)
  {
    docId: createDocId('IRN', 'NZL'),
    data: {
      team1Code: 'IRN',
      team2Code: 'NZL',
      team1Name: 'Iran',
      team2Name: 'New Zealand',
      historicalAnalysis: `Iran and New Zealand meet for the first time in World Cup history, though they faced each other in a 2017 friendly that Iran won 2-0. Both nations are regulars in the intercontinental playoffs, often fighting for the same World Cup spot.

Iran have been Asia's most consistent World Cup qualifiers, appearing in 6 of the last 7 tournaments. Their 2022 World Cup saw an emotional campaign amid political turmoil at home, including a famous 2-0 win over Wales.

New Zealand qualified through the Oceania region and a playoff victory. The All Whites have only progressed past the group stage once (three draws in 2010), but this experienced squad has European-based players who can compete at this level.`,
      keyStorylines: [
        'Asia vs Oceania in a battle of regional powers',
        'Iran\'s experienced squad vs New Zealand\'s organization',
        'Both nations have World Cup upset potential',
        'Crucial match for knockout round aspirations',
      ],
      playersToWatch: [
        { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Forward', reason: 'Inter Milan\'s clinical striker and Iran\'s talisman' },
        { name: 'Chris Wood', teamCode: 'NZL', position: 'Forward', reason: 'Nottingham Forest\'s Premier League-proven striker' },
        { name: 'Sardar Azmoun', teamCode: 'IRN', position: 'Forward', reason: 'The Iranian Messi with flair and finishing' },
        { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'Empoli\'s attacking left-back providing width' },
      ],
      tacticalPreview: `Iran's 4-3-3 is built on defensive solidity and quick transitions. Taremi and Azmoun's partnership is world-class, and their counter-attacking threat is formidable.

New Zealand's 4-4-2 is pragmatic and organized. Wood's aerial ability will be crucial, with the All Whites looking to maximize set-pieces and crosses.`,
      prediction: {
        predictedOutcome: 'IRN',
        predictedScore: '2-1',
        confidence: 62,
        reasoning: 'Iran\'s superior attacking talent should prove decisive, but New Zealand\'s organization will make this competitive.',
        alternativeScenario: 'If Wood dominates aerially and New Zealand defend resolutely, a 1-1 draw is very possible.',
      },
      pastEncountersSummary: 'One previous meeting: a 2017 friendly won 2-0 by Iran.',
      funFacts: [
        'Taremi scored in both the Champions League and Europa League finals in consecutive seasons',
        'New Zealand are unbeaten in World Cup history (3 draws in 2010)',
        'Iran have qualified for more World Cups than any Asian nation except Japan and South Korea',
        'Chris Wood has scored more than 50 Premier League goals',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 16: Saudi Arabia vs Uruguay (Group G)
  {
    docId: createDocId('SAU', 'URU'),
    data: {
      team1Code: 'SAU',
      team2Code: 'URU',
      team1Name: 'Saudi Arabia',
      team2Name: 'Uruguay',
      historicalAnalysis: `These nations met in a 2018 World Cup group match that Uruguay won 1-0 thanks to a Luis Suárez goal. Saudi Arabia's famous 2022 World Cup victory over Argentina showed what they're capable of at their best.

Saudi Arabia's football has been transformed by massive investment and the signings of global stars to their domestic league. Their national team benefits from this exposure to top-level football, and their technical quality has improved dramatically.

Uruguay remain a South American powerhouse, with two World Cup titles and a history of punching above their weight. Their blend of experienced veterans and emerging talents makes them dark horse candidates once again.`,
      keyStorylines: [
        'Saudi Arabia seeking to replicate their 2022 magic against another South American giant',
        'Uruguay\'s two-time champions looking to assert their pedigree',
        'Saudi investment vs Uruguayan tradition',
        'Rematch of 2018 World Cup encounter',
      ],
      playersToWatch: [
        { name: 'Darwin Núñez', teamCode: 'URU', position: 'Forward', reason: 'Liverpool\'s explosive striker leading the new generation' },
        { name: 'Salem Al-Dawsari', teamCode: 'SAU', position: 'Winger', reason: 'Scored the winner against Argentina in 2022' },
        { name: 'Federico Valverde', teamCode: 'URU', position: 'Midfielder', reason: 'Real Madrid\'s all-action midfielder' },
        { name: 'Saleh Al-Shehri', teamCode: 'SAU', position: 'Forward', reason: 'Clinical finisher who scored against Argentina' },
      ],
      tacticalPreview: `Uruguay's 4-4-2 provides defensive solidity while unleashing Núñez's pace on the counter. Valverde's box-to-box running adds another dimension to their attack.

Saudi Arabia's 4-3-3 emphasizes quick passing and technical football. Al-Dawsari's creativity is crucial, and they'll look to play with the same intensity that shocked Argentina.`,
      prediction: {
        predictedOutcome: 'URU',
        predictedScore: '2-1',
        confidence: 60,
        reasoning: 'Uruguay\'s experience and squad depth should prove decisive, but Saudi Arabia have shown they can beat anyone on their day.',
        alternativeScenario: 'If Saudi Arabia start fast and pressure Uruguay\'s backline, they could produce another shock result.',
      },
      pastEncountersSummary: 'Met once at the 2018 World Cup, Uruguay winning 1-0 with a Luis Suárez goal.',
      funFacts: [
        'Saudi Arabia\'s win over Argentina is considered one of the greatest World Cup upsets ever',
        'Uruguay won the first ever World Cup in 1930',
        'Al-Dawsari\'s goal against Argentina was voted the best goal of the 2022 World Cup',
        'Uruguay have won Copa América 15 times—a record',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 21: Austria vs Jordan (Group J)
  {
    docId: createDocId('AUT', 'JOR'),
    data: {
      team1Code: 'AUT',
      team2Code: 'JOR',
      team1Name: 'Austria',
      team2Name: 'Jordan',
      historicalAnalysis: `This is a historic first meeting between Austria and Jordan. Austria have been one of Europe's most improved teams, finishing top of their Nations League group and playing attractive football under Ralf Rangnick's gegenpressing system.

Jordan's qualification is a breakthrough for Asian football. As 2023 AFC Asian Cup runners-up (losing to Qatar in the final), they've proven their ability to compete with the continent's best. This is their first World Cup.

Austria enter as clear favorites, but Jordan's organization and spirit have seen them overcome supposedly superior opponents before.`,
      keyStorylines: [
        'Jordan\'s historic World Cup debut',
        'Austria\'s gegenpressing revolution under Rangnick',
        'First ever meeting between these nations',
        'European sophistication vs Asian Cup runners-up',
      ],
      playersToWatch: [
        { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'Real Madrid legend and Austrian captain' },
        { name: 'Mousa Al-Taamari', teamCode: 'JOR', position: 'Winger', reason: 'Montpellier\'s tricky winger and Jordan\'s star' },
        { name: 'Marcel Sabitzer', teamCode: 'AUT', position: 'Midfielder', reason: 'Dortmund\'s energetic midfielder' },
        { name: 'Yazan Al-Naimat', teamCode: 'JOR', position: 'Forward', reason: 'Young striker with an eye for goal' },
      ],
      tacticalPreview: `Austria's 4-2-3-1 under Rangnick emphasizes intense pressing and quick transitions. Sabitzer's energy and Laimer's running will try to overwhelm Jordan's midfield.

Jordan's 4-4-2 is disciplined and compact. They'll look to frustrate Austria and exploit counter-attacking opportunities through Al-Taamari's pace and skill.`,
      prediction: {
        predictedOutcome: 'AUT',
        predictedScore: '2-0',
        confidence: 70,
        reasoning: 'Austria\'s superior squad quality and pressing intensity should prove decisive. Jordan will compete but lack the firepower to threaten consistently.',
        alternativeScenario: 'If Jordan defend heroically and Austria struggle to break them down, a nervy 1-0 win is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Jordan reached the AFC Asian Cup final in 2023, losing 3-1 to Qatar',
        'Rangnick\'s Austria are unbeaten in their last 15 competitive home games',
        'This is Jordan\'s first World Cup appearance',
        'Austria\'s best World Cup finish was third place in 1954',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 24: Uzbekistan vs Colombia (Group K)
  {
    docId: createDocId('UZB', 'COL'),
    data: {
      team1Code: 'UZB',
      team2Code: 'COL',
      team1Name: 'Uzbekistan',
      team2Name: 'Colombia',
      historicalAnalysis: `This is a first ever meeting between Uzbekistan and Colombia. Uzbekistan make their World Cup debut after years of near-misses, emerging from a competitive Asian qualifying campaign. Colombia return to the World Cup after missing 2022.

Uzbekistan's qualification represents Asian football's growing depth. Their technical, possession-based style is influenced by decades of Soviet-era coaching traditions, creating players who are comfortable on the ball.

Colombia's absence from Qatar 2022 was a shock, but this squad featuring James Rodríguez, Luis Díaz, and a host of young talents is ready to make an impact.`,
      keyStorylines: [
        'Uzbekistan\'s historic World Cup debut',
        'Colombia seeking redemption after missing 2022',
        'Central Asian technical football vs South American flair',
        'First ever meeting between these nations',
      ],
      playersToWatch: [
        { name: 'Luis Díaz', teamCode: 'COL', position: 'Winger', reason: 'Liverpool\'s electrifying winger and Colombia\'s talisman' },
        { name: 'Eldor Shomurodov', teamCode: 'UZB', position: 'Forward', reason: 'Roma striker leading Uzbekistan\'s attack' },
        { name: 'James Rodríguez', teamCode: 'COL', position: 'Midfielder', reason: 'The 2014 World Cup Golden Boot winner still producing magic' },
        { name: 'Jaloliddin Masharipov', teamCode: 'UZB', position: 'Midfielder', reason: 'Creative playmaker pulling the strings' },
      ],
      tacticalPreview: `Colombia's 4-3-3 emphasizes attacking intent, with Díaz and Arias providing width. James operates in the pocket, and their pressing has improved dramatically.

Uzbekistan's 4-2-3-1 focuses on possession and patient buildup. Shomurodov's hold-up play creates space for runners, and they won't be intimidated by Colombia's reputation.`,
      prediction: {
        predictedOutcome: 'COL',
        predictedScore: '2-1',
        confidence: 68,
        reasoning: 'Colombia\'s superior attacking talent should prove decisive, but Uzbekistan\'s technical quality will make this competitive.',
        alternativeScenario: 'If Uzbekistan\'s defense holds firm and they take their chances, a shock draw is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'James Rodríguez won the 2014 World Cup Golden Boot with 6 goals',
        'Uzbekistan came agonizingly close to qualifying for 2018, losing to Australia in playoffs',
        'Colombia\'s 2014 World Cup quarter-final run was their best ever',
        'Shomurodov became the first Uzbek player in Serie A',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 25: Ghana vs Panama (Group L)
  {
    docId: createDocId('GHA', 'PAN'),
    data: {
      team1Code: 'GHA',
      team2Code: 'PAN',
      team1Name: 'Ghana',
      team2Name: 'Panama',
      historicalAnalysis: `Ghana and Panama meet for the first time in World Cup history. Ghana are four-time AFCON champions with a proud World Cup tradition—their 2010 quarter-final run remains one of Africa's greatest World Cup achievements.

Panama made their World Cup debut in 2018, where the experience of simply being there seemed to overwhelm them. Now, with a more experienced squad, they return with greater ambitions.

This is a crucial match for both teams' knockout round hopes in a tough group with England and Croatia.`,
      keyStorylines: [
        'Ghana\'s proud World Cup tradition vs Panama\'s growing experience',
        'First ever meeting between these nations',
        'Battle for potential third place in Group L',
        'African power vs CONCACAF rising force',
      ],
      playersToWatch: [
        { name: 'Mohammed Kudus', teamCode: 'GHA', position: 'Midfielder', reason: 'West Ham\'s dazzling talent and Ghana\'s main creator' },
        { name: 'José Fajardo', teamCode: 'PAN', position: 'Forward', reason: 'Panama\'s experienced striker leading the line' },
        { name: 'Thomas Partey', teamCode: 'GHA', position: 'Midfielder', reason: 'Arsenal\'s midfield anchor controlling the game' },
        { name: 'Adalberto Carrasquilla', teamCode: 'PAN', position: 'Midfielder', reason: 'MLS star providing energy and creativity' },
      ],
      tacticalPreview: `Ghana's 4-2-3-1 unleashes Kudus in the No. 10 role, with Partey providing defensive security. Their combination of power and technique is formidable.

Panama's 4-4-2 is compact and disciplined. They'll look to frustrate Ghana and hit on counter-attacks, with aerial threats from set-pieces a key weapon.`,
      prediction: {
        predictedOutcome: 'GHA',
        predictedScore: '2-0',
        confidence: 65,
        reasoning: 'Ghana\'s superior individual quality, particularly Kudus and Partey, should prove decisive. Panama will compete but lack the cutting edge.',
        alternativeScenario: 'If Panama\'s physical approach disrupts Ghana\'s rhythm, a 1-0 win either way is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Ghana reached the World Cup quarter-finals in 2010, Africa\'s best modern performance',
        'Panama scored their first ever World Cup goal against England in 2018',
        'Kudus was West Ham\'s record signing and has been one of the Premier League\'s best players',
        'Panama\'s 2018 World Cup qualification ended a 41-year wait',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 26: Mexico vs South Korea (Group A)
  {
    docId: createDocId('MEX', 'KOR'),
    data: {
      team1Code: 'MEX',
      team2Code: 'KOR',
      team1Name: 'Mexico',
      team2Name: 'South Korea',
      historicalAnalysis: `Mexico and South Korea have met twice at World Cups, both matches won by Mexico. In 2018, Mexico won 2-1 in Rostov, while their 1998 meeting ended 3-1 to El Tri. However, South Korea's 2022 World Cup performance showed they can compete with anyone.

Both nations share a similar frustration—they consistently qualify but struggle to advance deep into tournaments. Mexico's Round of 16 curse is well-documented, while South Korea's 2002 semi-final run remains an outlier in their history.

As co-hosts, Mexico have extra pressure to perform. South Korea's dynamic attacking play and pressing intensity will provide a stern test.`,
      keyStorylines: [
        'Mexico\'s Round of 16 curse vs South Korea\'s deep run aspirations',
        'Co-hosts needing to maintain momentum after the opener',
        'Two of Asia and North America\'s most consistent qualifiers',
        'Mexico\'s historical dominance in this fixture',
      ],
      playersToWatch: [
        { name: 'Son Heung-min', teamCode: 'KOR', position: 'Forward', reason: 'Tottenham captain and one of Asia\'s greatest ever players' },
        { name: 'Santiago Giménez', teamCode: 'MEX', position: 'Forward', reason: 'Feyenoord\'s prolific striker' },
        { name: 'Lee Kang-in', teamCode: 'KOR', position: 'Midfielder', reason: 'PSG\'s creative spark and Korea\'s playmaker' },
        { name: 'Hirving Lozano', teamCode: 'MEX', position: 'Winger', reason: 'PSV\'s explosive winger providing pace and goals' },
      ],
      tacticalPreview: `Mexico's 4-3-3 will look to control possession and create through wide areas. Giménez's movement and finishing are key, with Lozano's pace stretching defenses.

South Korea's 4-3-3 emphasizes pressing and quick transitions. Son's ability to drift and create, combined with Lee Kang-in's creativity, makes them dangerous in transition.`,
      prediction: {
        predictedOutcome: 'MEX',
        predictedScore: '2-1',
        confidence: 58,
        reasoning: 'Home advantage and Mexico\'s historical dominance give them an edge, but South Korea\'s quality makes this a close encounter.',
        alternativeScenario: 'If Son dominates and Korea\'s pressing works, they could spring an upset 2-1 win.',
      },
      pastEncountersSummary: 'Two World Cup meetings, both won by Mexico (3-1 in 1998, 2-1 in 2018).',
      funFacts: [
        'Son Heung-min has scored more than 100 goals for Tottenham',
        'Mexico have won their last 4 matches against South Korea',
        'Lee Kang-in won the Golden Ball at the 2019 U-20 World Cup',
        'South Korea reached the 2002 World Cup semi-finals as co-hosts',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 28: Canada vs Qatar (Group B)
  {
    docId: createDocId('CAN', 'QAT'),
    data: {
      team1Code: 'CAN',
      team2Code: 'QAT',
      team1Name: 'Canada',
      team2Name: 'Qatar',
      historicalAnalysis: `Canada and Qatar meet for the first time in World Cup history. Canada are co-hosting this tournament, returning to the World Cup for only the second time in their history (after 1986). Qatar are the 2022 hosts looking for redemption after a disappointing home campaign.

Canada's 2022 World Cup was brief but showed their potential—they scored against Belgium and Croatia but failed to earn a point. With home advantage and an improved squad, expectations are higher now.

Qatar's 2022 campaign saw them become the worst-performing host nation ever, losing all three group games. Their Asian Cup win in 2023 showed they can still compete at the continental level.`,
      keyStorylines: [
        'Canada co-hosting their first World Cup since 1986',
        'Qatar seeking redemption after disappointing 2022 performance',
        'First ever meeting between these nations',
        'Former host vs current co-host',
      ],
      playersToWatch: [
        { name: 'Alphonso Davies', teamCode: 'CAN', position: 'Defender', reason: 'Bayern Munich\'s lightning-fast left-back' },
        { name: 'Akram Afif', teamCode: 'QAT', position: 'Winger', reason: 'Asian Player of the Year' },
        { name: 'Jonathan David', teamCode: 'CAN', position: 'Forward', reason: 'Lille\'s prolific striker with a killer instinct' },
        { name: 'Almoez Ali', teamCode: 'QAT', position: 'Forward', reason: 'Qatar\'s record scorer' },
      ],
      tacticalPreview: `Canada's 4-3-3 unleashes Davies as an attacking wing-back, with David leading the line. Their pace in transition is frightening, and home support will drive aggressive pressing.

Qatar's 5-3-2 will be more conservative after 2022's lessons. They'll look to be compact and hit on counters through Afif's creativity.`,
      prediction: {
        predictedOutcome: 'CAN',
        predictedScore: '2-0',
        confidence: 70,
        reasoning: 'Home advantage and Canada\'s superior attacking threats should prove decisive. Qatar\'s confidence remains fragile after 2022.',
        alternativeScenario: 'If Qatar start well and Canada struggle with pressure, a 1-1 draw is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Canada last hosted a FIFA tournament in 1987 (U-16 World Cup)',
        'Qatar won the Asian Cup in 2019 and 2023',
        'Davies became Bayern Munich\'s youngest ever Champions League scorer',
        'This is Canada\'s first World Cup on home soil',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 29: Scotland vs Morocco (Group C)
  {
    docId: createDocId('MAR', 'SCO'),
    data: {
      team1Code: 'SCO',
      team2Code: 'MAR',
      team1Name: 'Scotland',
      team2Name: 'Morocco',
      historicalAnalysis: `Scotland and Morocco have met only once before—a 1998 World Cup group match that ended 3-0 to Morocco. That result helped Morocco finish top of their group in one of their best World Cup performances.

Morocco's 2022 World Cup semi-final run was historic—the first African and Arab nation to reach that stage. Their defensive organization and spirit captured hearts worldwide, and they enter 2026 as Africa's best hope.

Scotland return to the World Cup desperate to finally progress beyond the group stage. Their Premier League-laden squad has never been stronger.`,
      keyStorylines: [
        'Morocco\'s historic 2022 squad seeking more glory',
        'Scotland\'s never-ending quest for knockout round football',
        'Rematch of 1998 World Cup encounter',
        'Africa\'s best vs Scotland\'s best in decades',
      ],
      playersToWatch: [
        { name: 'Achraf Hakimi', teamCode: 'MAR', position: 'Defender', reason: 'PSG\'s world-class right-back' },
        { name: 'John McGinn', teamCode: 'SCO', position: 'Midfielder', reason: 'Aston Villa captain leading from the front' },
        { name: 'Hakim Ziyech', teamCode: 'MAR', position: 'Midfielder', reason: 'Morocco\'s creative genius' },
        { name: 'Che Adams', teamCode: 'SCO', position: 'Forward', reason: 'Torino striker providing physical presence' },
      ],
      tacticalPreview: `Morocco's 4-3-3 is built on defensive solidity first. Hakimi provides attacking thrust from right-back, while Ziyech's creativity unlocks defenses.

Scotland's 3-5-2 provides width through wing-backs and bodies in midfield. McGinn's energy will be crucial in combating Morocco's technical midfield.`,
      prediction: {
        predictedOutcome: 'MAR',
        predictedScore: '2-1',
        confidence: 62,
        reasoning: 'Morocco\'s tournament experience and superior individual quality should prove decisive, but Scotland will make it competitive.',
        alternativeScenario: 'If Scotland\'s pressing disrupts Morocco\'s buildup, a 1-1 draw is realistic.',
      },
      pastEncountersSummary: 'One previous meeting: Morocco won 3-0 at the 1998 World Cup.',
      funFacts: [
        'Morocco became the first African team to reach a World Cup semi-final in 2022',
        'Scotland have never progressed past the World Cup group stage',
        'Hakimi is considered one of the best right-backs in the world',
        'Scotland\'s last World Cup was in 1998—against Morocco\'s group',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 30: Brazil vs Haiti (Group C)
  {
    docId: createDocId('BRA', 'HAI'),
    data: {
      team1Code: 'BRA',
      team2Code: 'HAI',
      team1Name: 'Brazil',
      team2Name: 'Haiti',
      historicalAnalysis: `Brazil and Haiti have met just once—a 2016 Copa América Centenario match that Brazil won 7-1. That scoreline reflected the gulf in quality, but Haiti's mere presence at another major tournament shows their progress.

Brazil enter seeking to end their World Cup drought—they haven't lifted the trophy since 2002, their longest wait since the tournament began. After 2022's painful quarter-final exit, the pressure is immense.

Haiti's first World Cup in 52 years is about creating memories and inspiring the next generation. Playing Brazil, football's most decorated nation, is the ultimate test.`,
      keyStorylines: [
        'Brazil\'s quest to end their longest World Cup drought',
        'Haiti\'s historic return to the World Cup after 52 years',
        'Five-time champions vs Caribbean underdogs',
        'Rematch of 2016 Copa América encounter (7-1 Brazil)',
      ],
      playersToWatch: [
        { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'Real Madrid superstar and Ballon d\'Or contender' },
        { name: 'Frantzdy Pierrot', teamCode: 'HAI', position: 'Forward', reason: 'Haiti\'s powerful target man' },
        { name: 'Rodrygo', teamCode: 'BRA', position: 'Forward', reason: 'Real Madrid\'s clinical finisher' },
        { name: 'Derrick Etienne Jr.', teamCode: 'HAI', position: 'Winger', reason: 'MLS winger providing pace' },
      ],
      tacticalPreview: `Brazil's 4-2-3-1 maximizes attacking firepower with Vinícius and Rodrygo terrorizing flanks. Their quick passing and movement should create numerous chances.

Haiti's 5-4-1 will park the bus and hope to survive. Their gameplan is damage limitation while looking for any counter-attacking opportunity or set-piece moment.`,
      prediction: {
        predictedOutcome: 'BRA',
        predictedScore: '4-0',
        confidence: 92,
        reasoning: 'The quality difference is enormous. Brazil should dominate possession and score at will against Haiti\'s defense.',
        alternativeScenario: 'If Brazil are complacent and Haiti defend heroically, a "modest" 2-0 win with Haiti frustrating the favorites.',
      },
      pastEncountersSummary: 'One meeting: Brazil won 7-1 at Copa América Centenario 2016.',
      funFacts: [
        'Haiti\'s 1974 World Cup squad included Emmanuel Sanon, who scored against Italy',
        'Brazil have won 5 World Cups—more than any other nation',
        'Haiti are making their first World Cup appearance in 52 years',
        'Vinícius Jr. scored in the 2024 Champions League final',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 34: Ecuador vs Curaçao (Group F)
  {
    docId: createDocId('ECU', 'CUR'),
    data: {
      team1Code: 'ECU',
      team2Code: 'CUR',
      team1Name: 'Ecuador',
      team2Name: 'Curaçao',
      historicalAnalysis: `This is a first ever meeting between Ecuador and Curaçao. Ecuador are experienced World Cup participants, having qualified for 4 of the last 5 tournaments. Curaçao make their historic debut as the smallest nation ever to qualify.

Ecuador's 2022 World Cup saw them beat Qatar and draw with the Netherlands before losing to Senegal. Their young, dynamic squad has only improved since.

For Curaçao, every moment is historic. Their journey from tiny Caribbean island to the World Cup stage is one of football's great underdog stories.`,
      keyStorylines: [
        'Ecuador\'s experienced squad vs World Cup debutants',
        'South American quality vs Caribbean passion',
        'First ever meeting between these nations',
        'Ecuador seeking to build on 2022 progress',
      ],
      playersToWatch: [
        { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'Chelsea\'s world-class midfielder' },
        { name: 'Juninho Bacuna', teamCode: 'CUR', position: 'Midfielder', reason: 'Curaçao\'s experienced Championship player' },
        { name: 'Kendry Páez', teamCode: 'ECU', position: 'Midfielder', reason: 'Teenage sensation signed by Chelsea' },
        { name: 'Kenji Gorré', teamCode: 'CUR', position: 'Winger', reason: 'Tricky winger with pace' },
      ],
      tacticalPreview: `Ecuador's 4-4-2 emphasizes quick passing and energetic pressing. Caicedo controls the midfield, while their forwards combine power with pace.

Curaçao's 5-4-1 is purely defensive. They'll aim to stay in the game and create memorable moments through counter-attacks and set-pieces.`,
      prediction: {
        predictedOutcome: 'ECU',
        predictedScore: '3-0',
        confidence: 85,
        reasoning: 'Ecuador\'s quality advantage is substantial. Their movement and technical ability should overwhelm Curaçao.',
        alternativeScenario: 'If Curaçao defend bravely, a 1-0 Ecuador win with growing frustration is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Curaçao is a constituent country of the Netherlands with a population of 150,000',
        'Ecuador\'s Caicedo is worth over £100 million',
        'This is Curaçao\'s World Cup debut',
        'Kendry Páez was 15 when signed by Chelsea',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 36: Tunisia vs Japan (Group E)
  {
    docId: createDocId('TUN', 'JPN'),
    data: {
      team1Code: 'TUN',
      team2Code: 'JPN',
      team1Name: 'Tunisia',
      team2Name: 'Japan',
      historicalAnalysis: `Tunisia and Japan have never met at a World Cup. Both nations have consistent World Cup pedigrees—Japan have qualified for every tournament since 1998, while Tunisia have appeared in 6 World Cups.

Japan's 2022 World Cup saw remarkable victories over Germany and Spain in the group stage before losing to Croatia on penalties. Their blend of technical precision and European-based stars makes them formidable.

Tunisia's 2022 campaign featured a famous win over France, showing they can compete with anyone when their organization and intensity are right.`,
      keyStorylines: [
        'Two consistent World Cup qualifiers meeting for the first time',
        'Japan seeking to build on Germany and Spain scalps',
        'Tunisia aiming to replicate their 2022 upset of France',
        'Asian precision vs African resilience',
      ],
      playersToWatch: [
        { name: 'Takefusa Kubo', teamCode: 'JPN', position: 'Winger', reason: 'Real Sociedad\'s creative spark and La Liga star' },
        { name: 'Hannibal Mejbri', teamCode: 'TUN', position: 'Midfielder', reason: 'Manchester United\'s Tunisian talent' },
        { name: 'Kaoru Mitoma', teamCode: 'JPN', position: 'Winger', reason: 'Brighton\'s dazzling dribbler' },
        { name: 'Wahbi Khazri', teamCode: 'TUN', position: 'Forward', reason: 'Tunisia\'s experienced talisman' },
      ],
      tacticalPreview: `Japan's 4-2-3-1 emphasizes technical football and quick transitions. Kubo and Mitoma's dribbling can unlock any defense, while their pressing is relentless.

Tunisia's 4-3-3 is built on defensive organization first. They'll look to frustrate Japan and hit on counter-attacks, with Khazri providing the creative spark.`,
      prediction: {
        predictedOutcome: 'JPN',
        predictedScore: '2-1',
        confidence: 60,
        reasoning: 'Japan\'s superior individual quality and tactical sophistication should prove decisive, but Tunisia\'s organization makes it competitive.',
        alternativeScenario: 'If Tunisia\'s pressing disrupts Japan\'s buildup, a 1-1 draw is very possible.',
      },
      pastEncountersSummary: 'First ever World Cup meeting. No significant history.',
      funFacts: [
        'Japan beat Germany and Spain at the 2022 World Cup',
        'Tunisia beat France 1-0 at the 2022 World Cup',
        'Mitoma\'s dribbling has been compared to Messi',
        'This is Tunisia\'s 6th World Cup appearance',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 38: Belgium vs Iran (Group H)
  {
    docId: createDocId('BEL', 'IRN'),
    data: {
      team1Code: 'BEL',
      team2Code: 'IRN',
      team1Name: 'Belgium',
      team2Name: 'Iran',
      historicalAnalysis: `Belgium and Iran met at the 2018 World Cup, with Belgium winning 1-0 through a late Lukaku goal. That match was tighter than expected, with Iran's organization frustrating Belgium for long periods.

Belgium's golden generation is evolving—De Bruyne and Lukaku remain, but younger talents like Doku and Openda are now key players. Their 2022 World Cup was disappointing, crashing out in the group stage.

Iran continue to be Asia's most consistent World Cup qualifiers. Their 2022 campaign included an emotional 2-0 win over Wales, proving their ability to deliver on the big stage.`,
      keyStorylines: [
        'Rematch of 2018 World Cup encounter',
        'Belgium\'s new generation vs Iran\'s experienced squad',
        'Belgium seeking redemption after 2022 group stage exit',
        'Taremi and Azmoun vs Belgium\'s defense',
      ],
      playersToWatch: [
        { name: 'Kevin De Bruyne', teamCode: 'BEL', position: 'Midfielder', reason: 'Manchester City\'s genius pulling the strings' },
        { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Forward', reason: 'Inter Milan\'s clinical striker' },
        { name: 'Jérémy Doku', teamCode: 'BEL', position: 'Winger', reason: 'Manchester City\'s explosive dribbler' },
        { name: 'Sardar Azmoun', teamCode: 'IRN', position: 'Forward', reason: 'Iran\'s "Iranian Messi"' },
      ],
      tacticalPreview: `Belgium's 4-3-3 maximizes De Bruyne's creativity, with Doku providing pace on the wing. Their transition play can devastate any defense.

Iran's 4-3-3 emphasizes defensive solidity and clinical counter-attacks. Taremi and Azmoun's partnership is world-class and can hurt any team.`,
      prediction: {
        predictedOutcome: 'BEL',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'Belgium\'s individual quality should prove decisive, but Iran\'s attacking threat makes this closer than expected.',
        alternativeScenario: 'If Taremi and Azmoun fire, Iran could spring an upset 1-0 victory.',
      },
      pastEncountersSummary: 'One World Cup meeting: Belgium won 1-0 in 2018 with a late Lukaku goal.',
      funFacts: [
        'Iran almost took a point off Belgium in 2018, hitting the post twice',
        'De Bruyne has won 6 Premier League titles with Manchester City',
        'Taremi has scored in both the Champions League and Europa League finals',
        'Belgium reached a World Cup semi-final in 2018',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 39: New Zealand vs Egypt (Group H)
  {
    docId: createDocId('EGY', 'NZL'),
    data: {
      team1Code: 'NZL',
      team2Code: 'EGY',
      team1Name: 'New Zealand',
      team2Name: 'Egypt',
      historicalAnalysis: `New Zealand and Egypt meet for the first time at a World Cup. Egypt return to the tournament after missing 2022, with Mohamed Salah leading a talented squad. New Zealand are the perennial Oceania champions making their third World Cup appearance.

Egypt's absence from 2022 was painful after reaching the 2018 tournament and the 2022 AFCON final. With Salah at his peak, this is a crucial opportunity to showcase Egyptian football.

New Zealand remain unbeaten in World Cup history (3 draws in 2010), and their organization and spirit make them difficult opponents for anyone.`,
      keyStorylines: [
        'Mohamed Salah leading Egypt\'s World Cup return',
        'New Zealand\'s historic unbeaten World Cup record at stake',
        'First ever meeting between these nations',
        'African giants vs Oceania champions',
      ],
      playersToWatch: [
        { name: 'Mohamed Salah', teamCode: 'EGY', position: 'Forward', reason: 'Liverpool legend and one of the world\'s best' },
        { name: 'Chris Wood', teamCode: 'NZL', position: 'Forward', reason: 'Premier League-proven striker' },
        { name: 'Mohamed Elneny', teamCode: 'EGY', position: 'Midfielder', reason: 'Experienced Arsenal midfielder' },
        { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'Empoli\'s attacking left-back' },
      ],
      tacticalPreview: `Egypt's 4-3-3 is built around Salah's brilliance on the right. Their attacking play flows through him, and his pace and finishing are world-class.

New Zealand's 4-4-2 is organized and disciplined. Wood's aerial presence creates opportunities, and they'll look to frustrate Egypt with set-piece threats.`,
      prediction: {
        predictedOutcome: 'EGY',
        predictedScore: '2-0',
        confidence: 70,
        reasoning: 'Salah\'s quality is the difference. Egypt\'s attacking firepower should be too much for New Zealand\'s defense.',
        alternativeScenario: 'If New Zealand\'s organization holds and Wood scores, a 1-1 draw extending their unbeaten record is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'New Zealand are unbeaten in World Cup history (3 draws in 2010)',
        'Salah has scored over 200 goals for Liverpool',
        'Egypt have won the AFCON a record 7 times',
        'Wood has scored 50+ Premier League goals',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 40: Uruguay vs Cape Verde (Group G)
  {
    docId: createDocId('URU', 'CPV'),
    data: {
      team1Code: 'URU',
      team2Code: 'CPV',
      team1Name: 'Uruguay',
      team2Name: 'Cape Verde',
      historicalAnalysis: `This is a historic first meeting between Uruguay and Cape Verde. Uruguay are two-time World Cup champions with a proud footballing tradition. Cape Verde make their World Cup debut as one of Africa's emerging nations.

Uruguay's blend of experienced stars like Valverde and emerging talents like Núñez makes them dark horse candidates. Their defensive organization and clinical finishing are trademark strengths.

Cape Verde's qualification is remarkable for a nation of just 500,000 people. Their technical, Portuguese-influenced style has produced notable players who feature in European leagues.`,
      keyStorylines: [
        'Cape Verde\'s historic World Cup debut',
        'Two-time World Cup champions vs tiny island nation',
        'First ever meeting between these nations',
        'Uruguay seeking deep tournament run',
      ],
      playersToWatch: [
        { name: 'Darwin Núñez', teamCode: 'URU', position: 'Forward', reason: 'Liverpool\'s explosive striker' },
        { name: 'Ryan Mendes', teamCode: 'CPV', position: 'Winger', reason: 'Cape Verde\'s most dangerous attacker' },
        { name: 'Federico Valverde', teamCode: 'URU', position: 'Midfielder', reason: 'Real Madrid\'s all-action midfielder' },
        { name: 'Garry Rodrigues', teamCode: 'CPV', position: 'Forward', reason: 'Experienced striker with European pedigree' },
      ],
      tacticalPreview: `Uruguay's 4-4-2 provides defensive solidity while Núñez's pace threatens on counters. Valverde's energy adds another dimension to their attack.

Cape Verde's 4-4-2 will be compact and disciplined, looking to frustrate Uruguay and take any counter-attacking opportunity.`,
      prediction: {
        predictedOutcome: 'URU',
        predictedScore: '3-0',
        confidence: 82,
        reasoning: 'Uruguay\'s quality advantage is significant. Their attacking firepower should overwhelm Cape Verde\'s defense.',
        alternativeScenario: 'If Cape Verde defend bravely, a 1-0 Uruguay win with growing frustration is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Uruguay won the first ever World Cup in 1930',
        'Cape Verde has a population of about 500,000',
        'Valverde is considered one of the best midfielders in the world',
        'This is Cape Verde\'s World Cup debut',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 41: Argentina vs Austria (Group J)
  {
    docId: createDocId('ARG', 'AUT'),
    data: {
      team1Code: 'ARG',
      team2Code: 'AUT',
      team1Name: 'Argentina',
      team2Name: 'Austria',
      historicalAnalysis: `Argentina and Austria have met 7 times, with Argentina winning 5. Their most notable World Cup encounter was the 1978 group stage in Argentina, where the hosts won 2-1 en route to their first World Cup title.

Argentina enter as reigning World Cup and Copa América champions, with Messi seeking one final moment of glory. This is likely his last World Cup, and the team is determined to send him off in style.

Austria have improved dramatically under Rangnick's gegenpressing system. Their Nations League performances have shown they can compete with Europe's best, and Alaba's leadership is invaluable.`,
      keyStorylines: [
        'Messi\'s last World Cup vs Rangnick\'s pressing machine',
        'Reigning champions vs European dark horses',
        'Argentina\'s historical advantage in this fixture',
        'Two contrasting styles: Argentine flair vs Austrian intensity',
      ],
      playersToWatch: [
        { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The GOAT in his final World Cup' },
        { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'Real Madrid legend and Austrian captain' },
        { name: 'Julián Álvarez', teamCode: 'ARG', position: 'Forward', reason: 'Man City striker who starred in 2022' },
        { name: 'Marcel Sabitzer', teamCode: 'AUT', position: 'Midfielder', reason: 'Dortmund\'s energetic midfielder' },
      ],
      tacticalPreview: `Argentina's 4-3-3 under Scaloni is built on collective excellence. Messi still provides moments of magic, but Álvarez, Mac Allister, and Enzo Fernández offer goals and creativity.

Austria's 4-2-3-1 emphasizes intense pressing and quick transitions. Their energy could disrupt Argentina's rhythm, with Sabitzer and Laimer providing box-to-box intensity.`,
      prediction: {
        predictedOutcome: 'ARG',
        predictedScore: '2-0',
        confidence: 72,
        reasoning: 'Argentina\'s winning mentality and superior quality should prove decisive. Austria will compete but lack the cutting edge against the champions.',
        alternativeScenario: 'If Austria\'s pressing disrupts Argentina\'s buildup and Alaba marshals the defense, a 1-1 draw is possible.',
      },
      pastEncountersSummary: '7 meetings with Argentina winning 5. The 1978 World Cup match (2-1 Argentina) came during their title-winning campaign.',
      funFacts: [
        'Messi has won more individual awards than any player in history',
        'Austria\'s best World Cup finish was third place in 1954',
        'Argentina\'s 2022 World Cup win was their third title',
        'Alaba has won more than 20 major trophies',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 43: Jordan vs Algeria (Group J)
  {
    docId: createDocId('ALG', 'JOR'),
    data: {
      team1Code: 'JOR',
      team2Code: 'ALG',
      team1Name: 'Jordan',
      team2Name: 'Algeria',
      historicalAnalysis: `This is a first ever meeting between Jordan and Algeria, two nations making major strides in world football. Jordan make their World Cup debut after reaching the 2023 Asian Cup final, while Algeria seek redemption after missing 2022.

Algeria won the 2019 AFCON and were disappointed to miss the 2022 World Cup. Their squad features European-based talent and plays attractive, attacking football.

Jordan's qualification is historic for a nation that has often come close but never reached the World Cup. Their organized, disciplined approach proved decisive in Asian qualifying.`,
      keyStorylines: [
        'Jordan\'s historic World Cup debut vs AFCON champions',
        'First ever meeting between these nations',
        'Two Arab nations battling for knockout round hopes',
        'Asian Cup finalists vs AFCON winners',
      ],
      playersToWatch: [
        { name: 'Riyad Mahrez', teamCode: 'ALG', position: 'Winger', reason: 'Saudi Pro League star and Algeria\'s creative hub' },
        { name: 'Mousa Al-Taamari', teamCode: 'JOR', position: 'Winger', reason: 'Montpellier\'s tricky winger' },
        { name: 'Ismaël Bennacer', teamCode: 'ALG', position: 'Midfielder', reason: 'AC Milan\'s midfield anchor' },
        { name: 'Yazan Al-Naimat', teamCode: 'JOR', position: 'Forward', reason: 'Young striker with composure' },
      ],
      tacticalPreview: `Algeria's 4-3-3 emphasizes possession and quick combinations. Mahrez's creativity from the right is crucial, with Bennacer controlling the midfield.

Jordan's 4-4-2 is compact and disciplined. They'll look to frustrate Algeria and hit on counter-attacks through Al-Taamari's pace and skill.`,
      prediction: {
        predictedOutcome: 'ALG',
        predictedScore: '2-1',
        confidence: 60,
        reasoning: 'Algeria\'s superior individual quality should prove decisive, but Jordan\'s organization and spirit will make this competitive.',
        alternativeScenario: 'If Jordan\'s defense holds and they take their chances, a historic draw is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Jordan reached the 2023 Asian Cup final, losing 3-1 to Qatar',
        'Algeria won the 2019 AFCON without losing a game',
        'This is Jordan\'s first World Cup appearance',
        'Mahrez scored the goal that won Algeria the 2019 AFCON',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 44: Norway vs Senegal (Group I)
  {
    docId: createDocId('NOR', 'SEN'),
    data: {
      team1Code: 'NOR',
      team2Code: 'SEN',
      team1Name: 'Norway',
      team2Name: 'Senegal',
      historicalAnalysis: `Norway and Senegal meet for the first time in World Cup history. Norway return to the tournament for the first time since 1998, led by Erling Haaland, one of the world's most prolific strikers.

Senegal are the reigning AFCON champions (2022) and reached the 2022 World Cup Round of 16 before losing to England. Their physical, technically gifted squad is one of Africa's best.

This match pits Haaland's goal-scoring brilliance against Senegal's organized, physical defense—a fascinating tactical battle.`,
      keyStorylines: [
        'Haaland\'s World Cup debut vs AFCON champions',
        'Norway\'s first World Cup since 1998',
        'First ever meeting between these nations',
        'Europe\'s best striker vs Africa\'s best defense',
      ],
      playersToWatch: [
        { name: 'Erling Haaland', teamCode: 'NOR', position: 'Forward', reason: 'Manchester City\'s record-breaking striker' },
        { name: 'Sadio Mané', teamCode: 'SEN', position: 'Forward', reason: 'AFCON hero and Senegal\'s talisman' },
        { name: 'Martin Ødegaard', teamCode: 'NOR', position: 'Midfielder', reason: 'Arsenal captain providing the creativity' },
        { name: 'Kalidou Koulibaly', teamCode: 'SEN', position: 'Defender', reason: 'Experienced defender tasked with stopping Haaland' },
      ],
      tacticalPreview: `Norway's 4-3-3 is designed to maximize Haaland's goal threat. Ødegaard's creativity and the team's pressing create chances for their lethal striker.

Senegal's 4-3-3 emphasizes physicality and organization. Koulibaly's battle with Haaland could decide the match, with Mané providing counter-attacking threat.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 55,
        reasoning: 'Two evenly matched sides with different strengths. Haaland and Mané should both score in a tight, entertaining encounter.',
        alternativeScenario: 'If Haaland is isolated and Senegal dominate midfield, a 2-0 Senegal win is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Haaland scored 52 goals in his first season at Manchester City',
        'Senegal won their first ever AFCON in 2022',
        'Norway last played at a World Cup in 1998',
        'Mané scored the winning penalty in the 2022 AFCON final',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 46: Portugal vs Uzbekistan (Group K)
  {
    docId: createDocId('POR', 'UZB'),
    data: {
      team1Code: 'POR',
      team2Code: 'UZB',
      team1Name: 'Portugal',
      team2Name: 'Uzbekistan',
      historicalAnalysis: `This is a first ever meeting between Portugal and Uzbekistan. Portugal are one of Europe's established powers, with Cristiano Ronaldo potentially making his final World Cup appearance. Uzbekistan make their historic debut after years of near-misses in Asian qualifying.

Portugal's 2022 World Cup ended in quarter-final heartbreak against Morocco. They return with a blend of experienced stars and emerging talents like Rafael Leão and João Neves.

Uzbekistan's qualification represents years of development in Central Asian football. Their technical, possession-based style could surprise opponents.`,
      keyStorylines: [
        'Potentially Ronaldo\'s last World Cup',
        'Uzbekistan\'s historic World Cup debut',
        'First ever meeting between these nations',
        'European giants vs Asian debutants',
      ],
      playersToWatch: [
        { name: 'Cristiano Ronaldo', teamCode: 'POR', position: 'Forward', reason: 'The all-time top international scorer' },
        { name: 'Eldor Shomurodov', teamCode: 'UZB', position: 'Forward', reason: 'Roma striker leading the line' },
        { name: 'Rafael Leão', teamCode: 'POR', position: 'Winger', reason: 'AC Milan\'s explosive talent' },
        { name: 'Jaloliddin Masharipov', teamCode: 'UZB', position: 'Midfielder', reason: 'Creative playmaker' },
      ],
      tacticalPreview: `Portugal's 4-3-3 provides multiple attacking threats. Leão's pace, Bruno Fernandes' creativity, and Ronaldo's finishing create a formidable frontline.

Uzbekistan's 4-2-3-1 focuses on possession and patient buildup. Shomurodov's hold-up play creates space, and they won't be intimidated by Portugal's reputation.`,
      prediction: {
        predictedOutcome: 'POR',
        predictedScore: '3-0',
        confidence: 80,
        reasoning: 'Portugal\'s quality advantage is significant. Their attacking firepower should overwhelm Uzbekistan\'s defense.',
        alternativeScenario: 'If Uzbekistan\'s defense holds firm, a 1-0 Portugal win with growing frustration is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Ronaldo has scored more international goals than any player in history',
        'Uzbekistan have come close to qualifying in previous World Cup cycles',
        'This is Uzbekistan\'s first World Cup appearance',
        'Portugal reached the 2006 World Cup semi-finals',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 49: Morocco vs Haiti (Group C)
  {
    docId: createDocId('HAI', 'MAR'),
    data: {
      team1Code: 'MAR',
      team2Code: 'HAI',
      team1Name: 'Morocco',
      team2Name: 'Haiti',
      historicalAnalysis: `This is a first ever meeting between Morocco and Haiti. Morocco are the 2022 World Cup semi-finalists, making history as the first African and Arab nation to reach that stage. Haiti return to the World Cup for the first time since 1974.

Morocco's 2022 run captured hearts worldwide—victories over Belgium, Spain, and Portugal were remarkable. They enter 2026 with expectations of repeating or exceeding that performance.

Haiti's qualification after 52 years is one of the great underdog stories. Their passionate fanbase and fearless approach make them entertaining opponents.`,
      keyStorylines: [
        'Morocco seeking to repeat 2022 heroics',
        'Haiti\'s first World Cup in 52 years',
        'First ever meeting between these nations',
        'Africa\'s best vs Caribbean underdogs',
      ],
      playersToWatch: [
        { name: 'Achraf Hakimi', teamCode: 'MAR', position: 'Defender', reason: 'PSG\'s world-class right-back' },
        { name: 'Frantzdy Pierrot', teamCode: 'HAI', position: 'Forward', reason: 'Haiti\'s powerful target man' },
        { name: 'Hakim Ziyech', teamCode: 'MAR', position: 'Midfielder', reason: 'Morocco\'s creative genius' },
        { name: 'Derrick Etienne Jr.', teamCode: 'HAI', position: 'Winger', reason: 'MLS winger with pace' },
      ],
      tacticalPreview: `Morocco's 4-3-3 is built on defensive solidity and clinical counter-attacks. Hakimi's marauding runs and Ziyech's creativity are key weapons.

Haiti's 4-3-3 will be organized but attacking when possible. They won't park the bus, preferring to compete and create memorable moments.`,
      prediction: {
        predictedOutcome: 'MAR',
        predictedScore: '3-0',
        confidence: 82,
        reasoning: 'Morocco\'s quality and tournament experience should prove decisive. Haiti will compete but lack the depth to threaten consistently.',
        alternativeScenario: 'If Haiti\'s physicality disrupts Morocco\'s rhythm, a 2-1 Morocco win is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Morocco became the first African team to reach a World Cup semi-final in 2022',
        'Haiti\'s 1974 World Cup included a goal against Italy by Emmanuel Sanon',
        'Hakimi scored the winning penalty against Spain in 2022',
        'This is Haiti\'s second World Cup, 52 years after their first',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 50: South Africa vs South Korea (Group A)
  {
    docId: createDocId('KOR', 'RSA'),
    data: {
      team1Code: 'RSA',
      team2Code: 'KOR',
      team1Name: 'South Africa',
      team2Name: 'South Korea',
      historicalAnalysis: `South Africa and South Korea met at the 2010 World Cup in South Africa, with South Korea winning 2-1 in a group match. South Korea went on to reach the Round of 16, while host nation South Africa became the first host eliminated in the group stage.

South Korea return as consistent Asian qualifiers, with Son Heung-min leading a talented generation. Their 2022 World Cup saw progression to the Round of 16 before losing to Brazil.

South Africa make their first World Cup appearance since hosting in 2010. The development of their domestic league and youth programs has produced a competitive squad.`,
      keyStorylines: [
        'Rematch of 2010 World Cup encounter in South Africa',
        'Son Heung-min vs Bafana Bafana',
        'South Africa\'s first World Cup since hosting in 2010',
        'Battle for potential Group A progression',
      ],
      playersToWatch: [
        { name: 'Son Heung-min', teamCode: 'KOR', position: 'Forward', reason: 'Tottenham captain and Asia\'s greatest player' },
        { name: 'Percy Tau', teamCode: 'RSA', position: 'Winger', reason: 'South Africa\'s most experienced European-based player' },
        { name: 'Lee Kang-in', teamCode: 'KOR', position: 'Midfielder', reason: 'PSG\'s creative playmaker' },
        { name: 'Ronwen Williams', teamCode: 'RSA', position: 'Goalkeeper', reason: 'AFCON 2024 Best Goalkeeper' },
      ],
      tacticalPreview: `South Korea's 4-3-3 emphasizes pressing and quick transitions. Son's ability to create from any position, combined with Lee's creativity, makes them dangerous.

South Africa's 4-4-2 is organized and physical. Williams' shot-stopping will be crucial, and they'll look to hit Korea on counters.`,
      prediction: {
        predictedOutcome: 'KOR',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'South Korea\'s individual quality, particularly Son, should prove decisive. South Africa will compete but lack finishing quality.',
        alternativeScenario: 'If South Africa score early and defend resolutely, a shock draw is possible.',
      },
      pastEncountersSummary: 'Met at the 2010 World Cup in South Africa, with South Korea winning 2-1.',
      funFacts: [
        'South Africa became the first host nation eliminated in the group stage (2010)',
        'Son is Tottenham\'s highest Premier League scorer',
        'This is South Africa\'s third World Cup after 1998 and 2010',
        'Lee Kang-in won the 2019 U-20 World Cup Golden Ball',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 53: Switzerland vs Canada (Group B)
  {
    docId: createDocId('CAN', 'SUI'),
    data: {
      team1Code: 'SUI',
      team2Code: 'CAN',
      team1Name: 'Switzerland',
      team2Name: 'Canada',
      historicalAnalysis: `Switzerland and Canada have met just once—a 2018 friendly that ended 0-0. This World Cup encounter pits two nations with contrasting World Cup histories. Switzerland have reached the knockout rounds in 4 of their last 5 tournaments, while Canada are making only their third appearance.

Switzerland's consistency at major tournaments is remarkable—they've progressed from their group in 4 of the last 5 World Cups. Their blend of experience and youth makes them dangerous.

Canada, as co-hosts, carry massive expectations. Their 2022 World Cup was brief (eliminated in group stage), but this talented generation featuring Davies, David, and Buchanan is ready for more.`,
      keyStorylines: [
        'Switzerland\'s tournament consistency vs Canada\'s home advantage',
        'Xhaka\'s leadership vs Davies\' explosiveness',
        'First competitive meeting between these nations',
        'Crucial match for Group B standings',
      ],
      playersToWatch: [
        { name: 'Granit Xhaka', teamCode: 'SUI', position: 'Midfielder', reason: 'Leverkusen\'s title-winning captain' },
        { name: 'Alphonso Davies', teamCode: 'CAN', position: 'Defender', reason: 'Bayern Munich\'s lightning-fast wing-back' },
        { name: 'Breel Embolo', teamCode: 'SUI', position: 'Forward', reason: 'Monaco\'s powerful striker' },
        { name: 'Jonathan David', teamCode: 'CAN', position: 'Forward', reason: 'Lille\'s prolific striker' },
      ],
      tacticalPreview: `Switzerland's 3-4-2-1 provides defensive stability while allowing Xhaka to orchestrate from deep. Their counter-attacking efficiency is world-class.

Canada's 4-3-3 unleashes Davies as an attacking threat. David's movement and finishing are key, with the crowd driving aggressive pressing.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 50,
        reasoning: 'Two well-organized teams should produce a tight encounter. Both have the quality to score but also defensive organization.',
        alternativeScenario: 'If Davies dominates and Canada\'s crowd creates an electric atmosphere, a 2-1 home win is possible.',
      },
      pastEncountersSummary: 'One friendly in 2018, ending 0-0.',
      funFacts: [
        'Switzerland have reached the knockout rounds in 4 of their last 5 major tournaments',
        'Davies is one of the fastest players in world football',
        'Xhaka won the Bundesliga with Leverkusen in 2024',
        'This is Canada\'s first World Cup on home soil',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 57: Tunisia vs Netherlands (Group E)
  {
    docId: createDocId('NED', 'TUN'),
    data: {
      team1Code: 'TUN',
      team2Code: 'NED',
      team1Name: 'Tunisia',
      team2Name: 'Netherlands',
      historicalAnalysis: `Tunisia and Netherlands have never met at a World Cup. The Netherlands are three-time runners-up seeking their first title, while Tunisia have consistently qualified but never progressed beyond the group stage.

The Netherlands' 2022 World Cup ended in quarter-final disappointment against Argentina. Their squad features a blend of experienced players and emerging talents, with Van Dijk anchoring the defense.

Tunisia's 2022 campaign included a famous win over France. Their organization and spirit make them dangerous opponents for any team.`,
      keyStorylines: [
        'Netherlands seeking first World Cup title',
        'Tunisia looking to replicate France upset',
        'First ever World Cup meeting between these nations',
        'Crucial group stage finale',
      ],
      playersToWatch: [
        { name: 'Virgil van Dijk', teamCode: 'NED', position: 'Defender', reason: 'Liverpool captain and defensive colossus' },
        { name: 'Hannibal Mejbri', teamCode: 'TUN', position: 'Midfielder', reason: 'Manchester United\'s Tunisian talent' },
        { name: 'Cody Gakpo', teamCode: 'NED', position: 'Forward', reason: 'Liverpool\'s versatile attacker' },
        { name: 'Wahbi Khazri', teamCode: 'TUN', position: 'Forward', reason: 'Tunisia\'s experienced talisman' },
      ],
      tacticalPreview: `Netherlands' 4-3-3 provides attacking width with Gakpo drifting inside. Van Dijk's aerial dominance and ball-playing ability are crucial.

Tunisia's 4-3-3 emphasizes organization first. They'll look to frustrate Netherlands and create chances on the counter through quick transitions.`,
      prediction: {
        predictedOutcome: 'NED',
        predictedScore: '2-0',
        confidence: 68,
        reasoning: 'Netherlands\' quality should prove decisive, but Tunisia\'s organization will make it harder than expected.',
        alternativeScenario: 'If Tunisia score early and defend resolutely, a shock 1-0 upset like France is possible.',
      },
      pastEncountersSummary: 'First World Cup meeting. Limited previous history.',
      funFacts: [
        'Netherlands have lost 3 World Cup finals (1974, 1978, 2010)',
        'Tunisia beat France 1-0 at the 2022 World Cup',
        'Van Dijk was named UEFA Defender of the Year in 2019',
        'This is Tunisia\'s 6th World Cup appearance',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 58: Ecuador vs Germany (Group F)
  {
    docId: createDocId('ECU', 'GER'),
    data: {
      team1Code: 'ECU',
      team2Code: 'GER',
      team1Name: 'Ecuador',
      team2Name: 'Germany',
      historicalAnalysis: `Ecuador and Germany have never met at a World Cup. Germany are four-time champions seeking redemption after consecutive group stage exits. Ecuador have proven they can compete at the World Cup level, with strong showings in 2022.

Germany's 2022 exit was their second consecutive group stage failure—unprecedented for German football. The rebuild under new leadership has produced exciting young talents like Wirtz and Musiala.

Ecuador's 2022 World Cup saw wins over Qatar and competitive performances against Netherlands and Senegal. Their young squad, led by Caicedo, has only improved.`,
      keyStorylines: [
        'Germany seeking redemption after two group exits',
        'Ecuador\'s emerging generation vs German experience',
        'First ever World Cup meeting between these nations',
        'Four-time champions vs South American dark horses',
      ],
      playersToWatch: [
        { name: 'Florian Wirtz', teamCode: 'GER', position: 'Midfielder', reason: 'Leverkusen\'s wonderkid' },
        { name: 'Moisés Caicedo', teamCode: 'ECU', position: 'Midfielder', reason: 'Chelsea\'s world-class midfielder' },
        { name: 'Jamal Musiala', teamCode: 'GER', position: 'Midfielder', reason: 'Bayern\'s dazzling talent' },
        { name: 'Kendry Páez', teamCode: 'ECU', position: 'Midfielder', reason: 'Teenage sensation' },
      ],
      tacticalPreview: `Germany's 4-2-3-1 unleashes Wirtz and Musiala in creative roles. Their technical quality and pressing intensity should dominate.

Ecuador's 4-4-2 emphasizes quick passing and energy. Caicedo's ability to disrupt and drive forward is crucial against Germany's midfield.`,
      prediction: {
        predictedOutcome: 'GER',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'Germany\'s quality and desperation for success should prove decisive, but Ecuador will make it competitive.',
        alternativeScenario: 'If Ecuador\'s pressing works and they take their chances, a shock draw or win is possible.',
      },
      pastEncountersSummary: 'First ever World Cup meeting.',
      funFacts: [
        'Germany\'s consecutive group stage exits (2018, 2022) were unprecedented',
        'Caicedo\'s £115m transfer is a British record',
        'Wirtz and Musiala are considered Germany\'s future',
        'Ecuador have qualified for 4 of the last 5 World Cups',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 59: Curaçao vs Ivory Coast (Group F)
  {
    docId: createDocId('CIV', 'CUR'),
    data: {
      team1Code: 'CUR',
      team2Code: 'CIV',
      team1Name: 'Curaçao',
      team2Name: 'Ivory Coast',
      historicalAnalysis: `This is a historic first meeting between Curaçao and Ivory Coast. Curaçao, making their World Cup debut with a population of just 150,000, face the reigning AFCON champions in what could be a David vs Goliath encounter.

Ivory Coast won the 2024 AFCON on home soil in dramatic fashion, coming from behind in the tournament before winning it all. Their blend of experienced stars and young talents makes them formidable.

For Curaçao, every match at this World Cup is historic. Their qualification from CONCACAF is one of football's great underdog stories.`,
      keyStorylines: [
        'AFCON champions vs World Cup debutants',
        'Ivory Coast seeking to continue AFCON momentum',
        'Curaçao\'s population of 150,000 on the world stage',
        'First ever meeting between these nations',
      ],
      playersToWatch: [
        { name: 'Sébastien Haller', teamCode: 'CIV', position: 'Forward', reason: 'Cancer survivor and AFCON hero' },
        { name: 'Juninho Bacuna', teamCode: 'CUR', position: 'Midfielder', reason: 'Curaçao\'s most experienced player' },
        { name: 'Franck Kessié', teamCode: 'CIV', position: 'Midfielder', reason: 'Barcelona midfielder providing steel' },
        { name: 'Kenji Gorré', teamCode: 'CUR', position: 'Winger', reason: 'Tricky winger with pace' },
      ],
      tacticalPreview: `Ivory Coast's 4-3-3 is built on power and pace. Haller's hold-up play and finishing are key, with width from the flanks creating chances.

Curaçao's 5-4-1 is purely about survival. They'll park the bus and hope to create a moment of magic on the counter or from a set-piece.`,
      prediction: {
        predictedOutcome: 'CIV',
        predictedScore: '3-0',
        confidence: 85,
        reasoning: 'The gulf in quality is significant. Ivory Coast\'s firepower should overwhelm Curaçao\'s defense.',
        alternativeScenario: 'If Curaçao defend heroically, Ivory Coast might only manage 1-0 with growing frustration.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Curaçao has a smaller population than most World Cup stadiums',
        'Haller returned to football after beating testicular cancer',
        'Ivory Coast won the AFCON 2024 after being on the brink of elimination',
        'This is Curaçao\'s first ever World Cup appearance',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 60: Paraguay vs Australia (Group D)
  {
    docId: createDocId('AUS', 'PAR'),
    data: {
      team1Code: 'PAR',
      team2Code: 'AUS',
      team1Name: 'Paraguay',
      team2Name: 'Australia',
      historicalAnalysis: `Paraguay and Australia have met at a World Cup before—in 2010, where Paraguay won 2-1 in a group stage match. Both nations have been consistent qualifiers in the modern era, though neither has progressed deeply into tournaments recently.

Paraguay return to the World Cup after missing 2018 and 2022. Their traditional South American style emphasizes organization and clinical finishing.

Australia reached the Round of 16 in 2022, their best performance since 2006. The Socceroos' blend of experienced A-League players and European-based talents makes them competitive.`,
      keyStorylines: [
        'Paraguay\'s return after missing two World Cups',
        'Australia seeking to repeat 2022 progress',
        'Rematch of 2010 World Cup encounter',
        'South American vs Asian qualifying champions',
      ],
      playersToWatch: [
        { name: 'Miguel Almirón', teamCode: 'PAR', position: 'Midfielder', reason: 'Newcastle\'s creative spark' },
        { name: 'Mitchell Duke', teamCode: 'AUS', position: 'Forward', reason: 'Australia\'s experienced target man' },
        { name: 'Julio Enciso', teamCode: 'PAR', position: 'Midfielder', reason: 'Brighton\'s exciting young talent' },
        { name: 'Jackson Irvine', teamCode: 'AUS', position: 'Midfielder', reason: 'Bundesliga experience and leadership' },
      ],
      tacticalPreview: `Paraguay's 4-4-2 emphasizes defensive organization and quick transitions. Almirón's creativity and Enciso's flair provide attacking threat.

Australia's 4-3-3 is hard-working and organized. Their pressing intensity and set-piece threat from Duke's aerial ability are key weapons.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 52,
        reasoning: 'Two evenly matched teams should produce a competitive draw. Both have strengths that could cancel each other out.',
        alternativeScenario: 'If Almirón and Enciso click, Paraguay could edge it 2-1 with superior technical quality.',
      },
      pastEncountersSummary: 'Met at the 2010 World Cup, Paraguay winning 2-1.',
      funFacts: [
        'Paraguay reached the World Cup quarter-finals in 2010',
        'Australia scored their first ever World Cup knockout goal in 2022 against Denmark',
        'Almirón was Newcastle\'s Player of the Season in 2022-23',
        'This is Paraguay\'s first World Cup since 2010',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 62: Cape Verde vs Saudi Arabia (Group G)
  {
    docId: createDocId('CPV', 'SAU'),
    data: {
      team1Code: 'CPV',
      team2Code: 'SAU',
      team1Name: 'Cape Verde',
      team2Name: 'Saudi Arabia',
      historicalAnalysis: `This is a first ever meeting between Cape Verde and Saudi Arabia. Cape Verde make their World Cup debut as one of Africa's smallest nations, while Saudi Arabia ride the momentum of their famous 2022 win over Argentina.

Saudi Arabia's investment in football has transformed their domestic league, attracting global stars and improving their national team's exposure to top-level football.

Cape Verde's qualification represents a remarkable achievement for a nation of just 500,000 people. Their Portuguese-influenced technical style has produced players featuring in European leagues.`,
      keyStorylines: [
        'Cape Verde\'s historic World Cup debut',
        'Saudi Arabia seeking more giant-killing acts',
        'First ever meeting between these nations',
        'Two underdog nations with different World Cup histories',
      ],
      playersToWatch: [
        { name: 'Salem Al-Dawsari', teamCode: 'SAU', position: 'Winger', reason: 'Scored the winner against Argentina in 2022' },
        { name: 'Ryan Mendes', teamCode: 'CPV', position: 'Winger', reason: 'Cape Verde\'s most dangerous attacker' },
        { name: 'Firas Al-Buraikan', teamCode: 'SAU', position: 'Forward', reason: 'Young Saudi striking talent' },
        { name: 'Garry Rodrigues', teamCode: 'CPV', position: 'Forward', reason: 'Experienced striker' },
      ],
      tacticalPreview: `Saudi Arabia's 4-3-3 emphasizes quick passing and intensity. Al-Dawsari's creativity is crucial, and their high press can overwhelm opponents.

Cape Verde's 4-4-2 is compact and organized. They'll look to stay in the game and take any opportunities that arise.`,
      prediction: {
        predictedOutcome: 'SAU',
        predictedScore: '2-0',
        confidence: 65,
        reasoning: 'Saudi Arabia\'s greater World Cup experience and individual quality should prove decisive against the debutants.',
        alternativeScenario: 'If Cape Verde\'s organization frustrates Saudi Arabia, a 1-0 Saudi win or even a draw is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'Saudi Arabia\'s 2022 win over Argentina was voted the best World Cup upset',
        'Cape Verde has a population of about 500,000',
        'Al-Dawsari\'s goal against Argentina is one of the most iconic World Cup goals',
        'This is Cape Verde\'s first World Cup appearance',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 63: Egypt vs Iran (Group H)
  {
    docId: createDocId('EGY', 'IRN'),
    data: {
      team1Code: 'EGY',
      team2Code: 'IRN',
      team1Name: 'Egypt',
      team2Name: 'Iran',
      historicalAnalysis: `Egypt and Iran have met just once—a 1990 friendly that Egypt won 1-0. Both nations are regional powers with passionate fanbases, making this a highly anticipated clash between Africa and Asia's football giants.

Egypt return to the World Cup after missing 2022, with Mohamed Salah leading a talented squad. The Pharaohs are seven-time AFCON champions with a proud footballing tradition.

Iran are Asia's most consistent World Cup qualifiers, appearing in 6 of the last 7 tournaments. Their 2022 campaign included a memorable win over Wales.`,
      keyStorylines: [
        'Salah vs Taremi: Two world-class forwards',
        'Africa\'s most successful nation vs Asia\'s most consistent',
        'Egypt\'s return after missing 2022',
        'Battle of regional football powers',
      ],
      playersToWatch: [
        { name: 'Mohamed Salah', teamCode: 'EGY', position: 'Forward', reason: 'Liverpool legend' },
        { name: 'Mehdi Taremi', teamCode: 'IRN', position: 'Forward', reason: 'Inter Milan\'s striker' },
        { name: 'Mohamed Elneny', teamCode: 'EGY', position: 'Midfielder', reason: 'Experienced Arsenal midfielder' },
        { name: 'Sardar Azmoun', teamCode: 'IRN', position: 'Forward', reason: 'The "Iranian Messi"' },
      ],
      tacticalPreview: `Egypt's 4-3-3 is built around Salah's brilliance. Their attacking play flows through him, with quick wingers providing support.

Iran's 4-3-3 emphasizes defensive solidity and clinical counters. Taremi and Azmoun's partnership is world-class.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 55,
        reasoning: 'Two well-matched teams with quality forwards should produce an entertaining draw. Both Salah and Taremi could score.',
        alternativeScenario: 'If Salah dominates and Egypt\'s midfield controls play, a 2-1 Egypt win is possible.',
      },
      pastEncountersSummary: 'One friendly in 1990, Egypt winning 1-0.',
      funFacts: [
        'Egypt have won 7 AFCON titles—more than any other nation',
        'Iran beat Wales 2-0 at the 2022 World Cup with late goals',
        'Salah has scored over 200 goals for Liverpool',
        'Taremi has scored in both Champions League and Europa League finals',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 64: New Zealand vs Belgium (Group H)
  {
    docId: createDocId('BEL', 'NZL'),
    data: {
      team1Code: 'NZL',
      team2Code: 'BEL',
      team1Name: 'New Zealand',
      team2Name: 'Belgium',
      historicalAnalysis: `New Zealand and Belgium have never met at a World Cup. Belgium's golden generation has produced consistent tournament performances without winning a major trophy. New Zealand remain unbeaten in World Cup history (3 draws in 2010).

Belgium enter this tournament with their core aging but still formidable. De Bruyne and Lukaku lead a squad that has disappointed at the last two major tournaments.

New Zealand's World Cup history is brief but proud—their 2010 campaign saw them draw with Italy, Slovakia, and Paraguay without losing.`,
      keyStorylines: [
        'New Zealand\'s unbeaten World Cup record at stake',
        'Belgium\'s aging golden generation',
        'First ever meeting between these nations',
        'European heavyweights vs Oceania champions',
      ],
      playersToWatch: [
        { name: 'Kevin De Bruyne', teamCode: 'BEL', position: 'Midfielder', reason: 'Manchester City\'s creative genius' },
        { name: 'Chris Wood', teamCode: 'NZL', position: 'Forward', reason: 'Premier League-proven striker' },
        { name: 'Jérémy Doku', teamCode: 'BEL', position: 'Winger', reason: 'Explosive dribbler' },
        { name: 'Liberato Cacace', teamCode: 'NZL', position: 'Defender', reason: 'Empoli\'s attacking left-back' },
      ],
      tacticalPreview: `Belgium's 4-3-3 maximizes De Bruyne's creativity. Doku's pace provides an outlet, while Lukaku's presence stretches defenses.

New Zealand's 4-4-2 is organized and hard-working. Wood's aerial ability and their defensive discipline are key to any upset hopes.`,
      prediction: {
        predictedOutcome: 'BEL',
        predictedScore: '2-0',
        confidence: 75,
        reasoning: 'Belgium\'s individual quality should prove decisive, ending New Zealand\'s unbeaten run.',
        alternativeScenario: 'If New Zealand defend heroically and Wood converts a chance, a historic 1-1 draw is possible.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'New Zealand are unbeaten in World Cup history (3 draws in 2010)',
        'Belgium have never won a major international trophy',
        'De Bruyne has won 6 Premier League titles',
        'Wood has scored 50+ Premier League goals',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 68: Norway vs France (Group I)
  {
    docId: createDocId('FRA', 'NOR'),
    data: {
      team1Code: 'NOR',
      team2Code: 'FRA',
      team1Name: 'Norway',
      team2Name: 'France',
      historicalAnalysis: `Norway and France have met at the World Cup before—Norway famously beat France 2-1 at the 1998 World Cup in Marseille, one of the biggest upsets of that tournament. France went on to win that World Cup, but the Norwegian victory remains iconic.

France are the 2022 runners-up and 2018 champions, with Mbappé leading one of the world's most talented squads. Les Bleus remain among the favorites despite their final loss to Argentina.

Norway return to the World Cup for the first time since 1998, with Haaland's goal-scoring prowess their main weapon. This is a dream matchup for Norwegian fans.`,
      keyStorylines: [
        'Rematch of 1998 World Cup upset',
        'Haaland vs Mbappé: two of the world\'s best',
        'Norway\'s first World Cup since 1998',
        'France seeking revenge for historic defeat',
      ],
      playersToWatch: [
        { name: 'Kylian Mbappé', teamCode: 'FRA', position: 'Forward', reason: 'World\'s best player and France captain' },
        { name: 'Erling Haaland', teamCode: 'NOR', position: 'Forward', reason: 'Record-breaking Manchester City striker' },
        { name: 'Aurélien Tchouaméni', teamCode: 'FRA', position: 'Midfielder', reason: 'Real Madrid\'s midfield anchor' },
        { name: 'Martin Ødegaard', teamCode: 'NOR', position: 'Midfielder', reason: 'Arsenal captain' },
      ],
      tacticalPreview: `France's 4-3-3 is built around Mbappé's devastating pace and movement. Their quality throughout the squad makes them favorites against anyone.

Norway's 4-3-3 aims to maximize Haaland's goal threat. Ødegaard's creativity provides the service, with the team organized to defend and counter.`,
      prediction: {
        predictedOutcome: 'FRA',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'France\'s overall squad depth and quality should prove decisive, but Haaland can score against anyone.',
        alternativeScenario: 'If Haaland dominates and Norway\'s organization holds, a shock 2-2 draw or Norway win is possible.',
      },
      pastEncountersSummary: 'Norway beat France 2-1 at the 1998 World Cup in a famous upset.',
      funFacts: [
        'Norway\'s 1998 World Cup win over France is one of the tournament\'s biggest upsets',
        'Mbappé scored a hat-trick in the 2022 World Cup final (in a losing effort)',
        'Haaland scored 52 goals in his first Man City season',
        'This is Norway\'s first World Cup in 28 years',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 69: Jordan vs Argentina (Group J)
  {
    docId: createDocId('ARG', 'JOR'),
    data: {
      team1Code: 'JOR',
      team2Code: 'ARG',
      team1Name: 'Jordan',
      team2Name: 'Argentina',
      historicalAnalysis: `This is a first ever meeting between Jordan and Argentina. Jordan make their World Cup debut, while Argentina are the reigning champions with Messi potentially playing his final World Cup matches.

Argentina's 2022 triumph was the culmination of Messi's career, finally lifting the trophy that had eluded him. The squad's mentality and togetherness make them formidable.

Jordan's qualification is historic for the nation. Their 2023 Asian Cup final appearance showed they can compete at the highest level in Asia, but Argentina represents an entirely different challenge.`,
      keyStorylines: [
        'Jordan\'s historic World Cup debut vs reigning champions',
        'Messi potentially in his final World Cup matches',
        'First ever meeting between these nations',
        'Middle Eastern debutants vs South American giants',
      ],
      playersToWatch: [
        { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The GOAT in his final World Cup' },
        { name: 'Mousa Al-Taamari', teamCode: 'JOR', position: 'Winger', reason: 'Jordan\'s star player' },
        { name: 'Julián Álvarez', teamCode: 'ARG', position: 'Forward', reason: 'Man City\'s striker' },
        { name: 'Yazan Al-Naimat', teamCode: 'JOR', position: 'Forward', reason: 'Young Jordanian striker' },
      ],
      tacticalPreview: `Argentina's 4-3-3 is built on collective excellence. Messi still provides magic, but the system doesn't depend solely on him anymore.

Jordan's 4-4-2 will be compact and disciplined. Their gameplan is survival—frustrate Argentina and hope for any counter-attacking moment.`,
      prediction: {
        predictedOutcome: 'ARG',
        predictedScore: '3-0',
        confidence: 88,
        reasoning: 'The gulf in quality is enormous. Argentina should control and dominate against World Cup debutants.',
        alternativeScenario: 'If Jordan defend heroically, Argentina might only manage 1-0 with growing frustration.',
      },
      pastEncountersSummary: 'First ever meeting at any level.',
      funFacts: [
        'This is Jordan\'s first World Cup appearance',
        'Messi has won more Ballon d\'Or awards than any player',
        'Jordan reached the 2023 Asian Cup final',
        'Argentina\'s 2022 win was their third World Cup title',
      ],
      isFirstMeeting: true,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 70: Algeria vs Austria (Group J)
  {
    docId: createDocId('ALG', 'AUT'),
    data: {
      team1Code: 'ALG',
      team2Code: 'AUT',
      team1Name: 'Algeria',
      team2Name: 'Austria',
      historicalAnalysis: `Algeria and Austria have met at a World Cup before—at the 1982 World Cup in Spain. That encounter is best remembered for the infamous "Disgrace of Gijón," where West Germany and Austria's later match appeared to produce a mutually beneficial result that eliminated Algeria despite their strong performances.

Algeria return to the World Cup after missing 2022, with revenge for historical injustice on many fans' minds. Their 2019 AFCON triumph showed their quality.

Austria have improved dramatically under Rangnick's leadership. Their aggressive pressing and tactical sophistication make them dangerous opponents.`,
      keyStorylines: [
        'Historical significance from 1982 World Cup "Disgrace of Gijón"',
        'Algeria seeking delayed revenge',
        'Austria\'s pressing system vs Algeria\'s technical quality',
        'Both teams with Group J progression hopes',
      ],
      playersToWatch: [
        { name: 'Riyad Mahrez', teamCode: 'ALG', position: 'Winger', reason: 'Algeria\'s creative hub' },
        { name: 'David Alaba', teamCode: 'AUT', position: 'Defender', reason: 'Real Madrid\'s versatile star' },
        { name: 'Ismaël Bennacer', teamCode: 'ALG', position: 'Midfielder', reason: 'AC Milan\'s midfield anchor' },
        { name: 'Marcel Sabitzer', teamCode: 'AUT', position: 'Midfielder', reason: 'Dortmund\'s engine' },
      ],
      tacticalPreview: `Austria's 4-2-3-1 emphasizes intense pressing. Sabitzer's energy and Laimer's running will try to overwhelm Algeria's midfield.

Algeria's 4-3-3 focuses on keeping the ball and hitting on counters. Mahrez's creativity and Bennacer's control are key.`,
      prediction: {
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 50,
        reasoning: 'Two evenly matched teams should produce a competitive draw. Both have quality to score and defensive organization.',
        alternativeScenario: 'If Austria\'s pressing dominates, a 2-0 win is possible. If Algeria counter effectively, they could win 2-1.',
      },
      pastEncountersSummary: 'Met at 1982 World Cup. The broader context of that tournament involved the infamous Germany-Austria match that affected Algeria.',
      funFacts: [
        'The 1982 "Disgrace of Gijón" led to FIFA scheduling final group games simultaneously',
        'Algeria won the 2019 AFCON without losing a match',
        'Alaba has won multiple Champions League titles',
        'Mahrez scored the winning goal in the 2019 AFCON',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },

  // Match 72: Panama vs England (Group L)
  {
    docId: createDocId('ENG', 'PAN'),
    data: {
      team1Code: 'PAN',
      team2Code: 'ENG',
      team1Name: 'Panama',
      team2Name: 'England',
      historicalAnalysis: `Panama and England met at the 2018 World Cup, with England winning 6-1 in one of the most one-sided matches of that tournament. Panama's debut World Cup saw them score their first ever goal (against England), a moment of national celebration despite the heavy defeat.

England enter seeking to finally win a World Cup after 56 years of hurt. Under Thomas Tuchel, they've developed into genuine contenders with a squad featuring world-class talents like Bellingham and Kane.

Panama return to the World Cup with more experience and higher ambitions, hoping to progress beyond the group stage for the first time.`,
      keyStorylines: [
        'Rematch of 2018\'s 6-1 England demolition',
        'England seeking first World Cup since 1966',
        'Panama hoping for revenge and progress',
        'Group L finale with potential knockout implications',
      ],
      playersToWatch: [
        { name: 'Jude Bellingham', teamCode: 'ENG', position: 'Midfielder', reason: 'Real Madrid\'s midfield superstar' },
        { name: 'José Fajardo', teamCode: 'PAN', position: 'Forward', reason: 'Panama\'s experienced striker' },
        { name: 'Harry Kane', teamCode: 'ENG', position: 'Forward', reason: 'England\'s all-time top scorer' },
        { name: 'Adalberto Carrasquilla', teamCode: 'PAN', position: 'Midfielder', reason: 'MLS star providing energy' },
      ],
      tacticalPreview: `England's 4-3-3 under Tuchel maximizes attacking talent. Bellingham's box-to-box running and Kane's movement create constant threats.

Panama's 4-4-2 will be compact and physical. They'll look to frustrate England and avoid another embarrassing scoreline while taking any opportunity.`,
      prediction: {
        predictedOutcome: 'ENG',
        predictedScore: '3-0',
        confidence: 85,
        reasoning: 'England\'s quality advantage is significant. They should dominate without conceding, though Panama will be more organized than 2018.',
        alternativeScenario: 'If Panama defend heroically and score first, a 2-1 England win is possible.',
      },
      pastEncountersSummary: 'Met at 2018 World Cup, England winning 6-1. Panama scored their first ever World Cup goal in that match.',
      funFacts: [
        'Panama\'s goal against England in 2018 sparked national celebrations',
        'England last won the World Cup in 1966',
        'Kane\'s 6 goals at the 2018 World Cup won the Golden Boot',
        'Bellingham won La Liga in his first season at Real Madrid',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },
];

async function seedRemainingSummaries() {
  console.log('========================================');
  console.log('Seeding Remaining AI Match Summaries');
  console.log('========================================');
  console.log(`Total summaries to add: ${summaries.length}`);
  console.log('');

  let successCount = 0;

  for (const { docId, data } of summaries) {
    try {
      await db.collection('matchSummaries').doc(docId).set(data);
      console.log(`✅ Added ${data.team1Name} vs ${data.team2Name}`);
      successCount++;
    } catch (error) {
      console.error(`❌ Failed ${data.team1Name} vs ${data.team2Name}:`, error);
    }
  }

  console.log('');
  console.log('========================================');
  console.log(`Total: ${successCount}/${summaries.length} summaries added`);
  console.log('========================================');
}

seedRemainingSummaries()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });
