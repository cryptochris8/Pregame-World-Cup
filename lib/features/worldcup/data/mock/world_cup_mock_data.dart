import '../../domain/entities/entities.dart';

/// Provides mock data for World Cup 2026 development and testing
class WorldCupMockData {
  WorldCupMockData._();

  /// All 48 qualified teams for World Cup 2026
  static final List<NationalTeam> teams = [
    // Host Nations
    _team('USA', 'United States', 'USA', Confederation.concacaf, 11, 'D', 0, true,
        coach: 'Mauricio Pochettino', nickname: 'The Yanks', captain: 'Christian Pulisic',
        primaryColor: '#002868', secondaryColor: '#BF0A30',
        stars: ['Christian Pulisic', 'Weston McKennie', 'Tyler Adams', 'Gio Reyna'],
        appearances: 11, bestFinish: 'Semi-finals (1930)'),
    _team('MEX', 'Mexico', 'MEX', Confederation.concacaf, 15, 'A', 0, true,
        coach: 'Javier Aguirre', nickname: 'El Tri', captain: 'Edson Álvarez',
        primaryColor: '#006847', secondaryColor: '#CE1126',
        stars: ['Hirving Lozano', 'Edson Álvarez', 'Raúl Jiménez', 'Santiago Giménez'],
        appearances: 17, bestFinish: 'Quarter-finals (1970, 1986)'),
    _team('CAN', 'Canada', 'CAN', Confederation.concacaf, 43, 'B', 0, true,
        coach: 'Jesse Marsch', nickname: 'Les Rouges', captain: 'Alphonso Davies',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Alphonso Davies', 'Jonathan David', 'Tajon Buchanan', 'Cyle Larin'],
        appearances: 2, bestFinish: 'Group Stage (1986, 2022)'),

    // CONCACAF (additional qualified)
    _team('PAN', 'Panama', 'PAN', Confederation.concacaf, 48, 'L', 0, false,
        coach: 'Thomas Christiansen', nickname: 'Los Canaleros', captain: 'Aníbal Godoy',
        primaryColor: '#C8102E', secondaryColor: '#FFFFFF',
        stars: ['José Luis Rodríguez', 'Édgar Bárcenas', 'Cecilio Waterman', 'Adalberto Carrasquilla'],
        appearances: 2, bestFinish: 'Group Stage (2018, 2022)'),
    _team('CUR', 'Curaçao', 'CUR', Confederation.concacaf, 85, 'E', 0, false,
        coach: 'Dick Advocaat', nickname: 'The Island Boys', captain: 'Cuco Martina',
        primaryColor: '#002B7F', secondaryColor: '#F9E814',
        stars: ['Cuco Martina', 'Juninho Bacuna', 'Kenji Gorré', 'Jarchinio Antonia'],
        appearances: 0, bestFinish: 'First appearance'),
    _team('HAI', 'Haiti', 'HAI', Confederation.concacaf, 80, 'C', 0, false,
        coach: 'Marc Collat', nickname: 'Les Grenadiers', captain: 'Duckens Nazon',
        primaryColor: '#00209F', secondaryColor: '#D21034',
        stars: ['Duckens Nazon', 'Derrick Etienne Jr.', 'Frantzdy Pierrot', 'Carlens Arcus'],
        appearances: 1, bestFinish: 'Group Stage (1974)'),

    // CONMEBOL (6 teams)
    _team('BRA', 'Brazil', 'BRA', Confederation.conmebol, 5, 'C', 5, false,
        coach: 'Carlo Ancelotti', nickname: 'A Seleção', captain: 'Marquinhos',
        primaryColor: '#FFDF00', secondaryColor: '#009739',
        stars: ['Vinícius Jr.', 'Rodrygo', 'Endrick', 'Bruno Guimarães'],
        appearances: 22, bestFinish: 'Winner (1958, 1962, 1970, 1994, 2002)'),
    _team('ARG', 'Argentina', 'ARG', Confederation.conmebol, 1, 'J', 3, false,
        coach: 'Lionel Scaloni', nickname: 'La Albiceleste', captain: 'Lionel Messi',
        primaryColor: '#75AADB', secondaryColor: '#FFFFFF',
        stars: ['Lionel Messi', 'Julián Álvarez', 'Enzo Fernández', 'Lautaro Martínez'],
        appearances: 18, bestFinish: 'Winner (1978, 1986, 2022)'),
    _team('URU', 'Uruguay', 'URU', Confederation.conmebol, 17, 'H', 2, false,
        coach: 'Marcelo Bielsa', nickname: 'La Celeste', captain: 'José María Giménez',
        primaryColor: '#0038A8', secondaryColor: '#FFFFFF',
        stars: ['Federico Valverde', 'Darwin Núñez', 'Ronald Araújo', 'Rodrigo Bentancur'],
        appearances: 14, bestFinish: 'Winner (1930, 1950)'),
    _team('COL', 'Colombia', 'COL', Confederation.conmebol, 12, 'K', 0, false,
        coach: 'Néstor Lorenzo', nickname: 'Los Cafeteros', captain: 'James Rodríguez',
        primaryColor: '#FCD116', secondaryColor: '#003893',
        stars: ['Luis Díaz', 'James Rodríguez', 'Jhon Arias', 'Jefferson Lerma'],
        appearances: 6, bestFinish: 'Quarter-finals (2014)'),
    _team('ECU', 'Ecuador', 'ECU', Confederation.conmebol, 28, 'E', 0, false,
        coach: 'Sebastián Beccacece', nickname: 'La Tri', captain: 'Enner Valencia',
        primaryColor: '#FFD100', secondaryColor: '#0033A0',
        stars: ['Moisés Caicedo', 'Enner Valencia', 'Pervis Estupiñán', 'Piero Hincapié'],
        appearances: 4, bestFinish: 'Round of 16 (2006)'),
    _team('PAR', 'Paraguay', 'PAR', Confederation.conmebol, 55, 'D', 0, false,
        coach: 'Alfaro', nickname: 'La Albirroja', captain: 'Gustavo Gómez',
        primaryColor: '#DA291C', secondaryColor: '#FFFFFF',
        stars: ['Miguel Almirón', 'Gustavo Gómez', 'Julio Enciso', 'Ángel Romero'],
        appearances: 8, bestFinish: 'Round of 16 (2010)'),

    // UEFA (13 teams)
    _team('FRA', 'France', 'FRA', Confederation.uefa, 2, 'I', 2, false,
        coach: 'Didier Deschamps', nickname: 'Les Bleus', captain: 'Kylian Mbappé',
        primaryColor: '#002395', secondaryColor: '#FFFFFF',
        stars: ['Kylian Mbappé', 'Antoine Griezmann', 'Aurélien Tchouaméni', 'Eduardo Camavinga'],
        appearances: 16, bestFinish: 'Winner (1998, 2018)'),
    _team('ENG', 'England', 'ENG', Confederation.uefa, 4, 'L', 1, false,
        coach: 'Thomas Tuchel', nickname: 'Three Lions', captain: 'Harry Kane',
        primaryColor: '#FFFFFF', secondaryColor: '#002366',
        stars: ['Harry Kane', 'Jude Bellingham', 'Phil Foden', 'Bukayo Saka'],
        appearances: 16, bestFinish: 'Winner (1966)'),
    _team('ESP', 'Spain', 'ESP', Confederation.uefa, 8, 'H', 1, false,
        coach: 'Luis de la Fuente', nickname: 'La Roja', captain: 'Álvaro Morata',
        primaryColor: '#AA151B', secondaryColor: '#F1BF00',
        stars: ['Lamine Yamal', 'Pedri', 'Nico Williams', 'Rodri'],
        appearances: 16, bestFinish: 'Winner (2010)'),
    _team('GER', 'Germany', 'GER', Confederation.uefa, 16, 'E', 4, false,
        coach: 'Julian Nagelsmann', nickname: 'Die Mannschaft', captain: 'İlkay Gündoğan',
        primaryColor: '#000000', secondaryColor: '#FFFFFF',
        stars: ['Jamal Musiala', 'Florian Wirtz', 'Kai Havertz', 'Joshua Kimmich'],
        appearances: 20, bestFinish: 'Winner (1954, 1974, 1990, 2014)'),
    _team('NED', 'Netherlands', 'NED', Confederation.uefa, 7, 'F', 0, false,
        coach: 'Ronald Koeman', nickname: 'Oranje', captain: 'Virgil van Dijk',
        primaryColor: '#FF6600', secondaryColor: '#FFFFFF',
        stars: ['Virgil van Dijk', 'Frenkie de Jong', 'Cody Gakpo', 'Xavi Simons'],
        appearances: 11, bestFinish: 'Runner-up (1974, 1978, 2010)'),
    _team('POR', 'Portugal', 'POR', Confederation.uefa, 6, 'K', 0, false,
        coach: 'Roberto Martínez', nickname: 'A Seleção', captain: 'Cristiano Ronaldo',
        primaryColor: '#FF0000', secondaryColor: '#006600',
        stars: ['Cristiano Ronaldo', 'Bruno Fernandes', 'Rafael Leão', 'Bernardo Silva'],
        appearances: 8, bestFinish: 'Third Place (1966)'),
    _team('BEL', 'Belgium', 'BEL', Confederation.uefa, 3, 'G', 0, false,
        coach: 'Domenico Tedesco', nickname: 'Red Devils', captain: 'Kevin De Bruyne',
        primaryColor: '#ED2939', secondaryColor: '#000000',
        stars: ['Kevin De Bruyne', 'Romelu Lukaku', 'Jérémy Doku', 'Amadou Onana'],
        appearances: 14, bestFinish: 'Third Place (2018)'),
    _team('BIH', 'Bosnia and Herzegovina', 'BIH', Confederation.uefa, 36, 'B', 0, false,
        coach: 'Sergej Barbarez', nickname: 'Zmajevi', captain: 'Edin Džeko',
        primaryColor: '#002395', secondaryColor: '#FECB00',
        stars: ['Edin Džeko', 'Ermedin Demirović', 'Haris Tabakovic', 'Anel Ahmedhodžić'],
        appearances: 1, bestFinish: 'Group Stage (2014)'),
    _team('CRO', 'Croatia', 'CRO', Confederation.uefa, 10, 'L', 0, false,
        coach: 'Zlatko Dalić', nickname: 'Vatreni', captain: 'Luka Modrić',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Luka Modrić', 'Mateo Kovačić', 'Joško Gvardiol', 'Andrej Kramarić'],
        appearances: 6, bestFinish: 'Runner-up (2018)'),
    _team('CZE', 'Czechia', 'CZE', Confederation.uefa, 28, 'A', 0, false,
        coach: 'Ivan Hašek', nickname: 'Národní tým', captain: 'Tomáš Souček',
        primaryColor: '#11457E', secondaryColor: '#FFFFFF',
        stars: ['Tomáš Souček', 'Patrik Schick', 'Adam Hložek', 'Pavel Šulc'],
        appearances: 2, bestFinish: 'Group Stage (2006)'),
    _team('SUI', 'Switzerland', 'SUI', Confederation.uefa, 19, 'B', 0, false,
        coach: 'Murat Yakin', nickname: 'Nati', captain: 'Granit Xhaka',
        primaryColor: '#FF0000', secondaryColor: '#FFFFFF',
        stars: ['Granit Xhaka', 'Manuel Akanji', 'Xherdan Shaqiri', 'Breel Embolo'],
        appearances: 12, bestFinish: 'Quarter-finals (1934, 1938, 1954)'),
    _team('AUT', 'Austria', 'AUT', Confederation.uefa, 25, 'J', 0, false,
        coach: 'Ralf Rangnick', nickname: 'Das Team', captain: 'David Alaba',
        primaryColor: '#ED2939', secondaryColor: '#FFFFFF',
        stars: ['David Alaba', 'Marcel Sabitzer', 'Konrad Laimer', 'Christoph Baumgartner'],
        appearances: 7, bestFinish: 'Third Place (1954)'),
    _team('TUR', 'Turkey', 'TUR', Confederation.uefa, 42, 'D', 0, false,
        coach: 'Vincenzo Montella', nickname: 'Crescent Stars', captain: 'Hakan Çalhanoğlu',
        primaryColor: '#E30A17', secondaryColor: '#FFFFFF',
        stars: ['Hakan Çalhanoğlu', 'Arda Güler', 'Kenan Yıldız', 'Barış Alper Yılmaz'],
        appearances: 2, bestFinish: 'Third Place (2002)'),
    _team('NOR', 'Norway', 'NOR', Confederation.uefa, 30, 'I', 0, false,
        coach: 'Ståle Solbakken', nickname: 'Drageblosen', captain: 'Martin Ødegaard',
        primaryColor: '#EF2B2D', secondaryColor: '#002868',
        stars: ['Erling Haaland', 'Martin Ødegaard', 'Alexander Sørloth', 'Sander Berge'],
        appearances: 3, bestFinish: 'Round of 16 (1998)'),
    _team('SCO', 'Scotland', 'SCO', Confederation.uefa, 40, 'C', 0, false,
        coach: 'Steve Clarke', nickname: 'The Tartan Army', captain: 'Andy Robertson',
        primaryColor: '#003399', secondaryColor: '#FFFFFF',
        stars: ['Andy Robertson', 'Scott McTominay', 'John McGinn', 'Che Adams'],
        appearances: 8, bestFinish: 'Group Stage'),

    // AFC (8 teams)
    _team('JPN', 'Japan', 'JPN', Confederation.afc, 18, 'F', 0, false,
        coach: 'Hajime Moriyasu', nickname: 'Samurai Blue', captain: 'Maya Yoshida',
        primaryColor: '#000080', secondaryColor: '#FFFFFF',
        stars: ['Takefusa Kubo', 'Kaoru Mitoma', 'Ritsu Doan', 'Wataru Endo'],
        appearances: 7, bestFinish: 'Round of 16 (2002, 2010, 2018, 2022)'),
    _team('KOR', 'Korea Republic', 'KOR', Confederation.afc, 23, 'A', 0, false,
        coach: 'Hong Myung-bo', nickname: 'Taegeuk Warriors', captain: 'Son Heung-min',
        primaryColor: '#C60C30', secondaryColor: '#FFFFFF',
        stars: ['Son Heung-min', 'Lee Kang-in', 'Kim Min-jae', 'Hwang Hee-chan'],
        appearances: 11, bestFinish: 'Fourth Place (2002)'),
    _team('AUS', 'Australia', 'AUS', Confederation.afc, 27, 'D', 0, false,
        coach: 'Tony Popovic', nickname: 'Socceroos', captain: 'Maty Ryan',
        primaryColor: '#FFCD00', secondaryColor: '#00843D',
        stars: ['Mathew Leckie', 'Jackson Irvine', 'Ajdin Hrustic', 'Harry Souttar'],
        appearances: 6, bestFinish: 'Round of 16 (2006, 2022)'),
    _team('IRN', 'Iran', 'IRN', Confederation.afc, 24, 'G', 0, false,
        coach: 'Amir Ghalenoei', nickname: 'Team Melli', captain: 'Alireza Jahanbakhsh',
        primaryColor: '#FFFFFF', secondaryColor: '#C8102E',
        stars: ['Mehdi Taremi', 'Sardar Azmoun', 'Alireza Jahanbakhsh', 'Saman Ghoddos'],
        appearances: 6, bestFinish: 'Group Stage'),
    _team('KSA', 'Saudi Arabia', 'KSA', Confederation.afc, 56, 'H', 0, false,
        coach: 'Hervé Renard', nickname: 'The Green Falcons', captain: 'Salman Al-Faraj',
        primaryColor: '#006C35', secondaryColor: '#FFFFFF',
        stars: ['Salem Al-Dawsari', 'Salman Al-Faraj', 'Firas Al-Buraikan', 'Mohammed Al-Burayk'],
        appearances: 7, bestFinish: 'Round of 16 (1994)'),
    _team('QAT', 'Qatar', 'QAT', Confederation.afc, 37, 'B', 0, false,
        coach: 'Luis García', nickname: 'Al-Annabi', captain: 'Hassan Al-Haydos',
        primaryColor: '#8D1B3D', secondaryColor: '#FFFFFF',
        stars: ['Akram Afif', 'Almoez Ali', 'Hassan Al-Haydos', 'Karim Boudiaf'],
        appearances: 1, bestFinish: 'Group Stage (2022)'),
    _team('SWE', 'Sweden', 'SWE', Confederation.uefa, 20, 'F', 0, false,
        coach: 'Jon Dahl Tomasson', nickname: 'Blågult', captain: 'Viktor Gyökeres',
        primaryColor: '#006AA7', secondaryColor: '#FECC02',
        stars: ['Viktor Gyökeres', 'Alexander Isak', 'Dejan Kulusevski', 'Anthony Elanga'],
        appearances: 12, bestFinish: 'Runner-up (1958)'),
    _team('IRQ', 'Iraq', 'IRQ', Confederation.afc, 55, 'I', 0, false,
        coach: 'Jesús Casas', nickname: 'Lions of Mesopotamia', captain: 'Mohanad Ali',
        primaryColor: '#007A3D', secondaryColor: '#FFFFFF',
        stars: ['Mohanad Ali', 'Amjad Attwan', 'Ibrahim Bayesh', 'Ali Adnan'],
        appearances: 1, bestFinish: 'Group Stage (1986)'),
    _team('JOR', 'Jordan', 'JOR', Confederation.afc, 65, 'J', 0, false,
        coach: 'Hussein Ammouta', nickname: 'Al-Nashama', captain: 'Mousa Al-Taamari',
        primaryColor: '#007A33', secondaryColor: '#FFFFFF',
        stars: ['Mousa Al-Taamari', 'Yazan Al-Naimat', 'Ehsan Haddad', 'Abdallah Nasib'],
        appearances: 0, bestFinish: 'First appearance'),
    _team('UZB', 'Uzbekistan', 'UZB', Confederation.afc, 65, 'K', 0, false,
        coach: 'Srecko Katanec', nickname: 'White Wolves', captain: 'Eldor Shomurodov',
        primaryColor: '#1EB53A', secondaryColor: '#0099B5',
        stars: ['Eldor Shomurodov', 'Abbosbek Fayzullaev', 'Jaloliddin Masharipov', 'Otabek Shukurov'],
        appearances: 0, bestFinish: 'First appearance'),

    // CAF (9 teams)
    _team('MAR', 'Morocco', 'MAR', Confederation.caf, 13, 'C', 0, false,
        coach: 'Walid Regragui', nickname: 'Atlas Lions', captain: 'Romain Saïss',
        primaryColor: '#C1272D', secondaryColor: '#006233',
        stars: ['Achraf Hakimi', 'Hakim Ziyech', 'Youssef En-Nesyri', 'Sofyan Amrabat'],
        appearances: 6, bestFinish: 'Semi-finals (2022)'),
    _team('SEN', 'Senegal', 'SEN', Confederation.caf, 20, 'I', 0, false,
        coach: 'Aliou Cissé', nickname: 'Lions of Teranga', captain: 'Kalidou Koulibaly',
        primaryColor: '#00853F', secondaryColor: '#FDEF42',
        stars: ['Sadio Mané', 'Kalidou Koulibaly', 'Édouard Mendy', 'Ismaïla Sarr'],
        appearances: 3, bestFinish: 'Quarter-finals (2002)'),
    _team('EGY', 'Egypt', 'EGY', Confederation.caf, 36, 'G', 0, false,
        coach: 'Hossam Hassan', nickname: 'The Pharaohs', captain: 'Mohamed Salah',
        primaryColor: '#C8102E', secondaryColor: '#FFFFFF',
        stars: ['Mohamed Salah', 'Omar Marmoush', 'Mahmoud Hassan Trezeguet', 'Mohamed Elneny'],
        appearances: 3, bestFinish: 'Group Stage'),
    _team('GHA', 'Ghana', 'GHA', Confederation.caf, 60, 'L', 0, false,
        coach: 'Otto Addo', nickname: 'Black Stars', captain: 'Andre Ayew',
        primaryColor: '#006B3F', secondaryColor: '#FCD116',
        stars: ['Mohammed Kudus', 'Thomas Partey', 'Andre Ayew', 'Jordan Ayew'],
        appearances: 4, bestFinish: 'Quarter-finals (2010)'),
    _team('CIV', 'Ivory Coast', 'CIV', Confederation.caf, 46, 'E', 0, false,
        coach: 'Emerse Faé', nickname: 'The Elephants', captain: 'Serge Aurier',
        primaryColor: '#F77F00', secondaryColor: '#009E60',
        stars: ['Sébastien Haller', 'Nicolas Pépé', 'Franck Kessié', 'Simon Adingra'],
        appearances: 3, bestFinish: 'Group Stage'),
    _team('ALG', 'Algeria', 'ALG', Confederation.caf, 31, 'J', 0, false,
        coach: 'Vladimir Petković', nickname: 'Les Fennecs', captain: 'Riyad Mahrez',
        primaryColor: '#006633', secondaryColor: '#FFFFFF',
        stars: ['Riyad Mahrez', 'Ismaël Bennacer', 'Islam Slimani', 'Saïd Benrahma'],
        appearances: 4, bestFinish: 'Round of 16 (2014)'),
    _team('TUN', 'Tunisia', 'TUN', Confederation.caf, 35, 'F', 0, false,
        coach: 'Faouzi Benzarti', nickname: 'Eagles of Carthage', captain: 'Youssef Msakni',
        primaryColor: '#E70013', secondaryColor: '#FFFFFF',
        stars: ['Youssef Msakni', 'Wahbi Khazri', 'Hannibal Mejbri', 'Aïssa Laïdouni'],
        appearances: 6, bestFinish: 'Group Stage'),
    _team('RSA', 'South Africa', 'RSA', Confederation.caf, 65, 'A', 0, false,
        coach: 'Hugo Broos', nickname: 'Bafana Bafana', captain: 'Ronwen Williams',
        primaryColor: '#007749', secondaryColor: '#FFB81C',
        stars: ['Percy Tau', 'Ronwen Williams', 'Themba Zwane', 'Bongokuhle Hlongwane'],
        appearances: 3, bestFinish: 'Group Stage (1998, 2002, 2010)'),
    _team('CPV', 'Cabo Verde', 'CPV', Confederation.caf, 70, 'H', 0, false,
        coach: 'Bubista', nickname: 'Blue Sharks', captain: 'Ryan Mendes',
        primaryColor: '#003893', secondaryColor: '#CD2E3A',
        stars: ['Ryan Mendes', 'Garry Rodrigues', 'Kenny Rocha Santos', 'Stopira'],
        appearances: 0, bestFinish: 'First appearance'),
    _team('COD', 'DR Congo', 'COD', Confederation.caf, 55, 'K', 0, false,
        coach: 'Sébastien Desabre', nickname: 'The Leopards', captain: 'Chancel Mbemba',
        primaryColor: '#007FFF', secondaryColor: '#CE1126',
        stars: ['Chancel Mbemba', 'Cédric Bakambu', 'Yoane Wissa', 'Samuel Moutoussamy'],
        appearances: 1, bestFinish: 'Group Stage (1974, as Zaire)'),

    // OFC (1 team)
    _team('NZL', 'New Zealand', 'NZL', Confederation.ofc, 93, 'G', 0, false,
        coach: 'Darren Bazeley', nickname: 'All Whites', captain: 'Chris Wood',
        primaryColor: '#FFFFFF', secondaryColor: '#000000',
        stars: ['Chris Wood', 'Liberato Cacace', 'Matt Garbett', 'Marko Stamenic'],
        appearances: 2, bestFinish: 'Group Stage (2010)'),
  ];

