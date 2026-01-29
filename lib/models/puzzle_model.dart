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
    final game = json['game'] ?? {};
    final puzzle = json['puzzle'] ?? {};

    return PuzzleModel(
      id: puzzle['id']?.toString() ?? 'unknown_id',
      rating: puzzle['rating'] ?? 1500,
      initialPgn: game['pgn'] ?? '',

      solution: List<String>.from(puzzle['solution'] ?? []),
      themes: List<String>.from(puzzle['themes'] ?? []),
    );
  }
}
