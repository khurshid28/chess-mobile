import 'bot_personality_model.dart';

class BotCategory {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<BotPersonality> bots;

  const BotCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.bots,
  });

  int get botCount => bots.length;
  
  int get minRating {
    if (bots.isEmpty) return 0;
    return bots.map((b) => b.rating).reduce((a, b) => a < b ? a : b);
  }
  
  int get maxRating {
    if (bots.isEmpty) return 0;
    return bots.map((b) => b.rating).reduce((a, b) => a > b ? a : b);
  }
}

class BotCategories {
  // Beginner Category (400-800)
  static const beginner = BotCategory(
    id: 'beginner',
    name: 'Beginner',
    description: 'Easy bots for beginners',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/a6e19caa-8a5a-11ea-b74e-55003725fb61.909cbd47.384x384o.c4d23e9051ff.png',
    bots: [
      BotPersonality(
        id: 'leo',
        name: 'Leo',
        description: 'Just learned how pieces move',
        avatar: '🧒',
        style: 'beginner',
        rating: 400,
        searchDepth: 1,
        errorRate: 0.45,
      ),
      BotPersonality(
        id: 'mia',
        name: 'Mia',
        description: 'Learning basic tactics',
        avatar: '👧',
        style: 'beginner',
        rating: 500,
        searchDepth: 1,
        errorRate: 0.40,
      ),
      BotPersonality(
        id: 'sam',
        name: 'Sam',
        description: 'School chess club member',
        avatar: '👦',
        style: 'beginner',
        rating: 600,
        searchDepth: 2,
        errorRate: 0.35,
      ),
      BotPersonality(
        id: 'emma',
        name: 'Emma',
        description: 'Plays for fun',
        avatar: '👧',
        style: 'beginner',
        rating: 700,
        searchDepth: 2,
        errorRate: 0.30,
      ),
      BotPersonality(
        id: 'jack',
        name: 'Jack',
        description: 'Getting better every day',
        avatar: '🧑',
        style: 'beginner',
        rating: 800,
        searchDepth: 2,
        errorRate: 0.25,
      ),
    ],
  );

  // Intermediate Category (900-1400)
  static const intermediate = BotCategory(
    id: 'intermediate',
    name: 'Intermediate',
    description: 'For developing players',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/ee8ff9d8-8a5b-11ea-ad88-f9bb1877a81f.c17c3d32.384x384o.3072a453d392.png',
    bots: [
      BotPersonality(
        id: 'oliver',
        name: 'Oliver',
        description: 'Knows basic openings',
        avatar: '🧔',
        style: 'balanced',
        rating: 900,
        searchDepth: 3,
        errorRate: 0.20,
        useOpeningBook: true,
      ),
      BotPersonality(
        id: 'sophia',
        name: 'Sophia',
        description: 'Loves tactical puzzles',
        avatar: '👩',
        style: 'tactical',
        rating: 1000,
        searchDepth: 3,
        errorRate: 0.18,
        useOpeningBook: true,
      ),
      BotPersonality(
        id: 'lucas',
        name: 'Lucas',
        description: 'Club tournament player',
        avatar: '🧑',
        style: 'balanced',
        rating: 1100,
        searchDepth: 3,
        errorRate: 0.15,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'ava',
        name: 'Ava',
        description: 'Solid defensive play',
        avatar: '👩',
        style: 'defensive',
        rating: 1200,
        searchDepth: 4,
        errorRate: 0.12,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'ethan',
        name: 'Ethan',
        description: 'Aggressive attacker',
        avatar: '😤',
        style: 'aggressive',
        rating: 1300,
        searchDepth: 4,
        errorRate: 0.10,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'isabella',
        name: 'Isabella',
        description: 'Positional understanding',
        avatar: '👩‍🎓',
        style: 'positional',
        rating: 1400,
        searchDepth: 4,
        errorRate: 0.08,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // Advanced Category (1500-2000)
  static const advanced = BotCategory(
    id: 'advanced',
    name: 'Advanced',
    description: 'For experienced players',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/30326f88-8a5c-11ea-b234-9b639e301bef.adf1facd.384x384o.39ecdf8795d5.png',
    bots: [
      BotPersonality(
        id: 'william',
        name: 'William',
        description: 'Regional champion',
        avatar: '🎖️',
        style: 'balanced',
        rating: 1500,
        searchDepth: 4,
        errorRate: 0.06,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'charlotte',
        name: 'Charlotte',
        description: 'Endgame specialist',
        avatar: '♟️',
        style: 'endgame',
        rating: 1600,
        searchDepth: 5,
        errorRate: 0.05,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'james',
        name: 'James',
        description: 'Tournament regular',
        avatar: '🏆',
        style: 'balanced',
        rating: 1700,
        searchDepth: 5,
        errorRate: 0.04,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'amelia',
        name: 'Amelia',
        description: 'Chess coach',
        avatar: '👩‍🏫',
        style: 'positional',
        rating: 1800,
        searchDepth: 5,
        errorRate: 0.03,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'henry',
        name: 'Henry',
        description: 'Candidate Master',
        avatar: '🎯',
        style: 'tactical',
        rating: 1900,
        searchDepth: 5,
        errorRate: 0.025,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'mila',
        name: 'Mila',
        description: 'Expert level',
        avatar: '💫',
        style: 'balanced',
        rating: 2000,
        searchDepth: 5,
        errorRate: 0.02,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // Master Category (2100-2500)
  static const master = BotCategory(
    id: 'master',
    name: 'Master',
    description: 'Strongest human-like bots',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/bdd36e82-8a5c-11ea-b774-516d3353b2f2.7af80eea.384x384o.74b89e2e6267.png',
    bots: [
      BotPersonality(
        id: 'alexander',
        name: 'Alexander',
        description: 'FIDE Master',
        avatar: '👑',
        style: 'master',
        rating: 2100,
        searchDepth: 5,
        errorRate: 0.015,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'victoria',
        name: 'Victoria',
        description: 'International Master',
        avatar: '💎',
        style: 'positional',
        rating: 2200,
        searchDepth: 5,
        errorRate: 0.01,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'maximilian',
        name: 'Maximilian',
        description: 'Grandmaster level',
        avatar: '⭐',
        style: 'master',
        rating: 2300,
        searchDepth: 5,
        errorRate: 0.008,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'elizabeth',
        name: 'Elizabeth',
        description: 'Super Grandmaster',
        avatar: '🏅',
        style: 'elite',
        rating: 2400,
        searchDepth: 5,
        errorRate: 0.005,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'magnus',
        name: 'Magnus',
        description: 'World class',
        avatar: '👑',
        style: 'champion',
        rating: 2500,
        searchDepth: 5,
        errorRate: 0.003,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // Legends Category - Chess style bots
  static const legends = BotCategory(
    id: 'legends',
    name: 'Legends',
    description: 'Play famous chess styles',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/faffe24a-8a5c-11ea-8907-3d0e2fea8a28.c7bd1399.384x384o.4830acf9a24d.png',
    bots: [
      BotPersonality(
        id: 'attacker',
        name: 'The Attacker',
        description: 'Kasparov-style aggression',
        avatar: '⚔️',
        style: 'aggressive',
        rating: 1800,
        searchDepth: 5,
        errorRate: 0.04,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'magician',
        name: 'The Magician',
        description: 'Tal-style sacrifices',
        avatar: '🎩',
        style: 'tactical',
        rating: 1900,
        searchDepth: 5,
        errorRate: 0.05,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'machine',
        name: 'The Machine',
        description: 'Capablanca precision',
        avatar: '🤖',
        style: 'precise',
        rating: 2000,
        searchDepth: 5,
        errorRate: 0.025,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'genius',
        name: 'The Genius',
        description: 'Fischer accuracy',
        avatar: '⚡',
        style: 'perfect',
        rating: 2100,
        searchDepth: 5,
        errorRate: 0.02,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'universal',
        name: 'The Universal',
        description: 'Carlsen-style flexibility',
        avatar: '🌟',
        style: 'modern',
        rating: 2200,
        searchDepth: 5,
        errorRate: 0.015,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // Personalities Category
  static const personalities = BotCategory(
    id: 'personalities',
    name: 'Personalities',
    description: 'Unique playing styles',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/f5c5d62c-8a5c-11ea-b5c1-f37a942bbe27.5fa49534.384x384o.391b0018feb6.png',
    bots: [
      BotPersonality(
        id: 'blitzer',
        name: 'Blitzer',
        description: 'Lightning fast moves',
        avatar: '⚡',
        style: 'blitz',
        rating: 1400,
        searchDepth: 4,
        errorRate: 0.12,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'fortress',
        name: 'Fortress',
        description: 'Impenetrable defense',
        avatar: '🛡️',
        style: 'defensive',
        rating: 1500,
        searchDepth: 4,
        errorRate: 0.08,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'gambit',
        name: 'Gambit',
        description: 'Loves sacrifices',
        avatar: '🎲',
        style: 'gambit',
        rating: 1600,
        searchDepth: 5,
        errorRate: 0.10,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'trapper',
        name: 'Trapper',
        description: 'Sets deadly traps',
        avatar: '🕸️',
        style: 'tricky',
        rating: 1700,
        searchDepth: 5,
        errorRate: 0.07,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'grinder',
        name: 'Grinder',
        description: 'Never gives up',
        avatar: '💪',
        style: 'resilient',
        rating: 1800,
        searchDepth: 5,
        errorRate: 0.05,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // Engine Category
  static const engine = BotCategory(
    id: 'engine',
    name: 'Engine',
    description: 'Pure computer strength',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/4c07340e-8a5d-11ea-9abb-79b3443058a1.6bfb2f43.384x384o.9fad36f33baf.png',
    bots: [
      BotPersonality(
        id: 'engine_1',
        name: 'Engine Lv.1',
        description: 'Beginner engine',
        avatar: '🤖',
        style: 'engine',
        rating: 1000,
        searchDepth: 3,
        errorRate: 0.15,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'engine_3',
        name: 'Engine Lv.3',
        description: 'Easy engine',
        avatar: '🤖',
        style: 'engine',
        rating: 1400,
        searchDepth: 4,
        errorRate: 0.08,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'engine_5',
        name: 'Engine Lv.5',
        description: 'Medium engine',
        avatar: '🤖',
        style: 'engine',
        rating: 1800,
        searchDepth: 5,
        errorRate: 0.04,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'engine_8',
        name: 'Engine Lv.8',
        description: 'Hard engine',
        avatar: '🤖',
        style: 'engine',
        rating: 2200,
        searchDepth: 5,
        errorRate: 0.015,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'engine_10',
        name: 'Engine Lv.10',
        description: 'Expert engine',
        avatar: '🤖',
        style: 'engine',
        rating: 2500,
        searchDepth: 5,
        errorRate: 0.005,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
      BotPersonality(
        id: 'engine_max',
        name: 'Engine MAX',
        description: 'Maximum strength',
        avatar: '🔥',
        style: 'engine',
        rating: 3000,
        searchDepth: 6,
        errorRate: 0.001,
        useOpeningBook: true,
        usePieceSquareTables: true,
      ),
    ],
  );

  // All categories list
  static const List<BotCategory> all = [
    beginner,
    intermediate,
    advanced,
    master,
    legends,
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
  
  static BotPersonality? getBotById(String id) {
    for (final category in all) {
      for (final bot in category.bots) {
        if (bot.id == id) return bot;
      }
    }
    return null;
  }
}