  /// Sample group stage matches
  static List<WorldCupMatch> get groupStageMatches {
    final matches = <WorldCupMatch>[];
    int matchNumber = 1;

    // Group A matches
    matches.addAll(_generateGroupMatches('A', ['MEX', 'KOR', 'DEN', 'RSA'], matchNumber));
    matchNumber += 6;

    // Group B matches
    matches.addAll(_generateGroupMatches('B', ['SUI', 'ITA', 'CAN', 'QAT'], matchNumber));
    matchNumber += 6;

    // Group C matches
    matches.addAll(_generateGroupMatches('C', ['BRA', 'MAR', 'SCO', 'HAI'], matchNumber));
    matchNumber += 6;

    // Group D matches
    matches.addAll(_generateGroupMatches('D', ['USA', 'PAR', 'TUR', 'AUS'], matchNumber));
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
    awayTeamCode: 'RSA',
    awayTeamName: 'South Africa',
    awayTeamFlagUrl: 'https://flagcdn.com/w80/za.png',
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
    homeGoalScorers: const ['Lozano 12\'', 'Herrera 55\''],
    awayGoalScorers: const ['Tau 38\''],
  );

  /// Sample group standings
  static List<WorldCupGroup> get groups {
    return [
      _createGroup('A', [
        _standing('MEX', 'Mexico', 1, 3, 2, 1, 0, 5, 2),
        _standing('KOR', 'Korea Republic', 2, 3, 2, 0, 1, 4, 3),
        _standing('CZE', 'Czechia', 3, 3, 1, 1, 1, 3, 3),
        _standing('RSA', 'South Africa', 4, 3, 0, 0, 3, 1, 5),
      ]),
      _createGroup('B', [
        _standing('BIH', 'Bosnia and Herzegovina', 1, 3, 3, 0, 0, 7, 1),
        _standing('SUI', 'Switzerland', 2, 3, 2, 0, 1, 5, 3),
        _standing('CAN', 'Canada', 3, 3, 1, 0, 2, 3, 4),
        _standing('QAT', 'Qatar', 4, 3, 0, 0, 3, 0, 7),
      ]),
      _createGroup('C', [
        _standing('BRA', 'Brazil', 1, 3, 2, 1, 0, 4, 1),
        _standing('MAR', 'Morocco', 2, 3, 1, 2, 0, 3, 2),
        _standing('SCO', 'Scotland', 3, 3, 1, 0, 2, 2, 4),
        _standing('HAI', 'Haiti', 4, 3, 0, 1, 2, 2, 4),
      ]),
      _createGroup('D', [
        _standing('USA', 'United States', 1, 3, 3, 0, 0, 8, 2),
        _standing('TUR', 'Turkey', 2, 3, 2, 0, 1, 5, 3),
        _standing('PAR', 'Paraguay', 3, 3, 1, 0, 2, 4, 5),
        _standing('AUS', 'Australia', 4, 3, 0, 0, 3, 1, 8),
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

  // Team code to ISO country code mapping for flag URLs
  static const Map<String, String> _fifaToIsoCode = {
    // CONCACAF
    'USA': 'us', 'MEX': 'mx', 'CAN': 'ca', 'PAN': 'pa',
    'CUR': 'cw', 'HAI': 'ht',
    // CONMEBOL
    'BRA': 'br', 'ARG': 'ar', 'URU': 'uy', 'COL': 'co', 'ECU': 'ec',
    'PAR': 'py',
    // UEFA
    'FRA': 'fr', 'ENG': 'gb-eng', 'ESP': 'es', 'GER': 'de', 'NED': 'nl',
    'POR': 'pt', 'BEL': 'be', 'ITA': 'it', 'CRO': 'hr', 'DEN': 'dk',
    'SUI': 'ch', 'AUT': 'at', 'TUR': 'tr', 'NOR': 'no', 'SCO': 'gb-sct',
    // AFC
    'JPN': 'jp', 'KOR': 'kr', 'AUS': 'au', 'IRN': 'ir', 'KSA': 'sa',
    'QAT': 'qa', 'IDN': 'id', 'IRQ': 'iq', 'JOR': 'jo', 'UZB': 'uz',
    // CAF
    'MAR': 'ma', 'SEN': 'sn', 'EGY': 'eg', 'GHA': 'gh',
    'CIV': 'ci', 'ALG': 'dz', 'TUN': 'tn', 'RSA': 'za',
    'CPV': 'cv', 'COD': 'cd',
    // OFC
    'NZL': 'nz',
  };

  /// Get ISO country code from team code for flag URL
  static String _getIsoCode(String teamCode) {
    return _fifaToIsoCode[teamCode] ?? teamCode.toLowerCase();
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
    int appearances = 0,
    String? bestFinish,
  }) {
    final isoCode = _getIsoCode(code);
    return NationalTeam(
      teamCode: code,
      countryName: name,
      shortName: shortName,
      flagUrl: 'https://flagcdn.com/w80/$isoCode.png',
      confederation: conf,
      worldRanking: ranking,
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
      worldCupAppearances: appearances,
      bestFinish: bestFinish,
    );
  }

  static List<WorldCupMatch> _generateGroupMatches(
    String group,
    List<String> teamCodes,
    int startMatchNumber,
  ) {
    final matches = <WorldCupMatch>[];
    final teams = teamCodes.map((code) =>
      WorldCupMockData.teams.firstWhere((t) => t.teamCode == code)
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
      homeTeamCode: home.teamCode,
      homeTeamName: home.countryName,
      homeTeamFlagUrl: home.flagUrl,
      awayTeamCode: away.teamCode,
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

  /// Head-to-head records for major team rivalries
  static final List<HeadToHead> headToHeadRecords = [
    // Brazil vs Argentina - El Superclásico de las Américas
    HeadToHead(
      team1Code: 'ARG',
      team2Code: 'BRA',
      totalMatches: 111,
      team1Wins: 40,
      team2Wins: 46,
      draws: 25,
      team1Goals: 163,
      team2Goals: 168,
      worldCupMatches: 4,
      team1WorldCupWins: 1,
      team2WorldCupWins: 2,
      worldCupDraws: 1,
      lastMatch: DateTime(2024, 11, 19),
      firstMeeting: DateTime(1914, 9, 20),
      notableMatches: const [
        HistoricalMatch(
          year: 1990,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 1,
          team2Score: 0,
          winnerCode: 'ARG',
          location: 'Turin, Italy',
          description: 'Caniggia stunner eliminates Brazil',
        ),
        HistoricalMatch(
          year: 1982,
          tournament: 'World Cup',
          stage: 'Second Round',
          team1Score: 1,
          team2Score: 3,
          winnerCode: 'BRA',
          location: 'Barcelona, Spain',
          description: 'Zico masterclass, Maradona sent off',
        ),
        HistoricalMatch(
          year: 1978,
          tournament: 'World Cup',
          stage: 'Second Round',
          team1Score: 0,
          team2Score: 0,
          location: 'Rosario, Argentina',
          description: 'Tense draw in Argentina\'s World Cup run',
        ),
        HistoricalMatch(
          year: 1974,
          tournament: 'World Cup',
          stage: 'Second Round',
          team1Score: 1,
          team2Score: 2,
          winnerCode: 'BRA',
          location: 'Hanover, Germany',
          description: 'Rivellino and Jairzinho goals',
        ),
      ],
    ),

    // England vs Germany - Classic European rivalry
    HeadToHead(
      team1Code: 'ENG',
      team2Code: 'GER',
      totalMatches: 37,
      team1Wins: 14,
      team2Wins: 15,
      draws: 8,
      team1Goals: 53,
      team2Goals: 49,
      worldCupMatches: 8,
      team1WorldCupWins: 2,
      team2WorldCupWins: 4,
      worldCupDraws: 2,
      lastMatch: DateTime(2022, 9, 26),
      firstMeeting: DateTime(1930, 5, 10),
      notableMatches: const [
        HistoricalMatch(
          year: 2021,
          tournament: 'Euro 2020',
          stage: 'Round of 16',
          team1Score: 2,
          team2Score: 0,
          winnerCode: 'ENG',
          location: 'London, England',
          description: 'Sterling and Kane end German hex at Wembley',
        ),
        HistoricalMatch(
          year: 2010,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 1,
          team2Score: 4,
          winnerCode: 'GER',
          location: 'Bloemfontein, South Africa',
          description: 'Lampard ghost goal denied, Germany rout',
        ),
        HistoricalMatch(
          year: 1996,
          tournament: 'Euro 96',
          stage: 'Semi-Final',
          team1Score: 1,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'London, England',
          description: 'Germany wins 6-5 on penalties, Southgate miss',
        ),
        HistoricalMatch(
          year: 1990,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 1,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Turin, Italy',
          description: 'Germany wins 4-3 on penalties, Waddle blazes over',
        ),
        HistoricalMatch(
          year: 1966,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 4,
          team2Score: 2,
          winnerCode: 'ENG',
          location: 'London, England',
          description: 'Hurst hat-trick, "They think it\'s all over"',
        ),
      ],
    ),

    // USA vs Mexico - CONCACAF rivalry
    HeadToHead(
      team1Code: 'MEX',
      team2Code: 'USA',
      totalMatches: 76,
      team1Wins: 36,
      team2Wins: 23,
      draws: 17,
      team1Goals: 139,
      team2Goals: 99,
      worldCupMatches: 2,
      team1WorldCupWins: 0,
      team2WorldCupWins: 0,
      worldCupDraws: 2,
      lastMatch: DateTime(2024, 10, 15),
      firstMeeting: DateTime(1934, 5, 24),
      notableMatches: const [
        HistoricalMatch(
          year: 2022,
          tournament: 'World Cup Qualifier',
          team1Score: 0,
          team2Score: 0,
          location: 'Mexico City, Mexico',
          description: 'Crucial qualifier draw at Azteca',
        ),
        HistoricalMatch(
          year: 2021,
          tournament: 'Nations League Final',
          team1Score: 2,
          team2Score: 3,
          winnerCode: 'USA',
          location: 'Denver, USA',
          description: 'Pulisic penalty wins it in extra time',
        ),
        HistoricalMatch(
          year: 2002,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 0,
          team2Score: 2,
          winnerCode: 'USA',
          location: 'Jeonju, South Korea',
          description: 'Dos a Cero - USA\'s famous World Cup upset',
        ),
        HistoricalMatch(
          year: 1997,
          tournament: 'World Cup Qualifier',
          team1Score: 0,
          team2Score: 0,
          location: 'Mexico City, Mexico',
          description: 'First US point at Azteca in qualifiers',
        ),
        HistoricalMatch(
          year: 1934,
          tournament: 'World Cup Qualifier',
          team1Score: 4,
          team2Score: 2,
          winnerCode: 'MEX',
          location: 'Rome, Italy',
          description: 'First ever World Cup meeting',
        ),
      ],
    ),

    // Brazil vs Germany - 7-1 and more
    HeadToHead(
      team1Code: 'BRA',
      team2Code: 'GER',
      totalMatches: 23,
      team1Wins: 12,
      team2Wins: 5,
      draws: 6,
      team1Goals: 41,
      team2Goals: 32,
      worldCupMatches: 4,
      team1WorldCupWins: 2,
      team2WorldCupWins: 2,
      worldCupDraws: 0,
      lastMatch: DateTime(2023, 3, 27),
      firstMeeting: DateTime(1963, 5, 5),
      notableMatches: const [
        HistoricalMatch(
          year: 2014,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 1,
          team2Score: 7,
          winnerCode: 'GER',
          location: 'Belo Horizonte, Brazil',
          description: 'The Mineirazo - Germany\'s historic demolition',
        ),
        HistoricalMatch(
          year: 2002,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 2,
          team2Score: 0,
          winnerCode: 'BRA',
          location: 'Yokohama, Japan',
          description: 'Ronaldo brace crowns Brazil\'s 5th title',
        ),
        HistoricalMatch(
          year: 1981,
          tournament: 'Friendly',
          team1Score: 1,
          team2Score: 4,
          winnerCode: 'GER',
          location: 'Stuttgart, Germany',
          description: 'Rummenigge masterclass',
        ),
        HistoricalMatch(
          year: 2018,
          tournament: 'Friendly',
          team1Score: 1,
          team2Score: 0,
          winnerCode: 'BRA',
          location: 'Berlin, Germany',
          description: 'Jesus goal, partial revenge for 7-1',
        ),
      ],
    ),

    // England vs Argentina - Hand of God rivalry
    HeadToHead(
      team1Code: 'ARG',
      team2Code: 'ENG',
      totalMatches: 15,
      team1Wins: 7,
      team2Wins: 5,
      draws: 3,
      team1Goals: 21,
      team2Goals: 16,
      worldCupMatches: 5,
      team1WorldCupWins: 2,
      team2WorldCupWins: 1,
      worldCupDraws: 2,
      lastMatch: DateTime(2023, 3, 28),
      firstMeeting: DateTime(1951, 5, 9),
      notableMatches: const [
        HistoricalMatch(
          year: 1986,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 2,
          team2Score: 1,
          winnerCode: 'ARG',
          location: 'Mexico City, Mexico',
          description: 'Hand of God and Goal of the Century',
        ),
        HistoricalMatch(
          year: 1998,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 2,
          team2Score: 2,
          winnerCode: 'ARG',
          location: 'Saint-Etienne, France',
          description: 'Beckham red card, Argentina win on penalties',
        ),
        HistoricalMatch(
          year: 2002,
          tournament: 'World Cup',
          stage: 'Group Stage',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'ENG',
          location: 'Sapporo, Japan',
          description: 'Beckham penalty redemption',
        ),
        HistoricalMatch(
          year: 1966,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'ENG',
          location: 'London, England',
          description: 'Hurst goal, Rattin sent off',
        ),
      ],
    ),

    // France vs Germany - European powerhouse rivalry
    HeadToHead(
      team1Code: 'FRA',
      team2Code: 'GER',
      totalMatches: 32,
      team1Wins: 13,
      team2Wins: 10,
      draws: 9,
      team1Goals: 52,
      team2Goals: 45,
      worldCupMatches: 4,
      team1WorldCupWins: 1,
      team2WorldCupWins: 2,
      worldCupDraws: 1,
      lastMatch: DateTime(2024, 3, 23),
      firstMeeting: DateTime(1931, 3, 15),
      notableMatches: const [
        HistoricalMatch(
          year: 2014,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Rio de Janeiro, Brazil',
          description: 'Hummels header sends Germany through',
        ),
        HistoricalMatch(
          year: 1982,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 3,
          team2Score: 3,
          winnerCode: 'GER',
          location: 'Seville, Spain',
          description: 'Epic match, Germany win on penalties',
        ),
        HistoricalMatch(
          year: 1986,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 2,
          team2Score: 0,
          winnerCode: 'FRA',
          location: 'Guadalajara, Mexico',
          description: 'France revenge, reach second straight final',
        ),
        HistoricalMatch(
          year: 2016,
          tournament: 'Euro 2016',
          stage: 'Semi-Final',
          team1Score: 2,
          team2Score: 0,
          winnerCode: 'FRA',
          location: 'Marseille, France',
          description: 'Griezmann brace sends hosts to final',
        ),
      ],
    ),

    // Netherlands vs Germany - Der Klassiker
    HeadToHead(
      team1Code: 'GER',
      team2Code: 'NED',
      totalMatches: 46,
      team1Wins: 17,
      team2Wins: 15,
      draws: 14,
      team1Goals: 74,
      team2Goals: 65,
      worldCupMatches: 4,
      team1WorldCupWins: 2,
      team2WorldCupWins: 1,
      worldCupDraws: 1,
      lastMatch: DateTime(2024, 3, 26),
      firstMeeting: DateTime(1910, 4, 10),
      notableMatches: const [
        HistoricalMatch(
          year: 1974,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 2,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Munich, Germany',
          description: 'Germany comeback, Müller winner',
        ),
        HistoricalMatch(
          year: 1988,
          tournament: 'Euro 88',
          stage: 'Semi-Final',
          team1Score: 1,
          team2Score: 2,
          winnerCode: 'NED',
          location: 'Hamburg, Germany',
          description: 'Van Basten penalty seals Dutch revenge',
        ),
        HistoricalMatch(
          year: 1978,
          tournament: 'World Cup',
          stage: 'Group Stage',
          team1Score: 2,
          team2Score: 2,
          location: 'Córdoba, Argentina',
          description: 'Thrilling draw, both reach second round',
        ),
        HistoricalMatch(
          year: 1990,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 2,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Milan, Italy',
          description: 'Rijkaard-Völler spitting incident',
        ),
      ],
    ),

    // France vs Italy - Euro neighbors
    HeadToHead(
      team1Code: 'FRA',
      team2Code: 'ITA',
      totalMatches: 38,
      team1Wins: 18,
      team2Wins: 10,
      draws: 10,
      team1Goals: 64,
      team2Goals: 40,
      worldCupMatches: 5,
      team1WorldCupWins: 2,
      team2WorldCupWins: 2,
      worldCupDraws: 1,
      lastMatch: DateTime(2024, 9, 6),
      firstMeeting: DateTime(1910, 5, 15),
      notableMatches: const [
        HistoricalMatch(
          year: 2006,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 1,
          team2Score: 1,
          winnerCode: 'ITA',
          location: 'Berlin, Germany',
          description: 'Zidane headbutt, Italy win on penalties',
        ),
        HistoricalMatch(
          year: 2000,
          tournament: 'Euro 2000',
          stage: 'Final',
          team1Score: 2,
          team2Score: 1,
          winnerCode: 'FRA',
          location: 'Rotterdam, Netherlands',
          description: 'Trezeguet golden goal wins it',
        ),
        HistoricalMatch(
          year: 1998,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 0,
          team2Score: 0,
          winnerCode: 'FRA',
          location: 'Saint-Denis, France',
          description: 'France win on penalties at home',
        ),
        HistoricalMatch(
          year: 1938,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 1,
          team2Score: 3,
          winnerCode: 'ITA',
          location: 'Paris, France',
          description: 'Italy defend title en route to win',
        ),
      ],
    ),

    // Argentina vs Germany - World Cup final regulars
    HeadToHead(
      team1Code: 'ARG',
      team2Code: 'GER',
      totalMatches: 23,
      team1Wins: 6,
      team2Wins: 10,
      draws: 7,
      team1Goals: 30,
      team2Goals: 35,
      worldCupMatches: 7,
      team1WorldCupWins: 2,
      team2WorldCupWins: 3,
      worldCupDraws: 2,
      lastMatch: DateTime(2022, 11, 21),
      firstMeeting: DateTime(1958, 6, 8),
      notableMatches: const [
        HistoricalMatch(
          year: 2014,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Rio de Janeiro, Brazil',
          description: 'Götze extra-time goal wins Germany\'s 4th title',
        ),
        HistoricalMatch(
          year: 2010,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 0,
          team2Score: 4,
          winnerCode: 'GER',
          location: 'Cape Town, South Africa',
          description: 'Germany demolish Messi\'s Argentina',
        ),
        HistoricalMatch(
          year: 1986,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 3,
          team2Score: 2,
          winnerCode: 'ARG',
          location: 'Mexico City, Mexico',
          description: 'Maradona inspires dramatic comeback win',
        ),
        HistoricalMatch(
          year: 1990,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Rome, Italy',
          description: 'Brehme penalty, bitter rematch for Argentina',
        ),
        HistoricalMatch(
          year: 2006,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 1,
          team2Score: 1,
          winnerCode: 'GER',
          location: 'Berlin, Germany',
          description: 'Germany win on penalties, Lehmann heroics',
        ),
      ],
    ),

    // Spain vs Portugal - Iberian Derby
    HeadToHead(
      team1Code: 'ESP',
      team2Code: 'POR',
      totalMatches: 38,
      team1Wins: 17,
      team2Wins: 7,
      draws: 14,
      team1Goals: 72,
      team2Goals: 35,
      worldCupMatches: 2,
      team1WorldCupWins: 0,
      team2WorldCupWins: 0,
      worldCupDraws: 2,
      lastMatch: DateTime(2024, 9, 8),
      firstMeeting: DateTime(1921, 12, 18),
      notableMatches: const [
        HistoricalMatch(
          year: 2018,
          tournament: 'World Cup',
          stage: 'Group Stage',
          team1Score: 3,
          team2Score: 3,
          location: 'Sochi, Russia',
          description: 'Ronaldo hat-trick in epic draw',
        ),
        HistoricalMatch(
          year: 2012,
          tournament: 'Euro 2012',
          stage: 'Semi-Final',
          team1Score: 0,
          team2Score: 0,
          winnerCode: 'ESP',
          location: 'Donetsk, Ukraine',
          description: 'Spain win on penalties, Cesc decisive',
        ),
        HistoricalMatch(
          year: 2010,
          tournament: 'World Cup',
          stage: 'Round of 16',
          team1Score: 1,
          team2Score: 0,
          winnerCode: 'ESP',
          location: 'Cape Town, South Africa',
          description: 'Villa goal, Spain march on to glory',
        ),
        HistoricalMatch(
          year: 2004,
          tournament: 'Euro 2004',
          stage: 'Group Stage',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'POR',
          location: 'Lisbon, Portugal',
          description: 'Nuno Gomes goal, hosts advance',
        ),
      ],
    ),

    // Brazil vs France - South American vs European giants
    HeadToHead(
      team1Code: 'BRA',
      team2Code: 'FRA',
      totalMatches: 14,
      team1Wins: 5,
      team2Wins: 4,
      draws: 5,
      team1Goals: 22,
      team2Goals: 21,
      worldCupMatches: 5,
      team1WorldCupWins: 2,
      team2WorldCupWins: 2,
      worldCupDraws: 1,
      lastMatch: DateTime(2023, 3, 26),
      firstMeeting: DateTime(1930, 7, 22),
      notableMatches: const [
        HistoricalMatch(
          year: 1998,
          tournament: 'World Cup',
          stage: 'Final',
          team1Score: 0,
          team2Score: 3,
          winnerCode: 'FRA',
          location: 'Saint-Denis, France',
          description: 'Zidane double, France first title',
        ),
        HistoricalMatch(
          year: 2006,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 0,
          team2Score: 1,
          winnerCode: 'FRA',
          location: 'Frankfurt, Germany',
          description: 'Henry goal ends Brazil\'s run',
        ),
        HistoricalMatch(
          year: 1986,
          tournament: 'World Cup',
          stage: 'Quarter-Final',
          team1Score: 1,
          team2Score: 1,
          winnerCode: 'FRA',
          location: 'Guadalajara, Mexico',
          description: 'France win on penalties, Platini era',
        ),
        HistoricalMatch(
          year: 1958,
          tournament: 'World Cup',
          stage: 'Semi-Final',
          team1Score: 5,
          team2Score: 2,
          winnerCode: 'BRA',
          location: 'Stockholm, Sweden',
          description: 'Pelé hat-trick, Brazil cruise to final',
        ),
      ],
    ),

    // Japan vs South Korea - Asian rivalry
    HeadToHead(
      team1Code: 'JPN',
      team2Code: 'KOR',
      totalMatches: 85,
      team1Wins: 16,
      team2Wins: 44,
      draws: 25,
      team1Goals: 75,
      team2Goals: 142,
      worldCupMatches: 0,
      team1WorldCupWins: 0,
      team2WorldCupWins: 0,
      worldCupDraws: 0,
      lastMatch: DateTime(2024, 3, 21),
      firstMeeting: DateTime(1954, 3, 7),
      notableMatches: const [
        HistoricalMatch(
          year: 2011,
          tournament: 'Asian Cup',
          stage: 'Semi-Final',
          team1Score: 2,
          team2Score: 2,
          winnerCode: 'JPN',
          location: 'Doha, Qatar',
          description: 'Japan win on penalties, reach final',
        ),
        HistoricalMatch(
          year: 2000,
          tournament: 'Asian Cup',
          stage: 'Semi-Final',
          team1Score: 1,
          team2Score: 2,
          winnerCode: 'KOR',
          location: 'Beirut, Lebanon',
          description: 'Korea advance to final',
        ),
        HistoricalMatch(
          year: 2019,
          tournament: 'Asian Cup',
          stage: 'Round of 16',
          team1Score: 1,
          team2Score: 0,
          winnerCode: 'JPN',
          location: 'Abu Dhabi, UAE',
          description: 'Shiotani goal secures Japan win',
        ),
      ],
    ),

    // Senegal vs Ghana - African rivalry
    HeadToHead(
      team1Code: 'GHA',
      team2Code: 'SEN',
      totalMatches: 19,
      team1Wins: 6,
      team2Wins: 6,
      draws: 7,
      team1Goals: 19,
      team2Goals: 17,
      worldCupMatches: 0,
      team1WorldCupWins: 0,
      team2WorldCupWins: 0,
      worldCupDraws: 0,
      lastMatch: DateTime(2024, 3, 26),
      firstMeeting: DateTime(1963, 3, 24),
      notableMatches: const [
        HistoricalMatch(
          year: 2022,
          tournament: 'Africa Cup of Nations',
          stage: 'Final',
          team1Score: 0,
          team2Score: 0,
          winnerCode: 'SEN',
          location: 'Yaoundé, Cameroon',
          description: 'Mané wins AFCON for Senegal on penalties',
        ),
        HistoricalMatch(
          year: 2015,
          tournament: 'Africa Cup of Nations',
          stage: 'Group Stage',
          team1Score: 1,
          team2Score: 2,
          winnerCode: 'SEN',
          location: 'Mongomo, Equatorial Guinea',
          description: 'Mané goal helps Senegal',
        ),
        HistoricalMatch(
          year: 2002,
          tournament: 'Africa Cup of Nations',
          stage: 'Quarter-Final',
          team1Score: 1,
          team2Score: 0,
          winnerCode: 'GHA',
          location: 'Bamako, Mali',
          description: 'Ghana advances to semi-final',
        ),
      ],
    ),
  ];

  /// Get head-to-head record for two teams
  static HeadToHead? getHeadToHead(String team1Code, String team2Code) {
    // Sort codes alphabetically to match stored format
    final codes = [team1Code, team2Code]..sort();
    final searchId = '${codes[0]}_${codes[1]}';

    try {
      return headToHeadRecords.firstWhere((h2h) => h2h.id == searchId);
    } catch (e) {
      return null;
    }
  }

  /// Get all head-to-head records involving a specific team
  static List<HeadToHead> getTeamHeadToHeadRecords(String teamCode) {
    return headToHeadRecords.where((h2h) =>
      h2h.team1Code == teamCode || h2h.team2Code == teamCode
    ).toList();
  }
}
