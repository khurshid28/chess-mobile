import 'bot_personality_model.dart';

class BotCategory {
  final String id;
  final String name;
  final String nameUz;
  final String description;
  final String imageUrl;
  final List<BotPersonality> bots;

  const BotCategory({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.description,
    required this.imageUrl,
    required this.bots,
  });

  int get botCount => bots.length;
}

class BotCategories {
  // Beginner Category - Easy bots for learning
  static final beginner = BotCategory(
    id: 'beginner',
    name: 'Beginner',
    nameUz: 'Boshlang\'ich',
    description: 'Easy bots for beginners',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/a6e19caa-8a5a-11ea-b74e-55003725fb61.909cbd47.384x384o.c4d23e9051ff.png',
    bots: [
      BotPersonalities.all[0], // Rustam
      BotPersonality(
        id: 'aziza',
        name: 'Aziza',
        nameUz: 'Aziza',
        description: 'Just learning how to play',
        avatar: '👧',
        style: 'beginner',
        difficulties: _createStandardDifficulties(400, 800),
      ),
      BotPersonality(
        id: 'bobur',
        name: 'Bobur',
        nameUz: 'Bobur',
        description: 'Learning chess at school',
        avatar: '👦',
        style: 'beginner',
        difficulties: _createStandardDifficulties(500, 900),
      ),
      BotPersonality(
        id: 'malika',
        name: 'Malika',
        nameUz: 'Malika',
        description: 'Newly started player',
        avatar: '👧',
        style: 'beginner',
        difficulties: _createStandardDifficulties(450, 850),
      ),
      BotPersonality(
        id: 'timur',
        name: 'Timur',
        nameUz: 'Timur',
        description: 'Loves strategy games',
        avatar: '🧒',
        style: 'beginner',
        difficulties: _createStandardDifficulties(400, 800),
      ),
    ],
  );

  // Intermediate Category
  static final intermediate = BotCategory(
    id: 'intermediate',
    name: 'Intermediate',
    nameUz: 'O\'rtacha',
    description: 'For intermediate players',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/ee8ff9d8-8a5b-11ea-ad88-f9bb1877a81f.c17c3d32.384x384o.3072a453d392.png',
    bots: [
      BotPersonalities.all[1], // Nodira
      BotPersonalities.all[2], // Jahongir
      BotPersonality(
        id: 'shohruh',
        name: 'Shohruh',
        nameUz: 'Shohruh',
        description: 'University student, knows tactics',
        avatar: '🧑',
        style: 'balanced',
        difficulties: _createStandardDifficulties(900, 1400),
      ),
      BotPersonality(
        id: 'gulnoza',
        name: 'Gulnoza',
        nameUz: 'Gulnoza',
        description: 'Loves classical chess',
        avatar: '👩',
        style: 'positional',
        difficulties: _createStandardDifficulties(850, 1350),
      ),
      BotPersonality(
        id: 'iskandar',
        name: 'Iskandar',
        nameUz: 'Iskandar',
        description: 'Has tournament experience',
        avatar: '🧔',
        style: 'balanced',
        difficulties: _createStandardDifficulties(1000, 1500),
      ),
    ],
  );

  // Advanced Category
  static final advanced = BotCategory(
    id: 'advanced',
    name: 'Advanced',
    nameUz: 'Murakkab',
    description: 'For experienced players',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/30326f88-8a5c-11ea-b234-9b639e301bef.adf1facd.384x384o.39ecdf8795d5.png',
    bots: [
      BotPersonalities.all[3], // Dilshod
      BotPersonalities.all[4], // Sarvar
      BotPersonality(
        id: 'behzod',
        name: 'Behzod',
        nameUz: 'Behzod',
        description: 'Regional champion',
        avatar: '🎖️',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(1500, 2000),
      ),
      BotPersonality(
        id: 'munira',
        name: 'Munira',
        nameUz: 'Munira',
        description: 'Chess coach',
        avatar: '👩‍🏫',
        style: 'positional',
        difficulties: _createStandardDifficulties(1450, 1950),
      ),
      BotPersonality(
        id: 'otabek',
        name: 'Otabek',
        nameUz: 'Otabek',
        description: 'Combination master',
        avatar: '🎯',
        style: 'tactical',
        difficulties: _createStandardDifficulties(1550, 2050),
      ),
    ],
  );

  // Master Category
  static final master = BotCategory(
    id: 'master',
    name: 'Master',
    nameUz: 'Master',
    description: 'Strongest bots',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/bdd36e82-8a5c-11ea-b774-516d3353b2f2.7af80eea.384x384o.74b89e2e6267.png',
    bots: [
      BotPersonalities.all[5], // Shohzoda
      BotPersonality(
        id: 'jamshid',
        name: 'Jamshid',
        nameUz: 'Jamshid',
        description: 'FIDE master',
        avatar: '👑',
        style: 'master',
        difficulties: _createStandardDifficulties(2100, 2600),
      ),
      BotPersonality(
        id: 'zarina',
        name: 'Zarina',
        nameUz: 'Zarina',
        description: 'International grandmaster',
        avatar: '💎',
        style: 'grandmaster',
        difficulties: _createStandardDifficulties(2200, 2700),
      ),
      BotPersonality(
        id: 'ulugbek',
        name: 'Ulugbek',
        nameUz: 'Ulugbek',
        description: 'Plays with astronomical precision',
        avatar: '⭐',
        style: 'scientific',
        difficulties: _createStandardDifficulties(2300, 2800),
      ),
    ],
  );

  // Athletes Category
  static final athletes = BotCategory(
    id: 'athletes',
    name: 'Warriors',
    nameUz: 'Jangchilar',
    description: 'Warrior spirit bots',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/811d9ab4-1b8c-11f0-86ce-efd0265768a6.cfa8800c.384x384o.62368d7c284b.png',
    bots: [
      BotPersonality(
        id: 'amir_temur',
        name: 'Amir Temur',
        nameUz: 'Amir Temur',
        description: 'Great conqueror strategy',
        avatar: '⚔️',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(1300, 1900),
      ),
      BotPersonality(
        id: 'alpomish',
        name: 'Alpomish',
        nameUz: 'Alpomish',
        description: 'Brave and wise',
        avatar: '🛡️',
        style: 'balanced',
        difficulties: _createStandardDifficulties(1250, 1850),
      ),
      BotPersonality(
        id: 'tomaris',
        name: 'Tomaris',
        nameUz: 'Tomaris',
        description: 'Queen Tomaris strategy',
        avatar: '👸',
        style: 'strategic',
        difficulties: _createStandardDifficulties(1400, 2000),
      ),
      BotPersonality(
        id: 'jaloliddin',
        name: 'Jaloliddin',
        nameUz: 'Jaloliddin',
        description: 'Manguberdi battle strategy',
        avatar: '🗡️',
        style: 'tactical',
        difficulties: _createStandardDifficulties(1350, 1950),
      ),
    ],
  );

  // Musicians Category - Replaced with Scientists
  static final musicians = BotCategory(
    id: 'scientists',
    name: 'Scientists',
    nameUz: 'Olimlar',
    description: 'Style of great scholars',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/909edaa2-f2d4-11ee-9c29-ff0b4f8c352f.a0248349.384x384o.f265173ed1e8.png',
    bots: [
      BotPersonality(
        id: 'ibn_sino',
        name: 'Ibn Sino',
        nameUz: 'Ibn Sino',
        description: 'Great physician and wise logic',
        avatar: '📚',
        style: 'logical',
        difficulties: _createStandardDifficulties(1500, 2100),
      ),
      BotPersonality(
        id: 'beruniy',
        name: 'Beruniy',
        nameUz: 'Beruniy',
        description: 'Mathematical precision',
        avatar: '🔬',
        style: 'precise',
        difficulties: _createStandardDifficulties(1450, 2050),
      ),
      BotPersonality(
        id: 'xorazmiy',
        name: 'Xorazmiy',
        nameUz: 'Xorazmiy',
        description: 'Founder of algebra calculations',
        avatar: '➗',
        style: 'mathematical',
        difficulties: _createStandardDifficulties(1550, 2150),
      ),
      BotPersonality(
        id: 'forobiy',
        name: 'Forobiy',
        nameUz: 'Forobiy',
        description: 'Deep philosophical play',
        avatar: '🎓',
        style: 'philosophical',
        difficulties: _createStandardDifficulties(1500, 2100),
      ),
    ],
  );

  // Top Players Category
  static final topPlayers = BotCategory(
    id: 'top_players',
    name: 'Legends',
    nameUz: 'Afsonalar',
    description: 'Chess legends',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/faffe24a-8a5c-11ea-8907-3d0e2fea8a28.c7bd1399.384x384o.4830acf9a24d.png',
    bots: [
      BotPersonality(
        id: 'carlsen_style',
        name: 'Carlsen Style',
        nameUz: 'Carlsen Uslubi',
        description: 'Modern style',
        avatar: '👑',
        style: 'modern',
        difficulties: _createStandardDifficulties(2300, 2900),
      ),
      BotPersonality(
        id: 'kasparov_style',
        name: 'Kasparov Style',
        nameUz: 'Kasparov Uslubi',
        description: 'Classic attacker',
        avatar: '♔',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(2300, 2900),
      ),
      BotPersonality(
        id: 'tal_style',
        name: 'Tal Style',
        nameUz: 'Tal Uslubi',
        description: 'Magical combinations',
        avatar: '🎩',
        style: 'tactical_genius',
        difficulties: _createStandardDifficulties(2200, 2800),
      ),
      BotPersonality(
        id: 'capablanca_style',
        name: 'Capablanca Style',
        nameUz: 'Capablanca Uslubi',
        description: 'Simple and effective',
        avatar: '♕',
        style: 'classical',
        difficulties: _createStandardDifficulties(2200, 2800),
      ),
      BotPersonality(
        id: 'fischer_style',
        name: 'Fischer Style',
        nameUz: 'Fischer Uslubi',
        description: 'Accurate and strong',
        avatar: '⚡',
        style: 'precise',
        difficulties: _createStandardDifficulties(2250, 2850),
      ),
    ],
  );

  // Personalities Category
  static final personalities = BotCategory(
    id: 'personalities',
    name: 'Personalities',
    nameUz: 'Shaxslar',
    description: 'Bots with different characters',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/f5c5d62c-8a5c-11ea-b5c1-f37a942bbe27.5fa49534.384x384o.391b0018feb6.png',
    bots: [
      BotPersonality(
        id: 'aggressive_anvar',
        name: 'Aggressive Anvar',
        nameUz: 'Hujumchi Anvar',
        description: 'Always attacks',
        avatar: '😤',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(1000, 1600),
      ),
      BotPersonality(
        id: 'defensive_davron',
        name: 'Defensive Davron',
        nameUz: 'Himoyachi Davron',
        description: 'Solid defense',
        avatar: '🛡️',
        style: 'defensive',
        difficulties: _createStandardDifficulties(1000, 1600),
      ),
      BotPersonality(
        id: 'patient_parviz',
        name: 'Patient Parviz',
        nameUz: 'Sabr-toqatli Parviz',
        description: 'Patiently improves position',
        avatar: '😌',
        style: 'patient',
        difficulties: _createStandardDifficulties(1100, 1700),
      ),
      BotPersonality(
        id: 'tricky_tohir',
        name: 'Tricky Tohir',
        nameUz: 'Ayyor Tohir',
        description: 'Sets traps',
        avatar: '😏',
        style: 'tricky',
        difficulties: _createStandardDifficulties(1050, 1650),
      ),
      BotPersonality(
        id: 'blitz_bekzod',
        name: 'Blitz Bekzod',
        nameUz: 'Blitz Bekzod',
        description: 'Fast and dangerous',
        avatar: '⚡',
        style: 'blitz',
        difficulties: _createStandardDifficulties(1200, 1800),
      ),
      BotPersonality(
        id: 'endgame_expert',
        name: 'Endgame Expert',
        nameUz: 'Endshpil Ustasi',
        description: 'Strong in endgame',
        avatar: '♟️',
        style: 'endgame_specialist',
        difficulties: _createStandardDifficulties(1300, 1900),
      ),
    ],
  );

  // Engine Category - Pure computer strength
  static final engine = BotCategory(
    id: 'engine',
    name: 'Engine',
    nameUz: 'Engine',
    description: 'Pure computer power',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/4c07340e-8a5d-11ea-9abb-79b3443058a1.6bfb2f43.384x384o.9fad36f33baf.png',
    bots: [
      BotPersonality(
        id: 'stockfish_easy',
        name: 'Stockfish 1',
        nameUz: 'Stockfish 1',
        description: 'Easy level',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(800, 1200),
      ),
      BotPersonality(
        id: 'stockfish_medium',
        name: 'Stockfish 5',
        nameUz: 'Stockfish 5',
        description: 'Medium level',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(1400, 1800),
      ),
      BotPersonality(
        id: 'stockfish_hard',
        name: 'Stockfish 10',
        nameUz: 'Stockfish 10',
        description: 'Hard level',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(2000, 2400),
      ),
      BotPersonality(
        id: 'stockfish_max',
        name: 'Stockfish 16',
        nameUz: 'Stockfish 16',
        description: 'Maximum strength',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(2600, 3200),
      ),
    ],
  );

  // All categories list
  static final List<BotCategory> all = [
    beginner,
    intermediate,
    advanced,
    master,
    athletes,
    musicians,
    topPlayers,
    personalities,
    engine,
  ];

  static BotCategory? getById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper to create standard difficulty levels
  static Map<String, BotDifficulty> _createStandardDifficulties(
    int minRating,
    int maxRating,
  ) {
    final range = maxRating - minRating;
    final step = range ~/ 3;

    return {
      'easy': BotDifficulty(
        level: 'easy',
        minRating: minRating,
        maxRating: minRating + step,
        searchDepth: 3,
        errorRate: 0.15,
        useOpeningBook: false,
        usePieceSquareTables: true,
      ),
      'medium': BotDifficulty(
        level: 'medium',
        minRating: minRating + step,
        maxRating: minRating + step * 2,
        searchDepth: 4,
        errorRate: 0.08,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      'hard': BotDifficulty(
        level: 'hard',
        minRating: minRating + step * 2,
        maxRating: maxRating - step ~/ 2,
        searchDepth: 5,
        errorRate: 0.03,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      'maximum': BotDifficulty(
        level: 'maximum',
        minRating: maxRating - step ~/ 2,
        maxRating: maxRating,
        searchDepth: 6,
        errorRate: 0.01,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    };
  }

  static Map<String, BotDifficulty> _createEngineDifficulties(
    int minRating,
    int maxRating,
  ) {
    final range = maxRating - minRating;
    final step = range ~/ 3;

    return {
      'easy': BotDifficulty(
        level: 'easy',
        minRating: minRating,
        maxRating: minRating + step,
        searchDepth: 4,
        errorRate: 0.05,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      'medium': BotDifficulty(
        level: 'medium',
        minRating: minRating + step,
        maxRating: minRating + step * 2,
        searchDepth: 6,
        errorRate: 0.02,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      'hard': BotDifficulty(
        level: 'hard',
        minRating: minRating + step * 2,
        maxRating: maxRating - step ~/ 2,
        searchDepth: 7,
        errorRate: 0.01,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      'maximum': BotDifficulty(
        level: 'maximum',
        minRating: maxRating - step ~/ 2,
        maxRating: maxRating,
        searchDepth: 8,
        errorRate: 0.005,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    };
  }
}
