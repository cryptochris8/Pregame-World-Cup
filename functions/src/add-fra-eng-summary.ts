/**
 * Quick script to add France vs England summary for testing
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

async function addFraEngSummary() {
  const summary = {
    team1Code: 'ENG',
    team2Code: 'FRA',
    team1Name: 'England',
    team2Name: 'France',
    historicalAnalysis: `France and England share one of football's most historic and fierce rivalries. These two nations have met 31 times, with France holding a slight edge at 12 wins to England's 10, with 9 draws. Their World Cup encounters have been particularly memorable, including France's dramatic 2-1 victory at the 2022 World Cup quarter-finals when Olivier Giroud and Aurélien Tchouaméni scored, and Harry Kane missed a crucial late penalty.

That 2022 encounter epitomized the tension between these neighbors separated only by the English Channel. England, seeking their first World Cup since 1966, came agonizingly close to forcing extra time before Kane's penalty struck the crossbar. France went on to reach the final, losing to Argentina in one of the greatest World Cup finals ever.

The rivalry extends beyond football—centuries of historical conflict, cultural competition, and sporting battles have shaped how these nations view each other. Euro 2004 saw France's Zinedine Zidane score two injury-time goals to steal a 2-1 victory from England. This 2026 World Cup meeting adds another chapter to an already legendary rivalry.`,
    keyStorylines: [
      'Revenge mission: England seeking redemption after 2022 World Cup quarter-final heartbreak',
      'Mbappé vs Bellingham: Two of the world\'s best players in a direct showdown',
      'Kane\'s redemption arc after missing the crucial 2022 penalty',
      'Two of Europe\'s most talented squads in a blockbuster group stage clash',
    ],
    playersToWatch: [
      {
        name: 'Kylian Mbappé',
        teamCode: 'FRA',
        position: 'Forward',
        reason: 'World\'s best player and France captain seeking to lead Les Bleus to back-to-back titles',
      },
      {
        name: 'Jude Bellingham',
        teamCode: 'ENG',
        position: 'Midfielder',
        reason: 'England\'s orchestrator and potential Ballon d\'Or winner',
      },
      {
        name: 'Harry Kane',
        teamCode: 'ENG',
        position: 'Forward',
        reason: 'England\'s all-time top scorer with unfinished World Cup business',
      },
      {
        name: 'Aurélien Tchouaméni',
        teamCode: 'FRA',
        position: 'Midfielder',
        reason: 'Scored the opening goal in 2022; France\'s midfield anchor',
      },
    ],
    tacticalPreview: `This clash features two of Europe's most sophisticated tactical setups. France's 4-3-3 under Deschamps maximizes Mbappé's devastating pace while providing midfield control through Tchouaméni and Camavinga. England's 4-3-3 under Thomas Tuchel emphasizes pressing and quick transitions, with Bellingham operating as the creative hub.

The key battle will be in the channels. If Mbappé can isolate England's fullbacks, France's pace advantage will be decisive. Conversely, if England can control midfield and supply Kane with quality chances, they could exact revenge for 2022. Expect a cagey, high-quality encounter where set-pieces could prove decisive.`,
    prediction: {
      predictedOutcome: 'FRA',
      predictedScore: '2-1',
      confidence: 55,
      reasoning: 'France\'s experience and Mbappé\'s brilliance give them a narrow edge. However, England\'s quality and motivation after 2022 make this essentially a coin flip. The French squad\'s tournament pedigree could be the difference in tight moments.',
      alternativeScenario: 'If Bellingham dominates midfield and Kane stays clinical, England could avenge 2022 with a 2-1 victory. Their pressing intensity could overwhelm France\'s aging midfield.',
    },
    pastEncountersSummary: '31 meetings, 12 French wins, 10 English wins, 9 draws. The 2022 World Cup quarter-final (2-1 France) dominates recent memory, particularly Kane\'s missed penalty. Zidane\'s injury-time brace at Euro 2004 is another iconic moment in this rivalry.',
    funFacts: [
      'Kane\'s 2022 penalty miss hit the crossbar and would have made it 2-2 in the 84th minute',
      'France have never lost to England in a World Cup match (2 wins, 0 draws, 0 losses)',
      'Giroud\'s header in 2022 was his record-breaking 52nd goal for France',
      'England\'s only World Cup win over France came in... they\'ve never beaten France at a World Cup',
    ],
    isFirstMeeting: false,
    updatedAt: new Date().toISOString(),
  };

  // Document ID is alphabetically sorted
  const docId = 'ENG_FRA';

  await db.collection('matchSummaries').doc(docId).set(summary);
  console.log('✅ Added France vs England summary!');
}

addFraEngSummary()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });
