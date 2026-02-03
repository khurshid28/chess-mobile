class LeaderboardEntryModel {
  final String userId;
  final String displayName;
  final int totalStars;
  final int tournamentsPlayed;
  final int wins;
  final int rank;
  final int? elo;
  final String? avatarUrl;

  LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.totalStars,
    required this.tournamentsPlayed,
    required this.wins,
    required this.rank,
    this.elo,
    this.avatarUrl,
  });

  factory LeaderboardEntryModel.fromFirestore(
    String userId,
    Map<String, dynamic> data,
  ) {
    return LeaderboardEntryModel(
      userId: userId,
      displayName: data['displayName'] ?? 'Unknown',
      totalStars: data['totalStars'] ?? 0,
      tournamentsPlayed: data['tournamentsPlayed'] ?? 0,
      wins: data['wins'] ?? 0,
      rank: data['rank'] ?? 0,
      elo: data['elo'],
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'totalStars': totalStars,
      'tournamentsPlayed': tournamentsPlayed,
      'wins': wins,
      'rank': rank,
      'elo': elo,
      'avatarUrl': avatarUrl,
    };
  }

  bool get isPodium => rank <= 3;

  String get rankDisplay {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  LeaderboardEntryModel copyWith({
    String? userId,
    String? displayName,
    int? totalStars,
    int? tournamentsPlayed,
    int? wins,
    int? rank,
    int? elo,
    String? avatarUrl,
  }) {
    return LeaderboardEntryModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      totalStars: totalStars ?? this.totalStars,
      tournamentsPlayed: tournamentsPlayed ?? this.tournamentsPlayed,
      wins: wins ?? this.wins,
      rank: rank ?? this.rank,
      elo: elo ?? this.elo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
