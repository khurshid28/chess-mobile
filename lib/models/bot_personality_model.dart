class BotDifficulty {
  final String level; // 'easy', 'medium', 'hard', 'maximum'
  final int minRating;
  final int maxRating;
  final int searchDepth;
  final double errorRate; // 0.0-1.0 (probability of making mistakes)
  final bool useOpeningBook;
  final bool usePieceSquareTables;

  const BotDifficulty({
    required this.level,
    required this.minRating,
    required this.maxRating,
    required this.searchDepth,
    required this.errorRate,
    this.useOpeningBook = false,
    this.usePieceSquareTables = false,
  });

  int get averageRating => (minRating + maxRating) ~/ 2;
}

class BotPersonality {
  final String id;
  final String name;
  final String nameUz;
  final String description;
  final String avatar; // emoji
  final String style; // 'beginner', 'balanced', 'aggressive', 'defensive', 'positional'
  final Map<String, BotDifficulty> difficulties;

  const BotPersonality({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.description,
    required this.avatar,
    required this.style,
    required this.difficulties,
  });

  BotDifficulty get easy => difficulties['easy']!;
  BotDifficulty get medium => difficulties['medium']!;
  BotDifficulty get hard => difficulties['hard']!;
  BotDifficulty get maximum => difficulties['maximum']!;

  BotDifficulty getDifficulty(String level) => difficulties[level]!;
}

class BotPersonalities {
  static const List<BotPersonality> all = [
    // Bot #1: Rustam - Beginner (400-900)
    BotPersonality(
      id: 'rustam',
      name: 'Rustam',
      nameUz: 'Rustam',
      description: 'Yangi o\'rganayotgan o\'yinchi, ba\'zan xato qiladi',
      avatar: '🧑',
      style: 'beginner',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 400,
          maxRating: 500,
          searchDepth: 1,
          errorRate: 0.4,
          useOpeningBook: false,
          usePieceSquareTables: false,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 550,
          maxRating: 650,
          searchDepth: 2,
          errorRate: 0.25,
          useOpeningBook: false,
          usePieceSquareTables: false,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 700,
          maxRating: 800,
          searchDepth: 2,
          errorRate: 0.15,
          useOpeningBook: false,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 850,
          maxRating: 900,
          searchDepth: 3,
          errorRate: 0.05,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),

    // Bot #2: Nodira - Learning (700-1250)
    BotPersonality(
      id: 'nodira',
      name: 'Nodira',
      nameUz: 'Nodira',
      description: 'Maktab o\'quvchisi, strategiya o\'rganyapti',
      avatar: '👧',
      style: 'learning',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 700,
          maxRating: 800,
          searchDepth: 2,
          errorRate: 0.2,
          useOpeningBook: false,
          usePieceSquareTables: false,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 850,
          maxRating: 950,
          searchDepth: 3,
          errorRate: 0.12,
          useOpeningBook: false,
          usePieceSquareTables: true,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 1000,
          maxRating: 1100,
          searchDepth: 3,
          errorRate: 0.08,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 1150,
          maxRating: 1250,
          searchDepth: 4,
          errorRate: 0.03,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),

    // Bot #3: Jahongir - Club Player (1000-1700)
    BotPersonality(
      id: 'jahongir',
      name: 'Jahongir',
      nameUz: 'Jahongir',
      description: 'Mahalliy klub o\'yinchisi, taktika yaxshi biladi',
      avatar: '🧔',
      style: 'balanced',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 1000,
          maxRating: 1150,
          searchDepth: 3,
          errorRate: 0.1,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 1200,
          maxRating: 1350,
          searchDepth: 4,
          errorRate: 0.05,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 1400,
          maxRating: 1550,
          searchDepth: 4,
          errorRate: 0.02,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 1600,
          maxRating: 1700,
          searchDepth: 5,
          errorRate: 0.01,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),

    // Bot #4: Dilshod - Tournament Player (1400-2100)
    BotPersonality(
      id: 'dilshod',
      name: 'Dilshod',
      nameUz: 'Dilshod',
      description: 'Turnir o\'yinchisi, strategik fikrlaydi',
      avatar: '👨‍💼',
      style: 'positional',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 1400,
          maxRating: 1550,
          searchDepth: 4,
          errorRate: 0.05,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 1600,
          maxRating: 1750,
          searchDepth: 5,
          errorRate: 0.02,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 1800,
          maxRating: 1950,
          searchDepth: 5,
          errorRate: 0.01,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 2000,
          maxRating: 2100,
          searchDepth: 6,
          errorRate: 0.005,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),

    // Bot #5: Sarvar - Expert (1700-2400)
    BotPersonality(
      id: 'sarvar',
      name: 'Sarvar',
      nameUz: 'Sarvar',
      description: 'Tajribali ustoz, pozitsion o\'yin',
      avatar: '🎓',
      style: 'expert',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 1700,
          maxRating: 1850,
          searchDepth: 5,
          errorRate: 0.02,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 1900,
          maxRating: 2050,
          searchDepth: 6,
          errorRate: 0.01,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 2100,
          maxRating: 2250,
          searchDepth: 6,
          errorRate: 0.005,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 2300,
          maxRating: 2400,
          searchDepth: 7,
          errorRate: 0.002,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),

    // Bot #6: Shohzoda - Master (2000-2800)
    BotPersonality(
      id: 'shohzoda',
      name: 'Shohzoda',
      nameUz: 'Shohzoda',
      description: 'Master darajasi, juda kuchli o\'ynaydi',
      avatar: '👑',
      style: 'master',
      difficulties: {
        'easy': BotDifficulty(
          level: 'easy',
          minRating: 2000,
          maxRating: 2150,
          searchDepth: 6,
          errorRate: 0.01,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'medium': BotDifficulty(
          level: 'medium',
          minRating: 2200,
          maxRating: 2350,
          searchDepth: 7,
          errorRate: 0.005,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'hard': BotDifficulty(
          level: 'hard',
          minRating: 2400,
          maxRating: 2550,
          searchDepth: 7,
          errorRate: 0.002,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
        'maximum': BotDifficulty(
          level: 'maximum',
          minRating: 2600,
          maxRating: 2800,
          searchDepth: 8,
          errorRate: 0.001,
          useOpeningBook: true,
          usePieceSquareTables: true,
        ),
      },
    ),
  ];

  static BotPersonality? getById(String id) {
    try {
      return all.firstWhere((bot) => bot.id == id);
    } catch (e) {
      return null;
    }
  }
}
