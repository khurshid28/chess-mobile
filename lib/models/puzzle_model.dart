class PuzzleModel {
  final String id;
  final int rating;
  final String initialPgn;

  final List<String> solution;
  final List<String> themes;

  PuzzleModel({
    required this.id,
    required this.rating,
    required this.initialPgn,
    required this.solution,
    required this.themes,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    // Handle both Lichess API format and our cached format
    if (json.containsKey('game') || json.containsKey('puzzle')) {
      // Lichess API response format
      final game = json['game'] ?? {};
      final puzzle = json['puzzle'] ?? {};

      return PuzzleModel(
        id: puzzle['id']?.toString() ?? 'unknown_id',
        rating: puzzle['rating'] ?? 1500,
        initialPgn: game['pgn'] ?? '',
        solution: List<String>.from(puzzle['solution'] ?? []),
        themes: List<String>.from(puzzle['themes'] ?? []),
      );
    } else {
      // Our cached format
      return PuzzleModel(
        id: json['id']?.toString() ?? 'unknown_id',
        rating: json['rating'] ?? 1500,
        initialPgn: json['initialPgn'] ?? '',
        solution: List<String>.from(json['solution'] ?? []),
        themes: List<String>.from(json['themes'] ?? []),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'initialPgn': initialPgn,
      'solution': solution,
      'themes': themes,
    };
  }
}
