/**
 * Add summaries for mock data matches
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

const summaries = [
  // Brazil vs Argentina
  {
    docId: 'ARG_BRA',
    data: {
      team1Code: 'ARG',
      team2Code: 'BRA',
      team1Name: 'Argentina',
      team2Name: 'Brazil',
      historicalAnalysis: `The Superclásico de las Américas is the most heated rivalry in South American football. Argentina and Brazil have met over 110 times, with Brazil holding a slight historical advantage. However, recent history favors Argentina, who defeated Brazil 1-0 in the 2021 Copa América final at the Maracanã—Messi's first major international trophy.

That 2021 final victory broke a psychological barrier for Argentina. Angel Di María's goal, eerily similar to his 2008 Olympic final winner against Brazil, sent the Albiceleste into delirium. Argentina followed that triumph with the 2022 World Cup title, cementing Messi's legacy and establishing the current squad as one of the greatest in history.

Brazil, meanwhile, have struggled to recapture their brilliance. Their 2022 World Cup quarter-final penalty shootout loss to Croatia exposed vulnerabilities, and they enter 2026 desperate to restore pride. This group stage clash could be a preview of a potential knockout round rematch.`,
      keyStorylines: [
        'Argentina as reigning World Cup and Copa América champions seeking to assert dominance',
        'Brazil desperate for redemption after 2022 World Cup disappointment',
        'Messi\'s potential final World Cup vs Brazil\'s new generation led by Vinícius Jr.',
        'The rivalry that transcends football: national pride on the line',
      ],
      playersToWatch: [
        { name: 'Lionel Messi', teamCode: 'ARG', position: 'Forward', reason: 'The GOAT in potentially his final World Cup' },
        { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'Brazil\'s talisman and Ballon d\'Or contender' },
        { name: 'Julián Álvarez', teamCode: 'ARG', position: 'Forward', reason: '2022 World Cup star who terrorized defenses' },
        { name: 'Rodrygo', teamCode: 'BRA', position: 'Forward', reason: 'Real Madrid magic to unlock defenses' },
      ],
      tacticalPreview: `Argentina's 4-3-3 under Scaloni is built on collective excellence and pressing. They don't rely solely on Messi anymore—Álvarez, Mac Allister, and Enzo Fernández provide goals and creativity from multiple sources. Their defensive organization under Romero and Otamendi has been exceptional.

Brazil's attacking 4-2-3-1 unleashes Vinícius Jr. on the left, with Rodrygo providing creativity centrally. Their challenge is midfield control—an area where Argentina have dominated them recently. This tactical battle could define the match.`,
      prediction: {
        predictedOutcome: 'ARG',
        predictedScore: '2-1',
        confidence: 58,
        reasoning: 'Argentina\'s winning mentality and superior organization give them an edge. Brazil have the individual quality to win any match, but Argentina\'s experience and cohesion should prove decisive.',
        alternativeScenario: 'If Vinícius Jr. dominates and Brazil\'s pressing disrupts Argentina\'s buildup, a 2-1 Brazilian victory is entirely possible.',
      },
      pastEncountersSummary: 'Over 110 meetings in one of football\'s greatest rivalries. Argentina\'s 2021 Copa América final win (1-0) and World Cup triumph have shifted momentum. Brazil last beat Argentina in 2019 Copa América semi-final (2-0).',
      funFacts: [
        'Argentina\'s 2021 Copa América final win at the Maracanã was their first title in Brazil since 1993',
        'Messi has scored 10 goals against Brazil in his career',
        'Brazil and Argentina have met in 5 World Cups but never in a final',
        'This rivalry is called the "Superclásico de las Américas"',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },
  // USA vs Mexico
  {
    docId: 'MEX_USA',
    data: {
      team1Code: 'MEX',
      team2Code: 'USA',
      team1Name: 'Mexico',
      team2Name: 'United States',
      historicalAnalysis: `The rivalry between the United States and Mexico is the defining matchup in CONCACAF. Historically, Mexico dominated this fixture for decades, but the tide has shifted dramatically. The USMNT have won their last four competitive matches against El Tri, including the 2021 Nations League Final (3-2 after extra time) and the 2021 Gold Cup Final (1-0).

The 2022 World Cup saw both nations advance from their group but exit in the Round of 16. For this 2026 World Cup, both are co-hosts alongside Canada, adding unprecedented stakes to every match. Neither nation has advanced past the Round of 16 since 2002 (USA) and 1986 (Mexico), creating desperate hunger for a breakthrough.

This rivalry transcends sport. Immigration, cultural identity, and national pride infuse every meeting. The "Dos a Cero" scoreline became an iconic American chant after repeated World Cup qualifying victories. Playing in either country guarantees a hostile, electric atmosphere that rivals any derby in world football.`,
      keyStorylines: [
        'Battle of the co-hosts in a group stage blockbuster',
        'USA\'s recent dominance vs Mexico\'s historical superiority',
        'Both nations seeking their first World Cup quarter-final since 2002/1986',
        'Pulisic and the golden generation vs a rejuvenated El Tri',
      ],
      playersToWatch: [
        { name: 'Christian Pulisic', teamCode: 'USA', position: 'Winger', reason: 'Captain America leading the home nation charge' },
        { name: 'Hirving Lozano', teamCode: 'MEX', position: 'Winger', reason: 'El Chucky brings pace and danger' },
        { name: 'Weston McKennie', teamCode: 'USA', position: 'Midfielder', reason: 'Box-to-box energy and big-game experience' },
        { name: 'Santiago Giménez', teamCode: 'MEX', position: 'Forward', reason: 'Mexican goal machine dominating in Europe' },
      ],
      tacticalPreview: `The USA under Pochettino play intense, high-pressing football with quick transitions. Their young core—Pulisic, McKennie, Reyna—have European experience and tactical sophistication. The challenge is maintaining composure in a rivalry game.

Mexico's 4-3-3 under Aguirre emphasizes ball retention and patient buildup. They'll look to frustrate the USA and hit them on the counter through Lozano's pace. The midfield battle between McKennie and Edson Álvarez could be decisive.`,
      prediction: {
        predictedOutcome: 'USA',
        predictedScore: '2-1',
        confidence: 55,
        reasoning: 'USA\'s home advantage, recent dominance, and superior squad depth give them an edge. Mexico will be motivated and dangerous, but the USA have their number in recent years.',
        alternativeScenario: 'If Mexico score early and absorb pressure, they could steal a 1-0 victory. Their counter-attacking threat through Lozano is always dangerous.',
      },
      pastEncountersSummary: 'Over 75 meetings in a fierce rivalry. Mexico historically leads, but USA have won the last 4 competitive matches including both 2021 finals (Nations League, Gold Cup). The "Dos a Cero" World Cup qualifying victories remain iconic.',
      funFacts: [
        '"Dos a Cero" became an American fan chant after repeated 2-0 World Cup qualifying wins',
        'USA last lost to Mexico in a competitive match in 2019 (Gold Cup Final)',
        'Both nations have never met in a World Cup knockout match',
        'This is the first World Cup where USA and Mexico are co-hosts',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },
  // Brazil vs Ghana (Group B)
  {
    docId: 'BRA_GHA',
    data: {
      team1Code: 'BRA',
      team2Code: 'GHA',
      team1Name: 'Brazil',
      team2Name: 'Ghana',
      historicalAnalysis: `Brazil and Ghana have met just twice, both in friendlies, with Brazil winning both comfortably. Their most recent meeting was in 2022, just before the World Cup, when Brazil cruised to a 3-0 victory in Le Havre, France. Richarlison scored twice in that match, continuing his remarkable international form.

Ghana's 2010 World Cup quarter-final run remains their finest hour, though it ended in heartbreak when Asamoah Gyan missed a penalty in the final minute of extra time after Luis Suárez's infamous handball. Brazil, meanwhile, haven't won the World Cup since 2002—their longest drought in history.

This 2026 encounter pits South America's powerhouse against Africa's most decorated footballing nation (Ghana has won 4 AFCON titles). Ghana's physical, athletic style has troubled top teams before, but Brazil's technical superiority typically prevails.`,
      keyStorylines: [
        'Brazil seeking to end their longest World Cup drought (since 2002)',
        'Ghana looking to replicate their 2010 quarter-final heroics',
        'Vinícius Jr. and Rodrygo vs Ghana\'s athletic defense',
        'Five-time champions against African football\'s resilient spirit',
      ],
      playersToWatch: [
        { name: 'Vinícius Jr.', teamCode: 'BRA', position: 'Winger', reason: 'World-class talent who can unlock any defense' },
        { name: 'Mohammed Kudus', teamCode: 'GHA', position: 'Midfielder', reason: 'Ghana\'s most creative and dangerous player' },
        { name: 'Endrick', teamCode: 'BRA', position: 'Forward', reason: 'Teenage sensation making his World Cup debut' },
        { name: 'Thomas Partey', teamCode: 'GHA', position: 'Midfielder', reason: 'Arsenal\'s anchor must control the midfield' },
      ],
      tacticalPreview: `Brazil's 4-2-3-1 maximizes their attacking firepower with Vinícius and Rodrygo creating from wide positions. Their movement and one-touch passing can overwhelm defensive lines.

Ghana will look to be compact and organized in a 4-4-2, using Partey and Kudus to disrupt Brazil's rhythm. Their counter-attacking speed through the wings could cause problems. Set-pieces may be Ghana's best chance.`,
      prediction: {
        predictedOutcome: 'BRA',
        predictedScore: '3-0',
        confidence: 80,
        reasoning: 'Brazil\'s quality advantage is substantial. Ghana will compete but lack the firepower to consistently threaten. This should be relatively comfortable for the Seleção.',
        alternativeScenario: 'If Kudus produces individual magic and Ghana stay compact, a 2-1 Brazil win with a tense finish is possible.',
      },
      pastEncountersSummary: 'Just two meetings, both Brazil victories. The 2022 friendly (3-0) saw Richarlison score twice. Brazil have never lost to an African nation at a World Cup.',
      funFacts: [
        'Brazil have won all 22 World Cups they\'ve participated in... wait, they\'ve won 5 of 22 appearances',
        'Ghana\'s 2010 quarter-final remains the furthest an African team advanced (tied with Cameroon 1990, Senegal 2002)',
        'Richarlison scored 2 goals in Brazil\'s 3-0 friendly win over Ghana in 2022',
        'Ghana are 4-time AFCON champions, the most successful West African nation',
      ],
      isFirstMeeting: false,
      updatedAt: new Date().toISOString(),
    },
  },
];

async function addSummaries() {
  for (const { docId, data } of summaries) {
    await db.collection('matchSummaries').doc(docId).set(data);
    console.log(`✅ Added ${data.team1Name} vs ${data.team2Name}`);
  }
  console.log('\n✅ All mock match summaries added!');
}

addSummaries()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });
