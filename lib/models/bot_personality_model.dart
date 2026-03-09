class BotPersonality {
  final String id;
  final String name;
  final String description;
  final String avatar; // emoji
  final String style; // 'beginner', 'balanced', 'aggressive', 'defensive', 'positional'
  final int rating; // Exact rating
  final int searchDepth;
  final double errorRate; // 0.0-1.0 (probability of making mistakes)
  final bool useOpeningBook;
  final bool usePieceSquareTables;

  const BotPersonality({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.style,
    required this.rating,
    required this.searchDepth,
    required this.errorRate,
    this.useOpeningBook = false,
    this.usePieceSquareTables = false,
  });
}

class BotPersonalities {
  static BotPersonality? getById(String id) {
    // Search through all categories
    return null; // Will be handled by BotCategories
  }
}
