import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus {
  pending,
  inProgress,
  completed,
}

class GameResult {
  final String gameId;
  final String result; // 'white', 'black', 'draw'
  final String playerColor; // 'white' or 'black'

  GameResult({
    required this.gameId,
    required this.result,
    required this.playerColor,
  });

  factory GameResult.fromMap(Map<String, dynamic> data) {
    return GameResult(
      gameId: data['gameId'] ?? '',
      result: data['result'] ?? '',
      playerColor: data['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'result': result,
      'color': playerColor,
    };
  }
}

class TournamentMatchModel {
  final String matchId;
  final String player1Id;
  final String player2Id;
  final String? player1Name;
  final String? player2Name;
  final int player1Score; // 0, 1, or 2
  final int player2Score; // 0, 1, or 2
  final String? winnerId;
  final MatchStatus status;
  final List<GameResult> games;
  final bool isArmageddon;

  TournamentMatchModel({
    required this.matchId,
    required this.player1Id,
    required this.player2Id,
    this.player1Name,
    this.player2Name,
    this.player1Score = 0,
    this.player2Score = 0,
    this.winnerId,
    this.status = MatchStatus.pending,
    this.games = const [],
    this.isArmageddon = false,
  });

  factory TournamentMatchModel.fromMap(Map<String, dynamic> data) {
    return TournamentMatchModel(
      matchId: data['matchId'] ?? '',
      player1Id: data['player1Id'] ?? '',
      player2Id: data['player2Id'] ?? '',
      player1Name: data['player1Name'],
      player2Name: data['player2Name'],
      player1Score: data['player1Score'] ?? 0,
      player2Score: data['player2Score'] ?? 0,
      winnerId: data['winnerId'],
      status: MatchStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MatchStatus.pending,
      ),
      games: (data['games'] as List<dynamic>?)
              ?.map((g) => GameResult.fromMap(g as Map<String, dynamic>))
              .toList() ??
          [],
      isArmageddon: data['isArmageddon'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'winnerId': winnerId,
      'status': status.name,
      'games': games.map((g) => g.toMap()).toList(),
      'isArmageddon': isArmageddon,
    };
  }

  bool get isCompleted => status == MatchStatus.completed;
  bool get needsArmageddon => player1Score == 1 && player2Score == 1;
  
  String get displayScore => '$player1Score - $player2Score';

  TournamentMatchModel copyWith({
    String? matchId,
    String? player1Id,
    String? player2Id,
    String? player1Name,
    String? player2Name,
    int? player1Score,
    int? player2Score,
    String? winnerId,
    MatchStatus? status,
    List<GameResult>? games,
    bool? isArmageddon,
  }) {
    return TournamentMatchModel(
      matchId: matchId ?? this.matchId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      winnerId: winnerId ?? this.winnerId,
      status: status ?? this.status,
      games: games ?? this.games,
      isArmageddon: isArmageddon ?? this.isArmageddon,
    );
  }
}

class TournamentRoundModel {
  final int round; // 1=1/8, 2=1/4, 3=Semi, 4=Final
  final List<TournamentMatchModel> matches;

  TournamentRoundModel({
    required this.round,
    required this.matches,
  });

  factory TournamentRoundModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TournamentRoundModel(
      round: data['round'] ?? 1,
      matches: (data['matches'] as List<dynamic>?)
              ?.map((m) => TournamentMatchModel.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'round': round,
      'matches': matches.map((m) => m.toMap()).toList(),
    };
  }

  String get roundName {
    switch (round) {
      case 1:
        return 'Round of 16';
      case 2:
        return 'Quarter Finals';
      case 3:
        return 'Semi Finals';
      case 4:
        return 'Final';
      default:
        return 'Round $round';
    }
  }
}
