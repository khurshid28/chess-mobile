class BotGameHistory {
  final String id;
  final String userId;
  final String botId;
  final String botName;
  final int botRating;
  final String difficulty;
  final String result; // '1-0', '0-1', '1/2-1/2'
  final String resultReason;
  final List<String> moveHistory;
  final String userSide; // 'white' or 'black'
  final int movesPlayed;
  final int accuracy;
  final int ratingChange;
  final DateTime createdAt;

  BotGameHistory({
    required this.id,
    required this.userId,
    required this.botId,
    required this.botName,
    required this.botRating,
    required this.difficulty,
    required this.result,
    required this.resultReason,
    required this.moveHistory,
    required this.userSide,
    required this.movesPlayed,
    required this.accuracy,
    required this.ratingChange,
    required this.createdAt,
  });

  factory BotGameHistory.fromMap(Map<String, dynamic> map, String id) {
    return BotGameHistory(
      id: id,
      userId: map['userId'] ?? '',
      botId: map['botId'] ?? '',
      botName: map['botName'] ?? '',
      botRating: map['botRating'] ?? 1200,
      difficulty: map['difficulty'] ?? '',
      result: map['result'] ?? '',
      resultReason: map['resultReason'] ?? '',
      moveHistory: List<String>.from(map['moveHistory'] ?? []),
      userSide: map['userSide'] ?? 'white',
      movesPlayed: map['movesPlayed'] ?? 0,
      accuracy: map['accuracy'] ?? 0,
      ratingChange: map['ratingChange'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'botId': botId,
      'botName': botName,
      'botRating': botRating,
      'difficulty': difficulty,
      'result': result,
      'resultReason': resultReason,
      'moveHistory': moveHistory,
      'userSide': userSide,
      'movesPlayed': movesPlayed,
      'accuracy': accuracy,
      'ratingChange': ratingChange,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  bool get isWin {
    if (userSide == 'white') {
      return result == '1-0';
    } else {
      return result == '0-1';
    }
  }

  bool get isDraw => result == '1/2-1/2';
  bool get isLoss => !isWin && !isDraw;
}
