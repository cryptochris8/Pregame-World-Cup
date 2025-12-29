import '../../domain/entities/entities.dart';

/// Provides mock data for World Cup 2026 development and testing
class WorldCupMockData {
  WorldCupMockData._();

  /// All 48 qualified teams for World Cup 2026
  static final List<NationalTeam> teams = [
    // Host Nations
    _team('USA', 'United States', 'USA', Confederation.concacaf, 11, 'A', 0, true,
        coach: 'Mauricio Pochettino', nickname: 'The Yanks', captain: 'Christian Pulisic',
        primaryColor: '#002868', secondaryColor: '#BF0A30',
        stars: ['Christian Pulisic', 'Weston McKennie', 'Tyler Adams', 'Gio Reyna']),
    _team('MEX', 'Mexico', 'MEX', Confederation.concacaf, 15, 'A', 2, true,
        coach: 'Javier Aguirre', nickname: 'El Tri', captain: 'Edson Álvarez',
        primaryColor: '#006847', secondaryColor: '#CE1126',
        stars: ['Hirving Lozano', 'Edson Álvarez', 'Raúl Jiménez', 'Santiago Giménez']),
    _team('CAN', 'Canada', 'CAN', Confederation.concacaf, 43, 'A', 0, true,
        coach: 'Jesse Marsch', nickname: 'Les Rouges', captain: 'Alphonso Davies',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Alphonso Davies', 'Jonathan David', 'Tajon Buchanan', 'Cyle Larin']),

    // CONMEBOL (7 teams)
    _team('BRA', 'Brazil', 'BRA', Confederation.conmebol, 5, 'B', 5, false,
        coach: 'Carlo Ancelotti', nickname: 'A Seleção', captain: 'Marquinhos',
        primaryColor: '#FFDF00', secondaryColor: '#009739',
        stars: ['Vinícius Jr.', 'Rodrygo', 'Endrick', 'Bruno Guimarães']),
    _team('ARG', 'Argentina', 'ARG', Confederation.conmebol, 1, 'B', 3, false,
        coach: 'Lionel Scaloni', nickname: 'La Albiceleste', captain: 'Lionel Messi',
        primaryColor: '#75AADB', secondaryColor: '#FFFFFF',
        stars: ['Lionel Messi', 'Julián Álvarez', 'Enzo Fernández', 'Lautaro Martínez']),
    _team('URU', 'Uruguay', 'URU', Confederation.conmebol, 17, 'B', 2, false,
        coach: 'Marcelo Bielsa', nickname: 'La Celeste', captain: 'José María Giménez',
        primaryColor: '#0038A8', secondaryColor: '#FFFFFF',
        stars: ['Federico Valverde', 'Darwin Núñez', 'Ronald Araújo', 'Rodrigo Bentancur']),
    _team('COL', 'Colombia', 'COL', Confederation.conmebol, 12, 'C', 0, false,
        coach: 'Néstor Lorenzo', nickname: 'Los Cafeteros', captain: 'James Rodríguez',
        primaryColor: '#FCD116', secondaryColor: '#003893',
        stars: ['Luis Díaz', 'James Rodríguez', 'Jhon Arias', 'Jefferson Lerma']),
    _team('ECU', 'Ecuador', 'ECU', Confederation.conmebol, 28, 'C', 0, false,
        coach: 'Sebastián Beccacece', nickname: 'La Tri', captain: 'Enner Valencia',
        primaryColor: '#FFD100', secondaryColor: '#0033A0',
        stars: ['Moisés Caicedo', 'Enner Valencia', 'Pervis Estupiñán', 'Piero Hincapié']),
    _team('CHI', 'Chile', 'CHI', Confederation.conmebol, 32, 'C', 0, false,
        coach: 'Ricardo Gareca', nickname: 'La Roja', captain: 'Claudio Bravo',
        primaryColor: '#D52B1E', secondaryColor: '#0033A0',
        stars: ['Alexis Sánchez', 'Ben Brereton Díaz', 'Erick Pulgar', 'Eduardo Vargas']),
    _team('PER', 'Peru', 'PER', Confederation.conmebol, 29, 'L', 0, false,
        coach: 'Jorge Fossati', nickname: 'La Blanquirroja', captain: 'Paolo Guerrero',
        primaryColor: '#D91023', secondaryColor: '#FFFFFF',
        stars: ['Paolo Guerrero', 'André Carrillo', 'Renato Tapia', 'Pedro Aquino']),

    // UEFA (16 teams)
    _team('FRA', 'France', 'FRA', Confederation.uefa, 2, 'D', 2, false,
        coach: 'Didier Deschamps', nickname: 'Les Bleus', captain: 'Kylian Mbappé',
        primaryColor: '#002395', secondaryColor: '#FFFFFF',
        stars: ['Kylian Mbappé', 'Antoine Griezmann', 'Aurélien Tchouaméni', 'Eduardo Camavinga']),
    _team('ENG', 'England', 'ENG', Confederation.uefa, 4, 'D', 1, false,
        coach: 'Thomas Tuchel', nickname: 'Three Lions', captain: 'Harry Kane',
        primaryColor: '#FFFFFF', secondaryColor: '#002366',
        stars: ['Harry Kane', 'Jude Bellingham', 'Phil Foden', 'Bukayo Saka']),
    _team('ESP', 'Spain', 'ESP', Confederation.uefa, 8, 'D', 1, false,
        coach: 'Luis de la Fuente', nickname: 'La Roja', captain: 'Álvaro Morata',
        primaryColor: '#AA151B', secondaryColor: '#F1BF00',
        stars: ['Lamine Yamal', 'Pedri', 'Nico Williams', 'Rodri']),
    _team('GER', 'Germany', 'GER', Confederation.uefa, 16, 'E', 4, false,
        coach: 'Julian Nagelsmann', nickname: 'Die Mannschaft', captain: 'İlkay Gündoğan',
        primaryColor: '#000000', secondaryColor: '#FFFFFF',
        stars: ['Jamal Musiala', 'Florian Wirtz', 'Kai Havertz', 'Joshua Kimmich']),
    _team('NED', 'Netherlands', 'NED', Confederation.uefa, 7, 'E', 0, false,
        coach: 'Ronald Koeman', nickname: 'Oranje', captain: 'Virgil van Dijk',
        primaryColor: '#FF6600', secondaryColor: '#FFFFFF',
        stars: ['Virgil van Dijk', 'Frenkie de Jong', 'Cody Gakpo', 'Xavi Simons']),
    _team('POR', 'Portugal', 'POR', Confederation.uefa, 6, 'E', 0, false,
        coach: 'Roberto Martínez', nickname: 'A Seleção', captain: 'Cristiano Ronaldo',
        primaryColor: '#FF0000', secondaryColor: '#006600',
        stars: ['Cristiano Ronaldo', 'Bruno Fernandes', 'Rafael Leão', 'Bernardo Silva']),
    _team('BEL', 'Belgium', 'BEL', Confederation.uefa, 3, 'F', 0, false,
        coach: 'Domenico Tedesco', nickname: 'Red Devils', captain: 'Kevin De Bruyne',
        primaryColor: '#ED2939', secondaryColor: '#000000',
        stars: ['Kevin De Bruyne', 'Romelu Lukaku', 'Jérémy Doku', 'Amadou Onana']),
    _team('ITA', 'Italy', 'ITA', Confederation.uefa, 9, 'F', 4, false,
        coach: 'Luciano Spalletti', nickname: 'Gli Azzurri', captain: 'Gianluigi Donnarumma',
        primaryColor: '#0066CC', secondaryColor: '#FFFFFF',
        stars: ['Gianluigi Donnarumma', 'Nicolò Barella', 'Federico Chiesa', 'Gianluca Scamacca']),
    _team('CRO', 'Croatia', 'CRO', Confederation.uefa, 10, 'F', 0, false,
        coach: 'Zlatko Dalić', nickname: 'Vatreni', captain: 'Luka Modrić',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Luka Modrić', 'Mateo Kovačić', 'Joško Gvardiol', 'Andrej Kramarić']),
    _team('DEN', 'Denmark', 'DEN', Confederation.uefa, 21, 'G', 0, false,
        coach: 'Kasper Hjulmand', nickname: 'Danish Dynamite', captain: 'Simon Kjær',
        primaryColor: '#C8102E', secondaryColor: '#FFFFFF',
        stars: ['Christian Eriksen', 'Rasmus Højlund', 'Pierre-Emile Højbjerg', 'Joachim Andersen']),
    _team('SUI', 'Switzerland', 'SUI', Confederation.uefa, 19, 'G', 0, false,
        coach: 'Murat Yakin', nickname: 'Nati', captain: 'Granit Xhaka',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Granit Xhaka', 'Manuel Akanji', 'Xherdan Shaqiri', 'Breel Embolo']),
    _team('AUT', 'Austria', 'AUT', Confederation.uefa, 25, 'G', 0, false,
        coach: 'Ralf Rangnick', nickname: 'Das Team', captain: 'David Alaba',
        primaryColor: '#ED2939', secondaryColor: '#FFFFFF',
        stars: ['David Alaba', 'Marcel Sabitzer', 'Konrad Laimer', 'Christoph Baumgartner']),
    _team('POL', 'Poland', 'POL', Confederation.uefa, 26, 'H', 0, false,
        coach: 'Michał Probierz', nickname: 'Biało-Czerwoni', captain: 'Robert Lewandowski',
        primaryColor: '#FFFFFF', secondaryColor: '#DC143C',
        stars: ['Robert Lewandowski', 'Piotr Zieliński', 'Nicola Zalewski', 'Jakub Moder']),
    _team('SRB', 'Serbia', 'SRB', Confederation.uefa, 33, 'H', 0, false,
        coach: 'Dragan Stojković', nickname: 'Orlovi', captain: 'Dušan Tadić',
        primaryColor: '#C6363C', secondaryColor: '#FFFFFF',
        stars: ['Dušan Vlahović', 'Aleksandar Mitrović', 'Dušan Tadić', 'Sergej Milinković-Savić']),
    _team('UKR', 'Ukraine', 'UKR', Confederation.uefa, 22, 'H', 0, false,
        coach: 'Serhiy Rebrov', nickname: 'Zbirna', captain: 'Andriy Yarmolenko',
        primaryColor: '#0057B7', secondaryColor: '#FFD700',
        stars: ['Mykhailo Mudryk', 'Oleksandr Zinchenko', 'Artem Dovbyk', 'Georgiy Sudakov']),
    _team('WAL', 'Wales', 'WAL', Confederation.uefa, 28, 'I', 0, false,
        coach: 'Craig Bellamy', nickname: 'The Dragons', captain: 'Aaron Ramsey',
        primaryColor: '#C8102E', secondaryColor: '#00AB39',
        stars: ['Aaron Ramsey', 'Daniel James', 'Brennan Johnson', 'Ethan Ampadu']),

    // AFC (8 teams)
    _team('JPN', 'Japan', 'JPN', Confederation.afc, 18, 'I', 0, false,
        coach: 'Hajime Moriyasu', nickname: 'Samurai Blue', captain: 'Maya Yoshida',
        primaryColor: '#000080', secondaryColor: '#FFFFFF',
        stars: ['Takefusa Kubo', 'Kaoru Mitoma', 'Ritsu Doan', 'Wataru Endo']),
    _team('KOR', 'Korea Republic', 'KOR', Confederation.afc, 23, 'I', 0, false,
        coach: 'Hong Myung-bo', nickname: 'Taegeuk Warriors', captain: 'Son Heung-min',
        primaryColor: '#C60C30', secondaryColor: '#FFFFFF',
        stars: ['Son Heung-min', 'Lee Kang-in', 'Kim Min-jae', 'Hwang Hee-chan']),
    _team('AUS', 'Australia', 'AUS', Confederation.afc, 27, 'J', 0, false,
        coach: 'Tony Popovic', nickname: 'Socceroos', captain: 'Maty Ryan',
        primaryColor: '#FFCD00', secondaryColor: '#00843D',
        stars: ['Mathew Leckie', 'Jackson Irvine', 'Ajdin Hrustic', 'Harry Souttar']),
    _team('IRN', 'Iran', 'IRN', Confederation.afc, 24, 'J', 0, false,
        coach: 'Amir Ghalenoei', nickname: 'Team Melli', captain: 'Alireza Jahanbakhsh',
        primaryColor: '#FFFFFF', secondaryColor: '#C8102E',
        stars: ['Mehdi Taremi', 'Sardar Azmoun', 'Alireza Jahanbakhsh', 'Saman Ghoddos']),
    _team('KSA', 'Saudi Arabia', 'KSA', Confederation.afc, 56, 'J', 0, false,
        coach: 'Hervé Renard', nickname: 'The Green Falcons', captain: 'Salman Al-Faraj',
        primaryColor: '#006C35', secondaryColor: '#FFFFFF',
        stars: ['Salem Al-Dawsari', 'Salman Al-Faraj', 'Firas Al-Buraikan', 'Mohammed Al-Burayk']),
    _team('QAT', 'Qatar', 'QAT', Confederation.afc, 37, 'K', 0, false,
        coach: 'Luis García', nickname: 'Al-Annabi', captain: 'Hassan Al-Haydos',
        primaryColor: '#8D1B3D', secondaryColor: '#FFFFFF',
        stars: ['Akram Afif', 'Almoez Ali', 'Hassan Al-Haydos', 'Karim Boudiaf']),
    _team('UAE', 'United Arab Emirates', 'UAE', Confederation.afc, 69, 'K', 0, false,
        coach: 'Paulo Bento', nickname: 'Al-Abyad', captain: 'Walid Abbas',
        primaryColor: '#FFFFFF', secondaryColor: '#009639',
        stars: ['Omar Abdulrahman', 'Ali Mabkhout', 'Fabio de Lima', 'Khalfan Mubarak']),
    _team('CHN', 'China PR', 'CHN', Confederation.afc, 79, 'K', 0, false,
        coach: 'Branko Ivanković', nickname: 'Team Dragon', captain: 'Wu Xi',
        primaryColor: '#DE2910', secondaryColor: '#FFDE00',
        stars: ['Wu Lei', 'Wu Xi', 'Zhang Linpeng', 'Yan Junling']),

    // CAF (9 teams)
    _team('MAR', 'Morocco', 'MAR', Confederation.caf, 13, 'L', 0, false,
        coach: 'Walid Regragui', nickname: 'Atlas Lions', captain: 'Romain Saïss',
        primaryColor: '#C1272D', secondaryColor: '#006233',
        stars: ['Achraf Hakimi', 'Hakim Ziyech', 'Youssef En-Nesyri', 'Sofyan Amrabat']),
    _team('SEN', 'Senegal', 'SEN', Confederation.caf, 20, 'L', 0, false,
        coach: 'Aliou Cissé', nickname: 'Lions of Teranga', captain: 'Kalidou Koulibaly',
        primaryColor: '#00853F', secondaryColor: '#FDEF42',
        stars: ['Sadio Mané', 'Kalidou Koulibaly', 'Édouard Mendy', 'Ismaïla Sarr']),
    _team('NGA', 'Nigeria', 'NGA', Confederation.caf, 30, 'L', 0, false,
        coach: 'Finidi George', nickname: 'Super Eagles', captain: 'William Troost-Ekong',
        primaryColor: '#008751', secondaryColor: '#FFFFFF',
        stars: ['Victor Osimhen', 'Samuel Chukwueze', 'Wilfred Ndidi', 'Alex Iwobi']),
    _team('EGY', 'Egypt', 'EGY', Confederation.caf, 36, 'A', 0, false,
        coach: 'Hossam Hassan', nickname: 'The Pharaohs', captain: 'Mohamed Salah',
        primaryColor: '#C8102E', secondaryColor: '#FFFFFF',
        stars: ['Mohamed Salah', 'Omar Marmoush', 'Mahmoud Hassan Trezeguet', 'Mohamed Elneny']),
    _team('GHA', 'Ghana', 'GHA', Confederation.caf, 60, 'B', 0, false,
        coach: 'Otto Addo', nickname: 'Black Stars', captain: 'Andre Ayew',
        primaryColor: '#006B3F', secondaryColor: '#FCD116',
        stars: ['Mohammed Kudus', 'Thomas Partey', 'Andre Ayew', 'Jordan Ayew']),
    _team('CMR', 'Cameroon', 'CMR', Confederation.caf, 50, 'C', 0, false,
        coach: 'Marc Brys', nickname: 'Indomitable Lions', captain: 'Vincent Aboubakar',
        primaryColor: '#007A5E', secondaryColor: '#CE1126',
        stars: ['André-Frank Zambo Anguissa', 'Eric Maxim Choupo-Moting', 'Vincent Aboubakar', 'Karl Toko Ekambi']),
    _team('CIV', 'Ivory Coast', 'CIV', Confederation.caf, 46, 'D', 0, false,
        coach: 'Emerse Faé', nickname: 'The Elephants', captain: 'Serge Aurier',
        primaryColor: '#F77F00', secondaryColor: '#009E60',
        stars: ['Sébastien Haller', 'Nicolas Pépé', 'Franck Kessié', 'Simon Adingra']),
    _team('ALG', 'Algeria', 'ALG', Confederation.caf, 31, 'E', 0, false,
        coach: 'Vladimir Petković', nickname: 'Les Fennecs', captain: 'Riyad Mahrez',
        primaryColor: '#006633', secondaryColor: '#FFFFFF',
        stars: ['Riyad Mahrez', 'Ismaël Bennacer', 'Islam Slimani', 'Saïd Benrahma']),
    _team('TUN', 'Tunisia', 'TUN', Confederation.caf, 35, 'F', 0, false,
        coach: 'Faouzi Benzarti', nickname: 'Eagles of Carthage', captain: 'Youssef Msakni',
        primaryColor: '#E70013', secondaryColor: '#FFFFFF',
        stars: ['Youssef Msakni', 'Wahbi Khazri', 'Hannibal Mejbri', 'Aïssa Laïdouni']),

    // OFC (1 team)
    _team('NZL', 'New Zealand', 'NZL', Confederation.ofc, 93, 'G', 0, false,
        coach: 'Darren Bazeley', nickname: 'All Whites', captain: 'Chris Wood',
        primaryColor: '#FFFFFF', secondaryColor: '#000000',
        stars: ['Chris Wood', 'Liberato Cacace', 'Matt Garbett', 'Marko Stamenic']),

    // Additional CONCACAF teams
    _team('CRC', 'Costa Rica', 'CRC', Confederation.concacaf, 52, 'H', 0, false,
        coach: 'Claudio Vivas', nickname: 'Los Ticos', captain: 'Bryan Ruiz',
        primaryColor: '#C8102E', secondaryColor: '#002B7F',
        stars: ['Keylor Navas', 'Bryan Ruiz', 'Joel Campbell', 'Jewison Bennette']),
    _team('JAM', 'Jamaica', 'JAM', Confederation.concacaf, 63, 'I', 0, false,
        coach: 'Heimir Hallgrímsson', nickname: 'Reggae Boyz', captain: 'Andre Blake',
        primaryColor: '#009B3A', secondaryColor: '#FED100',
        stars: ['Leon Bailey', 'Michail Antonio', 'Bobby Decordova-Reid', 'Ravel Morrison']),
    _team('HON', 'Honduras', 'HON', Confederation.concacaf, 77, 'J', 0, false,
        coach: 'Reinaldo Rueda', nickname: 'Los Catrachos', captain: 'Maynor Figueroa',
        primaryColor: '#0073CF', secondaryColor: '#FFFFFF',
        stars: ['Alberth Elis', 'Romell Quioto', 'Luis Palma', 'Andy Najar']),
    _team('PAN', 'Panama', 'PAN', Confederation.concacaf, 48, 'K', 0, false,
        coach: 'Thomas Christiansen', nickname: 'Los Canaleros', captain: 'Aníbal Godoy',
        primaryColor: '#C8102E', secondaryColor: '#FFFFFF',
        stars: ['José Luis Rodríguez', 'Édgar Bárcenas', 'Cecilio Waterman', 'Adalberto Carrasquilla']),
  ];

  /// Sample group stage matches
  static List<WorldCupMatch> get groupStageMatches {
    final matches = <WorldCupMatch>[];
    int matchNumber = 1;

    // Group A matches
    matches.addAll(_generateGroupMatches('A', ['USA', 'MEX', 'CAN', 'EGY'], matchNumber));
    matchNumber += 6;

    // Group B matches
    matches.addAll(_generateGroupMatches('B', ['BRA', 'ARG', 'URU', 'GHA'], matchNumber));
    matchNumber += 6;

    // Group C matches
    matches.addAll(_generateGroupMatches('C', ['COL', 'ECU', 'CHI', 'CMR'], matchNumber));
    matchNumber += 6;

    // Group D matches
    matches.addAll(_generateGroupMatches('D', ['FRA', 'ENG', 'ESP', 'CIV'], matchNumber));
    matchNumber += 6;

    return matches;
  }

  /// Sample live match for testing
  static WorldCupMatch get liveMatch => WorldCupMatch(
    matchId: 'group_A_1',
    matchNumber: 1,
    stage: MatchStage.groupStage,
    group: 'A',
    groupMatchDay: 1,
    homeTeamCode: 'MEX',
    homeTeamName: 'Mexico',
    homeTeamFlagUrl: 'https://flagcdn.com/w80/mx.png',
    awayTeamCode: 'PER',
    awayTeamName: 'Peru',
    awayTeamFlagUrl: 'https://flagcdn.com/w80/pe.png',
    status: MatchStatus.inProgress,
    homeScore: 2,
    awayScore: 1,
    minute: 73,
    dateTime: DateTime(2026, 6, 11, 20, 0),
    dateTimeUtc: DateTime.utc(2026, 6, 12, 1, 0), // UTC time (Mexico City is UTC-5 during summer)
    venue: const WorldCupVenue(
      venueId: 'azteca',
      name: 'Estadio Azteca',
      city: 'Mexico City',
      country: HostCountry.mexico,
      capacity: 87523,
      latitude: 19.3029,
      longitude: -99.1506,
      timeZone: 'America/Mexico_City',
      utcOffset: -5,
    ),
    homeGoalScorers: ['Lozano 12\'', 'Herrera 55\''],
    awayGoalScorers: ['Carrillo 38\''],
  );

  /// Sample group standings
  static List<WorldCupGroup> get groups {
    return [
      _createGroup('A', [
        _standing('USA', 'United States', 1, 3, 2, 1, 0, 5, 2),
        _standing('MEX', 'Mexico', 2, 3, 2, 0, 1, 4, 3),
        _standing('CAN', 'Canada', 3, 3, 1, 1, 1, 3, 3),
        _standing('EGY', 'Egypt', 4, 3, 0, 0, 3, 1, 5),
      ]),
      _createGroup('B', [
        _standing('ARG', 'Argentina', 1, 3, 3, 0, 0, 7, 1),
        _standing('BRA', 'Brazil', 2, 3, 2, 0, 1, 5, 3),
        _standing('URU', 'Uruguay', 3, 3, 1, 0, 2, 3, 4),
        _standing('GHA', 'Ghana', 4, 3, 0, 0, 3, 0, 7),
      ]),
      _createGroup('C', [
        _standing('COL', 'Colombia', 1, 3, 2, 1, 0, 4, 1),
        _standing('ECU', 'Ecuador', 2, 3, 1, 2, 0, 3, 2),
        _standing('CMR', 'Cameroon', 3, 3, 1, 0, 2, 2, 4),
        _standing('CHI', 'Chile', 4, 3, 0, 1, 2, 2, 4),
      ]),
      _createGroup('D', [
        _standing('FRA', 'France', 1, 3, 3, 0, 0, 8, 2),
        _standing('ENG', 'England', 2, 3, 2, 0, 1, 5, 3),
        _standing('ESP', 'Spain', 3, 3, 1, 0, 2, 4, 5),
        _standing('CIV', 'Ivory Coast', 4, 3, 0, 0, 3, 1, 8),
      ]),
    ];
  }

  /// Sample bracket for knockout stage
  static WorldCupBracket get bracket {
    return WorldCupBracket(
      roundOf32: _generateRoundOf32Matches(),
      roundOf16: _generateRoundOf16Matches(),
      quarterFinals: _generateQuarterFinalMatches(),
      semiFinals: _generateSemiFinalMatches(),
      thirdPlace: _createBracketMatch('3rd', 63, MatchStage.thirdPlace, 1, 'FRA', 'France', 'ENG', 'England'),
      finalMatch: _createBracketMatch('final', 64, MatchStage.final_, 1, 'ARG', 'Argentina', 'BRA', 'Brazil'),
    );
  }

  /// All 16 official World Cup 2026 venues
  static List<WorldCupVenue> get venues => [
    // USA Venues (12)
    const WorldCupVenue(
      venueId: 'v1',
      name: 'MetLife Stadium',
      city: 'East Rutherford',
      country: HostCountry.usa,
      capacity: 82500,
      latitude: 40.8135,
      longitude: -74.0745,
    ),
    const WorldCupVenue(
      venueId: 'v2',
      name: 'SoFi Stadium',
      city: 'Inglewood',
      country: HostCountry.usa,
      capacity: 70240,
      latitude: 33.9535,
      longitude: -118.3392,
    ),
    const WorldCupVenue(
      venueId: 'v3',
      name: 'AT&T Stadium',
      city: 'Arlington',
      country: HostCountry.usa,
      capacity: 80000,
      latitude: 32.7473,
      longitude: -97.0945,
    ),
    const WorldCupVenue(
      venueId: 'v6',
      name: 'Arrowhead Stadium',
      city: 'Kansas City',
      country: HostCountry.usa,
      capacity: 76416,
      latitude: 39.0489,
      longitude: -94.4852,
    ),
    const WorldCupVenue(
      venueId: 'v7',
      name: 'Mercedes-Benz Superdome',
      city: 'New Orleans',
      country: HostCountry.usa,
      capacity: 73208,
      latitude: 29.9511,
      longitude: -90.0807,
    ),
    const WorldCupVenue(
      venueId: 'v8',
      name: 'NRG Stadium',
      city: 'Houston',
      country: HostCountry.usa,
      capacity: 72220,
      latitude: 29.6847,
      longitude: -95.4095,
    ),
    const WorldCupVenue(
      venueId: 'v9',
      name: 'Levi\'s Stadium',
      city: 'Santa Clara',
      country: HostCountry.usa,
      capacity: 75000,
      latitude: 37.4050,
      longitude: -121.9690,
    ),
    const WorldCupVenue(
      venueId: 'v10',
      name: 'Lincoln Financial Field',
      city: 'Philadelphia',
      country: HostCountry.usa,
      capacity: 69176,
      latitude: 39.9012,
      longitude: -75.1676,
    ),
    const WorldCupVenue(
      venueId: 'v11',
      name: 'Hard Rock Stadium',
      city: 'Miami',
      country: HostCountry.usa,
      capacity: 65326,
      latitude: 25.9581,
      longitude: -80.2388,
    ),
    const WorldCupVenue(
      venueId: 'v12',
      name: 'Empower Field at Mile High',
      city: 'Denver',
      country: HostCountry.usa,
      capacity: 76125,
      latitude: 39.7397,
      longitude: -104.9903,
    ),
    const WorldCupVenue(
      venueId: 'v13',
      name: 'Allegiant Stadium',
      city: 'Las Vegas',
      country: HostCountry.usa,
      capacity: 61629,
      latitude: 36.0899,
      longitude: -115.1833,
    ),
    const WorldCupVenue(
      venueId: 'v14',
      name: 'Lumen Field',
      city: 'Seattle',
      country: HostCountry.usa,
      capacity: 69000,
      latitude: 47.5952,
      longitude: -122.3316,
    ),
    // Mexico Venues (3)
    const WorldCupVenue(
      venueId: 'v4',
      name: 'Estadio Azteca',
      city: 'Mexico City',
      country: HostCountry.mexico,
      capacity: 87523,
      latitude: 19.3029,
      longitude: -99.1505,
    ),
    const WorldCupVenue(
      venueId: 'v15',
      name: 'Estadio BBVA',
      city: 'Monterrey',
      country: HostCountry.mexico,
      capacity: 72711,
      latitude: 25.6938,
      longitude: -100.2539,
    ),
    const WorldCupVenue(
      venueId: 'v16',
      name: 'Estadio Akron',
      city: 'Guadalajara',
      country: HostCountry.mexico,
      capacity: 46420,
      latitude: 20.5933,
      longitude: -103.3091,
    ),
    // Canada Venues (1)
    const WorldCupVenue(
      venueId: 'v5',
      name: 'BMO Field',
      city: 'Toronto',
      country: HostCountry.canada,
      capacity: 45000,
      latitude: 43.6332,
      longitude: -79.4186,
    ),
  ];

  // FIFA code to ISO country code mapping for flag URLs
  static const Map<String, String> _fifaToIsoCode = {
    // CONCACAF
    'USA': 'us', 'MEX': 'mx', 'CAN': 'ca', 'CRC': 'cr', 'JAM': 'jm',
    'HON': 'hn', 'PAN': 'pa',
    // CONMEBOL
    'BRA': 'br', 'ARG': 'ar', 'URU': 'uy', 'COL': 'co', 'ECU': 'ec',
    'CHI': 'cl', 'PER': 'pe',
    // UEFA
    'FRA': 'fr', 'ENG': 'gb-eng', 'ESP': 'es', 'GER': 'de', 'NED': 'nl',
    'POR': 'pt', 'BEL': 'be', 'ITA': 'it', 'CRO': 'hr', 'DEN': 'dk',
    'SUI': 'ch', 'AUT': 'at', 'POL': 'pl', 'SRB': 'rs', 'UKR': 'ua',
    'WAL': 'gb-wls',
    // AFC
    'JPN': 'jp', 'KOR': 'kr', 'AUS': 'au', 'IRN': 'ir', 'KSA': 'sa',
    'QAT': 'qa', 'UAE': 'ae', 'CHN': 'cn',
    // CAF
    'MAR': 'ma', 'SEN': 'sn', 'NGA': 'ng', 'EGY': 'eg', 'GHA': 'gh',
    'CMR': 'cm', 'CIV': 'ci', 'ALG': 'dz', 'TUN': 'tn',
    // OFC
    'NZL': 'nz',
  };

  /// Get ISO country code from FIFA code for flag URL
  static String _getIsoCode(String fifaCode) {
    return _fifaToIsoCode[fifaCode] ?? fifaCode.toLowerCase();
  }

  // Helper methods
  static NationalTeam _team(
    String code,
    String name,
    String shortName,
    Confederation conf,
    int ranking,
    String group,
    int titles,
    bool isHost, {
    String? coach,
    String? nickname,
    String? captain,
    String? primaryColor,
    String? secondaryColor,
    List<String> stars = const [],
  }) {
    final isoCode = _getIsoCode(code);
    return NationalTeam(
      fifaCode: code,
      countryName: name,
      shortName: shortName,
      flagUrl: 'https://flagcdn.com/w80/$isoCode.png',
      confederation: conf,
      fifaRanking: ranking,
      group: group,
      worldCupTitles: titles,
      isHostNation: isHost,
      coachName: coach,
      nickname: nickname,
      captainName: captain,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      starPlayers: stars,
      isQualified: true,
    );
  }

  static List<WorldCupMatch> _generateGroupMatches(
    String group,
    List<String> teamCodes,
    int startMatchNumber,
  ) {
    final matches = <WorldCupMatch>[];
    final teams = teamCodes.map((code) =>
      WorldCupMockData.teams.firstWhere((t) => t.fifaCode == code)
    ).toList();

    // Group A: June 11, 15, 19 (Host nation Mexico)
    // Group B: June 12, 16, 20
    // Group C: June 13, 17, 21
    // Group D: June 14, 18, 22

    int dayOffset = group == 'A' ? 0 : group == 'B' ? 1 : group == 'C' ? 2 : 3;

    // Match day 1 - June 11-14
    matches.add(_createGroupMatch(startMatchNumber, group, 1, teams[0], teams[1],
      DateTime(2026, 6, 11 + dayOffset, 18, 0), MatchStatus.completed, 2, 1, ['${teams[0].shortName.split(' ')[0]} 23\'', '${teams[0].shortName.split(' ')[0]} 67\''], ['${teams[1].shortName.split(' ')[0]} 45\'']));
    matches.add(_createGroupMatch(startMatchNumber + 1, group, 1, teams[2], teams[3],
      DateTime(2026, 6, 11 + dayOffset, 21, 0), MatchStatus.scheduled, 0, 0, [], []));

    // Match day 2 - June 15-18
    matches.add(_createGroupMatch(startMatchNumber + 2, group, 2, teams[0], teams[2],
      DateTime(2026, 6, 15 + dayOffset, 18, 0), MatchStatus.completed, 1, 1, ['${teams[0].shortName.split(' ')[0]} 12\''], ['${teams[2].shortName.split(' ')[0]} 89\'']));
    matches.add(_createGroupMatch(startMatchNumber + 3, group, 2, teams[1], teams[3],
      DateTime(2026, 6, 15 + dayOffset, 21, 0), MatchStatus.scheduled, 0, 0, [], []));

    // Match day 3 - June 19-22 (Simultaneous kickoff times)
    matches.add(_createGroupMatch(startMatchNumber + 4, group, 3, teams[0], teams[3],
      DateTime(2026, 6, 19 + dayOffset, 20, 0), MatchStatus.scheduled, 0, 0, [], []));
    matches.add(_createGroupMatch(startMatchNumber + 5, group, 3, teams[1], teams[2],
      DateTime(2026, 6, 19 + dayOffset, 20, 0), MatchStatus.scheduled, 0, 0, [], []));

    return matches;
  }

  static WorldCupMatch _createGroupMatch(
    int matchNumber,
    String group,
    int matchDay,
    NationalTeam home,
    NationalTeam away,
    DateTime dateTime,
    MatchStatus status,
    int homeScore,
    int awayScore,
    List<String> homeGoalScorers,
    List<String> awayGoalScorers,
  ) {
    // Mock times are in US Eastern Time (EDT during summer = UTC-4)
    // Convert to UTC by adding 4 hours
    final utcTime = dateTime.add(const Duration(hours: 4));

    // Assign a default venue based on group
    final venue = _getVenueForGroup(group);

    return WorldCupMatch(
      matchId: 'group_${group}_$matchNumber',
      matchNumber: matchNumber,
      stage: MatchStage.groupStage,
      group: group,
      groupMatchDay: matchDay,
      homeTeamCode: home.fifaCode,
      homeTeamName: home.countryName,
      homeTeamFlagUrl: home.flagUrl,
      awayTeamCode: away.fifaCode,
      awayTeamName: away.countryName,
      awayTeamFlagUrl: away.flagUrl,
      dateTime: dateTime,
      dateTimeUtc: utcTime,
      venue: venue,
      status: status,
      homeScore: homeScore,
      awayScore: awayScore,
      homeGoalScorers: homeGoalScorers,
      awayGoalScorers: awayGoalScorers,
    );
  }

  /// Get a venue for a given group (for mock data)
  static WorldCupVenue _getVenueForGroup(String group) {
    switch (group) {
      case 'A':
        return const WorldCupVenue(
          venueId: 'metlife',
          name: 'MetLife Stadium',
          city: 'East Rutherford',
          country: HostCountry.usa,
          capacity: 82500,
          latitude: 40.8135,
          longitude: -74.0745,
          timeZone: 'America/New_York',
          utcOffset: -4, // EDT
        );
      case 'B':
        return const WorldCupVenue(
          venueId: 'sofi',
          name: 'SoFi Stadium',
          city: 'Inglewood',
          country: HostCountry.usa,
          capacity: 70240,
          latitude: 33.9535,
          longitude: -118.3392,
          timeZone: 'America/Los_Angeles',
          utcOffset: -7, // PDT
        );
      case 'C':
        return const WorldCupVenue(
          venueId: 'att',
          name: 'AT&T Stadium',
          city: 'Arlington',
          country: HostCountry.usa,
          capacity: 80000,
          latitude: 32.7473,
          longitude: -97.0945,
          timeZone: 'America/Chicago',
          utcOffset: -5, // CDT
        );
      case 'D':
        return const WorldCupVenue(
          venueId: 'azteca',
          name: 'Estadio Azteca',
          city: 'Mexico City',
          country: HostCountry.mexico,
          capacity: 87523,
          latitude: 19.3029,
          longitude: -99.1506,
          timeZone: 'America/Mexico_City',
          utcOffset: -5, // CDT
        );
      default:
        return const WorldCupVenue(
          venueId: 'metlife',
          name: 'MetLife Stadium',
          city: 'East Rutherford',
          country: HostCountry.usa,
          capacity: 82500,
          latitude: 40.8135,
          longitude: -74.0745,
          timeZone: 'America/New_York',
          utcOffset: -4,
        );
    }
  }

  static WorldCupGroup _createGroup(String letter, List<GroupTeamStanding> standings) {
    return WorldCupGroup(
      groupLetter: letter,
      standings: standings,
    );
  }

  static GroupTeamStanding _standing(
    String code,
    String name,
    int position,
    int played,
    int won,
    int drawn,
    int lost,
    int gf,
    int ga,
  ) {
    final isoCode = _getIsoCode(code);
    return GroupTeamStanding(
      teamCode: code,
      teamName: name,
      flagUrl: 'https://flagcdn.com/w80/$isoCode.png',
      position: position,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: gf,
      goalsAgainst: ga,
      points: won * 3 + drawn,
    );
  }

  static List<BracketMatch> _generateRoundOf32Matches() {
    return List.generate(16, (i) => _createBracketMatch(
      'r32_$i',
      i + 49,
      MatchStage.roundOf32,
      i + 1,
      i.isEven ? 'USA' : 'BRA',
      i.isEven ? 'United States' : 'Brazil',
      i.isEven ? 'MEX' : 'ARG',
      i.isEven ? 'Mexico' : 'Argentina',
    ));
  }

  static List<BracketMatch> _generateRoundOf16Matches() {
    return List.generate(8, (i) => _createBracketMatch(
      'r16_$i',
      i + 49,
      MatchStage.roundOf16,
      i + 1,
      ['USA', 'BRA', 'FRA', 'GER', 'ARG', 'ENG', 'ESP', 'NED'][i],
      ['United States', 'Brazil', 'France', 'Germany', 'Argentina', 'England', 'Spain', 'Netherlands'][i],
      ['MEX', 'URU', 'ITA', 'POR', 'COL', 'SEN', 'JPN', 'BEL'][i],
      ['Mexico', 'Uruguay', 'Italy', 'Portugal', 'Colombia', 'Senegal', 'Japan', 'Belgium'][i],
    ));
  }

  static List<BracketMatch> _generateQuarterFinalMatches() {
    return [
      _createBracketMatch('qf_1', 57, MatchStage.quarterFinal, 1, 'USA', 'United States', 'BRA', 'Brazil'),
      _createBracketMatch('qf_2', 58, MatchStage.quarterFinal, 2, 'FRA', 'France', 'GER', 'Germany'),
      _createBracketMatch('qf_3', 59, MatchStage.quarterFinal, 3, 'ARG', 'Argentina', 'ENG', 'England'),
      _createBracketMatch('qf_4', 60, MatchStage.quarterFinal, 4, 'ESP', 'Spain', 'NED', 'Netherlands'),
    ];
  }

  static List<BracketMatch> _generateSemiFinalMatches() {
    return [
      _createBracketMatch('sf_1', 61, MatchStage.semiFinal, 1, 'USA', 'United States', 'FRA', 'France'),
      _createBracketMatch('sf_2', 62, MatchStage.semiFinal, 2, 'ARG', 'Argentina', 'ESP', 'Spain'),
    ];
  }

  static BracketMatch _createBracketMatch(
    String matchId,
    int matchNumber,
    MatchStage stage,
    int matchNumberInStage,
    String homeCode,
    String homeName,
    String awayCode,
    String awayName,
  ) {
    // Calculate realistic knockout stage dates
    DateTime dateTime;
    if (stage == MatchStage.roundOf32) {
      // Round of 32: June 29 - July 6, 2026
      dateTime = DateTime(2026, 6, 28).add(Duration(days: (matchNumberInStage / 2).ceil()));
    } else if (stage == MatchStage.roundOf16) {
      // Round of 16: July 2-5, 2026
      dateTime = DateTime(2026, 7, 1).add(Duration(days: (matchNumberInStage / 2).ceil()));
    } else if (stage == MatchStage.quarterFinal) {
      // Quarter Finals: July 8-9, 2026
      dateTime = DateTime(2026, 7, 7).add(Duration(days: (matchNumberInStage / 2).ceil()));
    } else if (stage == MatchStage.semiFinal) {
      // Semi Finals: July 12-13, 2026
      dateTime = DateTime(2026, 7, 11).add(Duration(days: matchNumberInStage));
    } else if (stage == MatchStage.thirdPlace) {
      // Third Place: July 18, 2026
      dateTime = DateTime(2026, 7, 18, 18, 0);
    } else {
      // Final: July 19, 2026 at MetLife Stadium
      dateTime = DateTime(2026, 7, 19, 19, 0);
    }

    return BracketMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      stage: stage,
      matchNumberInStage: matchNumberInStage,
      homeSlot: BracketSlot(
        slotId: '${matchId}_home',
        stage: stage,
        matchNumberInStage: matchNumberInStage,
        teamCode: homeCode,
        teamNameOrPlaceholder: homeName,
        isConfirmed: true,
      ),
      awaySlot: BracketSlot(
        slotId: '${matchId}_away',
        stage: stage,
        matchNumberInStage: matchNumberInStage,
        teamCode: awayCode,
        teamNameOrPlaceholder: awayName,
        isConfirmed: true,
      ),
      status: MatchStatus.scheduled,
      dateTime: dateTime,
    );
  }
}
