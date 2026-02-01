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
    description: 'Yangi boshlovchilar uchun oson botlar',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/a6e19caa-8a5a-11ea-b74e-55003725fb61.909cbd47.384x384o.c4d23e9051ff.png',
    bots: [
      BotPersonalities.all[0], // Rustam
      // More beginner bots...
    ],
  );

  // Intermediate Category
  static final intermediate = BotCategory(
    id: 'intermediate',
    name: 'Intermediate',
    nameUz: 'O\'rtacha',
    description: 'O\'rta darajadagi o\'yinchilar uchun',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/ee8ff9d8-8a5b-11ea-ad88-f9bb1877a81f.c17c3d32.384x384o.3072a453d392.png',
    bots: [
      BotPersonalities.all[1], // Nodira
      BotPersonalities.all[2], // Jahongir
    ],
  );

  // Advanced Category
  static final advanced = BotCategory(
    id: 'advanced',
    name: 'Advanced',
    nameUz: 'Murakkab',
    description: 'Tajribali o\'yinchilar uchun',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/30326f88-8a5c-11ea-b234-9b639e301bef.adf1facd.384x384o.39ecdf8795d5.png',
    bots: [
      BotPersonalities.all[3], // Dilshod
      BotPersonalities.all[4], // Sarvar
    ],
  );

  // Master Category
  static final master = BotCategory(
    id: 'master',
    name: 'Master',
    nameUz: 'Master',
    description: 'Eng kuchli botlar',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/bdd36e82-8a5c-11ea-b774-516d3353b2f2.7af80eea.384x384o.74b89e2e6267.png',
    bots: [
      BotPersonalities.all[5], // Shohzoda
    ],
  );

  // Athletes Category
  static final athletes = BotCategory(
    id: 'athletes',
    name: 'Athletes',
    nameUz: 'Sportchilar',
    description: 'Mashhur sportchilar uslubida',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/811d9ab4-1b8c-11f0-86ce-efd0265768a6.cfa8800c.384x384o.62368d7c284b.png',
    bots: [
      BotPersonality(
        id: 'ronaldo',
        name: 'Ronaldo',
        nameUz: 'Ronaldo',
        description: 'Hujum qiluvchi uslub, tez o\'yin',
        avatar: '⚽',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(1200, 1800),
      ),
      BotPersonality(
        id: 'messi',
        name: 'Messi',
        nameUz: 'Messi',
        description: 'Pozitsion o\'yin, aniq hisob',
        avatar: '⚽',
        style: 'positional',
        difficulties: _createStandardDifficulties(1200, 1800),
      ),
    ],
  );

  // Musicians Category
  static final musicians = BotCategory(
    id: 'musicians',
    name: 'Musicians',
    nameUz: 'Musiqachilar',
    description: 'Mashhur musiqachilar uslubida',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/909edaa2-f2d4-11ee-9c29-ff0b4f8c352f.a0248349.384x384o.f265173ed1e8.png',
    bots: [
      BotPersonality(
        id: 'beethoven',
        name: 'Beethoven',
        nameUz: 'Betxoven',
        description: 'Klassik uslub, chuqur strategiya',
        avatar: '🎵',
        style: 'classical',
        difficulties: _createStandardDifficulties(1400, 2000),
      ),
      BotPersonality(
        id: 'mozart',
        name: 'Mozart',
        nameUz: 'Motsart',
        description: 'Ijodiy va tez o\'yin',
        avatar: '🎵',
        style: 'creative',
        difficulties: _createStandardDifficulties(1400, 2000),
      ),
    ],
  );

  // Top Players Category
  static final topPlayers = BotCategory(
    id: 'top_players',
    name: 'Top Players',
    nameUz: 'Top O\'yinchilar',
    description: 'Jahon shaxmat chempionlari',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/faffe24a-8a5c-11ea-8907-3d0e2fea8a28.c7bd1399.384x384o.4830acf9a24d.png',
    bots: [
      BotPersonality(
        id: 'magnus',
        name: 'Magnus',
        nameUz: 'Magnus',
        description: 'Jahon chempioni Magnus Carlsen uslubida',
        avatar: '👑',
        style: 'world_champion',
        difficulties: _createStandardDifficulties(2200, 2800),
      ),
      BotPersonality(
        id: 'kasparov',
        name: 'Kasparov',
        nameUz: 'Kasparov',
        description: 'Garri Kasparov - hujumchi uslub',
        avatar: '♔',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(2200, 2800),
      ),
    ],
  );

  // Personalities Category
  static final personalities = BotCategory(
    id: 'personalities',
    name: 'Personalities',
    nameUz: 'Shaxslar',
    description: 'Turli xarakterli botlar',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/f5c5d62c-8a5c-11ea-b5c1-f37a942bbe27.5fa49534.384x384o.391b0018feb6.png',
    bots: [
      BotPersonality(
        id: 'aggressive_andy',
        name: 'Aggressive Andy',
        nameUz: 'Hujumchi Anvar',
        description: 'Doimo hujum qiladi',
        avatar: '😤',
        style: 'aggressive',
        difficulties: _createStandardDifficulties(1000, 1600),
      ),
      BotPersonality(
        id: 'defensive_david',
        name: 'Defensive David',
        nameUz: 'Himoyachi Davron',
        description: 'Mustahkam himoya',
        avatar: '🛡️',
        style: 'defensive',
        difficulties: _createStandardDifficulties(1000, 1600),
      ),
    ],
  );

  // Engine Category - Pure computer strength
  static final engine = BotCategory(
    id: 'engine',
    name: 'Engine',
    nameUz: 'Engine',
    description: 'Sof kompyuter kuchi',
    imageUrl: 'https://images.chesscomfiles.com/uploads/v1/bot_personality/4c07340e-8a5d-11ea-9abb-79b3443058a1.6bfb2f43.384x384o.9fad36f33baf.png',
    bots: [
      BotPersonality(
        id: 'stockfish_easy',
        name: 'Stockfish 1',
        nameUz: 'Stockfish 1',
        description: 'Oson daraja',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(800, 1200),
      ),
      BotPersonality(
        id: 'stockfish_medium',
        name: 'Stockfish 5',
        nameUz: 'Stockfish 5',
        description: 'O\'rtacha daraja',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(1400, 1800),
      ),
      BotPersonality(
        id: 'stockfish_hard',
        name: 'Stockfish 10',
        nameUz: 'Stockfish 10',
        description: 'Qiyin daraja',
        avatar: '🤖',
        style: 'engine',
        difficulties: _createEngineDifficulties(2000, 2400),
      ),
      BotPersonality(
        id: 'stockfish_max',
        name: 'Stockfish 16',
        nameUz: 'Stockfish 16',
        description: 'Maksimal kuch',
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
