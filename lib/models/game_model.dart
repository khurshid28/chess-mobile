import 'package:cloud_firestore/cloud_firestore.dart';

enum GameStatus { waiting, inprogress, completed, error }

class PendingPromotion {
  final String from;
  final String to;
  final String color;
  PendingPromotion({required this.from, required this.to, required this.color});

  factory PendingPromotion.fromMap(Map<String, dynamic> map) {
    return PendingPromotion(
      from: map['from'],
      to: map['to'],
      color: map['color'],
    );
  }
}

class GameModel {
  final String id;
  final String fen;
  final String pgn;
  final GameStatus status;
  final List<String> participants;
  final String? playerWhiteId;
  final String? playerBlackId;
  final String? playerWhiteName;
  final String? playerBlackName;
  final String? playerWhiteImage;
  final String? playerBlackImage;
  final String turn;
  final String? winner;
  final String? outcome;
  final String? drawOfferFrom;
  final int whiteTimeLeft;
  final int blackTimeLeft;
  final Timestamp? lastMoveTimestamp;
  final PendingPromotion? pendingPromotion;
  final String? rematchOfferFrom;
  final String? nextGameId;
  final int initialTime;
  final int? playerWhiteElo;
  final int? playerBlackElo;
  final int? maxElo;
  final String? playerWhiteCountryCode;
  final String? playerBlackCountryCode;
  final String playerWhiteStatus;
  final String playerBlackStatus;
  final Timestamp? completedAt;
  final Timestamp? playerWhiteDisconnectedAt;
  final Timestamp? playerBlackDisconnectedAt;
  // Bot game fields
  final String gameType; // 'online' or 'computer'
  final String? botPersonalityId;
  final String? botDifficulty; // 'easy', 'medium', 'hard', 'maximum'
  // Tournament and ranking fields
  final bool isRanked; // Whether the game affects ELO rating
  final String? tournamentId; // ID of tournament if this is a tournament game
  final String? tournamentMatchId; // ID of specific match in tournament bracket

  GameModel({
    required this.id,
    required this.fen,
    this.pgn = '',
    this.status = GameStatus.waiting,
    this.participants = const [],
    this.playerWhiteId,
    this.playerBlackId,
    this.playerWhiteName,
    this.playerBlackName,
    this.playerWhiteImage,
    this.playerBlackImage,
    this.turn = 'w',
    this.winner,
    this.outcome,
    this.drawOfferFrom,
    required this.whiteTimeLeft,
    required this.blackTimeLeft,
    this.lastMoveTimestamp,
    this.pendingPromotion,
    this.rematchOfferFrom,
    this.nextGameId,
    this.initialTime = 300,
    this.playerWhiteElo,
    this.playerBlackElo,
    this.maxElo,
    this.playerWhiteCountryCode,
    this.playerBlackCountryCode,
    this.playerWhiteStatus = 'online',
    this.playerBlackStatus = 'online',
    this.completedAt,
    this.playerWhiteDisconnectedAt,
    this.playerBlackDisconnectedAt,
    this.gameType = 'online',
    this.botPersonalityId,
    this.botDifficulty,
    this.isRanked = true,
    this.tournamentId,
    this.tournamentMatchId,
  });

  bool get isBotGame => gameType == 'computer';

  factory GameModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final defaultTime = data['initialTime'] ?? 300;

    return GameModel(
      id: snapshot.id,
      fen:
          data['fen'] ??
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      pgn: data['pgn'] ?? '',

      status: GameStatus.values.firstWhere(
        (e) => e.toString() == 'GameStatus.${data['status']}',
        orElse: () {
          if (data['status'] == null) {
            return GameStatus.waiting;
          }
          return GameStatus.error;
        },
      ),
      participants: List<String>.from(data['participants'] ?? []),
      playerWhiteId: data['playerWhiteId'],
      playerBlackId: data['playerBlackId'],
      playerWhiteName: data['playerWhiteName'],
      playerBlackName: data['playerBlackName'],
      playerWhiteImage: data['playerWhiteImage'],
      playerBlackImage: data['playerBlackImage'],
      turn: data['turn'] ?? 'w',
      winner: data['winner'],
      outcome: data['outcome'],
      drawOfferFrom: data['drawOfferFrom'],
      whiteTimeLeft: data['whiteTimeLeft'] ?? defaultTime,
      blackTimeLeft: data['blackTimeLeft'] ?? defaultTime,
      lastMoveTimestamp: data['lastMoveTimestamp'],
      pendingPromotion: data['pendingPromotion'] != null
          ? PendingPromotion.fromMap(data['pendingPromotion'])
          : null,
      rematchOfferFrom: data['rematchOfferFrom'],
      nextGameId: data['nextGameId'],
      initialTime: data['initialTime'] ?? 300,
      playerWhiteElo: data['playerWhiteElo'],
      playerBlackElo: data['playerBlackElo'],
      maxElo: data['maxElo'],
      playerWhiteCountryCode: data['playerWhiteCountryCode'],
      playerBlackCountryCode: data['playerBlackCountryCode'],
      playerWhiteStatus: data['playerWhiteStatus'] ?? 'online',
      playerBlackStatus: data['playerBlackStatus'] ?? 'online',
      completedAt: data['completedAt'],
      playerWhiteDisconnectedAt: data['playerWhiteDisconnectedAt'],
      playerBlackDisconnectedAt: data['playerBlackDisconnectedAt'],
      gameType: data['gameType'] ?? 'online',
      botPersonalityId: data['botPersonalityId'],
      botDifficulty: data['botDifficulty'],
      isRanked: data['isRanked'] ?? true,
      tournamentId: data['tournamentId'],
      tournamentMatchId: data['tournamentMatchId'],
    );
  }
}
